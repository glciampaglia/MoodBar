library(survival)
library(boot)
library(ggplot2)

moodbar = read.table("data/time_to_1st_feedback.tsv", sep="\t", header=T)
moodbar$ttfeedback = moodbar$first_feedback_or_now - moodbar$first_edit_click

# parameters for density
tfrom = 0
tto = max(moodbar$ttfeedback)
nn = 1024

# parameters for boot
R = 10000

hazard = function(data, ...) {
  surv = survfit(Surv(ttfeedback, is_uncensored) ~ 1, data = data)
  surv$w = surv$n.event / surv$n.risk
  density(surv$time, kernel = "epanechnikov", weights = surv$w, ...)
}

test = function(data, indices, ...) {
  sdata = data.frame(ttfeedback = data$ttfeedback[indices], 
                     is_uncensored = data$is_uncensored[indices])
  haz = hazard(sdata, ...)
  haz$y
}

haz = hazard(moodbar, from = tfrom, to = tto, n = nn)
b = boot(moodbar, test, R = 100, parallel = "multicore", ncpus = 2, from = tfrom, 
         to = tto, n = nn)

haz$se.boot = apply(b$t, 2, sd)
ucl = haz$y + 1.96 * haz$se.boot
lcl = haz$y - 1.96 * haz$se.boot
p = qplot(haz$x, haz$y, xlab = "days since first edit click", ylab = "hazard rate") + 
  geom_smooth(aes(ymin = lcl, ymax = ucl), stat = "identity")