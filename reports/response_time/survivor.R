# Plot the survivor curves of the time to response data by mood type.

require(survival)
source("misc/ggkm.R")

# load data, and compute time to response (in days)
moodbar <- read.table("data/time_to_response.tsv", sep="\t", header=T)
moodbar$ttresponse <- as.numeric(as.POSIXct(moodbar$response_time) - 
  as.POSIXct(moodbar$mood_time)) / 86400.0 

# compute and plot the estimate of the survival curve, use log-linear scale for 
# better readability
moodbar.formula <- Surv(ttresponse, status) ~ mood + strata(is_editing)
km.fit <- survfit(moodbar.formula, data = moodbar)

p1 <- ggkm(km.fit, ystrataname = "mood", 
          ystratalabs = c("confused", "happy", "sad"), table=F, return=T, subs=0, 
          main = "Feedbacks sent while not editing", 
          xlabs = "Time since mood feedback", 
          ylabs = "Percentage of feedbacks with at least one response", 
          pval = F) + scale_x_log10()

p2 <- ggkm(km.fit, ystrataname = "mood", 
          ystratalabs = c("confused", "happy", "sad"), table=F, return=T, subs=1, 
          main = "Feedbacks sent while editing", 
          xlabs = "Time since mood feedback", 
          ylabs = "Percentage of feedbacks with at least one response", 
          pval = F) + scale_x_log10()

print(p1)
print(p2)

# print stats
print(km.fit)

# Peto test for difference of survival
survdiff(moodbar.formula, data = moodbar, rho = 1)

# Testing difference of survival for "sad" and "confused" only, stratifying on 
# is_editing and weekday of feedback posting
m1 <- moodbar[moodbar$mood != "happy",]
m1$wday <- factor(as.POSIXlt(m1$mood_time, tz = "UTC")$wday)
levels(m1$wday) <- c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")
survdiff(Surv(ttresponse, status) ~ mood + strata(is_editing, wday), data = m1)