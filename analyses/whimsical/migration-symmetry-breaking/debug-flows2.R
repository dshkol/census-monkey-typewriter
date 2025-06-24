# Debug the actual flows data content
library(tidyverse)
library(tidycensus)

# Set API key
census_api_key(Sys.getenv("CENSUS_API_KEY"))

cat("=== DETAILED FLOWS DATA DEBUGGING ===\n")

# Get flows for one county
test_flows <- get_flows(
  geography = "county",
  state = "48",  # Texas
  county = "201", # Harris County
  year = 2022,
  output = "wide"
)

cat("Data dimensions:", nrow(test_flows), "x", ncol(test_flows), "\n")
cat("Column names and types:\n")
str(test_flows)

cat("\nFirst 10 rows:\n")
print(head(test_flows, 10))

# Check for non-NA values in different columns
cat("\nNon-NA counts by column:\n")
na_counts <- test_flows %>%
  summarise(across(everything(), ~ sum(!is.na(.))))
print(na_counts)

# Look at MOVEDIN vs MOVEDOUT
cat("\nMOVEDIN vs MOVEDOUT comparison:\n")
movement_summary <- test_flows %>%
  summarise(
    movedin_records = sum(!is.na(MOVEDIN)),
    movedout_records = sum(!is.na(MOVEDOUT)),
    movedin_total = sum(MOVEDIN, na.rm = T),
    movedout_total = sum(MOVEDOUT, na.rm = T)
  )
print(movement_summary)

# Show examples of non-NA records
if (sum(!is.na(test_flows$MOVEDIN)) > 0) {
  cat("\nSample MOVEDIN records:\n")
  movedin_examples <- test_flows %>%
    filter(!is.na(MOVEDIN), MOVEDIN > 0) %>%
    head(10) %>%
    select(GEOID1, GEOID2, FULL1_NAME, FULL2_NAME, MOVEDIN, MOVEDOUT)
  print(movedin_examples)
}

if (sum(!is.na(test_flows$MOVEDOUT)) > 0) {
  cat("\nSample MOVEDOUT records:\n") 
  movedout_examples <- test_flows %>%
    filter(!is.na(MOVEDOUT), MOVEDOUT > 0) %>%
    head(10) %>%
    select(GEOID1, GEOID2, FULL1_NAME, FULL2_NAME, MOVEDIN, MOVEDOUT)
  print(movedout_examples)
}