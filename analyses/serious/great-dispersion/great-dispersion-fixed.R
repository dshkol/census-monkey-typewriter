# The Great Dispersion: Remote Work Demographic Reshuffling (Fixed)
# 
# Hypothesis: Counties experiencing anomalous population growth beyond 
# pre-pandemic trends show increases in remote-capable populations.
# Using PEP 2015-2023 with correct vintage parameters + education as remote work proxy.

library(tidyverse)
library(tidycensus)
library(scales)
library(ggplot2)

# Set API key
census_api_key(Sys.getenv("CENSUS_API_KEY"))

cat("=== THE GREAT DISPERSION ANALYSIS (FIXED) ===\n")
cat("Testing remote work demographic reshuffling using PEP 2015-2023 data\n")
cat("Using education levels as proxy for remote work capability\n\n")

# Step 1: Get PEP data with correct vintage parameters
cat("=== STEP 1: PEP POPULATION DATA (CORRECTED) ===\n")

# Function to get PEP data with proper vintage handling
get_pep_corrected <- function(year) {
  cat("Getting PEP data for", year, "...\n")
  tryCatch({
    if (year <= 2019) {
      # Pre-2020 data uses standard year parameter
      get_estimates(
        geography = "county",
        product = "population",
        year = year,
        state = NULL
      )
    } else {
      # Post-2020 data requires vintage parameter
      get_estimates(
        geography = "county",
        product = "population",
        vintage = year,
        year = year,
        state = NULL
      )
    }
  }, error = function(e) {
    cat("Error for year", year, ":", e$message, "\n")
    return(NULL)
  })
}

# Get data for available years
pep_years <- c(2015:2019, 2021:2023)  # Skip 2020 (not available)
pep_data_list <- map(pep_years, get_pep_corrected)

# Remove NULL results and combine
pep_data_clean <- pep_data_list %>%
  compact() %>%
  map_dfr(~ .x %>% 
    filter(variable == "POP") %>%
    mutate(year = first(pep_years[map_lgl(pep_data_list, ~ !is.null(.x) && identical(.x, .x))])))

# Clean data manually since automatic year assignment is complex
pep_final <- tibble()
for (i in seq_along(pep_data_list)) {
  if (!is.null(pep_data_list[[i]])) {
    year_data <- pep_data_list[[i]] %>%
      filter(variable == "POP") %>%
      mutate(year = pep_years[i]) %>%
      select(GEOID, NAME, year, population = value)
    pep_final <- bind_rows(pep_final, year_data)
  }
}

cat("PEP data collected for years:", paste(unique(pep_final$year), collapse = ", "), "\n")
cat("Total county-year observations:", nrow(pep_final), "\n")

# Clean and filter data
pep_clean <- pep_final %>%
  filter(!is.na(population), population > 0) %>%
  # Extract state and county FIPS
  mutate(
    state_fips = str_sub(GEOID, 1, 2),
    county_fips = str_sub(GEOID, 3, 5)
  ) %>%
  # Filter to continental US only
  filter(
    state_fips %in% c("01", "04", "05", "06", "08", "09", "10", "11", "12", "13", 
                      "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", 
                      "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", 
                      "36", "37", "38", "39", "40", "41", "42", "44", "45", "46", 
                      "47", "48", "49", "50", "51", "53", "54", "55", "56"),
    population >= 1000  # Exclude tiny counties
  ) %>%
  arrange(GEOID, year)

cat("Continental US counties in analysis:", length(unique(pep_clean$GEOID)), "\n")

# Step 2: Calculate growth trends
cat("\n=== STEP 2: GROWTH TREND ANALYSIS ===\n")

# Calculate year-over-year growth rates
growth_rates <- pep_clean %>%
  group_by(GEOID) %>%
  arrange(year) %>%
  mutate(
    pop_lag = lag(population),
    growth_rate = (population - pop_lag) / pop_lag,
    growth_pct = growth_rate * 100
  ) %>%
  filter(!is.na(growth_rate)) %>%
  ungroup()

# Define pre-pandemic (2015-2019) and pandemic+ periods (2021-2023)
pre_pandemic <- growth_rates %>%
  filter(year >= 2016, year <= 2019) %>%  # Growth rates 2016-2019
  group_by(GEOID) %>%
  summarise(
    pre_mean_growth = mean(growth_rate, na.rm = TRUE),
    pre_sd_growth = sd(growth_rate, na.rm = TRUE),
    pre_years = n(),
    .groups = "drop"
  ) %>%
  filter(pre_years >= 3)  # Require at least 3 years

pandemic_period <- growth_rates %>%
  filter(year >= 2021, year <= 2023) %>%  # Post-pandemic growth
  group_by(GEOID) %>%
  summarise(
    pandemic_mean_growth = mean(growth_rate, na.rm = TRUE),
    pandemic_sd_growth = sd(growth_rate, na.rm = TRUE),
    pandemic_years = n(),
    .groups = "drop"
  ) %>%
  filter(pandemic_years >= 2)

# Combine and identify anomalous growth
growth_analysis <- pre_pandemic %>%
  inner_join(pandemic_period, by = "GEOID") %>%
  mutate(
    # Calculate growth differential
    growth_differential = pandemic_mean_growth - pre_mean_growth,
    growth_differential_pct = growth_differential * 100,
    
    # Z-score: how many standard deviations above pre-pandemic trend?
    z_score = ifelse(pre_sd_growth > 0, 
                     growth_differential / pre_sd_growth, 
                     NA),
    
    # Classify counties
    growth_category = case_when(
      z_score >= 2 ~ "High Anomalous Growth",
      z_score >= 1 ~ "Moderate Anomalous Growth", 
      z_score >= -1 ~ "Normal Growth",
      z_score >= -2 ~ "Moderate Decline",
      TRUE ~ "High Decline"
    ),
    
    # Flag extreme outliers
    anomalous_growth = z_score >= 2 & !is.na(z_score)
  )

cat("Counties with anomalous growth (>2 SD above pre-pandemic trend):", 
    sum(growth_analysis$anomalous_growth, na.rm = TRUE), "\n")

# Get county names
county_details <- pep_clean %>%
  filter(year == 2023) %>%
  select(GEOID, NAME, population_2023 = population)

growth_with_names <- growth_analysis %>%
  left_join(county_details, by = "GEOID")

# Display top anomalous growth counties
if (sum(growth_analysis$anomalous_growth, na.rm = TRUE) > 0) {
  cat("\nTop 15 counties with most anomalous growth:\n")
  anomalous_counties <- growth_with_names %>%
    filter(!is.na(z_score)) %>%
    arrange(desc(z_score)) %>%
    head(15) %>%
    select(NAME, growth_differential_pct, z_score, population_2023) %>%
    mutate(
      growth_differential_pct = round(growth_differential_pct, 2),
      z_score = round(z_score, 2),
      population_2023 = comma(population_2023)
    )
  
  print(anomalous_counties)
}

# Step 3: Get education data as remote work proxy
cat("\n=== STEP 3: EDUCATION DATA (REMOTE WORK PROXY) ===\n")

# Higher education typically correlates with remote work capability
get_education_data <- function(year) {
  cat("Getting education data for", year, "...\n")
  tryCatch({
    get_acs(
      geography = "county",
      variables = c(
        "B15003_001",  # Total population 25+
        "B15003_022",  # Bachelor's degree
        "B15003_023",  # Master's degree
        "B15003_024",  # Professional degree
        "B15003_025"   # Doctorate
      ),
      year = year,
      output = "wide",
      survey = "acs5"
    ) %>%
      mutate(
        year = year,
        # Calculate higher education share
        total_25plus = B15003_001E,
        bachelors_plus = B15003_022E + B15003_023E + B15003_024E + B15003_025E,
        college_share = ifelse(total_25plus > 0, bachelors_plus / total_25plus, NA),
        college_pct = college_share * 100
      ) %>%
      select(GEOID, NAME, year, total_25plus, bachelors_plus, college_share, college_pct)
  }, error = function(e) {
    cat("Error getting education data for", year, ":", e$message, "\n")
    return(NULL)
  })
}

# Get education data for comparison periods
education_2019 <- get_education_data(2019)  # Pre-pandemic
education_2022 <- get_education_data(2022)  # Most recent available

if (!is.null(education_2019) && !is.null(education_2022)) {
  
  # Calculate education changes
  education_change <- education_2019 %>%
    select(GEOID, college_2019 = college_pct) %>%
    inner_join(
      education_2022 %>% select(GEOID, college_2022 = college_pct),
      by = "GEOID"
    ) %>%
    mutate(
      college_change = college_2022 - college_2019,
      college_change_pct = (college_2022 - college_2019) / college_2019 * 100
    )
  
  cat("Counties with education data for both periods:", nrow(education_change), "\n")
  
  # Step 4: Test the main hypothesis
  cat("\n=== STEP 4: HYPOTHESIS TESTING ===\n")
  
  # Combine population growth and education data
  main_analysis <- growth_with_names %>%
    inner_join(education_change, by = "GEOID") %>%
    filter(!is.na(z_score), !is.na(college_change), !is.na(population_2023))
  
  cat("Counties with both population and education data:", nrow(main_analysis), "\n")
  
  if (nrow(main_analysis) > 50) {
    
    # Correlation test
    cor_test <- cor.test(main_analysis$z_score, main_analysis$college_change)
    
    cat("Correlation between population growth anomaly and college education change:\n")
    cat("  Correlation coefficient:", round(cor_test$estimate, 3), "\n")
    cat("  P-value:", format.pval(cor_test$p.value), "\n")
    cat("  95% CI: [", round(cor_test$conf.int[1], 3), ", ", 
        round(cor_test$conf.int[2], 3), "]\n")
    
    # Regression analysis
    model <- lm(college_change ~ z_score + log(population_2023) + 
                I(pre_mean_growth * 100), data = main_analysis)
    
    cat("\nRegression results (College education change ~ Growth anomaly):\n")
    model_summary <- summary(model)
    print(model_summary)
    
    # Compare high vs normal growth counties
    high_growth <- main_analysis %>%
      filter(anomalous_growth == TRUE)
    
    normal_growth <- main_analysis %>%
      filter(growth_category == "Normal Growth")
    
    if (nrow(high_growth) > 5 && nrow(normal_growth) > 10) {
      t_test <- t.test(high_growth$college_change, normal_growth$college_change)
      
      cat("\nComparison: High anomalous growth vs Normal growth counties\n")
      cat("  High growth mean college education change:", 
          round(mean(high_growth$college_change, na.rm = TRUE), 2), "%\n")
      cat("  Normal growth mean college education change:", 
          round(mean(normal_growth$college_change, na.rm = TRUE), 2), "%\n")
      cat("  T-test p-value:", format.pval(t_test$p.value), "\n")
    }
    
    # Step 5: Visualizations
    cat("\n=== STEP 5: VISUALIZATIONS ===\n")
    
    # Plot 1: Growth anomaly distribution
    p1 <- main_analysis %>%
      ggplot(aes(x = z_score)) +
      geom_histogram(bins = 30, fill = "grey20", alpha = 0.7) +
      geom_vline(xintercept = 2, color = "red", linetype = "dashed") +
      labs(
        title = "Distribution of County Population Growth Anomalies",
        subtitle = "Z-score: Standard deviations above pre-pandemic trend • Red line = anomalous threshold",
        x = "Growth Anomaly Z-Score",
        y = "Count of Counties"
      ) +
      theme_minimal()
    
    print(p1)
    
    # Plot 2: Main hypothesis test
    p2 <- main_analysis %>%
      ggplot(aes(x = z_score, y = college_change)) +
      geom_point(alpha = 0.6, color = "grey20") +
      geom_smooth(method = "lm", color = "red") +
      geom_hline(yintercept = 0, color = "grey50", linetype = "dashed") +
      geom_vline(xintercept = 2, color = "red", linetype = "dashed", alpha = 0.5) +
      labs(
        title = "Population Growth Anomaly vs. College Education Change",
        subtitle = "Testing if counties with anomalous growth show increased college-educated populations",
        x = "Population Growth Anomaly (Z-Score)",
        y = "Change in College Education Share (%)"
      ) +
      theme_minimal()
    
    print(p2)
    
    # Plot 3: Growth categories comparison
    p3 <- main_analysis %>%
      mutate(growth_category = fct_reorder(growth_category, z_score)) %>%
      ggplot(aes(x = growth_category, y = college_change)) +
      geom_boxplot(fill = "grey20", alpha = 0.7) +
      geom_hline(yintercept = 0, color = "red", linetype = "dashed") +
      coord_flip() +
      labs(
        title = "College Education Changes by County Growth Category",
        subtitle = "Do high-growth counties attract more college-educated residents?",
        x = "Growth Category",
        y = "Change in College Education Share (%)"
      ) +
      theme_minimal()
    
    print(p3)
    
    # Step 6: Specific examples
    cat("\n=== STEP 6: SPECIFIC EXAMPLES ===\n")
    
    if (nrow(high_growth) > 0) {
      cat("Counties with both high anomalous growth AND increasing college education:\n")
      winners <- high_growth %>%
        filter(college_change > 0) %>%
        arrange(desc(z_score)) %>%
        head(10)
      
      if (nrow(winners) > 0) {
        print(winners %>%
                select(NAME, z_score, growth_differential_pct, college_change) %>%
                mutate_if(is.numeric, round, 2))
      }
    }
    
    # Summary results
    cat("\n=== SUMMARY RESULTS ===\n")
    
    if (cor_test$p.value < 0.05) {
      cat("HYPOTHESIS SUPPORTED: Significant correlation found between population growth anomalies and college education changes\n")
      cat("  Correlation:", round(cor_test$estimate, 3), " (p =", format.pval(cor_test$p.value), ")\n")
    } else {
      cat("HYPOTHESIS NOT SUPPORTED: No significant correlation between growth and college education\n")
      cat("  Correlation:", round(cor_test$estimate, 3), " (p =", format.pval(cor_test$p.value), ")\n")
    }
    
    cat("Counties with anomalous growth (>2 SD):", sum(main_analysis$anomalous_growth), "\n")
    cat("Mean college education change in high-growth counties:", 
        round(mean(high_growth$college_change, na.rm = TRUE), 2), "%\n")
    
  } else {
    cat("Insufficient data for hypothesis testing (n =", nrow(main_analysis), ")\n")
  }
  
} else {
  cat("Unable to obtain education data for analysis\n")
}

cat("\n=== ANALYSIS COMPLETE ===\n")