library(survival)
library(multicore)
library(boot)
library(ggplot2)

# MoodBar milestones (assuming deployment on midnight)
# ticon = as.POSIXct('2011-11-01', tz="GMT") # added icon
# tmessage = as.POSIXct('2011-11-17', tz="GMT") # message mandatory
ttooltip = as.POSIXct('2011-12-14', tz="GMT") # added tooltip

moodbar = read.table("data/time_to_1st_feedback.tsv", sep="\t", header=T)
moodbar$ttfeedback = moodbar$first_feedback_or_now - moodbar$first_edit_click
moodbar$fec = as.POSIXlt(moodbar$first_edit_click * 86400, tz="GMT", 
                         origin='1970-01-01')
moodbar$ffon = as.POSIXlt(moodbar$first_feedback_or_now * 86400, tz="GMT", 
                          origin='1970-01-01')
# moodbar1 = moodbar[moodbar$fec < t1 & moodbar$ffon < t1,]
# moodbar2 = moodbar[moodbar$fec >= t1 & moodbar$fec < t2 & moodbar$ffon >= t1 & 
#   moodbar$ffon < t2,]
# moodbar3 = moodbar[moodbar$fec >= t2 & moodbar$fec < t3 & moodbar$ffon >= t2 & 
#   moodbar$ffon < t3,]
moodbar1 = moodbar[moodbar$fec < ttooltip,]
moodbar2 = moodbar[moodbar$fec >= ttooltip,]

# parameters for boot
R = 10000
ncpus = multicore:::detectCores() # or whathever you want 

hazard.density = function(data) {
  surv = survfit(Surv(ttfeedback, is_uncensored) ~ 1, data = data)
  surv$w = surv$n.event / surv$n.risk
  density(surv$time, kernel = "epanechnikov", weights = surv$w)
}

hazard.statistic = function(data, indices) {
  sdata = data.frame(ttfeedback = data$ttfeedback[indices], 
                     is_uncensored = data$is_uncensored[indices])
  haz = hazard.density(sdata)
  haz$y
}

hazard.plot = function(data, R, ncpus, ...) {
  haz = hazard.density(data)
  b = boot(moodbar, hazard.statistic, R, parallel = "multicore", ncpus = ncpus)  
  haz$se.boot = apply(b$t, 2, sd)
  ucl = haz$y + 1.96 * haz$se.boot
  lcl = haz$y - 1.96 * haz$se.boot
  p = qplot(haz$x, haz$y, xlab = "days since first edit click", 
            ylab = "hazard rate", geom = "line", ...) + 
              geom_smooth(aes(ymin = lcl, ymax = ucl), stat = "identity")
  p
}

p1 = hazard.plot(moodbar1, R, ncpus, main = 'Hazard rate (without tooltip)') + 
  scale_x_continuous(limits = c(0,50)) + scale_y_continuous(limits = c(0,0.025))
p2 = hazard.plot(moodbar2, R, ncpus, main = 'Hazard rate (with tooltip)') + 
  scale_x_continuous(limits = c(0,50)) + scale_y_continuous(limits = c(0,0.025))
p1
p2