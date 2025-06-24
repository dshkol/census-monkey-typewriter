# Debug PEP data collection issues

library(tidyverse)
library(tidycensus)

census_api_key(Sys.getenv("CENSUS_API_KEY"))

cat("=== DEBUGGING PEP DATA COLLECTION ===\n")

# Test individual years
years_to_test <- c(2019, 2020, 2021, 2022, 2023)

for (year in years_to_test) {
  cat("\n--- Testing", year, "---\n")
  
  # Try old method
  result1 <- tryCatch({
    data <- get_estimates(
      geography = "county",
      product = "population",
      year = year,
      state = "06"  # California only for speed
    )
    cat("Old method success:", nrow(data), "records\n")
    data
  }, error = function(e) {
    cat("Old method failed:", e$message, "\n")
    NULL
  })
  
  # Try new method with vintage
  result2 <- tryCatch({
    data <- get_estimates(
      geography = "county",
      product = "population",
      vintage = year,
      year = year,
      state = "06"
    )
    cat("New method success:", nrow(data), "records\n")
    data
  }, error = function(e) {
    cat("New method failed:", e$message, "\n")
    NULL
  })
  
  # Check what variables are available
  if (!is.null(result1) || !is.null(result2)) {
    data <- if (!is.null(result2)) result2 else result1
    cat("Available variables:", paste(unique(data$variable), collapse = ", "), "\n")
  }
}

# Check what PEP years are actually available
cat("\n=== COMPREHENSIVE PEP AVAILABILITY TEST ===\n")

# Test different vintage/year combinations
vintage_years <- 2019:2023
data_years <- 2019:2023

pep_availability <- tibble()

for (vintage in vintage_years) {
  for (data_year in data_years) {
    result <- tryCatch({
      data <- get_estimates(
        geography = "county",
        product = "population",
        vintage = vintage,
        year = data_year,
        state = "06"
      )
      if (nrow(data) > 0) {
        tibble(vintage = vintage, data_year = data_year, records = nrow(data), success = TRUE)
      } else {
        tibble(vintage = vintage, data_year = data_year, records = 0, success = FALSE)
      }
    }, error = function(e) {
      tibble(vintage = vintage, data_year = data_year, records = 0, success = FALSE)
    })
    
    pep_availability <- bind_rows(pep_availability, result)
  }
}

cat("PEP data availability matrix:\n")
print(pep_availability %>% arrange(vintage, data_year))

# Try getting just the most recent data to verify it works
cat("\n=== TESTING RECENT SINGLE YEAR ===\n")
test_2023 <- tryCatch({
  get_estimates(
    geography = "county",
    product = "population",
    vintage = 2023,
    year = 2023
  ) %>%
    filter(variable == "POP") %>%
    head()
}, error = function(e) {
  cat("Error:", e$message, "\n")
  NULL
})

if (!is.null(test_2023)) {
  cat("Successfully retrieved 2023 data:\n")
  print(test_2023)
}