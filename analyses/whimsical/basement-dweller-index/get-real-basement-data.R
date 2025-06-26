# Get real basement dweller data to replace the simulated data

library(tidyverse)
library(tidycensus)
library(sf)

cat("Getting real basement dweller data from Census API...\n")

# First, let's look for the correct variables for young adults living with parents
vars_2019 <- load_variables(2019, "acs5", cache = TRUE)

# Search for variables related to living arrangements and age
living_age_vars <- vars_2019 %>%
  filter(str_detect(label, "living|Living|LIVING") | 
         str_detect(concept, "LIVING|RELATIONSHIP")) %>%
  filter(str_detect(label, "25|30|35|parent|Parent")) %>%
  arrange(name)

cat("Variables related to young adults and living arrangements:\n")
print(living_age_vars %>% select(name, label) %>% head(10))

# Let's look at B09021 - Living Arrangements table more specifically  
b09021_vars <- vars_2019 %>%
  filter(str_starts(name, "B09021")) %>%
  arrange(name)

cat("\nB09021 Living Arrangements variables:\n")
print(b09021_vars %>% select(name, label))

# Try to get real data for a manageable scope - let's start with a few states
# We'll focus on states with diverse housing markets

cat("\nAttempting to get real data for select states...\n")

# Key variables for our analysis:
basement_vars <- c(
  "B09021_001",  # Total population
  "B25077_001",  # Median home value  
  "B25064_001",  # Median gross rent
  "B23025_005"   # Unemployment
)

tryCatch({
  # Get data for states with diverse housing markets
  real_data <- get_acs(
    geography = "state", 
    variables = basement_vars,
    year = 2019,
    survey = "acs5",
    output = "wide"
  )
  
  cat("✓ Successfully retrieved real data for", nrow(real_data), "states\n")
  
  # Clean the data
  real_data_clean <- real_data %>%
    select(GEOID, NAME, 
           total_pop = B09021_001E, total_pop_moe = B09021_001M,
           median_home_value = B25077_001E, home_value_moe = B25077_001M,
           median_rent = B25064_001E, rent_moe = B25064_001M,
           unemployment = B23025_005E, unemployment_moe = B23025_005M) %>%
    filter(!is.na(median_home_value), !is.na(median_rent)) %>%
    mutate(
      housing_cost_index = scale(log(median_home_value + 1) + log(median_rent + 1))[,1],
      unemployment_rate = unemployment / total_pop * 100
    )
  
  cat("✓ Data cleaned, final dataset:", nrow(real_data_clean), "states\n")
  
  # Save for use in .Rmd
  saveRDS(real_data_clean, "real_basement_data.rds")
  cat("✓ Real data saved to real_basement_data.rds\n")
  
  # Show summary
  cat("\nReal data summary:\n")
  cat("Median home values: $", round(median(real_data_clean$median_home_value, na.rm = TRUE)), 
      " (range: $", round(min(real_data_clean$median_home_value, na.rm = TRUE)), 
      " - $", round(max(real_data_clean$median_home_value, na.rm = TRUE)), ")\n")
  cat("Median rents: $", round(median(real_data_clean$median_rent, na.rm = TRUE)), 
      " (range: $", round(min(real_data_clean$median_rent, na.rm = TRUE)), 
      " - $", round(max(real_data_clean$median_rent, na.rm = TRUE)), ")\n")
  
}, error = function(e) {
  cat("✗ Error getting real data:", e$message, "\n")
})

# Now let's try to get the actual basement dweller data
# We need to look for variables about adults living with parents

# Check PUMS variables which might have this data
cat("\nChecking PUMS variables for living with parents data...\n")

tryCatch({
  pums_vars <- pums_variables %>%
    filter(year == 2019, survey == "acs5") %>%
    filter(str_detect(var_label, "relationship|Relationship|RELATIONSHIP|parent|Parent")) %>%
    head(20)
  
  if(nrow(pums_vars) > 0) {
    cat("PUMS relationship variables found:\n")
    print(pums_vars %>% select(var_code, var_label))
  }
  
}, error = function(e) {
  cat("PUMS variables not readily available, continuing with available data\n")
})

cat("\n=== CONCLUSION ===\n")
cat("We have real Census data for housing costs and basic demographics.\n")
cat("For the basement dweller variable itself, we need to either:\n")
cat("1. Use a proxy from available variables\n") 
cat("2. Try PUMS data for direct measurement\n")
cat("3. Clearly state the limitation and focus on methodology\n")
cat("\nThe key is to use ONLY real data, not simulated data.\n")