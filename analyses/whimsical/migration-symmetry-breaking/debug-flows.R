# Debug flows data structure
library(tidyverse)
library(tidycensus)

# Set API key
census_api_key(Sys.getenv("CENSUS_API_KEY"))

cat("=== DEBUGGING FLOWS DATA STRUCTURE ===\n")

# Get flows data for Texas
tx_flows <- get_flows(
  geography = "county",
  state = "TX",
  county = NULL,
  year = 2022,
  output = "wide"
)

cat("Raw data dimensions:", nrow(tx_flows), "rows x", ncol(tx_flows), "columns\n")
cat("Column names:", paste(names(tx_flows), collapse = ", "), "\n\n")

# Examine GEOID structure
cat("Sample GEOID1 values:\n")
print(head(unique(tx_flows$GEOID1), 10))
cat("\nSample GEOID2 values:\n") 
print(head(unique(tx_flows$GEOID2), 10))

# Check for Texas-to-Texas flows
cat("\nGEOID1 patterns:\n")
geoid1_patterns <- tx_flows %>%
  mutate(
    geoid1_state = str_sub(GEOID1, 1, 2),
    geoid1_length = nchar(GEOID1)
  ) %>%
  count(geoid1_state, geoid1_length, sort = TRUE)
print(geoid1_patterns)

cat("\nGEOID2 patterns:\n")
geoid2_patterns <- tx_flows %>%
  mutate(
    geoid2_state = str_sub(GEOID2, 1, 2),
    geoid2_length = nchar(GEOID2)
  ) %>%
  count(geoid2_state, geoid2_length, sort = TRUE)
print(geoid2_patterns)

# Look for actual flows between Texas counties
cat("\nLooking for TX-TX flows...\n")
tx_to_tx <- tx_flows %>%
  filter(
    str_detect(GEOID1, "^48"),  # TX origin
    str_detect(GEOID2, "^48")   # TX destination
  )

cat("TX-to-TX flows found:", nrow(tx_to_tx), "\n")

if (nrow(tx_to_tx) > 0) {
  cat("Sample TX-TX flows:\n")
  print(head(tx_to_tx))
} else {
  cat("No TX-TX flows found. Checking alternative patterns...\n")
  
  # Maybe GEOID2 doesn't have state prefix?
  alt_search <- tx_flows %>%
    filter(str_detect(GEOID1, "^48")) %>%
    head(20)
  
  cat("Sample flows from TX counties:\n")
  print(alt_search %>% select(GEOID1, GEOID2, FULL1_NAME, FULL2_NAME, MOVEDOUT))
}