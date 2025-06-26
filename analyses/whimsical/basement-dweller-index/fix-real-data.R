# Fix the basement dweller analysis with real Census data
# Testing what we can actually get from the API

library(tidyverse)
library(tidycensus)
library(sf)

# Test API availability and what we can realistically obtain
cat("Testing Census API access for real basement dweller data...\n")

# Test basic API functionality
tryCatch({
  # Try to get a small sample of real data
  test_acs <- get_acs(
    geography = "state",
    variables = "B25001_001",  # Total housing units (simple test)
    year = 2019,
    survey = "acs5"
  )
  
  cat("✓ Census API accessible\n")
  cat("✓ Basic ACS data retrieval working\n")
  
}, error = function(e) {
  cat("✗ Census API error:", e$message, "\n")
  stop("Cannot proceed without API access")
})

# Test what basement dweller variables are actually available
cat("\nTesting basement dweller variable availability...\n")

tryCatch({
  # Check if our target variables exist
  vars_2019 <- load_variables(2019, "acs5", cache = TRUE)
  
  # Look for living arrangement variables
  living_vars <- vars_2019 %>%
    filter(str_detect(concept, "LIVING|RELATIONSHIP|HOUSEHOLD"))
  
  cat("Found", nrow(living_vars), "living arrangement related variables\n")
  
  # Look specifically for our target variables
  target_vars <- c("B09021_001", "B09021_002", "B09021_021", "B09021_022")
  available_targets <- vars_2019 %>%
    filter(name %in% target_vars)
  
  cat("Target variables available:", nrow(available_targets), "of", length(target_vars), "\n")
  
  if(nrow(available_targets) > 0) {
    cat("Available target variables:\n")
    print(available_targets %>% select(name, label))
  }
  
}, error = function(e) {
  cat("✗ Variable lookup error:", e$message, "\n")
})

# Test small-scale real data retrieval
cat("\nTesting small-scale real data retrieval...\n")

tryCatch({
  # Try to get real data for a few states only
  real_test <- get_acs(
    geography = "state",
    variables = c(
      total_pop = "B01001_001",
      med_income = "B19013_001"
    ),
    year = 2019,
    survey = "acs5",
    output = "wide"
  )
  
  cat("✓ Real ACS data retrieved successfully\n")
  cat("  States retrieved:", nrow(real_test), "\n")
  cat("  Variables retrieved:", ncol(real_test) - 2, "\n")  # Subtract GEOID and NAME
  
  # Show we have real data with real margins of error
  cat("  Real MOE data available: Yes\n")
  cat("  Sample median income MOE:", round(mean(real_test$med_incomeM, na.rm = TRUE)), "\n")
  
}, error = function(e) {
  cat("✗ Real data retrieval error:", e$message, "\n")
})

cat("\n=== ASSESSMENT ===\n")
cat("The proper approach is to either:\n")
cat("1. Use real Census data even if limited in scope\n")
cat("2. If API prevents full analysis, clearly state limitations\n")
cat("3. NEVER create fake/simulated data to complete analysis\n")
cat("\nWe must fix the .Rmd file to use only real data or clearly mark as methodology demo.\n")