# Old House, New Language: Housing Stock Age and Linguistic Diversity
#
# Hypothesis: Neighborhoods with older housing stock (built pre-1980) have 
# higher linguistic diversity scores. Older neighborhoods with potentially 
# more affordable housing serve as entry points for diverse immigrant groups.

library(tidyverse)
library(tidycensus)
library(scales)
library(ggplot2)
library(viridis)

# Set API key
census_api_key(Sys.getenv("CENSUS_API_KEY"))

cat("=== OLD HOUSE, NEW LANGUAGE ANALYSIS ===\n")
cat("Testing correlation between housing age and linguistic diversity\n")
cat("Hypothesis: Older neighborhoods = higher linguistic diversity\n\n")

# Step 1: Get housing age data
cat("=== STEP 1: HOUSING AGE DATA ===\n")

# Focus on Los Angeles County for detailed analysis
cat("Fetching housing age data for Los Angeles County...\n")
housing_age <- get_acs(
  geography = "tract",
  state = "CA",
  county = "037",  # Los Angeles County only
  variables = c(
    "B25034_001",  # Total housing units
    "B25034_002",  # Built 2014 or later
    "B25034_003",  # Built 2010 to 2013
    "B25034_004",  # Built 2000 to 2009
    "B25034_005",  # Built 1990 to 1999
    "B25034_006",  # Built 1980 to 1989
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
    
    # Calculate old housing (pre-1980)
    old_housing = B25034_007E + B25034_008E + B25034_009E + B25034_010E + B25034_011E,
    
    # Calculate very old housing (pre-1960)
    very_old_housing = B25034_009E + B25034_010E + B25034_011E,
    
    # Calculate new housing (post-2000)
    new_housing = B25034_002E + B25034_003E + B25034_004E,
    
    # Calculate percentages
    old_housing_pct = ifelse(total_units > 0, old_housing / total_units * 100, NA),
    very_old_housing_pct = ifelse(total_units > 0, very_old_housing / total_units * 100, NA),
    new_housing_pct = ifelse(total_units > 0, new_housing / total_units * 100, NA),
    
    # Categorize by housing age
    housing_age_category = case_when(
      old_housing_pct >= 70 ~ "Predominantly Old (70%+)",
      old_housing_pct >= 50 ~ "Mostly Old (50-70%)",
      old_housing_pct >= 30 ~ "Mixed Age (30-50%)",
      old_housing_pct >= 15 ~ "Mostly New (15-30%)",
      TRUE ~ "Predominantly New (<15%)"
    )
  ) %>%
  filter(!is.na(old_housing_pct), total_units >= 100) %>%  # Filter small tracts
  select(GEOID, NAME, total_units, old_housing_pct, very_old_housing_pct, 
         new_housing_pct, housing_age_category)

cat("Census tracts analyzed:", nrow(housing_age), "\n")
cat("Mean old housing percentage:", round(mean(housing_age$old_housing_pct, na.rm = TRUE), 1), "%\n")

# Display housing age distribution
age_summary <- housing_age %>%
  count(housing_age_category, sort = TRUE) %>%
  mutate(percentage = round(n / sum(n) * 100, 1))

cat("\nHousing age distribution:\n")
print(age_summary)

# Step 2: Get language diversity data
cat("\n=== STEP 2: LINGUISTIC DIVERSITY DATA ===\n")

cat("Fetching language spoken at home data...\n")
language_data <- get_acs(
  geography = "tract",
  state = "CA",
  county = "037",  # Los Angeles County only
  variables = c(
    "B16001_001",  # Total population 5 years and over
    "B16001_002",  # English only
    "B16001_003",  # Spanish
    "B16001_006",  # French, Haitian, or Cajun
    "B16001_009",  # German or other West Germanic languages
    "B16001_012",  # Russian, Polish, or other Slavic languages
    "B16001_015",  # Other Indo-European languages
    "B16001_018",  # Korean
    "B16001_021",  # Chinese (incl. Mandarin, Cantonese)
    "B16001_024",  # Vietnamese
    "B16001_027",  # Tagalog (incl. Filipino)
    "B16001_030",  # Other Asian and Pacific Island languages
    "B16001_033",  # Arabic
    "B16001_036"   # Other and unspecified languages
  ),
  year = 2022,
  output = "wide",
  survey = "acs5"
) %>%
  mutate(
    total_pop_5plus = B16001_001E,
    english_only = B16001_002E,
    
    # Major language groups
    spanish = B16001_003E,
    asian_languages = B16001_018E + B16001_021E + B16001_024E + B16001_027E + B16001_030E,
    european_languages = B16001_006E + B16001_009E + B16001_012E + B16001_015E,
    other_languages = B16001_033E + B16001_036E,
    
    # Calculate diversity metrics
    non_english = total_pop_5plus - english_only,
    non_english_pct = ifelse(total_pop_5plus > 0, non_english / total_pop_5plus * 100, NA),
    
    # Calculate linguistic diversity index (simplified Herfindahl)
    # Higher values = more diversity
    spanish_share = ifelse(total_pop_5plus > 0, spanish / total_pop_5plus, 0),
    asian_share = ifelse(total_pop_5plus > 0, asian_languages / total_pop_5plus, 0),
    european_share = ifelse(total_pop_5plus > 0, european_languages / total_pop_5plus, 0),
    other_share = ifelse(total_pop_5plus > 0, other_languages / total_pop_5plus, 0),
    english_share = ifelse(total_pop_5plus > 0, english_only / total_pop_5plus, 0),
    
    # Diversity index: 1 - sum of squares (higher = more diverse)
    diversity_index = ifelse(total_pop_5plus > 0,
                           1 - (english_share^2 + spanish_share^2 + asian_share^2 + 
                               european_share^2 + other_share^2),
                           NA),
    
    # Count of significant language groups (>5% of population)
    lang_groups_count = (spanish_share > 0.05) + (asian_share > 0.05) + 
                       (european_share > 0.05) + (other_share > 0.05),
    
    # Categorize diversity
    diversity_category = case_when(
      diversity_index >= 0.6 ~ "Very High Diversity",
      diversity_index >= 0.4 ~ "High Diversity", 
      diversity_index >= 0.25 ~ "Moderate Diversity",
      diversity_index >= 0.1 ~ "Low Diversity",
      TRUE ~ "Minimal Diversity"
    )
  )

cat("Debug: Language data before filtering:", nrow(language_data), "\n")
cat("Debug: Sample diversity_index values:", head(language_data$diversity_index, 10), "\n")
cat("Debug: Count of non-NA diversity_index:", sum(!is.na(language_data$diversity_index)), "\n")
cat("Debug: Sample total_pop_5plus:", head(language_data$total_pop_5plus, 5), "\n")
cat("Debug: Sample english_only:", head(language_data$english_only, 5), "\n")
cat("Debug: Sample spanish:", head(language_data$spanish, 5), "\n")
cat("Debug: Sample english_share:", head(language_data$english_share, 5), "\n")

language_data <- language_data %>%
  filter(!is.na(diversity_index), total_pop_5plus >= 200) %>%  # Filter small tracts
  select(GEOID, total_pop_5plus, non_english_pct, diversity_index, lang_groups_count, 
         diversity_category, spanish_share, asian_share, european_share, other_share)

cat("Debug: Language data after filtering:", nrow(language_data), "\n")

cat("Tracts with language data:", nrow(language_data), "\n")
cat("Mean linguistic diversity index:", round(mean(language_data$diversity_index, na.rm = TRUE), 3), "\n")
cat("Mean non-English percentage:", round(mean(language_data$non_english_pct, na.rm = TRUE), 1), "%\n")

# Display diversity distribution
diversity_summary <- language_data %>%
  count(diversity_category, sort = TRUE) %>%
  mutate(percentage = round(n / sum(n) * 100, 1))

cat("\nLinguistic diversity distribution:\n")
print(diversity_summary)

# Step 3: Combine and analyze
cat("\n=== STEP 3: CORRELATION ANALYSIS ===\n")

# Join housing age and language data
combined_analysis <- housing_age %>%
  inner_join(language_data, by = "GEOID") %>%
  mutate(
    # Add tract identifier for LA neighborhoods
    tract_id = str_sub(GEOID, 6, 11),
    metro_area = "Los Angeles County"
  ) %>%
  filter(!is.na(old_housing_pct), !is.na(diversity_index))

cat("Tracts with complete data:", nrow(combined_analysis), "\n")

# Step 4: Statistical tests
cat("\n=== STEP 4: HYPOTHESIS TESTING ===\n")

# Primary correlation test
cor_test1 <- cor.test(combined_analysis$old_housing_pct, 
                      combined_analysis$diversity_index)

cat("Correlation: Old housing % vs. Linguistic diversity index\n")
cat("  Correlation coefficient:", round(cor_test1$estimate, 3), "\n")
cat("  P-value:", format.pval(cor_test1$p.value), "\n")

# Secondary correlation with very old housing
cor_test2 <- cor.test(combined_analysis$very_old_housing_pct, 
                      combined_analysis$diversity_index)

cat("\nCorrelation: Very old housing % vs. Linguistic diversity index\n")
cat("  Correlation coefficient:", round(cor_test2$estimate, 3), "\n")
cat("  P-value:", format.pval(cor_test2$p.value), "\n")

# Test with non-English percentage
cor_test3 <- cor.test(combined_analysis$old_housing_pct, 
                      combined_analysis$non_english_pct)

cat("\nCorrelation: Old housing % vs. Non-English speaking %\n")
cat("  Correlation coefficient:", round(cor_test3$estimate, 3), "\n")
cat("  P-value:", format.pval(cor_test3$p.value), "\n")

# Compare extreme categories
extreme_comparison <- combined_analysis %>%
  filter(housing_age_category %in% c("Predominantly Old (70%+)", "Predominantly New (<15%)")) %>%
  group_by(housing_age_category) %>%
  summarise(
    n_tracts = n(),
    mean_diversity_index = round(mean(diversity_index, na.rm = TRUE), 3),
    mean_non_english_pct = round(mean(non_english_pct, na.rm = TRUE), 1),
    mean_lang_groups = round(mean(lang_groups_count, na.rm = TRUE), 1),
    .groups = "drop"
  )

cat("\nComparison of extreme housing age categories:\n")
print(extreme_comparison)

# T-test for extreme categories
old_housing_tracts <- combined_analysis %>% 
  filter(housing_age_category == "Predominantly Old (70%+)")
new_housing_tracts <- combined_analysis %>% 
  filter(housing_age_category == "Predominantly New (<15%)")

if (nrow(old_housing_tracts) >= 5 && nrow(new_housing_tracts) >= 5) {
  
  # T-test for diversity index
  t_test_diversity <- t.test(old_housing_tracts$diversity_index, 
                            new_housing_tracts$diversity_index)
  cat("\nT-test: Diversity index (Old vs New housing areas)\n")
  cat("  Old housing mean:", round(mean(old_housing_tracts$diversity_index), 3), "\n")
  cat("  New housing mean:", round(mean(new_housing_tracts$diversity_index), 3), "\n")
  cat("  P-value:", format.pval(t_test_diversity$p.value), "\n")
  
  # T-test for non-English percentage
  t_test_language <- t.test(old_housing_tracts$non_english_pct, 
                           new_housing_tracts$non_english_pct)
  cat("\nT-test: Non-English % (Old vs New housing areas)\n")
  cat("  Old housing mean:", round(mean(old_housing_tracts$non_english_pct), 1), "%\n")
  cat("  New housing mean:", round(mean(new_housing_tracts$non_english_pct), 1), "%\n")
  cat("  P-value:", format.pval(t_test_language$p.value), "\n")
}

# Step 5: Metro area analysis
cat("\n=== STEP 5: METRO AREA PATTERNS ===\n")

metro_patterns <- combined_analysis %>%
  group_by(metro_area) %>%
  summarise(
    n_tracts = n(),
    mean_old_housing_pct = round(mean(old_housing_pct, na.rm = TRUE), 1),
    mean_diversity_index = round(mean(diversity_index, na.rm = TRUE), 3),
    correlation = round(cor(old_housing_pct, diversity_index, use = "complete.obs"), 3),
    .groups = "drop"
  ) %>%
  arrange(desc(correlation))

cat("Housing age vs diversity correlation by metro area:\n")
print(metro_patterns)

# Step 6: Visualizations
cat("\n=== STEP 6: CREATING VISUALIZATIONS ===\n")

# Plot 1: Main correlation
p1 <- combined_analysis %>%
  ggplot(aes(x = old_housing_pct, y = diversity_index)) +
  geom_point(aes(color = metro_area), alpha = 0.6) +
  geom_smooth(method = "lm", color = "red") +
  scale_color_viridis_d(name = "Metro Area") +
  labs(
    title = "Housing Stock Age vs. Linguistic Diversity",
    subtitle = "Testing if older neighborhoods have higher linguistic diversity",
    x = "Old Housing Stock (% built before 1980)",
    y = "Linguistic Diversity Index"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")

print(p1)

# Plot 2: Distribution of housing ages
p2 <- combined_analysis %>%
  ggplot(aes(x = old_housing_pct)) +
  geom_histogram(bins = 30, fill = "grey20", alpha = 0.7) +
  geom_vline(xintercept = mean(combined_analysis$old_housing_pct), 
             color = "red", linetype = "dashed") +
  labs(
    title = "Distribution of Old Housing Stock",
    subtitle = "Percentage of housing units built before 1980 • Red line = mean",
    x = "Old Housing Stock (%)",
    y = "Count of Census Tracts"
  ) +
  theme_minimal()

print(p2)

# Plot 3: Diversity by housing age category
p3 <- combined_analysis %>%
  ggplot(aes(x = housing_age_category, y = diversity_index)) +
  geom_boxplot(fill = "grey20", alpha = 0.7) +
  labs(
    title = "Linguistic Diversity by Housing Age Category",
    subtitle = "Do older neighborhoods have consistently higher diversity?",
    x = "Housing Age Category",
    y = "Linguistic Diversity Index"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

print(p3)

# Plot 4: Metro area comparison
p4 <- combined_analysis %>%
  ggplot(aes(x = old_housing_pct, y = non_english_pct)) +
  geom_point(alpha = 0.5, color = "grey20") +
  geom_smooth(method = "lm", color = "red") +
  facet_wrap(~metro_area, scales = "free") +
  labs(
    title = "Housing Age vs. Non-English Speaking Population by Metro",
    subtitle = "Relationship varies by metropolitan area",
    x = "Old Housing Stock (%)",
    y = "Non-English Speaking (%)"
  ) +
  theme_minimal()

print(p4)

# Step 7: Language group analysis
cat("\n=== STEP 7: SPECIFIC LANGUAGE GROUP ANALYSIS ===\n")

# Test which language groups correlate most with old housing
lang_correlations <- combined_analysis %>%
  summarise(
    spanish_cor = cor(old_housing_pct, spanish_share, use = "complete.obs"),
    asian_cor = cor(old_housing_pct, asian_share, use = "complete.obs"),
    european_cor = cor(old_housing_pct, european_share, use = "complete.obs"),
    other_cor = cor(old_housing_pct, other_share, use = "complete.obs")
  ) %>%
  pivot_longer(everything(), names_to = "language_group", values_to = "correlation") %>%
  mutate(
    language_group = str_remove(language_group, "_cor"),
    language_group = str_to_title(language_group)
  ) %>%
  arrange(desc(abs(correlation)))

cat("Correlation between old housing and specific language groups:\n")
print(lang_correlations)

# Summary results
cat("\n=== SUMMARY RESULTS ===\n")

mean_old_housing <- mean(combined_analysis$old_housing_pct, na.rm = TRUE)
mean_diversity <- mean(combined_analysis$diversity_index, na.rm = TRUE)

cat("Overall Statistics:\n")
cat("  Mean old housing percentage:", round(mean_old_housing, 1), "%\n")
cat("  Mean linguistic diversity index:", round(mean_diversity, 3), "\n")
cat("  Tracts with complete data:", nrow(combined_analysis), "\n")

cat("\nHypothesis Test Results:\n")

# Primary hypothesis evaluation
if (cor_test1$p.value < 0.05) {
  direction <- ifelse(cor_test1$estimate > 0, "POSITIVE", "NEGATIVE")
  cat("  Housing age → Linguistic diversity: ", direction, " correlation (r = ", 
      round(cor_test1$estimate, 3), ", p = ", format.pval(cor_test1$p.value), ")\n")
  
  if (cor_test1$estimate > 0) {
    cat("  ✓ HYPOTHESIS SUPPORTED: Older neighborhoods have higher linguistic diversity\n")
  } else {
    cat("  ✗ HYPOTHESIS CONTRADICTED: Older neighborhoods have lower linguistic diversity\n")
  }
} else {
  cat("  Housing age → Linguistic diversity: No significant correlation\n")
  cat("  ○ HYPOTHESIS NOT SUPPORTED: No clear relationship found\n")
}

# Overall evaluation
strong_correlation <- abs(cor_test1$estimate) >= 0.3 && cor_test1$p.value < 0.05
moderate_correlation <- abs(cor_test1$estimate) >= 0.15 && cor_test1$p.value < 0.05

if (strong_correlation) {
  cat("\nOVERALL: OLD HOUSE, NEW LANGUAGE HYPOTHESIS STRONGLY SUPPORTED\n")
  cat("Clear evidence of relationship between housing age and linguistic diversity\n")
} else if (moderate_correlation) {
  cat("\nOVERALL: OLD HOUSE, NEW LANGUAGE HYPOTHESIS MODERATELY SUPPORTED\n")
  cat("Moderate evidence of relationship between housing age and linguistic diversity\n")
} else {
  cat("\nOVERALL: OLD HOUSE, NEW LANGUAGE HYPOTHESIS NOT SUPPORTED\n")
  cat("No clear evidence of relationship between housing age and linguistic diversity\n")
}

cat("\n=== ANALYSIS COMPLETE ===\n")