# ==============================================================================
# The Commuting Dead: DEMONSTRATION VERSION
# Mapping the Geography of Vehicle-less, Transit-Poor Households
# Analysis of transportation access and employment outcomes at the census tract level
# ==============================================================================

# This demonstration version uses simulated data that mirrors the structure
# of real Census data to show the analytical methodology

# Load required libraries
library(tidyverse)
library(sf)
library(viridis)
library(scales)

# Set up theme
theme_transit <- theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    plot.subtitle = element_text(size = 12),
    legend.position = "bottom",
    axis.text = element_text(size = 10),
    strip.text = element_text(size = 11, face = "bold")
  )

# ==============================================================================
# SIMULATED DATA CREATION
# ==============================================================================

cat("=== CREATING SIMULATED DEMONSTRATION DATA ===\n")

# Create simulated data that mirrors Census tract structure
set.seed(42)
n_tracts <- 500

# Create tract-level data with realistic distributions
simulated_data <- tibble(
  GEOID = sprintf("48%03d%06d", 
                 sample(1:10, n_tracts, replace = TRUE), 
                 sample(1:999999, n_tracts)),
  
  # Simulate household and vehicle data
  total_households = rpois(n_tracts, 800) + 200,
  no_vehicle_hh = rbinom(n_tracts, total_households, prob = runif(n_tracts, 0.02, 0.45)),
  
  # Simulate worker and transportation data  
  total_workers = round(total_households * runif(n_tracts, 0.4, 0.8)),
  public_transit_workers = rbinom(n_tracts, total_workers, prob = runif(n_tracts, 0.01, 0.25)),
  
  # Simulate employment outcomes (higher unemployment in transit deserts)
  unemployment_rate = pmax(0, pmin(25, 
    rnorm(n_tracts, mean = 6, sd = 3) + 
    scale(no_vehicle_hh/total_households)[,1] * 2 +  # Higher unemployment with more no-vehicle
    -scale(public_transit_workers/total_workers)[,1] * 1)), # Lower unemployment with more transit
  
  # Create geographic identifiers
  metro_area = sample(c("Houston", "Dallas", "Austin"), n_tracts, 
                     replace = TRUE, prob = c(0.5, 0.3, 0.2)),
  
  # Create simple coordinates for mapping
  longitude = runif(n_tracts, -96.5, -95.0),
  latitude = runif(n_tracts, 29.5, 30.2)
) %>%
  mutate(
    # Calculate percentages
    pct_no_vehicle = (no_vehicle_hh / total_households) * 100,
    pct_public_transit = (public_transit_workers / total_workers) * 100
  )

cat("Simulated", nrow(simulated_data), "census tracts\n")
cat("Metro areas:", paste(unique(simulated_data$metro_area), collapse = ", "), "\n")

# ==============================================================================
# QUADRANT ANALYSIS - IDENTIFYING "THE COMMUTING DEAD"
# ==============================================================================

cat("\n=== QUADRANT ANALYSIS ===\n")

# Calculate median values for quadrant splits
median_no_vehicle <- median(simulated_data$pct_no_vehicle)
median_public_transit <- median(simulated_data$pct_public_transit)

cat("Quadrant thresholds:\n")
cat("Median % No Vehicle:", round(median_no_vehicle, 2), "\n")
cat("Median % Public Transit:", round(median_public_transit, 2), "\n")

# Create quadrant classifications
transit_analysis <- simulated_data %>%
  mutate(
    quadrant = case_when(
      pct_no_vehicle >= median_no_vehicle & pct_public_transit < median_public_transit ~ "Commuting Dead",
      pct_no_vehicle >= median_no_vehicle & pct_public_transit >= median_public_transit ~ "Transit Dependent", 
      pct_no_vehicle < median_no_vehicle & pct_public_transit >= median_public_transit ~ "Transit Choice",
      pct_no_vehicle < median_no_vehicle & pct_public_transit < median_public_transit ~ "Car Dependent",
      TRUE ~ "Other"
    ),
    
    # Create extreme classification
    vehicle_quartile = ntile(pct_no_vehicle, 4),
    transit_quartile = ntile(pct_public_transit, 4),
    
    extreme_classification = case_when(
      vehicle_quartile == 4 & transit_quartile == 1 ~ "Extreme Commuting Dead",
      vehicle_quartile >= 3 & transit_quartile <= 2 ~ "Moderate Commuting Dead",
      TRUE ~ "Other"
    )
  )

# Quadrant summary
cat("\nQuadrant distribution:\n")
print(table(transit_analysis$quadrant))

cat("\nExtreme classification distribution:\n")
print(table(transit_analysis$extreme_classification))

# ==============================================================================
# STATISTICAL ANALYSIS
# ==============================================================================

cat("\n=== STATISTICAL ANALYSIS ===\n")

# Analyze unemployment by quadrant
unemployment_by_quadrant <- transit_analysis %>%
  group_by(quadrant) %>%
  summarise(
    n_tracts = n(),
    mean_unemployment = mean(unemployment_rate, na.rm = TRUE),
    median_unemployment = median(unemployment_rate, na.rm = TRUE),
    sd_unemployment = sd(unemployment_rate, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(mean_unemployment))

cat("Unemployment by quadrant:\n")
print(unemployment_by_quadrant)

# Statistical test - ANOVA
aov_result <- aov(unemployment_rate ~ quadrant, data = transit_analysis)
cat("\nANOVA results:\n")
print(summary(aov_result))

# Correlation analysis
cat("\nCorrelation analysis:\n")
correlations <- transit_analysis %>%
  select(pct_no_vehicle, pct_public_transit, unemployment_rate) %>%
  cor(use = "complete.obs")
print(round(correlations, 3))

# Linear regression models
cat("\nRegression analysis:\n")

# Model 1: Simple relationship
model1 <- lm(unemployment_rate ~ pct_no_vehicle + pct_public_transit, 
             data = transit_analysis)

# Model 2: Add quadrant effects
model2 <- lm(unemployment_rate ~ pct_no_vehicle + pct_public_transit + quadrant,
             data = transit_analysis)

# Model 3: Add metro area fixed effects
model3 <- lm(unemployment_rate ~ pct_no_vehicle + pct_public_transit + quadrant + metro_area,
             data = transit_analysis)

cat("Model 1 - Basic relationship:\n")
print(summary(model1))

cat("\nModel 2 - With quadrant effects:\n")
print(summary(model2))

cat("\nModel 3 - With metro fixed effects:\n")
print(summary(model3))

# ==============================================================================
# VISUALIZATION
# ==============================================================================

cat("\n=== CREATING VISUALIZATIONS ===\n")

# Create figures directory
dir.create("figures", showWarnings = FALSE)

# 1. Quadrant scatter plot
p1 <- ggplot(transit_analysis, aes(x = pct_public_transit, y = pct_no_vehicle, color = quadrant)) +
  geom_point(alpha = 0.6, size = 2) +
  geom_hline(yintercept = median_no_vehicle, linetype = "dashed", alpha = 0.7) +
  geom_vline(xintercept = median_public_transit, linetype = "dashed", alpha = 0.7) +
  scale_color_manual(values = c("Commuting Dead" = "#d73027",
                               "Transit Dependent" = "#4575b4", 
                               "Transit Choice" = "#91bfdb",
                               "Car Dependent" = "#fee08b")) +
  labs(
    title = "The Commuting Dead: Transit Access vs Vehicle Availability",
    subtitle = "Census tracts classified by transportation access patterns",
    x = "% Workers Using Public Transit",
    y = "% Households with No Vehicle",
    color = "Transit Access Category"
  ) +
  theme_transit

print(p1)
ggsave("figures/quadrant_analysis_demo.png", p1, width = 12, height = 8, dpi = 300)

# 2. Unemployment by quadrant
p2 <- ggplot(transit_analysis, aes(x = reorder(quadrant, unemployment_rate), y = unemployment_rate, fill = quadrant)) +
  geom_boxplot(alpha = 0.7) +
  scale_fill_manual(values = c("Commuting Dead" = "#d73027",
                              "Transit Dependent" = "#4575b4",
                              "Transit Choice" = "#91bfdb", 
                              "Car Dependent" = "#fee08b")) +
  labs(
    title = "Employment Outcomes by Transit Access Category",
    subtitle = "Unemployment rates across transportation access patterns",
    x = "Transit Access Category",
    y = "Unemployment Rate (%)",
    fill = "Category"
  ) +
  theme_transit +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  guides(fill = "none")

print(p2)
ggsave("figures/unemployment_by_quadrant_demo.png", p2, width = 10, height = 6, dpi = 300)

# 3. Correlation matrix heatmap
correlation_data <- expand.grid(
  Var1 = c("% No Vehicle", "% Public Transit", "Unemployment Rate"),
  Var2 = c("% No Vehicle", "% Public Transit", "Unemployment Rate")
) %>%
  mutate(
    correlation = c(
      correlations[1,1], correlations[1,2], correlations[1,3],
      correlations[2,1], correlations[2,2], correlations[2,3], 
      correlations[3,1], correlations[3,2], correlations[3,3]
    )
  )

p3 <- ggplot(correlation_data, aes(x = Var1, y = Var2, fill = correlation)) +
  geom_tile() +
  geom_text(aes(label = round(correlation, 2)), color = "white", size = 4) +
  scale_fill_gradient2(low = "#2166ac", mid = "white", high = "#d73027", 
                      midpoint = 0, name = "Correlation") +
  labs(
    title = "Correlation Matrix: Transportation Access and Employment",
    x = "", y = ""
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

print(p3)
ggsave("figures/correlation_matrix_demo.png", p3, width = 8, height = 6, dpi = 300)

# 4. Geographic visualization (simplified)
# Create simple point map
p4 <- ggplot(transit_analysis, aes(x = longitude, y = latitude, color = quadrant)) +
  geom_point(alpha = 0.7, size = 1.5) +
  scale_color_manual(values = c("Commuting Dead" = "#d73027",
                               "Transit Dependent" = "#4575b4",
                               "Transit Choice" = "#91bfdb",
                               "Car Dependent" = "#fee08b")) +
  facet_wrap(~ metro_area) +
  labs(
    title = "Geographic Distribution of Transit Access Categories",
    subtitle = "Simulated data showing spatial patterns of transportation access",
    x = "Longitude", y = "Latitude",
    color = "Transit Access Category"
  ) +
  theme_transit +
  theme(axis.text = element_text(size = 8))

print(p4)
ggsave("figures/geographic_distribution_demo.png", p4, width = 12, height = 8, dpi = 300)

# ==============================================================================
# POLICY ANALYSIS
# ==============================================================================

cat("\n=== POLICY ANALYSIS ===\n")

# Identify most severe "Commuting Dead" tracts
commuting_dead_tracts <- transit_analysis %>%
  filter(quadrant == "Commuting Dead") %>%
  arrange(desc(unemployment_rate)) %>%
  select(GEOID, metro_area, pct_no_vehicle, pct_public_transit, 
         unemployment_rate, total_households, total_workers)

cat("Top 10 most severe 'Commuting Dead' tracts by unemployment:\n")
print(head(commuting_dead_tracts, 10))

# Summary statistics for policy targeting
policy_summary <- transit_analysis %>%
  group_by(quadrant) %>%
  summarise(
    n_tracts = n(),
    total_households = sum(total_households),
    avg_unemployment = mean(unemployment_rate),
    households_no_vehicle = sum(no_vehicle_hh),
    .groups = "drop"
  ) %>%
  mutate(
    pct_total_households = (total_households / sum(total_households)) * 100
  )

cat("\nPolicy targeting summary:\n")
print(policy_summary)

# Effect size calculation
commuting_dead_unemployment <- mean(transit_analysis$unemployment_rate[transit_analysis$quadrant == "Commuting Dead"])
other_unemployment <- mean(transit_analysis$unemployment_rate[transit_analysis$quadrant != "Commuting Dead"])

cat("\nKey findings:\n")
cat("Total 'Commuting Dead' households:", 
    comma(sum(policy_summary$total_households[policy_summary$quadrant == "Commuting Dead"])), "\n")
cat("Average unemployment in 'Commuting Dead' areas:", round(commuting_dead_unemployment, 2), "%\n")
cat("Average unemployment in other areas:", round(other_unemployment, 2), "%\n")
cat("Unemployment rate difference:", round(commuting_dead_unemployment - other_unemployment, 2), 
    "percentage points\n")

# Calculate Cohen's d effect size
pooled_sd <- sqrt(((sum(transit_analysis$quadrant == "Commuting Dead") - 1) * 
                   var(transit_analysis$unemployment_rate[transit_analysis$quadrant == "Commuting Dead"]) +
                   (sum(transit_analysis$quadrant != "Commuting Dead") - 1) * 
                   var(transit_analysis$unemployment_rate[transit_analysis$quadrant != "Commuting Dead"])) /
                  (nrow(transit_analysis) - 2))

cohens_d <- (commuting_dead_unemployment - other_unemployment) / pooled_sd
cat("Effect size (Cohen's d):", round(cohens_d, 3), "\n")

# Export data
dir.create("data", showWarnings = FALSE)
write_csv(commuting_dead_tracts, "data/commuting_dead_tracts_demo.csv")
write_csv(transit_analysis, "data/full_transit_analysis_demo.csv")

cat("\n=== DEMONSTRATION ANALYSIS COMPLETE ===\n")
cat("This demonstration shows the methodology for identifying 'Commuting Dead' zones\n")
cat("using simulated data that mirrors real Census tract patterns.\n")
cat("\nKey outputs:\n")
cat("- Quadrant analysis identifying", nrow(commuting_dead_tracts), "severely affected tracts\n")
cat("- Statistical evidence of", round(cohens_d, 2), "standard deviation difference in unemployment\n")
cat("- Visualizations saved to figures/ directory\n")
cat("- Analysis data exported to data/ directory\n")
cat("\nTo run with real Census data, ensure API key is configured and API limits are respected.\n")