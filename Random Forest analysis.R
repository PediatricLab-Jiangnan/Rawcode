# Set the working directory
setwd("your path here")

# Load necessary library
library(randomForest)

# Read the input CSV file
train <- read.csv("your own file here")

# Display the dimensions of the dataset
dim(train)

# Prepare the data for modeling
data<- as.data.frame(train[,-1])
data$group <- ifelse(train$group == "Control", 0, 1)  # Convert group to binary (0 or 1)

# Convert the group variable to a factor
data$group <- factor(data$group)
dim(data.cox)

# Set the seed for reproducibility
set.seed(999)

# Fit the Random Forest model
fit <- randomForest(group ~ ., data = data)

# Display the fitted model
fit

# Plot the fitted model
plot(fit)

# Cross-validation
set.seed(647)
res <- rfcv(trainx = data.cox[,-1], trainy = data$group,
            cv.fold = 5,
            recursive = TRUE)

# Extract cross-validation results
n_var <- res$n.var
error_cv <- res$error.cv

# Display the number of variables and the error rates
res$n.var  # Number of variables
res$error.cv  # Error rates

# Create a more aesthetically pleasing plot
plot(n_var, error_cv, type = "o", lwd = 2, col = "steelblue", pch = 16, 
     xlab = "Number of Variables", ylab = "Cross-validation Error Rate",
     main = "Cross-validation Error Rate vs. Number of Variables",
     xlim = c(1, max(n_var)), ylim = c(0, max(error_cv) + 0.05))

# Add grid lines
grid()

# Add a horizontal reference line
abline(h = 0, col = "gray", lty = 2)

# Add a legend
legend("topright", legend = "Error Rate", col = "steelblue", lty = 1, lwd = 2, bty = "n")

# Add text annotation
text(max(n_var), max(error_cv), paste("Minimum Error:", round(min(error_cv), 4)), pos = 3)

# Assume res is the cross-validation result generated above
n_var <- res$n.var
error_cv <- res$error.cv
min_error <- min(error_cv)
min_var <- n_var[which.min(error_cv)]

# Create the plot using ggplot2
library(ggplot2)
p <- ggplot(data = data.frame(n_var, error_cv), aes(x = n_var, y = error_cv)) +
  geom_line(color = "steelblue", size = 1) +  # Adjust line color and size
  geom_point(aes(color = error_cv == min_error), size = 3) +  # Highlight the point with minimum error rate
  scale_color_manual(values = c("TRUE" = "red", "FALSE" = "blue")) +  # Use red color for the minimum error point
  labs(title = "Cross-validation Error Rate vs. Number of Variables",
       x = "Number of Variables", y = "Cross-validation Error Rate") +
  theme_minimal(base_size = 14) +  # Use minimal theme and adjust base font size
  theme(plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
        legend.position = "none") +  # Adjust title and legend position
  geom_text(aes(label = ifelse(error_cv == min_error, "Minimum", "")), 
            vjust = -1, hjust = -0.1, color = "red")  # Add text annotation

# Display the ggplot2 plot
print(p)