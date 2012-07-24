# Converts the person-period data into person-level format, perform stratified
# sampling, extracts data from it, and convert it back to person-period format

require(sampling)

# size of the sample
S <- 10000

# loads person-period data set
EC <- read.table("data/ec.tsv", header=T, sep="\t")
EC <- within(EC, treatment <- factor(treatment), user_id <- factor(user_id))
levels(EC$treatment) <- c("Reference", "Feedback", "Feed+Resp", "Feed+Useful")

# compute strata sizes
p <- as.numeric(table(EC$treatment))
p <- p / sum(p)
sizes <- ceiling(p * S)

# get the person-level dataset and run strata on it 
EC.pl <- unique(EC[c("user_id", "treatment")])
EC.strata <- strata(EC, c("treatment"), sizes, method="srswor")
EC.ids <- getdata(EC, EC.strata)$user_id

# take sampled subset and write table to file
EC.sample <- subset(EC, user_id %in% EC.ids)
write.table(EC.sample, sprintf("data/ec_%d.tsv", S), quote=F, sep="\t")
