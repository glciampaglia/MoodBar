# detrending by linear regression and differencing 

library(zoo)
library(ggplot2)

# read data
RET <- read.table("../../data/retention_daily.csv", header=TRUE, sep="\t")

# add factor, date variable
RET <- within(RET, {
              reg <- as.Date(registration.date)
              age <- as.factor(account.age)
#               wday <- as.POSIXlt(reg)$wday
#               wday <- as.factor(wday)
#               levels(wday) <- c("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat")
})

# get the residuals of the linear regression of still.active on the group.size
reg <- with(subset(RET, age == 1), reg)
N <- length(reg)
resid.by <- function(x) {
    resid(lm(still.active ~ group.size, data = x))
}

# make time series objects for both the full time series and the differenced one
ret.resid <- by(RET, RET$age, resid.by)
ret.resid.diff <- list()
for (age in levels(RET$age)) {
    ret.resid[[age]] <- ts(zoo(ret.resid[[age]], order.by=reg),
                               frequency=7)
    ret.resid.diff[[age]] <- ts(zoo(diff(ret.resid[[age]]),
                                    order.by=reg[1:N-1]), frequency=7)
}

# auto-correlation plot -- raw
par(mfcol=c(3,2))
for (age in levels(RET$age)) {
    acf(ret.resid[[age]], main=sprintf("%s days", age))
}
dev.copy2pdf(file="plots/acf_ret.resid.pdf")
dev.off()

# auto-correlation plot -- resid
par(mfcol=c(3,2))
for (age in levels(RET$age)) {
    acf(ret.resid.diff[[age]], main=sprintf("%s days", age))
}
dev.copy2pdf(file="plots/acf_ret.resid.diff.pdf")
dev.off()

# run-sequence plot -- raw
par(mfcol=c(3,2))
for (age in levels(RET$age)) {
    plot(ret.resid[[age]], main=sprintf("%s days", age),
         ylab="Residuals", xlab="Date", ylim=c(-100,100))
}
dev.copy2pdf(file="plots/runseq_ret.resid.pdf")
dev.off()

# run-sequence plot -- diff
par(mfcol=c(3,2))
for (age in levels(RET$age)) {
    plot(ret.resid.diff[[age]], main=sprintf("%s days", age),
         ylab="Residuals", xlab="Date", ylim=c(-100,100))
}
dev.copy2pdf(file="plots/runseq_ret.resid.diff.pdf")
dev.off()


# ggplot(RET, aes(x=reg, y=ret.resid)) + geom_line() + facet_wrap(~ age, ncol=2)
