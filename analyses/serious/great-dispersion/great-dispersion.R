# The Great Dispersion: Quantifying Remote Work's Demographic Reshuffling
# 
# Hypothesis: Counties experiencing anomalous population growth beyond 
# pre-pandemic trends show decreases in physically-present occupations.
# Using PEP annual data 2019-2024 to identify remote work migration patterns.

library(tidyverse)
library(tidycensus)
library(scales)
library(ggplot2)

# Set API key
census_api_key(Sys.getenv("CENSUS_API_KEY"))

cat("=== THE GREAT DISPERSION ANALYSIS ===\n")
cat("Testing remote work demographic reshuffling using PEP 2019-2024 data\n")
cat("Hypothesis: Anomalous post-2020 growth correlates with remote-capable occupation shifts\n\n")

# Step 1: Get Population Estimates Program (PEP) data
cat("=== STEP 1: PEP POPULATION DATA ACQUISITION ===\n")

# Get annual county population estimates
cat("Fetching PEP annual population estimates 2015-2023...\n")

# Function to get PEP data for a specific year
get_pep_year <- function(year) {
  cat("Getting PEP data for", year, "...\n")
  tryCatch({
    get_estimates(
      geography = "county",
      product = "population",
      year = year,
      state = NULL
    ) %>%
      mutate(year = year) %>%
      filter(variable == "POP") %>%
      select(GEOID, NAME, year, population = value)
  }, error = function(e) {
    cat("Error for year", year, ":", e$message, "\n")
    return(NULL)
  })
}

# Get data for available years (PEP typically available 2015-2023)
pep_years <- 2015:2023
pep_data_list <- map(pep_years, get_pep_year)

# Remove NULL results and combine
pep_data_clean <- pep_data_list %>%
  compact() %>%
  bind_rows()

cat("PEP data collected for years:", paste(unique(pep_data_clean$year), collapse = ", "), "\n")
cat("Total county-year observations:", nrow(pep_data_clean), "\n")

# Clean and standardize county identifiers
pep_clean <- pep_data_clean %>%
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
                      "47", "48", "49", "50", "51", "53", "54", "55", "56")
  ) %>%
  arrange(GEOID, year)

cat("Continental US counties in analysis:", length(unique(pep_clean$GEOID)), "\n")

# Step 2: Calculate growth trends and identify anomalous counties
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

# Define pre-pandemic (2015-2019) and pandemic periods (2020-2023)
pre_pandemic <- growth_rates %>%
  filter(year >= 2016, year <= 2019) %>%  # 2016-2019 growth rates
  group_by(GEOID) %>%
  summarise(
    pre_mean_growth = mean(growth_rate, na.rm = TRUE),
    pre_sd_growth = sd(growth_rate, na.rm = TRUE),
    pre_years = n(),
    .groups = "drop"
  ) %>%
  filter(pre_years >= 3)  # Require at least 3 years of pre-pandemic data

pandemic_period <- growth_rates %>%
  filter(year >= 2020, year <= 2023) %>%
  group_by(GEOID) %>%
  summarise(
    pandemic_mean_growth = mean(growth_rate, na.rm = TRUE),
    pandemic_sd_growth = sd(growth_rate, na.rm = TRUE),
    pandemic_years = n(),
    .groups = "drop"
  ) %>%
  filter(pandemic_years >= 2)  # Require at least 2 years of pandemic data

# Combine periods and identify anomalous growth
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
    
    # Flag extreme outliers (>2 SD above trend)
    anomalous_growth = z_score >= 2 & !is.na(z_score)
  )

cat("Counties with anomalous growth (>2 SD above pre-pandemic trend):", 
    sum(growth_analysis$anomalous_growth, na.rm = TRUE), "\n")

# Get county names and demographics
county_details <- pep_clean %>%
  filter(year == 2023) %>%  # Most recent year
  select(GEOID, NAME, population_2023 = population)

growth_with_names <- growth_analysis %>%
  left_join(county_details, by = "GEOID")

# Display top anomalous growth counties
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

# Step 3: Get occupation data for remote work analysis
cat("\n=== STEP 3: OCCUPATION DATA ANALYSIS ===\n")

# Get ACS occupation data for pre-pandemic and recent periods
cat("Fetching ACS occupation data...\n")

# Remote-capable occupations (based on telework feasibility research)
remote_capable_codes <- c(
  "B24010_005",  # Management occupations
  "B24010_006",  # Business and financial operations  
  "B24010_007",  # Computer, engineering, and science
  "B24010_015",  # Arts, design, entertainment, sports, and media
  "B24010_016",  # Healthcare practitioners and technical (some remote)
  "B24010_017",  # Healthcare support (some remote - telehealth)
  "B24010_030",  # Sales and related (some remote)
  "B24010_031",  # Office and administrative support
  "B24010_035"   # Legal occupations (included in management in some tables)
)

# Function to get occupation data for a year
get_occupation_data <- function(year) {
  cat("Getting occupation data for", year, "...\n")
  tryCatch({
    get_acs(
      geography = "county",
      table = "B24010", # Sex by occupation for the civilian employed population 16 years and over
      year = year,
      output = "wide",
      survey = "acs5"
    ) %>%
      mutate(year = year) %>%
      # Calculate remote-capable occupation share
      mutate(
        total_employed = B24010_001E,
        management = B24010_005E + B24010_006E, # Management + Business/Financial
        computer_eng_sci = B24010_007E,
        arts_media = B24010_015E,
        healthcare_pro = B24010_016E,
        sales_office = B24010_030E + B24010_031E, # Sales + Office/Admin
        
        # Sum remote-capable occupations
        remote_capable = management + computer_eng_sci + arts_media + 
                        healthcare_pro + sales_office,
        
        # Calculate share
        remote_capable_share = ifelse(total_employed > 0, 
                                    remote_capable / total_employed, 
                                    NA),
        remote_capable_pct = remote_capable_share * 100
      ) %>%
      select(GEOID, NAME, year, total_employed, remote_capable, 
             remote_capable_share, remote_capable_pct)
  }, error = function(e) {
    cat("Error getting occupation data for", year, ":", e$message, "\n")
    return(NULL)
  })
}

# Get occupation data for comparison years
occupation_2019 <- get_occupation_data(2019)  # Pre-pandemic
occupation_2022 <- get_occupation_data(2022)  # Most recent available

if (!is.null(occupation_2019) && !is.null(occupation_2022)) {
  
  # Calculate occupation changes
  occupation_change <- occupation_2019 %>%
    select(GEOID, remote_2019 = remote_capable_pct) %>%
    inner_join(
      occupation_2022 %>% select(GEOID, remote_2022 = remote_capable_pct),
      by = "GEOID"
    ) %>%
    mutate(
      remote_change = remote_2022 - remote_2019,
      remote_change_pct = (remote_2022 - remote_2019) / remote_2019 * 100
    )
  
  cat("Counties with occupation data for both periods:", nrow(occupation_change), "\n")
  
  # Step 4: Test the main hypothesis
  cat("\n=== STEP 4: HYPOTHESIS TESTING ===\n")
  
  # Combine population growth and occupation data
  main_analysis <- growth_with_names %>%
    inner_join(occupation_change, by = "GEOID") %>%
    filter(!is.na(z_score), !is.na(remote_change))
  
  cat("Counties with both population and occupation data:", nrow(main_analysis), "\n")
  
  # Test correlation between anomalous growth and remote work changes
  if (nrow(main_analysis) > 50) {
    
    # Correlation test
    cor_test <- cor.test(main_analysis$z_score, main_analysis$remote_change)
    
    cat("Correlation between population growth anomaly and remote work change:\n")
    cat("  Correlation coefficient:", round(cor_test$estimate, 3), "\n")
    cat("  P-value:", format.pval(cor_test$p.value), "\n")
    cat("  95% CI: [", round(cor_test$conf.int[1], 3), ", ", 
        round(cor_test$conf.int[2], 3), "]\n")
    
    # Regression analysis
    model <- lm(remote_change ~ z_score + log(population_2023) + 
                I(pre_mean_growth * 100), data = main_analysis)
    
    cat("\nRegression results (Remote work change ~ Growth anomaly):\n")
    print(summary(model))
    
    # Compare high vs low growth counties
    high_growth <- main_analysis %>%
      filter(anomalous_growth == TRUE)
    
    normal_growth <- main_analysis %>%
      filter(growth_category == "Normal Growth")
    
    if (nrow(high_growth) > 10 && nrow(normal_growth) > 10) {
      t_test <- t.test(high_growth$remote_change, normal_growth$remote_change)
      
      cat("\nComparison: High anomalous growth vs Normal growth counties\n")
      cat("  High growth mean remote work change:", 
          round(mean(high_growth$remote_change, na.rm = TRUE), 2), "%\n")
      cat("  Normal growth mean remote work change:", 
          round(mean(normal_growth$remote_change, na.rm = TRUE), 2), "%\n")
      cat("  T-test p-value:", format.pval(t_test$p.value), "\n")
    }
    
    # Step 5: Identify specific examples
    cat("\n=== STEP 5: SPECIFIC EXAMPLES ===\n")
    
    # Top remote work + high growth counties
    winners <- main_analysis %>%
      filter(anomalous_growth == TRUE, remote_change > 0) %>%
      arrange(desc(z_score)) %>%
      head(10)
    
    if (nrow(winners) > 0) {
      cat("Counties with both high anomalous growth AND increasing remote work:\n")
      print(winners %>%
              select(NAME, z_score, growth_differential_pct, remote_change) %>%
              mutate_if(is.numeric, round, 2))
    }
    
    # Counties with anomalous growth but declining remote work (contradicts hypothesis)
    losers <- main_analysis %>%
      filter(anomalous_growth == TRUE, remote_change < 0) %>%
      arrange(desc(z_score)) %>%
      head(5)
    
    if (nrow(losers) > 0) {
      cat("\nCounties with high growth but DECLINING remote work (counterexamples):\n")
      print(losers %>%
              select(NAME, z_score, growth_differential_pct, remote_change) %>%
              mutate_if(is.numeric, round, 2))
    }
    
    # Step 6: Visualizations
    cat("\n=== STEP 6: VISUALIZATIONS ===\n")
    
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
      ggplot(aes(x = z_score, y = remote_change)) +
      geom_point(alpha = 0.6, color = "grey20") +
      geom_smooth(method = "lm", color = "red") +
      geom_hline(yintercept = 0, color = "grey50", linetype = "dashed") +
      geom_vline(xintercept = 2, color = "red", linetype = "dashed", alpha = 0.5) +
      labs(
        title = "Population Growth Anomaly vs. Remote Work Change",
        subtitle = "Testing if counties with anomalous growth show increased remote work",
        x = "Population Growth Anomaly (Z-Score)",
        y = "Change in Remote-Capable Occupation Share (%)"
      ) +
      theme_minimal()
    
    print(p2)
    
    # Plot 3: Growth categories comparison
    p3 <- main_analysis %>%
      mutate(growth_category = fct_reorder(growth_category, z_score)) %>%
      ggplot(aes(x = growth_category, y = remote_change)) +
      geom_boxplot(fill = "grey20", alpha = 0.7) +
      geom_hline(yintercept = 0, color = "red", linetype = "dashed") +
      coord_flip() +
      labs(
        title = "Remote Work Changes by County Growth Category",
        subtitle = "Do high-growth counties show more remote work adoption?",
        x = "Growth Category",
        y = "Change in Remote-Capable Occupation Share (%)"
      ) +
      theme_minimal()
    
    print(p3)
    
    # Summary results
    cat("\n=== SUMMARY RESULTS ===\n")
    
    if (cor_test$p.value < 0.05) {
      cat("HYPOTHESIS SUPPORTED: Significant correlation found between population growth anomalies and remote work changes\n")
      cat("  Correlation:", round(cor_test$estimate, 3), " (p =", format.pval(cor_test$p.value), ")\n")
    } else {
      cat("HYPOTHESIS NOT SUPPORTED: No significant correlation between growth and remote work\n")
      cat("  Correlation:", round(cor_test$estimate, 3), " (p =", format.pval(cor_test$p.value), ")\n")
    }
    
    cat("Counties with anomalous growth (>2 SD):", sum(main_analysis$anomalous_growth), "\n")
    cat("Mean remote work change in high-growth counties:", 
        round(mean(high_growth$remote_change, na.rm = TRUE), 2), "%\n")
    
  } else {
    cat("Insufficient data for hypothesis testing (n =", nrow(main_analysis), ")\n")
  }
  
} else {
  cat("Unable to obtain occupation data for analysis\n")
}

cat("\n=== ANALYSIS COMPLETE ===\n")