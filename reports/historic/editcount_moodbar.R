require(gdata) # aggregate.table
require(MASS) # glm.nb
require(ggplot2)

EC <- read.table('data/ec_mb.tsv', sep='\t', header=T, stringsAsFactors=T)
# relevel factors
EC <- within(EC, 
             user_id<-factor(user_id),
             treatment<-factor(treatment), 
             namespace<-relevel(namespace, ref="Main"),
             browser<-relevel(browser, ref="msie"),
             os<-relevel(os, ref="win"),
             mood<-relevel(mood, ref="happy"),
             )
levels(EC$treatment)<-c("Feedback", "Feed+Resp.", "Feed+Useful")
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

# # Plot smoothed growth curves as function of treatment and mood
# p <- ggplot(EC, aes(age, editcount, colour=mood, linestyle=treatment)) + geom_smooth(se=F, method=loess)
# p + xlab("Days since activation") + ylab("Avg. edit count")
# ggsave("moodbar_loess.png", width=6, height=4)

# base model
MoodBar.nb.base <- glm.nb(editcount ~ I(age - 1) + treatment + mood + cohort,
                          data=EC)
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
