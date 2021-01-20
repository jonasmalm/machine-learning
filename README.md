# machine-learning
During the course [TDDE01: Machine Learning](https://liu.se/studieinfo/en/kurs/tdde01/ht-2020), I learned the basics of machine learning in the fall off 2020. In this repo, I included some R-code I wrote during the course.

# neuralnet.R: Neural Network Regression
![Neuralnet](images/nn.png)

In this file I create a neural network that predicts sin(x) from x. There is also some code to manually calculate the output of each layer using the sigmoid activation function.

# pca.R: Principle Component Analysis
![PCA](images/pca.png)

Here I do Principle Component Analysis on the iris data set, using features Sepal.Width and Sepal.Length to create two new coordinate axis. First implemented from scratch, and then plotted in the new coordinate system using the princomp package.

# svm.R: Support Vector Machines
![SVM](images/svm.png)

In this file I classify the spam data set using support vector machines with a gaussian kernel and the width 0.05. First train the model on training data and make predictions on the validation data for different C-values. Then the optimal C is chosen (here 3.5) and the model is trained on both training and validation data. Finally the generalization error is estimated using the test data set.
