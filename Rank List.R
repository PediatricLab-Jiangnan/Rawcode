# Load necessary library
library(ggplot2)

# Read the CSV file
data <- read.csv('Your GBD File.csv')

# Filter rows with DALYs per 100,000 measure
data_daly <- subset(data, Measure == 'DALYs per 100,000')

# Select top 10 locations by DALY values
top_10_data <- head(data_daly[order(-data_daly$Value), ], 10)

# Create dataframe
countries <- top_10_data$Location
daly_values <- top_10_data$Value

data <- data.frame(
  Country = factor(countries, levels = rev(countries)),
  DALY = daly_values,
  Rank = 1:length(countries)
)

# Create custom color vector
colors <- c('#D8BFD8', '#90EE90', '#E6E6FA', '#F0E68C', '#87CEFA',
            '#ADD8E6', '#98FB98', '#FFE4B5', '#DDA0DD', '#FFA07A')

# Create the plot
p <- ggplot(data, aes(x = Rank, y = DALY, fill = Country)) +
  geom_bar(stat = "identity", width = 0.7) +
  coord_flip() +
  scale_fill_manual(values = colors) +
  labs(title = 'Occupational Cadmium Exposure\nAll Genders, All Ages, 2021, Location Ranking',
       x = 'Ranking',
       y = 'DALY per 100,000') +
  theme_minimal(base_size = 16) +  # Set base font size to 16
  theme(
    plot.title = element_text(size = 20, face = "bold"),
    axis.title.x = element_text(size = 16, face = "bold"),
    axis.title.y = element_text(size = 16, face = "bold"),
    axis.text.x = element_text(size = 14),
    axis.text.y = element_text(size = 14),
    legend.position = "none",  # Hide legend
    panel.grid.major = element_blank(),  # Remove major grid lines
    panel.grid.minor = element_blank(),  # Remove minor grid lines
    panel.border = element_blank(),  # Remove panel border
    axis.line = element_line(size = 1.2),  # Thicken axis lines
    axis.ticks = element_blank()  # Remove axis ticks
  ) +
  geom_text(aes(label = Country, y = DALY/2), size = 5, fontface = "bold", color = "black") +  # Add country name inside bars
  geom_text(aes(label = sprintf("%.2f", DALY), y = DALY), hjust = -0.1, size = 5, fontface = "bold", color = "black") +  # Add DALY value at bar ends
  scale_x_continuous(breaks = 1:length(countries), labels = as.character(1:length(countries))) +  # Set X axis breaks and labels from 1 to 10
  scale_y_continuous(breaks = seq(0, max(daly_values), by = 0.1))  # Set Y axis breaks

# Display the plot
print(p)