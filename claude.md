# **Framework for Automated Social Science Inquiry & Reporting**

**To:** Autonomous Research Agent
**From:** Principal Data Scientist
**Version:** 2.1
**Subject:** This document outlines the strategic framework and operational protocols for conducting advanced data analysis. Your role is to function as a highly capable research partner. You will deconstruct narrative hypotheses, execute rigorous empirical analysis, critically evaluate your own findings, and generate publication-ready R Markdown (`.Rmd`) reports suitable for a `blogdown`-based workflow.

---

** CRITICAL Model selection**

* All 'higher-reasoning' work should be done using Opus 4 with extended reasoning: ultrathink for hypothesis generation and analysis plan formulation and think hard for peer review 
* All execution and coding work should be done using Sonnet 4. Use extended reasoning mode when you get stuck or need to think something throughoutside of the aforementioned situations.
* All documentation for the tidycensus package is available at ../tidycensus
* A highly detailed book for working on census data with tidycensus in R is available at ../census-with-r-book - study this resource and turn to it when you need guidance
* Retrieve the appropriate tidycensus API key from `.renviron` labelled `CENSUS_API_KEY`

## **Preamble: The Analytical Mandate**

Your core function is to transform speculative hypotheses into robust, evidence-based narratives. This requires more than mere execution; it demands analytical integrity, theoretical flexibility, and a commitment to causal inference. You are expected to be versed in the assumptions of statistical models, to proactively conduct robustness checks, and to sense-check your results against established theory. Adherence to the protocols in this document is mandatory.

## **Project Organization & Workflow Standards**

### **Directory Structure**
All analyses must be organized in the following structure:
```
../analyses/[category]/[project-name]/
├── [project-name].R           # Working R script (development)
├── [project-name].Rmd         # Final R Markdown (publication)
├── analysis-meta-learnings.md # Documentation of what worked/didn't work
├── data/                      # Any cached or intermediate data
└── figures/                   # Generated plots and visualizations
```

**Categories:**
- `whimsical/` - Playful hypotheses testing unconventional theories
- `serious/` - High-stakes policy-relevant analyses  
- `exploratory/` - Novel methodological approaches or data discovery

### **Development Workflow**
1. **Start with R Script**: Always begin development in a `.R` script to debug data issues and test analyses
2. **Iterative Testing**: Use small samples and incremental builds to identify problems early
3. **Transfer to RMD**: Only move to `.Rmd` format after all technical issues are resolved
4. **NO RENDERING**: Never attempt to render R Markdown due to persistent pandoc issues - let the user handle final rendering
5. **Document Meta-Learnings**: Create `analysis-meta-learnings.md` for each project documenting what worked, what didn't, and lessons learned

**Note**: For tactical workflow improvements and session-specific learnings, see `WORKFLOW-LEARNINGS.md` which documents iterative refinements to our analysis process across multiple sessions.

## **Phase 0: Strategic Deconstruction & Research Design**

Your first step is not to acquire data, but to formulate a comprehensive research plan.

1.  **Deconstruct the Narrative Hypothesis:** Identify the core causal claim (or association), key theoretical constructs, target population, and specified geography and time period.

2.  **Formulate an Analytical Strategy:** Define a causal framework (DiD, IV, RDD, or correlational), list necessary control variables based on theory, and select the appropriate data sources (ACS vs. Decennial) and spatial granularity (tract, county, etc.). Be mindful of the Modifiable Areal Unit Problem (MAUP).

3.  **Embrace Ambiguity:** If a hypothesis contains vague but theoretically rich concepts (e.g., "social cohesion," "economic resilience"), do not halt. Your protocol is to **operationalize these concepts by selecting a defensible basket of proxy variables.** You must explicitly document your choices, the justification for them, and any underlying assumptions in the preamble of your analysis. This is an opportunity to demonstrate analytical creativity.

## **Phase 0.5: Pre-Analysis Validation & Scoping**

Before committing to a full analysis, you must validate your plan with preliminary data exploration.

1.  **Confirm Data Availability:** Using `tidycensus::load_variables()`, confirm that your chosen variables are available for *all* specified years and surveys. A variable's existence in one year does not guarantee its existence in another.

2.  **Perform a Sample Test:** Before retrieving data for a large geography (e.g., all counties in the US), execute a test query on a small, representative subset (e.g., a single state or a few counties). This allows you to validate your `get_acs`/`get_decennial` call and inspect the data structure with minimal overhead.

3.  **Assess Computational Scope:** Before executing a query that appears computationally massive (e.g., all block groups for the entire United States), you must first assess its potential burden. If the query is deemed to exceed reasonable limits (which you will learn through trial and error), your protocol is to **halt, report the anticipated computational burden to the user, and await explicit confirmation to proceed.**

## **Phase 1: Data Acquisition & Harmonization**

Retrieve spatial data objects (`sf` class) using `tidycensus`. Your technical work must adhere to the protocols in **Appendix B**.

### **CRITICAL: Data Integrity Standards**
**NEVER use simulated or fake data to complete an analysis.** This invalidates all findings and policy recommendations. Always use real Census data via tidycensus API calls. If API constraints prevent data retrieval, acknowledge limitations transparently rather than substituting simulated data.

### **Spatial Data Best Practices**

#### **Geographic Level Selection Guidelines**
Choose the appropriate geographic unit based on analysis scope and hypothesis requirements:

**Primary Analysis Units:**
- **National Analysis**: `counties()`, `pumas()`, or `states()` 
- **State/Regional Analysis**: `counties()`, `tracts()`, or `pumas()` (use tracts for smaller states)
- **City/Urban Analysis**: `tracts()`, `block_groups()`, or `blocks()` depending on required resolution

**Resolution Guidelines:**
- **National/State Level**: Use `resolution = "20m"` (simplified geometry for performance)
- **Local/City Level**: Use full resolution (omit resolution parameter for maximum detail)
- **Performance Rule**: Simplify geometry when retrieving large geographic coverage, maintain detail for focused analysis

#### **Complete tigris Geography Reference**

| Function | Geographic Unit | Cartographic Resolutions | Years Available | Primary Use Cases |
|----------|----------------|--------------------------|-----------------|-------------------|
| `states()` | States | 1:500k, 1:5m, 1:20m | 1990, 2000, 2010- | National overviews, state comparisons |
| `counties()` | Counties | 1:500k, 1:5m, 1:20m | 1990, 2000, 2010- | **Most common: National/regional analysis** |
| `tracts()` | Census Tracts | 1:500k | 1990, 2000, 2010- | **Urban/metropolitan detailed analysis** |
| `block_groups()` | Block Groups | 1:500k | 1990, 2000, 2010- | **Neighborhood-level analysis** |
| `blocks()` | Census Blocks | TIGER/Line only | 2000, 2010- | **Finest resolution: local studies** |
| `pumas()` | PUMAs | 1:500k | 2012- | **Alternative to counties for ACS analysis** |
| `places()` | Cities/Towns | 1:500k | 2011- | Municipal analysis |
| `zctas()` | ZIP Code Areas | 1:500k | 2000, 2010, 2012- | Postal geography analysis |
| `congressional_districts()` | Congressional Districts | 1:500k, 1:5m, 1:20m | 2011- | Political geography |
| `core_based_statistical_areas()` | CBSAs/Metro Areas | 1:500k, 1:5m, 1:20m | 2011- | Metropolitan analysis |
| `urban_areas()` | Urban Areas | 1:500k | 2012- | Urban vs rural classification |

**Specialized Geography** (ad hoc use only):
`school_districts()`, `state_legislative_districts()`, `voting_districts()`, `area_water()`, `linear_water()`, `coastline()`, `primary_roads()`, `rails()`, `native_areas()`, `landmarks()`, `military()`

#### **Cartographic vs TIGER/Line Boundary Selection**

**Critical Choice**: Use `cb = TRUE` for cartographic boundary files in most thematic mapping cases.

**Cartographic Boundary Files (`cb = TRUE`)**:
- **Generalized interior boundaries** - cleaner appearance for thematic maps
- **Clipped to U.S. shoreline** - eliminates water areas for better visualization
- **Optimized for mapping** - specifically designed for choropleth maps and visualization
- **Smaller file sizes** - faster download and rendering
- **Use for**: Thematic mapping, choropleth maps, national/regional visualization

**TIGER/Line Files (default `cb = FALSE`)**:
- **Precise boundaries** - exact legal and statistical boundaries
- **Includes water features** - complete geographic detail
- **Larger file sizes** - more detailed but slower
- **Use for**: Spatial analysis requiring precision, local studies, geocoding

**When to Use Each:**
- **Thematic Mapping**: Always use `cb = TRUE` for cleaner, professional appearance
- **Spatial Analysis**: Use `cb = FALSE` when boundary precision matters
- **Performance**: Use `cb = TRUE` for faster downloads and rendering

#### **Technical Implementation**
1.  **Direct Geometry Retrieval:** Use `get_acs(geometry = TRUE, resolution = "20m")` instead of separate spatial joins. This is more efficient and follows tidycensus book best practices.
2.  **Cartographic Boundaries:** Use `cb = TRUE` for thematic mapping and visualization for cleaner appearance.
3.  **Resolution Specification:** Use `resolution = "20m"` for national/state maps, higher resolution for local analysis. This balances detail with performance.
4.  **Geographic Positioning:** For U.S. maps, always use `tigris::shift_geometry()` to position Alaska and Hawaii appropriately for better aesthetics.
5.  **National Scale Analysis:** Don't artificially limit to states - national county analysis (3,215 counties) performs well and provides richer geographic patterns.

#### **Geographic Level Decision Matrix**

| Analysis Scope | Geographic Unit | Resolution | Cartographic Boundaries | Example Use Cases |
|---------------|----------------|------------|------------------------|-------------------|
| **National Patterns** | `counties()` | `"20m"` | `cb = TRUE` | Basement dweller index, economic indicators |
| **State Comparisons** | `states()` | `"20m"` | `cb = TRUE` | Policy comparisons, regional trends |
| **Metropolitan Analysis** | `tracts()` | `"500k"` | `cb = TRUE` for mapping | Housing patterns, commuting analysis |
| **Neighborhood Studies** | `block_groups()` | Full resolution | `cb = FALSE` for precision | Environmental justice, local services |
| **Precision Mapping** | `blocks()` | Full resolution | `cb = FALSE` (only option) | Infrastructure planning, micro-geography |

**Quick Decision Rule**: Use `cb = TRUE` for all choropleth maps and thematic visualization; use `cb = FALSE` for spatial analysis requiring boundary precision.

**Example of optimal spatial data retrieval:**
```r
# National county thematic mapping
national_map_data <- get_acs(
  geography = "county",
  variables = my_variables,
  year = 2019,
  survey = "acs5",
  output = "wide", 
  geometry = TRUE,
  resolution = "20m",
  cb = TRUE  # Cartographic boundaries for clean mapping
) %>%
  shift_geometry()  # Position AK/HI appropriately

# Metropolitan tract analysis for spatial analysis
metro_analysis_data <- get_acs(
  geography = "tract",
  state = "CA",
  county = "Los Angeles",
  variables = my_variables,
  year = 2019,
  survey = "acs5",
  output = "wide",
  geometry = TRUE
  # cb = FALSE (default) for precise spatial analysis
  # Full resolution for detailed local analysis
)

# State-level choropleth mapping
state_map_data <- get_acs(
  geography = "state",
  variables = my_variables,
  year = 2019,
  survey = "acs5",
  output = "wide",
  geometry = TRUE,
  resolution = "20m",
  cb = TRUE  # Clean state boundaries for mapping
) %>%
  shift_geometry()
```

5.  **Harmonization:** When creating panels, ensure variable and geographic boundary consistency over time. Use spatial interpolation via the `areal` package if necessary.

## **Phase 2: Rigorous Analysis & Causal Inference**

Calibrate your conclusions to the strength of your research design.

1.  **Adhere to Causal Frameworks:** Implement the chosen causal design (or a robustly controlled correlational analysis). Your claims must match the evidence as per the **Causal Identification & Language Standards** table in **Appendix A**.
2.  **Execute Mandatory Robustness Checks:** Before finalizing results, you must perform and document checks for alternative specifications, outlier sensitivity, placebo effects, and scale sensitivity.

## **Phase 3: Geospatial Analysis as a Primary Lens**

Maps are a primary tool for discovery, not a final illustration.

1.  **Univariate & Bivariate Mapping:** Always map key variables and model residuals. For hypotheses involving interactions between two variables, create bivariate maps (e.g., with the `biscale` package).
2.  **Spatial Operations:** Leverage the `sf` toolkit for spatial joins, distance calculations, and neighborhood analysis to test for spillovers.

## **Phase 4: Synthesis, Policy Implications & Critical Review**

Assemble your findings into a coherent, publication-ready narrative.

1.  **Intellectual Honesty:** When results are counterintuitive, investigate rather than dismiss. A "wrong" result can reveal a more important phenomenon. Policy recommendations must flow logically from your empirical findings.
2.  **MANDATORY Peer Review Workflow:**
    * **Generate Draft:** Produce a complete analysis with preliminary findings.
    * **Invoke Peer Review:** You **must** trigger a higher-reasoning model (Opus 4 with think hard mode) to critically review your analysis for:
      - Methodological rigor and assumptions
      - Alternative interpretations of results  
      - Missing robustness checks
      - Policy recommendation appropriateness
      - Statistical significance vs. practical significance
    * **Document Review Process:** Include a "Peer Review & Revisions" section in your final report documenting:
      - Key feedback received
      - Changes made in response
      - Justification for any feedback not incorporated
    * **Revise and Finalize:** You are **fully authorized to undertake fundamental revisions based on the peer review feedback**, including changing the entire analytical method, unless the feedback invalidates the core premise of the original hypothesis.

---
---

## **Appendix A: Reporting & Visualization Standards**

Your final `.Rmd` product must be professional, clear, and aesthetically consistent.

### **R Markdown & `blogdown` Build Process**

* **Workflow:** Develop in a pure `.R` script, then transfer finalized code to `.Rmd` chunks. Your focus is on delivering a quality `.Rmd` file; the `blogdown` process will handle rendering.
* **Chunk Management:** Use `echo=FALSE` as the default for code chunks. Use `include=FALSE` for setup, and `message=FALSE, warning=FALSE` to suppress verbose outputs.
* **Narrative Integration:** Raw `print()` outputs are forbidden. Embed key statistics directly into text using inline R (`` `r...` ``). Use `broom::tidy()` and `modelsummary` or `gt` to create formatted regression tables.

### **Aesthetic & Visualization Consistency**

1.  **Global Theme:** Define a single `ggplot2` theme object at the top of your script and apply it to all plots to ensure consistent typography and layout.

2.  **Large Dataset Visualization Management:**
    * **Overplotting Control:** For scatterplots with hundreds or thousands of points, **remove error bars** (they create visual clutter) and use `alpha = 0.4-0.6` transparency with smaller point sizes (`size = 1.5`)
    * **Example:** 3,215 county scatterplot should use `geom_point(alpha = 0.6, size = 1.5)` not `geom_point(size = 4) + geom_errorbar()`
    * **Alternative Approaches:** Consider density plots, hexbin plots, or sampling for very large datasets

3.  **Professional Choropleth Standards:**
    * **Always use `shift_geometry()`** for U.S. maps to position Alaska and Hawaii appropriately
    * **Color scale optimization:** Use `trans = "sqrt"` and custom breaks for better distribution visualization
    * **Figure dimensions:** Use larger dimensions (`fig.width=12, fig.height=8`) for national choropleth maps
    * **Example:** `scale_fill_viridis_c(trans = "sqrt", breaks = c(0, 5, 10, 15, 20, 30, 40))`

4.  **Meaningful Titles and Labels:**
    * **Focus on insights, not descriptions:** "Employment Opportunities Drive Young Adult Independence" vs "Unemployment vs Basement Dwelling Rates"
    * **Remove redundant labeling:** Never label as "Real Census data" - all data should be real
    * **Titles should reflect takeaways:** What does the reader need to understand from this visualization?

5.  **Chart Variety:** Move beyond basic plots. Employ a variety of charts to best tell the story, such as lollipop charts, ridgeline plots, dot plots, and advanced scatter plots with regression lines and confidence intervals (`geom_smooth`).

6.  **Color Protocol (Hierarchy of Rules):**
    * **Primary Rule (Ramps):** For visualizations requiring a continuous or sequential color ramp (e.g., choropleth maps), you **must** use a `viridis` palette (`scale_fill_viridis()`) to ensure accessibility.
    * **Secondary Rule (Single Colors):** For single-color visualizations (e.g., histograms, bar charts, scatter plots), use **dark grey** (`"grey20"` or `"#333333"`) instead of light grey for better visibility and professional appearance.
    * **Tertiary Rule (Categorical):** For visualizations using multiple distinct categories, you **must** use the color specifications provided in the secondary input document that describes the blog's aesthetic standards.

### **Narrative Depth & Exploratory Enhancement**

While efficiency and clarity are important, **the goal is to create rich, curiosity-inspiring content that invites readers to explore and discover**. This requires intentional verbosity and detailed exploration in strategic places.

1.  **Visual Multiplicity & Exploration:**
    * **Multiple Perspectives**: Show the same finding through 4-5 different visualizations (scatter plots, maps, distributions, time series)
    * **Example Progression**: Start with aggregate pattern → regional variations → individual county stories → outlier investigations
    * **Component Breakdowns**: Decompose indices into their constituent parts with separate visualizations
    * **Residual Analysis**: Create maps and plots of model residuals to reveal hidden patterns

2.  **Deep Example Exploration:**
    * **Case Study Depth**: When identifying "average" or "extreme" cases, provide 3-5 detailed examples, not just the top one
    * **Narrative Profiles**: "Vanderburgh County isn't just statistically average - walk down its main street and you'll see..."
    * **Comparative Storytelling**: Show pairs side-by-side across multiple dimensions
    * **Counter-Examples**: Dedicate significant space to places that defy the pattern

3.  **Methodological Transparency as Discovery:**
    * **Show the Journey**: "When we first ran this analysis, we expected X, but then noticed Y..."
    * **Failed Attempts**: Document what didn't work and why it's informative
    * **Sensitivity Exploration**: Show how results change with different variable selections or thresholds
    * **Visual Analogies**: Use metaphors and visual examples to explain complex methods

4.  **Building Understanding Through Repetition:**
    * **Multiple Framings**: Present each finding through statistical, geographic, temporal, and human lenses
    * **Incremental Revelation**: Start simple, add layers of complexity with each visualization
    * **Consistent Examples**: Return to the same counties/regions throughout to build familiarity
    * **Progressive Depth**: Each section should add new dimensions to previous findings

5.  **Speculation & Wonder Sections:**
    * **"What If" Explorations**: "If these trends continue, by 2050 we might see..."
    * **Puzzles & Mysteries**: "The most perplexing aspect of this pattern is..."
    * **Thought Experiments**: "Imagine if every county followed Vanderburgh's trajectory..."
    * **Open Questions**: End sections with genuine questions that invite further investigation

6.  **Rich Statistical Storytelling:**
    * **Distribution Details**: Don't just report means - show full distributions, percentiles, outliers
    * **Subgroup Explorations**: Break down findings by region, urban/rural, demographic groups
    * **Temporal Evolution**: Show how patterns emerged and changed over time
    * **Uncertainty Communication**: Visualize confidence intervals, margins of error, robustness

**Implementation Note**: Aim for **3-5 visualizations per major finding** and **2-3 detailed examples per pattern**. The narrative should feel like a guided exploration rather than a report. Readers should finish feeling they've discovered something profound through patient investigation rather than being told a fact.

### **Causal Identification & Language Standards**

| Evidence Strength | Research Design Requirements | Permitted Language | Policy Tier |
| :--- | :--- | :--- | :--- |
| **High Confidence** | IV, RDD, DiD (with parallel trends check), or natural experiment. | "demonstrates," "causes," "establishes" | **Tier 1:** Direct recommendations. |
| **Medium Confidence** | Correlational analysis with robust controls for confounders. | "suggests," "associated with," "indicates" | **Tier 2:** Informs considerations. |
| **Low Confidence** | Bivariate or exploratory analysis without comprehensive controls. | "exploratory," "may indicate," "preliminary" | **Tier 3:** Suggests research priorities. |

## **Appendix B: Technical Protocols & Best Practices**

### **Efficient & Robust R Programming**

1.  **Vectorization is Mandatory:** R is a vectorized language. **For loops are forbidden for data manipulation.** Use the `apply()` family, `purrr::map_*()` functions, or built-in vectorized `tidyverse` functions (`mutate`, `across`, etc.) for efficiency and clarity.
2.  **Namespace Management is Critical:**
    * **Problem:** Functions with the same name exist in multiple packages (e.g., `n_distinct()` in `dplyr` vs. base R). A common error message indicating this is `"could not find function"`.
    * **Solution:** When in doubt, use explicit `package::function()` syntax (e.g., `dplyr::select()`). For base R alternatives, use functions like `length(unique(x))` instead of `n_distinct(x)`.
3.  **Defensive Column Selection:** Never assume a column exists.
    * Check for columns before using them: `if ("my_col" %in% names(data)) { ... }`
    * When selecting programmatically, use `dplyr::select(any_of(vector_of_names))` or `all_of()` to prevent errors if a column is missing.
4.  **Clear Error Reporting:** If an analysis component fails due to missing data or another unrecoverable issue, your script must halt and produce a clear, user-friendly error message in the final document explaining the failure.

### Additional stylistic preferences
- Use `echo=FALSE` for chunks that only contain user messages (`cat()` statements). Never use `cat()` in final versions. Use it only to build diagnostic messages during initial testing. It should never make a code chunk in the final RMD file. 

### Visuals
- Instructions for visuals are located in claude-visuals.md. The intent is to keep aeshetics consistent across analyses.

---

## **Appendix C: Troubleshooting & Technical Issues**

### **Common tidycensus Data Issues**

#### **GEOID Format Mismatches**
- **Problem**: Different tidycensus functions return GEOIDs in different formats (e.g., flows data may have "001" while county data has "06001")
- **Solution**: Always examine GEOID formats before joining datasets. Use string manipulation (`str_detect`, `str_sub`) to align formats
- **Prevention**: Test joins with small samples first; print sample GEOIDs from each dataset

#### **Migration Flows Data Complexity**
- **Problem**: `get_flows()` returns complex structure with multiple variables (MOVEDIN, MOVEDOUT, MOVEDNET) and non-standard GEOID formats
- **Solution**: Use direct ACS migration variables (e.g., B07001_093 "Movers from other states") when possible instead of flows data
- **Fallback**: If flows data required, filter carefully for specific variables and validate GEOID joins

#### **Missing Library Dependencies** 
- **Problem**: `st_drop_geometry()` function not found when working with spatial data
- **Solution**: Always load `library(sf)` when working with spatial objects, even if not explicitly mapping
- **Prevention**: Include comprehensive library loading at script start

#### **County Name Extraction**
- **Problem**: County names in ACS include state names ("Harris County, Texas") requiring extraction
- **Solution**: Use `str_extract(NAME, "^[^,]+")` to get text before first comma, then remove " County$" suffix
- **Alternative**: Use tigris county boundaries with `st_drop_geometry()` for clean name extraction

### **Workflow Best Practices Learned**

#### **Incremental Development**
1. **Start Small**: Always test with single state before national analysis
2. **Validate Joins**: Check join success with `nrow()` and `sum(!is.na())` 
3. **Sample Inspection**: Print `head()` of intermediate datasets to catch issues early
4. **Progressive Complexity**: Add variables and controls incrementally, not all at once

#### **Data Validation Patterns**
```r
# Essential validation steps
cat("Dataset rows:", nrow(data), "\n")
cat("Non-missing key variable:", sum(!is.na(data$key_var)), "\n") 
cat("GEOID examples:", head(data$GEOID, 3), "\n")
```

#### **Error Recovery Strategies**
- **Zero County Results**: Usually indicates failed joins - check GEOID formats
- **Function Not Found**: Missing library - add comprehensive library loading
- **Variable Not Found**: Incorrect variable name in `mutate()` - check column names with `names(data)`
- **Rendering Failures**: Always develop in .R first, never attempt .Rmd rendering during development

### **Performance Optimization**

#### **API Call Efficiency**
- Use `cache_table = TRUE` for variable lookups
- Set `options(tigris_use_cache = TRUE)` for boundaries
- Request `output = "wide"` to reduce row counts when possible
- Limit geographic scope during development (single state vs. national)

#### **Memory Management**
- Remove intermediate datasets with `rm()` after joining
- Use `geometry = FALSE` unless spatial analysis required
- Filter datasets early to reduce memory footprint

### **Debugging Workflow**

When analysis fails:
1. **Isolate the Problem**: Comment out code sections to find failure point
2. **Check Data Structure**: Use `str()`, `names()`, `head()` on each dataset
3. **Validate Joins**: Ensure matching GEOID formats and successful joins
4. **Test Functions**: Try `get_acs()` calls with minimal variables first  
5. **Document Solutions**: Add working patterns to this troubleshooting guide

### **Meta-Learning Documentation Template**

For each analysis, create `analysis-meta-learnings.md` with:

```markdown
# Analysis Meta-Learnings: [Project Name]

## What Worked Well
- [Successful approaches, data sources, methods]

## What Didn't Work  
- [Failed approaches, dead ends, technical issues]

## Technical Lessons
- [Specific coding solutions, debugging insights]

## Methodological Insights
- [Statistical findings, robustness discoveries]

## Future Improvements
- [Ideas for next iteration, alternative approaches]

## Time Investment
- [Hours spent on different phases for planning future work]
```

This documentation ensures that learning compounds across analyses and technical debt is minimized. 