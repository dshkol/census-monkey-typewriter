# Debug Great Dispersion Analysis
# Testing PEP data availability and ACS occupation tables

library(tidyverse)
library(tidycensus)

census_api_key(Sys.getenv("CENSUS_API_KEY"))

cat("=== DEBUGGING PEP AND ACS DATA ===\n")

# Test 1: Check PEP data availability with vintage parameter
cat("Testing PEP data with vintage parameter...\n")

# Try different approaches to get recent PEP data
test_pep_2023 <- tryCatch({
  get_estimates(
    geography = "county", 
    product = "population",
    vintage = 2023,
    year = 2023,
    state = "06"  # Test with California only
  )
}, error = function(e) {
  cat("Error with vintage 2023:", e$message, "\n")
  NULL
})

if (!is.null(test_pep_2023)) {
  cat("PEP 2023 data available with vintage parameter\n")
  cat("Sample counties:", nrow(test_pep_2023), "\n")
} else {
  cat("PEP 2023 not available\n")
}

# Test 2: Check ACS occupation variables
cat("\nTesting ACS occupation variables...\n")

# Load variables to see what's available
occupation_vars <- load_variables(2022, "acs5", cache = TRUE) %>%
  filter(str_detect(name, "^B24010"))

cat("Available B24010 variables:", nrow(occupation_vars), "\n")
if (nrow(occupation_vars) > 0) {
  cat("Sample variables:\n")
  print(head(occupation_vars, 10))
}

# Test simpler occupation approach
cat("\nTesting simplified occupation data...\n")
test_occupation <- tryCatch({
  get_acs(
    geography = "county",
    variables = c(
      "B24010_001",  # Total
      "B24010_002",  # Male
      "B24010_003"   # Management, business, science, and arts occupations - Male
    ),
    year = 2022,
    state = "06",
    output = "wide"
  )
}, error = function(e) {
  cat("Error with occupation data:", e$message, "\n")
  NULL
})

if (!is.null(test_occupation)) {
  cat("ACS occupation data available\n")
  cat("Sample records:", nrow(test_occupation), "\n")
} else {
  cat("ACS occupation data not available\n")
}

# Test 3: Alternative remote work proxy using education
cat("\nTesting education as remote work proxy...\n")
test_education <- tryCatch({
  get_acs(
    geography = "county",
    variables = c(
      "B15003_001",  # Total population 25+
      "B15003_022",  # Bachelor's degree
      "B15003_023",  # Master's degree
      "B15003_024",  # Professional degree
      "B15003_025"   # Doctorate
    ),
    year = 2022,
    state = "06",
    output = "wide"
  )
}, error = function(e) {
  cat("Error with education data:", e$message, "\n")
  NULL
})

if (!is.null(test_education)) {
  cat("Education data available as remote work proxy\n")
  cat("Sample records:", nrow(test_education), "\n")
}

# Test 4: Check available PEP years and vintages
cat("\nExploring available PEP years...\n")

# Test different years 
pep_test_years <- c(2020, 2021, 2022, 2023)
for (year in pep_test_years) {
  result <- tryCatch({
    get_estimates(
      geography = "county",
      product = "population", 
      vintage = year,
      year = year,
      state = "06"
    )
  }, error = function(e) {
    NULL
  })
  
  if (!is.null(result)) {
    cat("PEP", year, "available (vintage", year, ") -", nrow(result), "records\n")
  } else {
    cat("PEP", year, "not available\n")
  }
}