# This script plots an example of a decomposed time series from the daily
# retention data

library(zoo)

# Read data into a zoo object. Assumes dates are on the third column, and
# grouping factor (account.age) is on the first column.
RET <- read.zoo("../../data/retention_daily.csv", header=T, sep="\t",
                format="%Y-%m-%d", index.column=3, split=1)

# convert as time series with weekly frequency and decompose using moving
# average.
d.1 <- decompose(ts(as.numeric(RET$group.size.1), frequency=7))

# plot and save to file
plot(d.1)
dev.copy2pdf(file="plots/group.size.1_decompose.pdf")
