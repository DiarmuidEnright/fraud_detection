library(dplyr)
library(ggplot2)
library(caret)
library(cluster)# Read documentation
library(kernlab)
library(factoextra)
library(forecast)
library(Rtsne)
library(dbscan)
library(tensorflow)
library(keras)

setwd("data")
transactions = read.csv("transactions.csv")

summary(transactions)

transactions$location = as.numeric(factor(transactions$location))
transactions$time = as.numeric(factor(transactions$time))

transactions = na.omit(transactions)

# PCA for dim reduction
pca_model = prcomp(transactions[, c("amount", "location", "time")], scale. = TRUE)
transactions$pca1 = pca_model$x[, 1]
transactions$pca2 = pca_model$x[, 2]

# t-SNE for dim reduction
tsne_model = Rtsne(transactions[, c("amount", "location", "time")], dims = 2)
transactions$tsne1 = tsne_model$Y[, 1]
transactions$tsne2 = tsne_model$Y[, 2]

# Autoencoder
autoencoder_model = keras_model_sequential() %>%
  layer_dense(units = 2, activation = "relu", input_shape = c(3)) %>%
  layer_dense(units = 3, activation = "relu") %>%
  layer_dense(units = 2, activation = "sigmoid")
autoencoder_model %>% compile(loss = "mean_squared_error", optimizer = "adam")
autoencoder_model %>% fit(transactions[, c("amount", "location", "time")], transactions[, c("amount", "location", "time")], epochs = 100)
autoencoder_output = predict(autoencoder_model, transactions[, c("amount", "location", "time")])
transactions$autoencoder1 = autoencoder_output[, 1]
transactions$autoencoder2 = autoencoder_output[, 2]

# One-class SVM anom detec
svm_model = ksvm(amount ~ ., data = transactions, type = "one-classification")
transactions$svm_anomaly = predict(svm_model, transactions)

# LOF anom detec
lof_model = lof(transactions[, c("amount", "location", "time")], k = 5)
transactions$lof_anomaly = lof_model

# k means clustering
kmeans_model = kmeans(transactions[, c("amount", "location", "time")], centers = 5)
transactions$kmeans_cluster = kmeans_model$cluster

# Hierarchical clustering
hclust_model = hclust(dist(transactions[, c("amount", "location", "time")]), method = "ward.D2")
transactions$hclust_cluster = cutree(hclust_model, k = 5)

# ARIMA (time series)
arima_model = auto.arima(transactions$amount, ic = "bic")
transactions$arima_forecast = forecast(arima_model, h = 30)$mean

# LSTM (time series)
lstm_model = keras_model_sequential() %>%
  layer_lstm(units = 50, input_shape = c(30, 1)) %>%
  layer_dense(units = 1)
lstm_model %>% compile(loss = "mean_squared_error", optimizer = "adam")
lstm_model %>% fit(array(transactions$amount, dim = c(length(transactions$amount), 1, 1)), transactions$amount, epochs = 100)
transactions$lstm_forecast = predict(lstm_model, array(transactions$amount, dim = c(length(transactions$amount), 1, 1)))

# Graph analysis
gcn_model = keras_model_sequential() %>%
  layer_dense(units = 32, input_shape = c(30, 1), activation = "relu") %>%
  layer_dense(units = 64, activation = "relu") %>%
  layer_dense(units = 1)
gcn_model %>% compile(loss = "mean_squared_error", optimizer = "adam")
gcn_model %>% fit(transactions$amount, transactions$amount, epochs = 100)
transactions$gcn_forecast = predict(gcn_model, transactions$amount)

gat_model = keras_model_sequential() %>%
  layer_dense(units = 32, input_shape = c(30, 1), activation = "relu") %>%
  layer_dense(units = 64, activation = "relu") %>%
  layer_dense(units = 1)
gat_model %>% compile(loss = "mean_squared_error", optimizer = "adam")
gat_model %>% fit(transactions$amount, transactions$amount, epochs = 100)
transactions$gat_fore