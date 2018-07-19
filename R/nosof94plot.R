nosof94plot <- function(results,title = 'Nosofsky et al. (1994)') {
  plot(
    results$error[results$type == 1]
    , axes = FALSE
    , ylim = c(0,.7)
    , xlab = 'Block'
    , ylab ='P(error)'
    , bty = 'l'
    , mgp = c(2,1,0)
    , type = 'b'
    , pch = 15
    , lty = 'solid'
    , cex = 1
  )
  title(main = title)
  box(bty='l')
  axis(1,at=1:16,labels=c(' ','2',' ','4',' ','6',' ','8',' ','10',' ','12',' ','14',' ','16'))
  axis(2,at=c(0,0.1,0.2,0.3,0.4,0.5,0.6,0.7))
  
  lines(results$error[results$type == 2],type = 'b', pch=3, cex = 1)
  lines(results$error[results$type == 3],type = 'b', pch=8, cex = 1)
  lines(results$error[results$type == 4],type = 'b', pch=0, cex = 1)
  lines(results$error[results$type == 5],type = 'b', pch=4, cex = 1)
  lines(results$error[results$type == 6],type = 'b', pch=2, cex = 1)
  legend("topright",c('I','II','III','IV','V','VI'), pch = c(15,3,8,0,4,2),inset=0.05)
}
