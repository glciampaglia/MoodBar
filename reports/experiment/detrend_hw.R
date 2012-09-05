library(zoo)
library(ggplot2)

# read data
RET <- read.table("../../data/retention_daily.csv", header=TRUE, sep="\t")

# add factor, date variable
RET <- within(RET, {
              reg <- as.Date(registration.date)
              age <- as.factor(account.age)
              ret <- still.active / group.size
})

mean.retention <- with(RET, by(ret, age, function(x) { mean(x) }))
ret.cent <- with(RET, by(ret, age, function(x) { x - mean(x) }))
RET$ret.cent <- stack(ret.cent)[,1]


# sort reg dates chronologically and group as well
sorted.reg <- sort.int(with(subset(RET, age == 1), reg), index.return=TRUE)
reg <- sorted.reg$x
ix <- sorted.reg$ix
group <- with(subset(RET, age == 1), group)[ix]
group.size <- with(subset(RET, age == 1), group.size)[ix]

# detrend function (uses HoltWinters)
detrend.fun <- function(x) {
    x.ts <- ts(zoo(x, order.by=reg), frequency=7)
    resid(HoltWinters(x.ts))
}

# detrend residuals
hw.resid <- with(RET, by(ret.cent, age, detrend.fun))

# plot auto-correlation function of detrended residuals
par(mfcol=c(3,2))
for (age in levels(RET$age)) {
     acf(hw.resid[[age]], main=sprintf("%s day(s)", age))
}
dev.copy2pdf(file="plots/acf_hw.resid.pdf")
dev.off()

# re-compute retention with detrended residuals
for (age in levels(RET$age)) {
    hw.resid[[age]] <- hw.resid[[age]] + mean.retention[[age]]
}

# re-create data frame with detrended residuals and original mean
N <- length(hw.resid[[1]])
N.ages <- length(levels(RET$age))
RET.det <- data.frame(
                      reg = rep(reg[1:N], N.ages),
                      ret = c(sapply(hw.resid, as.numeric)), 
                      group = as.factor(rep(group[1:N], N.ages)),
                      age = as.factor(rep(as.numeric(levels(RET$age)), each=N)),
                      group.size = rep(group.size[1:N], N.ages)
                      )

# plot the retention
p <- ggplot(RET.det, aes(x=reg, y=ret, colour=group)) +
geom_point(alpha=0.25) + facet_wrap(~ age, ncol=2) 
ggsave(p, filename="plots/money_hw.pdf")

# same but logistic regression with proportions data
logreg.fit <- glm(ret ~ age + group, weights=group.size, data = RET.det, 
                  family=gaussian())
print(summary(logreg.fit))

print(with(logreg.fit, cbind(res.deviance = deviance, df = df.residual, p =
                       pchisq(deviance, df.residual, lower.tail = FALSE))))

# add predictions to data frame
RET.det <- within(RET.det, {
              ret.hat <- predict(logreg.fit, type="response")
})

# probability plot
p1 <- ggplot(RET.det, aes(x=reg, y=ret, colour=group)) +
geom_area(alpha=0.5) + facet_wrap(~ age, ncol = 2) + xlab("date") +
ylab("retention probability") + scale_y_continuous(limits=c(0,0.5))
p1 <- p1 + geom_line(aes(x=RET.det$reg, y=RET.det$ret.hat, group=age), colour="black")
print(p1)
ggsave(p1, filename="plots/hw_retention_prob.pdf")
