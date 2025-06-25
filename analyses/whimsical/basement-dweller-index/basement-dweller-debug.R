# Debug script to examine B09019 table structure
library(tidyverse)
library(tidycensus)

# Set API key
census_api_key(Sys.getenv("CENSUS_API_KEY"))

# Load variables to understand B09019 structure
acs_vars_2022 <- load_variables(2022, "acs5", cache = TRUE)

# Examine B09019 variables specifically
b09019_vars <- acs_vars_2022 %>%
  filter(str_detect(name, "^B09019")) %>%
  arrange(name)

cat("B09019 Table Structure:\n")
print(b09019_vars %>% select(name, label), n = 50)

# Get sample data to see structure
test_data <- get_acs(
  geography = "public use microdata area",
  table = "B09019", 
  state = "CA",
  year = 2022,
  survey = "acs5",
  geometry = FALSE,
  output = "wide"
)

cat("\nActual variables in dataset:\n")
b09019_cols <- names(test_data)[str_detect(names(test_data), "^B09019")]
cat(paste(b09019_cols, collapse = "\n"), "\n")

# Also check alternative tables for living arrangements
# Try S1101 - Households and Families
s1101_vars <- acs_vars_2022 %>%
  filter(str_detect(name, "^S1101")) %>%
  filter(str_detect(tolower(label), "child"))

cat("\nS1101 child-related variables:\n")
print(s1101_vars %>% select(name, label), n = 20)

# Test S1101
if(nrow(s1101_vars) > 0) {
  test_s1101 <- get_acs(
    geography = "public use microdata area",
    table = "S1101",
    state = "CA",
    year = 2022,
    survey = "acs5", 
    geometry = FALSE,
    output = "wide"
  )
  
  s1101_cols <- names(test_s1101)[str_detect(names(test_s1101), "^S1101")]
  cat("\nS1101 variables available:\n")
  cat(paste(s1101_cols[1:20], collapse = "\n"), "\n")
}