## HYPOTHESIS\_TITLE: The “Great Decoupling”: Divergence of Population Growth from Housing Unit Growth in High-Amenity Counties Post-2020 *(BUCKET: Serious)*

**Abstract (≤ 60 words)** Counties with high natural amenities and pre-existing housing shortages experienced a post-2020 decoupling, where population growth (from PEP) significantly outpaced the growth in housing units (from ACS). This divergence is hypothesized to drive disproportionate increases in housing cost burdens and rentership rates, signaling a new form of amenity-driven housing crisis not fully captured by pre-pandemic trends.

**Structured specification**

```json
{
  "novelty_rating":       "medium",
  "feasibility_rating":   "high",
  "complexity_rating":    "medium",
  "whimsy_rating":        "low",
  "geographic_level":     "county",
  "primary_metrics":      ["population change vs. housing unit change", "renter-occupied housing unit share", "median gross rent as % of household income"],
  "proposed_method":      "Difference-in-differences comparing high- vs. low-amenity counties, pre- vs. post-2020",
  "robustness_checks":    ["controlling for pre-existing growth trends", "using metro-level flows as an instrument", "alternative amenity definitions"],
  "expected_runtime":     "1–4 hr",
  "ethical_flags":        []
}
```

**Narrative plan**

1.  **Data sources** – Population Estimates Program (PEP) annual county estimates for population change. American Community Survey (ACS) 1-year estimates for housing unit counts (B25001), housing tenure (B25003), and gross rent as a percentage of household income (B25071). Pre-2020 trends will use 2015-2019 data; post-2020 trends will use 2021-2023 data.
2.  **Methodology** – We will first classify counties by an amenity score (a proxy could be the share of employment in arts, entertainment, and recreation from County Business Patterns, though that's technically outside the scope; a pure-Census proxy would be difficult, so we may have to define "amenity" by population density and proximity to coasts/mountains, a TIGER-based measure). The core analysis uses a diff-in-diff model to compare the change in the housing-population gap in high-amenity counties versus low-amenity counties before and after the pandemic watershed of 2020.
3.  **Why it matters / what could go wrong** – This hypothesis tests whether the "Zoom town" phenomenon created a structural housing crisis distinct from urban affordability issues. If true, it suggests a need for rural and exurban housing policy. A key challenge is defining "amenity" using only Census/TIGER data. The result could be spurious if high-amenity counties were already on a divergent path.

**Key references**
• Moretti, E. (2012). *The New Geography of Jobs*.
• Glaeser, E. L., & Gyourko, J. (2018). *The Economic Implications of Housing Supply*. Journal of Economic Perspectives.

-----

## HYPOTHESIS\_TITLE: The Gray-to-Green Transit Shift: Aging Suburbs and Public Transit Viability *(BUCKET: Serious)*

**Abstract (≤ 60 words)** Census tracts in post-war suburbs (defined by median year structure built) that experienced the largest increase in the 65+ age cohort between 2010 and 2020 also saw a disproportionate increase in public transit usage for commuting. This suggests that aging-in-place in auto-centric areas creates latent demand for transit, potentially making new investments in these areas viable.

**Structured specification**

```json
{
  "novelty_rating":       "medium",
  "feasibility_rating":   "high",
  "complexity_rating":    "medium",
  "whimsy_rating":        "low",
  "geographic_level":     "tract",
  "primary_metrics":      ["% population 65+", "median year structure built", "% of workers using public transportation"],
  "proposed_method":      "Cross-sectional regression with interaction terms for 2020 data, validated with change scores from 2010.",
  "robustness_checks":    ["controlling for tract density", "using ACS 5-year data for stability", "excluding tracts with major new transit lines"],
  "expected_runtime":     "4–12 hr",
  "ethical_flags":        []
}
```

**Narrative plan**

1.  **Data sources** – Decennial Census (2010 & 2020) for age structure (P12) and housing unit age (pulled from ACS, as it's more accessible). American Community Survey (ACS) 5-year estimates (2008-2012 vs 2018-2022) for means of transportation to work (B08301) and median year structure built (B25035).
2.  **Methodology** – First, identify "post-war suburban" tracts using B25035 (e.g., median year built 1950-1980). Calculate the change in the 65+ population share from 2010 to 2020. The primary analysis will regress the change in public transit commute share on the change in the senior population share, interacting this with the "post-war suburb" dummy.
3.  **Why it matters / what could go wrong** – This could provide an evidence base for expanding transit services in aging, low-density suburbs, a notoriously difficult market. The primary challenge is that "journey to work" data misses transit use by retirees for non-work trips (e.g., healthcare, shopping), which is likely the primary driver. The analysis might understate the true effect.

**Key references**
• Fishman, R. (1987). *Bourgeois Utopias: The Rise and Fall of Suburbia*.
• Wachs, M. (1990). *Regulating Traffic by Controlling Land Use: The Southern California Experience*. Transportation.

-----

## HYPOTHESIS\_TITLE: Linguistic Enclaves as "Brain Gain" Magnets for Specific Industries *(BUCKET: Serious)*

**Abstract (≤ 60 words)** PUMAs (Public Use Microdata Areas) with high concentrations of specific non-English language groups (e.g., Chinese, Hindi, Russian) also exhibit a disproportionately high share of foreign-born residents with graduate degrees working in specific high-skill industries (e.g., tech, medicine). This suggests linguistic enclaves function not just as social support systems but as specialized human capital hubs.

**Structured specification**

```json
{
  "novelty_rating":       "high",
  "feasibility_rating":   "medium",
  "complexity_rating":    "high",
  "whimsy_rating":        "low",
  "geographic_level":     "PUMA",
  "primary_metrics":      ["% speaking specific language at home", "Shannon diversity index of languages", "% foreign-born with grad degree by industry"],
  "proposed_method":      "Correlation analysis followed by fixed-effects regression",
  "robustness_checks":    ["controlling for overall metro area industry mix", "using different ACS years", "checking against state-level immigration data"],
  "expected_runtime":     "4–12 hr",
  "ethical_flags":        []
}
```

**Narrative plan**

1.  **Data sources** – American Community Survey (ACS) 5-year PUMA-level data. Key tables include Language Spoken at Home (B16001), Nativity by Educational Attainment (B06009), and Industry by Sex for the Civilian Employed Population (C24030).
2.  **Methodology** – For each PUMA, we will calculate the concentration of specific language groups (e.g., Mandarin/Cantonese, Hindi, Russian, Arabic). We will then calculate the share of the foreign-born population with a graduate or professional degree within specific NAICS industry codes. The analysis will test for a significant positive correlation between the concentration of a language group and the prevalence of high-skilled, foreign-born workers in related industries.
3.  **Why it matters / what could go wrong** – This shifts the narrative around linguistic diversity from one of integration challenges to one of economic specialization and strength. It matters for immigration and economic development policy. The analysis could suffer from ecological fallacy; the people speaking the language may not be the same people with the graduate degrees.

**Key references**
• Saxenian, A. (2006). *The New Argonauts: Regional Advantage in a Global Economy*.
• Hunt, J. (2011). *Which Immigrants Are Most Innovative and Entrepreneurial? Distinctions by Entry Visa*. Journal of Labor Economics.

-----

## HYPOTHESIS\_TITLE: The Childcare "Desert" Expansion and Female Labor Force Participation *(BUCKET: Serious)*

**Abstract (≤ 60 words)** In non-metro counties, a decrease in the availability of childcare facilities (proxied by a declining ratio of young children to workers in the childcare industry) between ACS 2015 and 2022 correlates with a statistically significant decline in labor force participation among women with children under 6, but not for other female or male demographic groups.

**Structured specification**

```json
{
  "novelty_rating":       "medium",
  "feasibility_rating":   "medium",
  "complexity_rating":    "medium",
  "whimsy_rating":        "low",
  "geographic_level":     "county",
  "primary_metrics":      ["ratio of population <5 to childcare workers", "female labor force participation rate (with children <6)"],
  "proposed_method":      "Fixed-effects panel regression across counties over time",
  "robustness_checks":    ["using different ACS time periods", "controlling for local unemployment rates", "comparison to metro counties"],
  "expected_runtime":     "1–4 hr",
  "ethical_flags":        []
}
```

**Narrative plan**

1.  **Data sources** – ACS 1-year estimates (for counties with sufficient population). Key tables: Age and Sex (B01001) to count children under 5. Industry by Sex (C24030) to count workers in "Child day care services" (NAICS 6244). Labor Force Participation by Presence of Own Children (B23008).
2.  **Methodology** – We will create a panel dataset of counties from \~2015 to 2023. For each county-year, we calculate a "childcare availability proxy" (children under 5 per childcare worker). The main regression will model the female labor force participation rate (for mothers of young children) as a function of this proxy, including county and year fixed effects to control for stable unobserved characteristics and national trends.
3.  **Why it matters / what could go wrong** – The hypothesis provides a quantitative link between childcare infrastructure and economic outcomes for women, a critical policy issue. The primary weakness is the proxy variable; the number of "childcare workers" is an imperfect measure of licensed slots or affordability. It could also be endogenous if falling female LFP reduces demand for childcare.

**Key references**
• Blau, F. D., & Kahn, L. M. (2017). *The Gender Wage Gap: Extent, Trends, and Explanations*. Journal of Economic Literature.

-----

## HYPOTHESIS\_TITLE: The Durability of "Middle-Skill" Jobs in Counties with High Vocational Training Enrollment *(BUCKET: Serious)*

**Abstract (≤ 60 words)** Counties with a higher-than-average share of the 18-24 population enrolled in "other" 2-year colleges (proxy for vocational/technical schools) experienced slower declines in manufacturing and construction employment between 2010 and 2020. This suggests that a strong vocational training pipeline provides resilience for "middle-skill" jobs against automation and offshoring pressures.

**Structured specification**

```json
{
  "novelty_rating":       "medium",
  "feasibility_rating":   "medium",
  "complexity_rating":    "medium",
  "whimsy_rating":        "low",
  "geographic_level":     "county",
  "primary_metrics":      ["% of 18-24 pop in 'other' 2-year college", "employment share in manufacturing/construction"],
  "proposed_method":      "First-differenced regression model",
  "robustness_checks":    ["controlling for initial industry mix", "lagging the education variable", "testing against other industries"],
  "expected_runtime":     "1–4 hr",
  "ethical_flags":        []
}
```

**Narrative plan**

1.  **Data sources** – ACS 5-year estimates (2008-2012 and 2018-2022) to ensure county-level coverage. Tables: School Enrollment by Type of School (B14001) to identify enrollment in "College or graduate school: Public, 2-year". Industry by occupation for the civilian employed population (C24040) for employment counts.
2.  **Methodology** – The analysis will use a first-differenced approach. The dependent variable is the change in the employment share of manufacturing and construction in a county between the two ACS 5-year periods. The key independent variable is the enrollment share in 2-year public colleges at the beginning of the period (2008-2012), instrumenting for the local supply of vocationally trained workers.
3.  **Why it matters / what could go wrong** – The findings could support policy arguments for increased investment in community and technical colleges as a pillar of local economic development strategy. A major limitation is that "2-year public college" is a noisy proxy for *vocational* training; it also includes students intending to transfer to 4-year schools.

**Key references**
• Autor, D. H. (2015). *Why Are There Still So Many Jobs? The History and Future of Workplace Automation*. Journal of Economic Perspectives.

-----

## HYPOTHESIS\_TITLE: "Reverse" Brain Drain: High-Cost Metro Out-Migration and the Skill Composition of Destination Counties *(BUCKET: Serious)*

**Abstract (≤ 60 words)** County-to-county migration flows originating from the nation's most expensive metro areas (e.g., San Francisco, New York) are disproportionately composed of individuals with higher educational attainment compared to the baseline population of both the origin and destination counties. This selective migration is actively increasing the human capital stock of lower-cost, often non-metropolitan, destination counties.

**Structured specification**

```json
{
  "novelty_rating":       "medium",
  "feasibility_rating":   "high",
  "complexity_rating":    "medium",
  "whimsy_rating":        "low",
  "geographic_level":     "county",
  "primary_metrics":      ["migration flow counts by educational attainment", "median gross rent", "median home value"],
  "proposed_method":      "Gravity model of migration, stratified by educational attainment",
  "robustness_checks":    ["controlling for distance and population size", "using different years of migration data", "examining age-specific flows"],
  "expected_runtime":     "4–12 hr",
  "ethical_flags":        []
}
```

**Narrative plan**

1.  **Data sources** – ACS Migration Flows (county-to-county files). These files provide counts of movers between county pairs, broken down by characteristics like educational attainment. ACS 1-year estimates for county-level housing costs (B25064, B25077) to identify high-cost origin metros.
2.  **Methodology** – First, identify the top 10 most expensive metro areas based on ACS housing cost data. For all outbound migration flows from counties within these metros, we will analyze the educational attainment profile of the movers. We will compare the share of movers with a Bachelor's degree or higher to the share in (a) the origin county, and (b) the destination county.
3.  **Why it matters / what could go wrong** – This hypothesis quantifies the "brain gain" for regions receiving domestic migrants from superstar cities, a key component of regional convergence/divergence debates. The migration flow data is based on a sample and can have large margins of error for smaller county pairs, requiring aggregation or careful handling of uncertainty.

**Key references**
• Diamond, R. (2016). *The Determinants and Welfare Implications of US Workers’ Diverging Location Choices*. American Economic Review.

-----

## HYPOTHESIS\_TITLE: The Echo of Segregation: Racial Composition and Municipal Broadband Adoption *(BUCKET: Serious)*

**Abstract (≤ 60 words)** In states that do not preempt municipal broadband, census tracts with a higher historical measure of racial residential segregation exhibit a lower likelihood of having high-speed internet access. This suggests that historical patterns of underinvestment and exclusion are replicated in the build-out of modern digital infrastructure, even when controlled by public entities.

**Structured specification**

```json
{
  "novelty_rating":       "high",
  "feasibility_rating":   "medium",
  "complexity_rating":    "high",
  "whimsy_rating":        "low",
  "geographic_level":     "tract",
  "primary_metrics":      ["Dissimilarity Index", "% households with broadband internet access", "internet subscription type"],
  "proposed_method":      "Spatial regression modeling broadband access as a function of segregation",
  "robustness_checks":    ["instrumental variable for state preemption laws", "controlling for poverty and population density", "using different segregation metrics"],
  "expected_runtime":     "4–12 hr",
  "ethical_flags":        []
}
```

**Narrative plan**

1.  **Data sources** – Decennial Census (2010) data on race (P5) to calculate a historical dissimilarity index at the metro level. ACS 5-year estimates (2018-2022) for household broadband access (B28002) at the tract level. (Note: The state law information is an external piece of context, not a dataset to be joined).
2.  **Methodology** – First, for each metropolitan area, calculate a Black-White and Hispanic-White dissimilarity index using 2010 tract-level data. Then, within states that allow municipal broadband, regress the 2018-2022 tract-level broadband subscription rate on this metro-level dissimilarity index, controlling for tract-level median income, population density, and housing unit age.
3.  **Why it matters / what could go wrong** – This tests whether public infrastructure investment can overcome historical patterns of racial inequality, a core question for federal infrastructure spending. The primary challenge is the lack of a direct measure of "municipal broadband service area." The analysis relies on inferring its impact from aggregate subscription data in a permissive legal environment.

**Key references**
• Massey, D. S., & Denton, N. A. (1993). *American Apartheid: Segregation and the Making of the Underclass*.
• Rhinesmith, C. (2021). *Digital Inclusion and Meaningful Broadband Adoption Initiatives*. Benton Institute for Broadband & Society.

-----

## HYPOTHESIS\_TITLE: Solo Boomers: The Rise of Single-Person 65+ Households and Its Impact on Housing Stock *(BUCKET: Serious)*

**Abstract (≤ 60 words)** Between the 2010 and 2020 Decennial Censuses, the fastest-growing household type was single-person households aged 65+. This demographic shift is creating a mismatch, where tracts with the largest growth in "solo boomers" have a housing stock dominated by 3+ bedroom homes, signaling future demand for smaller, more accessible housing units.

**Structured specification**

```json
{
  "novelty_rating":       "medium",
  "feasibility_rating":   "high",
  "complexity_rating":    "low",
  "whimsy_rating":        "low",
  "geographic_level":     "tract",
  "primary_metrics":      ["count of 65+ single-person households", "number of bedrooms in housing units", "units in structure"],
  "proposed_method":      "Descriptive statistics and change analysis, followed by a mismatch index calculation",
  "robustness_checks":    ["corroborating with ACS 5-year data", "controlling for urbanicity", "checking tenure (owner/renter)"],
  "expected_runtime":     "<1 hr",
  "ethical_flags":        []
}
```

**Narrative plan**

1.  **Data sources** – Decennial Census (2010 & 2020) tables on Households and Families (e.g., P18, H4). ACS 5-year data (e.g., 2018-2022) for housing characteristics like number of bedrooms (B25041) and units in structure (B25024).
2.  **Methodology** – Calculate the percentage change in single-person households with a householder aged 65+ for every census tract between 2010 and 2020. Separately, profile the housing stock of each tract using recent ACS data. Create a "mismatch index" by multiplying the growth rate of solo seniors by the percentage of large (3+ bedroom) single-family homes.
3.  **Why it matters / what could go wrong** – This highlights a looming housing challenge: a growing senior population living alone in homes that may be too large or difficult to maintain. This has implications for zoning (allowing subdivisions/ADUs), construction, and social services. The analysis is correlational; it doesn't prove causation but identifies areas of potential stress.

**Key references**
• Myers, D. (2015). *Apartment-Building Boom Shows the Changing Face of the American Renter*. The Conversation.

-----

## HYPOTHESIS\_TITLE: The Entrepreneurial Shift from High- to Low-Tax States *(BUCKET: Serious)*

**Abstract (≤ 60 words)** Migration flows of self-employed individuals ("unincorporated" workers) show a net movement from high-income-tax states to no-income-tax states that exceeds the rate for salaried workers. This effect is strongest for workers in high-earning professional services industries, suggesting that state tax policy is a significant driver of entrepreneurial location choice, independent of general population migration.

**Structured specification**

```json
{
  "novelty_rating":       "medium",
  "feasibility_rating":   "high",
  "complexity_rating":    "medium",
  "whimsy_rating":        "low",
  "geographic_level":     "state",
  "primary_metrics":      ["migration flow counts by class of worker", "migration flow counts by industry"],
  "proposed_method":      "Net migration calculation and comparative analysis",
  "robustness_checks":    ["using different years of ACS Migration Flows", "controlling for cost of living differences", "examining flows between contiguous state pairs"],
  "expected_runtime":     "1–4 hr",
  "ethical_flags":        []
}
```

**Narrative plan**

1.  **Data sources** – ACS Migration Flows (state-to-state files). These files provide mover counts by Class of Worker (e.g., employee of private company, self-employed in own not incorporated business). Industry of movers is also available. (State tax rates are external context, not joined data).
2.  **Methodology** – Classify states into "high tax" (e.g., CA, NY, NJ) and "no tax" (e.g., FL, TX, WA, NV) based on top marginal income tax rates. Using the ACS Migration Flows data, calculate the net migration of "self-employed, not incorporated" workers between these two groups of states. Compare this net flow rate (as a % of the stock population) to the net flow rate of "private for-profit employee" workers.
3.  **Why it matters / what could go wrong** – This speaks directly to the ongoing debate about whether state tax policies influence economic dynamism and attract entrepreneurs. The primary limitation is that "class of worker" can be fluid, and the ACS data captures status in the past year, which may not perfectly align with the reason for moving.

**Key references**
• Moretti, E., & Wilson, D. J. (2017). *The Effect of State Taxes on the Geographical Location of Top Earners: Evidence from Star Scientists*. American Economic Review.

-----

## HYPOTHESIS\_TITLE: The "TIGER's Stripes" Effect: Mismatches between Administrative Boundaries and Lived Experience *(BUCKET: Serious)*

**Abstract (≤ 60 words)** A significant portion of journey-to-work flows originating in one census tract terminate in an adjacent tract that belongs to a different municipality or county. The prevalence of these "cross-stripe" commutes is highest in highly fragmented metropolitan areas and is associated with lower median incomes, suggesting a cost imposed by inefficient administrative geography.

**Structured specification**

```json
{
  "novelty_rating":       "high",
  "feasibility_rating":   "low",
  "complexity_rating":    "high",
  "whimsy_rating":        "low",
  "geographic_level":     "tract",
  "primary_metrics":      ["% of commutes to adjacent tracts in different municipalities", "Herfindahl-Hirschman Index of government fragmentation"],
  "proposed_method":      "Geospatial analysis combining TIGER/Line files with tract-to-tract flow data (if available/procurable)",
  "robustness_checks":    ["controlling for population density", "using alternative measures of fragmentation", "examining specific metro areas"],
  "expected_runtime":     ">12 hr",
  "ethical_flags":        []
}
```

**Narrative plan**

1.  **Data sources** – This is on the edge of feasibility. The ACS Migration Flows do not provide tract-to-tract data publicly. This would require a special tabulation or access to the underlying microdata. The core geographic data comes from TIGER/Line shapefiles for census tracts and county/municipal boundaries. ACS 5-year data provides tract-level median income (B19013).
2.  **Methodology** – Assuming flow data is acquired: For each tract, identify its adjacent tracts using the shapefiles. Then, for each adjacent pair, determine if they lie in different municipalities/counties. Calculate the percentage of all commutes originating in the source tract that terminate in one of these "cross-stripe" adjacent tracts. Regress tract median income on this "cross-stripe commute" percentage.
3.  **Why it matters / what could go wrong** – This quantifies a core tenet of urban planning: that fragmented governance creates economic inefficiencies. It provides an empirical basis for promoting regional cooperation or consolidation. The primary obstacle is data acquisition; tract-to-tract commute data is not a standard product.

**Key references**
• Altshuler, A., et al. (1999). *Governance and Opportunity in Metropolitan America*.
• Rothwell, J. (2013). *The Metropolitan Revolution*. Brookings Institution Press.

-----

## HYPOTHESIS\_TITLE: Generational Crowding: Millennial Homebuyers and the Displacement of Long-Term Renters *(BUCKET: Exploratory)*

**Abstract (≤ 60 words)** In rapidly gentrifying census tracts, an increase in homeownership by the 30-44 age cohort (Millennials) between 2015 and 2022 is associated with a sharp decline in the number of renter households who have lived in their unit for 10 years or more. This suggests that the Millennial homebuying wave is directly displacing long-term, stable renter populations.

**Structured specification**

```json
{
  "novelty_rating":       "medium",
  "feasibility_rating":   "high",
  "complexity_rating":    "medium",
  "whimsy_rating":        "low",
  "geographic_level":     "tract",
  "primary_metrics":      ["homeownership rate by age", "tenure by year householder moved into unit"],
  "proposed_method":      "Panel data analysis with tract fixed effects",
  "robustness_checks":    ["controlling for new construction", "using different age brackets", "examining changes in racial composition"],
  "expected_runtime":     "4–12 hr",
  "ethical_flags":        ["Potential to stigmatize a demographic group (Millennials)"]
}
```

**Narrative plan**

1.  **Data sources** – ACS 5-year estimates (e.g., 2013-2017 vs. 2018-2022). Key tables: Tenure by Age of Householder (B25007) and Tenure by Year Householder Moved Into Unit (B25038).
2.  **Methodology** – Define "gentrifying tracts" as those in the top quartile of median gross rent increase. Within this subset, create a panel dataset of tracts over two 5-year periods. Regress the change in the count of long-term renters (moved in \>10 years ago) on the change in the count of homeowners aged 30-44, including controls for overall population change and new housing units.
3.  **Why it matters / what could go wrong** – This hypothesis adds a generational lens to the study of displacement, moving beyond simple income or race-based analysis. It could highlight the unintended consequences of one generation's economic progress on another's housing stability. A major confounder is that long-term renters may be leaving for other reasons (e.g., retirement, cashing out of a rent-controlled unit).

**Key references**
• Freeman, L. (2005). *Displacement or Succession? Residential Mobility in Gentrifying Neighborhoods*. Urban Affairs Review.

-----

## HYPOTHESIS\_TITLE: The Monoculture vs. Polyculture Economy: Ancestry Diversity and County-Level Economic Volatility *(BUCKET: Exploratory)*

**Abstract (≤ 60 words)** Counties with higher ancestry diversity (a Shannon entropy score calculated from detailed ancestry tables) exhibit lower volatility in their unemployment rates over the business cycle. This "polyculture" hypothesis posits that diverse social networks, tied to ancestry, create a more resilient and adaptable local economy compared to more homogenous "monoculture" counties.

**Structured specification**

```json
{
  "novelty_rating":       "high",
  "feasibility_rating":   "medium",
  "complexity_rating":    "medium",
  "whimsy_rating":        "medium",
  "geographic_level":     "county",
  "primary_metrics":      ["Shannon entropy of ancestry groups", "standard deviation of annual unemployment rate"],
  "proposed_method":      "Cross-sectional OLS regression",
  "robustness_checks":    ["controlling for industrial diversity (HHI)", "using different diversity metrics (e.g., Simpson)", "excluding high-immigration gateway counties"],
  "expected_runtime":     "1–4 hr",
  "ethical_flags":        []
}
```

**Narrative plan**

1.  **Data sources** – ACS 5-year estimates for county-level data. Key tables: First and Second Ancestries Reported (B04006). ACS 1-year estimates for annual unemployment rates (from table B23025, aggregated to annual series).
2.  **Methodology** – For each county, use the detailed ancestry data from B04006 to calculate a Shannon entropy index of diversity. Separately, using a time series of ACS 1-year data (e.g., 2007-2022), calculate the standard deviation of the annual unemployment rate for each county. Regress the unemployment volatility on the ancestry diversity index, controlling for factors like population size, industrial concentration, and region.
3.  **Why it matters / what could go wrong** – This provides a novel, culturally-grounded argument for the economic benefits of diversity, linking it to economic stability. The link is highly theoretical; ancestry may be a proxy for other unobserved factors (e.g., patterns of chain migration that are also linked to specific industries). The quality of self-reported ancestry data can also be inconsistent.

**Key references**
• Ottaviano, G. I., & Peri, G. (2006). *The economic value of cultural diversity: evidence from US cities*. Journal of Economic Geography.

-----

## HYPOTHESIS\_TITLE: The "Education-Commute" Tradeoff: Inverse Relationship Between Educational Attainment and Commute Time at the Metro Fringe *(BUCKET: Exploratory)*

**Abstract (≤ 60 words)** Within PUMAs on the exurban fringe of major metropolitan areas, there is a negative correlation between the median educational attainment and the median commute time. This suggests that higher-earning, more educated workers are "buying" shorter commutes by choosing pricier housing closer to job centers, while less-educated workers are forced into longer "super commutes" from more affordable peripheral locations.

**Structured specification**

```json
{
  "novelty_rating":       "medium",
  "feasibility_rating":   "high",
  "complexity_rating":    "medium",
  "whimsy_rating":        "low",
  "geographic_level":     "PUMA",
  "primary_metrics":      ["median educational attainment", "median travel time to work", "distance from metro core"],
  "proposed_method":      "Geographically weighted regression",
  "robustness_checks":    ["controlling for median income", "stratifying by industry (e.g., manufacturing vs. professional services)", "using alternative fringe definitions"],
  "expected_runtime":     "1–4 hr",
  "ethical_flags":        []
}
```

**Narrative plan**

1.  **Data sources** – ACS 5-year PUMA-level data. Key tables: Educational Attainment (B15002), Median Travel Time to Work (B08303). PUMA shapefiles from TIGER/Line to calculate distance from the metropolitan area's central business district.
2.  **Methodology** – Define "metro fringe" PUMAs as those with a certain population density and falling within a specific distance band from the metro core. Within this sample of PUMAs, use geographically weighted regression (GWR) to model median commute time as a function of the share of the population with a Bachelor's degree or higher. GWR will show how the relationship varies across space.
3.  **Why it matters / what could go wrong** – This highlights the spatial inequality of infrastructure access and quality of life, showing that for many on the fringe, education doesn't translate into better commute outcomes. The relationship could be confounded by the rise of remote work, which is not fully captured in "travel time to work" data, especially in post-2020 datasets.

**Key references**
• LeRoy, G., & Son, J. (2013). *The "transportation-induced" economic development model*. Good Jobs First.

-----

## HYPOTHESIS\_TITLE: The "Empty Nester, Full Inbox" Phenomenon: Remote Work Adoption is Highest Among 55-64 Year Olds in Low-Density Tracts *(BUCKET: Exploratory)*

**Abstract (≤ 60 words)** Comparing pre- and post-pandemic ACS data, the largest percentage-point increase in working from home occurred among the 55-64 age cohort ("empty nesters") living in census tracts with low population density and a high homeownership rate. This suggests remote work was most readily adopted by those with financial stability and available physical space, rather than younger "digital natives."

**Structured specification**

```json
{
  "novelty_rating":       "high",
  "feasibility_rating":   "medium",
  "complexity_rating":    "medium",
  "whimsy_rating":        "medium",
  "geographic_level":     "tract",
  "primary_metrics":      ["% working from home by age", "population density", "homeownership rate"],
  "proposed_method":      "Difference-in-differences analysis comparing age groups across tract types",
  "robustness_checks":    ["using PUMA-level data for stability", "controlling for industry mix", "examining internet access rates"],
  "expected_runtime":     "4–12 hr",
  "ethical_flags":        []
}
```

**Narrative plan**

1.  **Data sources** – ACS 5-year data (e.g., 2015-2019 vs. 2018-2022 to straddle the pandemic). Key tables: Means of Transportation to Work (B08301) which includes "Worked from home". This needs to be cross-tabulated by age, which requires PUMS microdata or a special tabulation. Tract-level density from Decennial Census and homeownership from ACS (B25003).
2.  **Methodology** – The ideal analysis requires tract-level data on remote work by age, which is difficult. A proxy is to use PUMA-level data from the ACS. We will calculate the change in the percentage working from home for different age groups (e.g., 25-34, 35-44, 45-54, 55-64) between the two ACS periods. We then regress this change on PUMA characteristics like median density and homeownership.
3.  **Why it matters / what could go wrong** – This challenges the popular image of the young, urban remote worker and suggests the digital transformation of work has a distinct generational and spatial geography. It has implications for understanding future retirement transitions and housing demand. The main limitation is the difficulty of getting this data at a fine-grained geographic level.

**Key references**
• Bloom, N. (2023). *The Surprising Stickiness of Remote Work*. Stanford Institute for Economic Policy Research.

-----

## HYPOTHESIS\_TITLE: Social Infrastructure and Integration: The Role of Public Libraries in Mitigating Linguistic Isolation *(BUCKET: Exploratory)*

**Abstract (≤ 60 words)** This is a "negative" hypothesis. There is no statistically significant correlation between the density of public libraries (a proxy for social infrastructure) and the prevalence of linguistically isolated households at the PUMA level. This suggests that while libraries are valuable, they are not, by themselves, a sufficient tool to overcome the structural barriers leading to linguistic isolation.

**Structured specification**

```json
{
  "novelty_rating":       "medium",
  "feasibility_rating":   "low",
  "complexity_rating":    "high",
  "whimsy_rating":        "low",
  "geographic_level":     "PUMA",
  "primary_metrics":      ["count of public libraries", "% of linguistically isolated households"],
  "proposed_method":      "Correlation analysis with spatial controls",
  "robustness_checks":    ["controlling for poverty, immigration rates, and urbanicity", "using different library data sources"],
  "expected_runtime":     "1–4 hr",
  "ethical_flags":        []
}
```

**Narrative plan**

1.  **Data sources** – ACS 5-year PUMA-level data for households speaking English less than "very well" (B16002). The key challenge is library locations. The Institute of Museum and Library Services (IMLS) provides this, but it is an *external dataset*. To do this with *only* Census data is impossible, as libraries are not identified. **This hypothesis is therefore not strictly possible under the prompt's constraints**, but illustrates a type of question that could be asked if "public buildings" were a Census category.
2.  **Methodology** – *Hypothetically*, one would geocode IMLS library locations and count them per PUMA. Then, regress the share of linguistically isolated households on the number of libraries per capita, controlling for confounding variables like the overall percentage of foreign-born population and poverty rates.
3.  **Why it matters / what could go wrong** – This tests the limits of "social infrastructure" arguments. A null finding would push policymakers to look for more structural solutions to social integration. The main problem is violating the "no external data" rule. A census-only proxy for social infrastructure is very difficult to construct.

**Key references**
• Klinenberg, E. (2018). *Palaces for the People: How Social Infrastructure Can Help Fight Inequality, Polarization, and the Decline of Civic Life*.

*(Self-correction: This hypothesis violates the data constraints. I will replace it with a feasible one.)*

-----

## HYPOTHESIS\_TITLE (REPLACEMENT): The "Hollowing Out" of Mid-Sized Family Homes: Bifurcation of Housing Stock *(BUCKET: Exploratory)*

**Abstract (≤ 60 words)** Between 2010 and 2020, the housing stock in many counties saw growth in the number of 1-2 bedroom units and 5+ bedroom units, but a stagnation or decline in traditional 3-4 bedroom homes. This bifurcation, visible in changing bedroom counts, reflects a splintering of household structure into smaller (singles, couples) and larger (multigenerational) units, squeezing out the mid-sized family norm.

**Structured specification**

```json
{
  "novelty_rating":       "medium",
  "feasibility_rating":   "high",
  "complexity_rating":    "low",
  "whimsy_rating":        "medium",
  "geographic_level":     "county",
  "primary_metrics":      ["% change in housing units by number of bedrooms"],
  "proposed_method":      "Descriptive analysis of change over time, correlated with demographic shifts.",
  "robustness_checks":    ["comparing owner-occupied vs. renter-occupied stock", "controlling for new construction vs. existing stock changes", "examining metro vs. non-metro counties"],
  "expected_runtime":     "1–4 hr",
  "ethical_flags":        []
}
```

**Narrative plan**

1.  **Data sources** – ACS 5-year data from two periods (e.g., 2008-2012 vs. 2018-2022). Key table: Bedrooms (B25041). This can be correlated with household type data, like Multigenerational Households (B11017) and nonfamily households.
2.  **Methodology** – For each county, calculate the percentage change in the number of housing units for different bedroom counts (1, 2, 3, 4, 5+). Classify counties based on the pattern of change (e.g., "bifurcated" if 1-2 and 5+ grow faster than 3-4). Correlate this classification with changes in the proportion of multigenerational and single-person households.
3.  **Why it matters / what could go wrong** – This provides concrete evidence for the changing American family structure as reflected in the built environment. It's a leading indicator for future housing demand and construction trends. The data doesn't distinguish between changes from new construction versus renovation, which is a limitation.

**Key references**
• Myers, D., & Pitkin, J. (2013). *The New 'House of the Future': The Post-Recession Outlook for a Smaller, More Rented, and More Diverse America*.

-----

## HYPOTHESIS\_TITLE: The Inter-Ethnic Commute: Do Different Racial/Ethnic Groups Have Systematically Different Commute Patterns? *(BUCKET: Exploratory)*

**Abstract (≤ 60 words)** Using ACS flow data, we hypothesize that, even after controlling for income and place of residence, different racial and ethnic groups exhibit systematically different commute sheds. For example, Hispanic commuters may have flows that are more geographically clustered than White non-Hispanic commuters, even when living in the same PUMA, reflecting distinct social or transit-dependent networks.

**Structured specification**

```json
{
  "novelty_rating":       "high",
  "feasibility_rating":   "low",
  "complexity_rating":    "high",
  "whimsy_rating":        "low",
  "geographic_level":     "PUMA",
  "primary_metrics":      ["commute flow counts by race/ethnicity", "spatial dispersion of commute destinations"],
  "proposed_method":      "Network analysis and spatial statistics on commute flows",
  "robustness_checks":    ["controlling for industry", "stratifying by means of transportation", "using different years"],
  "expected_runtime":     ">12 hr",
  "ethical_flags":        ["Analysis of racial data must be handled carefully to avoid reinforcing stereotypes."]
}
```

**Narrative plan**

1.  **Data sources** – This requires a special tabulation of the ACS journey-to-work data, specifically place-of-residence-to-place-of-work flows (at the tract or TAZ level) broken down by race/ethnicity. The public ACS Migration Flows are based on moves, not daily commutes, and standard commute tables don't show destinations. This is a major data access challenge.
2.  **Methodology** – *Hypothetically*, for a given metro area, one would take the commute flow data from a specific residential PUMA. For each racial/ethnic group, map the destination PUMAs/tracts. Calculate a measure of spatial dispersion (e.g., standard distance) for each group's commute shed. A regression would then test if the dispersion measure for, say, Black commuters is significantly different from White commuters after controlling for income.
3.  **Why it matters / what could go wrong** – This could uncover hidden layers of spatial mismatch and segregation that persist in daily travel patterns, with major implications for transportation equity planning. The data constraint is the biggest hurdle. If data is available, interpretation must be nuanced to avoid simplistic or deterministic conclusions.

**Key references**
• Stoll, M. A. (2005). *Job Sprawl and the Spatial Mismatch between Blacks and Jobs*. The Brookings Institution.

-----

## HYPOTHESIS\_TITLE: "Appliance Poverty" as a Leading Indicator of Neighborhood Decline *(BUCKET: Exploratory)*

**Abstract (≤ 60 words)** Census tracts with a statistically significant increase in the percentage of households lacking a vehicle and/or select kitchen facilities (stove, refrigerator) between 2010 and 2020 are more likely to experience subsequent population loss and declines in property values in the following years (as measured by ACS 2021-2023).

**Structured specification**

```json
{
  "novelty_rating":       "medium",
  "feasibility_rating":   "high",
  "complexity_rating":    "medium",
  "whimsy_rating":        "low",
  "geographic_level":     "tract",
  "primary_metrics":      ["% households with no vehicle", "% households lacking complete kitchen facilities", "population change", "median home value"],
  "proposed_method":      "Granger-causality-style analysis on time-series of ACS data",
  "robustness_checks":    ["controlling for poverty rate and income", "using different lag structures", "checking for spatial autocorrelation"],
  "expected_runtime":     "4–12 hr",
  "ethical_flags":        []
}
```

**Narrative plan**

1.  **Data sources** – ACS 5-year data (e.g., 2008-2012, 2013-2017, 2018-2022). Key tables: Vehicles Available (B25044), Kitchen Facilities (B25051), Population Total (B01003), Median Home Value (B25077).
2.  **Methodology** – Create a panel of census tracts across three or more ACS 5-year periods. The key independent variables are the changes in the percentage of households lacking a vehicle or complete kitchen. The dependent variables are the *future* changes in population and home values. For example, test if the change in appliance poverty from period 1 to 2 predicts the change in population from period 2 to 3.
3.  **Why it matters / what could go wrong** – This attempts to find a novel, non-monetary leading indicator of neighborhood distress. These physical indicators might capture decline before it appears in income or employment data. The relationship may not be causal; appliance poverty could be a coincident indicator of decline, not a leading one.

**Key references**
• Desmond, M. (2016). *Evicted: Poverty and Profit in the American City*.
• Sampson, R. J. (2012). *Great American City: Chicago and the Enduring Neighborhood Effect*.

-----

## HYPOTHESIS\_TITLE: The Grandparent Dividend: Grandchildren in Household and Senior Labor Force Participation *(BUCKET: Exploratory)*

**Abstract (≤ 60 words)** In counties with high housing cost burdens, there is a positive correlation between the number of householders over 60 responsible for their own grandchildren and the labor force participation rate of the 60+ population. This suggests that caregiving responsibilities, likely driven by economic pressures on the middle generation, are compelling seniors to remain in or re-enter the workforce.

**Structured specification**

```json
{
  "novelty_rating":       "medium",
  "feasibility_rating":   "high",
  "complexity_rating":    "low",
  "whimsy_rating":        "low",
  "geographic_level":     "county",
  "primary_metrics":      ["% of householders 60+ responsible for grandchildren", "labor force participation rate of 60+ population", "median gross rent as % of income"],
  "proposed_method":      "Interaction-term regression",
  "robustness_checks":    ["using PUMA-level data", "controlling for local unemployment", "stratifying by sex of householder"],
  "expected_runtime":     "1–4 hr",
  "ethical_flags":        []
}
```

**Narrative plan**

1.  **Data sources** – ACS 5-year data at the county level. Key tables: Grandparents Living With Grandchildren (B10050), Sex by Age by Employment Status (B23001), and Median Gross Rent as a Percentage of Household Income (B25071).
2.  **Methodology** – The analysis will be a cross-sectional regression across all counties. The dependent variable is the labor force participation rate for the 60+ population. The main independent variables are the percentage of households headed by a grandparent responsible for grandchildren and the county's median housing cost burden, plus an interaction term between the two.
3.  **Why it matters / what could go wrong** – This hypothesis connects three major trends: the retirement crisis, the housing affordability crisis, and the rising role of grandparents as primary caregivers. It reframes senior employment as potentially non-discretionary. Correlation is not causation; there could be an unobserved factor (e.g., poor local economic conditions) driving all three variables.

**Key references**
• Glick, J. E. (2010). *Grandparents as Caregivers in the U.S.*. Population Reference Bureau.

-----

## HYPOTHESIS\_TITLE: The Bachelor Pad Index: Correlation Between Sex Ratio Imbalance and Housing Tenure *(BUCKET: Exploratory)*

**Abstract (≤ 60 words)** PUMAs with a sex ratio skewed towards males aged 25-39 have a significantly higher rentership rate and a lower median number of rooms per housing unit compared to PUMAs skewed towards females. This suggests that male-dominated labor markets (e.g., tech, oil extraction) foster a transient, rental-focused housing culture, while female-dominated markets (e.g., education, healthcare) correlate with more settled, ownership-oriented patterns.

**Structured specification**

```json
{
  "novelty_rating":       "medium",
  "feasibility_rating":   "high",
  "complexity_rating":    "low",
  "whimsy_rating":        "high",
  "geographic_level":     "PUMA",
  "primary_metrics":      ["sex ratio for age 25-39", "renter-occupied housing unit share", "median rooms per unit"],
  "proposed_method":      "Simple correlation and OLS regression",
  "robustness_checks":    ["controlling for median age and income", "examining industry mix (e.g., % in construction vs. % in health care)", "using different age brackets"],
  "expected_runtime":     "<1 hr",
  "ethical_flags":        []
}
```

**Narrative plan**

1.  **Data sources** – ACS 5-year PUMA-level data. Tables: Sex by Age (B01001) to calculate the sex ratio. Housing Tenure (B25003). Median Rooms (B25018).
2.  **Methodology** – For each PUMA, calculate the sex ratio (males per 100 females) for the 25-39 age group. In a simple OLS model, regress the renter-occupied housing unit share on this sex ratio, controlling for PUMA-level median income and median age. A second regression will use median rooms as the dependent variable.
3.  **Why it matters / what could go wrong** – While exploratory, this links demographic composition to the fundamental structure of the local housing market. It could be an unusual predictor for housing developers or policymakers. The relationship is likely not causal but driven by the industrial structure of the PUMA, for which sex ratio is a proxy.

**Key references**
• Costa, D. L., & Kahn, M. E. (2000). *Power Couples: Changes in the Locational Choice of the College Educated, 1940-1990*. The Quarterly Journal of Economics.

-----

## HYPOTHESIS\_TITLE: The Commuting-by-Bicycle "Archipelago": Spatial Clustering of Bicycle Commuters is Independent of Income but Dependent on Housing Vintage *(BUCKET: Exploratory)*

**Abstract (≤ 60 words)** Bicycle commuting is not evenly distributed but occurs in distinct "islands" or clusters of census tracts. The likelihood of a tract being part of a bicycle-commuting archipelago is not significantly correlated with its median income but is strongly correlated with having a high proportion of pre-1940s housing stock, suggesting that historic street grids are a primary determinant.

**Structured specification**

```json
{
  "novelty_rating":       "medium",
  "feasibility_rating":   "high",
  "complexity_rating":    "high",
  "whimsy_rating":        "medium",
  "geographic_level":     "tract",
  "primary_metrics":      ["% of workers commuting by bicycle", "Getis-Ord Gi* statistic", "median year structure built"],
  "proposed_method":      "Hot spot analysis (Getis-Ord Gi*) followed by logistic regression",
  "robustness_checks":    ["controlling for population density", "testing in different metro areas", "using proximity to universities as a control"],
  "expected_runtime":     "4–12 hr",
  "ethical_flags":        []
}
```

**Narrative plan**

1.  **Data sources** – ACS 5-year data at the census tract level. Key tables: Means of Transportation to Work (B08301) for bicycle commuters. Median Year Structure Built (B25035). Median Household Income (B19013).
2.  **Methodology** – First, calculate the percentage of workers commuting by bicycle for every tract in a set of large metro areas. Use a hot spot analysis (Getis-Ord Gi\*) to identify statistically significant spatial clusters of high bicycle commuting (the "archipelagos"). Create a binary variable (1 if tract is in a hot spot, 0 otherwise). Use logistic regression to model this outcome, with median year structure built and median income as key predictors.
3.  **Why it matters / what could go wrong** – This suggests that infrastructure for cycling may be most effective when it builds on existing, historic urban forms rather than trying to create it from scratch in auto-oriented areas. The analysis could be confounded by unobserved factors like the presence of specific greenways or a pro-cycling culture not captured in census data.

**Key references**
• Pucher, J., & Buehler, R. (2008). *Making Cycling Irresistible: Lessons from The Netherlands, Denmark and Germany*. Transport Reviews.

-----

## HYPOTHESIS\_TITLE: The "Dialect Drifters": Correlation Between Regional Dialect Words and State-to-State Migration Flows *(BUCKET: Whimsical)*

**Abstract (≤ 60 words)** This hypothesis cannot be tested with Census data, as it requires linguistic data not collected by the Bureau. It imagines correlating state-to-state migration flows with linguistic similarity scores derived from dialect surveys (e.g., the prevalence of "y'all," "soda" vs. "pop"). The idea is that people are subtly more likely to move to places that "sound like home."

**Structured specification**

```json
{
  "novelty_rating":       "high",
  "feasibility_rating":   "low",
  "complexity_rating":    "medium",
  "whimsy_rating":        "high",
  "geographic_level":     "state",
  "primary_metrics":      ["migration flow counts", "linguistic distance metric"],
  "proposed_method":      "Gravity model of migration with a linguistic variable",
  "robustness_checks":    ["controlling for geographic distance", "using different dialect features", "checking against ancestry data"],
  "expected_runtime":     "1–4 hr",
  "ethical_flags":        []
}
```

**Narrative plan**

1.  **Data sources** – ACS Migration Flows (state-to-state). *The necessary second dataset, a quantitative measure of linguistic distance between states, does not exist in the Census Bureau API.* This would rely on external sources like the Harvard Dialect Survey.
2.  **Methodology** – *Hypothetically*, one would construct a linguistic distance matrix between states. A gravity model of migration would then be estimated, where the number of migrants between state A and state B is a function of their populations, the distance between them, and this new linguistic distance variable. The hypothesis predicts a significant negative coefficient on linguistic distance.
3.  **Why it matters / what could go wrong** – It's a playful exploration of cultural factors in migration. It's untestable as specified. To make it Census-based, one might use "Language Spoken at Home" as a very poor proxy, but it wouldn't capture regional English dialects. **This is a failed hypothesis under the rules.**

*(Self-correction: This hypothesis violates the data constraints. I will replace it with a feasible one.)*

-----

## HYPOTHESIS\_TITLE (REPLACEMENT): The "Carless Corridors": Tracts with Low Vehicle Ownership Form Distinct Spatial Corridors *(BUCKET: Whimsical)*

**Abstract (≤ 60 words)** In major cities, census tracts with a high percentage of zero-vehicle households are not randomly distributed but form contiguous linear corridors. These "carless corridors" align with historic streetcar lines or modern high-frequency bus routes, demonstrating how transit infrastructure from different eras shapes household economic decisions and creates distinct urban geographies visible in the census.

**Structured specification**

```json
{
  "novelty_rating":       "medium",
  "feasibility_rating":   "high",
  "complexity_rating":    "medium",
  "whimsy_rating":        "high",
  "geographic_level":     "tract",
  "primary_metrics":      ["% of households with zero vehicles", "Local Moran's I"],
  "proposed_method":      "Spatial autocorrelation analysis (LISA)",
  "robustness_checks":    ["testing against tract-level public transit usage data", "overlaying with TIGER/Line road network types", "comparing cities with different transit histories"],
  "expected_runtime":     "1–4 hr",
  "ethical_flags":        []
}
```

**Narrative plan**

1.  **Data sources** – ACS 5-year data at the census tract level. Key table: Vehicles Available (B25044). TIGER/Line files for road networks could be used for visual corroboration.
2.  **Methodology** – For a selection of large US cities, calculate the percentage of households with no vehicles for each census tract. Then, perform a Local Indicators of Spatial Association (LISA) analysis, like Local Moran's I, to identify significant clusters of high-zero-vehicle tracts (High-High clusters). The hypothesis is that these clusters will not be blob-like but will form distinct linear or arterial shapes.
3.  **Why it matters / what could go wrong** – This provides a novel way to visualize the enduring impact of transit infrastructure on neighborhood form and function. It could help modern transit planners identify corridors where car-free living is already an established norm to be reinforced. The pattern could be generated by other linear features, like rivers or parks, not just transit.

**Key references**
• Warner, S. B. (1962). *Streetcar Suburbs: The Process of Growth in Boston, 1870-1900*.

-----

## HYPOTHESIS\_TITLE: The "Gamer Ghetto" Myth: No Correlation Between Time Spent on Computers at Home and Local Youth Unemployment *(BUCKET: Whimsical)*

**Abstract (≤ 60 words)** This is a null hypothesis. At the PUMA level, there is no statistically significant correlation between the proportion of households having a computer with a broadband internet subscription and the unemployment rate for the 16-24 age group. This playfully refutes the stereotype that youth unemployment is driven by excessive "screen time," suggesting the factors are economic, not recreational.

**Structured specification**

```json
{
  "novelty_rating":       "low",
  "feasibility_rating":   "high",
  "complexity_rating":    "low",
  "whimsy_rating":        "high",
  "geographic_level":     "PUMA",
  "primary_metrics":      ["% households with computer and broadband", "unemployment rate for ages 16-24"],
  "proposed_method":      "Pearson correlation test",
  "robustness_checks":    ["controlling for overall PUMA unemployment rate", "checking different age brackets for youth", "using data from different ACS years"],
  "expected_runtime":     "<1 hr",
  "ethical_flags":        []
}
```

**Narrative plan**

1.  **Data sources** – ACS 5-year PUMA-level data. Key tables: Types of Computers and Internet Subscriptions (B28003) and Sex by Age by Employment Status (B23001).
2.  **Methodology** – For each PUMA, calculate the percentage of households with a computer and a broadband subscription. Also, calculate the unemployment rate for the population aged 16-24. Run a simple Pearson correlation test between these two variables across all PUMAs. The hypothesis is that the correlation coefficient will be statistically indistinguishable from zero.
3.  **Why it matters / what could go wrong** – This uses census data to playfully debunk a common folk theory about youth unemployment. It reinforces that correlation (or lack thereof) at a geographic level can challenge individual-level assumptions. The obvious flaw is that household computer access is a poor proxy for an individual's recreational screen time.

**Key references**
• N/A (This is a whimsical hypothesis designed to be simple and self-contained).

-----

## HYPOTHESIS\_TITLE: The "Old House, New Language" Effect: Housing Stock Age and Linguistic Diversity *(BUCKET: Whimsical)*

**Abstract (≤ 60 words)** In urban census tracts, there is a positive correlation between the median age of the housing stock and the diversity of languages spoken at home. The "old house, new language" effect suggests that older neighborhoods, with potentially more affordable or subdivided housing, serve as entry points for diverse immigrant groups, making housing vintage an unlikely proxy for linguistic pluralism.

**Structured specification**

```json
{
  "novelty_rating":       "medium",
  "feasibility_rating":   "high",
  "complexity_rating":    "medium",
  "whimsy_rating":        "high",
  "geographic_level":     "tract",
  "primary_metrics":      ["median year structure built", "Shannon entropy of languages spoken"],
  "proposed_method":      "Spatial regression",
  "robustness_checks":    ["controlling for poverty and rentership rates", "excluding tracts dominated by a single non-English language", "comparing across different cities"],
  "expected_runtime":     "4–12 hr",
  "ethical_flags":        []
}
```

**Narrative plan**

1.  **Data sources** – ACS 5-year tract-level data. Key tables: Median Year Structure Built (B25035) and Language Spoken at Home (B16001).
2.  **Methodology** – For each census tract in a selection of major cities, calculate a Shannon entropy index based on the counts of people speaking different languages from table B16001. Then, run a regression where this language diversity index is the dependent variable and the median year the structures were built is the key independent variable, controlling for confounders like population density and median income.
3.  **Why it matters / what could go wrong** – This is a whimsical but interesting way to link the physical environment (architecture, urban form) with the cultural fabric of a neighborhood. It suggests urban preservation has unintended, positive side effects on diversity. The relationship could be spurious, driven by the fact that both old housing and immigrant settlement are concentrated in central cities.

**Key references**
• Jacobs, J. (1961). *The Death and Life of Great American Cities*.

-----

## HYPOTHESIS\_TITLE: "Plumber's Paradox": Inverse Correlation Between Plumbing Completeness and Population Density *(BUCKET: Whimsical)*

**Abstract (≤ 60 words)** Across US counties, there is a weak but statistically significant *positive* correlation between population density and the percentage of housing units lacking complete plumbing facilities. This "Plumber's Paradox" is counterintuitive, suggesting that the nation's densest urban areas retain pockets of substandard housing that are less common in lower-density suburban or rural areas.

**Structured specification**

```json
{
  "novelty_rating":       "low",
  "feasibility_rating":   "high",
  "complexity_rating":    "low",
  "whimsy_rating":        "high",
  "geographic_level":     "county",
  "primary_metrics":      ["% of units lacking complete plumbing", "population per square mile"],
  "proposed_method":      "Bivariate correlation analysis",
  "robustness_checks":    ["using tract-level data to confirm", "controlling for median housing age", "removing extreme outliers like NYC"],
  "expected_runtime":     "<1 hr",
  "ethical_flags":        []
}
```

**Narrative plan**

1.  **Data sources** – ACS 5-year county-level data. Key table: Plumbing Facilities (B25049). Population and land area data from the Decennial Census summary files to calculate density.
2.  **Methodology** – For every county, calculate population density. From the ACS, find the percentage of housing units that lack complete plumbing. Plot these two variables on a scatter plot and calculate the Pearson correlation coefficient. The hypothesis predicts a small, positive r-value.
3.  **Why it matters / what could go wrong** – This is a simple, surprising statistic that subverts common assumptions about urban vs. rural quality of life. It can be a useful "cocktail party fact" to illustrate the complexity of urban inequality. The effect might be driven entirely by a few very large, dense cities with old housing stock, so checking for outliers is crucial.

**Key references**
• N/A

-----

## HYPOTHESIS\_TITLE: The Dog Walker's Dilemma: Solo Commuters and Single-Person Households *(BUCKET: Whimsical)*

**Abstract (≤ 60 words)** In suburban PUMAs, there is a strong positive correlation between the percentage of workers who drive alone to work and the percentage of households that are single-person households. This isn't just about commute choice, but reflects a lifestyle "package deal": a social landscape of individualism manifests in both solitary homes and solitary travel.

**Structured specification**

```json
{
  "novelty_rating":       "low",
  "feasibility_rating":   "high",
  "complexity_rating":    "low",
  "whimsy_rating":        "high",
  "geographic_level":     "PUMA",
  "primary_metrics":      ["% driving alone to work", "% single-person households"],
  "proposed_method":      "Correlation analysis",
  "robustness_checks":    ["controlling for population density and median age", "comparing suburban vs. urban PUMAs", "checking against vehicle ownership rates"],
  "expected_runtime":     "<1 hr",
  "ethical_flags":        []
}
```

**Narrative plan**

1.  **Data sources** – ACS 5-year PUMA-level data. Key tables: Means of Transportation to Work (B08301) and Household Type (B11001).
2.  **Methodology** – First, classify PUMAs as "suburban" based on a population density threshold. Within this group, calculate the percentage of workers driving alone and the percentage of single-person households. A simple correlation test is the main analysis. A regression controlling for median income could add rigor.
3.  **Why it matters / what could go wrong** – This is a whimsical way of showing how different Census variables can be woven together to tell a story about a particular social geography or "way of life." The correlation is almost certainly not causal but is instead driven by the built environment (low density) which encourages both driving and single-family (often single-person) living.

**Key references**
• Putnam, R. D. (2000). *Bowling Alone: The Collapse and Revival of American Community*.

-----

## HYPOTHESIS\_TITLE: The Left-Handed Smudge Effect: No Geographic Clustering of Left-Handedness *(BUCKET: Whimsical)*

**Abstract (≤ 60 words)** This is a null hypothesis that cannot be tested with census data. Handedness is not a variable collected by the U.S. Census Bureau. The hypothesis would be that, unlike almost any other human trait, the percentage of the population that is left-handed shows no geographic clustering at the state, county, or tract level, being a purely random biological phenomenon.

**Structured specification**

```json
{
  "novelty_rating":       "high",
  "feasibility_rating":   "low",
  "complexity_rating":    "low",
  "whimsy_rating":        "high",
  "geographic_level":     "county",
  "primary_metrics":      ["% left-handed (hypothetical)"],
  "proposed_method":      "Spatial autocorrelation analysis (Global Moran's I)",
  "robustness_checks":    [],
  "expected_runtime":     "<1 hr",
  "ethical_flags":        []
}
```

**Narrative plan**

1.  **Data sources** – No Census Bureau data is available for this variable. The hypothesis is untestable under the prompt's constraints. It serves as an example of a variable that, if it *were* collected, could be used to test for pure spatial randomness.
2.  **Methodology** – *Hypothetically*, one would collect the percentage of left-handed people per county. A Global Moran's I test would then be performed. The null hypothesis of the test (spatial randomness) is the research hypothesis here. One would expect to fail to reject the null.
3.  **Why it matters / what could go wrong** – It's a playful thought experiment about what a truly aspatial variable would look like, providing a baseline against which to compare the real-world geographic clustering of social and demographic phenomena. It is not a feasible research project using the allowed data.

*(Self-correction: This hypothesis violates the data constraints. I will replace it with a feasible one.)*

-----

## HYPOTHESIS\_TITLE (REPLACEMENT): The Moniker Median: Correlation Between State Population and Median Age *(BUCKET: Whimsical)*

**Abstract (≤ 60 words)** Across the 50 states, there is a moderate negative correlation between a state's total population and its median age. Larger states tend to be younger, while smaller states tend to be older. This may reflect the tendency of younger people to be drawn to large, economically dynamic states, while older populations are more prominent in smaller, slower-growing ones.

**Structured specification**

```json
{
  "novelty_rating":       "low",
  "feasibility_rating":   "high",
  "complexity_rating":    "low",
  "whimsy_rating":        "medium",
  "geographic_level":     "state",
  "primary_metrics":      ["total population", "median age"],
  "proposed_method":      "Simple OLS regression and scatterplot visualization",
  "robustness_checks":    ["using data from different decades (2010, 2020)", "weighting by population", "examining the role of migration flows from PEP"],
  "expected_runtime":     "<1 hr",
  "ethical_flags":        []
}
```

**Narrative plan**

1.  **Data sources** – Decennial Census (2020) state-level summary files. Key tables: Total Population (P1) and Median Age (P13). PEP components of change could be used for robustness checks on migration.
2.  **Methodology** – Create a dataset with two columns: the total population of each of the 50 states and the median age of each state. Run a simple linear regression of median age on the natural log of the total population. The hypothesis predicts a statistically significant negative coefficient.
3.  **Why it matters / what could go wrong** – This is a simple, easily communicable demographic fact that links two fundamental attributes of a state. It's a good entry point for discussions about migration, economic opportunity, and aging. The relationship isn't causal but reflects deeper economic and social forces that attract different age groups to different kinds of places.

**Key references**
• Frey, W. H. (2018). *Diversity Explosion: How New Racial Demographics are Remaking America*.

-----

## HYPOTHESIS\_TITLE: The "Hot Kitchen" Hypothesis: Correlation Between Lack of A/C and Lack of Complete Kitchens *(BUCKET: Whimsical)*

**Abstract (≤ 60 words)** At the county level, there is a positive correlation between the percentage of households lacking air conditioning and the percentage lacking a complete kitchen (stove or refrigerator). This suggests that housing quality is multi-dimensional; deficiencies are not isolated but tend to cluster, creating pockets of "compounded" housing inadequacy, particularly in regions where A/C is prevalent.

**Structured specification**

```json
{
  "novelty_rating":       "low",
  "feasibility_rating":   "high",
  "complexity_rating":    "low",
  "whimsy_rating":        "medium",
  "geographic_level":     "county",
  "primary_metrics":      ["% households without A/C", "% households lacking complete kitchen"],
  "proposed_method":      "Bivariate correlation, restricted to states in the South and Southwest",
  "robustness_checks":    ["controlling for county poverty rate", "using tract-level data", "comparing owner- vs. renter-occupied units"],
  "expected_runtime":     "<1 hr",
  "ethical_flags":        []
}
```

**Narrative plan**

1.  **Data sources** – This hypothesis has a data challenge. The Decennial Census and ACS do not have a general question about air conditioning. However, the American Housing Survey (AHS) does, but it's a separate survey not listed in the prompt's allowed datasets. Therefore, this is not testable.

*(Self-correction: This hypothesis violates the data constraints. I will replace it with a feasible one.)*

-----

## HYPOTHESIS\_TITLE (REPLACEMENT): The Multigenerational Commute: Inverse Relationship Between Multigenerational Households and Commute Times *(BUCKET: Whimsical)*

**Abstract (≤ 60 words)** At the PUMA level, there is a negative correlation between the prevalence of multigenerational households and median commute times. This suggests that multigenerational living, by pooling resources, allows households to afford housing closer to job centers, or that the complex logistics of coordinating multiple adults' lives incentivizes minimizing travel time.

**Structured specification**

```json
{
  "novelty_rating":       "medium",
  "feasibility_rating":   "high",
  "complexity_rating":    "low",
  "whimsy_rating":        "medium",
  "geographic_level":     "PUMA",
  "primary_metrics":      ["% multigenerational households", "median travel time to work"],
  "proposed_method":      "OLS Regression",
  "robustness_checks":    ["controlling for median household income and race/ethnicity", "examining high-cost-of-living areas only", "using different commute time thresholds"],
  "expected_runtime":     "<1 hr",
  "ethical_flags":        []
}
```

**Narrative plan**

1.  **Data sources** – ACS 5-year PUMA-level data. Key tables: Multigenerational Households (B11017) and Median Travel Time to Work (B08303).
2.  **Methodology** – For each PUMA, calculate the percentage of all households that are multigenerational. Regress the PUMA's median travel time to work on this percentage, including control variables like median household income, population density, and the percentage of the population that is foreign-born (as multigenerational living is more common among some immigrant groups).
3.  **Why it matters / what could go wrong** – This provides a potential, and often overlooked, social benefit to a rising household structure: reduced time spent commuting. It links household economics to transportation outcomes. The correlation could be spurious; for instance, cultural groups that favor multigenerational living may also favor living in dense urban neighborhoods that naturally have shorter commutes.

**Key references**
• Pew Research Center (2022). *The Enduring Appeal of Multigenerational Households*.