# Low-level adaptor function for plotting survival::survfit objects with ggplot2
# inspired by http://bit.ly/JXRgoV and others
# author: Giovanni Luca Ciampaglia <gciampaglia@wikimedia.org>

# TODO
# ----
# * infer levels and strata names from sfit, remove ystratalabs, ystrataname
# * add 95% confidence interval bands, possibly ggplot confidence bands
# * add marks for censored observations
# * pass xlab, ylab, main ...

surv2df <- function(sfit) {
  if (is.null(sfit$strata)) {
    tmp.frame <- data.frame(
      time = sfit$time,
      n.risk = sfit$n.risk,
      n.event = sfit$n.event,
      surv = sfit$surv,
      upper = sfit$upper,
      lower = sfit$lower
      )
  } else {
    # define tmp frame 
    tmp.frame <- data.frame(
      time = sfit$time,
      n.risk = sfit$n.risk,
      n.event = sfit$n.event,
      surv = sfit$surv,
      strata = factor(summary(sfit, censored = T)$strata),
      upper = sfit$upper,
      lower = sfit$lower
      )
  }
  tmp.frame
}

ggsurv <- function(sfit, ...) 
{

  require(ggplot2)
  
  tmp.frame <- surv2df(sfit)
  
  if (is.null(sfit$strata)) { # survfit object has no strata

    p <- ggplot(tmp.frame, aes(time, surv), ...) + geom_step()

  } else { # survfit object has strata
  
    # extract strata name and labels from survfit object
    strata.levels <- as.character(levels(summary(sfit)$strata))
    strata.name <- unlist(strsplit(strata.levels[1], "="))[1]
    strata.labels <- vector(mode = "character", 0)
    for (i in 1:length(strata.levels)) {
      strata.labels[i] <- unlist(strsplit(strata.levels[i], "="))[2]
    }
    
    levels(tmp.frame$strata) <- strata.labels
    p <- ggplot(tmp.frame, aes(time, surv, group = strata), ...) +
      geom_step(aes(linetype = strata)) + labs(linetype = strata.name)
  }
  
  print(p)
}