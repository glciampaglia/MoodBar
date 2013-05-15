require(ggplot2)

# read data, remove historical group
active <- read.table("../../data/active.tsv", stringsAsFactors=T, sep="\t",
                     header=T)
active <- within(subset(active, group != "historical"), {
                 group <- droplevels(group, "historical")
                     })

# add size variable to data frame
active$size <- 0

# read data frame with group size by registration day
size.day <- read.table("../../data/ppsize.tsv", stringsAsFactors=T,
                         header=T, sep="\t")

# sum over registration days to obtain group size
size.tot <- with(size.day, by(size, list(group), sum))

# adjust group size at the end of the observation window to account for the
# partial group size
for (g in levels(active$group)) {
    day.sizes <- with(size.day, subset(size, group == g))
    idx.obs <- active$group == g
    idx.reg <- size.day$group == g
    num.obs <- sum(idx.obs)
    num.reg <- sum(idx.reg)
    tot.size <- size.tot[[g]]
    sizes <- rep(tot.size, num.obs)
    N <- num.obs - num.reg + 2
    M <- num.obs
    sizes[N:M] <- tot.size - cumsum(day.sizes[2:num.reg])
    active[idx.obs,]$size <- sizes
}

# estimate proportion of retained
active$ph <- active$active / active$size

# plot difference 
ph <- split(active$ph, active$group)
N <- min(length(ph[["control"]]), length(ph[["treatment"]]))
mdph <- mean(ph[["treatment"]][1:N] - ph[["control"]][1:N])
plot(ph[["treatment"]][1:N] - ph[["control"]][1:N], xlab="Age",
     ylab=expression(hat(p)[treatment] - hat(p)[control]))
abline(mdph, 0, col="red")
savePlot("diff.png")

# plot the data
ggplot(active, aes(age, active / size, colour=group)) + geom_point() +
scale_y_continuous(limits=c(0,0.1)) + scale_y_log10() 
