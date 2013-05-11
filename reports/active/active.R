require(ggplot2)
active <- read.table("../../data/active.tsv", stringsAsFactors=T, sep="\t",
                     header=T)
active.tot <- read.table("../../data/active_total.tsv", stringsAsFactors=T,
                         header=T, sep="\t")

for (group in levels(active$group)) {
    tot <- active.tot[active.tot$uw_group == group,]$total
    idx <- active$group == group
    active[idx,]$active <- active[idx,]$active / tot
}

ggplot(subset(active, group != 'historical'), aes(age, active, colour=group)) + geom_point() +
scale_y_continuous(limits=c(0,0.1)) + scale_y_log10() #+ scale_x_continuous(limits=c(200,300))
