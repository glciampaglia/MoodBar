# TODO
# 1. fit of zero-inflated negative binomial and test if it gives an improvement on
#    the fit 
# 2. histogram of counts to give evidence of over-dispersion
# 3. Install package car and compute test for linear hypothesis
#    (car::linearHypothesis))
# 4. anova type III to test if the treatment is overall a statistically
#    significant factor (car::Anova)
# 5. try MASS::negative.binomial and play with different values of \theta < 0.1.
#    Then try again MASS::glm.nb with a starting value.
# 6. compute standard errors of poisson coefficients using sandwich estimator
# 7. do I need to put the user_id in the formula ??
# 8. test linear hypothesis (use linearHypothesis from package car)
# 9. sample a few user_ids with stratification and plot their trajectories, then fit
#    a spline model to the points. Use ggplot.

require(gdata) # aggregate.table
require(MASS) # glm.nb
require(pscl) # zeroinfl

# Load the raw counts
EC <- read.table('data/ec.tsv', sep='\t', header=T)
EC$treatment <- as.factor(EC$treatment)
levels(EC$treatment) <- c("Reference", "Feedback", "Feed+Resp.", "Feed+Useful")
summary(EC)

# conditional mean and standard dev.
cond.size <- table(EC$treatment, EC$age)
cond.mean <- aggregate.table(EC$editcount, EC$treatment, EC$age, fun = mean)
cond.std <- aggregate.table(EC$editcount, EC$treatment, EC$age, fun = sd)

print(cond.size)
print(cond.mean)
print(cond.std)

# Poisson GLM
m.pois <- glm(editcount ~ user_id + age + treatment + cohort, data=EC,
              family="poisson")
print(summary(m.pois))

## # Negative Binomial GLM 
## m.nb <- glm.nb(editcount ~ user_id + age + treatment + cohort, data=EC, 
##              control=glm.control(maxit=50, trace=1))
## print(summary(m.nb))
## 
## # Zero-inflated Negative Binomial GLM
## m.zinb <- zeroinfl(editcount ~ user_id + age + treatment + cohort, data=EC,
##                    dist="negbin")
## print(summary(m.nbz))
##
## # print summary and compute GoF
## m.pois$gof <- cbind(res.deviance=m.pois$deviance, df=m.pois$df.residual, 
##            p=1 - pchisq(m.pois$deviance, m.pois$df.residual))
## print(m.pois$gof)

