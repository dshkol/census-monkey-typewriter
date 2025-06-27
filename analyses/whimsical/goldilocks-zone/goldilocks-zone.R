# The Goldilocks Zone: Finding America's Most Average Counties
# A Philosophical Investigation of American Demographic Identity
# Working R script for development and testing

# Load required libraries
library(tidyverse)
library(tidycensus)
library(sf)
library(tigris)
library(scales)
library(viridis)
library(broom)
library(corrplot)
library(MASS)
library(cluster)
library(factoextra)
library(ggforce)
library(patchwork)
library(ggradar)
library(plotly)
library(DT)

# Set Census API key and options
options(tigris_use_cache = TRUE)

# Load variables for 2022 ACS 5-year estimates
vars_2022 <- load_variables(2022, "acs5", cache = TRUE)

# Define comprehensive variable list for demographic analysis
goldilocks_vars <- c(
  # Age and Sex (B01001)
  "B01001_001", # Total population
  "B01001_002", # Male
  "B01001_026", # Female  
  "B01001_020", # Female 65-66 years (proxy for median age)
  
  # Race and Ethnicity (B03002)
  "B03002_003", # White alone, not Hispanic
  "B03002_004", # Black alone, not Hispanic
  "B03002_006", # Asian alone, not Hispanic
  "B03002_012", # Hispanic or Latino
  
  # Educational Attainment (B15003 - 25 years and over)
  "B15003_001", # Total 25+
  "B15003_017", # High school graduate
  "B15003_022", # Bachelor's degree
  "B15003_023", # Master's degree
  
  # Income (B19013, B19001)
  "B19013_001", # Median household income
  "B19001_001", # Total households (for income distribution)
  "B19001_002", # Less than $10,000
  "B19001_017", # $200,000 or more
  
  # Employment Status (B23025)
  "B23025_001", # Total civilian labor force 16+
  "B23025_002", # In labor force
  "B23025_005", # Unemployed
  
  # Commuting (B08301)
  "B08301_001", # Total workers 16+
  "B08301_010", # Public transportation
  "B08301_021", # Worked from home
  
  # Housing (B25001, B25003, B25077)
  "B25001_001", # Total housing units
  "B25003_002", # Owner occupied
  "B25003_003", # Renter occupied
  "B25077_001", # Median home value
  
  # Poverty (B17001)
  "B17001_001", # Total for poverty determination
  "B17001_002", # Below poverty level
  
  # Household Type (B11001)
  "B11001_001", # Total households
  "B11001_002", # Family households
  "B11001_007", # Nonfamily households
  
  # Language (B16001)
  "B16001_001", # Total 5 years and over
  "B16001_002", # English only
  "B16001_003", # Spanish
  
  # Disability (B18101)
  "B18101_001", # Total civilian noninstitutionalized population
  "B18101_004", # With a disability
  
  # Health Insurance (B27001)
  "B27001_001", # Total civilian noninstitutionalized population
  "B27001_004", # With health insurance coverage
  
  # Veteran Status (B21001)
  "B21001_001", # Total civilian population 18+
  "B21001_002", # Veteran
  
  # Migration (B07001)
  "B07001_001", # Total 1 year and over
  "B07001_017", # Moved from different state
  
  # Industry (B24080 - major categories)
  "B24080_001", # Total civilian employed population 16+
  "B24080_002", # Agriculture, forestry, fishing, hunting, mining
  "B24080_003", # Construction
  "B24080_004", # Manufacturing
  "B24080_005", # Wholesale trade
  "B24080_006", # Retail trade
  "B24080_007", # Transportation, warehousing, utilities
  "B24080_008", # Information
  "B24080_009", # Finance, insurance, real estate, rental, leasing
  "B24080_010", # Professional, scientific, management, administrative
  "B24080_011", # Educational services, health care, social assistance
  "B24080_012", # Arts, entertainment, recreation, accommodation, food
  "B24080_013", # Other services, except public administration
  "B24080_014", # Public administration
  
  # Means of Transportation (B08301 - additional categories)
  "B08301_002", # Car, truck, or van
  "B08301_016", # Motorcycle
  "B08301_017", # Bicycle
  "B08301_018", # Walked
  "B08301_019", # Taxicab, motorcycle, bicycle, or other means
  
  # Fertility (B13016)
  "B13016_001", # Total women 15-50 who had birth in past 12 months
  "B13016_002"  # Women 15-50 who had birth in past 12 months
)

# Test with a few states first to validate approach
test_states <- c("CA", "TX", "FL")

cat("Testing data retrieval with", length(test_states), "states...\n")

# Test data retrieval
test_data <- get_acs(
  geography = "county",
  variables = goldilocks_vars,
  state = test_states,
  year = 2022,
  survey = "acs5",
  output = "wide",
  geometry = FALSE,
  cache_table = TRUE
)

cat("Test successful! Retrieved", nrow(test_data), "counties with", ncol(test_data), "columns\n")
cat("Sample GEOID:", head(test_data$GEOID, 3), "\n")

# Now get all US counties
cat("Retrieving data for all US counties...\n")

# Get comprehensive county data
county_data <- get_acs(
  geography = "county",
  variables = goldilocks_vars,
  year = 2022,
  survey = "acs5",
  output = "wide",
  geometry = TRUE,
  resolution = "20m",
  cb = TRUE,
  cache_table = TRUE
) %>%
  shift_geometry()

cat("Retrieved", nrow(county_data), "counties\n")

# Calculate population density with geometry
county_with_density <- county_data %>%
  mutate(
    area_sqkm = as.numeric(st_area(geometry)) / 1e6,
    pop_density = B01001_001E / area_sqkm
  ) %>%
  st_drop_geometry()

# Clean and prepare data for analysis
county_analysis <- county_with_density %>%
  dplyr::select(-NAME) %>%
  # Create percentage variables for standardization
  mutate(
    # Demographics percentages
    pct_male = B01001_002E / B01001_001E * 100,
    pct_white = B03002_003E / B01001_001E * 100,
    pct_black = B03002_004E / B01001_001E * 100,
    pct_asian = B03002_006E / B01001_001E * 100,
    pct_hispanic = B03002_012E / B01001_001E * 100,
    
    # Education percentages
    pct_hs_grad = B15003_017E / B15003_001E * 100,
    pct_bachelors = B15003_022E / B15003_001E * 100,
    pct_masters = B15003_023E / B15003_001E * 100,
    
    # Economic indicators
    median_income = B19013_001E,
    pct_low_income = B19001_002E / B19001_001E * 100,
    pct_high_income = B19001_017E / B19001_001E * 100,
    
    # Employment
    unemployment_rate = B23025_005E / B23025_002E * 100,
    labor_force_participation = B23025_002E / B23025_001E * 100,
    
    # Commuting
    pct_public_transit = B08301_010E / B08301_001E * 100,
    pct_work_from_home = B08301_021E / B08301_001E * 100,
    pct_drive_alone = B08301_002E / B08301_001E * 100,
    
    # Housing
    pct_owner_occupied = B25003_002E / B25001_001E * 100,
    median_home_value = B25077_001E,
    
    # Social indicators
    poverty_rate = B17001_002E / B17001_001E * 100,
    pct_family_households = B11001_002E / B11001_001E * 100,
    pct_english_only = B16001_002E / B16001_001E * 100,
    pct_spanish = B16001_003E / B16001_001E * 100,
    pct_with_disability = B18101_004E / B18101_001E * 100,
    pct_with_insurance = B27001_004E / B27001_001E * 100,
    pct_veteran = B21001_002E / B21001_001E * 100,
    pct_moved_from_other_state = B07001_017E / B07001_001E * 100,
    
    # Industry percentages
    pct_agriculture = B24080_002E / B24080_001E * 100,
    pct_construction = B24080_003E / B24080_001E * 100,
    pct_manufacturing = B24080_004E / B24080_001E * 100,
    pct_retail = B24080_006E / B24080_001E * 100,
    pct_finance = B24080_009E / B24080_001E * 100,
    pct_professional = B24080_010E / B24080_001E * 100,
    pct_education_health = B24080_011E / B24080_001E * 100,
    pct_public_admin = B24080_014E / B24080_001E * 100,
    
    # Population density already calculated above
    
    # Birth rate
    birth_rate = B13016_002E / B13016_001E * 1000 # per 1000 women 15-50
  ) %>%
  # Select analysis variables
  dplyr::select(GEOID, starts_with("pct_"), median_income, median_home_value, 
         unemployment_rate, labor_force_participation, poverty_rate,
         pop_density, birth_rate) %>%
  # Remove obvious problem rows first
  filter(!is.na(GEOID)) %>%
  # Replace infinite values and missing values
  mutate(across(where(is.numeric), ~{
    x <- ifelse(is.infinite(.), NA, .)
    ifelse(is.na(x), median(x, na.rm = TRUE), x)
  })) %>%
  # Keep rows with reasonable amount of data
  filter(rowSums(is.na(dplyr::select(., -GEOID))) < 10)

cat("Analysis dataset prepared with", nrow(county_analysis), "counties and", 
    ncol(county_analysis)-1, "variables\n")

# Calculate national means for each variable
national_means <- county_analysis %>%
  dplyr::select(-GEOID) %>%
  summarise(across(everything(), \(x) mean(x, na.rm = TRUE)))

cat("National means calculated\n")

# Prepare data matrix for Mahalanobis distance calculation
analysis_matrix <- county_analysis %>%
  dplyr::select(-GEOID) %>%
  # Ensure no missing or infinite values
  mutate(across(everything(), ~ifelse(is.na(.) | is.infinite(.), 0, .))) %>%
  as.matrix()

cat("Analysis matrix dimensions:", dim(analysis_matrix), "\n")
cat("Any missing values:", any(is.na(analysis_matrix)), "\n")
cat("Any infinite values:", any(is.infinite(analysis_matrix)), "\n")

# Calculate covariance matrix with error handling
cov_matrix <- tryCatch({
  cov(analysis_matrix, use = "complete.obs")
}, error = function(e) {
  cat("Error with complete.obs, trying pairwise.complete.obs\n")
  cov(analysis_matrix, use = "pairwise.complete.obs")
})

# Remove variables with zero variance to avoid singularity
var_check <- apply(analysis_matrix, 2, var)
cat("Variables with zero variance:", sum(var_check == 0), "\n")
cat("Variables with very low variance (< 1e-10):", sum(var_check < 1e-10), "\n")

# Keep only variables with reasonable variance
good_vars <- var_check > 1e-10
analysis_matrix_clean <- analysis_matrix[, good_vars]
national_means_clean <- national_means[good_vars]

cat("Using", ncol(analysis_matrix_clean), "variables for Mahalanobis distance\n")

# Calculate covariance matrix for cleaned data
cov_matrix_clean <- cov(analysis_matrix_clean)

# Use pseudoinverse for more robust calculation
cov_inv <- tryCatch({
  solve(cov_matrix_clean)
}, error = function(e) {
  cat("Using pseudoinverse due to singularity\n")
  MASS::ginv(cov_matrix_clean)
})

# Calculate Mahalanobis distance for each county
county_analysis$mahal_distance <- mahalanobis(
  analysis_matrix_clean, 
  center = as.numeric(national_means_clean),
  cov = cov_matrix_clean
)

cat("Mahalanobis distances calculated\n")

# Identify the most "average" counties (lowest Mahalanobis distance)
goldilocks_counties <- county_analysis %>%
  arrange(mahal_distance) %>%
  slice_head(n = 50) %>%
  left_join(
    county_data %>% 
      dplyr::select(GEOID, NAME) %>% 
      st_drop_geometry(), 
    by = "GEOID"
  )

cat("Top 10 most 'average' counties:\n")
print(goldilocks_counties %>% 
        dplyr::select(NAME, mahal_distance) %>% 
        slice_head(n = 10))

# Calculate some outcome variables for stability/satisfaction analysis
# Note: We'll use proxies available in Census data

county_outcomes <- county_data %>%
  st_drop_geometry() %>%
  mutate(
    # Population stability (lower mobility = more stable)
    stability_proxy = 100 - (B07001_017E / B07001_001E * 100),
    
    # Economic stability (lower income inequality proxy)
    income_stability = 100 - (B19001_017E / B19001_002E), # Ratio of high to low income
    
    # Housing stability (higher homeownership)
    housing_stability = B25003_002E / B25001_001E * 100,
    
    # Population growth (we'll need to compare across years - for now use age structure)
    # Younger populations suggest growth
    youth_ratio = (B01001_002E + B01001_026E - B01001_020E*2) / B01001_001E * 100
  ) %>%
  dplyr::select(GEOID, stability_proxy, income_stability, housing_stability, youth_ratio)

# Join with our main analysis
county_full_analysis <- county_analysis %>%
  left_join(county_outcomes, by = "GEOID") %>%
  left_join(
    county_data %>% 
      dplyr::select(GEOID, NAME) %>% 
      st_drop_geometry(), 
    by = "GEOID"
  )

# Test correlation between averageness and outcomes
cat("Correlation between Mahalanobis distance and outcome proxies:\n")
cor_results <- county_full_analysis %>%
  dplyr::select(mahal_distance, stability_proxy, income_stability, 
         housing_stability, youth_ratio) %>%
  cor(use = "complete.obs")

print(cor_results[1, 2:5])

# Create quintiles of averageness for analysis
county_full_analysis <- county_full_analysis %>%
  mutate(
    averageness_quintile = ntile(desc(mahal_distance), 5), # 1 = most average
    averageness_category = case_when(
      averageness_quintile == 1 ~ "Most Average",
      averageness_quintile == 2 ~ "Above Average",
      averageness_quintile == 3 ~ "Moderately Average", 
      averageness_quintile == 4 ~ "Below Average",
      averageness_quintile == 5 ~ "Least Average"
    )
  )

# Compare outcomes across quintiles
quintile_comparison <- county_full_analysis %>%
  group_by(averageness_category) %>%
  summarise(
    n_counties = n(),
    mean_stability = mean(stability_proxy, na.rm = TRUE),
    mean_income_stability = mean(income_stability, na.rm = TRUE), 
    mean_housing_stability = mean(housing_stability, na.rm = TRUE),
    mean_youth_ratio = mean(youth_ratio, na.rm = TRUE),
    .groups = "drop"
  )

cat("Outcomes by averageness quintile:\n")
print(quintile_comparison)

# ===== ENHANCED ANALYSIS: MULTIPLE AVERAGENESS METRICS =====

cat("\n=== CALCULATING ALTERNATIVE AVERAGENESS METRICS ===\n")

# 1. Centroid Distance (Euclidean)
centroid_distance <- function(data, means) {
  data_matrix <- as.matrix(data)
  means_vector <- as.numeric(means)
  sqrt(rowSums((data_matrix - rep(means_vector, each = nrow(data_matrix)))^2))
}

county_analysis$euclidean_distance <- centroid_distance(
  county_analysis %>% select(-GEOID, -mahal_distance),
  national_means
)

# 2. Median Absolute Deviation
county_analysis$mad_score <- apply(
  county_analysis %>% select(-GEOID, -mahal_distance, -euclidean_distance), 
  1, 
  function(row) {
    means_vec <- as.numeric(national_means)
    median(abs(row - means_vec), na.rm = TRUE)
  }
)

# 3. Quartile Spread Score
county_analysis$quartile_score <- apply(
  county_analysis %>% select(-GEOID, -mahal_distance, -euclidean_distance, -mad_score), 
  1, 
  function(row) {
    means_vec <- as.numeric(national_means)
    differences <- abs(row - means_vec)
    quantile(differences, 0.75, na.rm = TRUE) - quantile(differences, 0.25, na.rm = TRUE)
  }
)

# 4. Maximum Deviation Score
county_analysis$max_deviation <- apply(
  county_analysis %>% select(-GEOID, -mahal_distance, -euclidean_distance, -mad_score, -quartile_score), 
  1, 
  function(row) {
    means_vec <- as.numeric(national_means)
    max(abs(row - means_vec), na.rm = TRUE)
  }
)

# Compare different metrics
cat("Correlation between different averageness metrics:\n")
metrics_cor <- county_analysis %>%
  select(mahal_distance, euclidean_distance, mad_score, quartile_score, max_deviation) %>%
  cor(use = "complete.obs")
print(round(metrics_cor, 3))

# Find top counties by each metric
metrics_rankings <- data.frame(
  mahalanobis = county_analysis %>% arrange(mahal_distance) %>% slice_head(n = 10) %>% pull(GEOID),
  euclidean = county_analysis %>% arrange(euclidean_distance) %>% slice_head(n = 10) %>% pull(GEOID),
  mad = county_analysis %>% arrange(mad_score) %>% slice_head(n = 10) %>% pull(GEOID),
  quartile = county_analysis %>% arrange(quartile_score) %>% slice_head(n = 10) %>% pull(GEOID),
  max_dev = county_analysis %>% arrange(max_deviation) %>% slice_head(n = 10) %>% pull(GEOID)
)

cat("\nConsistency of top 10 across metrics:\n")
cat("Counties appearing in multiple top-10 lists:\n")
all_top_counties <- unlist(metrics_rankings)
consistent_counties <- table(all_top_counties)
print(sort(consistent_counties[consistent_counties > 1], decreasing = TRUE))

# ===== TEMPORAL EVOLUTION ANALYSIS =====

cat("\n=== TEMPORAL EVOLUTION OF AVERAGENESS ===\n")

# Get historical data for comparison (2010)
cat("Retrieving 2010 data for temporal comparison...\n")

# Load 2010 variables
vars_2010 <- load_variables(2010, "acs5", cache = TRUE)

# Get subset of variables available in both years
core_temporal_vars <- c(
  "B01001_001", # Total population
  "B01001_002", # Male
  "B03002_003", # White alone, not Hispanic
  "B03002_004", # Black alone, not Hispanic
  "B03002_012", # Hispanic or Latino
  "B15003_017", # High school graduate
  "B15003_022", # Bachelor's degree
  "B19013_001", # Median household income
  "B23025_005", # Unemployed
  "B25003_002", # Owner occupied
  "B17001_002"  # Below poverty level
)

# Test with small sample first
test_2010 <- get_acs(
  geography = "county",
  variables = core_temporal_vars,
  state = "MI",
  year = 2010,
  survey = "acs5",
  output = "wide",
  geometry = FALSE,
  cache_table = TRUE
)

cat("2010 test successful! Sample size:", nrow(test_2010), "\n")

# Get full 2010 data
county_2010 <- get_acs(
  geography = "county",
  variables = core_temporal_vars,
  year = 2010,
  survey = "acs5",
  output = "wide",
  geometry = FALSE,
  cache_table = TRUE
)

# Calculate comparable metrics for 2010
county_2010_clean <- county_2010 %>%
  mutate(
    pct_male = B01001_002E / B01001_001E * 100,
    pct_white = B03002_003E / B01001_001E * 100,
    pct_black = B03002_004E / B01001_001E * 100,
    pct_hispanic = B03002_012E / B01001_001E * 100,
    pct_hs_grad = B15003_017E / B01001_001E * 100,
    pct_bachelors = B15003_022E / B01001_001E * 100,
    median_income = B19013_001E,
    unemployment_rate = B23025_005E / B01001_001E * 100,
    pct_owner_occupied = B25003_002E / B01001_001E * 100,
    poverty_rate = B17001_002E / B01001_001E * 100
  ) %>%
  select(GEOID, starts_with("pct_"), median_income, unemployment_rate, poverty_rate) %>%
  filter(!is.na(GEOID)) %>%
  mutate(across(where(is.numeric), ~ifelse(is.infinite(.) | is.na(.), median(., na.rm = TRUE), .)))

# Calculate 2010 national means
national_means_2010 <- county_2010_clean %>%
  select(-GEOID) %>%
  summarise(across(everything(), \(x) mean(x, na.rm = TRUE)))

# Calculate 2010 Mahalanobis distances
analysis_matrix_2010 <- county_2010_clean %>%
  select(-GEOID) %>%
  as.matrix()

cov_matrix_2010 <- cov(analysis_matrix_2010)
cov_inv_2010 <- tryCatch({
  solve(cov_matrix_2010)
}, error = function(e) {
  MASS::ginv(cov_matrix_2010)
})

county_2010_clean$mahal_distance_2010 <- mahalanobis(
  analysis_matrix_2010,
  center = as.numeric(national_means_2010),
  cov = cov_matrix_2010
)

# Find most average counties in 2010
top_2010 <- county_2010_clean %>%
  arrange(mahal_distance_2010) %>%
  slice_head(n = 20) %>%
  left_join(
    county_data %>% 
      select(GEOID, NAME) %>% 
      st_drop_geometry(), 
    by = "GEOID"
  )

cat("\nTop 10 most average counties in 2010:\n")
print(top_2010 %>% select(NAME, mahal_distance_2010) %>% slice_head(n = 10))

# Compare 2010 vs 2022 rankings
temporal_comparison <- county_2010_clean %>%
  select(GEOID, mahal_distance_2010) %>%
  inner_join(
    county_analysis %>% select(GEOID, mahal_distance),
    by = "GEOID"
  ) %>%
  mutate(
    rank_2010 = rank(mahal_distance_2010),
    rank_2022 = rank(mahal_distance),
    rank_change = rank_2010 - rank_2022
  ) %>%
  left_join(
    county_data %>% 
      select(GEOID, NAME) %>% 
      st_drop_geometry(), 
    by = "GEOID"
  )

cat("\nCounties with biggest improvements in averageness (2010 to 2022):\n")
biggest_improvers <- temporal_comparison %>%
  arrange(desc(rank_change)) %>%
  slice_head(n = 10) %>%
  select(NAME, rank_2010, rank_2022, rank_change)
print(biggest_improvers)

cat("\nCounties with biggest declines in averageness (2010 to 2022):\n")
biggest_decliners <- temporal_comparison %>%
  arrange(rank_change) %>%
  slice_head(n = 10) %>%
  select(NAME, rank_2010, rank_2022, rank_change)
print(biggest_decliners)

# ===== VARIABLE SENSITIVITY ANALYSIS =====

cat("\n=== VARIABLE SENSITIVITY ANALYSIS ===\n")

# Test how rankings change with different variable subsets
variable_groups <- list(
  "demographics_only" = county_analysis %>% select(GEOID, starts_with("pct_")),
  "economics_only" = county_analysis %>% select(GEOID, median_income, unemployment_rate, poverty_rate),
  "no_race" = county_analysis %>% select(-GEOID, -pct_white, -pct_black, -pct_asian, -pct_hispanic, -mahal_distance, -euclidean_distance, -mad_score, -quartile_score, -max_deviation),
  "no_income" = county_analysis %>% select(-GEOID, -median_income, -mahal_distance, -euclidean_distance, -mad_score, -quartile_score, -max_deviation),
  "core_only" = county_analysis %>% select(GEOID, pct_white, pct_black, pct_hispanic, median_income, pct_bachelors, unemployment_rate, poverty_rate)
)

sensitivity_results <- list()

for (group_name in names(variable_groups)) {
  cat("Testing sensitivity for:", group_name, "\n")
  
  group_data <- variable_groups[[group_name]]
  if ("GEOID" %in% names(group_data)) {
    analysis_vars <- group_data %>% select(-GEOID)
  } else {
    analysis_vars <- group_data
  }
  
  # Calculate means and covariance for this subset
  group_means <- analysis_vars %>% summarise(across(everything(), \(x) mean(x, na.rm = TRUE)))
  group_matrix <- as.matrix(analysis_vars)
  group_cov <- cov(group_matrix)
  
  # Calculate Mahalanobis distance
  group_distances <- mahalanobis(
    group_matrix,
    center = as.numeric(group_means),
    cov = group_cov
  )
  
  # Get top 10 counties for this subset
  top_counties_group <- data.frame(
    GEOID = county_analysis$GEOID,
    distance = group_distances
  ) %>%
    arrange(distance) %>%
    slice_head(n = 10) %>%
    pull(GEOID)
  
  sensitivity_results[[group_name]] <- top_counties_group
}

# Check consistency across variable subsets
cat("\nConsistency of top 10 counties across variable subsets:\n")
all_sensitivity_counties <- unlist(sensitivity_results)
sensitivity_consistency <- table(all_sensitivity_counties)
print(sort(sensitivity_consistency[sensitivity_consistency > 1], decreasing = TRUE))

# ===== EXTREME COUNTIES ANALYSIS =====

cat("\n=== ANALYZING LEAST AVERAGE COUNTIES ===\n")

# Find most extreme counties
extreme_counties <- county_analysis %>%
  arrange(desc(mahal_distance)) %>%
  slice_head(n = 20) %>%
  left_join(
    county_data %>% 
      select(GEOID, NAME) %>% 
      st_drop_geometry(), 
    by = "GEOID"
  )

cat("Top 10 least average (most extreme) counties:\n")
print(extreme_counties %>% select(NAME, mahal_distance) %>% slice_head(n = 10))

# Analyze what makes them extreme
extreme_analysis <- extreme_counties %>%
  slice_head(n = 10) %>%
  select(-NAME, -euclidean_distance, -mad_score, -quartile_score, -max_deviation) %>%
  pivot_longer(-c(GEOID, mahal_distance), names_to = "variable", values_to = "value") %>%
  left_join(
    national_means %>%
      pivot_longer(everything(), names_to = "variable", values_to = "national_mean"),
    by = "variable"
  ) %>%
  mutate(
    deviation = abs(value - national_mean),
    standardized_deviation = deviation / national_mean
  ) %>%
  group_by(GEOID) %>%
  arrange(desc(standardized_deviation)) %>%
  slice_head(n = 3) %>%
  left_join(
    county_data %>% 
      select(GEOID, NAME) %>% 
      st_drop_geometry(), 
    by = "GEOID"
  )

cat("\nMost extreme deviations by county:\n")
print(extreme_analysis %>% 
  select(NAME, variable, value, national_mean, standardized_deviation) %>%
  arrange(desc(standardized_deviation)))

# ===== ENHANCED GOLDILOCKS PROFILES =====

cat("\n=== CREATING DETAILED PROFILES OF TOP 5 COUNTIES ===\n")

# Get top 5 most average counties with full details
top_5_profiles <- county_full_analysis %>%
  arrange(mahal_distance) %>%
  slice_head(n = 5) %>%
  select(GEOID, NAME, mahal_distance, everything())

# Create detailed profiles for each
for (i in 1:5) {
  county_profile <- top_5_profiles %>% slice(i)
  cat("\n--- PROFILE #", i, ": ", county_profile$NAME, " ---\n")
  cat("Averageness Score:", round(county_profile$mahal_distance, 3), "\n")
  
  # Find this county's closest matches to national means
  profile_data <- county_profile %>%
    select(starts_with("pct_"), median_income, unemployment_rate, poverty_rate) %>%
    pivot_longer(everything(), names_to = "variable", values_to = "value") %>%
    left_join(
      national_means %>%
        pivot_longer(everything(), names_to = "variable", values_to = "national_mean"),
      by = "variable"
    ) %>%
    mutate(
      difference = value - national_mean,
      abs_difference = abs(difference),
      variable_label = case_when(
        variable == "pct_white" ~ "% White",
        variable == "pct_black" ~ "% Black",
        variable == "pct_hispanic" ~ "% Hispanic",
        variable == "median_income" ~ "Median Income",
        variable == "unemployment_rate" ~ "Unemployment Rate",
        variable == "poverty_rate" ~ "Poverty Rate",
        variable == "pct_bachelors" ~ "% Bachelor's Degree",
        variable == "pct_owner_occupied" ~ "% Homeownership",
        TRUE ~ variable
      )
    ) %>%
    arrange(abs_difference) %>%
    slice_head(n = 5)
  
  cat("Top 5 closest matches to national average:\n")
  for (j in 1:nrow(profile_data)) {
    row <- profile_data[j, ]
    cat(sprintf("  %s: %.1f (vs %.1f national, diff: %+.1f)\n", 
                row$variable_label, row$value, row$national_mean, row$difference))
  }
}

# ===== SAVE ENHANCED DATA =====

cat("\n=== SAVING ENHANCED ANALYSIS DATA ===\n")

# Create comprehensive data package
save(
  # Original data
  county_data, county_full_analysis, goldilocks_counties, 
  quintile_comparison, national_means, cor_results,
  
  # Enhanced metrics
  county_analysis, metrics_cor, metrics_rankings,
  
  # Temporal analysis
  county_2010_clean, national_means_2010, top_2010, temporal_comparison,
  biggest_improvers, biggest_decliners,
  
  # Sensitivity analysis
  sensitivity_results, sensitivity_consistency,
  
  # Extreme counties
  extreme_counties, extreme_analysis,
  
  # Detailed profiles
  top_5_profiles,
  
  file = "/Users/dmitryshkolnik/Projects/census-monkey-typewriter/analyses/whimsical/goldilocks-zone/data/goldilocks_analysis_enhanced.RData"
)

cat("\n=== ENHANCED ANALYSIS COMPLETE ===\n")
cat("Most average county (Mahalanobis):", goldilocks_counties$NAME[1], "\n")
cat("Most average county (2010):", top_2010$NAME[1], "\n")
cat("Most extreme county:", extreme_counties$NAME[1], "\n")
cat("Correlation between Mahalanobis and Euclidean:", round(metrics_cor[1,2], 3), "\n")
cat("Counties consistent across all metrics:", names(sensitivity_consistency)[sensitivity_consistency == max(sensitivity_consistency)], "\n")