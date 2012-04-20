require(survival)

# load data and compute time to first feedback
moodbar = read.table("data/time_to_1st_feedback.tsv", sep="\t", header=T)
moodbar$ttfeedback = moodbar$first_feedback_or_now - moodbar$first_edit_click

# compute and plot the estimate of the survival curve
km.fit = survfit(Surv(ttfeedback, is_uncensored)~1, data = moodbar)
plot(km.fit, conf.int=T, xlab="time since first edit click (days)",
     ylab="proportion with at least one feedbacks", lab=c(10,10,7))
mtext("K-M Survivor Function", 3, 1)
abline(h=0)

# compute and plot the hazard rate
km.fit$weight = km.fit$n.event / km.fit$n.risk
smooth = density(km.fit$time, kernel="epanechnikov", weights=km.fit$weight, 
                 from=0, to=max(km.fit$time), n = 1024)
plot(smooth$x, smooth$y, type="l", xlab="time since first edit click (days)",
     ylab="hazard rate", lab=c(10,10,7))
mtext("Hazard Function", 3, 1)
abline(h=0)

# zooming in the first 20 days
smooth_zoom = density(km.fit$time, kernel = "epanechnikov", 
                      weights=km.fit$weight,, from=0, to=20, n=128)

plot(smooth_zoom$x, smooth_zoom$y, type = "l", 
     xlab = "time since first edit click (days)", lab = c(10,10,7))
mtext("Hazard Function", 3, 1)
abline(h=0)

# print fit object
print(km.fit)

# estimate truncated mean survival time
tmst = 1 * km.fit$surv[1] + sum(km.fit$surv[2:length(km.fit$surv)] * 
  diff(km.fit$time))

sprintf("mean truncated survival time = %g days", tmst) 