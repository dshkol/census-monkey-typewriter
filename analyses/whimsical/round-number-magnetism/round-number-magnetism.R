# Round Number Magnetism: Population Clustering at Psychological Thresholds
# 
# Hypothesis: Do county populations cluster around round numbers (100k, 250k, 500k) 
# more than random chance predicts?
#
# Testing whether growth rates slow as counties approach these thresholds and 
# accelerate after crossing them.

# Load required libraries
library(tidyverse)
library(tidycensus)
library(scales)
library(ggplot2)
library(broom)
library(gt)

# Set API key
census_api_key(Sys.getenv("CENSUS_API_KEY"))

# Analysis parameters
round_thresholds <- c(25000, 50000, 100000, 250000, 500000, 1000000)
years <- c(2010, 2020, 2019:2023)  # Use years we know work
threshold_tolerance <- 0.05  # 5% window around thresholds

cat("=== ROUND NUMBER MAGNETISM ANALYSIS ===\n")
cat("Testing population clustering at psychological thresholds\n")
cat("Thresholds:", paste(comma(round_thresholds), collapse = ", "), "\n")
cat("Years:", min(years), "-", max(years), "\n\n")

# Function to get population data for a single year
get_pop_data <- function(year) {
  cat("Fetching population data for", year, "...\n")
  
  # Use correct variable names for each data source
  if (year == 2010) {
    # 2010 uses different variable name
    get_decennial(
      geography = "county",
      variables = "P001001",  # Total population for 2010
      year = year,
      output = "wide"
    ) %>%
      rename(population = P001001)
  } else if (year == 2020) {
    # 2020 uses P1_001N
    get_decennial(
      geography = "county",
      variables = "P1_001N",  # Total population for 2020
      year = year,
      output = "wide"
    ) %>%
      rename(population = P1_001N)
  } else {
    # PEP data for other years
    get_estimates(
      geography = "county", 
      product = "population",
      year = year,
      output = "wide"
    ) %>%
      rename(population = POPESTIMATE)
  }
}

# Get population data for all years
cat("Acquiring population time series data...\n")
pop_data_list <- map(years, get_pop_data)

# Combine into single dataset
pop_data <- pop_data_list %>%
  imap_dfr(~ .x %>% mutate(year = years[.y])) %>%
  select(GEOID, NAME, year, population) %>%
  arrange(GEOID, year)

cat("Dataset rows:", nrow(pop_data), "\n")
cat("Unique counties:", length(unique(pop_data$GEOID)), "\n")
cat("Population range:", comma(min(pop_data$population, na.rm = T)), 
    "to", comma(max(pop_data$population, na.rm = T)), "\n\n")

# Calculate growth rates
cat("Calculating year-over-year growth rates...\n")
pop_growth <- pop_data %>%
  group_by(GEOID) %>%
  arrange(year) %>%
  mutate(
    pop_lag = lag(population),
    growth_rate = (population - pop_lag) / pop_lag,
    growth_rate = ifelse(is.infinite(growth_rate) | is.nan(growth_rate), NA, growth_rate)
  ) %>%
  filter(!is.na(growth_rate)) %>%
  ungroup()

cat("Growth data rows:", nrow(pop_growth), "\n")
cat("Mean growth rate:", percent(mean(pop_growth$growth_rate, na.rm = T)), "\n\n")

# Function to calculate distance to nearest round number
calculate_distance_to_round <- function(population, thresholds) {
  # For each population, find distance to nearest threshold
  distances <- map_dbl(population, function(pop) {
    # Calculate distance to each threshold
    threshold_distances <- abs(pop - thresholds)
    # Return minimum distance as proportion of population
    min(threshold_distances) / pop
  })
  return(distances)
}

# Calculate distance to nearest round number for each observation
cat("Calculating distances to round number thresholds...\n")
pop_analysis <- pop_growth %>%
  mutate(
    distance_to_round = calculate_distance_to_round(population, round_thresholds),
    near_threshold = distance_to_round <= threshold_tolerance,
    
    # Find the specific threshold each county is closest to
    closest_threshold = map_dbl(population, function(pop) {
      threshold_distances <- abs(pop - round_thresholds)
      round_thresholds[which.min(threshold_distances)]
    }),
    
    # Calculate direction relative to threshold (above or below)
    threshold_direction = ifelse(population > closest_threshold, "above", "below"),
    
    # Calculate growth rate in next year for threshold crossing analysis
    growth_rate_next = lead(growth_rate)
  ) %>%
  group_by(GEOID) %>%
  arrange(year) %>%
  ungroup()

cat("Counties near thresholds (±5%):", sum(pop_analysis$near_threshold), 
    "of", nrow(pop_analysis), "observations\n\n")

# Test 1: Do counties cluster near round numbers more than expected?
cat("=== TEST 1: CLUSTERING AROUND ROUND NUMBERS ===\n")

# Create histogram bins and count observations
bin_analysis <- pop_analysis %>%
  filter(population >= min(round_thresholds) * 0.5,  # Focus on relevant range
         population <= max(round_thresholds) * 1.5) %>%
  mutate(
    # Create bins relative to nearest threshold
    relative_position = (population - closest_threshold) / closest_threshold,
    position_bin = cut(relative_position, 
                      breaks = seq(-0.5, 0.5, by = 0.05),
                      include.lowest = TRUE)
  )

# Count observations in each bin
bin_counts <- bin_analysis %>%
  count(position_bin) %>%
  filter(!is.na(position_bin))

# Test for uniformity (should be roughly equal if no clustering)
clustering_test <- chisq.test(bin_counts$n)

cat("Chi-square test for uniform distribution:\n")
cat("X-squared =", round(clustering_test$statistic, 3), "\n")
cat("p-value =", format.pval(clustering_test$p.value), "\n")
cat("Interpretation:", ifelse(clustering_test$p.value < 0.05, 
                             "Significant clustering detected", 
                             "No significant clustering"), "\n\n")

# Test 2: Do growth rates change near thresholds?
cat("=== TEST 2: GROWTH RATE CHANGES NEAR THRESHOLDS ===\n")

# Compare growth rates near vs. far from thresholds
threshold_growth <- pop_analysis %>%
  filter(!is.na(growth_rate)) %>%
  group_by(near_threshold) %>%
  summarise(
    n = n(),
    mean_growth = mean(growth_rate, na.rm = T),
    median_growth = median(growth_rate, na.rm = T),
    sd_growth = sd(growth_rate, na.rm = T),
    .groups = "drop"
  )

print(threshold_growth)

# Statistical test
growth_test <- t.test(
  growth_rate ~ near_threshold, 
  data = filter(pop_analysis, !is.na(growth_rate))
)

cat("\nT-test comparing growth rates near vs. far from thresholds:\n")
cat("t =", round(growth_test$statistic, 3), "\n")
cat("p-value =", format.pval(growth_test$p.value), "\n")
cat("Mean difference:", percent(diff(growth_test$estimate)), "\n\n")

# Test 3: Regression discontinuity around specific thresholds
cat("=== TEST 3: REGRESSION DISCONTINUITY ANALYSIS ===\n")

# Focus on 100k threshold as most common
rd_data <- pop_analysis %>%
  filter(
    population >= 75000, 
    population <= 125000,
    !is.na(growth_rate)
  ) %>%
  mutate(
    above_100k = population > 100000,
    distance_from_100k = population - 100000,
    distance_from_100k_scaled = distance_from_100k / 1000  # Scale for interpretation
  )

if (nrow(rd_data) > 50) {  # Need sufficient observations
  # Regression discontinuity model
  rd_model <- lm(
    growth_rate ~ distance_from_100k_scaled + above_100k + 
                  distance_from_100k_scaled:above_100k,
    data = rd_data
  )
  
  cat("Regression discontinuity around 100k threshold:\n")
  print(summary(rd_model))
  
  # Extract key coefficient (discontinuity at threshold)
  rd_effect <- coef(rd_model)["above_100kTRUE"]
  rd_se <- sqrt(diag(vcov(rd_model)))["above_100kTRUE"]
  rd_pvalue <- summary(rd_model)$coefficients["above_100kTRUE", "Pr(>|t|)"]
  
  cat("\nDiscontinuity effect at 100k threshold:\n")
  cat("Coefficient:", percent(rd_effect), "±", percent(1.96 * rd_se), "\n")
  cat("p-value:", format.pval(rd_pvalue), "\n")
} else {
  cat("Insufficient observations near 100k threshold for RD analysis\n")
}

# Test 4: Bunching analysis - look for excess mass near thresholds
cat("\n=== TEST 4: BUNCHING ANALYSIS ===\n")

# For each threshold, count observations in narrow bands
bunching_results <- map_dfr(round_thresholds, function(threshold) {
  # Define narrow bands around threshold
  bands <- list(
    "within_1pct" = c(threshold * 0.99, threshold * 1.01),
    "within_2pct" = c(threshold * 0.98, threshold * 1.02),
    "within_5pct" = c(threshold * 0.95, threshold * 1.05)
  )
  
  # Count observations in each band
  band_counts <- map_dbl(bands, function(band) {
    sum(pop_analysis$population >= band[1] & pop_analysis$population <= band[2])
  })
  
  # Calculate expected count based on nearby density
  nearby_range <- c(threshold * 0.8, threshold * 1.2)
  nearby_count <- sum(pop_analysis$population >= nearby_range[1] & 
                     pop_analysis$population <= nearby_range[2])
  expected_density <- nearby_count / (nearby_range[2] - nearby_range[1])
  
  tibble(
    threshold = threshold,
    within_1pct = band_counts[1],
    within_2pct = band_counts[2], 
    within_5pct = band_counts[3],
    expected_1pct = expected_density * (threshold * 0.02),
    expected_2pct = expected_density * (threshold * 0.04),
    expected_5pct = expected_density * (threshold * 0.10),
    excess_1pct = band_counts[1] - (expected_density * threshold * 0.02),
    excess_2pct = band_counts[2] - (expected_density * threshold * 0.04),
    excess_5pct = band_counts[3] - (expected_density * threshold * 0.10)
  )
})

print(bunching_results)

# Summary statistics
cat("\n=== SUMMARY STATISTICS ===\n")
cat("Total county-year observations:", nrow(pop_analysis), "\n")
cat("Observations near thresholds (±5%):", sum(pop_analysis$near_threshold), "\n")
cat("Percentage near thresholds:", percent(mean(pop_analysis$near_threshold)), "\n")

# Most common thresholds
threshold_popularity <- pop_analysis %>%
  filter(near_threshold) %>%
  count(closest_threshold, sort = TRUE)

cat("\nMost common nearby thresholds:\n")
print(threshold_popularity)

# Create visualizations
cat("\n=== CREATING VISUALIZATIONS ===\n")

# Plot 1: Population distribution with threshold lines
p1 <- pop_analysis %>%
  filter(population >= 10000, population <= 1500000) %>%
  ggplot(aes(x = population)) +
  geom_histogram(bins = 100, fill = "grey20", alpha = 0.7) +
  geom_vline(xintercept = round_thresholds, 
             color = "red", linetype = "dashed", alpha = 0.8) +
  scale_x_continuous(labels = comma_format(), trans = "log10") +
  labs(
    title = "County Population Distribution with Round Number Thresholds",
    subtitle = "Red lines show hypothetical psychological thresholds",
    x = "Population (log scale)",
    y = "Count"
  ) +
  theme_minimal()

print(p1)

# Plot 2: Growth rates near vs. far from thresholds
p2 <- pop_analysis %>%
  filter(!is.na(growth_rate), abs(growth_rate) < 0.1) %>%  # Remove extreme outliers
  ggplot(aes(x = near_threshold, y = growth_rate)) +
  geom_boxplot(fill = "grey20", alpha = 0.7) +
  scale_x_discrete(labels = c("FALSE" = "Far from\nthresholds", 
                             "TRUE" = "Near\nthresholds")) +
  scale_y_continuous(labels = percent_format()) +
  labs(
    title = "Growth Rates Near vs. Far from Round Number Thresholds",
    subtitle = "Do counties slow growth when approaching round numbers?",
    x = "Position relative to thresholds",
    y = "Annual growth rate"
  ) +
  theme_minimal()

print(p2)

# Plot 3: Distance to round numbers vs. growth rate
p3 <- pop_analysis %>%
  filter(!is.na(growth_rate), 
         abs(growth_rate) < 0.1,
         distance_to_round <= 0.2) %>%  # Focus on counties within 20% of thresholds
  ggplot(aes(x = distance_to_round, y = growth_rate)) +
  geom_point(alpha = 0.5, color = "grey20") +
  geom_smooth(method = "lm", color = "red") +
  scale_x_continuous(labels = percent_format()) +
  scale_y_continuous(labels = percent_format()) +
  labs(
    title = "Growth Rate vs. Distance from Nearest Round Number",
    subtitle = "Does proximity to round numbers affect growth patterns?",
    x = "Distance to nearest threshold (% of population)",
    y = "Annual growth rate"
  ) +
  theme_minimal()

print(p3)

cat("\nAnalysis complete!\n")

# Test of extremes - identify counties that cross major thresholds
cat("\n=== THRESHOLD CROSSING ANALYSIS ===\n")

threshold_crossings <- pop_data %>%
  filter(year >= 2011) %>%  # Need previous year data
  group_by(GEOID) %>%
  arrange(year) %>%
  mutate(
    pop_prev = lag(population),
    crossed_threshold = map2_lgl(pop_prev, population, function(prev, curr) {
      if (is.na(prev)) return(FALSE)
      # Check if county crossed any major threshold
      any(
        (prev < round_thresholds & curr >= round_thresholds) |
        (prev >= round_thresholds & curr < round_thresholds)
      )
    })
  ) %>%
  filter(crossed_threshold) %>%
  ungroup()

cat("Counties that crossed major thresholds:", nrow(threshold_crossings), "\n")

if (nrow(threshold_crossings) > 0) {
  cat("\nExample threshold crossings:\n")
  print(threshold_crossings %>%
    select(NAME, year, pop_prev, population) %>%
    mutate(
      pop_prev = comma(pop_prev),
      population = comma(population)
    ) %>%
    head(10))
}

cat("\n=== ANALYSIS COMPLETE ===\n")