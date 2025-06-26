# Census Data Analysis with R: Quick Reference Guide

## Chapter 1: Introduction to the Census
**Main Theme:** Overview of US Census data sources and R programming basics for census analysis

**Key Functions Introduced:**
- Basic R functions for data manipulation
- Introduction to tidyverse ecosystem

**Important Concepts:**
- US Census hierarchy (nation → states → counties → tracts → block groups → blocks)
- Difference between Decennial Census and American Community Survey (ACS)
- Census data as sample-based estimates with margins of error

**Practical Examples:**
- Understanding Census geography levels
- Basic data loading and exploration

**Gotchas/Important Notes:**
- Census data represents estimates, not exact counts (except for Decennial Census)
- Geographic boundaries change over time
- Data availability varies by year and geography level

---

## Chapter 2: Getting Started with tidycensus
**Main Theme:** Core functionality of tidycensus package for accessing Census data via API

**Key Functions Introduced:**
- `census_api_key()` - Set up API access
- `get_decennial()` - Access Decennial Census data
- `get_acs()` - Access American Community Survey data
- `get_estimates()` - Access Population Estimates Program data
- `get_flows()` - Access migration flows data
- `load_variables()` - Browse available variables

**Important Concepts:**
- API key setup and management
- Wide vs. tidy data formats
- Understanding variable codes and names
- Geography specification

**Practical Examples:**
```r
# Basic ACS data retrieval
get_acs(geography = "county", 
        variables = "B19013_001",
        state = "TX",
        year = 2020)
```

**Gotchas/Important Notes:**
- Must register for free Census API key
- Default year changes - always specify explicitly
- Some geographies not available for all years
- Variable codes change between surveys

---

## Chapter 3: Wrangling Census Data with tidyverse Tools
**Main Theme:** Data manipulation and transformation techniques for census data

**Key Functions Introduced:**
- `mutate()` - Create new variables
- `filter()` - Subset data
- `group_by()` and `summarize()` - Aggregate data
- `pivot_wider()` and `pivot_longer()` - Reshape data
- `moe_sum()` - Calculate margins of error for derived estimates

**Important Concepts:**
- Working with margins of error
- Creating derived variables
- Handling missing data
- Time series analysis with census data

**Practical Examples:**
- Calculating percentages with proper error propagation
- Creating demographic indices
- Comparing data across time periods

**Gotchas/Important Notes:**
- Always account for margins of error in calculations
- Use `moe_prop()` for proportions, `moe_sum()` for sums
- Be careful with universe definitions when calculating percentages

---

## Chapter 4: Visualizing Census Data
**Main Theme:** Creating effective visualizations of census data using ggplot2

**Key Functions Introduced:**
- `geom_col()` and `geom_bar()` - Bar charts
- `geom_line()` - Time series plots
- `geom_errorbar()` - Margin of error visualization
- `facet_wrap()` and `facet_grid()` - Small multiples
- `scale_*_continuous()` - Axis formatting
- `ggplotly()` - Convert to interactive plots

**Advanced Visualization Techniques:**
- **Population Pyramids**: Age-sex structure visualization
- **Faceted Visualizations**: Small multiples for geographic/temporal comparisons
- **Time Series with Confidence Bands**: Showing temporal trends with uncertainty
- **Dot Plots for Rankings**: Alternative to bar charts for many categories
- **Interactive Plots**: Web-based graphics with plotly integration

**Uncertainty Visualization Patterns:**
```r
# Error bars for estimates
geom_errorbar(aes(ymin = estimate - moe, 
                  ymax = estimate + moe), 
              width = 0.2)

# Confidence bands for time series
geom_ribbon(aes(ymin = estimate - moe,
                ymax = estimate + moe), 
            alpha = 0.3)
```

**Design Principles for Demographics:**
- **Universe Awareness**: Always clarify population being analyzed
- **Normalization**: Use percentages/rates vs raw counts for comparisons
- **Log Scales**: Consider for skewed distributions
- **Comparative Context**: Show reference lines or comparison groups
- **Accessibility**: Colorblind-friendly palettes mandatory (viridis)

**Color and Accessibility Standards:**
- **Continuous scales**: Use `scale_fill_viridis_c()` exclusively
- **Single colors**: Dark grey (`"grey20"`) for simple charts
- **Avoid rainbow scales**: Not perceptually uniform
- **Interactive elements**: Hover, zoom, click-to-filter capabilities

**Common Visualization Patterns:**
1. **Comparative Bar Charts**: Include error bars, consider horizontal orientation
2. **Time Series**: Include confidence bands, use `geom_smooth()` for trends
3. **Small Multiples**: Consistent scales when appropriate, free scales for different magnitudes
4. **Distribution Plots**: Ridgeline plots for comparative densities

**Essential Code Template:**
```r
# Standard demographic bar chart
ggplot(data, aes(x = reorder(geography, estimate), y = estimate)) +
  geom_col(fill = "grey20") +
  geom_errorbar(aes(ymin = estimate - moe, ymax = estimate + moe), 
                width = 0.2) +
  coord_flip() +
  scale_y_continuous(labels = scales::percent) +
  labs(subtitle = "Clear, descriptive title",
       x = NULL, y = "Percentage",
       caption = "Source: American Community Survey")
```

**Gotchas/Important Notes:**
- Always show margins of error when relevant
- Normalize data for geographic comparisons
- Consider using log scales for skewed data
- Use colorblind-friendly palettes (viridis family)
- Label universes clearly in subtitles

---

## Chapter 5: Census Geographic Data and Mapping Foundations
**Main Theme:** Working with Census geographic boundaries using tigris package

**Geographic Hierarchy:**
- **Nation → States → Counties → Tracts → Block Groups → Blocks**
- Census tracts: 1,200-8,000 people
- Block groups: 600-3,000 people  
- PUMAs: 100,000+ people
- Boundaries change over time, especially tract/block group levels

**Key Functions Introduced:**
- `states()`, `counties()`, `tracts()`, `block_groups()` - Geographic boundaries
- `places()` - Incorporated places (cities, towns)
- `core_based_statistical_areas()` - Metro/micro areas
- `urban_areas()` - Urbanized areas
- `zctas()` - ZIP Code Tabulation Areas
- `st_transform()` - Project spatial data
- `shift_geometry()` - Inset Alaska/Hawaii for national maps
- `erase_water()` - Remove water areas

**Critical Parameters:**
- `state`, `county` - Filter to specific geographies
- `year` - Specify boundary vintage (boundaries change!)
- `cb` - Use cartographic boundaries when TRUE (simplified)
- `class` - Return "sf" (recommended) vs "sp" objects

**Spatial Data Structure (sf objects):**
- Combines data frame with geometry column
- Each row = geographic feature
- Geometry column contains spatial information
- Works with standard dplyr operations

**Coordinate Reference Systems (CRS):**
- **Default**: NAD83 (EPSG:4269) for Census data
- **Web mapping**: Web Mercator (EPSG:3857)
- **Analysis**: Use projected CRS for distance/area calculations
- **National maps**: Albers Equal Area for continental US
- **State analysis**: State Plane coordinates
- **Local analysis**: UTM zones

**Cartographic vs TIGER Boundaries:**
- **Cartographic** (`cb = TRUE`): Simplified, faster rendering, cleaner appearance
- **TIGER** (default): Detailed, follows coastlines exactly, precise analysis
- **Use cartographic for**: Visualization, national/state maps, web mapping
- **Use TIGER for**: Precise spatial analysis, local analysis

**Water Handling:**
```r
county_no_water <- erase_water(county_data, 
                               area_threshold = 0.1,
                               year = 2020)
```
- `area_threshold`: Proportion that must be water to remove (0-1)
- Default removes features >99% water

**Alaska/Hawaii Insets:**
```r
us_states <- states(cb = TRUE) %>% shift_geometry()
```
- Automatically scales and positions for national maps
- Creates standard "lower 48 + insets" layout

**Performance Optimization:**
```r
# Essential setup
options(tigris_use_cache = TRUE)

# Download and save large datasets
all_tracts <- tracts(state = "CA", cb = TRUE)
saveRDS(all_tracts, "ca_tracts.rds")

# Load in future sessions
all_tracts <- readRDS("ca_tracts.rds")
```

**Common Workflows:**

**Option 1: Integrated approach**
```r
data <- get_acs(geography = "tract", variables = "B19013_001",
                state = "TX", geometry = TRUE)  # Uses tigris internally
```

**Option 2: Separate data and boundaries**
```r
acs_data <- get_acs(geography = "county", variables = "B19013_001", state = "TX")
boundaries <- counties(state = "TX", cb = TRUE)
combined <- boundaries %>% left_join(acs_data, by = "GEOID")
```

**Best Practices:**
- Always match years between data and boundaries
- Use consistent geography levels
- Join on GEOID for reliable matching
- Check for missing joins (especially historical data)

**Gotchas/Important Notes:**
- Use `cb = TRUE` for cartographic boundaries (simplified)
- Always check/set CRS before spatial operations
- Cache downloads with `options(tigris_use_cache = TRUE)`
- Boundaries change over time - match years carefully
- Use `shift_geometry()` for any national maps including Alaska/Hawaii

---

## Chapter 6: Mapping Census Data
**Main Theme:** Creating professional static and interactive maps with census data

**Choropleth Mapping Best Practices:**
- **Use normalized data**: Rates, percentages, values normalized for population (never raw counts)
- **Choose appropriate classification**: Based on data distribution and analysis goals
- **Show uncertainty**: Use `legend.hist = TRUE` to show data distribution
- **Muted basemaps**: Monochrome/muted styles to avoid color conflicts
- **Transparency**: Use `alpha` parameter (0.5-0.7) when overlaying on basemaps

**Classification Methods:**
```r
tm_polygons(col = "percent", style = "jenks", n = 5)
```
- **"pretty"** (default): Clean intervals, may not handle skewed data well
- **"quantile"**: Equal observations per class, good for skewed data
- **"jenks"**: Natural breaks minimizing within-group variance (often best)
- **"equal"**: Equal intervals, simple but often ineffective for skewed data

**Map Types and Use Cases:**
- **Choropleth**: Best for rates, percentages, normalized values
- **Graduated symbols** (`tm_bubbles()`): Count data to avoid area bias
- **Faceted maps** (`tm_facets()`): Compare multiple variables side-by-side
- **Dot-density** (`as_dot_density()`): Population density and diversity within units
- **Bivariate maps**: Two variables simultaneously (estimates + MOE)

**Mapping Package Comparison:**

**ggplot2 + geom_sf():**
- **Strengths**: Familiar syntax, integrates with ggplot2 ecosystem
- **Best for**: Static maps, publication graphics, custom styling
```r
ggplot(data, aes(fill = estimate)) + 
  geom_sf() + scale_fill_viridis_c() + theme_void()
```

**tmap:**
- **Strengths**: Designed for thematic mapping, static/interactive conversion
- **Best for**: Professional cartographic output, complex layouts
```r
tm_shape(data) + tm_polygons(col = "variable", style = "jenks", 
                            palette = "viridis") + tm_layout()
```

**leaflet:**
- **Strengths**: Full control over interactive features
- **Best for**: Web-based interactive maps, dashboards
```r
leaflet(data) %>% addProviderTiles() %>% 
  addPolygons(fillColor = ~pal(estimate))
```

**Interactive Mapping Approaches:**

**Simple: mapview**
```r
mapview(data, zcol = "estimate")
```

**Flexible: tmap interactive mode**
```r
tmap_mode("view")  # All subsequent tmap maps become interactive
```

**Advanced: leaflet**
```r
pal <- colorNumeric("viridis", domain = data$estimate)
leaflet(data) %>%
  addProviderTiles(providers$Stamen.TonerLite) %>%
  addPolygons(fillColor = ~pal(estimate), fillOpacity = 0.7) %>%
  addLegend(pal = pal, values = ~estimate)
```

**Color Schemes and Legends:**
- **Sequential palettes**: Low to high data (e.g., "Purples", "viridis")
- **Diverging palettes**: Data with meaningful midpoint (e.g., "RdBu")
- **Qualitative palettes**: Categorical data (e.g., "Set1")
- **ColorBrewer integration**: Built into ggplot2 and tmap
- **Test palettes**: Use `tmaptools::palette_explorer()`

**Small Multiples/Faceted Maps:**
```r
tm_shape(data) + 
  tm_facets(by = "variable", scale.factor = 4) + 
  tm_fill(col = "percent")  # tm_fill cleaner than tm_polygons for small multiples
```
- Use consistent classification and colors across facets
- Adjust `scale.factor` for relative sizes
- Position legends strategically

**Professional Map Layout Elements:**
```r
tm_shape(data) + tm_polygons() +
  tm_scale_bar(position = c("left", "bottom")) +
  tm_compass(position = c("right", "top")) +
  tm_credits("(c) Mapbox, OSM", position = c("RIGHT", "BOTTOM")) +
  tm_layout(frame = FALSE, legend.outside = TRUE, 
            bg.color = "white", fontfamily = "Arial")
```

**Dot-Density Mapping:**
```r
dots <- as_dot_density(data, value = "population", 
                       values_per_dot = 100, group = "race",
                       erase_water = TRUE)
tm_shape(dots) + tm_dots(col = "race", size = 0.01)
```

**Critical Mapping Pitfalls to Avoid:**
- **Raw counts in choropleths**: Always normalize by population/area
- **Web Mercator distortion**: Use `shift_geometry()` for US national maps
- **Inappropriate classification**: Choose methods based on data distribution
- **Overplotting in dot maps**: Adjust `values_per_dot` and dot size
- **Water areas in dot maps**: Use `erase_water = TRUE`
- **Unclear legends**: Always specify units and data sources

**Professional tmap Template:**
```r
tm_shape(basemap_tiles) + tm_rgb() + 
  tm_shape(data) + 
  tm_polygons(col = "variable", style = "jenks", palette = "viridis", 
              alpha = 0.7, title = "Variable Title") +
  tm_scale_bar(position = c("left", "bottom")) + 
  tm_compass(position = c("right", "top")) + 
  tm_credits("Data source", position = c("RIGHT", "BOTTOM")) +
  tm_layout(title = "Map Title", title.position = c("center", "top"),
            legend.outside = TRUE, frame = FALSE)
```

**Gotchas/Important Notes:**
- Choose appropriate classification method for data distribution
- Consider normalized vs. raw count data (always normalize for choropleths)
- Use `geometry = TRUE` in tidycensus for spatial data
- Be mindful of the modifiable areal unit problem (MAUP)
- Test color schemes for accessibility (colorblind-friendly)
- Include proper attribution and data sources

---

## Chapter 7: Spatial Analysis with Census Data
**Main Theme:** Performing quantitative spatial analysis operations on census data

**Spatial Predicates and Relationships:**
- `st_intersects()` - Features that share any spatial overlap
- `st_within()` - Features completely contained within another
- `st_touches()` - Features that share boundaries but don't overlap
- `st_overlaps()` - Features that partially overlap
- **Critical**: These functions return specific results with distinct meanings

**Key Functions Introduced:**
- `st_join()` - Spatial joins between different geographic datasets
- `st_buffer()` - Create buffer zones around features
- `st_distance()` - Calculate distances between spatial features
- `spdep::moran.test()` - Test for spatial autocorrelation
- `spdep::nb2listw()` - Create spatial weights matrices

**Spatial Joins:**
```r
# Example: Join demographics to service areas
service_demographics <- st_join(census_tracts, service_boundaries)

# Find tracts within metro areas
metro_tracts <- st_join(tracts, metro_areas, join = st_within)
```
**Use cases**: Cross-geographic analysis, combining different boundary datasets

**Buffer Analysis:**
```r
# Create service area buffers
service_buffers <- st_buffer(service_locations, dist = 5000)  # 5km buffers

# Find population within buffers
population_served <- st_join(census_data, service_buffers)
```
**Applications**: Accessibility analysis, catchment area demographics, proximity studies

**Distance Calculations:**
```r
# Distance matrix between features
distances <- st_distance(from_features, to_features)

# Nearest neighbor analysis
nearest_services <- st_nearest_feature(census_tracts, service_locations)
```
**Critical**: Must use projected CRS for accurate distance calculations

**Spatial Autocorrelation:**
```r
# Create spatial weights matrix
neighbors <- poly2nb(spatial_data)  # Contiguity-based neighbors
weights <- nb2listw(neighbors, style = "W")  # Row-standardized weights

# Test for spatial clustering
moran_result <- moran.test(demographic_variable, weights)
```
**Concepts**: Spatial clustering, hot spots/cold spots, spatial dependence

**Coordinate Reference System Requirements:**
- **Always align CRS before operations**: `st_transform()` to match projections
- **Use projected CRS for distance**: Geographic CRS gives incorrect distances
- **Check CRS**: `st_crs(data)` before spatial operations
- **Buffer distances**: Understand units (meters, feet, etc.)

**Common Spatial Analysis Workflows:**

**1. Point-in-Polygon Analysis:**
```r
# Find census tracts containing specific points
points_in_tracts <- st_join(points, census_tracts, join = st_within)
```

**2. Accessibility Analysis:**
```r
# Create buffers around transit stops
transit_buffers <- st_buffer(transit_stops, dist = 800)  # 800m walking distance

# Find population within walking distance of transit
accessible_pop <- st_join(census_tracts, transit_buffers) %>%
  summarise(total_accessible = sum(population, na.rm = TRUE))
```

**3. Catchment Area Demographics:**
```r
# School catchment area analysis
school_buffer <- st_buffer(schools, dist = 1600)  # 1 mile radius
school_demographics <- st_join(census_tracts, school_buffer) %>%
  group_by(school_id) %>%
  summarise(
    total_pop = sum(total_population),
    median_income = weighted.mean(median_income, total_population),
    pct_poverty = weighted.mean(poverty_rate, total_population)
  )
```

**4. Spatial Clustering Analysis:**
```r
# Test for spatial autocorrelation in income
income_weights <- poly2nb(counties) %>% nb2listw(style = "W")
income_moran <- moran.test(counties$median_income, income_weights)

# Local indicators of spatial association (LISA)
income_lisa <- localmoran(counties$median_income, income_weights)
```

**Spatial Weights Matrices:**
- **Contiguity-based**: `poly2nb()` for adjacent features
- **Distance-based**: `dnearneigh()` for features within distance threshold
- **K-nearest neighbors**: `knn2nb()` for k closest features
- **Row standardization**: `style = "W"` for comparative analysis

**Integration with Census Data:**
```r
# Demographic analysis within buffers
hospital_access <- census_tracts %>%
  st_join(st_buffer(hospitals, dist = 5000)) %>%
  filter(!is.na(hospital_id)) %>%
  summarise(
    accessible_population = sum(total_population),
    avg_poverty_rate = weighted.mean(poverty_rate, total_population),
    pct_elderly = weighted.mean(pct_over_65, total_population)
  )
```

**Performance Optimization:**
- Use `st_make_valid()` to fix invalid geometries before operations
- Consider `st_simplify()` for large datasets where precision isn't critical
- Cache spatial operations results as .rds files
- Use appropriate spatial indexes for large datasets

**Policy Applications:**
- **Service accessibility**: "What percentage of population lives within X distance of services?"
- **Spatial equity**: "Are poverty rates spatially clustered?"
- **Catchment analysis**: "What are demographics of school attendance zones?"
- **Resource allocation**: "Which areas are underserved by current facilities?"

**Critical Gotchas/Important Notes:**
- Always align CRS before spatial operations (most common error source)
- Use projected CRS for distance calculations, geographic CRS for visualization
- Consider edge effects in spatial analysis (boundary effects)
- Spatial predicates have specific meanings: `st_within()` ≠ `st_intersects()`
- Distance units depend on CRS (meters, feet, degrees)
- Edge cases: Features crossing boundaries, islands, complex geometries
- Computational intensity: Spatial operations can be memory/time intensive

**Essential Workflow Pattern:**
```r
# 1. Ensure consistent CRS
data1 <- st_transform(data1, crs = 3857)  # Web Mercator for analysis
data2 <- st_transform(data2, crs = 3857)

# 2. Perform spatial operation
result <- st_join(data1, data2, join = st_intersects)

# 3. Validate results
cat("Original features:", nrow(data1), "\n")
cat("Joined features:", nrow(result), "\n")
cat("Success rate:", round(sum(!is.na(result$joined_var)) / nrow(result) * 100, 1), "%\n")
```

These spatial analysis tools transform census mapping from visualization into quantitative geographic analysis, enabling questions about proximity, accessibility, spatial clustering, and geographic equity that are essential for evidence-based policy making.

---

## Chapter 8: Modeling Census Data
**Main Theme:** Statistical modeling and machine learning with census data

**Key Functions Introduced:**
- `dissimilarity()` - Segregation indices
- `entropy()` - Diversity measures
- `lm()` and `glm()` - Regression modeling
- `spatialreg::lagsarlm()` - Spatial regression
- `kmeans()` - Clustering
- `skater()` - Regionalization

**Important Concepts:**
- Segregation and diversity indices
- Spatial regression models
- Geodemographic classification
- Regionalization with spatial constraints

**Practical Examples:**
- Calculating dissimilarity index by race
- Building regression models with census predictors
- Creating neighborhood typologies
- Designing sales territories

**Gotchas/Important Notes:**
- Check for spatial autocorrelation before standard regression
- Use appropriate segregation index for research question
- Consider multiple variables for geodemographic classification
- Validate clustering solutions

---

## Chapter 9: Introduction to Census Microdata
**Main Theme:** Working with individual-level PUMS data

**Key Functions Introduced:**
- `get_pums()` - Download PUMS data
- `pums_variables` - Browse PUMS variables

**Important Concepts:**
- Microdata vs. aggregate data
- Person vs. household weights (PWGTP, WGTP)
- Public Use Microdata Areas (PUMAs)
- Sample representation

**Practical Examples:**
- Basic PUMS data retrieval
- Understanding weight variables
- Filtering PUMS data
- Working with recoded variables

**Gotchas/Important Notes:**
- PUMS is a smaller sample than full ACS
- Must use weights for accurate estimates
- Geography limited to PUMAs (100k+ population)
- Variables differ from aggregate ACS

---

## Chapter 10: Analyzing Census Microdata
**Main Theme:** Advanced analysis and modeling with PUMS data

**Key Functions Introduced:**
- `to_survey()` - Convert to survey object
- `survey_count()` - Weighted tabulation
- `survey_mean()` - Calculate weighted statistics
- `svyglm()` - Survey-weighted regression

**Important Concepts:**
- Replicate weights for standard errors
- Survey design objects
- Subpopulation analysis
- Complex survey modeling

**Practical Examples:**
- Cross-tabulations with proper weighting
- Calculating standard errors
- Geographic analysis at PUMA level
- Logistic regression with survey weights

**Gotchas/Important Notes:**
- Use `rep_weights = TRUE` for standard errors
- Filter after creating survey object for subpopulations
- Estimates won't match published ACS exactly
- Check for adequate sample size in subgroups

---

## Chapter 11: Other Census and Government Data Resources
**Main Theme:** Accessing historical census data and other government datasets

**Key Functions Introduced:**
- `ipumsr::read_nhgis()` - Read NHGIS data
- `censusapi::getCensus()` - Access any Census API
- `lehdr::grab_lodes()` - Get LODES employment data
- `blscrapeR` functions - Bureau of Labor Statistics data

**Important Concepts:**
- NHGIS for historical census data (1790-present)
- IPUMS for harmonized microdata
- LEHD for employment and commuting
- Integration with other government APIs

**Practical Examples:**
- Mapping historical census data
- Analyzing commuting patterns
- Combining census with economic data
- Long-term demographic trends

**Gotchas/Important Notes:**
- NHGIS requires registration and manual download
- Historical boundaries differ from modern ones
- Variable definitions change over time
- Some datasets require special access

---

## Quick Reference: Essential Workflow

### Basic Setup
```r
library(tidycensus)
library(tidyverse)
library(sf)
census_api_key("YOUR_KEY", install = TRUE)
options(tigris_use_cache = TRUE)
```

### Common Patterns
1. **Get data with geometry:** `get_acs(..., geometry = TRUE)`
2. **Calculate derived estimates:** Account for MOE with `moe_sum()`, `moe_prop()`
3. **Spatial analysis:** Transform to projected CRS before operations
4. **Mapping:** Use `tmap` or `ggplot2` with `geom_sf()`
5. **PUMS analysis:** Always use weights; use survey methods for inference

### Key Considerations
- Variable availability changes by year and geography
- Always specify year explicitly
- Use cartographic boundaries (`cb = TRUE`) for mapping
- Account for margins of error in all calculations
- Check CRS alignment for spatial operations
- Use appropriate weights for PUMS data