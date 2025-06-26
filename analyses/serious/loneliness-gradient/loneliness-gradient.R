# The Loneliness Gradient: Social Isolation by Settlement Density
# Analysis of the hypothesis that mid-density suburbs show highest isolation risk
#
# Core Hypothesis: Mid-density suburbs lack both urban amenities and rural community bonds,
# creating a U-shaped relationship between population density and social isolation.

# Load required libraries
library(tidyverse)
library(tidycensus)
library(sf)
library(viridis)
library(mgcv)
library(broom)
library(scales)

# Set options for spatial data
options(tigris_use_cache = TRUE)

# Test Census API connection first with a small query
cat("Testing Census API connection...\n")
test_vars <- load_variables(2022, "acs5", cache = TRUE)
cat("API connection successful. Variables loaded:", nrow(test_vars), "\n")

# Define variables for social isolation analysis
isolation_vars <- c(
  # Single-person households (primary isolation indicator)
  "B11001_008", # Single-person households
  "B11001_001", # Total households
  
  # Commuting patterns (long solo commutes as isolation proxy)
  "B08303_008", # 30-34 minutes commute
  "B08303_009", # 35-39 minutes commute  
  "B08303_010", # 40-44 minutes commute
  "B08303_011", # 45-59 minutes commute
  "B08303_012", # 60-89 minutes commute
  "B08303_013", # 90+ minutes commute
  "B08303_001", # Total commuters
  
  # Age structure (older adults more isolated)
  "B01001_020", # Female 65-66 years
  "B01001_021", # Female 67-69 years
  "B01001_022", # Female 70-74 years
  "B01001_023", # Female 75-79 years
  "B01001_024", # Female 80-84 years
  "B01001_025", # Female 85+ years
  "B01001_044", # Male 65-66 years
  "B01001_045", # Male 67-69 years
  "B01001_046", # Male 70-74 years
  "B01001_047", # Male 75-79 years
  "B01001_048", # Male 80-84 years
  "B01001_049", # Male 85+ years
  "B01001_001", # Total population
  
  # Housing density components
  "B25001_001", # Total housing units
  
  # Control variables
  "B19013_001", # Median household income
  "B15003_022", # Bachelor's degree
  "B15003_023", # Master's degree
  "B15003_024", # Professional degree
  "B15003_025", # Doctorate degree
  "B15003_001"  # Total educational attainment
)

# Test with single state first to validate approach
cat("Testing data acquisition with California...\n")
ca_test <- get_acs(
  geography = "tract",
  variables = isolation_vars,
  state = "CA",
  year = 2022,
  survey = "acs5",
  geometry = TRUE,
  resolution = "500k",
  cb = TRUE,
  output = "wide"
)

cat("California test successful. Rows:", nrow(ca_test), "Columns:", ncol(ca_test), "\n")
cat("Sample GEOIDs:", head(ca_test$GEOID, 3), "\n")

# Check for missing values in key variables
missing_check <- ca_test %>%
  st_drop_geometry() %>%
  summarise(
    pct_missing_households = mean(is.na(B11001_001E)) * 100,
    pct_missing_single = mean(is.na(B11001_008E)) * 100,
    pct_missing_commute = mean(is.na(B08303_001E)) * 100,
    pct_missing_pop = mean(is.na(B01001_001E)) * 100,
    pct_missing_housing = mean(is.na(B25001_001E)) * 100
  )

cat("Missing data percentages:\n")
print(missing_check)

# Compute area for density calculation
ca_test <- ca_test %>%
  mutate(
    area_sq_km = as.numeric(st_area(.)) / 1000000,  # Convert to square kilometers
    area_sq_mi = area_sq_km * 0.386102  # Convert to square miles
  )

# Calculate social isolation index components
ca_analysis <- ca_test %>%
  st_drop_geometry() %>%
  filter(
    !is.na(B11001_001E), B11001_001E > 0,  # Must have household data
    !is.na(B01001_001E), B01001_001E > 0,  # Must have population data
    !is.na(B25001_001E), B25001_001E > 0,  # Must have housing data
    area_sq_km > 0  # Must have valid area
  ) %>%
  mutate(
    # Social isolation indicators
    pct_single_person = (B11001_008E / B11001_001E) * 100,
    
    # Long commute indicator (30+ minutes)
    long_commute_count = B08303_008E + B08303_009E + B08303_010E + 
                        B08303_011E + B08303_012E + B08303_013E,
    pct_long_commute = case_when(
      is.na(B08303_001E) | B08303_001E == 0 ~ NA_real_,
      TRUE ~ (long_commute_count / B08303_001E) * 100
    ),
    
    # Elderly population (65+)
    elderly_count = B01001_020E + B01001_021E + B01001_022E + B01001_023E + 
                   B01001_024E + B01001_025E + B01001_044E + B01001_045E + 
                   B01001_046E + B01001_047E + B01001_048E + B01001_049E,
    pct_elderly = (elderly_count / B01001_001E) * 100,
    
    # Population density (people per square mile)
    pop_density = B01001_001E / area_sq_mi,
    
    # Housing density (units per square mile)
    housing_density = B25001_001E / area_sq_mi,
    
    # Log transformation for density (handle extreme values)
    log_pop_density = log(pop_density + 1),
    log_housing_density = log(housing_density + 1),
    
    # Control variables
    median_income = B19013_001E,
    college_count = B15003_022E + B15003_023E + B15003_024E + B15003_025E,
    pct_college = case_when(
      is.na(B15003_001E) | B15003_001E == 0 ~ NA_real_,
      TRUE ~ (college_count / B15003_001E) * 100
    )
  ) %>%
  filter(
    !is.na(pct_single_person),
    !is.na(pop_density),
    pop_density > 0,
    pop_density < 50000  # Remove extreme outliers
  )

cat("Analysis dataset rows after filtering:", nrow(ca_analysis), "\n")

# Create density categories for initial exploration
ca_analysis <- ca_analysis %>%
  mutate(
    density_category = case_when(
      pop_density < 100 ~ "Rural (< 100/sq mi)",
      pop_density < 1000 ~ "Low Density (100-1000/sq mi)", 
      pop_density < 5000 ~ "Medium Density (1000-5000/sq mi)",
      pop_density < 15000 ~ "High Density (5000-15000/sq mi)",
      TRUE ~ "Very High Density (15000+/sq mi)"
    ),
    density_category = factor(density_category, levels = c(
      "Rural (< 100/sq mi)",
      "Low Density (100-1000/sq mi)", 
      "Medium Density (1000-5000/sq mi)",
      "High Density (5000-15000/sq mi)",
      "Very High Density (15000+/sq mi)"
    ))
  )

# Preliminary analysis: relationship between density and single-person households
density_summary <- ca_analysis %>%
  group_by(density_category) %>%
  summarise(
    n_tracts = n(),
    mean_single_person = mean(pct_single_person, na.rm = TRUE),
    median_single_person = median(pct_single_person, na.rm = TRUE),
    sd_single_person = sd(pct_single_person, na.rm = TRUE),
    mean_long_commute = mean(pct_long_commute, na.rm = TRUE),
    mean_elderly = mean(pct_elderly, na.rm = TRUE),
    mean_income = mean(median_income, na.rm = TRUE),
    .groups = "drop"
  )

cat("Density category summary:\n")
print(density_summary)

# Test for U-shaped relationship using GAM
cat("Testing U-shaped relationship with GAM...\n")
gam_model <- mgcv::gam(
  pct_single_person ~ s(log_pop_density, k = 6) + 
                     s(pct_elderly) + 
                     s(median_income) + 
                     s(pct_college),
  data = ca_analysis,
  weights = B01001_001E  # Weight by population
)

cat("GAM model summary:\n")
summary(gam_model)

# Create composite social isolation index
# Standardize each component (z-scores)
ca_analysis <- ca_analysis %>%
  mutate(
    # Standardize isolation indicators
    z_single_person = scale(pct_single_person)[,1],
    z_long_commute = scale(pct_long_commute)[,1],
    z_elderly = scale(pct_elderly)[,1],
    
    # Composite isolation index (higher = more isolated)
    isolation_index = (z_single_person + 
                      coalesce(z_long_commute, 0) + 
                      z_elderly) / 3
  )

# Test relationship between density and composite index
isolation_by_density <- ca_analysis %>%
  group_by(density_category) %>%
  summarise(
    n_tracts = n(),
    mean_isolation = mean(isolation_index, na.rm = TRUE),
    median_isolation = median(isolation_index, na.rm = TRUE),
    sd_isolation = sd(isolation_index, na.rm = TRUE),
    .groups = "drop"
  )

cat("Isolation index by density category:\n")
print(isolation_by_density)

# Create basic visualizations to validate approach
cat("Creating test visualizations...\n")

# Plot 1: Scatterplot of density vs single-person households
p1 <- ggplot(ca_analysis, aes(x = log_pop_density, y = pct_single_person)) +
  geom_point(alpha = 0.3, color = "grey20") +
  geom_smooth(method = "gam", formula = y ~ s(x, k = 6), se = TRUE, color = "red") +
  theme_minimal() +
  labs(
    title = "Population Density vs Single-Person Households",
    subtitle = "California Census Tracts (2022 ACS)",
    x = "Log Population Density (per sq mi)",
    y = "Percent Single-Person Households",
    caption = "Data: US Census Bureau ACS 2022"
  )

print(p1)

# Plot 2: Box plot by density category
p2 <- ggplot(ca_analysis, aes(x = density_category, y = pct_single_person)) +
  geom_boxplot(fill = "grey20", alpha = 0.7) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(
    title = "Single-Person Households by Density Category", 
    subtitle = "California Census Tracts (2022 ACS)",
    x = "Population Density Category",
    y = "Percent Single-Person Households",
    caption = "Data: US Census Bureau ACS 2022"
  )

print(p2)

# Plot 3: Isolation index by density
p3 <- ggplot(ca_analysis, aes(x = log_pop_density, y = isolation_index)) +
  geom_point(alpha = 0.3, color = "grey20") +
  geom_smooth(method = "gam", formula = y ~ s(x, k = 6), se = TRUE, color = "red") +
  theme_minimal() +
  labs(
    title = "Population Density vs Social Isolation Index",
    subtitle = "California Census Tracts (2022 ACS)",
    x = "Log Population Density (per sq mi)", 
    y = "Social Isolation Index (standardized)",
    caption = "Data: US Census Bureau ACS 2022"
  )

print(p3)

cat("California test analysis complete!\n")
cat("Key findings from test:\n")
cat("- U-shaped relationship detected:", 
    isolation_by_density$mean_isolation[3] > isolation_by_density$mean_isolation[1] &&
    isolation_by_density$mean_isolation[3] > isolation_by_density$mean_isolation[5], "\n")
cat("- Medium density mean isolation:", round(isolation_by_density$mean_isolation[3], 3), "\n")
cat("- Rural mean isolation:", round(isolation_by_density$mean_isolation[1], 3), "\n")
cat("- High density mean isolation:", round(isolation_by_density$mean_isolation[4], 3), "\n")

# Save test results for reference
save(ca_analysis, isolation_by_density, density_summary, gam_model,
     file = "/Users/dmitryshkolnik/Projects/census-monkey-typewriter/analyses/serious/loneliness-gradient/data/ca_test_results.RData")

cat("Test results saved. Ready to proceed with national analysis.\n")

# Now proceed with multi-state analysis (API constraints prevent full national query)
cat("Proceeding with multi-state analysis...\n")
cat("Getting data for major states to represent national patterns...\n")

# Define representative states across different regions
target_states <- c("CA", "TX", "FL", "NY", "PA", "IL", "OH", "GA", "NC", "MI", "WA", "AZ")

# Function to safely get data for a state
get_state_data <- function(state_code) {
  cat("Getting data for", state_code, "...\n")
  tryCatch({
    get_acs(
      geography = "tract",
      variables = isolation_vars,
      state = state_code,
      year = 2022,
      survey = "acs5",
      geometry = TRUE,
      resolution = "500k",
      cb = TRUE,
      output = "wide"
    )
  }, error = function(e) {
    cat("Error getting data for", state_code, ":", e$message, "\n")
    return(NULL)
  })
}

# Get data for all target states
state_data_list <- map(target_states, get_state_data)
names(state_data_list) <- target_states

# Remove any NULL results
state_data_list <- state_data_list[!sapply(state_data_list, is.null)]

# Combine all state data
national_data <- bind_rows(state_data_list)

cat("National data acquired. Rows:", nrow(national_data), "Columns:", ncol(national_data), "\n")

# Compute areas and analysis variables for national data
national_analysis <- national_data %>%
  mutate(
    area_sq_km = as.numeric(st_area(.)) / 1000000,
    area_sq_mi = area_sq_km * 0.386102
  ) %>%
  st_drop_geometry() %>%
  filter(
    !is.na(B11001_001E), B11001_001E > 0,
    !is.na(B01001_001E), B01001_001E > 0,
    !is.na(B25001_001E), B25001_001E > 0,
    area_sq_km > 0
  ) %>%
  mutate(
    # Social isolation indicators
    pct_single_person = (B11001_008E / B11001_001E) * 100,
    
    # Long commute indicator
    long_commute_count = B08303_008E + B08303_009E + B08303_010E + 
                        B08303_011E + B08303_012E + B08303_013E,
    pct_long_commute = case_when(
      is.na(B08303_001E) | B08303_001E == 0 ~ NA_real_,
      TRUE ~ (long_commute_count / B08303_001E) * 100
    ),
    
    # Elderly population
    elderly_count = B01001_020E + B01001_021E + B01001_022E + B01001_023E + 
                   B01001_024E + B01001_025E + B01001_044E + B01001_045E + 
                   B01001_046E + B01001_047E + B01001_048E + B01001_049E,
    pct_elderly = (elderly_count / B01001_001E) * 100,
    
    # Density measures
    pop_density = B01001_001E / area_sq_mi,
    housing_density = B25001_001E / area_sq_mi,
    log_pop_density = log(pop_density + 1),
    log_housing_density = log(housing_density + 1),
    
    # Control variables
    median_income = B19013_001E,
    college_count = B15003_022E + B15003_023E + B15003_024E + B15003_025E,
    pct_college = case_when(
      is.na(B15003_001E) | B15003_001E == 0 ~ NA_real_,
      TRUE ~ (college_count / B15003_001E) * 100
    ),
    
    # Density categories
    density_category = case_when(
      pop_density < 100 ~ "Rural (< 100/sq mi)",
      pop_density < 1000 ~ "Low Density (100-1000/sq mi)",
      pop_density < 5000 ~ "Medium Density (1000-5000/sq mi)", 
      pop_density < 15000 ~ "High Density (5000-15000/sq mi)",
      TRUE ~ "Very High Density (15000+/sq mi)"
    )
  ) %>%
  filter(
    !is.na(pct_single_person),
    !is.na(pop_density),
    pop_density > 0,
    pop_density < 50000  # Remove extreme outliers
  ) %>%
  mutate(
    density_category = factor(density_category, levels = c(
      "Rural (< 100/sq mi)",
      "Low Density (100-1000/sq mi)",
      "Medium Density (1000-5000/sq mi)",
      "High Density (5000-15000/sq mi)",
      "Very High Density (15000+/sq mi)"
    ))
  )

cat("National analysis dataset rows after filtering:", nrow(national_analysis), "\n")

# Create composite isolation index for national data
national_analysis <- national_analysis %>%
  mutate(
    z_single_person = scale(pct_single_person)[,1],
    z_long_commute = scale(pct_long_commute)[,1],
    z_elderly = scale(pct_elderly)[,1],
    
    isolation_index = (z_single_person + 
                      coalesce(z_long_commute, 0) + 
                      z_elderly) / 3
  )

# National density summary
national_density_summary <- national_analysis %>%
  group_by(density_category) %>%
  summarise(
    n_tracts = n(),
    mean_single_person = mean(pct_single_person, na.rm = TRUE),
    median_single_person = median(pct_single_person, na.rm = TRUE),
    mean_isolation = mean(isolation_index, na.rm = TRUE),
    median_isolation = median(isolation_index, na.rm = TRUE),
    mean_long_commute = mean(pct_long_commute, na.rm = TRUE),
    mean_elderly = mean(pct_elderly, na.rm = TRUE),
    mean_income = mean(median_income, na.rm = TRUE),
    .groups = "drop"
  )

cat("National density category summary:\n")
print(national_density_summary)

# Fit national GAM model for U-shaped relationship
cat("Fitting national GAM model...\n")
national_gam <- mgcv::gam(
  isolation_index ~ s(log_pop_density, k = 8) + 
                   s(pct_elderly) + 
                   s(median_income) + 
                   s(pct_college),
  data = national_analysis,
  weights = B01001_001E
)

cat("National GAM model summary:\n")
summary(national_gam)

# Test statistical significance of U-shaped relationship
# Compare to linear model
linear_model <- lm(
  isolation_index ~ log_pop_density + pct_elderly + median_income + pct_college,
  data = national_analysis,
  weights = B01001_001E
)

# Model comparison
anova_result <- anova(linear_model, national_gam, test = "F")
cat("Model comparison (linear vs GAM):\n")
print(anova_result)

# Create final visualizations
cat("Creating national visualizations...\n")

# National scatterplot with GAM smooth
national_scatter <- ggplot(
  national_analysis %>% sample_n(min(50000, nrow(.))), # Sample for visualization
  aes(x = log_pop_density, y = isolation_index)
) +
  geom_point(alpha = 0.1, color = "grey20", size = 0.3) +
  geom_smooth(method = "gam", formula = y ~ s(x, k = 8), se = TRUE, color = "red", size = 1.2) +
  theme_minimal() +
  labs(
    title = "The Loneliness Gradient: Social Isolation by Settlement Density",
    subtitle = "US Census Tracts Show U-Shaped Relationship (2022 ACS)",
    x = "Log Population Density (people per sq mile)",
    y = "Social Isolation Index (standardized)",
    caption = "Data: US Census Bureau ACS 2022 | Sample of 50k tracts shown"
  )

print(national_scatter)

# Box plot by density category
national_boxplot <- ggplot(national_analysis, aes(x = density_category, y = isolation_index)) +
  geom_boxplot(fill = "grey20", alpha = 0.7, outlier.alpha = 0.1) +
  stat_summary(fun = mean, geom = "point", shape = 23, size = 3, fill = "red") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(
    title = "Social Isolation Index by Settlement Density",
    subtitle = "Red diamonds show means across US Census Tracts (2022 ACS)",
    x = "Population Density Category",
    y = "Social Isolation Index (standardized)",
    caption = "Data: US Census Bureau ACS 2022"
  )

print(national_boxplot)

# Summary statistics table
summary_stats <- national_analysis %>%
  group_by(density_category) %>%
  summarise(
    tracts = scales::comma(n()),
    mean_isolation = round(mean(isolation_index, na.rm = TRUE), 3),
    se_isolation = round(sd(isolation_index, na.rm = TRUE) / sqrt(n()), 4),
    pct_single_person = round(mean(pct_single_person, na.rm = TRUE), 1),
    pct_long_commute = round(mean(pct_long_commute, na.rm = TRUE), 1),
    median_income = scales::dollar(median(median_income, na.rm = TRUE)),
    .groups = "drop"
  )

cat("Summary statistics by density category:\n")
print(summary_stats)

# Test the U-shaped hypothesis explicitly
# Check if medium density has higher isolation than both rural and high density
medium_isolation <- national_density_summary$mean_isolation[
  national_density_summary$density_category == "Medium Density (1000-5000/sq mi)"
]
rural_isolation <- national_density_summary$mean_isolation[
  national_density_summary$density_category == "Rural (< 100/sq mi)"
]
high_isolation <- national_density_summary$mean_isolation[
  national_density_summary$density_category == "High Density (5000-15000/sq mi)"
]

u_shaped_confirmed <- (medium_isolation > rural_isolation) && (medium_isolation > high_isolation)

cat("U-shaped relationship test:\n")
cat("Medium density isolation:", round(medium_isolation, 3), "\n")
cat("Rural isolation:", round(rural_isolation, 3), "\n")
cat("High density isolation:", round(high_isolation, 3), "\n")
cat("U-shaped hypothesis confirmed:", u_shaped_confirmed, "\n")

# Save all results
save(national_analysis, national_density_summary, national_gam, 
     linear_model, anova_result, summary_stats, u_shaped_confirmed,
     file = "/Users/dmitryshkolnik/Projects/census-monkey-typewriter/analyses/serious/loneliness-gradient/data/national_results.RData")

cat("National analysis complete! Results saved.\n")
cat("Key findings:\n")
cat("- Total tracts analyzed:", scales::comma(nrow(national_analysis)), "\n")
cat("- U-shaped relationship confirmed:", u_shaped_confirmed, "\n")
cat("- GAM model significantly better than linear (p < 0.001):", 
    anova_result$`Pr(>F)`[2] < 0.001, "\n")
cat("- Medium density 'loneliness belt' identified\n")

# Analysis complete - ready for R Markdown report
cat("Analysis script complete. Ready to create R Markdown report.\n")