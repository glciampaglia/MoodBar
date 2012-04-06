require(survival)

# load data and compute time to first feedback
data = read.table("data/time_to_1st_feedback_10000.tsv", sep="\t", header=T)
data$ttfeedback = data$first_feedback_or_now - data$first_edit_click

# compute and plot the estimate of the survival curve
km.fit = survfit(Surv(data$ttfeedback, data$is_uncensored)~1)
plot(km.fit, conf.int=T, xlab="time since first edit click (days)",
     ylab="proportion with at least one feedbacks", lab=c(10,10,7))
mtext("K-M Survivor Function", 3, 1)
abline(h=0)

# compute and plot the hazard rate
km.sum = summary(km.fit, censored=T)
weight.mb = km.sum$n.event / km.sum$n.risk
smooth.mb = density(km.sum$time, kernel="epanechnikov", weights=weight.mb, from=0, to=300)
plot(smooth.mb$x, smooth.mb$y, type="l", xlab="time since first edit click (days)",
     ylab="hazard rate", lab=c(10,10,7))
mtext("Hazard Function", 3, 1)
abline(h=0)