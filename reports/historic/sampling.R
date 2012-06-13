# Converts the person-period data into person-level format, perform stratified
# sampling, extracts data from it, and convert it back to person-period format

require(sampling)

# size of the sample
S <- 1000

# loads person-period data set
EC <- read.table("data/ec.tsv", header=T, sep="\t")
EC <- within(EC, treatment <- factor(treatment), user_id <- factor(user_id))
levels(EC$treatment) <- c("Reference", "Feedback", "Feed+Resp", "Feed+Useful")

# compute strata sizes
p <- as.numeric(table(EC$treatment))
p <- p / sum(p)
sizes <- ceiling(p * S)

# get the person-level dataset and run strata on it 
EC.persons <- unique(EC[c("user_id", "treatment")])
EC.sample <- strata(EC, c("treatment"), sizes, method="srswor")
user.ids <- getdata(EC, EC.sample)$user_id

# take sampled subset and write table to file
EC.1000 <- subset(EC, user_id %in% user.ids)
write.table(EC.1000, "data/ec_1000.tsv", quote=F, sep="\t")
