input <- matrix(sample(0:1, 360, replace = TRUE), ncol = 4)
output <- matrix(sample(0:1, 180, replace = TRUE), ncol = 2)

tr <- cbind(0, input, output)
tr[1, 1] <- 1

colnames(tr) <- c("ctrl", "a", "b", "c", "d", "y", "x")
