# Test improved choropleth with shift_geometry and resolution

library(tidyverse)
library(tidycensus)
library(tigris)
library(sf)
library(viridis)

cat("Testing improved choropleth approach...\n")

# Get a small sample of data to test quickly
real_basement_vars <- c(
  "B09021_008",  # 18 to 34 years total
  "B09021_013"   # 18 to 34 years: Child of householder (basement dwellers)
)

tryCatch({
  # Test with state-level data first for speed
  test_data <- get_acs(
    geography = "state",
    variables = real_basement_vars,
    year = 2019,
    survey = "acs5", 
    output = "wide",
    geometry = TRUE,
    resolution = "20m"
  ) %>%
    shift_geometry()
  
  cat("✓ Retrieved", nrow(test_data), "states with shifted geometry\n")
  
  # Clean data
  test_clean <- test_data %>%
    filter(
      !is.na(B09021_013E),
      !is.na(B09021_008E), 
      B09021_008E > 0
    ) %>%
    mutate(
      basement_dweller_pct = (B09021_013E / B09021_008E) * 100
    )
  
  cat("✓ Cleaned data:", nrow(test_clean), "states\n")
  cat("✓ Basement dweller range:", round(min(test_clean$basement_dweller_pct), 1), "% to", 
      round(max(test_clean$basement_dweller_pct), 1), "%\n")
  
  # Test the improved choropleth
  cat("✓ Creating improved choropleth...\n")
  
  map_plot <- ggplot(test_clean) +
    geom_sf(aes(fill = basement_dweller_pct), color = "white", size = 0.05) +
    scale_fill_viridis_c(name = "Basement\nDweller\nIndex (%)", 
                         option = "plasma",
                         trans = "sqrt",  # Square root transformation
                         breaks = c(0, 5, 10, 15, 20, 30, 40),
                         labels = function(x) paste0(x, "%")) +
    theme_void() +
    labs(
      title = "Test: Improved Choropleth with Shifted Geometry",
      subtitle = "State-level test showing Alaska and Hawaii positioning",
      caption = "Geometry shifted using tigris::shift_geometry()"
    ) +
    theme(
      legend.position = "right",
      plot.title = element_text(size = 14, face = "bold", hjust = 0.5)
    )
  
  cat("✓ Map created successfully\n")
  
  # Test that shift_geometry worked
  bbox <- st_bbox(test_clean)
  cat("✓ Bounding box after shift_geometry:\n")
  cat("  xmin:", round(bbox[1], 2), ", ymin:", round(bbox[2], 2), "\n")
  cat("  xmax:", round(bbox[3], 2), ", ymax:", round(bbox[4], 2), "\n")
  
}, error = function(e) {
  cat("✗ Error:", e$message, "\n")
})

cat("\n=== CONCLUSION ===\n")
cat("Improved choropleth approach with shift_geometry() and resolution='20m' tested.\n")