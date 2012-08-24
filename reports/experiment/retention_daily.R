setwd("../..")

library(ggplot2)

RET <- read.table("data/retention_daily.csv", header=T, sep="\t")

c <- ggplot(RET, aes(as.Date(registration.date), still.active/group.size, colour=group)) + geom_line() +
xlab("Date") + scale_y_continuous(limits=c(0,0.5)) + facet_grid(~ account.age)
c
ggsave("retention_daily.pdf", height=3, width=16)
