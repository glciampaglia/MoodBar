# try to detrend data using regression analysis

RET <- read.table("../../data/retention_daily.csv", header=T, sep="\t")
RET <- within(RET, {
              age <- as.factor(account.age)
              reg <- as.Date(registration.date)
              ret <- still.active / group.size
              wday <- as.POSIXlt(registration.date)$wday
              wday <- as.factor(wday)
              levels(wday) <- c("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat")
              group <- as.factor(group)
              moodbar <- as.factor(group == "historical" | group == "treatment")
              levels(moodbar) <- c("no-moodbar", "moodbar")
})

# R^2 is actually *worse* without the SOPA data
# # remove SOPA blackout
# sopa.date <- as.Date("2012-01-18")
# RET <- subset(RET, reg != sopa.date)

mod.fit <- glm(still.active ~ reg + age + moodbar + wday +
               offset(log(group.size)), weights=sqrt(group.size)**-1, data = RET, family=poisson(link="log"))

# same but logistic regression with proportions data
pmod.fit <- glm(ret ~ reg + age + moodbar + wday, weights=group.size, data = RET,
               family=binomial(link="logit"))

# add predictions to data frame
RET <- within(RET, {
              sa.hat <- predict(mod.fit, type="response")
              ret.hat <- predict(pmod.fit, type="response")
})

p1 <- ggplot(RET, aes(x=reg, y=ret, colour=moodbar)) +
geom_area(alpha=0.5) + facet_wrap(~ age, ncol = 2) + xlab("date") +
ylab("retention probability") + scale_y_continuous(limits=c(0,0.5))
p1 <- p1 + geom_line(aes(x=RET$reg, y=RET$ret.hat, group=age), colour="black")
print(p1)
ggsave(p1, filename="plots/retention_prob.pdf")

dev.new()
p2 <- ggplot(RET, aes(x=reg, y=still.active, colour=moodbar, shape=moodbar)) +
geom_point() + facet_wrap(~ age, ncol = 2) + xlab("date") +
ylab("retention") 
p2 <- p2 + geom_line(aes(x=RET$reg, y=RET$sa.hat, group=age), colour="black")
print(p2)
ggsave(p2, filename="plots/retention_raw.pdf")

dev.new()
p3 <- ggplot(RET, aes(x=reg, y=resid(mod.fit))) + geom_point() + 
facet_wrap(~ age, ncol = 2) + xlab("date") + ylab("residuals") 
p3 <- p3 + geom_hline(yintercept=0)
print(p3)
ggsave(p3, filename="plots/retention_resid.pdf")

summary(mod.fit)
with(mod.fit, cbind(res.deviance = deviance, df = df.residual, 
               p = pchisq(deviance, df.residual, lower.tail = FALSE)))
