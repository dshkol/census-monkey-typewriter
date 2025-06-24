# Simple Migration Symmetry Breaking Analysis
# 
# Using a different approach - get migration data and identify asymmetric patterns

library(tidyverse)
library(tidycensus)
library(scales)
library(ggplot2)

# Set API key
census_api_key(Sys.getenv("CENSUS_API_KEY"))

cat("=== SIMPLE MIGRATION SYMMETRY ANALYSIS ===\n")
cat("Finding asymmetric migration patterns using ACS migration tables\n\n")

# Alternative approach: Use ACS geographic mobility data
# This gives us migration by origin, we can compare patterns

# Get migration data for a manageable set of counties - major Texas metros
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
county_names <- get_acs(
  geography = "county",
  variables = "B01003_001",
  year = 2022,
  output = "wide"
) %>%
  filter(GEOID %in% major_tx_counties) %>%
  select(GEOID, NAME) %>%
  mutate(
    county_name = str_remove(NAME, " County, Texas$"),
    county_name = str_remove(county_name, ", Texas$")
  )

print(county_names)

# Get flows data for these specific counties
cat("\nGetting migration flows for major Texas counties...\n")

# Function to get flows for a specific county
get_county_flows <- function(county_geoid) {
  cat("Getting flows for county", county_geoid, "...\n")
  
  tryCatch({
    flows <- get_flows(
      geography = "county",
      state = str_sub(county_geoid, 1, 2),  # State FIPS
      county = str_sub(county_geoid, 3, 5), # County FIPS (last 3 digits)
      year = 2022,
      output = "wide"
    )
    
    # Add origin county identifier
    flows$origin_county <- county_geoid
    return(flows)
  }, error = function(e) {
    cat("Error getting flows for", county_geoid, ":", e$message, "\n")
    return(NULL)
  })
}

# Get flows for all major counties
all_flows <- map_dfr(major_tx_counties, get_county_flows)

if (nrow(all_flows) == 0) {
  cat("No flows data available. Switching to alternative approach...\n")
  
  # Alternative: Analyze migration patterns using ACS migration tables
  cat("Using ACS geographic mobility tables instead...\n")
  
  # Get migration data by origin state for Texas counties
  tx_migration <- get_acs(
    geography = "county",
    state = "TX",
    variables = c(
      total_pop = "B07001_001",      # Total population
      same_county = "B07001_017",    # Same county
      diff_county_same_state = "B07001_033", # Different county same state  
      diff_state = "B07001_049",     # Different state
      abroad = "B07001_065"          # From abroad
    ),
    year = 2022,
    output = "wide"
  ) %>%
    filter(GEOID %in% major_tx_counties) %>%
    mutate(
      county_name = str_remove(NAME, " County, Texas$"),
      county_name = str_remove(county_name, ", Texas$"),
      
      # Calculate percentages
      pct_same_county = same_countyE / total_popE,
      pct_diff_county_same_state = diff_county_same_stateE / total_popE,
      pct_diff_state = diff_stateE / total_popE,
      pct_abroad = abroadE / total_popE,
      
      # Calculate mobility index
      mobility_index = 1 - pct_same_county  # Higher = more mobile
    ) %>%
    arrange(desc(mobility_index))
  
  cat("Migration mobility patterns for major TX counties:\n")
  migration_summary <- tx_migration %>%
    select(county_name, total_popE, pct_same_county, pct_diff_county_same_state, 
           pct_diff_state, mobility_index) %>%
    mutate(
      pct_same_county = percent(pct_same_county, accuracy = 1),
      pct_diff_county_same_state = percent(pct_diff_county_same_state, accuracy = 1),
      pct_diff_state = percent(pct_diff_state, accuracy = 1),
      mobility_index = round(mobility_index, 3),
      total_popE = comma(total_popE)
    )
  
  print(migration_summary)
  
  # Now get state-to-state migration flows for Texas
  cat("\nAnalyzing asymmetric state-to-state flows involving Texas...\n")
  
  # Get flows TO Texas from other states
  flows_to_tx <- get_flows(
    geography = "state",
    state = "TX",
    year = 2022,
    output = "wide"
  ) %>%
    filter(!is.na(MOVEDIN), MOVEDIN > 0) %>%
    select(origin_code = GEOID2, dest_name = FULL1_NAME, flow_to_tx = MOVEDIN) %>%
    mutate(dest_state = "TX")
  
  cat("Flows TO Texas from other states:", nrow(flows_to_tx), "\n")
  
  # Get flows FROM Texas to other states  
  flows_from_tx <- get_flows(
    geography = "state", 
    state = "TX",
    year = 2022,
    output = "wide"
  ) %>%
    filter(!is.na(MOVEDOUT), MOVEDOUT > 0) %>%
    select(dest_code = GEOID2, origin_name = FULL1_NAME, flow_from_tx = MOVEDOUT) %>%
    mutate(origin_state = "TX")
  
  cat("Flows FROM Texas to other states:", nrow(flows_from_tx), "\n")
  
  # Compare bidirectional flows
  if (nrow(flows_to_tx) > 0 & nrow(flows_from_tx) > 0) {
    
    # Match up bidirectional flows
    bidirectional_flows <- flows_to_tx %>%
      full_join(flows_from_tx, by = c("origin_code" = "dest_code")) %>%
      filter(!is.na(flow_to_tx), !is.na(flow_from_tx)) %>%
      mutate(
        # Calculate asymmetry
        total_flow = flow_to_tx + flow_from_tx,
        asymmetry_index = (flow_to_tx - flow_from_tx) / total_flow,
        abs_asymmetry = abs(asymmetry_index),
        
        # Determine dominant direction
        dominant_direction = case_when(
          flow_to_tx > flow_from_tx ~ paste("TO Texas from", origin_code),
          flow_from_tx > flow_to_tx ~ paste("FROM Texas to", origin_code),
          TRUE ~ "Symmetric"
        ),
        
        flow_ratio = pmax(flow_to_tx, flow_from_tx) / pmin(flow_to_tx, flow_from_tx)
      ) %>%
      arrange(desc(abs_asymmetry))
    
    cat("\nMost asymmetric state-to-state flows with Texas:\n")
    top_asymmetric_states <- bidirectional_flows %>%
      head(10) %>%
      select(origin_code, flow_to_tx, flow_from_tx, asymmetry_index, dominant_direction) %>%
      mutate(
        flow_to_tx = comma(flow_to_tx),
        flow_from_tx = comma(flow_from_tx),
        asymmetry_index = round(asymmetry_index, 3)
      )
    
    print(top_asymmetric_states)
    
    # Summary statistics
    cat("\nAsymmetry summary statistics:\n")
    cat("Mean absolute asymmetry:", round(mean(bidirectional_flows$abs_asymmetry), 3), "\n")
    cat("Highly asymmetric flows (>80%):", sum(bidirectional_flows$abs_asymmetry > 0.8), "\n")
    cat("Moderately asymmetric flows (50-80%):", 
        sum(bidirectional_flows$abs_asymmetry > 0.5 & bidirectional_flows$abs_asymmetry <= 0.8), "\n")
    cat("Roughly symmetric flows (<20%):", sum(bidirectional_flows$abs_asymmetry < 0.2), "\n")
    
    # Create visualization
    p1 <- bidirectional_flows %>%
      ggplot(aes(x = asymmetry_index)) +
      geom_histogram(bins = 20, fill = "grey20", alpha = 0.7) +
      geom_vline(xintercept = 0, color = "red", linetype = "dashed") +
      scale_x_continuous(limits = c(-1, 1)) +
      labs(
        title = "State-to-State Migration Flow Asymmetry with Texas",
        subtitle = "-1 = all flow FROM Texas, +1 = all flow TO Texas, 0 = symmetric",
        x = "Asymmetry Index",
        y = "Count of States"
      ) +
      theme_minimal()
    
    print(p1)
    
    # Flow magnitude vs asymmetry
    p2 <- bidirectional_flows %>%
      ggplot(aes(x = log10(total_flow), y = abs_asymmetry)) +
      geom_point(alpha = 0.6, size = 3, color = "grey20") +
      geom_smooth(method = "lm", color = "red") +
      labs(
        title = "Flow Volume vs. Asymmetry",
        subtitle = "Relationship between total migration volume and flow imbalance",
        x = "Log Total Flow Volume", 
        y = "Absolute Asymmetry"
      ) +
      theme_minimal()
    
    print(p2)
    
    # Test specific hypotheses
    cat("\n=== HYPOTHESIS TESTING ===\n")
    
    # Look for geographic patterns
    geographic_patterns <- bidirectional_flows %>%
      mutate(
        state_region = case_when(
          origin_code %in% c("06", "04", "32", "49", "35", "08", "56", "30", "16", "53", "41", "02") ~ "West",
          origin_code %in% c("17", "18", "19", "20", "26", "27", "29", "31", "38", "39", "46", "55") ~ "Midwest", 
          origin_code %in% c("09", "23", "25", "33", "34", "36", "42", "44", "50") ~ "Northeast",
          origin_code %in% c("01", "05", "10", "11", "12", "13", "21", "22", "24", "28", "37", "40", "45", "47", "51", "54") ~ "South",
          TRUE ~ "Other"
        )
      ) %>%
      group_by(state_region) %>%
      summarise(
        n = n(),
        mean_asymmetry = mean(asymmetry_index),
        .groups = "drop"
      ) %>%
      arrange(desc(mean_asymmetry))
    
    cat("Asymmetry by US region:\n")
    print(geographic_patterns)
    
  } else {
    cat("Could not find sufficient bidirectional flow data.\n")
  }
  
} else {
  cat("Successfully retrieved", nrow(all_flows), "flow records\n")
  # Process the flows data here if we got it
}

cat("\n=== ANALYSIS COMPLETE ===\n")