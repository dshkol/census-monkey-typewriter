# Simplified Toponymic Analysis - Just use get_acs with names

library(tidycensus)
library(tidyverse)
library(tigris)

# Set API key
census_api_key(Sys.getenv("CENSUS_API_KEY"))
options(tigris_use_cache = TRUE)

cat("=== SIMPLIFIED TOPONYMIC TRAVEL TEST ===\n\n")

# Get data with names directly from get_acs
cat("Getting Texas county data with names...\n")

tx_data <- get_acs(
  geography = "county",
  state = "TX",
  variables = c(
    total_pop = "B01003_001",
    movers_from_other_state = "B07001_093"
  ),
  year = 2022,
  output = "wide",
  geometry = FALSE
)

cat("✓ Retrieved data for", nrow(tx_data), "counties\n")
cat("✓ Column names:", paste(names(tx_data), collapse = ", "), "\n")

# Process the data
analysis_data <- tx_data %>%
  mutate(
    # Calculate migration rate
    inmigration_rate = (movers_from_other_stateE / total_popE) * 1000,
    
    # Extract county name from the NAME column 
    county_name_full = NAME,
    county_name_clean = str_remove(str_extract(NAME, "^[^,]+"), " County$| Parish$"),
    
    # Calculate name complexity measures
    char_count = str_length(str_remove_all(county_name_clean, " ")),
    char_count_spaces = str_length(county_name_clean),
    word_count = str_count(county_name_clean, "\\S+"),
    syllable_count = str_count(tolower(county_name_clean), "[aeiouy]+"),
    
    # Log population for control
    log_pop = log(total_popE + 1)
  ) %>%
  filter(
    !is.na(inmigration_rate),
    !is.na(char_count),
    total_popE > 0,
    movers_from_other_stateE >= 0
  )

cat("✓ Processed data for", nrow(analysis_data), "counties\n\n")

# Show sample data
cat("Sample of processed data:\n")
sample_data <- analysis_data %>%
  select(county_name_clean, char_count, total_popE, movers_from_other_stateE, inmigration_rate) %>%
  head(10)

print(sample_data)

if(nrow(analysis_data) >= 10) {
  cat("\n\nANALYSIS RESULTS\n")
  cat("================\n")
  
  cat("Summary Statistics:\n")
  cat("- Counties:", nrow(analysis_data), "\n")
  cat("- Mean migration rate:", round(mean(analysis_data$inmigration_rate, na.rm = TRUE), 2), "per 1,000\n")
  cat("- Mean name length:", round(mean(analysis_data$char_count, na.rm = TRUE), 1), "characters\n")
  cat("- Name length range:", min(analysis_data$char_count), "-", max(analysis_data$char_count), "characters\n\n")
  
  # Extreme cases
  cat("LONGEST county names:\n")
  longest <- analysis_data %>%
    arrange(desc(char_count)) %>%
    head(8) %>%
    select(county_name_clean, char_count, inmigration_rate, total_popE)
  print(longest)
  
  cat("\nSHORTEST county names:\n")
  shortest <- analysis_data %>%
    arrange(char_count) %>%
    head(8) %>%
    select(county_name_clean, char_count, inmigration_rate, total_popE)
  print(shortest)
  
  # Statistical models
  cat("\n\nSTATISTICAL ANALYSIS\n")
  cat("====================\n")
  
  # Simple correlation
  cor_result <- cor(analysis_data$char_count, analysis_data$inmigration_rate, use = "complete.obs")
  cat("Simple correlation (name length vs migration):", round(cor_result, 4), "\n")
  
  # Simple regression
  model_simple <- lm(inmigration_rate ~ char_count, data = analysis_data)
  simple_coef <- coef(model_simple)["char_count"]
  simple_p <- summary(model_simple)$coefficients["char_count", "Pr(>|t|)"]
  
  cat("\nSimple regression:\n")
  cat("- Coefficient:", round(simple_coef, 6), "\n") 
  cat("- P-value:", round(simple_p, 4), "\n")
  cat("- R-squared:", round(summary(model_simple)$r.squared, 4), "\n")
  
  # Controlled regression
  model_controlled <- lm(inmigration_rate ~ char_count + log_pop, data = analysis_data)
  controlled_coef <- coef(model_controlled)["char_count"]
  controlled_p <- summary(model_controlled)$coefficients["char_count", "Pr(>|t|)"]
  
  cat("\nPopulation-controlled regression:\n")
  cat("- Coefficient:", round(controlled_coef, 6), "\n")
  cat("- P-value:", round(controlled_p, 4), "\n") 
  cat("- R-squared:", round(summary(model_controlled)$r.squared, 4), "\n")
  
  # Effect size
  mean_migration <- mean(analysis_data$inmigration_rate, na.rm = TRUE)
  sd_name_length <- sd(analysis_data$char_count, na.rm = TRUE)
  one_sd_effect <- controlled_coef * sd_name_length
  effect_pct <- abs(one_sd_effect) / mean_migration * 100
  
  cat("\nEffect size interpretation:\n")
  cat("- 1 SD change in name length (", round(sd_name_length, 1), "chars) =", round(one_sd_effect, 4), "change in migration rate\n")
  cat("- This is", round(effect_pct, 2), "% of the mean migration rate\n")
  
  # Group comparison
  cat("\nGroup comparison:\n")
  long_counties <- analysis_data %>% filter(char_count >= 10)
  short_counties <- analysis_data %>% filter(char_count <= 6)
  
  if(nrow(long_counties) > 0 && nrow(short_counties) > 0) {
    cat("- Long names (≥10 chars):", nrow(long_counties), "counties, mean migration:", 
        round(mean(long_counties$inmigration_rate), 2), "\n")
    cat("- Short names (≤6 chars):", nrow(short_counties), "counties, mean migration:", 
        round(mean(short_counties$inmigration_rate), 2), "\n")
  }
  
  cat("\n\nCONCLUSIONS\n")
  cat("===========\n")
  
  is_significant <- controlled_p < 0.05
  direction <- ifelse(controlled_coef < 0, "negative", "positive")
  
  if(is_significant) {
    cat("✓ SIGNIFICANT", toupper(direction), "effect found\n")
    cat("✓ P-value:", round(controlled_p, 4), "< 0.05\n")
  } else {
    cat("✗ NO significant effect found\n") 
    cat("✗ P-value:", round(controlled_p, 4), "≥ 0.05\n")
  }
  
  if(effect_pct < 1) {
    cat("✓ Effect size: TRIVIAL (", round(effect_pct, 2), "% of mean)\n")
  } else if(effect_pct < 5) {
    cat("✓ Effect size: SMALL (", round(effect_pct, 2), "% of mean)\n")
  } else {
    cat("✓ Effect size: MODERATE (", round(effect_pct, 2), "% of mean)\n")
  }
  
  cat("\nThis whimsical analysis suggests that county name length has")
  cat(ifelse(is_significant, " a statistically detectable but", " no"))
  cat(" substantively", ifelse(effect_pct < 1, " trivial", " small"), " effect on migration patterns.\n")
  cat("Economic and demographic factors remain the primary drivers of location choice.\n")
  
} else {
  cat("ERROR: Insufficient data\n")
}

cat("\n🤖 Toponymic Travel Test Complete!\n")