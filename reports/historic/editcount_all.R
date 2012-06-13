require(gdata) # aggregate.table
require(MASS) # glm.nb
require(ggplot2)

# Load the raw counts
EC <- read.table('data/ec_1000.tsv', sep='\t', header=T, stringsAsFactors=T)
EC <- within(EC, treatment <- factor(treatment), ept_lag <- scale(ept_lag))
levels(EC$treatment) <- c("Reference", "Feedback", "Feed+Resp.", "Feed+Useful")
summary(EC)

# conditional mean and standard dev.
cond.size <- table(EC$treatment, EC$age)
cond.mean <- aggregate.table(EC$editcount, EC$treatment, EC$age)
cond.std <- aggregate.table(EC$editcount, EC$treatment, EC$age, FUN=sd)
print(cond.size)
print(cond.mean)
print(cond.std)

# Plot smoothed growth curves as function of treatment and mood
p <- ggplot(EC, aes(age, editcount, colour=treatment)) + geom_smooth(se=F, method=loess)
p + xlab("Days since activation") + ylab("Avg. edit count")
ggsave("all_loess.png", width=6, height=4)

# base model
All.nb.base <- glm.nb(editcount ~ I(age - 1) + treatment + cohort, data=EC)
print(summary(All.nb.base))
anova(All.nb.base, test="Chisq")

# Control for ept_lag
All.nb.control <- update(All.nb.base, . ~ . + ept_lag)
print(summary(All.nb.control))
anova(All.nb.control, test="Chisq")

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

