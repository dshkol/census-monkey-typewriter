# Carless Corridors: Spatial Clustering of Zero-Vehicle Households
#
# Hypothesis: Census tracts with high percentage of zero-vehicle households 
# are not randomly distributed but form contiguous linear corridors. These 
# "carless corridors" align with transit infrastructure, demonstrating how 
# transportation shapes household economic decisions.

library(tidyverse)
library(tidycensus)
library(sf)
library(scales)
library(ggplot2)
library(viridis)

# Set API key
census_api_key(Sys.getenv("CENSUS_API_KEY"))

cat("=== CARLESS CORRIDORS ANALYSIS ===\n")
cat("Testing spatial clustering of zero-vehicle households\n")
cat("Hypothesis: High zero-vehicle tracts form linear corridors\n\n")

# Step 1: Get vehicle availability data
cat("=== STEP 1: VEHICLE AVAILABILITY DATA ===\n")

# Focus on one major metro area for detailed spatial analysis
cat("Fetching vehicle data for San Francisco Bay Area...\n")
vehicle_data <- get_acs(
  geography = "tract",
  state = "CA",
  county = c("001", "013", "041", "055", "075", "081", "085", "095", "097"),  # Bay Area counties
  variables = c(
    "B25044_001",  # Total occupied housing units
    "B25044_003",  # Owner occupied: No vehicle available
    "B25044_010"   # Renter occupied: No vehicle available
  ),
  year = 2022,
  output = "wide",
  geometry = TRUE,
  survey = "acs5"
) %>%
  mutate(
    total_households = B25044_001E,
    zero_vehicle_owner = B25044_003E,
    zero_vehicle_renter = B25044_010E,
    zero_vehicle_total = zero_vehicle_owner + zero_vehicle_renter,
    zero_vehicle_pct = ifelse(total_households > 0, 
                              zero_vehicle_total / total_households * 100, NA),
    
    # Classify by zero-vehicle prevalence
    vehicle_category = case_when(
      zero_vehicle_pct >= 30 ~ "Very High (30%+)",
      zero_vehicle_pct >= 20 ~ "High (20-30%)",
      zero_vehicle_pct >= 10 ~ "Moderate (10-20%)",
      zero_vehicle_pct >= 5 ~ "Low (5-10%)",
      TRUE ~ "Very Low (<5%)"
    )
  ) %>%
  filter(!is.na(zero_vehicle_pct), total_households >= 100) %>%  # Filter small tracts
  select(GEOID, NAME, total_households, zero_vehicle_total, zero_vehicle_pct, vehicle_category)

cat("Census tracts analyzed:", nrow(vehicle_data), "\n")
cat("Mean zero-vehicle percentage:", round(mean(vehicle_data$zero_vehicle_pct, na.rm = TRUE), 1), "%\n")

# Display distribution
vehicle_summary <- vehicle_data %>%
  st_drop_geometry() %>%
  count(vehicle_category, sort = TRUE) %>%
  mutate(percentage = round(n / sum(n) * 100, 1))

cat("\nZero-vehicle distribution:\n")
print(vehicle_summary)

# Step 2: Identify high zero-vehicle clusters
cat("\n=== STEP 2: SPATIAL CLUSTERING ANALYSIS ===\n")

# Create binary indicator for high zero-vehicle areas
high_carless_threshold <- 20  # 20%+ zero-vehicle
vehicle_data <- vehicle_data %>%
  mutate(
    high_carless = zero_vehicle_pct >= high_carless_threshold,
    very_high_carless = zero_vehicle_pct >= 30
  )

high_carless_tracts <- sum(vehicle_data$high_carless, na.rm = TRUE)
very_high_carless_tracts <- sum(vehicle_data$very_high_carless, na.rm = TRUE)

cat("Tracts with ≥20% zero-vehicle households:", high_carless_tracts, "\n")
cat("Tracts with ≥30% zero-vehicle households:", very_high_carless_tracts, "\n")

# Step 3: Spatial analysis - find contiguous clusters
cat("\n=== STEP 3: CONTIGUITY ANALYSIS ===\n")

# Filter to high carless tracts only
high_carless_sf <- vehicle_data %>%
  filter(high_carless == TRUE)

cat("High carless tracts for spatial analysis:", nrow(high_carless_sf), "\n")

if (nrow(high_carless_sf) > 5) {
  
  # Create adjacency matrix to find contiguous clusters
  cat("Analyzing spatial contiguity...\n")
  
  # Calculate centroids for distance analysis
  tract_centroids <- vehicle_data %>%
    st_transform(3857) %>%  # Project to meters for distance
    mutate(
      centroid = st_centroid(geometry),
      longitude = st_coordinates(centroid)[,1],
      latitude = st_coordinates(centroid)[,2]
    ) %>%
    st_transform(4326) %>%  # Back to WGS84
    st_drop_geometry() %>%
    select(GEOID, longitude, latitude, zero_vehicle_pct, high_carless)
  
  # Step 4: Linear corridor analysis
  cat("\n=== STEP 4: CORRIDOR IDENTIFICATION ===\n")
  
  # Analyze if high-carless tracts form linear patterns
  # Method: Calculate orientation of high-carless tract clusters
  
  high_carless_centroids <- tract_centroids %>%
    filter(high_carless == TRUE)
  
  if (nrow(high_carless_centroids) >= 10) {
    
    # Principal component analysis to find main orientation
    cat("Performing orientation analysis...\n")
    
    coords_matrix <- high_carless_centroids %>%
      select(longitude, latitude) %>%
      as.matrix()
    
    # PCA to find main axis
    pca_result <- prcomp(coords_matrix, center = TRUE, scale. = TRUE)
    
    # Calculate explained variance
    pc1_variance <- summary(pca_result)$importance[2, 1] * 100
    pc2_variance <- summary(pca_result)$importance[2, 2] * 100
    
    cat("Principal component analysis results:\n")
    cat("  PC1 explains", round(pc1_variance, 1), "% of spatial variance\n")
    cat("  PC2 explains", round(pc2_variance, 1), "% of spatial variance\n")
    
    # Test for linearity: high PC1 variance suggests linear arrangement
    linearity_score <- pc1_variance
    is_linear <- linearity_score >= 60  # Arbitrary threshold
    
    cat("Linearity score:", round(linearity_score, 1), "%\n")
    cat("Linear corridor detected:", ifelse(is_linear, "YES", "NO"), "\n")
    
    # Add PCA coordinates to data
    pca_coords <- data.frame(
      GEOID = high_carless_centroids$GEOID,
      PC1 = pca_result$x[, 1],
      PC2 = pca_result$x[, 2]
    )
    
    high_carless_with_pca <- high_carless_centroids %>%
      left_join(pca_coords, by = "GEOID")
    
  } else {
    cat("Insufficient high-carless tracts for corridor analysis\n")
    is_linear <- FALSE
    linearity_score <- NA
  }
  
  # Step 5: Visual analysis preparation
  cat("\n=== STEP 5: MAPPING PREPARATION ===\n")
  
  # Create main visualization map
  cat("Preparing maps...\n")
  
  # Focus on San Francisco core for detailed view
  sf_bbox <- list(
    xmin = -122.6, xmax = -122.3,
    ymin = 37.7, ymax = 37.9
  )
  
  # Create overall Bay Area map
  p1 <- vehicle_data %>%
    ggplot() +
    geom_sf(aes(fill = zero_vehicle_pct), color = "white", size = 0.1) +
    scale_fill_viridis_c(
      name = "Zero-Vehicle\nHouseholds (%)",
      option = "plasma",
      trans = "sqrt",
      breaks = c(0, 5, 10, 20, 30, 50),
      labels = c("0", "5", "10", "20", "30", "50+")
    ) +
    labs(
      title = "Zero-Vehicle Households in San Francisco Bay Area",
      subtitle = "Higher values indicate car-free living • Look for linear patterns"
    ) +
    theme_void() +
    theme(
      plot.title = element_text(size = 14, face = "bold"),
      legend.position = "bottom"
    )
  
  print(p1)
  
  # Create San Francisco detail map
  sf_detail <- vehicle_data %>%
    st_crop(c(xmin = sf_bbox$xmin, ymin = sf_bbox$ymin, 
              xmax = sf_bbox$xmax, ymax = sf_bbox$ymax))
  
  if (nrow(sf_detail) > 0) {
    p2 <- sf_detail %>%
      ggplot() +
      geom_sf(aes(fill = zero_vehicle_pct), color = "white", size = 0.2) +
      scale_fill_viridis_c(
        name = "Zero-Vehicle\nHouseholds (%)",
        option = "plasma",
        breaks = c(0, 10, 20, 30, 40, 50),
        limits = c(0, 50),
        oob = scales::squish
      ) +
      labs(
        title = "Zero-Vehicle Households in San Francisco",
        subtitle = "Detailed view showing potential transit corridors"
      ) +
      theme_void() +
      theme(
        plot.title = element_text(size = 14, face = "bold"),
        legend.position = "bottom"
      )
    
    print(p2)
  }
  
  # Create corridor analysis visualization
  if (exists("high_carless_with_pca") && nrow(high_carless_with_pca) > 0) {
    p3 <- high_carless_with_pca %>%
      ggplot(aes(x = PC1, y = PC2)) +
      geom_point(aes(size = zero_vehicle_pct), alpha = 0.7, color = "red") +
      geom_smooth(method = "lm", se = TRUE, color = "blue") +
      scale_size_continuous(name = "Zero-Vehicle %", range = c(1, 4)) +
      labs(
        title = "Principal Component Analysis of High Carless Tracts",
        subtitle = paste0("PC1 explains ", round(pc1_variance, 1), "% of variance • ",
                         ifelse(is_linear, "Linear", "Non-linear"), " pattern detected"),
        x = "First Principal Component",
        y = "Second Principal Component"
      ) +
      theme_minimal()
    
    print(p3)
  }
  
  # Step 6: Statistical validation
  cat("\n=== STEP 6: STATISTICAL TESTS ===\n")
  
  # Test spatial autocorrelation using Moran's I
  cat("Testing spatial autocorrelation...\n")
  
  # Create neighborhood structure (simplified)
  # For full analysis, would use spdep package, but testing basic patterns
  
  # Calculate distance-based clustering metric
  if (nrow(high_carless_centroids) >= 5) {
    
    # Calculate average nearest neighbor distance
    coords <- high_carless_centroids %>%
      select(longitude, latitude) %>%
      as.matrix()
    
    # Simple distance matrix calculation
    dist_matrix <- dist(coords)
    min_distances <- apply(as.matrix(dist_matrix), 1, function(x) min(x[x > 0]))
    mean_nn_distance <- mean(min_distances)
    
    cat("Average nearest neighbor distance:", round(mean_nn_distance, 4), "degrees\n")
    
    # Compare to random expectation (very simplified)
    # In reality would use proper spatial statistics
    bbox_area <- (max(coords[,1]) - min(coords[,1])) * (max(coords[,2]) - min(coords[,2]))
    expected_nn_distance <- 0.5 * sqrt(bbox_area / nrow(coords))
    
    clustering_ratio <- expected_nn_distance / mean_nn_distance
    
    cat("Clustering ratio (>1 = clustered):", round(clustering_ratio, 2), "\n")
    
    is_clustered <- clustering_ratio > 1.2
    cat("Spatial clustering detected:", ifelse(is_clustered, "YES", "NO"), "\n")
  }
  
} else {
  cat("Insufficient high carless tracts for spatial analysis\n")
  is_linear <- FALSE
  is_clustered <- FALSE
}

# Step 7: Comparison with transit usage
cat("\n=== STEP 7: TRANSIT CORRELATION ANALYSIS ===\n")

# Get transit usage data
cat("Fetching public transit data...\n")
transit_data <- get_acs(
  geography = "tract",
  state = "CA", 
  county = c("001", "013", "041", "055", "075", "081", "085", "095", "097"),
  variables = c(
    "B08301_001",  # Total workers 16 years and over
    "B08301_010"   # Public transportation (excluding taxicab)
  ),
  year = 2022,
  output = "wide",
  survey = "acs5"
) %>%
  mutate(
    total_commuters = B08301_001E,
    transit_commuters = B08301_010E,
    transit_pct = ifelse(total_commuters > 0, transit_commuters / total_commuters * 100, NA)
  ) %>%
  select(GEOID, transit_pct)

# Join with vehicle data
vehicle_transit <- vehicle_data %>%
  st_drop_geometry() %>%
  inner_join(transit_data, by = "GEOID") %>%
  filter(!is.na(transit_pct))

# Test correlation between zero-vehicle and transit usage
if (nrow(vehicle_transit) > 50) {
  cor_test <- cor.test(vehicle_transit$zero_vehicle_pct, 
                       vehicle_transit$transit_pct)
  
  cat("Correlation: Zero-vehicle % vs. Public transit %\n")
  cat("  Correlation coefficient:", round(cor_test$estimate, 3), "\n")
  cat("  P-value:", format.pval(cor_test$p.value), "\n")
  
  # Visualization
  p4 <- vehicle_transit %>%
    ggplot(aes(x = zero_vehicle_pct, y = transit_pct)) +
    geom_point(alpha = 0.6, color = "grey20") +
    geom_smooth(method = "lm", color = "red") +
    labs(
      title = "Zero-Vehicle Households vs. Public Transit Usage",
      subtitle = "Testing if carless areas correlate with transit infrastructure",
      x = "Zero-Vehicle Households (%)",
      y = "Public Transit Commuters (%)"
    ) +
    theme_minimal()
  
  print(p4)
}

# Summary results
cat("\n=== SUMMARY RESULTS ===\n")

cat("Bay Area Zero-Vehicle Analysis:\n")
cat("  Total tracts analyzed:", nrow(vehicle_data), "\n")
cat("  High carless tracts (≥20%):", high_carless_tracts, "\n")
cat("  Very high carless tracts (≥30%):", very_high_carless_tracts, "\n")
cat("  Mean zero-vehicle percentage:", round(mean(vehicle_data$zero_vehicle_pct), 1), "%\n")

if (exists("is_linear") && !is.na(is_linear)) {
  cat("\nSpatial Pattern Analysis:\n")
  cat("  Linear corridor pattern:", ifelse(is_linear, "DETECTED", "NOT DETECTED"), "\n")
  if (exists("linearity_score")) {
    cat("  Linearity score:", round(linearity_score, 1), "%\n")
  }
}

if (exists("is_clustered")) {
  cat("  Spatial clustering:", ifelse(is_clustered, "DETECTED", "NOT DETECTED"), "\n")
}

if (exists("cor_test") && cor_test$p.value < 0.05) {
  cat("\nTransit Correlation:\n")
  cat("  Zero-vehicle areas correlate with transit usage\n")
  cat("  Correlation:", round(cor_test$estimate, 3), "(p =", format.pval(cor_test$p.value), ")\n")
}

cat("\nHYPOTHESIS EVALUATION:\n")
if (exists("is_linear") && is_linear) {
  cat("✓ HYPOTHESIS SUPPORTED: Linear corridor patterns detected\n")
  cat("Zero-vehicle tracts form distinct spatial corridors\n")
} else if (exists("is_clustered") && is_clustered) {
  cat("○ HYPOTHESIS PARTIALLY SUPPORTED: Clustering detected but not linear\n")
  cat("Zero-vehicle tracts cluster spatially but not in corridors\n")
} else {
  cat("✗ HYPOTHESIS NOT SUPPORTED: No clear corridor patterns\n")
  cat("Zero-vehicle tracts appear randomly distributed\n")
}

cat("\n=== ANALYSIS COMPLETE ===\n")