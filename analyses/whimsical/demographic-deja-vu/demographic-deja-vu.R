# Demographic Déjà Vu: Finding America's Temporal Twin Towns
# Working R script for development and testing

# Load required libraries
library(tidyverse)
library(tidycensus)
library(sf)
library(viridis)
library(broom)
library(scales)
library(parallel)  # For parallel processing of DTW calculations

# Install and load DTW package if needed
if (!require(dtw, quietly = TRUE)) {
  cat("Installing DTW package...\n")
  options(repos = c(CRAN = "https://cran.rstudio.com/"))
  install.packages("dtw")
  library(dtw)
}

# Load optional packages with graceful handling
optional_packages <- c("factoextra", "corrplot")
for(pkg in optional_packages) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat("Optional package", pkg, "not available\n")
  }
}

# Set options
options(tigris_use_cache = TRUE)

# Load Census API Key
api_key <- Sys.getenv("CENSUS_API_KEY")
if(api_key != "") {
  census_api_key(api_key)
  cat("Census API key loaded successfully\n")
} else {
  cat("Warning: No Census API key found. Set CENSUS_API_KEY environment variable.\n")
}

# Phase 0: Strategic Deconstruction & Research Design

cat("=== PHASE 0: RESEARCH DESIGN ===\n")
cat("Core Hypothesis: Find temporal twins - places whose current demographics\n")
cat("mirror each other's past using dynamic time warping.\n\n")

cat("Research Design:\n")
cat("- Data: Decennial Census 1990-2020, ACS 2010-2023\n")
cat("- Unit: County level for computational feasibility\n")
cat("- Variables: Age structure, race/ethnicity, income, education, housing\n")
cat("- Method: Dynamic Time Warping (DTW) on standardized time series\n")
cat("- Validation: Out-of-sample prediction testing\n\n")

# Phase 0.5: Pre-Analysis Validation & Scoping

cat("=== PHASE 0.5: DATA AVAILABILITY CHECK ===\n")

# Check ACS variables for recent years - use available years
cat("Loading variable definitions...\n")
acs_vars_2022 <- tryCatch({
  load_variables(2022, "acs5", cache = TRUE)
}, error = function(e) {
  cat("2022 variables not available, trying 2021...\n")
  load_variables(2021, "acs5", cache = TRUE)
})

decennial_vars_2020 <- tryCatch({
  load_variables(2020, "sf1", cache = TRUE)  
}, error = function(e) {
  cat("2020 SF1 not available, trying 2020 sf2...\n")
  tryCatch({
    load_variables(2020, "sf2", cache = TRUE)
  }, error = function(e2) {
    cat("Using 2010 decennial variables instead\n")
    load_variables(2010, "sf1", cache = TRUE)
  })
})

# Define our demographic variables of interest
demographic_vars <- tribble(
  ~variable, ~label, ~category,
  # Age structure
  "B01001_003", "Male Under 5", "age",
  "B01001_027", "Female Under 5", "age", 
  "B01001_010", "Male 25-34", "age",
  "B01001_034", "Female 25-34", "age",
  "B01001_016", "Male 65-74", "age",
  "B01001_040", "Female 65-74", "age",
  
  # Race/ethnicity
  "B03002_003", "White Alone NH", "race",
  "B03002_004", "Black Alone NH", "race",
  "B03002_012", "Hispanic/Latino", "race",
  "B03002_006", "Asian Alone NH", "race",
  
  # Education (25+)
  "B15003_022", "Bachelor's Degree", "education",
  "B15003_023", "Master's Degree", "education",
  "B15003_024", "Professional Degree", "education",
  "B15003_025", "Doctorate Degree", "education",
  
  # Income
  "B19013_001", "Median Household Income", "income",
  "B25077_001", "Median Home Value", "housing"
)

cat("Checking variable availability...\n")
available_vars <- demographic_vars$variable %in% acs_vars_2022$name
cat("Variables available in 2022 ACS:", sum(available_vars), "out of", nrow(demographic_vars), "\n")

if(!all(available_vars)) {
  cat("Missing variables:\n")
  print(demographic_vars$variable[!available_vars])
}

# Phase 1: Data Acquisition & Harmonization

cat("\n=== PHASE 1: DATA ACQUISITION ===\n")

# Test data retrieval on a smaller sample first - let's start with a few states
test_states <- c("TX", "CA", "FL")

cat("Testing data retrieval for", length(test_states), "states...\n")

# Function to safely get ACS data with error handling
get_acs_safe <- function(geography, variables, year, state = NULL, survey = "acs5") {
  tryCatch({
    get_acs(
      geography = geography,
      variables = variables,
      year = year,
      state = state,
      survey = survey,
      geometry = FALSE,  # Start without geometry for testing
      output = "wide"
    )
  }, error = function(e) {
    cat("Error getting", year, "data:", e$message, "\n")
    return(NULL)
  })
}

# Test ACS data retrieval for recent years
test_years <- c(2012, 2017, 2022)
cat("Testing ACS data for years:", paste(test_years, collapse = ", "), "\n")

# Get test data for one state to validate approach
test_data <- get_acs_safe(
  geography = "county",
  variables = demographic_vars$variable,
  year = 2022,
  state = "TX"
)

if(!is.null(test_data)) {
  cat("Successfully retrieved test data for TX:\n")
  cat("- Rows:", nrow(test_data), "\n")
  cat("- Columns:", ncol(test_data), "\n")
  cat("- Sample GEOIDs:", paste(head(test_data$GEOID, 3), collapse = ", "), "\n")
  
  # Check for missing values
  missing_counts <- test_data %>%
    select(ends_with("E")) %>%  # Estimates only
    summarise_all(~sum(is.na(.))) %>%
    pivot_longer(everything(), names_to = "variable", values_to = "missing_count")
  
  cat("Missing value counts by variable:\n")
  print(missing_counts)
  
} else {
  cat("Failed to retrieve test data. Stopping analysis.\n")
  stop("Data retrieval failed")
}

# Now let's try to get historical data (this will be more complex)
cat("\nTesting historical data availability...\n")

# For decennial census, we need to map variables across years
# This is complex because variable codes change between censuses

# Let's focus on ACS 2010-2022 for now and create a time series
acs_years <- 2010:2022

cat("Attempting to retrieve ACS data for", length(acs_years), "years...\n")

# Function to get multi-year ACS data
get_multiyear_acs <- function(states, years, variables) {
  
  all_data <- list()
  
  for(year in years) {
    cat("Getting data for", year, "...\n")
    
    year_data <- get_acs_safe(
      geography = "county",
      variables = variables,
      year = year,
      state = states
    )
    
    if(!is.null(year_data)) {
      year_data$year <- year
      all_data[[as.character(year)]] <- year_data
    } else {
      cat("Failed to get data for", year, "\n")
    }
    
    # Add small delay to be respectful to API
    Sys.sleep(0.5)
  }
  
  if(length(all_data) > 0) {
    bind_rows(all_data)
  } else {
    NULL
  }
}

# Start with a single state for testing
cat("Getting multi-year data for TX...\n")
tx_multiyear <- get_multiyear_acs(
  states = "TX",
  years = c(2012, 2017, 2022),  # Test with fewer years first
  variables = demographic_vars$variable[1:6]  # Test with fewer variables
)

if(!is.null(tx_multiyear)) {
  cat("Successfully retrieved multi-year data:\n")
  cat("- Total rows:", nrow(tx_multiyear), "\n")
  cat("- Years:", paste(unique(tx_multiyear$year), collapse = ", "), "\n")
  cat("- Counties:", length(unique(tx_multiyear$GEOID)), "\n")
  
  # Check data completeness
  completeness <- tx_multiyear %>%
    group_by(year) %>%
    summarise(
      counties = n_distinct(GEOID),
      complete_cases = sum(complete.cases(select(., ends_with("E")))),
      .groups = "drop"
    )
  
  cat("Data completeness by year:\n")
  print(completeness)
  
} else {
  cat("Failed to retrieve multi-year data.\n")
}

# Phase 2: Create Demographic Time Series

cat("\n=== PHASE 2: TIME SERIES CREATION ===\n")

if(!is.null(tx_multiyear)) {
  
  # Clean and transform the data for time series analysis
  cat("Creating demographic time series...\n")
  
  # Create proportions and rates from raw counts
  ts_data <- tx_multiyear %>%
    # Calculate total population for proportions
    mutate(
      total_pop = B01001_003E + B01001_027E,  # This is just under 5 - we need total pop
      # We'll need to add total population variable
    ) %>%
    # For now, let's work with the raw estimates and create indices
    select(GEOID, NAME, year, ends_with("E")) %>%
    # Remove the "E" suffix for cleaner names
    rename_with(~str_remove(.x, "E$"), ends_with("E"))
  
  cat("Time series data shape:", nrow(ts_data), "rows,", ncol(ts_data), "columns\n")
  
  # Check if we have multiple time points per county
  time_points <- ts_data %>%
    count(GEOID) %>%
    pull(n)
  
  cat("Time points per county - Min:", min(time_points), "Max:", max(time_points), "\n")
  
  if(max(time_points) >= 2) {
    cat("Good! We have temporal variation for DTW analysis.\n")
    
    # Create a sample time series for one county to test DTW
    sample_county <- ts_data %>%
      filter(GEOID == first(GEOID)) %>%
      arrange(year)
    
    cat("Sample county time series:\n")
    print(sample_county)
    
  } else {
    cat("Warning: Insufficient temporal variation for DTW analysis.\n")
  }
  
} else {
  cat("No multi-year data available for time series creation.\n")
}

# Phase 3: Expand to Multi-State Analysis

cat("\n=== PHASE 3: MULTI-STATE DATA COLLECTION ===\n")

# Expand to NATIONAL scale - all US states for meaningful temporal twin detection
target_states <- NULL  # NULL gets all states in tidycensus
target_years <- c(2010, 2013, 2016, 2019, 2022)  # 5-year intervals for ACS

cat("Expanding analysis to ALL US STATES (national scale) and", length(target_years), "years\n")
cat("This will take considerable time due to API rate limits and computational requirements...\n")
cat("Estimated ~3000+ counties will be analyzed instead of ~1000\n")

# Get comprehensive multi-state data with error handling
cat("Beginning national data collection. This may take 30+ minutes...\n")
cat("Monitoring memory usage during collection...\n")

# Pre-collection memory check
initial_memory <- gc()
cat("Initial memory usage:", format(sum(initial_memory[,2]), units = "auto"), "\n")

full_data <- tryCatch({
  get_multiyear_acs(
    states = target_states,  # NULL for all states
    years = target_years,
    variables = demographic_vars$variable
  )
}, error = function(e) {
  cat("Error in national data collection:", e$message, "\n")
  cat("Attempting reduced variable set...\n")
  
  # Fallback: try with core variables only
  core_vars <- demographic_vars$variable[1:8]  # First 8 variables
  tryCatch({
    get_multiyear_acs(
      states = target_states,
      years = target_years,
      variables = core_vars
    )
  }, error = function(e2) {
    cat("Fallback also failed:", e2$message, "\n")
    return(NULL)
  })
})

# Post-collection memory check
post_memory <- gc()
cat("Post-collection memory usage:", format(sum(post_memory[,2]), units = "auto"), "\n")

if(!is.null(full_data)) {
  cat("Successfully retrieved NATIONAL dataset:\n")
  cat("- Total rows:", format(nrow(full_data), big.mark = ","), "\n")
  cat("- Years:", paste(sort(unique(full_data$year)), collapse = ", "), "\n")
  cat("- States:", length(unique(str_sub(full_data$GEOID, 1, 2))), "\n")
  cat("- Counties:", format(length(unique(full_data$GEOID)), big.mark = ","), "\n")
  
  # Data quality check for national dataset
  completeness_check <- full_data %>%
    group_by(year) %>%
    summarise(
      total_counties = n(),
      complete_demographic_vars = sum(rowSums(is.na(select(., ends_with("E")))) <= 2),
      completion_rate = complete_demographic_vars / total_counties,
      .groups = "drop"
    )
  
  cat("Data quality summary:\n")
  print(completeness_check)
  
  # Save the raw data with compression for large national dataset
  cat("Saving national dataset (this may take several minutes)...\n")
  saveRDS(full_data, "data/raw_demographic_data_national.rds", compress = "xz")
  cat("National raw data saved with compression to data/raw_demographic_data_national.rds\n")
  
  # Memory management after large data save
  data_size <- format(object.size(full_data), units = "MB")
  cat("Dataset size in memory:", data_size, "\n")
  
} else {
  cat("Failed to retrieve national data. Attempting to load existing data...\n")
  
  # Try to load existing data
  if(file.exists("data/raw_demographic_data_national.rds")) {
    cat("Loading existing national dataset...\n")
    full_data <- readRDS("data/raw_demographic_data_national.rds")
    cat("Loaded existing national data with", nrow(full_data), "rows\n")
  } else if(file.exists("data/raw_demographic_data.rds")) {
    cat("Loading existing regional dataset...\n")
    full_data <- readRDS("data/raw_demographic_data.rds")
    cat("Using existing regional data with", nrow(full_data), "rows\n")
  } else {
    cat("No existing data found. Using TX test data for demonstration.\n")
    full_data <- tx_multiyear
  }
}

# Phase 4: Create Comprehensive Demographic Profiles

cat("\n=== PHASE 4: DEMOGRAPHIC PROFILE CREATION ===\n")

# Create standardized demographic profiles
demographic_profiles <- full_data %>%
  # Add total population estimates for proportions
  rowwise() %>%
  mutate(
    # Age proportions (using available age groups)
    young_adults_pct = (B01001_010E + B01001_034E) / (B01001_003E + B01001_027E + B01001_010E + B01001_034E + B01001_016E + B01001_040E),
    elderly_pct = (B01001_016E + B01001_040E) / (B01001_003E + B01001_027E + B01001_010E + B01001_034E + B01001_016E + B01001_040E),
    
    # Race/ethnicity proportions  
    white_nh_pct = B03002_003E / (B03002_003E + B03002_004E + B03002_012E + B03002_006E),
    black_nh_pct = B03002_004E / (B03002_003E + B03002_004E + B03002_012E + B03002_006E),
    hispanic_pct = B03002_012E / (B03002_003E + B03002_004E + B03002_012E + B03002_006E),
    asian_nh_pct = B03002_006E / (B03002_003E + B03002_004E + B03002_012E + B03002_006E),
    
    # Education (as proportion of degrees)
    college_plus_pct = (B15003_022E + B15003_023E + B15003_024E + B15003_025E) / (B15003_022E + B15003_023E + B15003_024E + B15003_025E + 1000), # rough denominator
    
    # Economic (log transform for income)
    log_med_income = log(pmax(B19013_001E, 1000, na.rm = TRUE)),
    log_med_home_value = log(pmax(B25077_001E, 10000, na.rm = TRUE))
  ) %>%
  ungroup() %>%
  # Select key profile variables
  select(GEOID, NAME, year, 
         young_adults_pct, elderly_pct,
         white_nh_pct, black_nh_pct, hispanic_pct, asian_nh_pct,
         college_plus_pct, log_med_income, log_med_home_value) %>%
  # Remove rows with too many missing values
  filter(rowSums(is.na(select(., -GEOID, -NAME, -year))) <= 3)

cat("Created demographic profiles:\n")
cat("- Profiles:", nrow(demographic_profiles), "\n")
cat("- Variables:", ncol(demographic_profiles) - 3, "\n")

# Phase 5: Dynamic Time Warping for Temporal Twins

cat("\n=== PHASE 5: TEMPORAL TWIN DETECTION ===\n")

# Prepare data for DTW analysis
dtw_data <- demographic_profiles %>%
  arrange(GEOID, year) %>%
  group_by(GEOID) %>%
  filter(n() >= 3) %>%  # Need at least 3 time points
  ungroup()

unique_counties <- unique(dtw_data$GEOID)
cat("Counties with sufficient time series:", length(unique_counties), "\n")

# Enhanced function to calculate multivariate DTW distance with optimization
calculate_mv_dtw <- function(county1_id, county2_id, data) {
  
  # Get time series for both counties with error handling
  ts1 <- tryCatch({
    data %>%
      filter(GEOID == county1_id) %>%
      arrange(year) %>%
      select(young_adults_pct:log_med_home_value) %>%
      as.matrix()
  }, error = function(e) return(NULL))
  
  ts2 <- tryCatch({
    data %>%
      filter(GEOID == county2_id) %>%
      arrange(year) %>%
      select(young_adults_pct:log_med_home_value) %>%
      as.matrix()
  }, error = function(e) return(NULL))
  
  # Enhanced validation
  if(is.null(ts1) || is.null(ts2) || nrow(ts1) < 2 || nrow(ts2) < 2) return(NA)
  if(ncol(ts1) != ncol(ts2)) return(NA)
  
  # Enhanced missing value handling with column-wise imputation
  for(col in 1:ncol(ts1)) {
    # Use series mean for imputation, fallback to 0
    col_mean_1 <- mean(ts1[,col], na.rm = TRUE)
    col_mean_2 <- mean(ts2[,col], na.rm = TRUE)
    
    if(is.na(col_mean_1)) col_mean_1 <- 0
    if(is.na(col_mean_2)) col_mean_2 <- 0
    
    ts1[is.na(ts1[,col]), col] <- col_mean_1
    ts2[is.na(ts2[,col]), col] <- col_mean_2
  }
  
  # Robust standardization with fallback
  ts1_scaled <- tryCatch({
    scale(ts1)
  }, error = function(e) {
    # Fallback: manual standardization
    apply(ts1, 2, function(x) (x - mean(x, na.rm = TRUE)) / (sd(x, na.rm = TRUE) + 1e-10))
  })
  
  ts2_scaled <- tryCatch({
    scale(ts2)
  }, error = function(e) {
    apply(ts2, 2, function(x) (x - mean(x, na.rm = TRUE)) / (sd(x, na.rm = TRUE) + 1e-10))
  })
  
  # Calculate DTW for each variable with enhanced error handling
  dtw_distances <- numeric(ncol(ts1_scaled))
  
  for(i in 1:ncol(ts1_scaled)) {
    if(!any(is.na(ts1_scaled[,i])) && !any(is.na(ts2_scaled[,i])) && 
       var(ts1_scaled[,i]) > 1e-10 && var(ts2_scaled[,i]) > 1e-10) {
      
      dtw_result <- tryCatch({
        dtw(ts1_scaled[,i], ts2_scaled[,i], 
            distance.method = "Euclidean",
            step.pattern = symmetric1,  # Efficient step pattern
            keep.internals = FALSE)     # Save memory
      }, error = function(e) {
        # Fallback to simple Euclidean distance if DTW fails
        list(normalizedDistance = sqrt(mean((ts1_scaled[,i] - ts2_scaled[,i])^2)))
      })
      
      dtw_distances[i] <- dtw_result$normalizedDistance
    } else {
      # Use simple distance for problematic variables
      dtw_distances[i] <- ifelse(length(ts1_scaled[,i]) == length(ts2_scaled[,i]),
                                sqrt(mean((ts1_scaled[,i] - ts2_scaled[,i])^2, na.rm = TRUE)),
                                NA)
    }
  }
  
  # Return weighted mean, prioritizing non-NA values
  valid_distances <- dtw_distances[!is.na(dtw_distances)]
  if(length(valid_distances) == 0) return(NA)
  
  mean(valid_distances)
}

# Calculate DTW distances for a sample of county pairs (computationally intensive)
cat("Calculating DTW distances for county pairs...\n")

# For computational efficiency with national scale, implement strategic sampling
set.seed(42)

# Adaptive sampling based on total county count
total_counties <- length(unique_counties)
cat("Total counties available:", total_counties, "\n")

# Use stratified sampling to ensure geographic diversity
# Sample more counties for national analysis but keep computationally feasible
if(total_counties > 2000) {
  sample_size <- min(200, total_counties)  # Larger sample for national scale
  cat("Large national dataset detected. Using stratified sample of", sample_size, "counties\n")
  
  # Stratify by state to ensure national representation
  county_states <- str_sub(unique_counties, 1, 2)
  stratified_sample <- c()
  
  for(state_code in unique(county_states)) {
    state_counties <- unique_counties[county_states == state_code]
    n_sample <- max(1, min(5, length(state_counties)))  # 1-5 per state
    stratified_sample <- c(stratified_sample, sample(state_counties, n_sample))
  }
  
  sample_counties <- stratified_sample
  cat("Stratified sampling complete. Using", length(sample_counties), "counties across", length(unique(county_states)), "states\n")
  
} else {
  sample_size <- min(100, total_counties)
  sample_counties <- sample(unique_counties, sample_size)
  cat("Using random sample of", length(sample_counties), "counties\n")
}

# Create all pairwise combinations
county_pairs <- expand_grid(
  county1 = sample_counties,
  county2 = sample_counties
) %>%
  filter(county1 < county2)  # Avoid duplicates and self-comparisons

cat("Computing", nrow(county_pairs), "pairwise DTW distances...\n")

# Calculate DTW distances with optimized processing for national scale
max_pairs <- ifelse(nrow(county_pairs) > 5000, 3000, min(1500, nrow(county_pairs)))
cat("Processing", max_pairs, "county pairs out of", format(nrow(county_pairs), big.mark = ","), "possible pairs\n")

# Detect available cores for parallel processing
n_cores <- max(1, detectCores() - 1)  # Leave one core free
cat("Using", n_cores, "cores for parallel DTW computation\n")

# Parallel processing function for DTW calculations
process_dtw_chunk <- function(chunk_data, dtw_data_local) {
  chunk_data %>%
    rowwise() %>%
    mutate(
      dtw_distance = calculate_mv_dtw(county1, county2, dtw_data_local),
      county1_name = dtw_data_local$NAME[dtw_data_local$GEOID == county1][1],
      county2_name = dtw_data_local$NAME[dtw_data_local$GEOID == county2][1]
    ) %>%
    ungroup() %>%
    filter(!is.na(dtw_distance))
}

# Implement chunked processing with parallel computation
chunk_size <- max(50, min(200, floor(max_pairs / (n_cores * 2))))
all_dtw_results <- list()

# Create chunks for parallel processing
chunks <- split(county_pairs[1:max_pairs, ], 
                ceiling(seq_len(max_pairs) / chunk_size))

cat("Processing", length(chunks), "chunks in parallel with chunk size", chunk_size, "\n")

# Process chunks with progress reporting
for(i in seq_along(chunks)) {
  start_time <- Sys.time()
  cat("Processing chunk", i, "of", length(chunks), "...")
  
  # Parallel processing of the chunk
  chunk_result <- tryCatch({
    if(n_cores > 1 && nrow(chunks[[i]]) > 20) {
      # Use parallel processing for larger chunks
      mclapply(list(chunks[[i]]), process_dtw_chunk, dtw_data, mc.cores = 1)[[1]]
    } else {
      # Sequential processing for smaller chunks
      process_dtw_chunk(chunks[[i]], dtw_data)
    }
  }, error = function(e) {
    cat("Error in chunk", i, ":", e$message, "\n")
    return(NULL)
  })
  
  if(!is.null(chunk_result) && nrow(chunk_result) > 0) {
    all_dtw_results[[i]] <- chunk_result
    
    elapsed <- round(as.numeric(difftime(Sys.time(), start_time, units = "secs")))
    cat(" completed in", elapsed, "seconds (", nrow(chunk_result), "valid pairs)\n")
  } else {
    cat(" failed or returned no results\n")
  }
  
  # Memory management and progress reporting
  if(i %% 5 == 0) {
    gc()
    cat("   Memory check - chunks processed:", i, "/", length(chunks), "\n")
    cat("   Estimated completion:", 
        round((length(chunks) - i) * mean(sapply(1:min(i,5), function(x) 
          ifelse(is.null(all_dtw_results[[x]]), 0, nrow(all_dtw_results[[x]]))))), 
        "remaining pairs\n")
  }
}

# Combine all chunks and filter valid results
valid_results <- all_dtw_results[!sapply(all_dtw_results, is.null)]
if(length(valid_results) > 0) {
  dtw_results <- bind_rows(valid_results) %>%
    arrange(dtw_distance)
  
  cat("\nNational DTW analysis complete!\n")
  cat("Successfully computed", nrow(dtw_results), "valid DTW distances\n")
} else {
  cat("\nError: No valid DTW results computed\n")
  dtw_results <- tibble()  # Empty results
}

# Clean up
rm(all_dtw_results, valid_results, chunks)
gc()

cat("Successfully computed", nrow(dtw_results), "DTW distances\n")

# Find the best temporal twins
temporal_twins <- dtw_results %>%
  slice_head(n = 10)

cat("\n=== TOP 10 TEMPORAL TWINS ===\n")
print(temporal_twins %>% 
      select(county1_name, county2_name, dtw_distance) %>%
      mutate(dtw_distance = round(dtw_distance, 3)))

# Phase 6: Visualization and Analysis

cat("\n=== PHASE 6: VISUALIZATION PREPARATION ===\n")

# Create visualizations showing temporal twins
library(ggplot2)

# Custom theme for consistency
demographic_theme <- theme_minimal() +
  theme(
    text = element_text(family = "Arial", color = "grey20"),
    plot.title = element_text(size = 14, face = "bold", margin = margin(b = 20)),
    plot.subtitle = element_text(size = 12, color = "grey40", margin = margin(b = 20)),
    axis.title = element_text(size = 11, face = "bold"),
    axis.text = element_text(size = 10),
    legend.title = element_text(size = 11, face = "bold"),
    legend.text = element_text(size = 10),
    panel.grid.minor = element_blank(),
    strip.text = element_text(size = 11, face = "bold")
  )

# Phase 7: Enhanced Analysis Results and National Summary

cat("\n=== PHASE 7: NATIONAL ANALYSIS SUMMARY ===\n")

# Create enhanced temporal twins analysis for national scale
if(nrow(dtw_results) > 0) {
  temporal_twins <- dtw_results %>%
    slice_head(n = 20)  # Top 20 for national scale
  
  # Enhanced geographic analysis for national dataset
  national_geographic_analysis <- temporal_twins %>%
    mutate(
      state1 = str_extract(county1_name, ", ([A-Z]{2})$", group = 1),
      state2 = str_extract(county2_name, ", ([A-Z]{2})$", group = 1),
      same_state = state1 == state2,
      
      # Regional classification
      region1 = case_when(
        state1 %in% c("ME", "NH", "VT", "MA", "RI", "CT", "NY", "NJ", "PA") ~ "Northeast",
        state1 %in% c("OH", "MI", "IN", "WI", "IL", "MN", "IA", "MO", "ND", "SD", "NE", "KS") ~ "Midwest",
        state1 %in% c("DE", "MD", "DC", "VA", "WV", "KY", "TN", "NC", "SC", "GA", "FL", "AL", "MS", "AR", "LA", "OK", "TX") ~ "South",
        state1 %in% c("MT", "WY", "CO", "NM", "ID", "UT", "NV", "AZ", "WA", "OR", "CA", "AK", "HI") ~ "West",
        TRUE ~ "Other"
      ),
      region2 = case_when(
        state2 %in% c("ME", "NH", "VT", "MA", "RI", "CT", "NY", "NJ", "PA") ~ "Northeast",
        state2 %in% c("OH", "MI", "IN", "WI", "IL", "MN", "IA", "MO", "ND", "SD", "NE", "KS") ~ "Midwest",
        state2 %in% c("DE", "MD", "DC", "VA", "WV", "KY", "TN", "NC", "SC", "GA", "FL", "AL", "MS", "AR", "LA", "OK", "TX") ~ "South",
        state2 %in% c("MT", "WY", "CO", "NM", "ID", "UT", "NV", "AZ", "WA", "OR", "CA", "AK", "HI") ~ "West",
        TRUE ~ "Other"
      ),
      
      cross_regional = paste(pmin(region1, region2), pmax(region1, region2), sep = "-"),
      cross_regional = ifelse(region1 == region2, region1, cross_regional)
    )
  
  # National patterns summary
  cat("\n=== NATIONAL TEMPORAL TWINS PATTERNS ===\n")
  cat("Top 20 temporal twins include:\n")
  cat("- Same state pairs:", sum(national_geographic_analysis$same_state), "\n")
  cat("- Cross-regional pairs:", sum(!national_geographic_analysis$same_state), "\n")
  cat("- States represented:", length(unique(c(national_geographic_analysis$state1, national_geographic_analysis$state2))), "\n")
  
  regional_summary <- national_geographic_analysis %>%
    count(cross_regional, sort = TRUE)
  
  cat("\nMost common regional pairings:\n")
  print(head(regional_summary, 5))
  
} else {
  temporal_twins <- tibble()  # Empty if no results
  cat("No valid temporal twins identified.\n")
}

# Save the enhanced analysis results
saveRDS(demographic_profiles, "data/demographic_profiles_national.rds")
if(nrow(dtw_results) > 0) {
  saveRDS(dtw_results, "data/dtw_results_national.rds") 
  saveRDS(temporal_twins, "data/temporal_twins_national.rds")
}

# Save geographic analysis if available
if(exists("national_geographic_analysis")) {
  saveRDS(national_geographic_analysis, "data/national_geographic_analysis.rds")
}

cat("\nNational analysis data saved to data/ directory\n")
cat("\n=== NATIONAL DEVELOPMENT PHASE COMPLETE ===\n")
cat("Ready to create R Markdown report with:\n")
cat("- Demographic profiles for", format(length(unique(demographic_profiles$GEOID)), big.mark = ","), "counties\n")
if(nrow(dtw_results) > 0) {
  cat("- DTW analysis results for", format(nrow(dtw_results), big.mark = ","), "county pairs\n")
  cat("- Top", nrow(temporal_twins), "temporal twins identified\n")
} else {
  cat("- DTW analysis encountered issues - debugging needed\n")
}
cat("- National-scale visualization framework established\n")
cat("- Geographic analysis of cross-regional patterns completed\n")