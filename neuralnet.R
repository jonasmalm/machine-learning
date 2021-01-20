library(neuralnet)
library(ggplot2)

############ Sampling data

# Sample [0, 10], n = 500
set.seed(12345)
x = runif(500, 0, 10)
data = data.frame(x, sin = sin(x))
train = data[1:25,] 
test = data[26:500,] 

# Decide on the depth of NN
layers = c(5)

#            From input       To output            Bias terms     Interactions between layers
no_weights = layers[1] + tail(layers, n = 1) + sum(layers) + 1 + sum(c(0, layers) * c(layers,0))
initial_weights = runif(no_weights, -1, 1)


# linear.output: Don't apply activation function to output neurons?
# Regression --> TRUE, classification --> FALSE
# threshold: stopping criteria, partial derivative

nn = neuralnet(sin ~ x, data = train, hidden = layers, startweights = initial_weights)


plot_data = data.frame(x = test$x, sin = test$sin, type = 'Test')
plot_data = rbind(plot_data, data.frame(x = test$x, sin = predict(nn, test), type = 'Predictions'))
plot_data = rbind(plot_data, data.frame(x = train$x, sin = train$sin, type = 'Training'))


ggplot() + 
  geom_point(data = plot_data, aes(x = x, y = sin, color = type))
  

###################### Predictions outside trained interval ######################
# The neural net cannot make accurate predictions in the interval [10, 20]
# when trained on the interval [0, 10]

x1 = runif(500, 0, 20)
data_new = data.frame(x = x1, sin = sin(x1))

pred_new = data.frame(x = data_new$x, sin = predict(nn, data_new))
ggplot() + 
  geom_point(data = data_new, aes(x = x, y = sin), color = 'blue', size = 1) +
  geom_point(data = pred_new, aes(x = x, y = sin), color = 'red', size = 1)

###################### Reverse pred (x from sin(x)) ######################
# This should not work at all, since many sin(x) corresponds to the same x

nn_bad = neuralnet(x ~ sin, train, hidden = layers, startweights = initial_weights)
pred_bad = data.frame(x = predict(nn_bad, test), sin = test$sin)

ggplot() + 
  geom_point(data = train, aes(x = x, y = sin), color = 'black', size = 2) +
  geom_point(data = test, aes(x = x, y = sin), color = 'blue', size = 1) + 
  geom_point(data = pred_bad, aes(x = x, y = sin), color = 'red', size = 1)


############# OUTPUT OF LAYERS
# Calculate the output of individual layers

library(e1071)

outputs = function(nn, input, round = TRUE) {
  l1_w = nn$weights[[1]][[1]]
  l2_w = nn$weights[[1]][[2]]
  n = dim(nn$startweights[[1]][[1]])[2]
  
  layer1_output = sigmoid(l1_w[2,] * input + l1_w[1,])
  layer2_input = layer1_output * l2_w[1:n + 1]
  
  # if linear output is set to false (classification!)
  # output = sigmoid(output)
  output = sum(layer2_input) + l2_w[1]
  
  if (round) {
    out = list(
      l1_out = round(layer1_output, digits = 3),
      l2_in = round(layer2_input, digits = 3), 
      out = output)
  } else {
    out = list(l1_out = layer1_output, l2_in = layer2_input, out = output)
  }
  
  return(out)
}
outputs(nn, 1)

# Test to ensure it is working as it should:
outputs(nn, 1)$out == predict(nn, data.frame(x = 1))
