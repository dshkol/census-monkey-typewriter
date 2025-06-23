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

**Important Concepts:**
- Visualizing uncertainty with error bars
- Population pyramids
- Faceted visualizations for comparisons
- Interactive plots with plotly

**Practical Examples:**
- Age-sex pyramids
- Time series with confidence bands
- Comparative bar charts with MOE
- Dot plots for rankings

**Gotchas/Important Notes:**
- Always show margins of error when relevant
- Consider using log scales for skewed data
- Use colorblind-friendly palettes (viridis)

---

## Chapter 5: Census Geographic Data and Mapping Foundations
**Main Theme:** Working with Census geographic boundaries using tigris package

**Key Functions Introduced:**
- `states()`, `counties()`, `tracts()`, `block_groups()` - Get boundaries
- `st_transform()` - Project spatial data
- `shift_geometry()` - Inset Alaska/Hawaii
- `erase_water()` - Remove water areas

**Important Concepts:**
- Simple features (sf) data structure
- Coordinate reference systems (CRS)
- TIGER/Line shapefiles
- Cartographic boundaries vs. TIGER boundaries

**Practical Examples:**
- Downloading and plotting state boundaries
- Creating national maps with insets
- Handling water features in coastal areas

**Gotchas/Important Notes:**
- Use `cb = TRUE` for cartographic boundaries (simplified)
- Always check/set CRS before spatial operations
- Cache downloads with `options(tigris_use_cache = TRUE)`

---

## Chapter 6: Mapping Census Data
**Main Theme:** Creating static and interactive maps with census data

**Key Functions Introduced:**
- `tm_shape()` and `tm_polygons()` - tmap basics
- `tm_facets()` - Small multiple maps
- `mapview()` - Quick interactive maps
- `leaflet()` - Advanced interactive maps

**Important Concepts:**
- Choropleth mapping principles
- Classification methods (jenks, quantile, etc.)
- Bivariate mapping
- Interactive map features

**Practical Examples:**
- County-level poverty maps
- Graduated symbol maps
- Dot-density maps
- Time series animations

**Gotchas/Important Notes:**
- Choose appropriate classification method for data distribution
- Consider normalized vs. raw count data
- Use `geometry = TRUE` in tidycensus for spatial data
- Be mindful of the modifiable areal unit problem (MAUP)

---

## Chapter 7: Spatial Analysis with Census Data
**Main Theme:** Performing spatial analysis operations on census data

**Key Functions Introduced:**
- `st_join()` - Spatial joins
- `st_buffer()` - Create buffers
- `st_intersects()`, `st_within()` - Spatial predicates
- `st_distance()` - Calculate distances
- `spdep::moran.test()` - Spatial autocorrelation

**Important Concepts:**
- Spatial overlay operations
- Point-in-polygon analysis
- Distance-based analysis
- Spatial weights matrices
- Catchment areas and accessibility

**Practical Examples:**
- Finding tracts within metro areas
- Creating service area buffers
- Analyzing spatial clustering
- Measuring accessibility to services

**Gotchas/Important Notes:**
- Always align CRS before spatial operations
- Use projected CRS for distance calculations
- Consider edge effects in spatial analysis
- Spatial predicates have specific meanings (within vs. intersects)

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