# Test the R chunks from basement-dweller-index.Rmd

library(tidyverse)
library(tidycensus)
library(sf)
library(ggplot2)
library(scales)
library(viridis)
library(spdep)

cat("Testing R chunks from .Rmd...\n")

# Set global theme
theme_set(theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    plot.subtitle = element_text(size = 12, color = "grey40"),
    panel.grid.minor = element_blank()
  ))

# Data analysis chunk
cat("Running data analysis chunk...\n")

real_basement_vars <- c(
  "B09021_008",  # 18 to 34 years total
  "B09021_013",  # 18 to 34 years: Child of householder (basement dwellers)
  "B25077_001",  # Median home value
  "B25064_001",  # Median gross rent
  "B01001_001",  # Total population
  "B23025_005"   # Unemployed
)

# Retrieve REAL data from Census API with geometry
real_data <- get_acs(
  geography = "county",
  state = "CA",  # Start with California for testing
  variables = real_basement_vars,
  year = 2019,
  survey = "acs5", 
  output = "wide",
  geometry = TRUE
)

cat("✓ Retrieved", nrow(real_data), "counties\n")

# Clean and calculate REAL basement dweller statistics
sample_data <- real_data %>%
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
    # REAL basement dweller index from Census data
    basement_dweller_pct = (basement_dwellers / young_adults_total) * 100,
    basement_dweller_moe = (basement_dwellers_moe / young_adults_total) * 100,
    
    # Housing cost index  
    housing_cost_index = scale(log(median_home_value + 1) + log(median_rent + 1))[,1],
    
    # Unemployment rate
    unemployment_rate = (unemployed / total_pop) * 100,
    
    # Categorize counties by housing cost
    metro_type = case_when(
      housing_cost_index > 0.5 ~ "High-Cost Counties",
      housing_cost_index < -0.5 ~ "Low-Cost Counties", 
      TRUE ~ "Moderate-Cost Counties"
    )
  )

cat("✓ Cleaned data:", nrow(sample_data), "counties\n")

# Data already has geometry from get_acs() call
sample_spatial <- sample_data %>%
  filter(!is.na(basement_dweller_pct))

# Statistical models using REAL data
model_housing <- lm(basement_dweller_pct ~ housing_cost_index, data = sample_data)
model_unemployment <- lm(basement_dweller_pct ~ unemployment_rate, data = sample_data)
model_combined <- lm(basement_dweller_pct ~ housing_cost_index + unemployment_rate, data = sample_data)

# Extract key statistics from REAL data
housing_r2 <- summary(model_housing)$r.squared
unemployment_r2 <- summary(model_unemployment)$r.squared
combined_r2 <- summary(model_combined)$r.squared

cat("✓ Housing R²:", round(housing_r2, 3), "\n")
cat("✓ Unemployment R²:", round(unemployment_r2, 3), "\n")
cat("✓ Combined R²:", round(combined_r2, 3), "\n")

# Calculate REAL correlations
housing_correlation <- cor(sample_data$housing_cost_index, sample_data$basement_dweller_pct, use = "complete.obs")
unemployment_correlation <- cor(sample_data$unemployment_rate, sample_data$basement_dweller_pct, use = "complete.obs")

cat("✓ Housing correlation:", round(housing_correlation, 3), "\n")
cat("✓ Unemployment correlation:", round(unemployment_correlation, 3), "\n")

# Test inline calculations that would be in the Executive Summary
cat("\n=== Executive Summary Values ===\n")
cat("Mean basement dweller rate:", round(mean(sample_data$basement_dweller_pct, na.rm = TRUE), 1), "%\n")
cat("Unemployment explains", round(unemployment_r2 * 100, 1), "% of variation\n")
cat("Housing costs explain", round(housing_r2 * 100, 1), "% of variation\n")

cat("\n✓ All R chunks work correctly!\n")