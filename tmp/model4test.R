library(catlearn)
library(Rcpp)
library(data.table)
library(stringr)
sourceCpp("src/slpModel4.cpp")

seq <- fread("tmp/trial_order.csv", header = TRUE)
out_sim <- fread("tmp/sim2model4.csv")

tr <- krus96train(blocks = 15, subjs = 1, ctxt = FALSE, seed = 1023)

tr$stim <- str_replace(tr$stim, "\\.", " + ")
tr$stim <- str_replace(tr$stim, "\\.", " + ")
print(tail(tr))

seq[, seq := as.factor(seq)]
tr$stim <- as.factor(tr$stim)

bigtr <- NULL
for (i in 1:nrow(seq)) {
    current <- which(tr$stim == seq$seq[i])[1]
    bigtr <- rbind(bigtr, tr[current, ])
}

head(data.matrix(bigtr)[,c(1, 4:13)])

bigtr$ctrl <- tr$ctrl
rownames(bigtr) <- NULL
## Set state
st <- list(P = 1,             ## attentional normalization
           phi = 5,          ## response consistency
           lambda = 0.1,       ## learning rate parameter
           mu = 0.1,           ## attentional learning rate parameter
           colskip = 1,
           outcomes = 4,
           w = matrix(0, nrow = 4, ncol = 6),
           eta = rep(1, 6)         ## intial salience of cues
       )

## Run simulation
out <- slpDRNCAG(st, data.matrix(bigtr)[, c(1, 4:13)])

probs <- data.table(out$p)
probs <- data.table(cbind(bigtr[, 1:3], probs))

probs <- probs[ctrl == 2, 3:7]

colnames(probs)[2:5] <- c("C1", "R1", "C1", "R1")
diff <- out_sim[order(rn)] - probs[order(stim)]

mdiff <- mean(abs(data.matrix(diff[, -1])))

print(paste("The C++ Model 4 implementation can replicate the simulation of",
            "Paskewitz and Jones (2021) with a mean difference of", mdiff))