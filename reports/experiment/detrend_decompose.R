# this script computes the average retention by age and group. Data are
# pre-processed by removing the seasonal (weekly) and trend components and only
# using moving averages (see decompose())

library(zoo)
library(ggplot2)

# read data table into a data frame. 
RET <- read.table("../../data/retention_daily.csv", header=T, sep="\t")
RET <- within(RET, {
              reg <- as.Date(registration.date)
              age <- as.factor(account.age)
              group <- as.factor(group)
              ret <- still.active / group.size
})

# decompose retention in trend, seasonal, and random components, and return the
# random (N.B.: trend is really another seasonal on the yearly scale, but, as of
# 2012/08, lacking data on more than one year, it is impossible to treat it as a
# seasonality)
by.preprocess <- function(x, freq=7) {
    # creates a regular time series with NAs (for missing date 2012-06-14)
    ret.ts <- with(x, ts(zoo(ret, reg), frequency=freq))
    d <- decompose(ret.ts)
    d$random
}

# preprocess each age separately
ret.random <- by(RET, RET$age, by.preprocess, freq=7)
ret.random <- c(sapply(ret.random, as.vector))

# order the "group" factor chronologically
ix <- sort.int(subset(RET, age == 1)$reg, index.return=T)$ix
group <- with(subset(RET, age == 1), {
            group[ix]
})
group <- rep(group, 5)

# order registration dates chronologically
reg <- with(subset(RET, age == 1), {
            reg[ix]
})
reg <- rep(reg, 5)

# create a new data frame
RET.pre <- data.frame(
                      reg=reg,
                      ret=ret.random,
                      group=group,
                      age=RET$age
                      )

# plot the retention
p <- ggplot(RET.pre, aes(x=reg, y=ret, colour=group, shape=group)) +
geom_line() + facet_wrap(~ age, ncol=2)
ggsave(p, filename="plots/retention_decomposed.pdf")

# compute average retention by age and group 
x <- with(RET.pre, tapply(ret, list(age, group), mean, na.rm=T))
print(x)
