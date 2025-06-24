# Solo Boomers: The Rise of Single-Person 65+ Households and Housing Stock Mismatch
#
# Hypothesis: Single-person households aged 65+ are growing rapidly, creating 
# mismatch with housing stock dominated by large homes.

library(tidyverse)
library(tidycensus)
library(scales)
library(ggplot2)

# Set API key
census_api_key(Sys.getenv("CENSUS_API_KEY"))

cat("=== SOLO BOOMERS ANALYSIS ===\n")
cat("Testing single-person 65+ household growth and housing stock mismatch\n\n")

# Step 1: Get household data - focusing on one state to avoid rate limits
cat("=== STEP 1: HOUSEHOLD DATA ANALYSIS ===\n")

# Get 2020 ACS data 
cat("Fetching 2020 single-person household data for California...\n")
acs_2020 <- get_acs(
  geography = "county",  # Use county level for broader view
  state = "CA",
  variables = c(
    "B11007_001",  # Total households
    "B11007_002",  # Householder living alone
    "B11007_008",  # Householder living alone: Male: 65 years and over
    "B11007_017"   # Householder living alone: Female: 65 years and over
  ),
  year = 2020,
  output = "wide",
  survey = "acs5"
) %>%
  mutate(
    total_households = B11007_001E,
    solo_households = B11007_002E,
    solo_65plus = B11007_008E + B11007_017E,
    solo_65plus_pct = ifelse(total_households > 0, solo_65plus / total_households * 100, NA)
  ) %>%
  select(GEOID, NAME, total_households, solo_households, solo_65plus, solo_65plus_pct)

# Get 2010 ACS data
cat("Fetching 2010 data for comparison...\n")
acs_2010 <- get_acs(
  geography = "county",
  state = "CA",
  variables = c(
    "B11007_001",  # Total households
    "B11007_008",  # Householder living alone: Male: 65 years and over
    "B11007_017"   # Householder living alone: Female: 65 years and over
  ),
  year = 2010,
  output = "wide",
  survey = "acs5"
) %>%
  mutate(
    total_households_2010 = B11007_001E,
    solo_65plus_2010 = B11007_008E + B11007_017E,
    solo_65plus_pct_2010 = ifelse(total_households_2010 > 0, 
                                   solo_65plus_2010 / total_households_2010 * 100, NA)
  ) %>%
  select(GEOID, total_households_2010, solo_65plus_2010, solo_65plus_pct_2010)

# Calculate changes
household_changes <- acs_2020 %>%
  inner_join(acs_2010, by = "GEOID") %>%
  mutate(
    # Calculate changes
    solo_65plus_change = solo_65plus - solo_65plus_2010,
    solo_65plus_pct_change = solo_65plus_pct - solo_65plus_pct_2010,
    solo_65plus_growth_rate = ifelse(solo_65plus_2010 > 0, 
                                     (solo_65plus - solo_65plus_2010) / solo_65plus_2010 * 100, 
                                     NA),
    
    # Classify growth
    growth_category = case_when(
      solo_65plus_pct_change >= 3 ~ "High Growth (3%+)",
      solo_65plus_pct_change >= 1.5 ~ "Moderate Growth (1.5-3%)",
      solo_65plus_pct_change >= 0 ~ "Low Growth (0-1.5%)",
      TRUE ~ "Decline"
    )
  ) %>%
  filter(!is.na(solo_65plus_change))

cat("Counties analyzed:", nrow(household_changes), "\n")
cat("Total solo 65+ households 2020:", sum(household_changes$solo_65plus), "\n")
cat("Total solo 65+ households 2010:", sum(household_changes$solo_65plus_2010), "\n")
cat("Overall growth:", round((sum(household_changes$solo_65plus) / sum(household_changes$solo_65plus_2010) - 1) * 100, 1), "%\n")
cat("Mean percentage point change:", round(mean(household_changes$solo_65plus_pct_change, na.rm = TRUE), 2), "pp\n")

# Step 2: Get housing stock data
cat("\n=== STEP 2: HOUSING STOCK ANALYSIS ===\n")

# Get current housing characteristics
cat("Fetching housing stock characteristics...\n")
housing_stock <- get_acs(
  geography = "county",
  state = "CA",
  variables = c(
    "B25041_001",  # Total housing units
    "B25041_002",  # No bedroom
    "B25041_003",  # 1 bedroom
    "B25041_004",  # 2 bedrooms
    "B25041_005",  # 3 bedrooms
    "B25041_006",  # 4 bedrooms
    "B25041_007"   # 5 or more bedrooms
  ),
  year = 2020,
  output = "wide",
  survey = "acs5"
) %>%
  mutate(
    total_units = B25041_001E,
    small_units = B25041_002E + B25041_003E + B25041_004E,  # 0-2 bedrooms
    large_units = B25041_005E + B25041_006E + B25041_007E,  # 3+ bedrooms
    small_units_pct = ifelse(total_units > 0, small_units / total_units * 100, NA),
    large_units_pct = ifelse(total_units > 0, large_units / total_units * 100, NA)
  ) %>%
  select(GEOID, total_units, small_units, large_units, small_units_pct, large_units_pct)

# Get additional housing type data
housing_type <- get_acs(
  geography = "county",
  state = "CA",
  variables = c(
    "B25024_001",  # Total units
    "B25024_002",  # 1-unit detached
    "B25024_003"   # 1-unit attached
  ),
  year = 2020,
  output = "wide",
  survey = "acs5"
) %>%
  mutate(
    single_family = B25024_002E + B25024_003E,
    single_family_pct = ifelse(B25024_001E > 0, single_family / B25024_001E * 100, NA)
  ) %>%
  select(GEOID, single_family_pct)

# Combine housing data
housing_complete <- housing_stock %>%
  left_join(housing_type, by = "GEOID")

# Step 3: Create mismatch analysis
cat("\n=== STEP 3: HOUSING MISMATCH ANALYSIS ===\n")

# Combine household changes with housing stock
mismatch_analysis <- household_changes %>%
  inner_join(housing_complete, by = "GEOID") %>%
  mutate(
    # Create mismatch index
    mismatch_index = solo_65plus_pct_change * large_units_pct / 100,
    
    # Alternative mismatch: solo 65+ share vs small unit share
    supply_demand_gap = solo_65plus_pct - small_units_pct,
    
    # Categorize mismatch
    mismatch_category = case_when(
      mismatch_index >= 2 ~ "Severe Mismatch",
      mismatch_index >= 1 ~ "Moderate Mismatch",
      mismatch_index >= 0.5 ~ "Mild Mismatch",
      TRUE ~ "No Mismatch"
    )
  ) %>%
  filter(!is.na(mismatch_index))

cat("Counties with complete data:", nrow(mismatch_analysis), "\n")
cat("Counties with severe mismatch:", sum(mismatch_analysis$mismatch_category == "Severe Mismatch"), "\n")
cat("Mean mismatch index:", round(mean(mismatch_analysis$mismatch_index, na.rm = TRUE), 2), "\n")

# Display top mismatch counties
cat("\nTop 10 counties with highest housing mismatch:\n")
top_mismatch <- mismatch_analysis %>%
  arrange(desc(mismatch_index)) %>%
  head(10) %>%
  select(NAME, solo_65plus_pct, solo_65plus_pct_change, large_units_pct, mismatch_index) %>%
  mutate(
    solo_65plus_pct = round(solo_65plus_pct, 1),
    solo_65plus_pct_change = round(solo_65plus_pct_change, 1),
    large_units_pct = round(large_units_pct, 1),
    mismatch_index = round(mismatch_index, 2)
  )

print(top_mismatch)

# Step 4: Statistical tests
cat("\n=== STEP 4: STATISTICAL ANALYSIS ===\n")

# Test correlation between solo 65+ share and housing size
cor_test1 <- cor.test(mismatch_analysis$solo_65plus_pct, 
                      mismatch_analysis$large_units_pct)

cat("Correlation between solo 65+ share and large housing stock:\n")
cat("  Correlation coefficient:", round(cor_test1$estimate, 3), "\n")
cat("  P-value:", format.pval(cor_test1$p.value), "\n")

# Test if high-growth counties have different housing stock
growth_housing_comparison <- mismatch_analysis %>%
  mutate(high_growth = growth_category == "High Growth (3%+)") %>%
  group_by(high_growth) %>%
  summarise(
    n_counties = n(),
    mean_large_units_pct = mean(large_units_pct, na.rm = TRUE),
    mean_single_family_pct = mean(single_family_pct, na.rm = TRUE),
    mean_solo_65plus_pct = mean(solo_65plus_pct, na.rm = TRUE),
    .groups = "drop"
  )

cat("\nHousing characteristics by growth status:\n")
print(growth_housing_comparison)

# T-test for difference in large unit percentage
high_growth_counties <- mismatch_analysis %>% 
  filter(growth_category == "High Growth (3%+)")
other_counties <- mismatch_analysis %>% 
  filter(growth_category != "High Growth (3%+)")

if (nrow(high_growth_counties) >= 5 && nrow(other_counties) >= 5) {
  t_test <- t.test(high_growth_counties$large_units_pct, 
                   other_counties$large_units_pct)
  
  cat("\nT-test: Large unit % in high vs other growth counties:\n")
  cat("  High growth mean:", round(mean(high_growth_counties$large_units_pct), 1), "%\n")
  cat("  Other counties mean:", round(mean(other_counties$large_units_pct), 1), "%\n")
  cat("  P-value:", format.pval(t_test$p.value), "\n")
}

# Step 5: Visualizations
cat("\n=== STEP 5: CREATING VISUALIZATIONS ===\n")

# Plot 1: Solo 65+ household changes
p1 <- mismatch_analysis %>%
  ggplot(aes(x = solo_65plus_pct_change)) +
  geom_histogram(bins = 20, fill = "grey20", alpha = 0.7) +
  geom_vline(xintercept = 0, color = "red", linetype = "dashed") +
  geom_vline(xintercept = mean(mismatch_analysis$solo_65plus_pct_change), 
             color = "blue", linetype = "dashed") +
  labs(
    title = "Distribution of Solo 65+ Household Changes (2010-2020)",
    subtitle = "California counties • Red = no change, Blue = mean change",
    x = "Percentage Point Change in Solo 65+ Households",
    y = "Count of Counties"
  ) +
  theme_minimal()

print(p1)

# Plot 2: Mismatch visualization
p2 <- mismatch_analysis %>%
  ggplot(aes(x = solo_65plus_pct, y = large_units_pct)) +
  geom_point(aes(size = total_households, color = growth_category), alpha = 0.7) +
  geom_smooth(method = "lm", color = "red", se = FALSE) +
  scale_size_continuous(labels = comma_format(), name = "Total Households") +
  scale_color_viridis_d(name = "Growth Category") +
  labs(
    title = "Solo Boomer Prevalence vs. Large Housing Stock",
    subtitle = "Each point is a California county • Size = total households",
    x = "Solo 65+ Households (% of all households)",
    y = "Large Homes (3+ bedrooms, % of housing stock)"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")

print(p2)

# Plot 3: Supply-demand gap
p3 <- mismatch_analysis %>%
  mutate(county_short = str_remove(NAME, " County, California")) %>%
  arrange(desc(supply_demand_gap)) %>%
  head(15) %>%
  ggplot(aes(x = reorder(county_short, supply_demand_gap), y = supply_demand_gap)) +
  geom_col(fill = "grey20", alpha = 0.7) +
  coord_flip() +
  labs(
    title = "Housing Supply-Demand Gap for Solo Seniors",
    subtitle = "Gap = Solo 65+ household % - Small unit % (positive = undersupply of small units)",
    x = "County",
    y = "Supply-Demand Gap (percentage points)"
  ) +
  theme_minimal()

print(p3)

# Plot 4: Growth patterns
p4 <- mismatch_analysis %>%
  ggplot(aes(x = growth_category, y = large_units_pct)) +
  geom_boxplot(fill = "grey20", alpha = 0.7) +
  labs(
    title = "Housing Stock Characteristics by Solo 65+ Growth Category",
    subtitle = "Do high-growth counties have more large homes?",
    x = "Solo 65+ Household Growth Category",
    y = "Large Homes (3+ bedrooms, %)"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

print(p4)

# Summary results
cat("\n=== SUMMARY RESULTS ===\n")

# Overall statistics
total_solo_65plus_2020 <- sum(mismatch_analysis$solo_65plus)
total_solo_65plus_2010 <- sum(mismatch_analysis$solo_65plus_2010)
overall_growth_rate <- (total_solo_65plus_2020 / total_solo_65plus_2010 - 1) * 100

cat("California Solo 65+ Household Statistics:\n")
cat("  2010: ", comma(total_solo_65plus_2010), " households\n")
cat("  2020: ", comma(total_solo_65plus_2020), " households\n")
cat("  Growth: ", comma(total_solo_65plus_2020 - total_solo_65plus_2010), 
    " (", round(overall_growth_rate, 1), "%)\n")

# Key findings
mean_large_units <- mean(mismatch_analysis$large_units_pct, na.rm = TRUE)
mean_supply_gap <- mean(mismatch_analysis$supply_demand_gap, na.rm = TRUE)

cat("\nKey Findings:\n")
cat("  Mean % of housing stock with 3+ bedrooms:", round(mean_large_units, 1), "%\n")
cat("  Mean supply-demand gap:", round(mean_supply_gap, 1), "pp\n")
cat("  Counties with severe mismatch:", 
    sum(mismatch_analysis$mismatch_category == "Severe Mismatch"), 
    "(", round(mean(mismatch_analysis$mismatch_category == "Severe Mismatch") * 100, 1), "%)\n")

if (cor_test1$p.value < 0.05) {
  cat("\nHYPOTHESIS EVALUATION:\n")
  cat("- Solo 65+ households grew significantly (", round(overall_growth_rate, 1), "%)\n")
  cat("- Correlation with large housing stock: ", 
      ifelse(cor_test1$estimate < 0, "NEGATIVE", "POSITIVE"), 
      " (r = ", round(cor_test1$estimate, 3), ", p < 0.05)\n")
  if (cor_test1$estimate < 0) {
    cat("- This suggests solo seniors may already be in areas with smaller units\n")
  } else {
    cat("- This confirms mismatch: solo seniors are in areas with larger homes\n")
  }
} else {
  cat("\nHYPOTHESIS PARTIALLY SUPPORTED:\n")
  cat("- Solo 65+ households grew significantly\n")
  cat("- No clear correlation with housing stock size\n")
}

cat("\n=== ANALYSIS COMPLETE ===\n")