library(ggplot2)

RET <- read.table("../../data/retention_daily.csv", header=T, sep="\t")

c <- ggplot(RET, aes(as.Date(registration.date), still.active/group.size,
                     colour=group)) + geom_area(alpha=0.5) + xlab("date") +
ylab("retention probability") + scale_y_continuous(limits=c(0,0.5)) +
facet_wrap(~ account.age, ncol=2)
print(c)
ggsave("plots/retention_daily.pdf", height=7, width=7)
ggsave("plots/retention_daily.png", height=7, width=7)
