# Working Migration Symmetry Breaking Analysis
# 
# Processing the flows data we successfully retrieved

library(tidyverse)
library(tidycensus)
library(scales)
library(ggplot2)

# Set API key
census_api_key(Sys.getenv("CENSUS_API_KEY"))

cat("=== MIGRATION SYMMETRY BREAKING ANALYSIS ===\n")
cat("Processing county-to-county flows to find asymmetric patterns\n\n")

# Get flows for major Texas counties
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

# Function to get flows for a specific county
get_county_flows <- function(county_geoid) {
  flows <- get_flows(
    geography = "county",
    state = str_sub(county_geoid, 1, 2),
    county = str_sub(county_geoid, 3, 5),
    year = 2022,
    output = "wide"
  )
  flows$origin_county <- county_geoid
  return(flows)
}

# Get all flows
cat("Collecting flows data...\n")
all_flows <- map_dfr(major_tx_counties, get_county_flows)

cat("Total flows collected:", nrow(all_flows), "\n")
cat("Columns:", paste(names(all_flows), collapse = ", "), "\n")

# Process flows data
cat("\nProcessing flows data for asymmetry analysis...\n")

flows_processed <- all_flows %>%
  # Focus on outbound flows that have destination info
  filter(!is.na(MOVEDOUT), MOVEDOUT > 0) %>%
  select(
    origin_geoid = origin_county,
    dest_geoid = GEOID2, 
    origin_name = FULL1_NAME,
    dest_name = FULL2_NAME,
    flow_volume = MOVEDOUT
  ) %>%
  # Clean destination names and codes
  mutate(
    origin_name = str_remove(origin_name, " County, Texas$"),
    dest_name = str_remove(dest_name, " County$"),
    dest_name = str_remove(dest_name, ", .*$"),  # Remove state suffix
    
    # Create destination type categories
    dest_type = case_when(
      str_length(dest_geoid) == 5 & str_starts(dest_geoid, "48") ~ "TX County",
      str_length(dest_geoid) == 3 ~ "Other State",
      dest_geoid %in% c("AFR", "ASI", "EUR", "NAM", "SAM", "OCE") ~ "International",
      TRUE ~ "Other"
    ),
    
    # For state-level destinations, map codes to names
    dest_state = case_when(
      dest_geoid == "001" ~ "Alabama",
      dest_geoid == "004" ~ "Arizona", 
      dest_geoid == "005" ~ "Arkansas",
      dest_geoid == "006" ~ "California",
      dest_geoid == "008" ~ "Colorado",
      dest_geoid == "009" ~ "Connecticut",
      dest_geoid == "010" ~ "Delaware",
      dest_geoid == "012" ~ "Florida",
      dest_geoid == "013" ~ "Georgia",
      dest_geoid == "015" ~ "Hawaii",
      dest_geoid == "016" ~ "Idaho",
      dest_geoid == "017" ~ "Illinois",
      dest_geoid == "018" ~ "Indiana",
      dest_geoid == "019" ~ "Iowa",
      dest_geoid == "020" ~ "Kansas",
      dest_geoid == "021" ~ "Kentucky",
      dest_geoid == "022" ~ "Louisiana",
      dest_geoid == "023" ~ "Maine",
      dest_geoid == "024" ~ "Maryland",
      dest_geoid == "025" ~ "Massachusetts",
      dest_geoid == "026" ~ "Michigan",
      dest_geoid == "027" ~ "Minnesota", 
      dest_geoid == "028" ~ "Mississippi",
      dest_geoid == "029" ~ "Missouri",
      dest_geoid == "030" ~ "Montana",
      dest_geoid == "031" ~ "Nebraska",
      dest_geoid == "032" ~ "Nevada",
      dest_geoid == "033" ~ "New Hampshire",
      dest_geoid == "034" ~ "New Jersey",
      dest_geoid == "035" ~ "New Mexico",
      dest_geoid == "036" ~ "New York",
      dest_geoid == "037" ~ "North Carolina",
      dest_geoid == "038" ~ "North Dakota",
      dest_geoid == "039" ~ "Ohio",
      dest_geoid == "040" ~ "Oklahoma",
      dest_geoid == "041" ~ "Oregon",
      dest_geoid == "042" ~ "Pennsylvania",
      dest_geoid == "044" ~ "Rhode Island",
      dest_geoid == "045" ~ "South Carolina",
      dest_geoid == "046" ~ "South Dakota",
      dest_geoid == "047" ~ "Tennessee",
      dest_geoid == "049" ~ "Utah",
      dest_geoid == "050" ~ "Vermont",
      dest_geoid == "051" ~ "Virginia",
      dest_geoid == "053" ~ "Washington",
      dest_geoid == "054" ~ "West Virginia",
      dest_geoid == "055" ~ "Wisconsin",
      dest_geoid == "056" ~ "Wyoming",
      TRUE ~ dest_name
    )
  )

cat("Processed flows:", nrow(flows_processed), "\n")

# Analyze destination patterns
dest_summary <- flows_processed %>%
  group_by(dest_type) %>%
  summarise(
    n_flows = n(),
    total_migrants = sum(flow_volume),
    avg_flow = mean(flow_volume),
    .groups = "drop"
  ) %>%
  arrange(desc(total_migrants))

cat("\nFlow patterns by destination type:\n")
print(dest_summary)

# Focus on state-to-state flows for asymmetry analysis
state_flows <- flows_processed %>%
  filter(dest_type == "Other State", !is.na(dest_state)) %>%
  group_by(origin_name, dest_state) %>%
  summarise(
    outbound_flow = sum(flow_volume),
    .groups = "drop"
  )

cat("\nState-level outbound flows:", nrow(state_flows), "\n")

# Top destination states from Texas metros
top_destinations <- state_flows %>%
  group_by(dest_state) %>%
  summarise(
    total_from_tx = sum(outbound_flow),
    n_counties = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(total_from_tx)) %>%
  head(15)

cat("\nTop destination states from Texas metros:\n")
print(top_destinations)

# For asymmetry analysis, we need bidirectional flows
# Let's analyze the patterns we can see in outbound flows

# Which Texas counties are most different in their destination preferences?
county_preferences <- state_flows %>%
  group_by(origin_name) %>%
  mutate(
    total_out = sum(outbound_flow),
    pct_to_dest = outbound_flow / total_out
  ) %>%
  filter(pct_to_dest >= 0.05) %>%  # Focus on significant flows (5%+)
  arrange(origin_name, desc(pct_to_dest))

cat("\nMajor destination preferences by Texas county (5%+ of outbound flow):\n")
print(county_preferences %>% 
      select(origin_name, dest_state, outbound_flow, pct_to_dest) %>%
      mutate(pct_to_dest = percent(pct_to_dest, accuracy = 1)))

# Analyze asymmetric preferences
# Which states show very uneven attraction to different TX counties?

state_asymmetry <- state_flows %>%
  group_by(dest_state) %>%
  summarise(
    total_flow = sum(outbound_flow),
    n_counties = n(),
    max_flow = max(outbound_flow),
    min_flow = min(outbound_flow),
    flow_range = max_flow - min_flow,
    coefficient_variation = sd(outbound_flow) / mean(outbound_flow),
    .groups = "drop"
  ) %>%
  filter(total_flow >= 100, n_counties >= 3) %>%  # Meaningful sample
  arrange(desc(coefficient_variation))

cat("\nStates with most asymmetric attraction to TX counties:\n")
print(state_asymmetry %>% 
      select(dest_state, total_flow, coefficient_variation, max_flow, min_flow) %>%
      head(10))

# Identify specific asymmetric patterns
cat("\n=== SPECIFIC ASYMMETRIC PATTERNS ===\n")

# Find county-state pairs with unusually high flows
high_flow_pairs <- state_flows %>%
  group_by(dest_state) %>%
  mutate(
    mean_flow_to_state = mean(outbound_flow),
    flow_deviation = outbound_flow - mean_flow_to_state,
    flow_ratio = outbound_flow / mean_flow_to_state
  ) %>%
  filter(flow_ratio >= 2, outbound_flow >= 50) %>%  # At least 2x average and meaningful volume
  arrange(desc(flow_ratio)) %>%
  ungroup()

cat("County-state pairs with disproportionately high flows:\n")
print(high_flow_pairs %>% 
      select(origin_name, dest_state, outbound_flow, flow_ratio) %>%
      mutate(flow_ratio = round(flow_ratio, 1)) %>%
      head(15))

# Create visualizations
cat("\n=== CREATING VISUALIZATIONS ===\n")

# Plot 1: Flow distribution by destination type
p1 <- dest_summary %>%
  ggplot(aes(x = reorder(dest_type, total_migrants), y = total_migrants)) +
  geom_col(fill = "grey20", alpha = 0.7) +
  coord_flip() +
  scale_y_continuous(labels = comma_format()) +
  labs(
    title = "Migration Outflows from Major Texas Counties",
    subtitle = "Total migrants by destination type, 2022",
    x = "Destination Type",
    y = "Total Migrants"
  ) +
  theme_minimal()

print(p1)

# Plot 2: Top destination states
p2 <- top_destinations %>%
  head(10) %>%
  ggplot(aes(x = reorder(dest_state, total_from_tx), y = total_from_tx)) +
  geom_col(fill = "grey20", alpha = 0.7) +
  coord_flip() +
  scale_y_continuous(labels = comma_format()) +
  labs(
    title = "Top Destination States from Texas Metro Counties",
    subtitle = "Total outbound migration, 2022",
    x = "Destination State",
    y = "Total Migrants"
  ) +
  theme_minimal()

print(p2)

# Plot 3: Asymmetry in state preferences
p3 <- state_asymmetry %>%
  head(10) %>%
  ggplot(aes(x = reorder(dest_state, coefficient_variation), y = coefficient_variation)) +
  geom_col(fill = "grey20", alpha = 0.7) +
  coord_flip() +
  labs(
    title = "Most Asymmetric State Destinations",
    subtitle = "States with highest variation in attraction to different TX counties",
    x = "Destination State",
    y = "Coefficient of Variation"
  ) +
  theme_minimal()

print(p3)

# Summary insights
cat("\n=== SUMMARY INSIGHTS ===\n")
cat("Total processed flows:", nrow(flows_processed), "\n")
cat("Major destination types:\n")
for (i in 1:nrow(dest_summary)) {
  cat("  ", dest_summary$dest_type[i], ":", comma(dest_summary$total_migrants[i]), "migrants\n")
}

cat("\nMost asymmetric state destinations (highest variation):\n")
for (i in 1:min(5, nrow(state_asymmetry))) {
  cat("  ", state_asymmetry$dest_state[i], 
      "- CV:", round(state_asymmetry$coefficient_variation[i], 2), "\n")
}

cat("\nMost disproportionate county-state flows:\n")
for (i in 1:min(5, nrow(high_flow_pairs))) {
  cat("  ", high_flow_pairs$origin_name[i], "→", high_flow_pairs$dest_state[i],
      ":", comma(high_flow_pairs$outbound_flow[i]), "migrants",
      "(", round(high_flow_pairs$flow_ratio[i], 1), "x average)\n")
}

cat("\n=== ANALYSIS COMPLETE ===\n")