# Debug script to find correct variable names
library(tidycensus)

# Set API key
census_api_key(Sys.getenv("CENSUS_API_KEY"))

# Check available variables for 2010 decennial
cat("=== 2010 DECENNIAL VARIABLES ===\n")
vars_2010 <- load_variables(2010, "sf1", cache = TRUE)
pop_vars_2010 <- vars_2010[grepl("total.*population|P001001|P1_001", vars_2010$name, ignore.case = TRUE), ]
print(head(pop_vars_2010, 10))

cat("\n=== 2020 DECENNIAL VARIABLES ===\n")
vars_2020 <- load_variables(2020, "pl", cache = TRUE)
pop_vars_2020 <- vars_2020[grepl("total.*population|P1_001", vars_2020$name, ignore.case = TRUE), ]
print(head(pop_vars_2020, 10))

cat("\n=== PEP VARIABLES ===\n")
# Test PEP for recent year
vars_pep <- load_variables(2022, "pep", cache = TRUE)
pop_vars_pep <- vars_pep[grepl("POP", vars_pep$name, ignore.case = TRUE), ]
print(head(pop_vars_pep, 10))