# Simple Round Number Magnetism: Single-Year Analysis
# 
# Testing whether county populations cluster around round numbers using 2020 data

# Load required libraries
library(tidyverse)
library(tidycensus)
library(scales)
library(ggplot2)

# Set API key
census_api_key(Sys.getenv("CENSUS_API_KEY"))

# Analysis parameters
round_thresholds <- c(25000, 50000, 100000, 250000, 500000, 1000000)

cat("=== SIMPLE ROUND NUMBER MAGNETISM ANALYSIS ===\n")
cat("Testing population clustering at psychological thresholds\n")
cat("Thresholds:", paste(comma(round_thresholds), collapse = ", "), "\n")
cat("Using 2020 Census data\n\n")

# Get 2020 population data
cat("Fetching 2020 Census population data...\n")
pop_data <- get_decennial(
  geography = "county",
  variables = "P1_001N",
  year = 2020,
  output = "wide"
) %>%
  rename(population = P1_001N) %>%
  filter(!is.na(population), population > 0)

cat("Dataset rows:", nrow(pop_data), "\n")
cat("Population range:", comma(min(pop_data$population)), 
    "to", comma(max(pop_data$population)), "\n\n")

# Function to calculate distance to nearest round number
calculate_distance_to_round <- function(population, thresholds) {
  map_dbl(population, function(pop) {
    threshold_distances <- abs(pop - thresholds)
    min(threshold_distances) / pop  # Relative distance
  })
}

# Calculate distances to round numbers
cat("Calculating distances to round number thresholds...\n")
pop_analysis <- pop_data %>%
  mutate(
    distance_to_round = calculate_distance_to_round(population, round_thresholds),
    
    # Find closest threshold
    closest_threshold = map_dbl(population, function(pop) {
      threshold_distances <- abs(pop - round_thresholds)
      round_thresholds[which.min(threshold_distances)]
    }),
    
    # Calculate relative position to closest threshold
    relative_position = (population - closest_threshold) / closest_threshold,
    
    # Create bins for analysis
    position_bin = cut(relative_position, 
                      breaks = seq(-0.3, 0.3, by = 0.02),
                      include.lowest = TRUE),
    
    # Flag counties very close to thresholds
    very_close = distance_to_round <= 0.01,  # Within 1%
    close = distance_to_round <= 0.05       # Within 5%
  ) %>%
  filter(!is.na(position_bin))

cat("Counties within 1% of thresholds:", sum(pop_analysis$very_close), "\n")
cat("Counties within 5% of thresholds:", sum(pop_analysis$close), "\n\n")

# Test 1: Clustering analysis
cat("=== TEST 1: CLUSTERING AROUND ROUND NUMBERS ===\n")

# Count observations in each bin
bin_counts <- pop_analysis %>%
  count(position_bin) %>%
  filter(!is.na(position_bin))

# Test for uniformity
clustering_test <- chisq.test(bin_counts$n)

cat("Chi-square test for uniform distribution:\n")
cat("X-squared =", round(clustering_test$statistic, 3), "\n")
cat("p-value =", format.pval(clustering_test$p.value), "\n")

# Look for peak at zero (exact round numbers)
central_bins <- bin_counts %>%
  mutate(
    bin_center = as.numeric(str_extract(position_bin, "-?0\\.[0-9]+")) + 0.01
  ) %>%
  filter(abs(bin_center) <= 0.05) %>%
  arrange(bin_center)

cat("\nObservations in central bins (±5%):\n")
print(central_bins)

# Test 2: Bunching analysis
cat("\n=== TEST 2: BUNCHING ANALYSIS ===\n")

# For each threshold, count exact and near matches
bunching_results <- map_dfr(round_thresholds, function(threshold) {
  exact_matches <- sum(pop_analysis$population == threshold)
  within_1pct <- sum(abs(pop_analysis$population - threshold) <= threshold * 0.01)
  within_2pct <- sum(abs(pop_analysis$population - threshold) <= threshold * 0.02)
  within_5pct <- sum(abs(pop_analysis$population - threshold) <= threshold * 0.05)
  
  tibble(
    threshold = threshold,
    exact_matches = exact_matches,
    within_1pct = within_1pct,
    within_2pct = within_2pct,
    within_5pct = within_5pct
  )
})

print(bunching_results)

# Total bunching
total_exact <- sum(bunching_results$exact_matches)
total_close <- sum(pop_analysis$very_close)

cat("\nTotal exact threshold matches:", total_exact, "\n")
cat("Total counties within 1% of thresholds:", total_close, "\n")
cat("Percentage of all counties:", percent(total_close / nrow(pop_analysis)), "\n")

# Test 3: Identify specific examples
cat("\n=== TEST 3: SPECIFIC EXAMPLES ===\n")

# Find counties very close to major thresholds
close_examples <- pop_analysis %>%
  filter(very_close, closest_threshold >= 100000) %>%
  select(NAME, population, closest_threshold, distance_to_round) %>%
  arrange(distance_to_round) %>%
  head(10)

if (nrow(close_examples) > 0) {
  cat("Counties very close to major thresholds:\n")
  print(close_examples)
} else {
  cat("No counties found very close to major thresholds\n")
}

# Find exact matches
exact_matches <- pop_analysis %>%
  filter(distance_to_round == 0) %>%
  select(NAME, population, closest_threshold)

if (nrow(exact_matches) > 0) {
  cat("\nCounties with exact round number populations:\n")
  print(exact_matches)
} else {
  cat("\nNo counties with exact round number populations found\n")
}

# Create visualizations
cat("\n=== CREATING VISUALIZATIONS ===\n")

# Plot 1: Population distribution with threshold lines
p1 <- pop_analysis %>%
  filter(population >= 10000, population <= 1500000) %>%
  ggplot(aes(x = population)) +
  geom_histogram(bins = 100, fill = "grey20", alpha = 0.7) +
  geom_vline(xintercept = round_thresholds, 
             color = "red", linetype = "dashed", alpha = 0.8) +
  scale_x_continuous(labels = comma_format()) +
  labs(
    title = "County Population Distribution with Round Number Thresholds",
    subtitle = "Red lines show hypothetical psychological thresholds",
    x = "Population",
    y = "Count"
  ) +
  theme_minimal()

print(p1)

# Plot 2: Relative position histogram (zoomed in)
p2 <- pop_analysis %>%
  filter(abs(relative_position) <= 0.2) %>%
  ggplot(aes(x = relative_position)) +
  geom_histogram(bins = 40, fill = "grey20", alpha = 0.7) +
  geom_vline(xintercept = 0, color = "red", linetype = "dashed") +
  scale_x_continuous(labels = percent_format()) +
  labs(
    title = "County Populations Relative to Nearest Round Number",
    subtitle = "Do counties cluster at 0% (exact round numbers)?",
    x = "Position relative to nearest threshold",
    y = "Count of counties"
  ) +
  theme_minimal()

print(p2)

# Plot 3: Distance distribution
p3 <- pop_analysis %>%
  filter(distance_to_round <= 0.2) %>%
  ggplot(aes(x = distance_to_round)) +
  geom_histogram(bins = 50, fill = "grey20", alpha = 0.7) +
  scale_x_continuous(labels = percent_format()) +
  labs(
    title = "Distance to Nearest Round Number Threshold",
    subtitle = "Random distribution would be uniform; clustering would show peak near 0",
    x = "Distance to nearest threshold (% of population)",
    y = "Count of counties"
  ) +
  theme_minimal()

print(p3)

# Summary statistics
cat("\n=== SUMMARY STATISTICS ===\n")
cat("Total counties analyzed:", nrow(pop_analysis), "\n")
cat("Mean distance to round numbers:", percent(mean(pop_analysis$distance_to_round)), "\n")
cat("Median distance to round numbers:", percent(median(pop_analysis$distance_to_round)), "\n")
cat("Counties within 1% of thresholds:", sum(pop_analysis$very_close), 
    "(", percent(mean(pop_analysis$very_close)), ")\n")
cat("Counties within 5% of thresholds:", sum(pop_analysis$close), 
    "(", percent(mean(pop_analysis$close)), ")\n")

# Most popular thresholds
threshold_popularity <- pop_analysis %>%
  filter(close) %>%
  count(closest_threshold, sort = TRUE)

cat("\nMost popular nearby thresholds:\n")
print(threshold_popularity)

cat("\n=== ANALYSIS COMPLETE ===\n")