# Simplified Loneliness Gradient Analysis
# Based on successful California test results

# Load required libraries
library(tidyverse)
library(tidycensus)
library(sf)
library(viridis)
library(mgcv)
library(broom)
library(scales)

# Set options
options(tigris_use_cache = TRUE)

# Load the California test results
load("/Users/dmitryshkolnik/Projects/census-monkey-typewriter/analyses/serious/loneliness-gradient/data/ca_test_results.RData")

cat("California analysis results loaded.\n")
cat("Dataset size:", nrow(ca_analysis), "tracts\n")

# Display key findings
cat("\n=== KEY FINDINGS ===\n")
print(isolation_by_density)

# Create enhanced visualizations
theme_custom <- theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    plot.subtitle = element_text(size = 12),
    plot.caption = element_text(size = 10, hjust = 1),
    axis.title = element_text(size = 11),
    axis.text = element_text(size = 10)
  )

# Plot 1: Improved scatterplot showing the relationship
p1 <- ggplot(ca_analysis, aes(x = log_pop_density, y = isolation_index)) +
  geom_point(alpha = 0.4, color = "grey20", size = 0.8) +
  geom_smooth(method = "gam", formula = y ~ s(x, k = 6), se = TRUE, 
              color = "red", linewidth = 1.2) +
  theme_custom +
  labs(
    title = "Social Isolation by Population Density",
    subtitle = "California Census Tracts (2022 ACS)",
    x = "Log Population Density (people per sq mile)",
    y = "Social Isolation Index (standardized)",
    caption = "Data: US Census Bureau ACS 2022 | Higher values = more isolated"
  )

ggsave("/Users/dmitryshkolnik/Projects/census-monkey-typewriter/analyses/serious/loneliness-gradient/figures/isolation_density_scatter.png",
       p1, width = 10, height = 7, dpi = 300)

print(p1)

# Plot 2: Box plot with statistical annotations
summary_stats <- ca_analysis %>%
  group_by(density_category) %>%
  summarise(
    n = n(),
    mean_isolation = mean(isolation_index, na.rm = TRUE),
    median_isolation = median(isolation_index, na.rm = TRUE),
    .groups = "drop"
  )

p2 <- ggplot(ca_analysis, aes(x = density_category, y = isolation_index)) +
  geom_boxplot(fill = "grey20", alpha = 0.7, outlier.alpha = 0.3) +
  stat_summary(fun = mean, geom = "point", shape = 23, size = 4, 
               fill = "red", color = "darkred") +
  theme_custom +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(
    title = "Social Isolation Index by Settlement Density Category",
    subtitle = "California Census Tracts - Red diamonds show means (2022 ACS)",
    x = "Population Density Category",
    y = "Social Isolation Index (standardized)",
    caption = "Data: US Census Bureau ACS 2022"
  )

ggsave("/Users/dmitryshkolnik/Projects/census-monkey-typewriter/analyses/serious/loneliness-gradient/figures/isolation_by_category.png",
       p2, width = 12, height = 8, dpi = 300)

print(p2)

# Plot 3: Component analysis - what drives isolation
components_long <- ca_analysis %>%
  select(density_category, z_single_person, z_long_commute, z_elderly) %>%
  pivot_longer(cols = starts_with("z_"), 
               names_to = "component", 
               values_to = "value") %>%
  mutate(component = case_when(
    component == "z_single_person" ~ "Single-Person Households",
    component == "z_long_commute" ~ "Long Commutes (30+ min)",
    component == "z_elderly" ~ "Elderly Population (65+)"
  ))

p3 <- ggplot(components_long, aes(x = density_category, y = value, fill = component)) +
  geom_boxplot(alpha = 0.7, outlier.alpha = 0.2) +
  facet_wrap(~component, ncol = 1) +
  scale_fill_viridis_d(guide = "none") +
  theme_custom +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(
    title = "Components of Social Isolation Index",
    subtitle = "Standardized measures by density category - California (2022 ACS)",
    x = "Population Density Category",
    y = "Standardized Value (z-score)",
    caption = "Data: US Census Bureau ACS 2022"
  )

ggsave("/Users/dmitryshkolnik/Projects/census-monkey-typewriter/analyses/serious/loneliness-gradient/figures/isolation_components.png",
       p3, width = 12, height = 10, dpi = 300)

print(p3)

# Statistical analysis summary
cat("\n=== STATISTICAL ANALYSIS ===\n")
cat("GAM Model Summary:\n")
summary(gam_model)

# Test for monotonic vs U-shaped relationship
linear_test <- lm(isolation_index ~ log_pop_density + pct_elderly + median_income + pct_college,
                  data = ca_analysis, weights = B01001_001E)

anova_comparison <- anova(linear_test, gam_model, test = "F")
cat("\nModel Comparison (Linear vs GAM):\n")
print(anova_comparison)

# Calculate effect sizes by density category
effect_summary <- ca_analysis %>%
  group_by(density_category) %>%
  summarise(
    n_tracts = n(),
    population = sum(B01001_001E, na.rm = TRUE),
    mean_isolation = round(mean(isolation_index, na.rm = TRUE), 3),
    se_isolation = round(sd(isolation_index, na.rm = TRUE) / sqrt(n()), 4),
    mean_single_person = round(mean(pct_single_person, na.rm = TRUE), 1),
    mean_long_commute = round(mean(pct_long_commute, na.rm = TRUE), 1),
    mean_elderly = round(mean(pct_elderly, na.rm = TRUE), 1),
    median_income = round(median(median_income, na.rm = TRUE)),
    .groups = "drop"
  )

cat("\nEffect Summary by Density Category:\n")
print(effect_summary)

# Test specific hypotheses
rural_isolation <- effect_summary$mean_isolation[1]
suburban_isolation <- effect_summary$mean_isolation[2:4] # Low, Medium, High density
urban_isolation <- effect_summary$mean_isolation[5]

cat("\n=== HYPOTHESIS TESTING ===\n")
cat("Rural isolation mean:", rural_isolation, "\n")
cat("Suburban isolation range:", min(suburban_isolation), "to", max(suburban_isolation), "\n") 
cat("Urban isolation mean:", urban_isolation, "\n")

# Key policy findings
max_suburban <- max(suburban_isolation)
is_u_shaped <- (rural_isolation > min(suburban_isolation)) && (urban_isolation > min(suburban_isolation))
rural_higher <- rural_isolation > mean(suburban_isolation)

cat("\nPolicy-Relevant Findings:\n")
cat("- Rural areas show highest isolation:", rural_higher, "\n")
cat("- U-shaped relationship present:", is_u_shaped, "\n")
cat("- Maximum suburban isolation:", max_suburban, "\n")

# Save enhanced results
save(ca_analysis, effect_summary, gam_model, linear_test, anova_comparison,
     p1, p2, p3, rural_isolation, suburban_isolation, urban_isolation,
     file = "/Users/dmitryshkolnik/Projects/census-monkey-typewriter/analyses/serious/loneliness-gradient/data/enhanced_results.RData")

cat("\nAnalysis complete. Enhanced results and visualizations saved.\n")