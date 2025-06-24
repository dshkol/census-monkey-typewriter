# The Bachelor Pad Index: Sex Ratio Imbalance and Housing Tenure
#
# Hypothesis: PUMAs with sex ratio skewed towards males aged 25-39 have 
# higher rentership rates and lower median rooms per unit compared to 
# female-skewed PUMAs. Male-dominated labor markets foster transient, 
# rental-focused housing culture.

library(tidyverse)
library(tidycensus)
library(scales)
library(ggplot2)

# Set API key
census_api_key(Sys.getenv("CENSUS_API_KEY"))

cat("=== THE BACHELOR PAD INDEX ANALYSIS ===\n")
cat("Testing sex ratio effects on housing tenure and unit size\n")
cat("Hypothesis: Male-skewed areas = more rentals + smaller units\n\n")

# Step 1: Get demographic data
cat("=== STEP 1: DEMOGRAPHIC DATA COLLECTION ===\n")

# Get age by sex data for PUMAs in major states
cat("Fetching age and sex data for PUMAs...\n")
demo_data <- get_acs(
  geography = "public use microdata area",
  state = c("CA", "TX", "NY", "FL", "WA"),  # Tech/oil/finance/diverse states
  variables = c(
    "B01001_001",  # Total population
    "B01001_002",  # Male
    "B01001_026",  # Female
    "B01001_009",  # Male: 25 to 29 years
    "B01001_010",  # Male: 30 to 34 years  
    "B01001_011",  # Male: 35 to 39 years
    "B01001_033",  # Female: 25 to 29 years
    "B01001_034",  # Female: 30 to 34 years
    "B01001_035"   # Female: 35 to 39 years
  ),
  year = 2022,
  output = "wide",
  survey = "acs5"
) %>%
  mutate(
    total_pop = B01001_001E,
    total_male = B01001_002E,
    total_female = B01001_026E,
    
    # Target age group: 25-39
    male_25_39 = B01001_009E + B01001_010E + B01001_011E,
    female_25_39 = B01001_033E + B01001_034E + B01001_035E,
    total_25_39 = male_25_39 + female_25_39,
    
    # Calculate sex ratios
    overall_sex_ratio = total_male / total_female * 100,
    target_sex_ratio = male_25_39 / female_25_39 * 100,
    
    # Classify by sex ratio skew
    sex_ratio_category = case_when(
      target_sex_ratio >= 120 ~ "Male-Skewed (120+)",
      target_sex_ratio >= 110 ~ "Male-Leaning (110-120)",
      target_sex_ratio >= 95 ~ "Balanced (95-110)",
      target_sex_ratio >= 85 ~ "Female-Leaning (85-95)",
      TRUE ~ "Female-Skewed (<85)"
    )
  ) %>%
  filter(!is.na(target_sex_ratio), total_25_39 >= 500) %>%  # Filter for meaningful sample
  select(GEOID, NAME, total_pop, total_25_39, male_25_39, female_25_39, 
         overall_sex_ratio, target_sex_ratio, sex_ratio_category)

cat("PUMAs analyzed:", nrow(demo_data), "\n")
cat("Mean sex ratio (25-39):", round(mean(demo_data$target_sex_ratio, na.rm = TRUE), 1), "\n")

# Display sex ratio distribution
sex_ratio_summary <- demo_data %>%
  count(sex_ratio_category, sort = TRUE) %>%
  mutate(percentage = round(n / sum(n) * 100, 1))

cat("\nSex ratio distribution:\n")
print(sex_ratio_summary)

# Step 2: Get housing tenure data
cat("\n=== STEP 2: HOUSING TENURE DATA ===\n")

cat("Fetching housing tenure data...\n")
tenure_data <- get_acs(
  geography = "public use microdata area",
  state = c("CA", "TX", "NY", "FL", "WA"),
  variables = c(
    "B25003_001",  # Total occupied housing units
    "B25003_002",  # Owner occupied
    "B25003_003"   # Renter occupied
  ),
  year = 2022,
  output = "wide",
  survey = "acs5"
) %>%
  mutate(
    total_units = B25003_001E,
    owner_occupied = B25003_002E,
    renter_occupied = B25003_003E,
    renter_pct = ifelse(total_units > 0, renter_occupied / total_units * 100, NA)
  ) %>%
  select(GEOID, total_units, renter_pct)

# Step 3: Get housing size data
cat("Fetching housing size data...\n")
size_data <- get_acs(
  geography = "public use microdata area", 
  state = c("CA", "TX", "NY", "FL", "WA"),
  variables = c(
    "B25018_001",  # Median number of rooms
    "B25041_001",  # Total housing units (for bedrooms)
    "B25041_002",  # No bedroom
    "B25041_003",  # 1 bedroom
    "B25041_004",  # 2 bedrooms
    "B25041_005",  # 3 bedrooms
    "B25041_006",  # 4 bedrooms
    "B25041_007"   # 5+ bedrooms
  ),
  year = 2022,
  output = "wide",
  survey = "acs5"
) %>%
  mutate(
    median_rooms = B25018_001E,
    total_housing_units = B25041_001E,
    small_units = B25041_002E + B25041_003E + B25041_004E,  # 0-2 bedrooms
    large_units = B25041_005E + B25041_006E + B25041_007E,  # 3+ bedrooms
    small_units_pct = ifelse(total_housing_units > 0, small_units / total_housing_units * 100, NA)
  ) %>%
  select(GEOID, median_rooms, small_units_pct)

# Step 4: Get income data for controls
cat("Fetching income data for controls...\n")
income_data <- get_acs(
  geography = "public use microdata area",
  state = c("CA", "TX", "NY", "FL", "WA"),
  variables = c(
    "B19013_001",  # Median household income
    "B01002_001"   # Median age
  ),
  year = 2022,
  output = "wide",
  survey = "acs5"
) %>%
  mutate(
    median_income = B19013_001E,
    median_age = B01002_001E
  ) %>%
  select(GEOID, median_income, median_age)

# Step 5: Combine all data
cat("\n=== STEP 3: COMPREHENSIVE ANALYSIS ===\n")

# Combine all datasets
bachelor_analysis <- demo_data %>%
  inner_join(tenure_data, by = "GEOID") %>%
  inner_join(size_data, by = "GEOID") %>%
  inner_join(income_data, by = "GEOID") %>%
  filter(!is.na(renter_pct), !is.na(median_rooms), !is.na(median_income)) %>%
  mutate(
    # Create state identifier for analysis
    state = str_sub(GEOID, 1, 2),
    state_name = case_when(
      state == "06" ~ "California",
      state == "48" ~ "Texas", 
      state == "36" ~ "New York",
      state == "12" ~ "Florida",
      state == "53" ~ "Washington",
      TRUE ~ "Other"
    )
  )

cat("PUMAs with complete data:", nrow(bachelor_analysis), "\n")

# Step 6: Statistical tests
cat("\n=== STEP 4: HYPOTHESIS TESTING ===\n")

# Test 1: Correlation between sex ratio and rental rate
cor_test1 <- cor.test(bachelor_analysis$target_sex_ratio, 
                      bachelor_analysis$renter_pct)

cat("Correlation: Sex ratio (25-39) vs. Rental rate\n")
cat("  Correlation coefficient:", round(cor_test1$estimate, 3), "\n")
cat("  P-value:", format.pval(cor_test1$p.value), "\n")

# Test 2: Correlation between sex ratio and housing size
cor_test2 <- cor.test(bachelor_analysis$target_sex_ratio, 
                      bachelor_analysis$median_rooms)

cat("\nCorrelation: Sex ratio (25-39) vs. Median rooms\n")
cat("  Correlation coefficient:", round(cor_test2$estimate, 3), "\n")
cat("  P-value:", format.pval(cor_test2$p.value), "\n")

# Test 3: Correlation with small units
cor_test3 <- cor.test(bachelor_analysis$target_sex_ratio, 
                      bachelor_analysis$small_units_pct)

cat("\nCorrelation: Sex ratio (25-39) vs. Small units (0-2 bedrooms)\n")
cat("  Correlation coefficient:", round(cor_test3$estimate, 3), "\n")
cat("  P-value:", format.pval(cor_test3$p.value), "\n")

# Test 4: Compare extreme categories
extreme_comparison <- bachelor_analysis %>%
  filter(sex_ratio_category %in% c("Male-Skewed (120+)", "Female-Skewed (<85)")) %>%
  group_by(sex_ratio_category) %>%
  summarise(
    n_pumas = n(),
    mean_renter_pct = round(mean(renter_pct, na.rm = TRUE), 1),
    mean_median_rooms = round(mean(median_rooms, na.rm = TRUE), 1),
    mean_small_units_pct = round(mean(small_units_pct, na.rm = TRUE), 1),
    mean_income = round(mean(median_income, na.rm = TRUE), 0),
    .groups = "drop"
  )

cat("\nComparison of extreme sex ratio categories:\n")
print(extreme_comparison)

# T-tests for extreme categories
male_skewed <- bachelor_analysis %>% 
  filter(sex_ratio_category == "Male-Skewed (120+)")
female_skewed <- bachelor_analysis %>% 
  filter(sex_ratio_category == "Female-Skewed (<85)")

if (nrow(male_skewed) >= 5 && nrow(female_skewed) >= 5) {
  
  # T-test for rental rate
  t_test_rent <- t.test(male_skewed$renter_pct, female_skewed$renter_pct)
  cat("\nT-test: Rental rate (Male-skewed vs Female-skewed)\n")
  cat("  Male-skewed mean:", round(mean(male_skewed$renter_pct), 1), "%\n")
  cat("  Female-skewed mean:", round(mean(female_skewed$renter_pct), 1), "%\n")
  cat("  P-value:", format.pval(t_test_rent$p.value), "\n")
  
  # T-test for room size
  t_test_rooms <- t.test(male_skewed$median_rooms, female_skewed$median_rooms)
  cat("\nT-test: Median rooms (Male-skewed vs Female-skewed)\n")
  cat("  Male-skewed mean:", round(mean(male_skewed$median_rooms), 1), "rooms\n")
  cat("  Female-skewed mean:", round(mean(female_skewed$median_rooms), 1), "rooms\n")
  cat("  P-value:", format.pval(t_test_rooms$p.value), "\n")
}

# Step 7: Regression analysis with controls
cat("\n=== STEP 5: REGRESSION ANALYSIS ===\n")

# Regression: Rental rate on sex ratio with controls
model1 <- lm(renter_pct ~ target_sex_ratio + log(median_income) + median_age + 
             factor(state_name), data = bachelor_analysis)

cat("Regression: Rental rate ~ Sex ratio + controls\n")
model1_summary <- summary(model1)
print(model1_summary)

# Regression: Median rooms on sex ratio with controls  
model2 <- lm(median_rooms ~ target_sex_ratio + log(median_income) + median_age + 
             factor(state_name), data = bachelor_analysis)

cat("\nRegression: Median rooms ~ Sex ratio + controls\n")
model2_summary <- summary(model2)
print(model2_summary)

# Step 8: Visualizations
cat("\n=== STEP 6: CREATING VISUALIZATIONS ===\n")

# Plot 1: Sex ratio distribution
p1 <- bachelor_analysis %>%
  ggplot(aes(x = target_sex_ratio)) +
  geom_histogram(bins = 30, fill = "grey20", alpha = 0.7) +
  geom_vline(xintercept = 100, color = "red", linetype = "dashed") +
  labs(
    title = "Distribution of Sex Ratios (25-39 Age Group)",
    subtitle = "Males per 100 females • Red line = gender parity",
    x = "Sex Ratio (Males per 100 Females)",
    y = "Count of PUMAs"
  ) +
  theme_minimal()

print(p1)

# Plot 2: Sex ratio vs rental rate
p2 <- bachelor_analysis %>%
  ggplot(aes(x = target_sex_ratio, y = renter_pct)) +
  geom_point(aes(color = state_name), alpha = 0.6) +
  geom_smooth(method = "lm", color = "red") +
  geom_vline(xintercept = 100, color = "grey50", linetype = "dashed") +
  scale_color_viridis_d(name = "State") +
  labs(
    title = "Sex Ratio vs. Rental Rate",
    subtitle = "Testing if male-skewed areas have higher rental rates",
    x = "Sex Ratio (Males per 100 Females, Age 25-39)",
    y = "Rental Rate (%)"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")

print(p2)

# Plot 3: Sex ratio vs housing size
p3 <- bachelor_analysis %>%
  ggplot(aes(x = target_sex_ratio, y = median_rooms)) +
  geom_point(aes(color = state_name), alpha = 0.6) +
  geom_smooth(method = "lm", color = "red") +
  geom_vline(xintercept = 100, color = "grey50", linetype = "dashed") +
  scale_color_viridis_d(name = "State") +
  labs(
    title = "Sex Ratio vs. Housing Size",
    subtitle = "Testing if male-skewed areas have smaller housing units",
    x = "Sex Ratio (Males per 100 Females, Age 25-39)",
    y = "Median Rooms per Unit"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")

print(p3)

# Plot 4: Comparison by categories
p4 <- bachelor_analysis %>%
  ggplot(aes(x = sex_ratio_category, y = renter_pct)) +
  geom_boxplot(fill = "grey20", alpha = 0.7) +
  labs(
    title = "Rental Rates by Sex Ratio Category",
    subtitle = "Do male-skewed PUMAs have higher rental rates?",
    x = "Sex Ratio Category",
    y = "Rental Rate (%)"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

print(p4)

# Step 9: Industry analysis (if hypothesis supported)
if (cor_test1$p.value < 0.05 && cor_test1$estimate > 0) {
  cat("\n=== STEP 7: INDUSTRY ANALYSIS ===\n")
  
  # Get industry data for high sex ratio PUMAs
  cat("Investigating industries in male-skewed PUMAs...\n")
  
  # Identify most extreme male-skewed PUMAs
  extreme_male_pumas <- bachelor_analysis %>%
    filter(target_sex_ratio >= 115) %>%
    arrange(desc(target_sex_ratio)) %>%
    head(10)
  
  cat("Top 10 most male-skewed PUMAs:\n")
  print(extreme_male_pumas %>% 
    select(NAME, target_sex_ratio, renter_pct, median_rooms, median_income) %>%
    mutate(
      target_sex_ratio = round(target_sex_ratio, 1),
      renter_pct = round(renter_pct, 1),
      median_rooms = round(median_rooms, 1),
      median_income = comma(median_income)
    ))
}

# Summary results
cat("\n=== SUMMARY RESULTS ===\n")

mean_sex_ratio <- mean(bachelor_analysis$target_sex_ratio, na.rm = TRUE)
male_skewed_count <- sum(bachelor_analysis$target_sex_ratio > 110)
female_skewed_count <- sum(bachelor_analysis$target_sex_ratio < 90)

cat("Overall Statistics:\n")
cat("  Mean sex ratio (25-39):", round(mean_sex_ratio, 1), "males per 100 females\n")
cat("  Male-skewed PUMAs (>110):", male_skewed_count, "\n")
cat("  Female-skewed PUMAs (<90):", female_skewed_count, "\n")

cat("\nHypothesis Test Results:\n")

# Rental rate hypothesis
if (cor_test1$p.value < 0.05) {
  direction1 <- ifelse(cor_test1$estimate > 0, "POSITIVE", "NEGATIVE")
  cat("  Sex ratio → Rental rate: ", direction1, " correlation (r = ", 
      round(cor_test1$estimate, 3), ", p = ", format.pval(cor_test1$p.value), ")\n")
  if (cor_test1$estimate > 0) {
    cat("  ✓ HYPOTHESIS SUPPORTED: Male-skewed areas have higher rental rates\n")
  } else {
    cat("  ✗ HYPOTHESIS CONTRADICTED: Male-skewed areas have lower rental rates\n")
  }
} else {
  cat("  Sex ratio → Rental rate: No significant correlation\n")
}

# Housing size hypothesis
if (cor_test2$p.value < 0.05) {
  direction2 <- ifelse(cor_test2$estimate > 0, "POSITIVE", "NEGATIVE")
  cat("  Sex ratio → Housing size: ", direction2, " correlation (r = ", 
      round(cor_test2$estimate, 3), ", p = ", format.pval(cor_test2$p.value), ")\n")
  if (cor_test2$estimate < 0) {
    cat("  ✓ HYPOTHESIS SUPPORTED: Male-skewed areas have smaller housing units\n")
  } else {
    cat("  ✗ HYPOTHESIS CONTRADICTED: Male-skewed areas have larger housing units\n")
  }
} else {
  cat("  Sex ratio → Housing size: No significant correlation\n")
}

# Overall evaluation
if ((cor_test1$p.value < 0.05 && cor_test1$estimate > 0) || 
    (cor_test2$p.value < 0.05 && cor_test2$estimate < 0)) {
  cat("\nOVERALL: BACHELOR PAD INDEX HYPOTHESIS SUPPORTED\n")
  cat("Male-skewed areas show rental/transient housing patterns\n")
} else {
  cat("\nOVERALL: BACHELOR PAD INDEX HYPOTHESIS NOT SUPPORTED\n")
  cat("No clear evidence of sex ratio effects on housing patterns\n")
}

cat("\n=== ANALYSIS COMPLETE ===\n")