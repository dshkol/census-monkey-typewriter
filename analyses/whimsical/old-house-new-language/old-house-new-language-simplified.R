# Old House, New Language: Housing Stock Age and Linguistic Diversity
# Simplified Analysis with Basic Language Variables

library(tidyverse)
library(tidycensus)
library(scales)
library(ggplot2)

# Set API key
census_api_key(Sys.getenv("CENSUS_API_KEY"))

cat("=== OLD HOUSE, NEW LANGUAGE ANALYSIS (SIMPLIFIED) ===\n")
cat("Testing correlation between housing age and non-English speaking population\n")
cat("Hypothesis: Older neighborhoods = higher linguistic diversity\n\n")

# Step 1: Get housing age data for Los Angeles County
cat("=== STEP 1: HOUSING AGE DATA ===\n")
housing_age <- get_acs(
  geography = "tract",
  state = "CA",
  county = "037",  # Los Angeles County
  variables = c(
    "B25034_001",  # Total housing units
    "B25034_007",  # Built 1970 to 1979
    "B25034_008",  # Built 1960 to 1969
    "B25034_009",  # Built 1950 to 1959
    "B25034_010",  # Built 1940 to 1949
    "B25034_011"   # Built 1939 or earlier
  ),
  year = 2022,
  output = "wide",
  survey = "acs5"
) %>%
  mutate(
    total_units = B25034_001E,
    old_housing = B25034_007E + B25034_008E + B25034_009E + B25034_010E + B25034_011E,
    old_housing_pct = ifelse(total_units > 0, old_housing / total_units * 100, NA)
  ) %>%
  filter(!is.na(old_housing_pct), total_units >= 100) %>%
  select(GEOID, NAME, total_units, old_housing_pct)

cat("Tracts with housing data:", nrow(housing_age), "\n")
cat("Mean old housing percentage:", round(mean(housing_age$old_housing_pct, na.rm = TRUE), 1), "%\n")

# Step 2: Get basic language data
cat("\n=== STEP 2: LANGUAGE DATA ===\n")
language_data <- get_acs(
  geography = "tract",
  state = "CA",
  county = "037",
  variables = c(
    "B16004_001",  # Total population 5 years and over
    "B16004_002",  # English only
    "B16004_003",  # Spanish
    "B16004_005",  # French, Haitian, or Cajun
    "B16004_007",  # German or other West Germanic
    "B16004_009",  # Russian, Polish, or other Slavic
    "B16004_011",  # Other Indo-European
    "B16004_013",  # Korean
    "B16004_015",  # Chinese
    "B16004_017",  # Vietnamese  
    "B16004_019",  # Tagalog
    "B16004_021",  # Other Asian and Pacific Island
    "B16004_023",  # Arabic
    "B16004_025"   # Other and unspecified
  ),
  year = 2022,
  output = "wide",
  survey = "acs5"
) %>%
  mutate(
    total_pop_5plus = B16004_001E,
    english_only = B16004_002E,
    non_english = total_pop_5plus - english_only,
    non_english_pct = ifelse(total_pop_5plus > 0, non_english / total_pop_5plus * 100, NA),
    
    # Calculate major language groups
    spanish = B16004_003E,
    asian_langs = B16004_013E + B16004_015E + B16004_017E + B16004_019E + B16004_021E,
    european_langs = B16004_005E + B16004_007E + B16004_009E + B16004_011E,
    other_langs = B16004_023E + B16004_025E,
    
    # Language diversity metric: number of significant language groups
    spanish_pct = ifelse(total_pop_5plus > 0, spanish / total_pop_5plus * 100, 0),
    asian_pct = ifelse(total_pop_5plus > 0, asian_langs / total_pop_5plus * 100, 0),
    european_pct = ifelse(total_pop_5plus > 0, european_langs / total_pop_5plus * 100, 0),
    other_pct = ifelse(total_pop_5plus > 0, other_langs / total_pop_5plus * 100, 0),
    
    # Count groups with >5% population
    lang_diversity_score = (spanish_pct > 5) + (asian_pct > 5) + (european_pct > 5) + (other_pct > 5)
  ) %>%
  filter(!is.na(non_english_pct), total_pop_5plus >= 200) %>%
  select(GEOID, total_pop_5plus, non_english_pct, lang_diversity_score, 
         spanish_pct, asian_pct, european_pct, other_pct)

cat("Tracts with language data:", nrow(language_data), "\n") 
cat("Mean non-English percentage:", round(mean(language_data$non_english_pct, na.rm = TRUE), 1), "%\n")
cat("Mean language diversity score:", round(mean(language_data$lang_diversity_score, na.rm = TRUE), 1), "\n")

# Step 3: Combine and analyze
cat("\n=== STEP 3: CORRELATION ANALYSIS ===\n")
combined_analysis <- housing_age %>%
  inner_join(language_data, by = "GEOID") %>%
  filter(!is.na(old_housing_pct), !is.na(non_english_pct))

cat("Tracts with complete data:", nrow(combined_analysis), "\n")

# Step 4: Statistical tests
cat("\n=== STEP 4: HYPOTHESIS TESTING ===\n")

# Primary correlation: old housing vs non-English speakers
cor_test1 <- cor.test(combined_analysis$old_housing_pct, 
                      combined_analysis$non_english_pct)

cat("Correlation: Old housing % vs. Non-English speaking %\n")
cat("  Correlation coefficient:", round(cor_test1$estimate, 3), "\n")
cat("  P-value:", format.pval(cor_test1$p.value), "\n")

# Secondary correlation: old housing vs diversity score
cor_test2 <- cor.test(combined_analysis$old_housing_pct, 
                      combined_analysis$lang_diversity_score)

cat("\nCorrelation: Old housing % vs. Language diversity score\n")
cat("  Correlation coefficient:", round(cor_test2$estimate, 3), "\n") 
cat("  P-value:", format.pval(cor_test2$p.value), "\n")

# Create quartile comparison
combined_analysis <- combined_analysis %>%
  mutate(
    housing_age_quartile = case_when(
      old_housing_pct >= quantile(old_housing_pct, 0.75, na.rm = TRUE) ~ "Oldest 25%",
      old_housing_pct >= quantile(old_housing_pct, 0.5, na.rm = TRUE) ~ "Older 50%", 
      old_housing_pct >= quantile(old_housing_pct, 0.25, na.rm = TRUE) ~ "Newer 50%",
      TRUE ~ "Newest 25%"
    )
  )

quartile_comparison <- combined_analysis %>%
  group_by(housing_age_quartile) %>%
  summarise(
    n_tracts = n(),
    mean_old_housing_pct = round(mean(old_housing_pct, na.rm = TRUE), 1),
    mean_non_english_pct = round(mean(non_english_pct, na.rm = TRUE), 1),
    mean_diversity_score = round(mean(lang_diversity_score, na.rm = TRUE), 1),
    .groups = "drop"
  )

cat("\nComparison by housing age quartile:\n")
print(quartile_comparison)

# Step 5: Visualizations
cat("\n=== STEP 5: VISUALIZATIONS ===\n")

# Plot 1: Main correlation
p1 <- combined_analysis %>%
  ggplot(aes(x = old_housing_pct, y = non_english_pct)) +
  geom_point(alpha = 0.6, color = "grey20") +
  geom_smooth(method = "lm", color = "red") +
  labs(
    title = "Housing Stock Age vs. Non-English Speaking Population",
    subtitle = "Los Angeles County census tracts",
    x = "Old Housing Stock (% built before 1980)",
    y = "Non-English Speaking Population (%)"
  ) +
  theme_minimal()

print(p1)

# Plot 2: Quartile comparison
p2 <- combined_analysis %>%
  ggplot(aes(x = housing_age_quartile, y = non_english_pct)) +
  geom_boxplot(fill = "grey20", alpha = 0.7) +
  labs(
    title = "Non-English Speaking Population by Housing Age Quartile", 
    subtitle = "Do older neighborhoods consistently have more linguistic diversity?",
    x = "Housing Age Quartile",
    y = "Non-English Speaking Population (%)"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

print(p2)

# Plot 3: Diversity score comparison
p3 <- combined_analysis %>%
  ggplot(aes(x = old_housing_pct, y = lang_diversity_score)) +
  geom_point(alpha = 0.6, color = "grey20") +
  geom_smooth(method = "lm", color = "red") +
  labs(
    title = "Housing Age vs. Language Diversity Score",
    subtitle = "Score = number of language groups with >5% population share",
    x = "Old Housing Stock (% built before 1980)", 
    y = "Language Diversity Score (0-4)"
  ) +
  theme_minimal()

print(p3)

# Summary results
cat("\n=== SUMMARY RESULTS ===\n")

mean_old_housing <- mean(combined_analysis$old_housing_pct, na.rm = TRUE)
mean_non_english <- mean(combined_analysis$non_english_pct, na.rm = TRUE)

cat("Los Angeles County Analysis:\n")
cat("  Tracts analyzed:", nrow(combined_analysis), "\n")
cat("  Mean old housing percentage:", round(mean_old_housing, 1), "%\n")
cat("  Mean non-English speaking:", round(mean_non_english, 1), "%\n")

cat("\nHypothesis Test Results:\n")

if (cor_test1$p.value < 0.05) {
  direction <- ifelse(cor_test1$estimate > 0, "POSITIVE", "NEGATIVE")
  cat("  Housing age → Non-English speakers: ", direction, " correlation (r = ", 
      round(cor_test1$estimate, 3), ", p = ", format.pval(cor_test1$p.value), ")\n")
  
  if (cor_test1$estimate > 0) {
    cat("  ✓ HYPOTHESIS SUPPORTED: Older neighborhoods have more non-English speakers\n")
  } else {
    cat("  ✗ HYPOTHESIS CONTRADICTED: Older neighborhoods have fewer non-English speakers\n")
  }
} else {
  cat("  Housing age → Non-English speakers: No significant correlation\n")
  cat("  ○ HYPOTHESIS NOT SUPPORTED: No clear relationship found\n")
}

# Diversity score results
if (cor_test2$p.value < 0.05) {
  direction2 <- ifelse(cor_test2$estimate > 0, "POSITIVE", "NEGATIVE")
  cat("  Housing age → Diversity score: ", direction2, " correlation (r = ", 
      round(cor_test2$estimate, 3), ", p = ", format.pval(cor_test2$p.value), ")\n")
} else {
  cat("  Housing age → Diversity score: No significant correlation\n")
}

# Overall evaluation
strong_correlation <- abs(cor_test1$estimate) >= 0.3 && cor_test1$p.value < 0.05
moderate_correlation <- abs(cor_test1$estimate) >= 0.15 && cor_test1$p.value < 0.05

if (strong_correlation && cor_test1$estimate > 0) {
  cat("\nOVERALL: OLD HOUSE, NEW LANGUAGE HYPOTHESIS STRONGLY SUPPORTED\n")
  cat("Strong positive correlation between housing age and linguistic diversity\n")
} else if (moderate_correlation && cor_test1$estimate > 0) {
  cat("\nOVERALL: OLD HOUSE, NEW LANGUAGE HYPOTHESIS MODERATELY SUPPORTED\n")
  cat("Moderate positive correlation between housing age and linguistic diversity\n")
} else if (cor_test1$p.value < 0.05 && cor_test1$estimate < 0) {
  cat("\nOVERALL: OLD HOUSE, NEW LANGUAGE HYPOTHESIS CONTRADICTED\n")
  cat("Significant negative correlation - newer neighborhoods more linguistically diverse\n")
} else {
  cat("\nOVERALL: OLD HOUSE, NEW LANGUAGE HYPOTHESIS NOT SUPPORTED\n")
  cat("No significant relationship between housing age and linguistic diversity\n")
}

cat("\n=== ANALYSIS COMPLETE ===\n")