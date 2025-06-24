# Final Migration Symmetry Breaking Analysis
# 
# Analyzing "Attractiveness Asymmetry" - which states show very different 
# migration rates to different Texas counties

library(tidyverse)
library(tidycensus)
library(scales)
library(ggplot2)

# Set API key
census_api_key(Sys.getenv("CENSUS_API_KEY"))

cat("=== MIGRATION ATTRACTIVENESS ASYMMETRY ANALYSIS ===\n")
cat("Testing whether different states show asymmetric attraction to Texas counties\n\n")

# Major Texas counties for analysis
major_tx_counties <- c(
  "48201", # Harris (Houston)
  "48113", # Dallas  
  "48029", # Bexar (San Antonio)
  "48453", # Travis (Austin)
  "48439", # Tarrant (Fort Worth)
  "48085", # Collin (Plano)
  "48157", # Fort Bend (Sugar Land)
  "48121", # Denton
  "48491", # Williamson (Round Rock)
  "48027"  # Bell (Killeen)
)

# Get county names for reference
county_info <- tibble(
  geoid = major_tx_counties,
  county_name = c("Harris", "Dallas", "Bexar", "Travis", "Tarrant", 
                 "Collin", "Fort Bend", "Denton", "Williamson", "Bell"),
  metro_area = c("Houston", "Dallas", "San Antonio", "Austin", "Fort Worth",
                "Dallas", "Houston", "Dallas", "Austin", "Killeen")
)

# Function to get inbound flows for a county
get_inbound_flows <- function(county_geoid) {
  cat("Getting inbound flows for", county_geoid, "...\n")
  flows <- get_flows(
    geography = "county",
    state = str_sub(county_geoid, 1, 2),
    county = str_sub(county_geoid, 3, 5),
    year = 2022,
    output = "wide"
  )
  flows$dest_county <- county_geoid
  return(flows)
}

# Collect all inbound flows
cat("Collecting inbound migration flows...\n")
all_inbound <- map_dfr(major_tx_counties, get_inbound_flows)

cat("Total flow records:", nrow(all_inbound), "\n")

# Process and clean the flows data
flows_clean <- all_inbound %>%
  filter(!is.na(MOVEDIN), MOVEDIN > 0) %>%
  select(
    origin_code = GEOID2,
    dest_geoid = dest_county,
    origin_name = FULL2_NAME,
    dest_name = FULL1_NAME,
    inbound_flow = MOVEDIN
  ) %>%
  # Add county info
  left_join(county_info, by = c("dest_geoid" = "geoid")) %>%
  # Clean up origin names and codes
  mutate(
    # Identify origin types
    origin_type = case_when(
      str_length(origin_code) == 3 & str_detect(origin_code, "^[0-9]+$") ~ "US State",
      origin_code %in% c("AFR", "ASI", "EUR", "NAM", "SAM", "OCE") ~ "International",
      TRUE ~ "Other"
    ),
    
    # Map state codes to names for US states
    origin_state = case_when(
      origin_code == "001" ~ "Alabama",
      origin_code == "002" ~ "Alaska", 
      origin_code == "004" ~ "Arizona",
      origin_code == "005" ~ "Arkansas",
      origin_code == "006" ~ "California",
      origin_code == "008" ~ "Colorado",
      origin_code == "009" ~ "Connecticut",
      origin_code == "010" ~ "Delaware",
      origin_code == "011" ~ "District of Columbia",
      origin_code == "012" ~ "Florida",
      origin_code == "013" ~ "Georgia",
      origin_code == "015" ~ "Hawaii",
      origin_code == "016" ~ "Idaho",
      origin_code == "017" ~ "Illinois",
      origin_code == "018" ~ "Indiana",
      origin_code == "019" ~ "Iowa",
      origin_code == "020" ~ "Kansas",
      origin_code == "021" ~ "Kentucky",
      origin_code == "022" ~ "Louisiana",
      origin_code == "023" ~ "Maine",
      origin_code == "024" ~ "Maryland",
      origin_code == "025" ~ "Massachusetts",
      origin_code == "026" ~ "Michigan",
      origin_code == "027" ~ "Minnesota",
      origin_code == "028" ~ "Mississippi",
      origin_code == "029" ~ "Missouri",
      origin_code == "030" ~ "Montana",
      origin_code == "031" ~ "Nebraska",
      origin_code == "032" ~ "Nevada",
      origin_code == "033" ~ "New Hampshire",
      origin_code == "034" ~ "New Jersey",
      origin_code == "035" ~ "New Mexico",
      origin_code == "036" ~ "New York",
      origin_code == "037" ~ "North Carolina",
      origin_code == "038" ~ "North Dakota",
      origin_code == "039" ~ "Ohio",
      origin_code == "040" ~ "Oklahoma",
      origin_code == "041" ~ "Oregon",
      origin_code == "042" ~ "Pennsylvania",
      origin_code == "044" ~ "Rhode Island",
      origin_code == "045" ~ "South Carolina",
      origin_code == "046" ~ "South Dakota",
      origin_code == "047" ~ "Tennessee",
      origin_code == "049" ~ "Utah",
      origin_code == "050" ~ "Vermont",
      origin_code == "051" ~ "Virginia",
      origin_code == "053" ~ "Washington",
      origin_code == "054" ~ "West Virginia",
      origin_code == "055" ~ "Wisconsin",
      origin_code == "056" ~ "Wyoming",
      TRUE ~ origin_name
    )
  ) %>%
  filter(origin_type == "US State") %>%  # Focus on state-to-county flows
  select(origin_state, dest_geoid, county_name, metro_area, inbound_flow)

cat("Processed state-to-county flows:", nrow(flows_clean), "\n")
cat("Unique origin states:", length(unique(flows_clean$origin_state)), "\n")
cat("Unique destination counties:", length(unique(flows_clean$dest_geoid)), "\n")

# Calculate asymmetry metrics
cat("\n=== CALCULATING ASYMMETRY METRICS ===\n")

# For each state, calculate how unevenly it distributes migrants across TX counties
state_asymmetry <- flows_clean %>%
  group_by(origin_state) %>%
  summarise(
    total_to_tx = sum(inbound_flow),
    n_counties = n(),
    max_flow = max(inbound_flow),
    min_flow = min(inbound_flow),
    mean_flow = mean(inbound_flow),
    median_flow = median(inbound_flow),
    
    # Asymmetry measures
    flow_range = max_flow - min_flow,
    coefficient_variation = sd(inbound_flow) / mean(inbound_flow),
    gini_coefficient = {
      # Calculate Gini coefficient for inequality
      flows_sorted <- sort(inbound_flow)
      n <- length(flows_sorted)
      index <- 1:n
      (2 * sum(index * flows_sorted)) / (n * sum(flows_sorted)) - (n + 1) / n
    },
    
    # Concentration ratio (top county / total)
    top_concentration = max_flow / total_to_tx,
    
    .groups = "drop"
  ) %>%
  # Filter for meaningful sample sizes
  filter(total_to_tx >= 100, n_counties >= 5) %>%
  arrange(desc(coefficient_variation))

cat("States with most asymmetric Texas preferences (top 10):\n")
print(state_asymmetry %>% 
      select(origin_state, total_to_tx, coefficient_variation, top_concentration) %>%
      head(10) %>%
      mutate(
        total_to_tx = comma(total_to_tx),
        coefficient_variation = round(coefficient_variation, 2),
        top_concentration = percent(top_concentration, accuracy = 1)
      ))

# Identify specific asymmetric preferences
cat("\n=== SPECIFIC ASYMMETRIC PATTERNS ===\n")

# Find state-county pairs with unusually high concentrations
high_concentration_pairs <- flows_clean %>%
  group_by(origin_state) %>%
  mutate(
    state_total = sum(inbound_flow),
    pct_to_county = inbound_flow / state_total,
    mean_pct = 1 / n(),  # Expected percentage if equally distributed
    concentration_ratio = pct_to_county / mean_pct
  ) %>%
  filter(concentration_ratio >= 2, inbound_flow >= 100) %>%  # 2x expected + meaningful volume
  arrange(desc(concentration_ratio)) %>%
  ungroup()

cat("Most concentrated state-to-county preferences:\n")
print(high_concentration_pairs %>%
      select(origin_state, county_name, inbound_flow, pct_to_county, concentration_ratio) %>%
      head(15) %>%
      mutate(
        inbound_flow = comma(inbound_flow),
        pct_to_county = percent(pct_to_county, accuracy = 1),
        concentration_ratio = paste0(round(concentration_ratio, 1), "x")
      ))

# Analyze patterns by Texas metro area
metro_preferences <- flows_clean %>%
  group_by(origin_state, metro_area) %>%
  summarise(
    metro_flow = sum(inbound_flow),
    .groups = "drop"
  ) %>%
  group_by(origin_state) %>%
  mutate(
    total_flow = sum(metro_flow),
    pct_to_metro = metro_flow / total_flow
  ) %>%
  filter(total_flow >= 200) %>%  # Meaningful volume
  arrange(origin_state, desc(pct_to_metro))

# Find states with strong metro preferences
strong_metro_preferences <- metro_preferences %>%
  group_by(origin_state) %>%
  summarise(
    top_metro = first(metro_area),
    top_metro_pct = first(pct_to_metro),
    .groups = "drop"
  ) %>%
  filter(top_metro_pct >= 0.6) %>%  # 60%+ to one metro
  arrange(desc(top_metro_pct))

cat("\nStates with strong single-metro preferences (60%+ to one metro):\n")
print(strong_metro_preferences %>%
      mutate(top_metro_pct = percent(top_metro_pct, accuracy = 1)))

# Create visualizations
cat("\n=== CREATING VISUALIZATIONS ===\n")

# Plot 1: Asymmetry distribution
p1 <- state_asymmetry %>%
  ggplot(aes(x = coefficient_variation)) +
  geom_histogram(bins = 15, fill = "grey20", alpha = 0.7) +
  labs(
    title = "Distribution of State Migration Asymmetry to Texas",
    subtitle = "Coefficient of variation in flows to different TX counties",
    x = "Coefficient of Variation",
    y = "Count of States"
  ) +
  theme_minimal()

print(p1)

# Plot 2: Top asymmetric states
p2 <- state_asymmetry %>%
  head(12) %>%
  ggplot(aes(x = reorder(origin_state, coefficient_variation), y = coefficient_variation)) +
  geom_col(fill = "grey20", alpha = 0.7) +
  coord_flip() +
  labs(
    title = "Most Asymmetric State Preferences for Texas Counties",
    subtitle = "States with highest variation in county destination choices",
    x = "Origin State",
    y = "Coefficient of Variation"
  ) +
  theme_minimal()

print(p2)

# Plot 3: Total flow vs asymmetry
p3 <- state_asymmetry %>%
  ggplot(aes(x = log10(total_to_tx), y = coefficient_variation)) +
  geom_point(alpha = 0.7, size = 3, color = "grey20") +
  geom_smooth(method = "lm", color = "red") +
  labs(
    title = "Migration Volume vs. Destination Asymmetry",
    subtitle = "Do high-volume migrating states show more focused preferences?",
    x = "Log Total Migration to Texas",
    y = "Coefficient of Variation"
  ) +
  theme_minimal()

print(p3)

# Summary statistics and insights
cat("\n=== SUMMARY INSIGHTS ===\n")

# Overall statistics
total_migrants <- sum(flows_clean$inbound_flow)
cat("Total interstate migrants to major TX counties:", comma(total_migrants), "\n")
cat("Mean asymmetry (CV) across states:", round(mean(state_asymmetry$coefficient_variation), 2), "\n")
cat("States with high asymmetry (CV > 1.0):", sum(state_asymmetry$coefficient_variation > 1.0), "\n")

# Top patterns
cat("\nMost asymmetric states:\n")
for (i in 1:5) {
  state <- state_asymmetry$origin_state[i]
  cv <- round(state_asymmetry$coefficient_variation[i], 2)
  top_county <- high_concentration_pairs %>%
    filter(origin_state == state) %>%
    slice_max(concentration_ratio, n = 1) %>%
    pull(county_name)
  if (length(top_county) > 0) {
    cat("  ", state, "(CV =", cv, ") - most prefers", top_county[1], "\n")
  } else {
    cat("  ", state, "(CV =", cv, ")\n")
  }
}

# Geographic patterns
cat("\nGeographic clustering test:\n")
# Test if neighboring states show similar asymmetry patterns
south_states <- c("Louisiana", "Arkansas", "Oklahoma", "New Mexico")
west_states <- c("California", "Nevada", "Arizona", "Colorado")
east_states <- c("Florida", "Georgia", "North Carolina", "Virginia")

south_asymmetry <- state_asymmetry %>%
  filter(origin_state %in% south_states) %>%
  summarise(mean_cv = mean(coefficient_variation))

west_asymmetry <- state_asymmetry %>%
  filter(origin_state %in% west_states) %>%
  summarise(mean_cv = mean(coefficient_variation))

east_asymmetry <- state_asymmetry %>%
  filter(origin_state %in% east_states) %>%
  summarise(mean_cv = mean(coefficient_variation))

cat("Mean asymmetry by region:\n")
cat("  South states:", round(south_asymmetry$mean_cv, 2), "\n")
cat("  West states:", round(west_asymmetry$mean_cv, 2), "\n") 
cat("  East states:", round(east_asymmetry$mean_cv, 2), "\n")

cat("\n=== ANALYSIS COMPLETE ===\n")