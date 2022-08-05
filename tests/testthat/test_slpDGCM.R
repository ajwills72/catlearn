context("slpDGCM")
library(catlearn)
load('../data/test_slpDGCM.RData')

out <- slpDGCM(st, tr, exemplar_decay = FALSE,
               exemplar_mute = TRUE, dec = "NOISE")

dgcm <- data.matrix(out$p)
dgcm <- suppressWarnings(melt(dgcm)$value)
empirical <- as.matrix(obryan18[, 2:5])
empirical <- suppressWarnings(melt(empirical)$value)

test_that("slpDGCM reproduces O'Bryan et al. (2018) with a mean
          difference of 0.000262.", {
    expect_lt(mean(abs(dgcm - empirical)), 0.001)
})

out <- slpDGCM(st, tr, exemplar_decay = TRUE,
               exemplar_mute = FALSE, dec = "BIAS")

test_that("slpDGCM runs without error with SM07 settings", {
    expect_equal(out, mock_sm)
})
