require(ggplot2)
require(gridExtra)

# load data
moodbar <- read.table("data/time_to_response.tsv", sep="\t", header=T)
# compute time to response (in days)
moodbar$response <- as.numeric(as.POSIXct(moodbar$response_time) - 
  as.POSIXct(moodbar$mood_time)) / 86400.0
# compute day of week of posting factor
mood.time <- as.POSIXlt(moodbar$mood_time, tz = "UTC")
moodbar$wday <- factor(mood.time$wday)
levels(moodbar$wday) <- c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")
moodbar$hour <- factor(mood.time$hour)

# Plot log-response time distribution over mood x week combinations
qplot(response, data = moodbar[moodbar$status == 1,], facets = mood ~  wday, 
      geom = "histogram", log= "x", xlab = "Response time, log(days)", 
      ylab = "Count", main = "Response time distribution over the week")

p.sad <- qplot(log(response), main = "sad", clip = T,
               data = moodbar[moodbar$status == 1 & moodbar$mood == "sad",],
               geom = "histogram", asp = 1) + facet_wrap(~ hour, nrow = 6)

p.happy <- qplot(log(response), main = "happy", clip = T, ylab = "", xlab = "",
               data = moodbar[moodbar$status == 1 & moodbar$mood == "happy",],
               geom = "histogram", asp = 1) + facet_wrap(~ hour, nrow = 6)

p.confused <- qplot(log(response), main = "confused", clip = T, ylab = "", xlab = "",
               data = moodbar[moodbar$status == 1 & moodbar$mood == "confused",],
               geom = "histogram", asp = 1) + facet_wrap(~ hour, nrow = 6)

grid.arrange(p.sad, p.happy, p.confused, nrow = 1)

# Plot response time over the week
qplot(x = wday, y = response, data = moodbar[moodbar$status == 1,], 
      geom = "boxplot", facets = . ~ mood, log = "y", 
      xlab = "Day of feedback posting", ylab = "Response time log(days)", 
      main = "Response time over the week")

qplot(x = hour, y = response, data = moodbar[moodbar$status == 1,], 
      geom = "boxplot", facets = mood ~ ., log = "y", 
      xlab = "Hour of feedback posting", ylab = "Response time log(days)", 
      main = "Response time over the day")

# test weekly differences
kruskal.test(log(response) ~ wday + mood, data = moodbar[moodbar$status == 1,])

# test hourly differences
kruskal.test(log(response) ~ hour + mood, data = moodbar[moodbar$status == 1,])
