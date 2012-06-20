require(gdata) # aggregate.table
require(MASS) # glm.nb
require(ggplot2)

EC <- read.table('data/ec_mb.tsv', sep='\t', header=T, stringsAsFactors=T)

# relevel factors, make treatment a factor
EC$user_id <- as.factor(EC$user_id)
EC$namespace <- relevel(EC$namespace, ref="Main")
EC$browser <-relevel(EC$browser, ref="msie")
EC$os <- relevel(EC$os, ref="win")
EC$mood <- relevel(EC$mood, ref="happy")
EC$treatment <- as.factor(EC$treatment)
levels(EC$treatment) <- c("Feedback", "Feed+Resp.", "Feed+Useful")

# print summary before rescaling
summary(EC)

# rescale control variables
EC <- within(EC,
             cohort<-scale(cohort),
             is_editing<-scale(is_editing),
             feedback_lag<-scale(feedback_lag),
             ept_lag<-scale(ept_lag),
             feedback_editcount<-scale(feedback_editcount),
             feedback_len<-scale(feedback_len),
             num_feedbacks<-scale(num_feedbacks)
             )

# conditional mean and standard dev. give evidence of overdispersion
cond.size <- table(EC$treatment, EC$age)
cond.mean <- aggregate.table(EC$editcount, EC$treatment, EC$age)
cond.std <- aggregate.table(EC$editcount, EC$treatment, EC$age, FUN = sd)
print(cond.size)
print(cond.mean)
print(cond.std)

# make a barplot of the cond.mean, with standard errors of the mean
cmeans <- data.frame(
                     cond.size=as.vector(cond.size),
                     cond.mean=as.vector(cond.mean),
                     cond.std=as.vector(cond.std),
                     treatment=rep(unlist(dimnames(cond.mean)[[1]]), 5),
                     age=rep(as.vector(dimnames(cond.mean)[[2]], mode="numeric"),
                             each=3)
                     )
ggplot(cmeans, aes(x = factor(treatment), y = cond.mean)) +
geom_bar(color="black", fill="white") + facet_grid(~ age) +
geom_errorbar(aes(ymax = cond.mean + cond.std / sqrt(cond.size), ymin =
                  cond.mean - cond.std / sqrt(cond.size), width=0.25)) +
xlab("Days since activation of MoodBar") + ylab("Avg. editcount")
ggsave("barplot_mb_stderr.png", width=14, height=5)

# Plot smoothed growth curves as function of treatment and mood
p <- ggplot(EC, aes(age, editcount, colour=mood)) + 
facet_grid(. ~ treatment) + geom_smooth(se=F, method=loess)
p <- p + stat_summary(aes(age, editcount), fun.y=mean, color="black",
                      fun.ymin = function(y) { mean(y) - sd(y) / sqrt(length(y)) },
                      fun.ymax = function(y) { mean(y) + sd(y) / sqrt(length(y)) })  
p + xlab("Days since activation") + ylab("Avg. edit count")
ggsave("moodbar_loess.png", width=10, height=3)

# base model (age interacts with treatment and mood by default)
MoodBar.nb.base <- glm.nb(editcount ~ I(age - 1) * (treatment + mood) + cohort,
                          data=EC, control=glm.control(trace=F, maxit=300))
print(summary(MoodBar.nb.base))
anova(MoodBar.nb.base, test="Chisq")

# adding interaction between mood and treatment
MoodBar.nb.int <- update(MoodBar.nb.base, . ~ . + mood : treatment)
print(summary(MoodBar.nb.int))
anova(MoodBar.nb.int, test="Chisq")

# controlling for feedback_len, lags, and editcount at moment of feedback and
# total number of feedbacks, is_editing
MoodBar.nb.cont <- update(MoodBar.nb.int, . ~ . + feedback_lag + ept_lag +
                          feedback_editcount + feedback_len + num_feedbacks +
                          is_editing)
print(summary(MoodBar.nb.cont))
anova(MoodBar.nb.cont, test="Chisq")

# controlling for additional parameters
MoodBar.nb.addcont <- update(MoodBar.nb.cont, . ~ . + namespace + browser + os + feedback_lag)
print(summary(MoodBar.nb.addcont))
anova(MoodBar.nb.addcont, test="Chisq")

# The best should be MoodBar.nb.addcont
AIC(MoodBar.nb.base, MoodBar.nb.int, MoodBar.nb.cont, MoodBar.nb.addcont)

# Make new data frame with control variables set to their mean values
EC.pred <- data.frame(age <- rep(1:30, 3),
                      treatment <- factor(rep(levels(EC$treatment), each=30)), 
                      mood <- factor(rep(levels(EC$mood), 30)),
                      cohort <- rep(mean(EC$cohort), 90), 
                      ept_lag <- rep(mean(EC$ept_lag), 90),
                      feedback_lag <- rep(mean(EC$feedback_lag), 90),
                      is_editing <- rep(mean(EC$is_editing), 90),
                      feedback_editcount <- rep(mean(EC$feedback_editcount),
                                                90),
                      num_feedbacks <- rep(mean(EC$num_feedbacks), 90),
                      namespace <- factor(rep("Main", 90)),
                      feedback_len <- rep(mean(EC$feedback_len, 90)),
                      os <- factor(rep("win", 90)),
                      browser <- factor(rep("msie", 90))
                      )

# give the data frame nice column names...
names(EC.pred) <- c("age", "treatment", "mood", "cohort", "ept_lag",
                    "feedback_lag", "is_editing", "feedback_editcount",
                    "num_feedbacks", "namespace", "feedback_len", "os",
                    "browser")

# ...and adjust dimension for those variable that need it, otherwise predict()
# will complain (don't ask yourself why cohort needs to be a (90x1) matrix
# though...
dim(EC.pred$cohort) <- c(90,1)

# compute average population prediction of editcount and plot lines
EC.pred$editcount <- predict(MoodBar.nb.addcont, EC.pred, type="response")
p <- ggplot(EC.pred, aes(y=editcount, x=age, colour=mood)) + 
facet_grid(. ~ treatment) + geom_line() + xlab("Days since activation") + 
ylab("Avg. edit count") 
ggsave("moodbar_predict.png", width=10, height=3) 
