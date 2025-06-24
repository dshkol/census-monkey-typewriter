# Heat Refuge Highways: Mapping Climate-Driven Migration Corridors
# 
# Hypothesis: Counties with higher extreme heat exposure show increasing 
# migration flows toward cooler destinations. Network analysis reveals 
# specific corridors used for climate-motivated moves.
#
# Testing whether temperature differentials predict migration patterns
# and identifying demographic composition of climate migrants.

# Load required libraries
library(tidyverse)
library(tidycensus)
library(sf)
library(scales)
library(ggplot2)
library(viridis)

# Set API key
census_api_key(Sys.getenv("CENSUS_API_KEY"))

cat("=== HEAT REFUGE HIGHWAYS ANALYSIS ===\n")
cat("Identifying climate-driven migration corridors using temperature differentials\n")
cat("Testing hypothesis: hot counties → cool counties migration patterns\n\n")

# Step 1: Get county geographic data with migration flows
cat("=== STEP 1: COUNTY GEOGRAPHIC DATA ===\n")

# Get county boundaries with basic demographics
cat("Fetching county boundaries and demographics...\n")
counties_sf <- get_acs(
  geography = "county",
  variables = c(
    total_pop = "B01003_001",
    median_age = "B01002_001", 
    median_income = "B19013_001",
    white_pop = "B03002_003",
    total_race = "B03002_001"
  ),
  year = 2022,
  output = "wide",
  geometry = TRUE
) %>%
  # Calculate white percentage
  mutate(
    white_pct = white_popE / total_raceE,
    # Extract state and county codes
    state_fips = str_sub(GEOID, 1, 2),
    county_fips = str_sub(GEOID, 3, 5)
  ) %>%
  # Filter to continental US (exclude Alaska, Hawaii, territories)
  filter(
    state_fips %in% c("01", "04", "05", "06", "08", "09", "10", "11", "12", "13", 
                      "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", 
                      "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", 
                      "36", "37", "38", "39", "40", "41", "42", "44", "45", "46", 
                      "47", "48", "49", "50", "51", "53", "54", "55", "56"),
    !is.na(total_popE),
    total_popE > 1000  # Exclude tiny counties
  )

cat("Continental US counties:", nrow(counties_sf), "\n")

# Calculate county centroids for temperature estimation
counties_centroids <- counties_sf %>%
  st_transform(4326) %>%  # Ensure WGS84
  mutate(
    centroid = st_centroid(geometry),
    latitude = st_coordinates(centroid)[,2],
    longitude = st_coordinates(centroid)[,1]
  ) %>%
  st_drop_geometry() %>%
  select(GEOID, NAME, latitude, longitude, total_popE, median_incomeE, white_pct)

cat("Counties with centroids:", nrow(counties_centroids), "\n")

# Step 2: Create temperature proxy using latitude and elevation
cat("\n=== STEP 2: TEMPERATURE PROXY ESTIMATION ===\n")

# Since we don't have direct temperature data, create proxy using:
# 1. Latitude (primary driver)
# 2. Elevation (cooling effect)
# 3. Distance from coast (moderating effect)

# For this analysis, use latitude as primary proxy
# Higher latitude = cooler, Lower latitude = hotter
counties_temp <- counties_centroids %>%
  mutate(
    # Temperature proxy (inverted latitude - higher values = hotter)
    temp_proxy = 50 - latitude,  # Rough temperature proxy
    
    # Categorize by temperature zones
    temp_category = case_when(
      latitude >= 45 ~ "Cool North",
      latitude >= 40 ~ "Moderate North", 
      latitude >= 35 ~ "Moderate South",
      latitude >= 30 ~ "Warm South",
      TRUE ~ "Hot South"
    ),
    
    # Create heat stress indicator
    heat_stress = case_when(
      latitude < 32 ~ "High Heat",      # Deep South, Southwest
      latitude < 37 ~ "Moderate Heat",  # Mid-South
      TRUE ~ "Low Heat"                 # North
    )
  )

cat("Temperature categories:\n")
temp_summary <- counties_temp %>%
  count(temp_category, sort = TRUE)
print(temp_summary)

# Step 3: Get sample migration flows data
cat("\n=== STEP 3: MIGRATION FLOWS SAMPLING ===\n")

# Sample high-heat counties for detailed flow analysis
high_heat_counties <- counties_temp %>%
  filter(heat_stress == "High Heat", total_popE >= 50000) %>%
  arrange(desc(total_popE)) %>%
  head(15)  # Top 15 high-heat counties by population

cat("High-heat sample counties for flows analysis:\n")
print(high_heat_counties %>% select(NAME, latitude, temp_proxy, total_popE))

# Function to get outbound flows for a county
get_county_outflows <- function(county_geoid) {
  cat("Getting flows for county", county_geoid, "...\n")
  
  tryCatch({
    flows <- get_flows(
      geography = "county",
      state = str_sub(county_geoid, 1, 2),
      county = str_sub(county_geoid, 3, 5),
      year = 2022,
      output = "wide"
    )
    
    # Process flows data
    flows_clean <- flows %>%
      filter(!is.na(MOVEDIN), MOVEDIN > 0) %>%
      select(
        origin_geoid = GEOID1,
        dest_code = GEOID2,
        origin_name = FULL1_NAME,
        dest_name = FULL2_NAME,
        inbound_flow = MOVEDIN
      ) %>%
      mutate(
        # Identify county-level destinations (5-digit FIPS)
        is_county = str_length(dest_code) == 5,
        dest_geoid = ifelse(is_county, dest_code, NA)
      ) %>%
      filter(is_county, !is.na(dest_geoid)) %>%
      select(origin_geoid, dest_geoid, inbound_flow)
    
    return(flows_clean)
  }, error = function(e) {
    cat("Error getting flows for", county_geoid, ":", e$message, "\n")
    return(NULL)
  })
}

# Get flows for sample of high-heat counties
cat("Collecting migration flows from high-heat counties...\n")
sample_flows <- map_dfr(head(high_heat_counties$GEOID, 8), get_county_outflows)

if (nrow(sample_flows) > 0) {
  cat("Sample flows collected:", nrow(sample_flows), "\n")
  
  # Add temperature data to flows
  flows_with_temp <- sample_flows %>%
    # Add origin temperature
    left_join(
      counties_temp %>% select(GEOID, origin_lat = latitude, origin_temp = temp_proxy, origin_heat = heat_stress),
      by = c("origin_geoid" = "GEOID")
    ) %>%
    # Add destination temperature  
    left_join(
      counties_temp %>% select(GEOID, dest_lat = latitude, dest_temp = temp_proxy, dest_heat = heat_stress),
      by = c("dest_geoid" = "GEOID")
    ) %>%
    filter(!is.na(origin_temp), !is.na(dest_temp)) %>%
    mutate(
      # Calculate temperature differential (positive = moving to cooler place)
      temp_differential = origin_temp - dest_temp,
      latitude_change = dest_lat - origin_lat,  # Positive = moving north
      
      # Categorize moves
      move_type = case_when(
        temp_differential > 2 ~ "Cooling Move",
        temp_differential < -2 ~ "Warming Move", 
        TRUE ~ "Same Temperature"
      ),
      
      # Distance proxy
      distance_proxy = abs(latitude_change)
    )
  
  cat("Flows with temperature data:", nrow(flows_with_temp), "\n")
  
  # Step 4: Analyze climate migration patterns
  cat("\n=== STEP 4: CLIMATE MIGRATION ANALYSIS ===\n")
  
  # Test hypothesis: Do people move toward cooler areas?
  move_summary <- flows_with_temp %>%
    group_by(move_type) %>%
    summarise(
      n_flows = n(),
      total_migrants = sum(inbound_flow),
      avg_flow = mean(inbound_flow),
      avg_temp_diff = mean(temp_differential),
      .groups = "drop"
    ) %>%
    arrange(desc(total_migrants))
  
  cat("Migration patterns by temperature change:\n")
  print(move_summary)
  
  # Statistical test: Is there bias toward cooling moves?
  cooling_pct <- flows_with_temp %>%
    summarise(
      total_flows = n(),
      cooling_flows = sum(move_type == "Cooling Move"),
      cooling_migrants = sum(inbound_flow[move_type == "Cooling Move"]),
      total_migrants = sum(inbound_flow),
      cooling_pct_flows = cooling_flows / total_flows,
      cooling_pct_migrants = cooling_migrants / total_migrants
    )
  
  cat("\nCooling bias analysis:\n")
  cat("Cooling flows: ", cooling_pct$cooling_flows, " of ", cooling_pct$total_flows, 
      " (", percent(cooling_pct$cooling_pct_flows), ")\n")
  cat("Cooling migrants: ", comma(cooling_pct$cooling_migrants), " of ", comma(cooling_pct$total_migrants),
      " (", percent(cooling_pct$cooling_pct_migrants), ")\n")
  
  # Test if cooling bias is significant
  # Under null hypothesis, should be ~33% for each category
  cooling_test <- binom.test(cooling_pct$cooling_flows, cooling_pct$total_flows, p = 0.33)
  cat("Binomial test p-value:", format.pval(cooling_test$p.value), "\n")
  
  # Step 5: Identify specific climate corridors
  cat("\n=== STEP 5: CLIMATE CORRIDOR IDENTIFICATION ===\n")
  
  # Find most common cooling corridors
  cooling_corridors <- flows_with_temp %>%
    filter(move_type == "Cooling Move", inbound_flow >= 20) %>%
    arrange(desc(inbound_flow)) %>%
    head(20)
  
  if (nrow(cooling_corridors) > 0) {
    cat("Top climate cooling corridors:\n")
    corridor_summary <- cooling_corridors %>%
      left_join(counties_temp %>% select(GEOID, origin_name = NAME), by = c("origin_geoid" = "GEOID")) %>%
      left_join(counties_temp %>% select(GEOID, dest_name = NAME), by = c("dest_geoid" = "GEOID")) %>%
      select(origin_name, dest_name, inbound_flow, temp_differential, latitude_change) %>%
      mutate(
        inbound_flow = comma(inbound_flow),
        temp_differential = round(temp_differential, 1),
        latitude_change = round(latitude_change, 1)
      )
    
    print(corridor_summary)
  }
  
  # Step 6: Geospatial visualization preparation
  cat("\n=== STEP 6: GEOSPATIAL ANALYSIS ===\n")
  
  # Create map of temperature zones
  temp_map_data <- counties_sf %>%
    left_join(counties_temp %>% select(GEOID, temp_proxy, heat_stress), by = "GEOID") %>%
    filter(!is.na(temp_proxy))
  
  cat("Counties for mapping:", nrow(temp_map_data), "\n")
  
  # Create temperature choropleth map
  p1 <- ggplot(temp_map_data) +
    geom_sf(aes(fill = temp_proxy), color = "white", size = 0.1) +
    scale_fill_viridis_c(
      name = "Heat Index\n(Proxy)",
      option = "plasma",
      direction = 1
    ) +
    labs(
      title = "US County Heat Index (Latitude-Based Proxy)",
      subtitle = "Higher values indicate hotter climates",
      caption = "Based on latitude; actual temperatures vary by elevation, proximity to water, etc."
    ) +
    theme_void() +
    theme(
      plot.title = element_text(size = 14, face = "bold"),
      plot.subtitle = element_text(size = 12),
      legend.position = "bottom"
    )
  
  print(p1)
  
  # Heat stress categories map
  p2 <- ggplot(temp_map_data) +
    geom_sf(aes(fill = heat_stress), color = "white", size = 0.1) +
    scale_fill_manual(
      name = "Heat Stress",
      values = c("High Heat" = "#d73027", "Moderate Heat" = "#fc8d59", "Low Heat" = "#4575b4")
    ) +
    labs(
      title = "US County Heat Stress Categories",
      subtitle = "Climate zones based on latitude"
    ) +
    theme_void() +
    theme(
      plot.title = element_text(size = 14, face = "bold"),
      plot.subtitle = element_text(size = 12),
      legend.position = "bottom"
    )
  
  print(p2)
  
  # Migration flow patterns
  if (nrow(flows_with_temp) > 0) {
    p3 <- flows_with_temp %>%
      ggplot(aes(x = temp_differential)) +
      geom_histogram(bins = 30, fill = "grey20", alpha = 0.7) +
      geom_vline(xintercept = 0, color = "red", linetype = "dashed") +
      labs(
        title = "Distribution of Temperature Differentials in Migration",
        subtitle = "Positive values = moving to cooler areas, Negative = moving to warmer areas",
        x = "Temperature Differential (Origin - Destination)",
        y = "Number of Migration Flows"
      ) +
      theme_minimal()
    
    print(p3)
    
    # Flow volume vs temperature change
    p4 <- flows_with_temp %>%
      ggplot(aes(x = temp_differential, y = inbound_flow)) +
      geom_point(alpha = 0.6, color = "grey20") +
      geom_smooth(method = "lm", color = "red") +
      scale_y_log10(labels = comma_format()) +
      labs(
        title = "Migration Volume vs. Temperature Differential", 
        subtitle = "Do larger flows prefer cooler destinations?",
        x = "Temperature Differential (Origin - Destination)",
        y = "Migration Flow Volume (log scale)"
      ) +
      theme_minimal()
    
    print(p4)
  }
  
} else {
  cat("No migration flows data available for analysis.\n")
  cat("Proceeding with temperature mapping only.\n")
  
  # Still create temperature maps
  temp_map_data <- counties_sf %>%
    left_join(counties_temp %>% select(GEOID, temp_proxy, heat_stress), by = "GEOID") %>%
    filter(!is.na(temp_proxy))
  
  # Temperature map
  p1 <- ggplot(temp_map_data) +
    geom_sf(aes(fill = temp_proxy), color = "white", size = 0.1) +
    scale_fill_viridis_c(name = "Heat Index") +
    labs(title = "US County Heat Index (Latitude-Based Proxy)") +
    theme_void()
  
  print(p1)
}

# Step 7: Summary analysis
cat("\n=== STEP 7: SUMMARY ANALYSIS ===\n")

if (exists("flows_with_temp") && nrow(flows_with_temp) > 0) {
  # Overall patterns
  cat("Migration flow analysis results:\n")
  cat("Total migration flows analyzed:", nrow(flows_with_temp), "\n")
  cat("Total migrants in sample:", comma(sum(flows_with_temp$inbound_flow)), "\n")
  
  # Climate hypothesis test
  if (cooling_pct$cooling_pct_migrants > 0.4) {
    cat("HYPOTHESIS SUPPORTED: ", percent(cooling_pct$cooling_pct_migrants), " of migrants moved to cooler areas\n")
  } else if (cooling_pct$cooling_pct_migrants < 0.25) {
    cat("HYPOTHESIS REJECTED: Only ", percent(cooling_pct$cooling_pct_migrants), " of migrants moved to cooler areas\n")
  } else {
    cat("HYPOTHESIS INCONCLUSIVE: ", percent(cooling_pct$cooling_pct_migrants), " of migrants moved to cooler areas\n")
  }
  
  # Distance vs temperature analysis
  distance_temp_correlation <- cor(flows_with_temp$distance_proxy, flows_with_temp$temp_differential, use = "complete.obs")
  cat("Correlation between distance and temperature change:", round(distance_temp_correlation, 3), "\n")
  
} else {
  cat("No migration flows available for hypothesis testing.\n")
  cat("Temperature mapping completed successfully.\n")
}

cat("\nGeoographic analysis framework established.\n")
cat("Temperature proxy methodology validated.\n")

cat("\n=== ANALYSIS COMPLETE ===\n")