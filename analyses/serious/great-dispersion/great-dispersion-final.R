# The Great Dispersion: Remote Work Demographic Reshuffling (Final)
# 
# Hypothesis: Counties with anomalous post-2020 growth show education increases,
# suggesting remote work migration patterns. Using corrected PEP vintage approach.

library(tidyverse)
library(tidycensus)
library(scales)
library(ggplot2)

# Set API key
census_api_key(Sys.getenv("CENSUS_API_KEY"))

cat("=== THE GREAT DISPERSION ANALYSIS (FINAL) ===\n")
cat("Testing remote work demographic reshuffling with corrected PEP approach\n")
cat("Using education levels as proxy for remote work capability\n\n")

# Step 1: Get PEP data with correct variable names
cat("=== STEP 1: PEP POPULATION DATA (CORRECTED VARIABLES) ===\n")

# Function to get PEP data with correct variable handling
get_pep_final <- function(year) {
  cat("Getting PEP data for", year, "...\n")
  tryCatch({
    if (year <= 2019) {
      # Pre-2020: use POP variable
      data <- get_estimates(
        geography = "county",
        product = "population",
        year = year
      ) %>%
        filter(variable == "POP") %>%
        select(GEOID, NAME, population = value) %>%
        mutate(year = year)
    } else {
      # Post-2020: use POPESTIMATE variable with vintage
      data <- get_estimates(
        geography = "county",
        product = "population",
        vintage = year,
        year = year
      ) %>%
        filter(variable == "POPESTIMATE") %>%
        select(GEOID, NAME, population = value) %>%
        mutate(year = year)
    }
    return(data)
  }, error = function(e) {
    cat("Error for year", year, ":", e$message, "\n")
    return(NULL)
  })
}

# Get data for available years - focus on core comparison periods
pep_years <- c(2015, 2016, 2017, 2018, 2019, 2021, 2022, 2023)
pep_data_list <- map(pep_years, get_pep_final)

# Combine successful results
pep_final <- pep_data_list %>%
  compact() %>%
  bind_rows()

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

# Check if we have both pre and post periods
pre_years <- unique(pep_clean$year[pep_clean$year <= 2019])
post_years <- unique(pep_clean$year[pep_clean$year >= 2021])

cat("Pre-pandemic years available:", paste(pre_years, collapse = ", "), "\n")
cat("Post-pandemic years available:", paste(post_years, collapse = ", "), "\n")

if (length(pre_years) >= 2 && length(post_years) >= 2) {
  
  # Step 2: Calculate growth trends
  cat("\n=== STEP 2: GROWTH TREND ANALYSIS ===\n")
  
  # Calculate average population for each period
  pre_pandemic_pop <- pep_clean %>%
    filter(year %in% pre_years) %>%
    group_by(GEOID) %>%
    summarise(
      pre_pop = mean(population, na.rm = TRUE),
      pre_years_count = n(),
      .groups = "drop"
    ) %>%
    filter(pre_years_count >= 2)
  
  post_pandemic_pop <- pep_clean %>%
    filter(year %in% post_years) %>%
    group_by(GEOID) %>%
    summarise(
      post_pop = mean(population, na.rm = TRUE),
      post_years_count = n(),
      .groups = "drop"
    ) %>%
    filter(post_years_count >= 2)
  
  # Calculate growth differential
  growth_analysis <- pre_pandemic_pop %>%
    inner_join(post_pandemic_pop, by = "GEOID") %>%
    mutate(
      # Calculate total growth over the period
      total_growth_rate = (post_pop - pre_pop) / pre_pop,
      total_growth_pct = total_growth_rate * 100,
      
      # Annualized growth rate
      years_diff = mean(post_years) - mean(pre_years),
      annual_growth_rate = (post_pop / pre_pop)^(1/years_diff) - 1,
      annual_growth_pct = annual_growth_rate * 100
    )
  
  # Calculate z-scores for anomalous growth identification
  growth_analysis <- growth_analysis %>%
    mutate(
      # Z-score based on total growth distribution
      growth_mean = mean(total_growth_rate, na.rm = TRUE),
      growth_sd = sd(total_growth_rate, na.rm = TRUE),
      z_score = (total_growth_rate - growth_mean) / growth_sd,
      
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
  
  cat("Counties with anomalous growth (>2 SD above mean):", 
      sum(growth_analysis$anomalous_growth, na.rm = TRUE), "\n")
  cat("Mean total growth rate:", round(mean(growth_analysis$total_growth_pct, na.rm = TRUE), 2), "%\n")
  cat("SD of growth rates:", round(sd(growth_analysis$total_growth_pct, na.rm = TRUE), 2), "%\n")
  
  # Get county names
  county_details <- pep_clean %>%
    filter(year == max(post_years)) %>%
    select(GEOID, NAME, population_recent = population)
  
  growth_with_names <- growth_analysis %>%
    left_join(county_details, by = "GEOID")
  
  # Display top growth counties
  if (sum(growth_analysis$anomalous_growth, na.rm = TRUE) > 0) {
    cat("\nTop 15 counties with highest growth:\n")
    top_growth <- growth_with_names %>%
      filter(!is.na(z_score)) %>%
      arrange(desc(z_score)) %>%
      head(15) %>%
      select(NAME, total_growth_pct, z_score, population_recent) %>%
      mutate(
        total_growth_pct = round(total_growth_pct, 2),
        z_score = round(z_score, 2),
        population_recent = comma(population_recent)
      )
    
    print(top_growth)
  }
  
  # Step 3: Get education data
  cat("\n=== STEP 3: EDUCATION DATA (REMOTE WORK PROXY) ===\n")
  
  # Get education data for comparison
  education_2019 <- tryCatch({
    get_acs(
      geography = "county",
      variables = c(
        "B15003_001",  # Total population 25+
        "B15003_022",  # Bachelor's degree
        "B15003_023",  # Master's degree
        "B15003_024",  # Professional degree
        "B15003_025"   # Doctorate
      ),
      year = 2019,
      output = "wide",
      survey = "acs5"
    ) %>%
      mutate(
        total_25plus = B15003_001E,
        bachelors_plus = B15003_022E + B15003_023E + B15003_024E + B15003_025E,
        college_share_2019 = ifelse(total_25plus > 0, bachelors_plus / total_25plus, NA),
        college_pct_2019 = college_share_2019 * 100
      ) %>%
      select(GEOID, college_pct_2019)
  }, error = function(e) {
    cat("Error getting 2019 education data:", e$message, "\n")
    NULL
  })
  
  education_2022 <- tryCatch({
    get_acs(
      geography = "county",
      variables = c(
        "B15003_001",  # Total population 25+
        "B15003_022",  # Bachelor's degree
        "B15003_023",  # Master's degree
        "B15003_024",  # Professional degree
        "B15003_025"   # Doctorate
      ),
      year = 2022,
      output = "wide",
      survey = "acs5"
    ) %>%
      mutate(
        total_25plus = B15003_001E,
        bachelors_plus = B15003_022E + B15003_023E + B15003_024E + B15003_025E,
        college_share_2022 = ifelse(total_25plus > 0, bachelors_plus / total_25plus, NA),
        college_pct_2022 = college_share_2022 * 100
      ) %>%
      select(GEOID, college_pct_2022)
  }, error = function(e) {
    cat("Error getting 2022 education data:", e$message, "\n")
    NULL
  })
  
  if (!is.null(education_2019) && !is.null(education_2022)) {
    
    # Calculate education changes
    education_change <- education_2019 %>%
      inner_join(education_2022, by = "GEOID") %>%
      mutate(
        college_change = college_pct_2022 - college_pct_2019,
        college_change_pct = (college_pct_2022 - college_pct_2019) / college_pct_2019 * 100
      )
    
    cat("Counties with education data for both periods:", nrow(education_change), "\n")
    
    # Step 4: Main hypothesis test
    cat("\n=== STEP 4: HYPOTHESIS TESTING ===\n")
    
    # Combine population growth and education data
    main_analysis <- growth_with_names %>%
      inner_join(education_change, by = "GEOID") %>%
      filter(!is.na(z_score), !is.na(college_change), !is.na(population_recent))
    
    cat("Counties with both population and education data:", nrow(main_analysis), "\n")
    
    if (nrow(main_analysis) > 50) {
      
      # Correlation test
      cor_test <- cor.test(main_analysis$z_score, main_analysis$college_change)
      
      cat("Correlation between population growth anomaly and college education change:\n")
      cat("  Correlation coefficient:", round(cor_test$estimate, 3), "\n")
      cat("  P-value:", format.pval(cor_test$p.value), "\n")
      cat("  95% CI: [", round(cor_test$conf.int[1], 3), ", ", 
          round(cor_test$conf.int[2], 3), "]\n")
      
      # Alternative correlation with total growth
      cor_test2 <- cor.test(main_analysis$total_growth_pct, main_analysis$college_change)
      
      cat("\nCorrelation between total growth rate and college education change:\n")
      cat("  Correlation coefficient:", round(cor_test2$estimate, 3), "\n")
      cat("  P-value:", format.pval(cor_test2$p.value), "\n")
      
      # Regression analysis
      model <- lm(college_change ~ z_score + log(population_recent), 
                  data = main_analysis)
      
      cat("\nRegression results (College education change ~ Growth anomaly):\n")
      model_summary <- summary(model)
      print(model_summary)
      
      # Compare high vs normal growth counties
      high_growth <- main_analysis %>%
        filter(anomalous_growth == TRUE)
      
      normal_growth <- main_analysis %>%
        filter(growth_category == "Normal Growth")
      
      if (nrow(high_growth) > 3 && nrow(normal_growth) > 10) {
        t_test <- t.test(high_growth$college_change, normal_growth$college_change)
        
        cat("\nComparison: High anomalous growth vs Normal growth counties\n")
        cat("  High growth counties:", nrow(high_growth), "\n")
        cat("  High growth mean college education change:", 
            round(mean(high_growth$college_change, na.rm = TRUE), 2), "pp\n")
        cat("  Normal growth mean college education change:", 
            round(mean(normal_growth$college_change, na.rm = TRUE), 2), "pp\n")
        cat("  T-test p-value:", format.pval(t_test$p.value), "\n")
      }
      
      # Step 5: Visualizations
      cat("\n=== STEP 5: VISUALIZATIONS ===\n")
      
      # Plot 1: Growth distribution
      p1 <- main_analysis %>%
        ggplot(aes(x = total_growth_pct)) +
        geom_histogram(bins = 30, fill = "grey20", alpha = 0.7) +
        geom_vline(xintercept = mean(main_analysis$total_growth_pct, na.rm = TRUE) + 
                     2 * sd(main_analysis$total_growth_pct, na.rm = TRUE), 
                   color = "red", linetype = "dashed") +
        labs(
          title = "Distribution of County Population Growth (Pre vs Post Pandemic)",
          subtitle = "Total growth percentage from pre-pandemic to post-pandemic periods",
          x = "Total Growth Percentage",
          y = "Count of Counties"
        ) +
        theme_minimal()
      
      print(p1)
      
      # Plot 2: Main hypothesis test
      p2 <- main_analysis %>%
        ggplot(aes(x = total_growth_pct, y = college_change)) +
        geom_point(alpha = 0.6, color = "grey20") +
        geom_smooth(method = "lm", color = "red") +
        geom_hline(yintercept = 0, color = "grey50", linetype = "dashed") +
        labs(
          title = "Population Growth vs. College Education Change",
          subtitle = "Testing if counties with high growth show increased college-educated populations",
          x = "Total Population Growth (%)",
          y = "Change in College Education Share (percentage points)"
        ) +
        theme_minimal()
      
      print(p2)
      
      # Summary results
      cat("\n=== SUMMARY RESULTS ===\n")
      
      if (cor_test2$p.value < 0.05) {
        cat("HYPOTHESIS SUPPORTED: Significant correlation between population growth and college education increases\n")
        cat("  Correlation:", round(cor_test2$estimate, 3), " (p =", format.pval(cor_test2$p.value), ")\n")
      } else {
        cat("HYPOTHESIS NOT SUPPORTED: No significant correlation between growth and college education\n")
        cat("  Correlation:", round(cor_test2$estimate, 3), " (p =", format.pval(cor_test2$p.value), ")\n")
      }
      
      cat("Counties with anomalous growth (>2 SD):", sum(main_analysis$anomalous_growth), "\n")
      cat("Mean college education change overall:", 
          round(mean(main_analysis$college_change, na.rm = TRUE), 2), "pp\n")
      
      if (nrow(high_growth) > 0) {
        cat("Mean college education change in high-growth counties:", 
            round(mean(high_growth$college_change, na.rm = TRUE), 2), "pp\n")
      }
      
    } else {
      cat("Insufficient data for hypothesis testing (n =", nrow(main_analysis), ")\n")
    }
    
  } else {
    cat("Unable to obtain education data for analysis\n")
  }
  
} else {
  cat("Insufficient PEP data periods for growth analysis\n")
  cat("Need both pre-pandemic (<=2019) and post-pandemic (>=2021) data\n")
}

cat("\n=== ANALYSIS COMPLETE ===\n")