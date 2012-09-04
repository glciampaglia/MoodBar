library(ggplot2)

RET <- read.table("../../data/retention_daily.csv", header=T, sep="\t")

c <- ggplot(RET, aes(as.Date(registration.date), still.active/group.size, colour=group)) + geom_line() +
xlab("Date") + scale_y_continuous(limits=c(0,0.5)) + facet_wrap(~ account.age,
                                                                ncol=2)
c
ggsave("plots/retention_daily.pdf", height=3, width=16)
