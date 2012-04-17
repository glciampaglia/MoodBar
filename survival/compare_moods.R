require(survival)

# load data and compute time to first feedback
moodbar = read.table("data/time_to_1st_feedback.tsv", sep="\t", header=T)
moodbar$ttfeedback = moodbar$first_feedback_or_now - moodbar$first_edit_click

# take only uncensored observations and construct the KM estimator
moodbar1 = moodbar[moodbar$is_uncensored == 1,]
km.fit = survfit(Surv(ttfeedback, is_uncensored)~mood_code, data = moodbar1)
print(km.fit)

# plot the survival curves
plot(km.fit, conf.int=T, xlab="time since first edit click (days)",
     ylab="proportion with at least one feedbacks", lab=c(10,10,7), 
     main="K-M Survivor Function",  lty=1:3, log=T, col=1:3, xmax=20)
legend(14, 0.65, c("sad", "confused", "happy"), lty=1:3, col=1:3)
mtext("Comparison by mood type",3, -2)
abline(h=0)

# test difference between mood types -- using Peto & Peto's modification of the 
# Gheann-Wilcoxon test
survdiff(Surv(ttfeedback, is_uncensored)~mood_code, data=moodbar1, rho=1)