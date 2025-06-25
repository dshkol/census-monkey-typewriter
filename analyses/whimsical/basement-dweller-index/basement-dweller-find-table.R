# Find the right table for relationship by age analysis
library(tidyverse)
library(tidycensus)

# Set API key
census_api_key(Sys.getenv("CENSUS_API_KEY"))

# Load all ACS variables
acs_vars_2022 <- load_variables(2022, "acs5", cache = TRUE)

# Search for tables that might have relationship by age
cat("Searching for tables with relationship and age...\n")

# Look for tables with both "relationship" and "age" in concept
relationship_age_tables <- acs_vars_2022 %>%
  filter(str_detect(tolower(concept), "relationship") | str_detect(tolower(concept), "household")) %>%
  filter(str_detect(tolower(concept), "age") | str_detect(tolower(label), "age")) %>%
  distinct(concept) %>%
  arrange(concept)

cat("Tables with relationship and age:\n")
print(relationship_age_tables)

# Look more broadly for living arrangements
living_arrangement_tables <- acs_vars_2022 %>%
  filter(str_detect(tolower(concept), "living|household|family") & 
         str_detect(tolower(concept), "age|year")) %>%
  distinct(concept) %>%
  arrange(concept)

cat("\nTables with living arrangements and age:\n")
print(living_arrangement_tables)

# Let's look at specific B tables that might work
b_tables_age <- acs_vars_2022 %>%
  filter(str_detect(name, "^B") & str_detect(tolower(label), "child|son|daughter")) %>%
  filter(str_detect(tolower(label), "25|30|35|age")) %>%
  distinct(concept) %>%
  arrange(concept)

cat("\nB tables with child/age references:\n")
print(b_tables_age)

# Check B09021 specifically - it might be household relationship by age
b09021_vars <- acs_vars_2022 %>%
  filter(str_detect(name, "^B09021")) %>%
  arrange(name)

cat("\nB09021 variables:\n")
print(b09021_vars %>% select(name, label, concept), n = 30)

# Let's also check for "grandparent" tables which might indicate multi-generational living
grandparent_vars <- acs_vars_2022 %>%
  filter(str_detect(tolower(label), "grandparent|grandchild")) %>%
  distinct(concept)

cat("\nGrandparent-related concepts:\n") 
print(grandparent_vars)

# Try detailed tables  
detailed_vars <- acs_vars_2022 %>%
  filter(str_detect(name, "^B09") | str_detect(name, "^B11") | str_detect(name, "^B25")) %>%
  filter(str_detect(tolower(label), "child") | str_detect(tolower(concept), "relationship")) %>%
  distinct(concept) %>%
  arrange(concept)

cat("\nDetailed B09/B11/B25 concepts:\n")
print(detailed_vars)

# Let's try B11005 - Households by presence of people
b11005_vars <- acs_vars_2022 %>%
  filter(str_detect(name, "^B11005")) %>%
  arrange(name)

if(nrow(b11005_vars) > 0) {
  cat("\nB11005 variables:\n")
  print(b11005_vars %>% select(name, label), n = 20)
}

# Check for ACS data profiles with household composition
dp_household_vars <- acs_vars_2022 %>%
  filter(str_detect(name, "^DP02") | str_detect(name, "^S1101")) %>%
  filter(str_detect(tolower(label), "child|live|adult")) %>%
  arrange(name)

cat("\nData Profile household variables:\n")
print(dp_household_vars %>% select(name, label), n = 15)