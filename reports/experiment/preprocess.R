# Pre-processes the retention data using LOESS. The parameter \alpha of LOESS is
# chosen via cross-validation

# loessGCV and bestLoess adapted from:
# http://www.r-bloggers.com/whats-wrong-with-loess-for-palaeo-data/
# Note: contrarily to the blog post, our data is actually independent because
# each day, modulo sockpuppets and double accounts, consists of independent
# groups of people. 

setwd("../..")

library(ggplot2)

RET <- read.table("data/retention_daily.csv", header=T, sep="\t")
RET$reg <- as.numeric(as.Date(RET$registration.date))
RET$ret <- RET$still.active / RET$group.size
RET$age <- as.factor(RET$account.age)

# computes GCV for LOESS model x
loessGCV <- function (x) {
    ## Modified from code by Michael Friendly
    ## http://tolstoy.newcastle.edu.au/R/help/05/11/15899.html
    if (!(inherits(x,"loess"))) stop("Error: argument must be a loess object")
    ## extract values from loess object
    span <- x$pars$span
    n <- x$n
    traceL <- x$trace.hat
    sigma2 <- sum(resid(x)^2) / (n-1)
    gcv  <- n*sigma2 / (n-traceL)^2
    result <- list(span=span, gcv=gcv)
    result
}

# returns span that minimizes GCV for span in [0,1]
bestLoess <- function(model, data, age, spans = seq(.05, .95, .05)) {
    f <- function(span) {
        mod <- update(model, span = span, data = RET, subset = age == age)
        loessGCV(mod)[["gcv"]]
    }
    result <- optimize(f, spans)
    result
}

# fit each age separately with LOESS
models <- by(RET, RET$age, function (x) loess(ret ~ reg, data = x, weights =
                                                sqrt(group.size)), simplify=F)

# compute cross-validated span for each age
for (age in levels(RET$age)) {
    m <- models[[age]]
    best.span <- bestLoess(m, RET, age)[["minimum"]]
    m <- update(m, span = best.span, data = RET, subset = age == age)
}

# summary(mod.fit)
# par(mfcol = c(2,2))
# plot(mod.fit)
