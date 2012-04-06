require(survival)

# load data and compute time to first feedback
data = read.table("data/time_to_1st_feedback_10000.tsv", sep="\t", header=T)
data$ttfeedback = data$first_feedback_or_now - data$first_edit_click

# compute the estimate of the survival curve
km.fit = survfit(Surv(data$ttfeedback, data$is_uncensored)~1)
plot(km.fit, conf.int=T, xlab="time to first feedback (days)",
     ylab="proportion with at least one feedbacks", lab=c(10,10,7))
mtext("K-M Survivor Function", 3, 1)
abline(h=0)

