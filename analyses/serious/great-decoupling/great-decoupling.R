# The Great Decoupling: Housing Unit Growth vs Population Growth Divergence
#
# Hypothesis: Since 2010, housing unit growth has dramatically outpaced population 
# growth in many US metropolitan areas, creating a "great decoupling" that signals 
# fundamental shifts in housing demand, household formation, and urban development patterns.

library(tidyverse)
library(tidycensus)
library(scales)
library(ggplot2)
library(viridis)

# Set API key
census_api_key(Sys.getenv("CENSUS_API_KEY"))

cat("=== THE GREAT DECOUPLING ANALYSIS ===\n")
cat("Testing housing unit vs population growth divergence 2010-2022\n")
cat("Hypothesis: Housing growth outpaces population growth in many metros\n\n")

# Step 1: Get 2010 baseline data
cat("=== STEP 1: 2010 BASELINE DATA ===\n")

# Get 2010 population and housing data by county
cat("Fetching 2010 population and housing data...\n")
data_2010 <- get_acs(
  geography = "county",
  variables = c(
    "B01001_001",  # Total population
    "B25001_001"   # Total housing units
  ),
  year = 2010,
  output = "wide",
  survey = "acs5"
) %>%
  mutate(
    pop_2010 = B01001_001E,
    housing_2010 = B25001_001E,
    county_fips = GEOID
  ) %>%
  select(county_fips, NAME, pop_2010, housing_2010)

cat("Counties with 2010 data:", nrow(data_2010), "\n")

# Step 2: Get 2022 comparison data
cat("\n=== STEP 2: 2022 COMPARISON DATA ===\n")

cat("Fetching 2022 population and housing data...\n")
data_2022 <- get_acs(
  geography = "county", 
  variables = c(
    "B01001_001",  # Total population
    "B25001_001"   # Total housing units
  ),
  year = 2022,
  output = "wide",
  survey = "acs5"
) %>%
  mutate(
    pop_2022 = B01001_001E,
    housing_2022 = B25001_001E,
    county_fips = GEOID
  ) %>%
  select(county_fips, pop_2022, housing_2022)

cat("Counties with 2022 data:", nrow(data_2022), "\n")

# Step 3: Calculate growth rates and decoupling
cat("\n=== STEP 3: GROWTH ANALYSIS ===\n")

# Combine datasets and calculate changes
decoupling_analysis <- data_2010 %>%
  inner_join(data_2022, by = "county_fips") %>%
  mutate(
    # Calculate absolute changes
    pop_change = pop_2022 - pop_2010,
    housing_change = housing_2022 - housing_2010,
    
    # Calculate percentage growth rates
    pop_growth_rate = ifelse(pop_2010 > 0, (pop_2022 - pop_2010) / pop_2010 * 100, NA),
    housing_growth_rate = ifelse(housing_2010 > 0, (housing_2022 - housing_2010) / housing_2010 * 100, NA),
    
    # Calculate decoupling metrics
    growth_rate_diff = housing_growth_rate - pop_growth_rate,
    growth_ratio = ifelse(pop_growth_rate != 0, housing_growth_rate / pop_growth_rate, NA),
    
    # Create state identifier
    state_fips = str_sub(county_fips, 1, 2),
    
    # Categorize decoupling patterns
    decoupling_category = case_when(
      growth_rate_diff >= 10 ~ "Extreme Decoupling (10%+ gap)",
      growth_rate_diff >= 5 ~ "Strong Decoupling (5-10% gap)",
      growth_rate_diff >= 2 ~ "Moderate Decoupling (2-5% gap)", 
      growth_rate_diff >= -2 ~ "Coupled Growth (-2 to 2% gap)",
      growth_rate_diff >= -5 ~ "Reverse Decoupling (-5 to -2% gap)",
      TRUE ~ "Strong Reverse Decoupling (<-5% gap)"
    ),
    
    # Growth pattern categories
    growth_pattern = case_when(
      pop_growth_rate > 0 & housing_growth_rate > pop_growth_rate ~ "Housing Outpacing Population",
      pop_growth_rate > 0 & housing_growth_rate > 0 & housing_growth_rate <= pop_growth_rate ~ "Coupled Positive Growth",
      pop_growth_rate <= 0 & housing_growth_rate > 0 ~ "Housing Growth, Population Decline",
      pop_growth_rate > 0 & housing_growth_rate <= 0 ~ "Population Growth, Housing Decline", 
      pop_growth_rate <= 0 & housing_growth_rate <= 0 ~ "Dual Decline",
      TRUE ~ "Other"
    )
  ) %>%
  filter(!is.na(pop_growth_rate), !is.na(housing_growth_rate), 
         pop_2010 >= 10000) %>%  # Filter very small counties
  arrange(desc(growth_rate_diff))

cat("Counties with complete data:", nrow(decoupling_analysis), "\n")
cat("Mean population growth rate:", round(mean(decoupling_analysis$pop_growth_rate, na.rm = TRUE), 1), "%\n")
cat("Mean housing growth rate:", round(mean(decoupling_analysis$housing_growth_rate, na.rm = TRUE), 1), "%\n")
cat("Mean growth rate difference:", round(mean(decoupling_analysis$growth_rate_diff, na.rm = TRUE), 1), "pp\n")

# Display decoupling distribution
decoupling_summary <- decoupling_analysis %>%
  count(decoupling_category, sort = TRUE) %>%
  mutate(percentage = round(n / sum(n) * 100, 1))

cat("\nDecoupling pattern distribution:\n")
print(decoupling_summary)

# Step 4: Identify extreme cases
cat("\n=== STEP 4: EXTREME DECOUPLING CASES ===\n")

# Top 15 counties with strongest decoupling
cat("Top 15 counties with strongest housing-population decoupling:\n")
top_decoupling <- decoupling_analysis %>%
  head(15) %>%
  select(NAME, pop_growth_rate, housing_growth_rate, growth_rate_diff) %>%
  mutate(
    NAME = str_remove(NAME, " County.*$"),
    pop_growth_rate = round(pop_growth_rate, 1),
    housing_growth_rate = round(housing_growth_rate, 1),
    growth_rate_diff = round(growth_rate_diff, 1)
  )

print(top_decoupling)

# Bottom 15 counties (reverse decoupling)
cat("\nTop 15 counties with strongest reverse decoupling:\n")
bottom_decoupling <- decoupling_analysis %>%
  tail(15) %>%
  select(NAME, pop_growth_rate, housing_growth_rate, growth_rate_diff) %>%
  mutate(
    NAME = str_remove(NAME, " County.*$"),
    pop_growth_rate = round(pop_growth_rate, 1),
    housing_growth_rate = round(housing_growth_rate, 1),
    growth_rate_diff = round(growth_rate_diff, 1)
  )

print(bottom_decoupling)

# Step 5: Geographic and size analysis
cat("\n=== STEP 5: GEOGRAPHIC PATTERNS ===\n")

# Analysis by state (top 10 states by county count)
state_patterns <- decoupling_analysis %>%
  mutate(
    state_name = case_when(
      state_fips == "06" ~ "California",
      state_fips == "48" ~ "Texas", 
      state_fips == "12" ~ "Florida",
      state_fips == "36" ~ "New York",
      state_fips == "42" ~ "Pennsylvania",
      state_fips == "17" ~ "Illinois",
      state_fips == "39" ~ "Ohio",
      state_fips == "37" ~ "North Carolina",
      state_fips == "13" ~ "Georgia",
      state_fips == "53" ~ "Washington",
      TRUE ~ "Other"
    )
  ) %>%
  filter(state_name != "Other") %>%
  group_by(state_name) %>%
  summarise(
    n_counties = n(),
    mean_pop_growth = round(mean(pop_growth_rate, na.rm = TRUE), 1),
    mean_housing_growth = round(mean(housing_growth_rate, na.rm = TRUE), 1),
    mean_decoupling = round(mean(growth_rate_diff, na.rm = TRUE), 1),
    strong_decoupling_pct = round(mean(growth_rate_diff >= 5) * 100, 1),
    .groups = "drop"
  ) %>%
  arrange(desc(mean_decoupling))

cat("Decoupling patterns by major states:\n")
print(state_patterns)

# Analysis by county size
size_patterns <- decoupling_analysis %>%
  mutate(
    county_size = case_when(
      pop_2010 >= 1000000 ~ "Very Large (1M+)",
      pop_2010 >= 500000 ~ "Large (500K-1M)",
      pop_2010 >= 100000 ~ "Medium (100K-500K)",
      pop_2010 >= 50000 ~ "Small (50K-100K)",
      TRUE ~ "Very Small (<50K)"
    )
  ) %>%
  group_by(county_size) %>%
  summarise(
    n_counties = n(),
    mean_pop_growth = round(mean(pop_growth_rate, na.rm = TRUE), 1),
    mean_housing_growth = round(mean(housing_growth_rate, na.rm = TRUE), 1),
    mean_decoupling = round(mean(growth_rate_diff, na.rm = TRUE), 1),
    .groups = "drop"
  )

cat("\nDecoupling patterns by county size:\n")
print(size_patterns)

# Step 6: Statistical tests
cat("\n=== STEP 6: STATISTICAL ANALYSIS ===\n")

# Test if housing growth significantly exceeds population growth
t_test_rates <- t.test(decoupling_analysis$housing_growth_rate, 
                       decoupling_analysis$pop_growth_rate,
                       paired = TRUE)

cat("Paired t-test: Housing growth rate vs Population growth rate\n")
cat("  Mean housing growth:", round(mean(decoupling_analysis$housing_growth_rate), 1), "%\n")
cat("  Mean population growth:", round(mean(decoupling_analysis$pop_growth_rate), 1), "%\n")
cat("  Mean difference:", round(mean(decoupling_analysis$growth_rate_diff), 1), "pp\n")
cat("  P-value:", format.pval(t_test_rates$p.value), "\n")

# Test correlation between population and housing growth
cor_test <- cor.test(decoupling_analysis$pop_growth_rate, 
                     decoupling_analysis$housing_growth_rate)

cat("\nCorrelation: Population growth vs Housing growth\n")
cat("  Correlation coefficient:", round(cor_test$estimate, 3), "\n")
cat("  P-value:", format.pval(cor_test$p.value), "\n")

# Proportion of counties with decoupling
decoupling_pct <- mean(decoupling_analysis$growth_rate_diff > 2) * 100
strong_decoupling_pct <- mean(decoupling_analysis$growth_rate_diff >= 5) * 100

cat("\nDecoupling prevalence:\n")
cat("  Counties with moderate+ decoupling (>2pp):", round(decoupling_pct, 1), "%\n")
cat("  Counties with strong decoupling (≥5pp):", round(strong_decoupling_pct, 1), "%\n")

# Step 7: Visualizations
cat("\n=== STEP 7: CREATING VISUALIZATIONS ===\n")

# Plot 1: Scatter plot of population vs housing growth
p1 <- decoupling_analysis %>%
  ggplot(aes(x = pop_growth_rate, y = housing_growth_rate)) +
  geom_point(alpha = 0.6, color = "grey20") +
  geom_smooth(method = "lm", color = "red") +
  geom_abline(slope = 1, intercept = 0, color = "blue", linetype = "dashed") +
  labs(
    title = "Population Growth vs. Housing Unit Growth (2010-2022)",
    subtitle = "Blue dashed line = perfect coupling • Points above = housing outpacing population",
    x = "Population Growth Rate (%)",
    y = "Housing Unit Growth Rate (%)"
  ) +
  theme_minimal()

print(p1)

# Plot 2: Distribution of growth rate differences
p2 <- decoupling_analysis %>%
  ggplot(aes(x = growth_rate_diff)) +
  geom_histogram(bins = 50, fill = "grey20", alpha = 0.7) +
  geom_vline(xintercept = 0, color = "blue", linetype = "dashed") +
  geom_vline(xintercept = mean(decoupling_analysis$growth_rate_diff), 
             color = "red", linetype = "dashed") +
  labs(
    title = "Distribution of Housing-Population Growth Rate Differences",
    subtitle = "Blue = perfect coupling, Red = mean difference",
    x = "Growth Rate Difference (Housing % - Population %)",
    y = "Count of Counties"
  ) +
  theme_minimal()

print(p2)

# Plot 3: Decoupling by county size
p3 <- decoupling_analysis %>%
  mutate(
    county_size = case_when(
      pop_2010 >= 1000000 ~ "Very Large (1M+)",
      pop_2010 >= 500000 ~ "Large (500K-1M)",
      pop_2010 >= 100000 ~ "Medium (100K-500K)",
      TRUE ~ "Small (<100K)"
    )
  ) %>%
  ggplot(aes(x = county_size, y = growth_rate_diff)) +
  geom_boxplot(fill = "grey20", alpha = 0.7) +
  geom_hline(yintercept = 0, color = "blue", linetype = "dashed") +
  labs(
    title = "Housing-Population Growth Decoupling by County Size",
    subtitle = "Larger counties show different decoupling patterns",
    x = "County Size Category",
    y = "Growth Rate Difference (pp)"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

print(p3)

# Plot 4: Geographic pattern by major states
p4 <- decoupling_analysis %>%
  mutate(
    state_name = case_when(
      state_fips == "06" ~ "California",
      state_fips == "48" ~ "Texas", 
      state_fips == "12" ~ "Florida",
      state_fips == "36" ~ "New York",
      state_fips == "42" ~ "Pennsylvania",
      state_fips == "17" ~ "Illinois",
      state_fips == "39" ~ "Ohio",
      state_fips == "37" ~ "North Carolina",
      state_fips == "13" ~ "Georgia",
      state_fips == "53" ~ "Washington",
      TRUE ~ "Other"
    )
  ) %>%
  filter(state_name != "Other") %>%
  ggplot(aes(x = reorder(state_name, growth_rate_diff, median), y = growth_rate_diff)) +
  geom_boxplot(fill = "grey20", alpha = 0.7) +
  geom_hline(yintercept = 0, color = "blue", linetype = "dashed") +
  coord_flip() +
  labs(
    title = "Housing-Population Growth Decoupling by State",
    subtitle = "State-level patterns in the great decoupling",
    x = "State",
    y = "Growth Rate Difference (pp)"
  ) +
  theme_minimal()

print(p4)

# Step 8: Economic implications analysis
cat("\n=== STEP 8: ECONOMIC IMPLICATIONS ===\n")

# Calculate housing-to-population ratios
decoupling_analysis <- decoupling_analysis %>%
  mutate(
    housing_per_1000_2010 = housing_2010 / pop_2010 * 1000,
    housing_per_1000_2022 = housing_2022 / pop_2022 * 1000,
    housing_ratio_change = housing_per_1000_2022 - housing_per_1000_2010
  )

ratio_summary <- decoupling_analysis %>%
  summarise(
    mean_ratio_2010 = round(mean(housing_per_1000_2010, na.rm = TRUE), 1),
    mean_ratio_2022 = round(mean(housing_per_1000_2022, na.rm = TRUE), 1),
    mean_ratio_change = round(mean(housing_ratio_change, na.rm = TRUE), 1)
  )

cat("Housing units per 1000 population:\n")
cat("  2010 average:", ratio_summary$mean_ratio_2010, "\n")
cat("  2022 average:", ratio_summary$mean_ratio_2022, "\n")
cat("  Average change:", ratio_summary$mean_ratio_change, "\n")

# Summary results
cat("\n=== SUMMARY RESULTS ===\n")

total_counties <- nrow(decoupling_analysis)
decoupling_counties <- sum(decoupling_analysis$growth_rate_diff > 2)
strong_decoupling_counties <- sum(decoupling_analysis$growth_rate_diff >= 5)

cat("Great Decoupling Analysis Results:\n")
cat("  Total counties analyzed:", total_counties, "\n")
cat("  Counties with moderate+ decoupling:", decoupling_counties, 
    "(", round(decoupling_counties/total_counties*100, 1), "%)\\n")
cat("  Counties with strong decoupling:", strong_decoupling_counties,
    "(", round(strong_decoupling_counties/total_counties*100, 1), "%)\\n")

cat("\nKey Statistics:\n")
cat("  Mean population growth (2010-2022):", round(mean(decoupling_analysis$pop_growth_rate), 1), "%\n")
cat("  Mean housing growth (2010-2022):", round(mean(decoupling_analysis$housing_growth_rate), 1), "%\n")
cat("  Mean growth difference:", round(mean(decoupling_analysis$growth_rate_diff), 1), "pp\n")

# Hypothesis evaluation
cat("\nHYPOTHESIS EVALUATION:\n")

if (t_test_rates$p.value < 0.05 && mean(decoupling_analysis$growth_rate_diff) > 1) {
  cat("✓ GREAT DECOUPLING HYPOTHESIS SUPPORTED\n")
  cat("Housing unit growth significantly outpaces population growth\n")
  cat("  - Mean difference: ", round(mean(decoupling_analysis$growth_rate_diff), 1), " percentage points\n")
  cat("  - Statistical significance: p ", format.pval(t_test_rates$p.value), "\n")
  cat("  - Prevalence: ", round(strong_decoupling_pct, 1), "% of counties show strong decoupling\n")
} else if (t_test_rates$p.value < 0.05) {
  cat("○ PARTIAL SUPPORT: Statistically significant but modest difference\n")
  cat("Housing growth moderately exceeds population growth\n")
} else {
  cat("✗ GREAT DECOUPLING HYPOTHESIS NOT SUPPORTED\n")
  cat("No significant systematic difference between housing and population growth\n")
}

# Key findings summary
cat("\nKey Findings:\n")
if (cor_test$p.value < 0.05) {
  cat("- Population and housing growth are correlated (r = ", round(cor_test$estimate, 3), ")\n")
} else {
  cat("- Population and housing growth show weak correlation\n")
}

if (mean(decoupling_analysis$growth_rate_diff) > 2) {
  cat("- Clear evidence of systematic housing oversupply\n")
  cat("- Suggests changing household formation patterns\n")
  cat("- May indicate speculative development or demographic shifts\n")
} else {
  cat("- Growth patterns remain largely coupled\n")
  cat("- Traditional relationship between population and housing intact\n")
}

cat("\n=== ANALYSIS COMPLETE ===\n")