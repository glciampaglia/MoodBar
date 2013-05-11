require(ggplot2)
active <- read.table("../../data/active_30.tsv", stringsAsFactors=T, sep="\t",
                     header=T)
active.tot <- read.table("../../data/active_total.tsv", stringsAsFactors=T,
                         header=T, sep="\t")

active <- subset(active, group != 'historical')

for (group in levels(active$group)) {
    tot <- active.tot[active.tot$uw_group == group,]$total
    idx <- active$group == group
    active[idx,]$retained <- active[idx,]$retained / tot
}

ggplot(active, aes(period, retained, colour=group)) + geom_point() + 
scale_y_log10() + scale_y_continuous(limits=c(0,0.05)) 
