library(zoo)
library(ggplot2)

# read data
RET <- read.table("../../data/retention_daily.csv", header=TRUE, sep="\t")

# add factor, date variable
RET <- within(RET, {
              reg <- as.Date(registration.date)
              age <- as.factor(account.age)
})

# scatter plot of group.size vs still.active
scatter.plot <- ggplot(RET, aes(x=group.size, y=still.active)) + geom_point() +
facet_wrap(~ age, ncol=2)  + geom_smooth(aes(group=age), method="lm", 
                                         se=FALSE) + xlab("group size") +
ylab("still active") 
print(scatter.plot) 
dev.copy2pdf(file="plots/group.size-still.active.pdf")
savePlot(file="plots/group.size-still.active.png", type="png")
dev.off()

# sort dates chronologically
sorted.reg <- as.Date(sort.int(with(subset(RET, age == 1), reg)))
N = length(sorted.reg)

# get sorting index
ix <- sort.int(with(subset(RET, age == 1), reg), index.return=TRUE)$ix
group <- with(subset(RET, age == 1), group[ix])

# ages vector
ages <- levels(RET$age)

# now compute autocorrelation functions

#
# still.active / raw
#
still.active <- with(RET, by(still.active, age, identity))
par(mfcol=c(3,2))
for (a in ages) {
    # convert to ts (irregular!), apply diff
    the.ts <- ts(zoo(still.active[[a]], order.by=sorted.reg), frequency=7)
    still.active[[a]] <- the.ts

    # plot ACF on raw series and save it to PDF
    acf(still.active[[a]], main = sprintf("still_active(%s)", a))
}
dev.copy2pdf(file="plots/acf_still_active.pdf")
savePlot(file="plots/acf_still_active.png", type="png")
dev.off()

#
# still.active / diff
#
still.active.diff <- list()
par(mfcol=c(3,2))
for (a in ages) {
    # apply differencing
    still.active.diff[[a]] <- diff(still.active[[a]])

    # plot ACF on the differenced series and save to PDF
    acf(still.active.diff[[a]], main = sprintf("still_active(%s)", a))
}
dev.copy2pdf(file="plots/acf_still_active_diff.pdf")
savePlot(file="plots/acf_still_active_diff.png", type="png")
dev.off()

#
# group.size / raw
#
group.size <- with(RET, by(group.size, age, identity))
par(mfcol=c(3,2))
for (a in ages) {
    # convert to ts (irregular!)
    the.ts <- ts(zoo(group.size[[a]], order.by=sorted.reg), frequency=7)
    group.size[[a]] <- the.ts

    # plot ACF on raw series and save it to PDF
    acf(group.size[[a]], main = sprintf("group_size(%s)", a))
}
dev.copy2pdf(file="plots/acf_group_size.pdf")
savePlot(file="plots/acf_group_size.png", type="png")
dev.off()

#
# group.size / diff
#
group.size.diff <- list()
par(mfcol=c(3,2))
for (a in ages) {
    # apply differencing
    group.size.diff[[a]] <- diff(group.size[[a]])

    # plot ACF on the differenced series and save to PDF
    acf(group.size.diff[[a]], main = sprintf("group_size(%s)", a))
}
dev.copy2pdf(file="plots/acf_group_size_diff.pdf")
savePlot(file="plots/acf_group_size_diff.png", type="png")
dev.off()

#
# retention -- raw
#
retention <- list()
par(mfcol=c(3,2))
for (a in ages) {
    # convert to ts (irregular!)
    retention[[a]] <- still.active[[a]] / group.size[[a]]

    # plot ACF on raw series and save it to PDF
    acf(retention[[a]], main = sprintf("retention(%s)", a))
}
dev.copy2pdf(file="plots/acf_retention.pdf")
savePlot(file="plots/acf_retention.png", type="png")
dev.off()

#
# retention -- diff
#
retention.diff <- list()
par(mfcol=c(3,2))
for (a in ages) {
    # apply differencing
    retention.diff[[a]] <- still.active.diff[[a]] / group.size.diff[[a]]

    # plot ACF on diff series and save it to PDF
    acf(retention.diff[[a]], main = sprintf("retention(%s)", a))
}
dev.copy2pdf(file="plots/acf_retention_diff.pdf")
savePlot(file="plots/acf_retention_diff.png", type="png")
dev.off()

# create data frame (with one element less than the original D.F.)
RET.diff <- data.frame(
                       reg = rep(sorted.reg[1:N-1], length(ages)),
                       ret = c(sapply(retention.diff, as.numeric)), 
                       group.size = as.vector(sapply(group.size, function(x) { 
                                                     x[1:N-1] }
                       )), 
                       age = as.factor(rep(as.numeric(ages), each=N-1)), 
                       group = as.factor(rep(group[1:N-1], length(ages)))
                  )

# print retention over time
retention.plot <- ggplot(RET.diff, aes(reg, ret, colour=group)) +
geom_area(alpha = .5) + facet_wrap(~ age, ncol=1) + xlab("registration date") +
ylab("retention (diff from baseline)")
print(retention.plot)
dev.copy2pdf(file="plots/retention_deseasonalized.pdf")
savePlot(file="plots/retention_deseasonalized.png", type="png")
dev.off()

group.ret <- with(RET.diff, tapply(ret, list(group, age), mean, simplify=FALSE))
print(group.ret)
