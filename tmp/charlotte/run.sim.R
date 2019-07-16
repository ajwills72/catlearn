
# Helpful function for normalizing and preparing data for slpSUSTAIN
.transform <- function(x) {
 # Simplified feature scaling
    for (i in 1:ncol(x)) x[, i] <- x[, i]/max(x[, i])
 # Adding difficulties of items for comprehensiveness
 # 1 = easy; 2 = medium; 3 = hard
    diff <- rep(1:3, 6)[order(rep(1:3, 6))]
    out <- cbind(rep(0, nrow(x)), rep(t(diff), 2),
               x)
    out <- matrix(rep(t(out), 16), ncol = 6, byrow = TRUE)
    out <- out[sample(nrow(out)), ]
 # Adding column names for slpSUSTAIN
    colnames(out) <- c("ctrl", "diff", "x", "y", "c1", "c2")
 # 'ctrl' code 1 = reset network and do supervised learning
 # 'ctrl' code 0 = do supervised learning
    out[, 1] <- 0
    out[1, 1] <- 1
    return(out)
}


library(catlearn)
source('training.spiering.ashby.R')
source('training.edmunds.R')

training.edmunds <- lapply(training.edmunds, .transform)
training.spiering.ashby <- .transform(spieringashby08)


# Parameters were taken under the "All studies" heading in
# Table 1 Love, Medin and Gureckis (2004)
init.params <- list(r = 2.844642, # attentional focus
                    beta = 2.386305, # cluster competition
                    d = 12.0, # decision consistency
                    eta = 0.09361126, # learning rate
                    tau = 0.0, # unsupervised threshold
                    lambda = c(1, 1),
                    dims = c(1, 1),
                    w = NA,
                    cluster = NA,
                    colskip = 2)

output.edmunds <- list()

for (i in 1:4) {
  output.edmunds[[i]] <- slpSUSTAIN(init.params, training.edmunds[[i]])
}

names(output.edmunds) <- names(training.edmunds)

output.spiering.ashby <- slpSUSTAIN(init.params, training.spiering.ashby)

