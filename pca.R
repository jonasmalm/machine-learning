library(ggplot2)
data(iris)

##################### PCA from scratch
# Plot in original dimension
# PCA is only done on features
data = cbind(iris$Sepal.Length, iris$Sepal.Width)

data = scale(data)
eigen = eigen(cov(data))

# Responsible for variance:
proportion = eigen$values / sum(eigen$values)

pc1_slope = eigen$vectors[1,1] / eigen$vectors[2,1]
pc2_slope = eigen$vectors[1,2] / eigen$vectors[2,2]

data = data.frame(Species = iris$Species, Sepal.Width = data[,1], Sepal.Length = data[,2])
ggplot(data, aes(x = Sepal.Width, y = Sepal.Length)) + 
  geom_point(aes(color = Species)) +
  geom_abline(aes(intercept = 0, slope = pc1_slope), color = 'red') + 
  geom_abline(aes(intercept = 0, slope = pc2_slope), color = 'blue')


##### how many components do we need to explain p % of the variance
no_comps = function(e, p) {
  n = 0
  sum = 0
  
  for (i in 1:length(e)) {
    sum = sum + e[i]
    n = i
    if (sum > p) break
  }
  
  return(n)
}

no_comps(proportion, 0.95)



##################### Plotting in the new coordinate system

# PCA is only done on features!
pca_model = princomp(data[,-1])

# pca_model$scores[, 1] contains the PC1 values of the observations
# pca_model$loadings [, 1] contains the loadings 
# (coeff for linear combination of inital variables) of PC1

pca_data = data.frame(
  Species = data$Species,
  PC1 = pca_model$scores[, 1],
  PC2 = pca_model$scores[, 2]
)

ggplot(pca_data) + 
  geom_point(aes(x = PC1, y = PC2, color = Species)) + 
  geom_hline(aes(yintercept = 0), color = 'red') +
  geom_vline(aes(xintercept = 0), color = 'blue')  



