require(ggplot2)
require(gam)

reg.orig <- read.table("http://toolserver.org/~dartar/reg2/reg2_combo.csv", sep=",", 
                  header=T)
reg.orig$datetime <- as.Date(reg.orig$datetime)

d0.orig <- read.table("http://toolserver.org/~dartar/moodbar/d0.csv", sep=",", 
                 header=T)
d0.orig$date <- as.Date(d0.orig$date)

# remove SOPA/PIPA outlier
sopa.day = as.Date('2012-01-18')
d0.orig$date[d0.orig$date == sopa.day] <- NA
d0.orig = na.omit(d0.orig)
reg.orig$datetime[reg.orig$datetime == sopa.day] <- NA
reg.orig = na.omit(reg.orig)

p3.start <- "2011-12-16"
p3.end <- "2012-05-22"
reg <- reg.orig[reg.orig$datetime >= p3.start & reg.orig$datetime < p3.end,]
d0 <- d0.orig[d0.orig$date >= p3.start & d0.orig$date < p3.end,]
mbar = data.frame(day = as.numeric(d0$date),
                   wday = as.POSIXlt(d0$date)$wday,
                   mon = as.POSIXlt(d0$date)$mon,
                   activs = reg$live.accounts, 
                   posts = d0$posts)

m <- glm(posts ~ mon + wday + day, data = mbar, family = "poisson")
summary(m)
plot(d0$date, d0$posts, xlab="day", ylab="MoodBar posts")
lines(d0$date, predict(m, type="response"), col=2) 
ylim(0,200)

d0.new <- d0.orig[d0.orig$date >= p3.end,]
new.obs <- length(d0.new$date)
new.day = as.Date(rep(1:new.obs), origin=p3.end)
mbar.new = data.frame(day = as.numeric(new.day), 
                       wday = as.POSIXlt(new.day)$wday, 
                       mon = as.POSIXlt(new.day)$mon)
preds <- predict(m, newdata=mbar.new, se.fit=T, type="response")
boost <- d0.new$posts / preds$fit
boost.mean <- mean(boost)
print(sprintf("average boost = %g", boost.mean))

