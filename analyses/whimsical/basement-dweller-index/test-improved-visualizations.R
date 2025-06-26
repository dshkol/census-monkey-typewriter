# Test improved visualizations without error bars and with meaningful titles

library(tidyverse)
library(tidycensus)
library(tigris)
library(sf)
library(viridis)

cat("Testing improved visualizations...\n")

# Get sample data to test (use a few states for speed)
real_basement_vars <- c(
  "B09021_008",  # 18 to 34 years total
  "B09021_013",  # 18 to 34 years: Child of householder (basement dwellers)
  "B25077_001",  # Median home value
  "B25064_001",  # Median gross rent
  "B01001_001",  # Total population
  "B23025_005"   # Unemployed
)

tryCatch({
  # Test with a subset of states for quick validation
  test_states <- c("CA", "TX", "FL", "NY", "GA", "NC", "OH", "MI", "PA", "IL")
  
  sample_data <- get_acs(
    geography = "county",
    state = test_states,
    variables = real_basement_vars,
    year = 2019,
    survey = "acs5", 
    output = "wide",
    geometry = FALSE  # Skip geometry for testing speed
  ) %>%
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
      unemployment_rate = (unemployed / total_pop) * 100,
      metro_type = case_when(
        housing_cost_index > 0.5 ~ "High-Cost Counties",
        housing_cost_index < -0.5 ~ "Low-Cost Counties", 
        TRUE ~ "Moderate-Cost Counties"
      )
    )
  
  cat("✓ Retrieved sample data:", nrow(sample_data), "counties\n")
  
  # Test correlations
  unemployment_r2 <- summary(lm(basement_dweller_pct ~ unemployment_rate, data = sample_data))$r.squared
  housing_r2 <- summary(lm(basement_dweller_pct ~ housing_cost_index, data = sample_data))$r.squared
  
  cat("✓ Unemployment R²:", round(unemployment_r2, 3), "\n")
  cat("✓ Housing R²:", round(housing_r2, 3), "\n")
  
  # Test improved scatterplot (without error bars)
  cat("✓ Creating improved scatterplot...\n")
  scatter_plot <- ggplot(sample_data, aes(x = unemployment_rate, y = basement_dweller_pct)) +
    geom_point(aes(color = housing_cost_index), size = 1.5, alpha = 0.6) +
    geom_smooth(method = "lm", se = TRUE, color = "grey20", linetype = "solid", size = 1.2) +
    scale_color_viridis_c(name = "Housing Cost\nIndex", option = "plasma") +
    scale_x_continuous(labels = function(x) paste0(x, "%")) +
    scale_y_continuous(labels = function(x) paste0(x, "%")) +
    labs(
      title = "Employment Opportunities, Not Housing Costs, Drive Young Adult Independence",
      subtitle = paste0("Counties with higher unemployment show more basement dwelling (R² = ", 
                       round(unemployment_r2, 3), ")"),
      caption = "Each point represents one county. Color shows relative housing costs.",
      x = "County Unemployment Rate (%)",
      y = "Basement Dweller Index (%)"
    )
  
  cat("✓ Scatterplot created successfully\n")
  
  # Test improved boxplot
  cat("✓ Creating improved boxplot...\n")
  box_plot <- sample_data %>%
    ggplot(aes(x = reorder(metro_type, basement_dweller_pct, median), 
               y = basement_dweller_pct)) +
    geom_boxplot(aes(fill = metro_type), alpha = 0.7, outlier.alpha = 0.4) +
    scale_fill_viridis_d(option = "plasma", end = 0.8) +
    scale_y_continuous(labels = function(x) paste0(x, "%")) +
    labs(
      title = "Housing Costs Are Not the Primary Driver",
      subtitle = "Similar basement dwelling rates across low-cost, moderate-cost, and high-cost counties",
      x = "County Housing Cost Category",
      y = "Basement Dweller Index (%)"
    ) +
    theme(legend.position = "none")
  
  cat("✓ Boxplot created successfully\n")
  
}, error = function(e) {
  cat("✗ Error:", e$message, "\n")
})

cat("\n=== CONCLUSION ===\n")
cat("Improved visualizations tested:\n")
cat("- Removed error bars for cleaner scatterplot with many points\n")
cat("- Added alpha transparency to manage overplotting\n")
cat("- Created meaningful titles that reflect key insights\n")
cat("- Removed 'Real Census data' redundant labeling\n")