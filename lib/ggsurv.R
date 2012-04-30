# Low-level adaptor function for plotting survival::survfit objects with ggplot2
# inspired by http://bit.ly/JXRgoV and others
# author: Giovanni Luca Ciampaglia <gciampaglia@wikimedia.org>

# TODO
# ----
# * infer levels and strata names from sfit, remove ystratalabs, ystrataname
# * add 95% confidence interval bands, possibly ggplot confidence bands
# * add marks for censored observations
# * pass xlab, ylab, main ...

require(ggplot2)

ggsurv <- function(sfit, ystratalabs = NULL, ystrataname = NULL, ...) 
{

  if(is.null(ystratalabs)) ystratalabs <- as.character(levels(summary(sfit)$strata))
  if(is.null(ystrataname)) ystrataname <- "Strata"

  tmp.frame <- data.frame(
    time = sfit$time,
    n.risk = sfit$n.risk,
    n.event = sfit$n.event,
    surv = sfit$surv,
    strata = factor(summary(sfit, censored = T)$strata),
    upper = sfit$upper,
    lower = sfit$lower
  )
  
  p <- ggplot(tmp.frame, aes(time, surv, group = strata), ...) +
    geom_step(aes(linetype = strata))
  
  print(p)
}