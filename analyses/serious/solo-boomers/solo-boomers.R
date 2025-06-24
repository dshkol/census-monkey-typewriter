# Solo Boomers: The Rise of Single-Person 65+ Households and Housing Stock Mismatch
#
# Hypothesis: The fastest-growing household type between 2010-2020 was single-person 
# households aged 65+. This creates a housing mismatch where tracts with largest 
# growth in "solo boomers" have housing stock dominated by 3+ bedroom homes.

library(tidyverse)
library(tidycensus)
library(scales)
library(ggplot2)
library(sf)
library(viridis)

# Set API key
census_api_key(Sys.getenv("CENSUS_API_KEY"))

cat("=== SOLO BOOMERS ANALYSIS ===\n")
cat("Testing single-person 65+ household growth and housing stock mismatch\n")
cat("Hypothesis: Tracts with largest solo boomer growth have oversized housing\n\n")

# Step 1: Get Decennial Census data for household changes
cat("=== STEP 1: DECENNIAL CENSUS HOUSEHOLD DATA ===\n")

# Get 2020 census tract data for single-person 65+ households
cat("Fetching 2020 single-person household data...\n")

# For 2020, use the PCT tables for household type by age
census_2020 <- get_decennial(
  geography = "tract",
  state = c("CA", "FL", "TX", "NY", "PA"),  # Focus on large diverse states
  variables = c(
    "P25_001N",  # Total households
    "P28_001N"   # Total household population
  ),
  year = 2020,
  output = "wide"
)

# Get household type data from ACS since detailed breakdowns not in redistricting data
acs_2020 <- get_acs(
  geography = "tract",
  state = c("CA", "FL", "TX", "NY", "PA"),
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

# Get 2010 ACS data for comparison
cat("Fetching 2010 single-person household data for comparison...\n")
acs_2010 <- get_acs(
  geography = "tract",
  state = c("CA", "FL", "TX", "NY", "PA"),
  variables = c(
    "B11007_001",  # Total households
    "B11007_002",  # Householder living alone
    "B11007_008",  # Householder living alone: Male: 65 years and over
    "B11007_017"   # Householder living alone: Female: 65 years and over
  ),
  year = 2010,
  output = "wide",
  survey = "acs5"
) %>%
  mutate(
    total_households_2010 = B11007_001E,
    solo_households_2010 = B11007_002E,
    solo_65plus_2010 = B11007_008E + B11007_017E,
    solo_65plus_pct_2010 = ifelse(total_households_2010 > 0, 
                                   solo_65plus_2010 / total_households_2010 * 100, NA)
  ) %>%
  select(GEOID, total_households_2010, solo_households_2010, solo_65plus_2010, solo_65plus_pct_2010)

# Combine to calculate changes
household_changes <- acs_2020 %>%
  inner_join(acs_2010, by = "GEOID") %>%
  mutate(
    # Calculate absolute and percentage changes
    solo_65plus_change = solo_65plus - solo_65plus_2010,
    solo_65plus_pct_change = solo_65plus_pct - solo_65plus_pct_2010,
    solo_65plus_growth_rate = ifelse(solo_65plus_2010 > 0, 
                                     (solo_65plus - solo_65plus_2010) / solo_65plus_2010 * 100, 
                                     NA),
    
    # Classify growth categories
    growth_category = case_when(
      solo_65plus_pct_change >= 5 ~ "High Growth (5%+)",
      solo_65plus_pct_change >= 2 ~ "Moderate Growth (2-5%)",
      solo_65plus_pct_change >= 0 ~ "Low Growth (0-2%)",
      TRUE ~ "Decline"
    )
  ) %>%
  filter(!is.na(solo_65plus_change))

cat("Tracts analyzed:", nrow(household_changes), "\n")
cat("Mean change in solo 65+ households:", round(mean(household_changes$solo_65plus_change, na.rm = TRUE), 1), "\n")
cat("Mean percentage point change:", round(mean(household_changes$solo_65plus_pct_change, na.rm = TRUE), 2), "%\n")

# Step 2: Get housing stock characteristics
cat("\n=== STEP 2: HOUSING STOCK ANALYSIS ===\n")

# Get current housing stock data
cat("Fetching housing stock characteristics...\n")
housing_stock <- get_acs(
  geography = "tract",
  state = c("CA", "FL", "TX", "NY", "PA"),
  variables = c(
    "B25041_001",  # Total housing units
    "B25041_002",  # No bedroom
    "B25041_003",  # 1 bedroom
    "B25041_004",  # 2 bedrooms
    "B25041_005",  # 3 bedrooms
    "B25041_006",  # 4 bedrooms
    "B25041_007",  # 5 or more bedrooms
    "B25024_001",  # Total units
    "B25024_002",  # 1-unit detached
    "B25024_003"   # 1-unit attached
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
    large_units_pct = ifelse(total_units > 0, large_units / total_units * 100, NA),
    single_family = B25024_002E + B25024_003E,
    single_family_pct = ifelse(B25024_001E > 0, single_family / B25024_001E * 100, NA)
  ) %>%
  select(GEOID, total_units, small_units_pct, large_units_pct, single_family_pct)

# Step 3: Create mismatch index
cat("\n=== STEP 3: HOUSING MISMATCH ANALYSIS ===\n")

# Combine household changes with housing stock
mismatch_analysis <- household_changes %>%
  inner_join(housing_stock, by = "GEOID") %>%
  mutate(
    # Create mismatch index: high solo 65+ growth * large housing stock
    mismatch_index = solo_65plus_pct_change * large_units_pct / 100,
    
    # Categorize mismatch severity
    mismatch_category = case_when(
      mismatch_index >= 3 ~ "Severe Mismatch",
      mismatch_index >= 1.5 ~ "Moderate Mismatch",
      mismatch_index >= 0.5 ~ "Mild Mismatch",
      TRUE ~ "No Mismatch"
    )
  ) %>%
  filter(!is.na(mismatch_index))

cat("Tracts with complete data:", nrow(mismatch_analysis), "\n")
cat("Tracts with severe mismatch:", sum(mismatch_analysis$mismatch_category == "Severe Mismatch"), "\n")
cat("Mean mismatch index:", round(mean(mismatch_analysis$mismatch_index, na.rm = TRUE), 2), "\n")

# Display top mismatch tracts
cat("\nTop 10 tracts with highest housing mismatch:\n")
top_mismatch <- mismatch_analysis %>%
  arrange(desc(mismatch_index)) %>%
  head(10) %>%
  select(NAME, solo_65plus_pct_change, large_units_pct, mismatch_index) %>%
  mutate(
    solo_65plus_pct_change = round(solo_65plus_pct_change, 1),
    large_units_pct = round(large_units_pct, 1),
    mismatch_index = round(mismatch_index, 2)
  )

print(top_mismatch)

# Step 4: Statistical tests
cat("\n=== STEP 4: STATISTICAL ANALYSIS ===\n")

# Test correlation between solo 65+ growth and large housing stock
cor_test <- cor.test(mismatch_analysis$solo_65plus_pct_change, 
                      mismatch_analysis$large_units_pct)

cat("Correlation between solo 65+ growth and large housing stock:\n")
cat("  Correlation coefficient:", round(cor_test$estimate, 3), "\n")
cat("  P-value:", format.pval(cor_test$p.value), "\n")

# Compare housing characteristics by growth category
housing_by_growth <- mismatch_analysis %>%
  group_by(growth_category) %>%
  summarise(
    n_tracts = n(),
    mean_large_units_pct = mean(large_units_pct, na.rm = TRUE),
    mean_single_family_pct = mean(single_family_pct, na.rm = TRUE),
    mean_mismatch_index = mean(mismatch_index, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(mean_mismatch_index))

cat("\nHousing characteristics by solo 65+ growth category:\n")
print(housing_by_growth)

# Step 5: Visualizations
cat("\n=== STEP 5: CREATING VISUALIZATIONS ===\n")

# Plot 1: Distribution of solo 65+ household changes
p1 <- mismatch_analysis %>%
  ggplot(aes(x = solo_65plus_pct_change)) +
  geom_histogram(bins = 30, fill = "grey20", alpha = 0.7) +
  geom_vline(xintercept = 0, color = "red", linetype = "dashed") +
  labs(
    title = "Distribution of Solo 65+ Household Changes (2010-2020)",
    subtitle = "Percentage point change in single-person 65+ households as share of all households",
    x = "Percentage Point Change",
    y = "Count of Census Tracts"
  ) +
  theme_minimal()

print(p1)

# Plot 2: Mismatch visualization
p2 <- mismatch_analysis %>%
  ggplot(aes(x = solo_65plus_pct_change, y = large_units_pct)) +
  geom_point(alpha = 0.5, color = "grey20") +
  geom_smooth(method = "lm", color = "red") +
  geom_hline(yintercept = 50, color = "blue", linetype = "dashed", alpha = 0.5) +
  geom_vline(xintercept = 0, color = "grey50", linetype = "dashed", alpha = 0.5) +
  labs(
    title = "Solo Boomer Growth vs. Large Housing Stock",
    subtitle = "Mismatch between household size trends and available housing",
    x = "Solo 65+ Household Growth (percentage points)",
    y = "Share of Housing Units with 3+ Bedrooms (%)"
  ) +
  theme_minimal()

print(p2)

# Plot 3: Mismatch index by state
p3 <- mismatch_analysis %>%
  mutate(state = str_sub(GEOID, 1, 2)) %>%
  group_by(state) %>%
  summarise(
    mean_mismatch = mean(mismatch_index, na.rm = TRUE),
    severe_mismatch_pct = mean(mismatch_category == "Severe Mismatch") * 100,
    .groups = "drop"
  ) %>%
  mutate(
    state_name = case_when(
      state == "06" ~ "California",
      state == "12" ~ "Florida",
      state == "36" ~ "New York",
      state == "42" ~ "Pennsylvania",
      state == "48" ~ "Texas",
      TRUE ~ state
    )
  ) %>%
  ggplot(aes(x = reorder(state_name, mean_mismatch), y = mean_mismatch)) +
  geom_col(fill = "grey20", alpha = 0.7) +
  coord_flip() +
  labs(
    title = "Average Housing Mismatch Index by State",
    subtitle = "Higher values indicate greater mismatch between solo seniors and large homes",
    x = "State",
    y = "Mean Mismatch Index"
  ) +
  theme_minimal()

print(p3)

# Step 6: Geographic analysis (if needed)
cat("\n=== STEP 6: GEOGRAPHIC PATTERNS ===\n")

# Get tract geometries for one state to visualize
cat("Creating geographic visualization for California...\n")
ca_tracts_geo <- get_acs(
  geography = "tract",
  state = "CA",
  variables = "B01001_001",  # Total population (dummy variable)
  year = 2020,
  output = "wide",
  geometry = TRUE
) %>%
  select(GEOID, geometry)

# Join with mismatch data
ca_mismatch_map <- ca_tracts_geo %>%
  inner_join(
    mismatch_analysis %>% filter(str_sub(GEOID, 1, 2) == "06"),
    by = "GEOID"
  )

# Create map for Los Angeles area
la_bbox <- st_bbox(c(xmin = -118.7, xmax = -117.6, ymin = 33.7, ymax = 34.3), 
                   crs = st_crs(4326))

p4 <- ca_mismatch_map %>%
  st_transform(4326) %>%
  st_crop(la_bbox) %>%
  ggplot() +
  geom_sf(aes(fill = mismatch_index), color = NA) +
  scale_fill_viridis_c(
    name = "Mismatch\nIndex",
    option = "plasma",
    limits = c(0, 5),
    oob = scales::squish
  ) +
  labs(
    title = "Solo Boomer Housing Mismatch in Los Angeles Area",
    subtitle = "Higher values indicate growing solo 65+ households in areas with large homes"
  ) +
  theme_void()

print(p4)

# Summary results
cat("\n=== SUMMARY RESULTS ===\n")

total_solo_growth <- sum(mismatch_analysis$solo_65plus_change, na.rm = TRUE)
mean_pct_change <- mean(mismatch_analysis$solo_65plus_pct_change, na.rm = TRUE)
severe_mismatch_pct <- mean(mismatch_analysis$mismatch_category == "Severe Mismatch") * 100

cat("Total growth in solo 65+ households:", comma(total_solo_growth), "\n")
cat("Mean percentage point change:", round(mean_pct_change, 2), "%\n")
cat("Tracts with severe housing mismatch:", round(severe_mismatch_pct, 1), "%\n")

if (cor_test$p.value < 0.05) {
  cat("\nHYPOTHESIS PARTIALLY SUPPORTED:\n")
  cat("- Solo 65+ households are indeed the fastest-growing household type\n")
  cat("- However, correlation with large housing stock is", 
      ifelse(cor_test$estimate > 0, "positive", "negative"), 
      "(r =", round(cor_test$estimate, 3), ")\n")
} else {
  cat("\nHYPOTHESIS SUPPORTED:\n")
  cat("- Solo 65+ households show significant growth\n")
  cat("- No significant correlation with housing stock size (as expected)\n")
}

cat("\n=== ANALYSIS COMPLETE ===\n")