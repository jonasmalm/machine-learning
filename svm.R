library(kernlab)
data(spam)

data = spam
n = dim(data)[1]
set.seed(12345)
id = sample(1:n, floor(n * 0.4))
train = data[id, ]
id1 = setdiff(1:n, id)
set.seed(12345)
id2 = sample(id1, floor(n * 0.3))
val = data[id2, ]
id3 = setdiff(id1, id2)
test = data[id3, ]


C = seq(0.5, 15, 0.5)
res = rep(0, length(C))
res_train = rep(0, length(C))

i = 1
for (c in C) {
  filter = ksvm(type ~ ., data = train, kernel = 'rbfdot', 
                kpar = list(sigma = 0.05), C = c)
  
  pred = predict(filter, val)
  confm = table(val$type, pred)
  misclass = 1 - sum(diag(confm)) / sum(confm)
  res[i] = misclass
  
  pred = predict(filter, train)
  confm = table(train$type, pred)
  misclass = 1 - sum(diag(confm)) / sum(confm)
  res_train[i] = misclass
  
  i = i + 1
}

res = data.frame(C = C, Misclass = res, type = 'Validation')
res = rbind(res, data.frame(C = C, Misclass = res_train, type = 'Training'))

ggplot() + 
  geom_line(data = res, aes(x = C, y = Misclass, color = type))

best_c = C[which.min(res$Misclass)]

### Finished model selection - let's train the model!
final_filter = ksvm(type ~ ., data = rbind(train, val), kernel = 'rbfdot', 
                    kpar = list(sigma = 0.05), C = best_c)

pred = predict(final_filter, test)
confm = table(test$type, pred)
gen_error = 1 - sum(diag(confm)) / sum(confm)
gen_error