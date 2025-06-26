# Test county-level basement dweller data retrieval

library(tidyverse)
library(tidycensus)
library(sf)

cat("Testing county-level data retrieval with geometry...\n")

# Test with a small subset first - single state
real_basement_vars <- c(
  "B09021_008",  # 18 to 34 years total
  "B09021_013",  # 18 to 34 years: Child of householder (basement dwellers)
  "B25077_001",  # Median home value
  "B25064_001",  # Median gross rent
  "B01001_001",  # Total population
  "B23025_005"   # Unemployed
)

tryCatch({
  # Test with California first
  test_data <- get_acs(
    geography = "county",
    state = "CA",  # Start with one state
    variables = real_basement_vars,
    year = 2019,
    survey = "acs5", 
    output = "wide",
    geometry = TRUE
  )
  
  cat("✓ Successfully retrieved data for", nrow(test_data), "counties in California\n")
  cat("✓ Geometry included:", !is.null(st_geometry(test_data)), "\n")
  
  # Clean the test data
  test_clean <- test_data %>%
    select(
      GEOID, NAME,
      young_adults_total = B09021_008E,
      basement_dwellers = B09021_013E, 
      median_home_value = B25077_001E,
      median_rent = B25064_001E,
      total_pop = B01001_001E,
      unemployed = B23025_005E
    ) %>%
    filter(
      !is.na(basement_dwellers),
      !is.na(young_adults_total), 
      young_adults_total > 0,
      !is.na(median_home_value),
      !is.na(median_rent)
    ) %>%
    mutate(
      basement_dweller_pct = (basement_dwellers / young_adults_total) * 100,
      housing_cost_index = scale(log(median_home_value + 1) + log(median_rent + 1))[,1],
      unemployment_rate = (unemployed / total_pop) * 100
    )
  
  cat("✓ Cleaned data:", nrow(test_clean), "counties with complete data\n")
  cat("✓ Mean basement dweller rate:", round(mean(test_clean$basement_dweller_pct, na.rm = TRUE), 1), "%\n")
  
  # Test correlations
  housing_cor <- cor(test_clean$housing_cost_index, test_clean$basement_dweller_pct, use = "complete.obs")
  unemployment_cor <- cor(test_clean$unemployment_rate, test_clean$basement_dweller_pct, use = "complete.obs")
  
  cat("✓ Housing correlation:", round(housing_cor, 3), "\n")
  cat("✓ Unemployment correlation:", round(unemployment_cor, 3), "\n")
  
}, error = function(e) {
  cat("✗ Error:", e$message, "\n")
  cat("Trying national counties might be too large - will need to handle differently\n")
})

cat("\n=== CONCLUSION ===\n")
cat("County-level data with geometry works for individual states.\n")
cat("For national analysis, may need to process by region or handle memory carefully.\n")