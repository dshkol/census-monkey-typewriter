# Test national counties basement dweller data retrieval

library(tidyverse)
library(tidycensus)
library(sf)

cat("Testing NATIONAL county-level data retrieval with geometry...\n")

real_basement_vars <- c(
  "B09021_008",  # 18 to 34 years total
  "B09021_013",  # 18 to 34 years: Child of householder (basement dwellers)
  "B25077_001",  # Median home value
  "B25064_001",  # Median gross rent
  "B01001_001",  # Total population
  "B23025_005"   # Unemployed
)

cat("Starting national county data retrieval...\n")

start_time <- Sys.time()

tryCatch({
  # Get ALL U.S. counties
  real_data <- get_acs(
    geography = "county",
    variables = real_basement_vars,
    year = 2019,
    survey = "acs5", 
    output = "wide",
    geometry = TRUE
  )
  
  end_time <- Sys.time()
  cat("✓ Successfully retrieved data for", nrow(real_data), "counties\n")
  cat("✓ Time taken:", round(as.numeric(end_time - start_time), 1), "seconds\n")
  cat("✓ Geometry included:", !is.null(st_geometry(real_data)), "\n")
  
  # Clean the data
  clean_data <- real_data %>%
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
  
  cat("✓ Cleaned data:", nrow(clean_data), "counties with complete data\n")
  cat("✓ Mean basement dweller rate:", round(mean(clean_data$basement_dweller_pct, na.rm = TRUE), 1), "%\n")
  cat("✓ Range:", round(min(clean_data$basement_dweller_pct, na.rm = TRUE), 1), "% to", 
      round(max(clean_data$basement_dweller_pct, na.rm = TRUE), 1), "%\n")
  
  # Test correlations
  housing_cor <- cor(clean_data$housing_cost_index, clean_data$basement_dweller_pct, use = "complete.obs")
  unemployment_cor <- cor(clean_data$unemployment_rate, clean_data$basement_dweller_pct, use = "complete.obs")
  
  cat("✓ Housing correlation:", round(housing_cor, 3), "\n")
  cat("✓ Unemployment correlation:", round(unemployment_cor, 3), "\n")
  
  # Show top and bottom counties
  cat("\nTop 5 counties with highest basement dweller rates:\n")
  top_counties <- clean_data %>% 
    arrange(desc(basement_dweller_pct)) %>% 
    head(5) %>%
    select(NAME, basement_dweller_pct, unemployment_rate, housing_cost_index)
  print(top_counties)
  
  cat("\nTop 5 counties with lowest basement dweller rates:\n")
  bottom_counties <- clean_data %>%
    arrange(basement_dweller_pct) %>%
    head(5) %>%
    select(NAME, basement_dweller_pct, unemployment_rate, housing_cost_index)
  print(bottom_counties)
  
}, error = function(e) {
  cat("✗ Error:", e$message, "\n")
})

cat("\n=== CONCLUSION ===\n")
cat("National county-level data with geometry retrieval completed.\n")