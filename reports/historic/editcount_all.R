require(gdata) # aggregate.table
require(MASS) # glm.nb
require(ggplot2)

# Load the raw counts
EC <- read.table('data/ec.tsv', sep='\t', header=T, stringsAsFactors=T)

# make treatment a factor
EC$treatment <- factor(EC$treatment)
levels(EC$treatment) <- c("Reference", "Feedback", "Feed+Resp.", "Feed+Useful")

# print summary
summary(EC)

# scale and center ept_lag
EC$ept_lag <- scale(EC$ept_lag)

# conditional mean and standard dev.
cond.size <- table(EC$treatment, EC$age)
cond.mean <- aggregate.table(EC$editcount, EC$treatment, EC$age)
cond.std <- aggregate.table(EC$editcount, EC$treatment, EC$age, FUN=sd)
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
                             each=4)
                     )
ggplot(cmeans, aes(x = factor(treatment), y = cond.mean)) +
geom_bar(color="black", fill="white") + facet_grid(~ age) +
geom_errorbar(aes(ymax = cond.mean + cond.std / sqrt(cond.size), ymin =
                  cond.mean - cond.std / sqrt(cond.size), width=0.25)) +
xlab("Days since activation of MoodBar") + ylab("Avg. editcount")
ggsave("barplot_all_stderr.png", width=16, height=5)

# ## This takes too long ... maybe try different method?
# # Plot smoothed growth curves as function of treatment and mood
# p <- ggplot(EC, aes(age, editcount, colour=treatment)) + geom_smooth(se=F, method=loess)
# p + xlab("Days since activation") + ylab("Avg. edit count")
# ggsave("all_loess.png", width=6, height=4)

# base model (time interacts with treatment by default)
All.nb.base <- glm.nb(editcount ~ I(age - 1) * treatment + cohort, data=EC)
print(summary(All.nb.base))
anova(All.nb.base, test="Chisq")

# Control for ept_lag
All.nb.control <- update(All.nb.base, . ~ . + ept_lag)
print(summary(All.nb.control))
anova(All.nb.control, test="Chisq")

# Make new data frame with control variable set to its mean
EC.pred <- data.frame(age = rep(1:30, 4),
                      treatment = factor(rep(levels(EC$treatment), each=30)), 
                      cohort = rep(mean(EC$cohort), 120), 
                      ept_lag = rep(mean(EC$ept_lag), 120))


# give the data frame nice column names...
names(EC.pred) <- c("age", "treatment", "cohort", "ept_lag")

# ...and adjust dimensions otherwise predict() will complain
dim(EC.pred$ept_lag) <- c(120,1)

# compute average population prediction of editcount and plot lines
EC.pred$editcount <- predict(All.nb.control, EC.pred)
p <- ggplot(EC.pred, aes(y = editcount, x= age, linetype=treatment)) + geom_line()
p + xlab("Days since activation") + ylab("Avg. edit count") 
ggsave("all_predict.png", width=6, height=4) 

## # Uncomment the following for other alternatives
## # Poisson GLM
## m.pois <- glm(editcount ~ user_id + I(age - 1) + treatment + cohort, data=EC,
##               family="poisson")
## print(summary(m.pois))
## anova(m.pois, test="Chisq")
## 
## # Zero-inflated Negative Binomial GLM
## m.zinb <- zeroinfl(editcount ~ user_id + age + treatment + cohort, data=EC,
##                    dist="negbin")
## print(summary(m.nbz))

