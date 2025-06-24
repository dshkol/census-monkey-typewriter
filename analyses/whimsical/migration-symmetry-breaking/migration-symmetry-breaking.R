# Migration Symmetry Breaking: When A→B ≠ B→A
# 
# Hypothesis: Identify county pairs with maximally asymmetric migration flows—
# where many move A→B but few move B→A. Test whether these imbalanced pairs 
# share systematic characteristics.
#
# Creating an "asymmetry index" to reveal hidden hierarchies in how Americans 
# conceptualize geographic mobility.

# Load required libraries
library(tidyverse)
library(tidycensus)
library(scales)
library(ggplot2)
library(sf)

# Set API key
census_api_key(Sys.getenv("CENSUS_API_KEY"))

cat("=== MIGRATION SYMMETRY BREAKING ANALYSIS ===\n")
cat("Identifying asymmetric county-to-county migration flows\n")
cat("Testing whether A→B ≠ B→A in systematic ways\n\n")

# First, let's test with a manageable subset - Texas counties for initial exploration
cat("Starting with Texas counties for manageable analysis scope...\n")

# Get Texas county-to-county migration flows
cat("Fetching Texas county-to-county migration flows...\n")
tx_flows <- get_flows(
  geography = "county",
  state = "TX",
  county = NULL,  # All TX counties
  year = 2022,
  output = "wide"
)

cat("Raw flows data rows:", nrow(tx_flows), "\n")
cat("Columns:", paste(names(tx_flows), collapse = ", "), "\n")
cat("Sample data:\n")
print(head(tx_flows))

# Clean and process flows data
cat("\nProcessing migration flows data...\n")
flows_clean <- tx_flows %>%
  # Filter for flows between TX counties (both origin and destination in TX)
  filter(
    str_detect(GEOID1, "^48"),  # TX state FIPS = 48
    str_detect(GEOID2, "^48"),
    !is.na(MOVEDOUT),
    MOVEDOUT > 0  # Only include positive flows
  ) %>%
  select(
    origin_geoid = GEOID1,
    dest_geoid = GEOID2,
    origin_name = FULL1_NAME,
    dest_name = FULL2_NAME,
    flow_out = MOVEDOUT
  ) %>%
  # Clean up names
  mutate(
    origin_name = str_remove(origin_name, ", Texas$"),
    dest_name = str_remove(dest_name, ", Texas$")
  )

cat("Cleaned flows rows:", nrow(flows_clean), "\n")
cat("Unique origin counties:", length(unique(flows_clean$origin_geoid)), "\n")
cat("Unique destination counties:", length(unique(flows_clean$dest_geoid)), "\n")

# Create symmetric flow pairs
cat("\nCreating symmetric flow pairs for asymmetry analysis...\n")

# For each origin-destination pair, find the reverse flow
flows_symmetric <- flows_clean %>%
  # Create sorted pair identifiers to group bidirectional flows
  mutate(
    geoid_pair = map2_chr(origin_geoid, dest_geoid, function(a, b) {
      paste(sort(c(a, b)), collapse = "_")
    }),
    # Identify direction within pair
    is_primary = origin_geoid < dest_geoid
  ) %>%
  # Group by pair and calculate asymmetry
  group_by(geoid_pair) %>%
  summarise(
    # Get both directions
    geoid_a = first(ifelse(is_primary, origin_geoid, dest_geoid)),
    geoid_b = first(ifelse(is_primary, dest_geoid, origin_geoid)),
    name_a = first(ifelse(is_primary, origin_name, dest_name)),
    name_b = first(ifelse(is_primary, dest_name, origin_name)),
    
    # Flows in each direction
    flow_a_to_b = sum(ifelse(is_primary, flow_out, 0), na.rm = T),
    flow_b_to_a = sum(ifelse(!is_primary, flow_out, 0), na.rm = T),
    
    # Total bidirectional flow
    total_flow = flow_a_to_b + flow_b_to_a,
    
    .groups = "drop"
  ) %>%
  # Calculate asymmetry metrics
  mutate(
    # Asymmetry index: ranges from -1 (all B→A) to +1 (all A→B)
    asymmetry_index = if_else(
      total_flow > 0,
      (flow_a_to_b - flow_b_to_a) / total_flow,
      0
    ),
    
    # Absolute asymmetry (0 = symmetric, 1 = completely one-directional)
    abs_asymmetry = abs(asymmetry_index),
    
    # Dominant direction
    dominant_direction = case_when(
      flow_a_to_b > flow_b_to_a ~ paste(name_a, "→", name_b),
      flow_b_to_a > flow_a_to_b ~ paste(name_b, "→", name_a),
      TRUE ~ "Symmetric"
    ),
    
    # Flow ratio (larger flow / smaller flow)
    flow_ratio = if_else(
      total_flow > 0,
      pmax(flow_a_to_b, flow_b_to_a) / pmax(pmin(flow_a_to_b, flow_b_to_a), 1),
      1
    )
  ) %>%
  # Filter for meaningful flows
  filter(total_flow >= 10) %>%  # At least 10 total migrants
  arrange(desc(abs_asymmetry))

cat("County pairs with meaningful flows:", nrow(flows_symmetric), "\n")
cat("Mean asymmetry index:", round(mean(flows_symmetric$asymmetry_index), 3), "\n")
cat("Mean absolute asymmetry:", round(mean(flows_symmetric$abs_asymmetry), 3), "\n\n")

# Analyze most asymmetric flows
cat("=== MOST ASYMMETRIC MIGRATION FLOWS ===\n")

# Top 15 most asymmetric pairs
top_asymmetric <- flows_symmetric %>%
  head(15) %>%
  select(name_a, name_b, flow_a_to_b, flow_b_to_a, asymmetry_index, flow_ratio, dominant_direction)

print(top_asymmetric)

# Statistical summary of asymmetry
cat("\n=== ASYMMETRY DISTRIBUTION ANALYSIS ===\n")

asymmetry_stats <- flows_symmetric %>%
  summarise(
    total_pairs = n(),
    mean_asymmetry = mean(abs_asymmetry),
    median_asymmetry = median(abs_asymmetry),
    highly_asymmetric = sum(abs_asymmetry > 0.8),  # >80% asymmetric
    moderately_asymmetric = sum(abs_asymmetry > 0.5 & abs_asymmetry <= 0.8),
    symmetric = sum(abs_asymmetry <= 0.2),
    max_asymmetry = max(abs_asymmetry),
    perfectly_symmetric = sum(asymmetry_index == 0)
  )

print(asymmetry_stats)

cat("\nAsymmetry categories:\n")
cat("Highly asymmetric (>80%):", asymmetry_stats$highly_asymmetric, 
    "(", percent(asymmetry_stats$highly_asymmetric / asymmetry_stats$total_pairs), ")\n")
cat("Moderately asymmetric (50-80%):", asymmetry_stats$moderately_asymmetric,
    "(", percent(asymmetry_stats$moderately_asymmetric / asymmetry_stats$total_pairs), ")\n")
cat("Roughly symmetric (<20%):", asymmetry_stats$symmetric,
    "(", percent(asymmetry_stats$symmetric / asymmetry_stats$total_pairs), ")\n")

# Test for systematic patterns in asymmetric flows
cat("\n=== TESTING FOR SYSTEMATIC PATTERNS ===\n")

# Get county characteristics for pattern analysis
cat("Fetching county characteristics for pattern analysis...\n")
tx_counties <- get_acs(
  geography = "county",
  state = "TX",
  variables = c(
    total_pop = "B01003_001",
    median_income = "B19013_001",
    rural_pop = "B08301_021"  # Workers who work at home (proxy for rurality)
  ),
  year = 2022,
  output = "wide"
) %>%
  select(GEOID, NAME, total_popE, median_incomeE, rural_popE) %>%
  rename(
    geoid = GEOID,
    population = total_popE,
    median_income = median_incomeE,
    rural_workers = rural_popE
  ) %>%
  mutate(
    county_name = str_remove(NAME, " County, Texas$")
  )

cat("County characteristics rows:", nrow(tx_counties), "\n")

# Merge characteristics with flow pairs
flows_with_chars <- flows_symmetric %>%
  left_join(
    tx_counties %>% select(geoid, pop_a = population, income_a = median_income),
    by = c("geoid_a" = "geoid")
  ) %>%
  left_join(
    tx_counties %>% select(geoid, pop_b = population, income_b = median_income),
    by = c("geoid_b" = "geoid")
  ) %>%
  filter(!is.na(pop_a), !is.na(pop_b), !is.na(income_a), !is.na(income_b)) %>%
  mutate(
    # Calculate differences
    pop_ratio = pop_a / pop_b,
    income_diff = income_a - income_b,
    income_ratio = income_a / income_b,
    
    # Categorize by size and income
    size_relationship = case_when(
      pop_ratio > 2 ~ "A much larger",
      pop_ratio > 1.2 ~ "A larger", 
      pop_ratio < 0.5 ~ "B much larger",
      pop_ratio < 0.83 ~ "B larger",
      TRUE ~ "Similar size"
    ),
    
    income_relationship = case_when(
      income_ratio > 1.2 ~ "A richer",
      income_ratio < 0.83 ~ "B richer", 
      TRUE ~ "Similar income"
    )
  )

cat("Pairs with complete characteristics:", nrow(flows_with_chars), "\n")

# Test hypotheses about asymmetry patterns
cat("\n=== HYPOTHESIS TESTING ===\n")

# Hypothesis 1: Do people move from smaller to larger counties?
size_test <- flows_with_chars %>%
  group_by(size_relationship) %>%
  summarise(
    n = n(),
    mean_asymmetry = mean(asymmetry_index),
    .groups = "drop"
  ) %>%
  arrange(desc(mean_asymmetry))

cat("Asymmetry by relative county size:\n")
print(size_test)

# Hypothesis 2: Do people move from poorer to richer counties?
income_test <- flows_with_chars %>%
  group_by(income_relationship) %>%
  summarise(
    n = n(),
    mean_asymmetry = mean(asymmetry_index),
    .groups = "drop"
  ) %>%
  arrange(desc(mean_asymmetry))

cat("\nAsymmetry by relative county income:\n")
print(income_test)

# Hypothesis 3: Distance effects
cat("\nAnalyzing distance effects on asymmetry...\n")

# For distance analysis, we need coordinates - let's get county centroids
tx_counties_sf <- get_acs(
  geography = "county",
  state = "TX", 
  variables = "B01003_001",
  year = 2022,
  geometry = TRUE
) %>%
  st_transform(4326) %>%  # Ensure WGS84
  mutate(
    centroid = st_centroid(geometry),
    lon = st_coordinates(centroid)[,1],
    lat = st_coordinates(centroid)[,2]
  ) %>%
  st_drop_geometry() %>%
  select(GEOID, county_name = NAME, lon, lat) %>%
  mutate(county_name = str_remove(county_name, " County, Texas$"))

# Calculate distances
flows_with_distance <- flows_with_chars %>%
  left_join(
    tx_counties_sf %>% select(GEOID, lon_a = lon, lat_a = lat),
    by = c("geoid_a" = "GEOID")
  ) %>%
  left_join(
    tx_counties_sf %>% select(GEOID, lon_b = lon, lat_b = lat),
    by = c("geoid_b" = "GEOID")
  ) %>%
  filter(!is.na(lon_a), !is.na(lat_a), !is.na(lon_b), !is.na(lat_b)) %>%
  rowwise() %>%
  mutate(
    # Calculate distance using Haversine formula (approximate)
    distance_miles = distHaversine(c(lon_a, lat_a), c(lon_b, lat_b)) / 1609.34
  ) %>%
  ungroup() %>%
  mutate(
    distance_category = case_when(
      distance_miles < 50 ~ "Very close (<50 mi)",
      distance_miles < 100 ~ "Close (50-100 mi)",
      distance_miles < 200 ~ "Medium (100-200 mi)",
      TRUE ~ "Far (>200 mi)"
    )
  )

# Distance vs asymmetry analysis
distance_test <- flows_with_distance %>%
  group_by(distance_category) %>%
  summarise(
    n = n(),
    mean_asymmetry = mean(abs_asymmetry),
    mean_distance = mean(distance_miles),
    .groups = "drop"
  ) %>%
  arrange(mean_distance)

cat("Asymmetry by distance:\n")
print(distance_test)

# Create visualizations
cat("\n=== CREATING VISUALIZATIONS ===\n")

# Plot 1: Asymmetry distribution
p1 <- flows_symmetric %>%
  ggplot(aes(x = asymmetry_index)) +
  geom_histogram(bins = 40, fill = "grey20", alpha = 0.7) +
  geom_vline(xintercept = 0, color = "red", linetype = "dashed") +
  scale_x_continuous(limits = c(-1, 1)) +
  labs(
    title = "Distribution of Migration Flow Asymmetry",
    subtitle = "Texas county pairs • -1 = all flow B→A, +1 = all flow A→B, 0 = symmetric",
    x = "Asymmetry Index",
    y = "Count of County Pairs"
  ) +
  theme_minimal()

print(p1)

# Plot 2: Asymmetry vs. population ratio
p2 <- flows_with_chars %>%
  filter(abs(asymmetry_index) > 0.3) %>%  # Focus on asymmetric pairs
  ggplot(aes(x = log10(pop_ratio), y = asymmetry_index)) +
  geom_point(alpha = 0.6, color = "grey20") +
  geom_smooth(method = "lm", color = "red") +
  geom_hline(yintercept = 0, linetype = "dashed", alpha = 0.5) +
  geom_vline(xintercept = 0, linetype = "dashed", alpha = 0.5) +
  labs(
    title = "Migration Asymmetry vs. Population Ratio",
    subtitle = "Do people move from smaller to larger counties?",
    x = "Log Population Ratio (County A / County B)",
    y = "Asymmetry Index (+ = more A→B flow)"
  ) +
  theme_minimal()

print(p2)

# Plot 3: Flow magnitude vs asymmetry
p3 <- flows_symmetric %>%
  ggplot(aes(x = log10(total_flow), y = abs_asymmetry)) +
  geom_point(alpha = 0.6, color = "grey20") +
  geom_smooth(method = "lm", color = "red") +
  labs(
    title = "Flow Volume vs. Asymmetry",
    subtitle = "Are high-volume flows more or less symmetric?",
    x = "Log Total Flow Volume",
    y = "Absolute Asymmetry"
  ) +
  theme_minimal()

print(p3)

# Identify specific patterns
cat("\n=== SPECIFIC PATTERN ANALYSIS ===\n")

# Look for alphabetical ordering effects
alphabet_test <- flows_symmetric %>%
  mutate(
    alphabetical_order = name_a < name_b,
    matches_flow_direction = case_when(
      alphabetical_order & asymmetry_index > 0 ~ "Alphabetical matches flow",
      !alphabetical_order & asymmetry_index < 0 ~ "Alphabetical matches flow", 
      TRUE ~ "Alphabetical opposite to flow"
    )
  ) %>%
  group_by(matches_flow_direction) %>%
  summarise(
    n = n(),
    mean_asymmetry = mean(abs_asymmetry),
    .groups = "drop"
  )

cat("Alphabetical ordering vs. flow direction:\n")
print(alphabet_test)

# Look for geographic patterns (north-south, east-west)
geographic_test <- flows_with_distance %>%
  mutate(
    lat_diff = lat_a - lat_b,  # Positive = A is north of B
    lon_diff = lon_a - lon_b,  # Positive = A is west of B
    
    direction = case_when(
      abs(lat_diff) > abs(lon_diff) & lat_diff > 0 ~ "North to South",
      abs(lat_diff) > abs(lon_diff) & lat_diff < 0 ~ "South to North",
      abs(lon_diff) > abs(lat_diff) & lon_diff > 0 ~ "West to East",
      TRUE ~ "East to West"
    )
  ) %>%
  group_by(direction) %>%
  summarise(
    n = n(),
    mean_asymmetry = mean(asymmetry_index),
    .groups = "drop"
  )

cat("\nAsymmetry by geographic direction:\n")
print(geographic_test)

# Summary insights
cat("\n=== SUMMARY INSIGHTS ===\n")
cat("Total county pairs analyzed:", nrow(flows_symmetric), "\n")
cat("Most asymmetric pair:", 
    flows_symmetric$dominant_direction[1], 
    "(asymmetry =", round(flows_symmetric$abs_asymmetry[1], 3), ")\n")
cat("Least asymmetric pairs:", sum(flows_symmetric$abs_asymmetry < 0.1), "\n")

# Top patterns by various criteria
cat("\nTop asymmetric flows by volume:\n")
top_by_volume <- flows_symmetric %>%
  filter(abs_asymmetry > 0.5) %>%
  arrange(desc(total_flow)) %>%
  head(5) %>%
  select(dominant_direction, total_flow, asymmetry_index)
print(top_by_volume)

cat("\n=== ANALYSIS COMPLETE ===\n")