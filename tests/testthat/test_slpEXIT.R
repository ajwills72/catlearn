## Check slpEXIT against a short IBRE simulation
context("slpEXIT")
load('../data/test_slpEXIT.RData')
tout <- slpEXIT(st, tr, xtdo=F)

test_that("slpEXIT reproduces IBRE simulation.", {
    expect_equal(tout$p[,1], corr)
})


## Generating code
#tr <- krus96train(blocks = 1, subjs = 1, seed = 1234)
#params <-  c(2.87, 2.48, 4.42, 4.42, .222, 1.13, .401)

#exemplars <- rbind(c(1,1,0,0,0,0,1),
#                   c(1,0,1,0,0,0,1),
#                   c(0,0,0,1,1,0,1),
#                   c(0,0,0,1,0,1,1))

#w_exemplars <- exemplars
#w_exemplars[] <- 0
#nFeat = 7
#nCat = 4
#w_in_out <- matrix(0, nCat, nFeat)
    
#st <- list(nFeat = nFeat, nCat = nCat,
#           phi = params[3], c = params[1], P = params[2],
#           l_gain = params[4], l_weight = params[5], l_ex = params[6],
#           sigma = c(rep(1,6), params[7]), 
#           iterations = 10,
#           exemplars = exemplars,
#           w_exemplars = w_exemplars,
#           w_in_out = w_in_out)
#rm(exemplars, nCat, nFeat, params, w_exemplars, w_in_out)

#corr <- c(0.2500000000000000, 0.2665891328372711, 0.3772027363522861,
#          0.1689622092461746, 0.0983246687763398, 0.4578623898048708,
#          0.1539995880005246, 0.6807966490530410, 0.6221035689649324,
#          0.6774316171213102, 0.2007273190462887, 0.1314876974887666,
#          0.1308916521271407, 0.2089970605354426, 0.5010955294915848,
#          0.1423325468600891, 0.6765162053413211, 0.0867322704131168,
#          0.3824338660335294, 0.4666775043769692, 0.4154448799963301,
#          0.1362422257878339, 0.5069625412275843, 0.1365392263298607,
#          0.6972229299758037, 0.0808077150259761)




