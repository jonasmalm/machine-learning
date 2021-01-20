########################### Gaussian kernel
g_kernel = function(x) {
  eucl_dist = sqrt(sum(x^2))
  return(exp(-eucl_dist^2))
}

########################### The function making the predictions
pred = function(x, h, this) {
  kernel = g_kernel
  X = data[, 1]
  Y = data[, 2]
  n = dim(data)[1]
  
  numerator = 0
  denominator = 0
  for (i in 1:n) {
    
    # Don't allow the point we are predicting to vote!!
    if (i == this) {
      next
    }
    
    
    k = kernel( (x - X[i]) / h)
    numerator = numerator + k * Y[i] 
    denominator = denominator + k  
  }
  
  return(numerator / denominator)
}




###################### Finding good h values ######################
library(ggplot2)

# This code scales terribly!
# O(n^2 * H)

n = 200
set.seed(1234567890)
x = runif(n, 0, 20)
data = data.frame(x, sin = sin(x))

H = c(seq(0.1225, 2.0, 0.1225), seq(2.25, 3.0, 0.25), seq(3, 10, 0.5))

############## Plotting MSE(h)
mse = c()
for(h in H) {
  yhat = rep(0, n)
  for (i in 1:n) {
    yhat[i] = pred(data$x[i], h, i)
  }
  mse = rbind(mse, mean((data$sin - yhat)^2))
  
}

res = data.frame(H = H, MSE = mse)
ggplot() +
  geom_line(data = res, aes(x = H, y = MSE))






############# Plotting predictions for different h-values
res = data.frame(x = NA, y = NA, H = NA)
for(h in 1:length(H)) {
  yhat = rep(0, n)
  for (i in 1:n) {
    yhat[i] = pred(data$x[i], H[h], i)
  }
  n_data = data.frame(x = data$x, y = yhat, H = H[h])
  res = rbind(res, n_data)
  
}
res = res[-1, ]

ggplot() +
  geom_point(data = data, aes(x = x, y = sin), color = 'red') +
  geom_line(data = res, aes(x = x, y = y, color = H, group = H))



