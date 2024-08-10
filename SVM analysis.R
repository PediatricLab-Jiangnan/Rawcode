# Set the working directory
setwd("Your path here")

# Load necessary libraries
library(tidyverse)
library(glmnet)
source('msvmRFE.R')  # obtain from github https://github.com/johncolby/SVM-RFE
library(sigFeature)
library(e1071)
library(caret)
library(randomForest)

# Read the CSV file
data <- read.csv("your own file ", row.names = 1)

# Convert group labels to binary (0 and 1)
data$group <- ifelse(data$group == "normal", 0, 1)

# Perform 5-fold cross-validation for SVM-RFE
set.seed(999)
results <- svmRFE(data, k = 5, halve.above = 100)

# Extract the top features
top.features <- WriteFeatures(results, data, save = FALSE)
write.csv(top.features, "feature_svm.csv")

# Select the top 48 variables to construct the SVM model
featsweep <- lapply(1:48, FeatSweep.wrap, results, data)
save(featsweep, file = "featsweep.RData")

# Calculate error rates
no.info <- min(prop.table(table(data[, 1])))
errors <- sapply(featsweep, function(x) ifelse(is.null(x), NA, x$error))

# Plot error rates
pdf("B_svm-error.pdf", width = 5, height = 5)
PlotErrors(errors, no.info = no.info)
dev.off()

# Plot accuracy rates
pdf("B_svm-accuracy.pdf", width = 5, height = 5)
Plotaccuracy(1 - errors, no.info = no.info)
dev.off()

# Identify the top features based on the minimum error rate
min_error_index <- which.min(errors)
top <- top.features[1:min_error_index, "FeatureName"]
write.csv(top, "top.csv")