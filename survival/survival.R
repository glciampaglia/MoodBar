require(survival)

data = read.table("data/time_to_1st_feedback_10000.tsv", sep="\t", header=T)
data$ttfeedback = data$first_feedback_or_now - data$first_edit_click
esf.fit = survfit(Surv(data$ttfeedback, data$is_uncensored)~1)
plot(esf.fit, conf.int=F, xlab="time to first feedback (days)", 
     ylab="proportion with at least one feedbacks", lab=c(10,10,7))
mtext("The Empirical Survivor Function of the MoodBar data", 3, -3)
# legend(75, .80, c())
abline(h=0)