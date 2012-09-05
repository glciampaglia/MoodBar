library(zoo)
library(ggplot2)

##------------------------------------------------------------------------------
## INPUT STEP: read data into a frame and prepare it for analysis
##------------------------------------------------------------------------------

# read into a frame, add factors, compute retention
RET <- read.table("../../data/retention_daily.csv", header=TRUE, sep="\t")
RET <- within(RET, {
              reg <- as.Date(registration.date)
              age <- as.factor(account.age)
              ret <- still.active / group.size
})

# sort registration.date, group.size and group chronologically
sorted.reg <- sort.int(with(subset(RET, age == 1), reg), index.return=TRUE)
reg <- sorted.reg$x
ix <- sorted.reg$ix
group <- with(subset(RET, age == 1), group)[ix]
group.size <- with(subset(RET, age == 1), group.size)[ix]

##------------------------------------------------------------------------------
## PRE-PROCESSING STEP: de-trend and de-seasonalize the time series by applying
## the HoltWinters filter to the residuals of the retention about their mean
##------------------------------------------------------------------------------

# center the retention
mean.retention <- with(RET, by(ret, age, function(x) { mean(x) }))
ret.cent <- with(RET, by(ret, age, function(x) { x - mean(x) }))
RET$ret.cent <- stack(ret.cent)[,1]

# detrend function (uses HoltWinters)
detrend.fun <- function(x) {
    x.ts <- ts(zoo(x, order.by=reg), frequency=7)
    resid(HoltWinters(x.ts))
## uncomment the following to use an ARIMA model instead. It should give the
## same results.
#    residuals(arima(x.ts, order=c(1,1,1), seasonal=list(order=c(1,1,1))))
}

# detrend residuals
hw.resid <- with(RET, by(ret.cent, age, detrend.fun))

# check the auto-correlation plot to see if the pre-processing work. The plot
# should show only spurious auto-correlations, but no decay nor periodicity of
# the auto-correlation
par(mfcol=c(3,2))
for (age in levels(RET$age)) {
     acf(hw.resid[[age]], main=sprintf("%s day(s)", age))
}
dev.copy2pdf(file="plots/acf_hw.resid.pdf")
dev.off()

# construct detrended retention from the residuals of the HoltWinters filter (or
# the ARIMA model) and the original mean values
for (age in levels(RET$age)) {
    hw.resid[[age]] <- hw.resid[[age]] + mean.retention[[age]]
}

##------------------------------------------------------------------------------
## ANALYSIS STEP: apply a linear model to detect differences in group (i.e. the
## experimental treatments)
##------------------------------------------------------------------------------

# new data frame that is now amenable to analysis
N <- length(hw.resid[[1]])
N.ages <- length(levels(RET$age))
RET.det <- data.frame(
                      reg = rep(reg[1:N], N.ages),
                      ret = c(sapply(hw.resid, as.numeric)), 
                      group = as.factor(rep(group[1:N], N.ages)),
                      age = as.factor(rep(as.numeric(levels(RET$age)), each=N)),
                      group.size = rep(group.size[1:N], N.ages)
                      )

# apply regression analysis. Note that logistic regression is not feasible
# anymore because in general the detrended residuals give rise to non-integer
# successes counts. We thus use a simple gaussian GLM:
reg.fit <- glm(ret ~ age + group, weights=group.size, data = RET.det, 
                  family=gaussian())
print(summary(reg.fit))

# test GoF of the model. If the residual deviance is not significant then the
# model fits the data well (there is no significant difference from a saturated
# model)
print("Residual deviance test for the GLM:")
print(with(reg.fit, cbind(res.deviance = deviance, df = df.residual, p =
                       pchisq(deviance, df.residual, lower.tail = FALSE))))

# add predictions to data frame
RET.det <- within(RET.det, {
              ret.hat <- predict(reg.fit, type="response")
})

# make a "probability" plot (note the quotes: because we are not doing logistic
# regression anymore, but still we can interpret it as a retention probability)
p1 <- ggplot(RET.det, aes(x=reg, y=ret, colour=group)) +
geom_area(alpha=0.5) + facet_wrap(~ age, ncol = 2) + xlab("date") +
ylab("retention probability") + scale_y_continuous(limits=c(0,0.5))
p1 <- p1 + geom_line(aes(x=RET.det$reg, y=RET.det$ret.hat, group=age), colour="black")
print(p1)
ggsave(p1, filename="plots/hw_retention_prob.pdf")
