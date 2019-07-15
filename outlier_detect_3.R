library(ks)
library(viridis)
# NOT RUN {
## positive data example
set.seed(8192)
x <- 2^rnorm(100)
fhat <- kde(x=x, positive=TRUE)
plot(fhat, col=3)
points(c(0.5, 1), predict(fhat, x=c(0.5, 1)))

## large data example on non-default grid
## 151 x 151 grid = [-5,-4.933,..,5] x [-5,-4.933,..,5]
set.seed(8192)
x <- rmvnorm.mixt(10000, mus=c(0,0), Sigmas=invvech(c(1,0.8,1)))
fhat <- kde(x=x, binned=TRUE, compute.cont=TRUE, xmin=c(-5,-5), xmax=c(5,5), bgridsize=c(151,151))
plot(fhat)

## See other examples in ? plot.kde
# }

n <- 200
set.seed(35233)
x <- mvtnorm::rmvnorm(n = n, mean = c(0, 0),
                      sigma = rbind(c(1.5, 0.25), c(0.25, 0.5)))

# Compute kde for a diagonal bandwidth matrix (trivially positive definite)
H <- diag(c(1.25, 0.75))
kde <- ks::kde(x = x, H = H)

# The eval.points slot contains the grids on x and y
str(kde$eval.points)
## List of 2
##  $ : num [1:151] -8.58 -8.47 -8.37 -8.26 -8.15 ...
##  $ : num [1:151] -5.1 -5.03 -4.96 -4.89 -4.82 ...

# The grids in kde$eval.points are crossed in order to compute a grid matrix
# where to compute the estimate
dim(kde$estimate)
## [1] 151 151

# Manual plotting using the kde object structure
image(kde$eval.points[[1]], kde$eval.points[[2]], kde$estimate,
      col = viridis::viridis(20), xlab = "x", ylab = "y")
points(kde$x) # The data is returned in $x
