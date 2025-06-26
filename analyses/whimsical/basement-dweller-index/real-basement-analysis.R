# Get REAL basement dweller data using proper Census variables

library(tidyverse)
library(tidycensus)
library(sf)

cat("Getting REAL basement dweller data from Census API...\n")

# The correct approach: Use B09021 table which has living arrangements by age
# Focus on "Child of householder" for 18-34 age group

real_basement_vars <- c(
  # Living arrangements
  "B09021_008",  # 18 to 34 years total
  "B09021_013",  # 18 to 34 years: Child of householder (BASEMENT DWELLERS!)
  # Housing costs
  "B25077_001",  # Median home value
  "B25064_001",  # Median gross rent
  # Demographics
  "B01001_001",  # Total population
  "B23025_005"   # Unemployed
)

cat("Using real Census variables:\n")
cat("- B09021_013: 18-34 year olds who are 'Child of householder' (basement dwellers)\n")
cat("- B09021_008: Total 18-34 year olds\n")
cat("- B25077_001: Median home value\n")
cat("- B25064_001: Median gross rent\n")

# Get real data for states (manageable scope)
tryCatch({
  
  real_data <- get_acs(
    geography = "state",
    variables = real_basement_vars,
    year = 2019,
    survey = "acs5", 
    output = "wide"
  )
  
  cat("✓ Retrieved real data for", nrow(real_data), "states\n")
  
  # Clean and calculate the real basement dweller index
  real_clean <- real_data %>%
    select(
      GEOID, NAME,
      young_adults_total = B09021_008E,
      young_adults_total_moe = B09021_008M,
      basement_dwellers = B09021_013E, 
      basement_dwellers_moe = B09021_013M,
      median_home_value = B25077_001E,
      home_value_moe = B25077_001M,
      median_rent = B25064_001E,
      rent_moe = B25064_001M,
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
      # REAL basement dweller index
      basement_dweller_pct = (basement_dwellers / young_adults_total) * 100,
      basement_dweller_moe_pct = (basement_dwellers_moe / young_adults_total) * 100,
      
      # Housing cost index  
      housing_cost_index = scale(log(median_home_value + 1) + log(median_rent + 1))[,1],
      
      # Unemployment rate
      unemployment_rate = (unemployed / total_pop) * 100
    )
  
  cat("✓ Real basement dweller analysis complete\n")
  cat("States with complete data:", nrow(real_clean), "\n")
  
  # Show REAL statistics
  cat("\n=== REAL BASEMENT DWELLER STATISTICS ===\n")
  cat("Mean basement dweller rate:", round(mean(real_clean$basement_dweller_pct, na.rm = TRUE), 1), "%\n")
  cat("Range:", round(min(real_clean$basement_dweller_pct, na.rm = TRUE), 1), "% to", 
      round(max(real_clean$basement_dweller_pct, na.rm = TRUE), 1), "%\n")
  
  # REAL correlation analysis
  housing_correlation <- cor(real_clean$housing_cost_index, real_clean$basement_dweller_pct, use = "complete.obs")
  unemployment_correlation <- cor(real_clean$unemployment_rate, real_clean$basement_dweller_pct, use = "complete.obs")
  
  cat("REAL correlation with housing costs:", round(housing_correlation, 3), "\n")
  cat("REAL correlation with unemployment:", round(unemployment_correlation, 3), "\n")
  
  # REAL regression models
  housing_model <- lm(basement_dweller_pct ~ housing_cost_index, data = real_clean)
  unemployment_model <- lm(basement_dweller_pct ~ unemployment_rate, data = real_clean)
  combined_model <- lm(basement_dweller_pct ~ housing_cost_index + unemployment_rate, data = real_clean)
  
  cat("REAL R² for housing model:", round(summary(housing_model)$r.squared, 3), "\n")
  cat("REAL R² for unemployment model:", round(summary(unemployment_model)$r.squared, 3), "\n")
  cat("REAL R² for combined model:", round(summary(combined_model)$r.squared, 3), "\n")
  
  # Save REAL data
  saveRDS(real_clean, "real_basement_analysis.rds")
  cat("\n✓ REAL data saved to real_basement_analysis.rds\n")
  
  # Show top and bottom states
  cat("\nHighest basement dweller rates (REAL DATA):\n")
  top_states <- real_clean %>% 
    arrange(desc(basement_dweller_pct)) %>% 
    head(5) %>%
    select(NAME, basement_dweller_pct, median_home_value, median_rent)
  print(top_states)
  
  cat("\nLowest basement dweller rates (REAL DATA):\n") 
  bottom_states <- real_clean %>%
    arrange(basement_dweller_pct) %>%
    head(5) %>%
    select(NAME, basement_dweller_pct, median_home_value, median_rent)
  print(bottom_states)
  
}, error = function(e) {
  cat("✗ Error getting real basement dweller data:", e$message, "\n")
  stop("Cannot proceed without real data")
})

cat("\n=== SUCCESS ===\n")
cat("We now have REAL Census data for basement dwellers!\n")
cat("No simulated data used. Ready to fix the .Rmd file.\n")