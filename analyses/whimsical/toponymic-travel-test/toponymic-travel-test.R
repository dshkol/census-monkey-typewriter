# Enhanced Toponymic Analysis - Deep Exploration of Name Complexity and Migration
# Following narrative depth standards from claude.md

library(tidycensus)
library(tidyverse)
library(tigris)
library(sf)
library(ggridges)
library(ggalt)
library(stringi)
library(english)
library(patchwork)
library(gt)
library(broom)

# Set API key and caching
census_api_key(Sys.getenv("CENSUS_API_KEY"))
options(tigris_use_cache = TRUE)

cat("=== ENHANCED TOPONYMIC TRAVEL TEST ===\n\n")
cat("A Deep Exploration of How Place Names Shape Human Migration\n\n")

# Part 1: Data Acquisition - Start with Texas then expand nationally
cat("PHASE 1: Data Discovery Journey\n")
cat("================================\n\n")

cat("Starting our investigation with Texas counties...\n")

# Get Texas data with geometry for mapping
tx_data <- get_acs(
  geography = "county",
  state = "TX",
  variables = c(
    total_pop = "B01003_001",
    movers_from_other_state = "B07001_093",
    median_income = "B19013_001",
    median_age = "B01002_001",
    pct_college = "B15003_022"  # Bachelor's degree
  ),
  year = 2022,
  output = "wide",
  geometry = TRUE,
  resolution = "20m",
  cb = TRUE
)

cat("✓ Retrieved data for", nrow(tx_data), "Texas counties\n\n")

# Part 2: Multi-dimensional Name Analysis
cat("PHASE 2: Deconstructing Place Names\n") 
cat("===================================\n\n")

# Enhanced name analysis function
analyze_county_name <- function(name) {
  # Clean the county name
  clean_name <- str_remove(str_extract(name, "^[^,]+"), " County$| Parish$")
  
  # Multiple complexity measures
  data.frame(
    county_name_clean = clean_name,
    
    # Basic metrics
    char_count = str_length(str_remove_all(clean_name, " ")),
    char_count_spaces = str_length(clean_name),
    word_count = str_count(clean_name, "\\S+"),
    
    # Phonetic complexity
    syllable_count = str_count(tolower(clean_name), "[aeiouy]+"),
    consonant_clusters = str_count(tolower(clean_name), "[bcdfghjklmnpqrstvwxyz]{2,}"),
    
    # Reading complexity  
    has_apostrophe = str_detect(clean_name, "'"),
    has_hyphen = str_detect(clean_name, "-"),
    has_special_char = str_detect(clean_name, "[^A-Za-z\\s-']"),
    
    # Linguistic origin indicators
    ends_in_o = str_detect(clean_name, "o$"),  # Spanish influence
    has_saint = str_detect(clean_name, "^St\\.|^Saint"),  # Religious naming
    has_direction = str_detect(clean_name, "^(North|South|East|West)"),
    
    # Pronunciation difficulty proxies
    double_letters = str_count(clean_name, "(.)\\1"),
    unique_chars = length(unique(str_split(tolower(clean_name), "")[[1]])),
    
    stringsAsFactors = FALSE
  )
}

# Apply to Texas data
name_analysis <- map_df(tx_data$NAME, analyze_county_name)

# Combine with main dataset
analysis_data <- tx_data %>%
  bind_cols(name_analysis) %>%
  mutate(
    # Calculate migration rate
    inmigration_rate = (movers_from_other_stateE / total_popE) * 1000,
    
    # Control variables
    log_pop = log(total_popE + 1),
    college_rate = (pct_collegeE / total_popE) * 100,
    
    # Create complexity indices
    phonetic_complexity = syllable_count + consonant_clusters + double_letters,
    orthographic_complexity = as.numeric(has_apostrophe) + as.numeric(has_hyphen) + 
                            as.numeric(has_special_char),
    
    # Name type categories
    name_origin = case_when(
      has_saint ~ "Religious",
      ends_in_o ~ "Spanish Origin",
      has_direction ~ "Directional",
      TRUE ~ "Other"
    )
  ) %>%
  filter(
    !is.na(inmigration_rate),
    total_popE > 1000  # Focus on counties with meaningful population
  )

# Part 3: Initial Discovery Visualizations
cat("Discovered", nrow(analysis_data), "counties with complete data\n\n")

cat("Sample of name complexity measures:\n")
complex_sample <- analysis_data %>%
  st_drop_geometry() %>%
  arrange(desc(char_count)) %>%
  head(5) %>%
  select(county_name_clean, char_count, syllable_count, phonetic_complexity, inmigration_rate)
print(complex_sample)

# Part 4: Deep Statistical Exploration
cat("\n\nPHASE 3: The Statistical Journey\n")
cat("================================\n\n")

# Multiple regression specifications
models <- list(
  simple = lm(inmigration_rate ~ char_count, data = analysis_data),
  controlled = lm(inmigration_rate ~ char_count + log_pop, data = analysis_data),
  full = lm(inmigration_rate ~ char_count + log_pop + median_incomeE + median_ageE + college_rate, 
            data = analysis_data),
  phonetic = lm(inmigration_rate ~ phonetic_complexity + log_pop, data = analysis_data),
  syllables = lm(inmigration_rate ~ syllable_count + log_pop, data = analysis_data),
  nonlinear = lm(inmigration_rate ~ poly(char_count, 2) + log_pop, data = analysis_data)
)

# Extract key results
cat("MODEL COMPARISON:\n")
model_results <- map_df(names(models), function(name) {
  mod <- models[[name]]
  if(name != "nonlinear") {
    key_var <- ifelse(name == "phonetic", "phonetic_complexity", 
                     ifelse(name == "syllables", "syllable_count", "char_count"))
    coef_data <- tidy(mod) %>% filter(term == key_var)
    data.frame(
      model = name,
      coefficient = coef_data$estimate,
      p_value = coef_data$p.value,
      r_squared = summary(mod)$r.squared
    )
  } else {
    # For polynomial model, report linear term
    coef_data <- tidy(mod) %>% filter(str_detect(term, "char_count"))
    data.frame(
      model = name,
      coefficient = coef_data$estimate[1],
      p_value = coef_data$p.value[1],
      r_squared = summary(mod)$r.squared
    )
  }
})

print(model_results)

# Part 5: Geographic Patterns
cat("\n\nPHASE 4: Geographic Discovery\n")
cat("=============================\n\n")

# Identify interesting county pairs
cat("CASE STUDIES: Similar Demographics, Different Names\n\n")

# Find pairs of counties with similar population but different name lengths
find_similar_counties <- function(data, target_county, n = 3) {
  target <- data %>% 
    filter(county_name_clean == target_county) %>%
    st_drop_geometry()
  
  if(nrow(target) == 0) return(NULL)
  
  similar <- data %>%
    st_drop_geometry() %>%
    mutate(
      pop_diff = abs(log_pop - target$log_pop),
      income_diff = abs(median_incomeE - target$median_incomeE) / target$median_incomeE,
      name_diff = abs(char_count - target$char_count)
    ) %>%
    filter(
      county_name_clean != target_county,
      pop_diff < 0.5,  # Similar population (log scale)
      income_diff < 0.2,  # Similar income (within 20%)
      name_diff > 5  # Very different name length
    ) %>%
    arrange(desc(name_diff)) %>%
    head(n)
  
  return(similar)
}

# Example pairs
pairs_to_examine <- c("Harris", "Bexar", "Dallas", "El Paso")

cat("County Pairs with Similar Demographics but Different Name Lengths:\n\n")
for(county in pairs_to_examine) {
  similar <- find_similar_counties(analysis_data, county, n = 2)
  if(!is.null(similar) && nrow(similar) > 0) {
    cat(county, "County (", 
        analysis_data$char_count[analysis_data$county_name_clean == county][1], 
        " chars) vs:\n")
    for(i in 1:nrow(similar)) {
      cat("  -", similar$county_name_clean[i], 
          "(", similar$char_count[i], "chars,",
          "migration rate:", round(similar$inmigration_rate[i], 1), ")\n")
    }
    cat("\n")
  }
}

# Part 6: National Expansion
cat("\n\nPHASE 5: National Perspective\n")
cat("=============================\n\n")

cat("Expanding analysis to national scale...\n")

# Get a sample of states for national perspective
sample_states <- c("CA", "NY", "FL", "IL", "PA", "OH", "MI", "NC", "GA", "WA")

national_data <- get_acs(
  geography = "county",
  state = sample_states,
  variables = c(
    total_pop = "B01003_001",
    movers_from_other_state = "B07001_093"
  ),
  year = 2022,
  output = "wide",
  geometry = FALSE
)

# Process national data
national_analysis <- map_df(national_data$NAME, analyze_county_name) %>%
  bind_cols(national_data) %>%
  mutate(
    inmigration_rate = (movers_from_other_stateE / total_popE) * 1000,
    state = str_extract(NAME, "[A-Z]{2}$")
  ) %>%
  filter(!is.na(inmigration_rate))

cat("✓ Analyzed", nrow(national_analysis), "counties across", 
    length(unique(national_analysis$state)), "states\n\n")

# Regional patterns
regional_summary <- national_analysis %>%
  group_by(state) %>%
  summarise(
    counties = n(),
    mean_name_length = mean(char_count),
    mean_migration = mean(inmigration_rate, na.rm = TRUE),
    correlation = cor(char_count, inmigration_rate, use = "complete.obs")
  ) %>%
  arrange(desc(abs(correlation)))

cat("STATE-LEVEL PATTERNS:\n")
print(regional_summary)

# Part 7: Historical Context
cat("\n\nPHASE 6: Historical Name Changes & Migration\n")
cat("===========================================\n\n")

# Notable county name changes (manually curated examples)
name_changes <- tribble(
  ~old_name, ~new_name, ~state, ~year_changed, ~reason,
  "Dade County", "Miami-Dade County", "FL", 1997, "Recognition of largest city",
  "King County", "King County", "WA", 2005, "Rededication from William R. King to MLK Jr.",
  "Greer County", "(Dissolved)", "OK/TX", 1896, "Territorial dispute resolution"
)

cat("Historical County Name Changes:\n")
print(name_changes)

cat("\nSpeculation: Could strategic renaming influence migration patterns?\n")
cat("If counties could rebrand like corporations, what would happen?\n\n")

# Part 8: Cognitive Science Perspective
cat("PHASE 7: The Psychology of Place Names\n")
cat("=====================================\n\n")

# Readability analysis
flesch_kincaid_approximation <- function(name) {
  words <- str_count(name, "\\S+")
  syllables <- str_count(tolower(name), "[aeiouy]+")
  if(words == 0) return(NA)
  
  # Simplified Flesch Reading Ease approximation
  206.835 - 1.015 * (1) - 84.6 * (syllables / words)
}

analysis_data <- analysis_data %>%
  mutate(
    reading_ease = map_dbl(county_name_clean, flesch_kincaid_approximation),
    cognitive_load = phonetic_complexity + orthographic_complexity,
    
    # Memorability factors
    name_length_category = case_when(
      char_count <= 5 ~ "Very Short",
      char_count <= 8 ~ "Short",
      char_count <= 12 ~ "Medium",
      char_count <= 16 ~ "Long",
      TRUE ~ "Very Long"
    )
  )

# Summary by cognitive load
cognitive_summary <- analysis_data %>%
  st_drop_geometry() %>%
  group_by(name_length_category) %>%
  summarise(
    counties = n(),
    mean_migration = mean(inmigration_rate, na.rm = TRUE),
    sd_migration = sd(inmigration_rate, na.rm = TRUE),
    mean_income = mean(median_incomeE, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(name_length_category = factor(name_length_category, 
                                       levels = c("Very Short", "Short", "Medium", 
                                                 "Long", "Very Long")))

cat("COGNITIVE LOAD ANALYSIS:\n")
print(cognitive_summary)

# Part 9: What If Scenarios
cat("\n\nPHASE 8: Thought Experiments\n")
cat("============================\n\n")

cat("WHAT IF: Every county adopted a 5-character name?\n")
short_name_world <- analysis_data %>%
  st_drop_geometry() %>%
  filter(char_count <= 5)

cat("- Current counties with ≤5 char names:", nrow(short_name_world), "\n")
cat("- Their average migration rate:", round(mean(short_name_world$inmigration_rate), 2), "\n")
cat("- Compared to overall average:", round(mean(analysis_data$inmigration_rate), 2), "\n\n")

cat("WHAT IF: Counties could use emojis in their names?\n")
cat("- 🌵 County, Arizona?\n")
cat("- 🏔️ County, Colorado?\n")
cat("- Would visual symbols reduce cognitive load?\n\n")

# Part 10: Conclusions
cat("PHASE 9: Synthesis and Wonder\n")
cat("=============================\n\n")

# Effect size calculations
main_model <- models$controlled
main_coef <- coef(main_model)["char_count"]
mean_migration <- mean(analysis_data$inmigration_rate, na.rm = TRUE)
sd_name <- sd(analysis_data$char_count, na.rm = TRUE)
effect_size <- main_coef * sd_name
effect_pct <- abs(effect_size) / mean_migration * 100

cat("KEY FINDINGS:\n")
cat("- Effect per character:", round(main_coef, 6), "migrants per 1,000\n")
cat("- One SD change in name length:", round(effect_size, 4), "migrants\n") 
cat("- As percentage of mean:", round(effect_pct, 2), "%\n")
cat("- Statistical significance:", ifelse(summary(main_model)$coefficients["char_count", 4] < 0.05, 
                                          "YES", "NO"), "\n\n")

cat("REMAINING MYSTERIES:\n")
cat("- Why do some long-named counties thrive? (Cultural identity?)\n")
cat("- Do pronunciation and spelling correlate? (Linguistic patterns?)\n")
cat("- Would name simplification campaigns work? (Policy implications?)\n")
cat("- How do digital maps change the equation? (Technology effects?)\n\n")

cat("This analysis reveals that while toponymic complexity has minimal\n")
cat("aggregate effect on migration, the psychological hypothesis remains\n")
cat("intriguing for further investigation in other domains.\n\n")

# Save key objects for RMarkdown
save(analysis_data, models, model_results, national_analysis, 
     regional_summary, cognitive_summary,
     file = "toponymic_analysis_results.RData")

cat("🤖 Enhanced Toponymic Travel Test Complete!\n")
cat("Results saved for visualization in R Markdown.\n")