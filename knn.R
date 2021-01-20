data(iris)

n = dim(iris)[1]
set.seed(12345)
id = sample(1:n, floor(n * 0.5))
train = iris[id,]
test = iris[-id,]


library(kknn)

rect_err = rep(0, 30)
gaus_err = rep(0, 30)
tri_err = rep(0, 30)


for (i in 1:30) {
  fit = kknn(Species ~ ., train = train, test = test, k = i, kernel = 'rectangular')
  confm = table(test$Species, fitted(fit))
  rect_err[i] = 1 - sum(diag(confm)) / sum(confm)
  
  fit = kknn(Species ~ ., train = train, test = test, k = i, kernel = 'gaussian')
  confm = table(test$Species, fitted(fit))
  gaus_err[i] = 1 - sum(diag(confm)) / sum(confm)
  
  fit = kknn(Species ~ ., train = train, test = test, k = i, kernel = 'triweight')
  confm = table(test$Species, fitted(fit))
  tri_err[i] = 1 - sum(diag(confm)) / sum(confm)

  
}

data = data.frame(K = 1:30, Error = rect_err, Kernel = 'Rectangular')
data = rbind(data, data.frame(K = 1:30, Error = gaus_err, Kernel = 'Gaussian'))
data = rbind(data, data.frame(K = 1:30, Error = tri_err, Kernel = 'Triweight'))

ggplot(data) + 
  geom_line(aes(K, Error, color = Kernel, group = Kernel))