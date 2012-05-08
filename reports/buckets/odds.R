buckets <- read.table("data/buckets.tsv", sep = "\t", header = T)
priors <- list(0.8, 0.1, 0.1)
names(priors) <- c("feedback", "editing", "share")

buckets$date <- as.POSIXct(buckets$date, tz="UTC")
buckets <- buckets[buckets$date < as.POSIXct("2011-12-01", tz="UTC") 
                   & buckets$date > as.POSIXct("2011-07-26"),]

tot_clicks <- sum(buckets$num_clicks)
L = list(sum(buckets$num_feedback) / tot_clicks, 
                  sum(buckets$num_editing) / tot_clicks, 
                  sum(buckets$num_share) / tot_clicks)
names(L) <- c("feedback", "editing", "share")
ef <- log(L$editing) - log(L$feedback) - log(priors$editing) + log(priors$feedback)
sf <- log(L$share) - log(L$feedback) - log(priors$share) + log(priors$feedback)
es <- log(L$editing) - log(L$share) - log(priors$editing) + log(priors$share)
odds <- exp(c(ef, sf, es))
names(odds) <- c("editing vs feedback", "share vs feedback", "editing vs share")
print(odds)