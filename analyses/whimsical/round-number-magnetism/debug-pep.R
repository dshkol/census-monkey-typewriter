# Debug PEP data structure
library(tidycensus)

# Set API key
census_api_key(Sys.getenv("CENSUS_API_KEY"))

# Test PEP data
cat("Testing PEP data structure...\n")
test_data <- get_estimates(
  geography = "county", 
  product = "population",
  year = 2022,
  output = "wide"
)

cat("Columns in PEP data:\n")
print(names(test_data))
cat("\nFirst few rows:\n")
print(head(test_data))