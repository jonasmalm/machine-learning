library(tree)
library(kernlab) # For the spam dataset
data(spam)

######### Data selection
data = spam
n = dim(data)[1]
set.seed(1234)
id = sample(1:n, floor(n * 0.5))
train = data[id,]
val = data[-id,]

######### Basic model

#### NOTE: For int classes, e.g. Class = 0, 1
# Decision tree: convert to factor
# Regression tree: leave as numeric

tree_model = tree(type ~ ., data = train)
plot(tree_model)
text(tree_model, cex = 0.75)

preds = predict(tree_model, val, type = 'class')
confm = table(val$type, preds)

######### Plotting deviance by leaves
no_leaves = summary(tree_model)$size
score_tr = rep(0, no_leaves)
score_va = rep(0, no_leaves)

ind = 2:no_leaves
for (i in ind) {
  t = prune.tree(tree_model, best = i)
  
  pred = predict(t, val, type = 'tree')
  
  score_tr[i] = deviance(t) / dim(train)[1]
  score_va[i] = deviance(pred) / dim(val)[1]
}

plot_data = data.frame(Size = ind, Deviance = score_tr[ind], Type = 'Training')
plot_data = rbind(plot_data, data.frame(Size = ind, Deviance = score_va[ind], Type = 'Validation'))

ggplot() + 
  geom_line(data = plot_data, aes(Size, Deviance, color = Type)) + 
  geom_point(data = plot_data, aes(Size, Deviance, color = Type))

######### Optimal depth by CV
set.seed(1234)
tree_model = tree(type ~ ., data = spam)
cv_result = cv.tree(tree_model)
plot(cv_result$size, cv_result$dev, type="b", col="red")


###################### Package rpart
library(rpart)

######### CV rpart()
set.seed(12345)
control = trainControl(method = 'cv', number = 5)
cv_model = train(type ~ ., data = spam, method = 'rpart', trControl = control)
best_tree = cv_model$finalModel
plot(best_tree)
text(best_tree)
title('Choosing depth with 5-fold cross validation')

preds = predict(best_tree, spam, type = 'class')
confm = table(spam$type, preds)

############ Loss matrix ############

lossm = matrix(c(0, 1, 5, 0), ncol = 2)

set.seed(12345)

cv_model_loss = train(type ~ ., data = spam, method = 'rpart', 
                      parms = list(loss = lossm))
best_tree_loss = cv_model_loss$finalModel
plot(best_tree_loss)
text(best_tree_loss)
title('Penalizing false negatives with loss matrix')

preds = predict(best_tree_loss, spam, type = 'class')
confm_loss = table(spam$type, preds)
