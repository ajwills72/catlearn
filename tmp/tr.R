input <- matrix(sample(0:1, 360, replace = TRUE), ncol = 4)
output <- matrix(c(0, 1, 1, 0), ncol = 2, nrow = 90, byrow = TRUE)

tr <- cbind(0, input, output)
tr[1, 1] <- 1

colnames(tr) <- c("ctrl", "a", "b", "c", "d", "y", "x")
