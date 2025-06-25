## HYPOTHESIS\_TITLE: The “Zoom Town” Premium: Quantifying the Impact of Remote Work-Friendly Job Structures on Post-Pandemic County Growth *(BUCKET: Serious)*

**Abstract (≤ 60 words)**
Counties with a higher pre-pandemic concentration of occupations amenable to remote work experienced significantly greater population and median income growth between 2019 and 2023. This effect is strongest in counties with high natural amenities and lower pre-pandemic housing costs, suggesting a re-sorting of high-earning professionals accelerated by the normalization of remote work.

**Structured specification**

```json
{
"novelty_rating": "medium",
"feasibility_rating": "high",
"complexity_rating": "medium",
"whimsy_rating": "low",
"geographic_level": "county",
"primary_metrics": ["population growth", "median household income change", "net domestic migration"],
"proposed_method": "difference-in-differences",
"robustness_checks": ["controlling for pre-trends", "alternative remote work index weighting", "spatial lag models"],
"expected_runtime": "1–4 hr",
"ethical_flags": []
}
```

**Narrative plan**

1.  **Data sources** – The analysis will leverage:

      * **ACS 5-Year Estimates (2015-2019)**: Table `S2401` (Occupation by Sex for the Civilian Employed Population) to construct a pre-pandemic index of remote-work amenability at the county level, based on standard occupation classifications (e.g., Dingel & Neiman, 2020). Table `DP03` for baseline income.
      * **Population Estimates Program (PEP)**: Annual `pep/population` and `pep/components` endpoints to track county-level population change and net domestic migration from 2020 to the latest available year.
      * **ACS 1-Year Estimates (2019, 2021, 2022, 2023)**: Table `B19013` to measure changes in median household income.

2.  **Methodology** – A difference-in-differences (DiD) or a continuous treatment model will be employed. The "treatment" intensity is the pre-2020 share of jobs in a county that can be performed remotely. The "post" period is 2020 onwards. The model will compare changes in population, migration, and income across counties with varying levels of this remote-work index, controlling for baseline demographic and economic characteristics.

3.  **Why it matters / what could go wrong** – Understanding this re-sorting is crucial for housing, transportation, and fiscal policy in both "losing" and "winning" counties. A key challenge is that the remote work index is a proxy. The primary risk is omitted variable bias; for instance, counties with high remote-work potential might also have other unobserved attributes (e.g., "quality of life") that are the true drivers of growth. Pre-trend analysis is critical to mitigate this.

**Key references**
• Dingel, J. I., & Neiman, B. (2020). *How Many Jobs Can be Done at Home?*. NBER Working Paper No. 26948.
• Moretti, E. (2012). *The New Geography of Jobs*. Houghton Mifflin Harcourt.

-----

## HYPOTHESIS\_TITLE: Vacancy Chains and Neighborhood Tipping Points: Do High "For Rent" Vacancy Rates Predict Accelerated Gentrification? *(BUCKET: Serious)*

**Abstract (≤ 60 words)**
In historically low-income urban census tracts, a sharp, sustained increase in the share of vacant units classified as "For Rent" is a leading indicator of accelerated demographic change. We hypothesize that a high rental vacancy rate precedes significant increases in median income, educational attainment, and the proportion of non-Hispanic White residents within the following five-year period.

**Structured specification**

```json
{
"novelty_rating": "medium",
"feasibility_rating": "high",
"complexity_rating": "medium",
"whimsy_rating": "low",
"geographic_level": "tract",
"primary_metrics": ["change in median household income", "change in racial composition", "change in educational attainment"],
"proposed_method": "fixed-effects panel regression",
"robustness_checks": ["lagged dependent variables", "instrumental variable for vacancy", "testing for spatial autocorrelation"],
"expected_runtime": "4–12 hr",
"ethical_flags": ["potential to identify areas vulnerable to displacement"]
}
```

**Narrative plan**

1.  **Data sources** – The core data is a panel constructed from two non-overlapping **ACS 5-Year Estimates** (e.g., 2010-2014 and 2015-2019).

      * `B25004` (Vacancy Status): The primary predictor variable—the share of vacant units "For Rent."
      * `DP05` (Demographic and Housing Estimates): Outcome variables including racial composition.
      * `B19013` (Median Household Income): Key economic outcome.
      * `S1501` (Educational Attainment): Key social outcome.

2.  **Methodology** – We will use a tract-level fixed-effects model to control for time-invariant unobserved neighborhood characteristics. The model will regress changes in demographic and economic outcomes in the second period on the rental vacancy rate from the first period, controlling for a suite of baseline characteristics (e.g., housing tenure, population density). This isolates the predictive power of the vacancy signal.

3.  **Why it matters / what could go wrong** – This could provide a quantifiable early-warning system for communities at risk of displacement, allowing for proactive policy interventions. The main challenge is reverse causality or simultaneity: are rising rents causing vacancies, or are vacancies signaling an area ripe for investment? The use of lagged predictors helps, but an instrumental variable (e.g., changes in local landlord-tenant laws) would be stronger, though likely unavailable within Census data.

**Key references**
• Guerrieri, V., Hartley, D., & Hurst, E. (2013). *Endogenous Gentrification and Housing Price Dynamics*. Journal of Public Economics, 100, 45-60.
• Sampson, R. J. (2012). *Great American City: Chicago and the Enduring Neighborhood Effect*. University of Chicago Press.

-----

## HYPOTHESIS\_TITLE: The Grandparent Dividend: Grandchild Co-residence as a Quasi-Subsidy for Female Labor Force Participation *(BUCKET: Serious)*

**Abstract (≤ 60 words)**
In U.S. states with low female labor force participation (LFP), census tracts with a higher proportion of grandparents living with their own grandchildren under 18 exhibit a statistically significant positive deviation in LFP for females with young children. This suggests that intergenerational co-residence functions as a critical, non-market childcare subsidy, impacting local labor supply.

**Structured specification**

```json
{
"novelty_rating": "high",
"feasibility_rating": "medium",
"complexity_rating": "medium",
"whimsy_rating": "low",
"geographic_level": "tract",
"primary_metrics": ["female labor force participation rate (with children)", "grandparents living with grandchildren"],
"proposed_method": "instrumental variable (IV) regression",
"robustness_checks": ["sub-group analysis by race/ethnicity", "controlling for local housing costs", "placebo test using households with older children"],
"expected_runtime": "4–12 hr",
"ethical_flags": []
}
```

**Narrative plan**

1.  **Data sources** – All data from the **ACS 5-Year Estimates** to ensure statistical stability at the tract level.

      * `B10051` (Grandparents Living With Grandchildren): The key independent variable.
      * `B23008` (Age of Own Children by Labor Force Status for Females): The primary outcome variable.
      * `DP02`, `DP03`, `DP04`: Control variables for social, economic, and housing characteristics of the tract.

2.  **Methodology** – OLS regression faces endogeneity: women may choose to work *because* a grandparent is present, or the grandparent may move in *because* the woman is working. To establish causality, we propose an instrumental variable approach. A potential instrument for grandparent co-residence is the tract's share of residents aged 60-70 who moved into the county from another state 5+ years ago—plausibly correlated with "grandparent migration" but not directly with a woman's current decision to work.

3.  **Why it matters / what could go wrong** – The findings could quantify the economic value of a specific form of informal care, informing policies around affordable housing for multi-generational families and childcare subsidies. The proposed instrument is novel but may be weak or violate the exclusion restriction if grandparent migration is correlated with unobserved economic opportunities for the entire family.

**Key references**
• Ruiz, N. G., & Vivas, A. (2018). *The role of grandparents in the labor supply of mothers of young children*. IZA Journal of Labor Policy, 8(1), 1-21.
• Compton, J., & Pollak, R. A. (2014). *Family Proximity, Childcare, and Women's Labor Force Attachment*. Journal of Urban Economics, 79, 72-90.

-----

## HYPOTHESIS\_TITLE: Broadband Access as a Catalyst for Rural Self-Employment *(BUCKET: Serious)*

**Abstract (≤ 60 words)**
In non-metropolitan counties, higher rates of household broadband internet subscription are causally linked to a subsequent increase in the rate of self-employment and the amount of non-farm self-employment income reported. The effect is hypothesized to be largest for female entrepreneurs and in counties that previously had high levels of unemployment, suggesting broadband acts as an economic lifeline.

**Structured specification**

```json
{
"novelty_rating": "medium",
"feasibility_rating": "high",
"complexity_rating": "medium",
"whimsy_rating": "low",
"geographic_level": "county",
"primary_metrics": ["self-employment rate", "mean self-employment income"],
"proposed_method": "cross-lagged panel model",
"robustness_checks": ["controlling for industry mix", "using alternative ACS broadband metrics", "examining different demographic subgroups"],
"expected_runtime": "1–4 hr",
"ethical_flags": []
}
```

**Narrative plan**

1.  **Data sources** – The study will use a panel of counties over several years using **ACS 1-Year Estimates** (for larger counties) and **ACS 5-Year Estimates** (for smaller/rural counties).

      * `S2801` (Types of Computers and Internet Subscriptions): Primary independent variable (household broadband subscription rate).
      * `DP03` (Selected Economic Characteristics): Outcome variable (Class of Worker section for self-employment rate).
      * `B19302` (Mean Self-Employment Income).
      * **PEP** `pep/population` for population controls.

2.  **Methodology** – A cross-lagged panel model will be used to assess the reciprocal relationship between broadband adoption and self-employment over time. We will model self-employment at time `t` as a function of broadband penetration at time `t-1`, while also modeling broadband at `t` as a function of self-employment at `t-1`. This helps untangle the direction of causality while controlling for county-level fixed effects.

3.  **Why it matters / what could go wrong** – Results could provide strong evidence for the ROI of public investment in rural broadband infrastructure as a tool for economic development and entrepreneurship. The main methodological challenge is that both broadband adoption and entrepreneurship could be driven by a third factor, like a latent "pro-growth" orientation in a county. The fixed-effects panel structure helps, but cannot eliminate this entirely.

**Key references**
• Kolko, J. (2012). *Broadband and local growth*. Journal of Urban Economics, 71(1), 100-113.
• De-Wit, G., & van Winden, W. (2009). *The economic impact of broadband access in rural areas: a review of the literature*. Agribusiness, 25(4), 523-535.

-----

## HYPOTHESIS\_TITLE: The Geography of Disconnected Youth *(BUCKET: Serious)*

**Abstract (≤ 60 words)**
The prevalence of "disconnected youth"—individuals aged 16-19 neither enrolled in school nor in the labor force—is spatially concentrated in census tracts characterized by high housing cost burdens, low rates of adult educational attainment, and a high proportion of single-parent households. The increase in youth disconnection from 2010 to 2020 is greatest in post-industrial "rust belt" metros.

**Structured specification**

```json
{
"novelty_rating": "low",
"feasibility_rating": "high",
"complexity_rating": "low",
"whimsy_rating": "low",
"geographic_level": "tract",
"primary_metrics": ["percent disconnected youth", "Gini coefficient of youth disconnection"],
"proposed_method": "geographically weighted regression (GWR)",
"robustness_checks": ["spatial autocorrelation tests (Moran's I)", "controlling for state-level policy changes", "using PUMAs as an alternative geography"],
"expected_runtime": "4–12 hr",
"ethical_flags": ["stigmatization of neighborhoods"]
}
```

**Narrative plan**

1.  **Data sources** – Data is drawn from the **2010 Decennial Census (SF1)** and **2020 Decennial Census (P1)** for population counts, and the **ACS 5-Year Estimates** for social and economic characteristics.

      * `B14005` (Sex by School Enrollment by Educational Attainment by Employment Status for the Population 16 to 19 Years): The core table for identifying disconnected youth.
      * `DP02`, `DP03`, `DP04`: To source independent variables like family structure, housing burden, and adult educational attainment.

2.  **Methodology** – The primary method will be Geographically Weighted Regression (GWR). Unlike a global OLS model that produces one coefficient for the entire study area, GWR allows the relationships between disconnection and its predictors to vary over space. This can identify "hotspots" where, for example, housing costs are a particularly strong predictor of youth disconnection, yielding localized policy insights.

3.  **Why it matters / what could go wrong** – Identifying the specific community-level factors associated with youth disconnection allows for targeted interventions. A GWR model is descriptive, not causal. The results show where relationships are strongest, but not necessarily why. It's crucial to avoid interpreting the GWR coefficients as causal effects. Furthermore, the results could be used to stigmatize certain neighborhoods.

**Key references**
• Burd-Sharps, S., & Lewis, K. (2018). *A Portrait of Disconnected Youth in America*. Measure of America.
• Fotheringham, A. S., Brunsdon, C., & Charlton, M. (2002). *Geographically Weighted Regression: The Analysis of Spatially Varying Relationships*. John Wiley & Sons.

-----

## HYPOTHESIS\_TITLE: Linguistic Isolation and Economic Integration *(BUCKET: Serious)*

**Abstract (≤ 60 words)**
An increase in the concentration of linguistically isolated households within a Public Use Microdata Area (PUMA) is associated with lower labor force participation and lower median earnings for the foreign-born population in that PUMA. This effect persists even after controlling for country of origin and years in the U.S., suggesting neighborhood-level language context is an independent factor in economic integration.

**Structured specification**

```json
{
"novelty_rating": "medium",
"feasibility_rating": "medium",
"complexity_rating": "high",
"whimsy_rating": "low",
"geographic_level": "PUMA",
"primary_metrics": ["labor force participation rate (foreign-born)", "median earnings (foreign-born)", "linguistic isolation rate"],
"proposed_method": "instrumental variable using historical settlement patterns",
"robustness_checks": ["controlling for PUMA-level industry mix", "using 5-year lags", "separating by world region of birth"],
"expected_runtime": "4–12 hr",
"ethical_flags": []
}
```

**Narrative plan**

1.  **Data sources** – The analysis will use **ACS 1-Year PUMS (Public Use Microdata Sample)** data to allow for detailed individual-level controls, aggregated to the PUMA level.

      * `PUMS Housing Record`: Variables for linguistic isolation (`HHL`).
      * `PUMS Person Record`: Variables for labor force status (`ESR`), earnings (`PERNP`), nativity (`NATIVITY`), language spoken (`LANX`), and other controls.

2.  **Methodology** – The core challenge is that immigrants with lower earnings potential may choose to live in linguistically isolated enclaves for social support. To address this self-selection, we will use an instrumental variable approach based on historical settlement patterns (a "shift-share" instrument). The instrument will predict the size of a linguistic group in a PUMA today based on historical settlement patterns from decades prior (e.g., 1980 Census) and recent national-level immigration flows for that group, purging the measure of local economic pull factors.

3.  **Why it matters / what could go wrong** – The results could inform language access policies and workforce development programs by showing whether neighborhood context has an independent effect on immigrant economic outcomes. The validity of the shift-share instrument rests on the assumption that historical settlement patterns are not correlated with recent, unobserved economic shocks in specific PUMAs, which may be a strong assumption.

**Key references**
• Card, D. (2001). *Immigrant Inflows, Native Outflows, and the Local Labor Market Impacts of Immigration*. Journal of Labor Economics, 19(1), 22-64.
• Bartel, A. P. (1989). *Where Do the New U.S. Immigrants Live?*. Journal of Labor Economics, 7(4), 371-391.

-----

## HYPOTHESIS\_TITLE: The Housing Stock Age Penalty on Millennial Retention *(BUCKET: Serious)*

**Abstract (≤ 60 words)**
Metropolitan areas where the housing stock is disproportionately old (i.e., a high percentage of units built before 1970) and dominated by single-family homes experience higher net out-migration of adults aged 25-34. This "age penalty" reflects a mismatch between the housing preferences and financial capacity of younger cohorts and the available, aging housing inventory.

**Structured specification**

```json
{
"novelty_rating": "medium",
"feasibility_rating": "high",
"complexity_rating": "medium",
"whimsy_rating": "low",
"geographic_level": "metro",
"primary_metrics": ["net migration rate (age 25-34)", "median year structure built", "percent single-family detached units"],
"proposed_method": "panel regression with metro fixed effects",
"robustness_checks": ["controlling for local wage growth", "using alternative age cohorts", "weighting by population"],
"expected_runtime": "1–4 hr",
"ethical_flags": []
}
```

**Narrative plan**

1.  **Data sources** – This study combines three main sources:

      * **ACS Migration Flows**: Provides metro-to-metro migration flows, which can be used to calculate net migration for specific age groups.
      * **ACS 5-Year Estimates**: Table `DP04` (Selected Housing Characteristics) provides data on "Year Structure Built" and "Units in Structure" for each metro area.
      * **ACS 1-Year Estimates**: Table `B07001` (Geographical Mobility in the Past Year) provides an alternative source for migration data.

2.  **Methodology** – We will use a panel regression model with metro area fixed effects, covering a period of several years (e.g., 2010-2022). The dependent variable will be the net migration rate for 25-34 year olds. The key independent variables are the median year the housing stock was built and the percentage of single-family homes. The fixed effects control for time-invariant metro characteristics (e.g., climate, culture), isolating the effect of the evolving housing stock.

3.  **Why it matters / what could go wrong** – This research highlights a critical, under-examined factor in talent attraction and retention: the physical structure of the housing market. A major challenge is that older housing stock might be correlated with other undesirable features (e.g., aging infrastructure, declining industries) that are the true cause of out-migration. Including controls for local economic conditions (e.g., unemployment, wage growth) is essential.

**Key references**
• Gyourko, J., Mayer, C., & Sinai, T. (2013). *Superstar Cities*. American Economic Journal: Economic Policy, 5(4), 167-99.
• Hsieh, C. T., & Moretti, E. (2019). *Housing Constraints and Spatial Misallocation*. American Economic Journal: Macroeconomics, 11(2), 1-39.

-----

## HYPOTHESIS\_TITLE: Post-2020 International Migration and State-Level Demographic Resilience *(BUCKET: Serious)*

**Abstract (≤ 60 words)**
Following the sharp decline in international migration during the pandemic, states with historically high reliance on immigration for population growth experienced a more severe "demographic recession" (i.e., slower overall growth and faster population aging) than states where growth was primarily driven by domestic migration or natural increase. This reveals vulnerabilities in state growth models.

**Structured specification**

```json
{
"novelty_rating": "low",
"feasibility_rating": "high",
"complexity_rating": "low",
"whimsy_rating": "low",
"geographic_level": "state",
"primary_metrics": ["total population change", "change in median age", "net international migration"],
"proposed_method": "comparative case study with shift-share decomposition",
"robustness_checks": ["correlation analysis with ACS data", "examining different time windows", "controlling for economic shocks"],
"expected_runtime": "<1 hr",
"ethical_flags": []
}
```

**Narrative plan**

1.  **Data sources** – The analysis relies principally on the **Population Estimates Program (PEP)**.

      * `pep/components`: Provides annual state-level data on the components of population change: births, deaths, net international migration, and net domestic migration.
      * `pep/population`: Provides total population estimates.
      * **ACS 1-Year Estimates**: Table `DP05` to track changes in median age.

2.  **Methodology** – The approach is a descriptive analysis and decomposition. First, we will classify states based on the pre-2020 composition of their population growth (e.g., "high international migration," "high domestic migration," "natural increase driven"). Second, we will compare the post-2020 trajectory of these state groups on metrics like total growth and median age. A simple shift-share analysis can decompose how much of the growth slowdown is attributable to the international migration component versus other factors.

3.  **Why it matters / what could go wrong** – The research demonstrates the role of federal immigration policy and global travel conditions as a key variable in state-level demographic and economic health. The analysis is correlational, not causal. It doesn't explain *why* international migration fell, but rather documents the consequences for states with different growth profiles. Confounding factors like state-specific COVID-19 economic impacts must be acknowledged.

**Key references**
• Frey, W. H. (2020). *Diversity Explosion: How New Racial Demographics are Remaking America*. Brookings Institution Press.
• Johnson, K. M. (2022). *US population growth has slowed to a crawl, new census data show*. Carsey School of Public Policy Publications.

-----

## HYPOTHESIS\_TITLE: The Commuting Cost of Sprawl: Polycentricity and Travel Times *(BUCKET: Serious)*

**Abstract (≤ 60 words)**
In sprawling metropolitan areas with multiple employment subcenters, average commute times have not decreased and may have increased over the last decade. This contradicts the theory that polycentricity shortens commutes. We hypothesize that residential settlement patterns have not kept pace with job decentralization, leading to complex, cross-cutting commutes that negate the benefits of employment subcenters.

**Structured specification**

```json
{
"novelty_rating": "medium",
"feasibility_rating": "medium",
"complexity_rating": "high",
"whimsy_rating": "low",
"geographic_level": "PUMA",
"primary_metrics": ["mean travel time to work", "number of employment centers"],
"proposed_method": "spatial regression with geographically defined employment centers",
"robustness_checks": ["alternative definitions of employment centers", "analysis by transportation mode", "controlling for residential sorting"],
"expected_runtime": "4–12 hr",
"ethical_flags": []
}
```

**Narrative plan**

1.  **Data sources** – The study will require detailed sub-metro data.

      * **ACS 5-Year Estimates**: Table `B08303` (Travel Time to Work) and `B08006` (Sex of Workers by Place of Work) at the tract level. Place of Work data is essential for identifying employment centers.
      * **TIGER/Line Shapefiles**: To define the geographic relationships between residential tracts and employment center tracts.

2.  **Methodology** – First, we will use a standard algorithm (e.g., defining tracts with job densities above a certain threshold) to identify primary and secondary employment centers within each metro for two time periods (e.g., 2010 and 2020). Second, we will model the change in mean commute time at the residential tract level as a function of its distance to the nearest center, the number of centers, and changes in local housing and population characteristics.

3.  **Why it matters / what could go wrong** – The findings challenge a core tenet of urban planning—that creating jobs subcenters reduces commute times and congestion. It suggests that land use and transportation planning must be more tightly integrated. A major challenge is accurately identifying employment centers using Census data alone. The definition is subjective and can influence the results. Reverse causality is also a risk: long commutes might encourage firms to create subcenters.

**Key references**
• Giuliano, G., & Small, K. A. (1991). *Subcenters in the Los Angeles region*. Regional Science and Urban Economics, 21(2), 163-182.
• Glaeser, E. L., & Kahn, M. E. (2004). *Sprawl and urban growth*. In *Handbook of regional and urban economics* (Vol. 4, pp. 2481-2527). Elsevier.

-----

## HYPOTHESIS\_TITLE: The 'Missing Middle' Housing Deficit and Generational Economic Outcomes *(BUCKET: Serious)*

**Abstract (≤ 60 words)**
Young adults (25-34) living in Public Use Microdata Areas (PUMAs) with a low proportion of "missing middle" housing (i.e., 2-19 unit structures) relative to single-family homes and large apartment buildings exhibit lower rates of household formation, lower median incomes, and higher housing cost burdens, even after controlling for local labor market conditions.

**Structured specification**

```json
{
"novelty_rating": "medium",
"feasibility_rating": "high",
"complexity_rating": "medium",
"whimsy_rating": "low",
"geographic_level": "PUMA",
"primary_metrics": ["ratio of 2-19 unit structures to all housing", "household formation rate (age 25-34)", "median income (age 25-34)"],
"proposed_method": "regression with instrumental variable",
"robustness_checks": ["spatial fixed effects", "controlling for population density", "testing alternative definitions of 'missing middle'"],
"expected_runtime": "1–4 hr",
"ethical_flags": []
}
```

**Narrative plan**

1.  **Data sources** – The analysis will use **ACS 5-Year Estimates** at the PUMA level.

      * `B25024` (Units in Structure): The key independent variable to construct the "missing middle" ratio.
      * `B11007` (Household Type by Age of Householder): To calculate household formation rates for the target age group.
      * `B19025` (Age of Householder by Household Income): To measure economic outcomes.
      * `DP03` and `DP04`: For control variables like unemployment rate and overall median home value.

2.  **Methodology** – The core analysis is a regression model. However, the housing stock composition is not random. To approach causality, we can use a historical instrument: the share of housing built between 1940 and 1980, a period when "missing middle" housing was more common. This historical building pattern is less likely to be correlated with recent economic shocks affecting young adults, but still predicts the current housing mix.

3.  **Why it matters / what could go wrong** – This provides empirical evidence for the "missing middle" housing debate, linking specific housing typologies to the economic well-being of the next generation of workers. The instrument could be weak or invalid if older housing stock is systematically located in areas that are now economically declining for other reasons. The definition of "missing middle" itself is also debatable.

**Key references**
• Parolek, D. (2020). *Missing Middle Housing: Thinking Big and Building Small to Respond to Today's Housing Crisis*. Island Press.
• Anacker, K. B., & Niedt, C. (Eds.). (2021). *The Routledge Handbook of Housing Policy and Planning*. Routledge.

-----

## HYPOTHESIS\_TITLE: The Entropy of Commuting: A Proxy for Urban Resilience? *(BUCKET: Exploratory)*

**Abstract (≤ 60 words)**
We propose that the Shannon entropy of "Means of Transportation to Work" at the metropolitan level serves as a novel index of urban transportation resilience. We hypothesize that metros with higher commute-mode entropy (i.e., more balanced usage across many modes) experienced smaller increases in average travel times following major disruptions like the COVID-19 pandemic.

**Structured specification**

```json
{
"novelty_rating": "high",
"feasibility_rating": "high",
"complexity_rating": "medium",
"whimsy_rating": "medium",
"geographic_level": "metro",
"primary_metrics": ["Shannon entropy of commute modes", "change in mean travel time"],
"proposed_method": "event study / difference-in-differences",
"robustness_checks": ["using Theil's Index as an alternative diversity measure", "controlling for work-from-home rates", "testing on pre-pandemic years as placebo"],
"expected_runtime": "1–4 hr",
"ethical_flags": []
}
```

**Narrative plan**

1.  **Data sources** – The analysis will use **ACS 1-Year Estimates** for a panel of large metro areas.

      * `B08301` (Means of Transportation to Work): The core table to calculate the Shannon entropy for each metro-year. The formula is $H = -\\sum\_{i=1}^{n} p\_i \\log\_2(p\_i)$, where $p\_i$ is the proportion of commuters using mode $i$.
      * `B08303` (Travel Time to Work): The primary outcome variable.
      * `DP03`: To control for changes in the labor force, such as the rise of remote work.

2.  **Methodology** – An event study framework will examine changes in travel time around the 2020 disruption. We will compare metros with high pre-pandemic commute entropy ("resilient") to those with low entropy (e.g., \>90% drive-alone, "brittle"). The hypothesis is that the "resilient" group shows a less severe spike in commute times (or a faster recovery) as travel patterns shifted.

3.  **Why it matters / what could go wrong** – This research introduces a new, easily calculable metric for policymakers to assess the resilience of their transportation systems. A more diverse system is less vulnerable to shocks affecting a single mode (e.g., gas price spikes, transit shutdowns). The primary weakness is that entropy is a summary measure; it doesn't capture the quality or capacity of the different modes. High entropy could simply mean many people are using inefficient modes.

**Key references**
• Shannon, C. E. (1948). *A Mathematical Theory of Communication*. Bell System Technical Journal, 27(3), 379-423.
• Batty, M. (2013). *The New Science of Cities*. MIT Press.

-----

## HYPOTHESIS\_TITLE: A Linguistic Gravity Model of Domestic Migration *(BUCKET: Exploratory)*

**Abstract (≤ 60 words)**
For the foreign-born population, domestic migration flows between U.S. counties are better predicted by a "linguistic gravity" model than a standard gravity model. The attractive force between two counties is a function of not only population size and distance, but also the population share speaking the same non-English language, especially for recent movers.

**Structured specification**

```json
{
"novelty_rating": "high",
"feasibility_rating": "medium",
"complexity_rating": "high",
"whimsy_rating": "medium",
"geographic_level": "county",
"primary_metrics": ["county-to-county migration flow", "Jaccard similarity of language profiles"],
"proposed_method": "gravity model of migration (Poisson pseudo-maximum likelihood)",
"robustness_checks": ["separating by language group", "controlling for interstate distances", "using metro areas instead of counties"],
"expected_runtime": ">12 hr",
"ethical_flags": []
}
```

**Narrative plan**

1.  **Data sources** – This requires merging two large datasets.

      * **ACS Migration Flows**: The 5-year county-to-county migration flow table is the dependent variable. This is a very large dataset.
      * **ACS 5-Year Estimates**: Table `B16001` (Language Spoken at Home) for every county. This will be used to calculate the linguistic similarity between county pairs.

2.  **Methodology** – We will estimate a gravity model using Poisson pseudo-maximum likelihood (PPML), which is standard for flow data with many zeros. The model will be:
    $Flow\_{ij} = \\exp(\\beta\_0 + \\beta\_1\\ln(Pop\_i) + \\beta\_2\\ln(Pop\_j) + \\beta\_3\\ln(Dist\_{ij}) + \\beta\_4\\ln(LingSim\_{ij}) + \\epsilon\_{ij})$
    where `LingSim` is a measure of linguistic similarity (e.g., 1 minus the Jensen-Shannon divergence of the language distributions). We will compare the model fit with and without the linguistic term.

3.  **Why it matters / what could go wrong** – This refines our understanding of migrant decision-making, showing that cultural/linguistic networks can be as important as economic "pull" factors. The computational burden is the biggest challenge; a full county-to-county matrix is \~3000x3000. The analysis may need to be restricted to larger counties or sampled pairs. Defining "linguistic similarity" is also a key theoretical choice.

**Key references**
• Anderson, J. E. (2011). *The Gravity Model*. Annual Review of Economics, 3(1), 133-160.
• Santos Silva, J. M. C., & Tenreyro, S. (2006). *The Log of Gravity*. The Review of Economics and Statistics, 88(4), 641-658.

-----

## HYPOTHESIS\_TITLE: The "Ghost Kitchen" Signal: Using Food Service Occupation Spikes to Predict Retail Shifts *(BUCKET: Exploratory)*

**Abstract (≤ 60 words)**
A sudden, statistically significant increase in the population of "Cooks" and "Food Preparation and Serving Related Workers" in a PUMA, when not accompanied by a corresponding increase in traditional restaurant establishments (proxied by workers commuting to a workplace), signals the growth of "ghost kitchens" and a shift in the local food economy towards delivery platforms.

**Structured specification**

```json
{
"novelty_rating": "high",
"feasibility_rating": "medium",
"complexity_rating": "high",
"whimsy_rating": "high",
"geographic_level": "PUMA",
"primary_metrics": ["number of cooks", "number of food delivery workers", "work-from-home rate"],
"proposed_method": "time series anomaly detection",
"robustness_checks": ["controlling for overall employment growth", "comparing with data on commercial vacancies (if possible)", "text analysis of business names (not possible with Census)"],
"expected_runtime": "4–12 hr",
"ethical_flags": []
}
```

**Narrative plan**

1.  **Data sources** – The analysis requires granular occupation and employment data from the **ACS 1-Year PUMS data**, aggregated to the PUMA level for time-series analysis.

      * `PUMS Person Record`: Occupation codes (`OCCP`) to identify cooks, food prep workers, and delivery drivers. `POWSP` (Place of Work State PUMA) and `PUMA` (Residence PUMA) to analyze commuting patterns. `WKW` (Work at home) to proxy for non-traditional work arrangements.

2.  **Methodology** – For each PUMA, we will create a time series of the relevant occupation counts from 2010 to present. We will use an anomaly detection algorithm (e.g., Seasonal Hybrid ESD) to identify PUMAs that show a significant, positive deviation from the expected trend in food service workers. We will then test if these anomalous spikes are correlated with an increase in the "work from home" rate for those same occupations, which would be consistent with a delivery-centric model.

3.  **Why it matters / what could go wrong** – This provides a novel, high-frequency indicator of changes in the urban retail landscape that are often invisible to traditional economic surveys. The signal could be very noisy. An increase in cooks could also be driven by catering businesses or institutional food service (hospitals, schools). The key assumption is that a significant portion of "ghost kitchen" workers would be classified in a way that is detectable and distinct in ACS data.

**Key references**
• Kireyeva, A., & van der Zee, R. (2021). *The rise of ghost kitchens: a review of the literature and future research directions*. International Journal of Contemporary Hospitality Management.
• Hyndman, R. J., & Athanasopoulos, G. (2018). *Forecasting: principles and practice*. OTexts.

-----

## HYPOTHESIS\_TITLE: Spatial Polarization of Work: A Widening Occupational Divide *(BUCKET: Exploratory)*

**Abstract (≤ 60 words)**
The geographic segregation of occupations has intensified over the past decade. Using a dissimilarity index, we hypothesize that "symbolic-analytic" professional jobs have become more concentrated in high-cost urban PUMAs, while "routine production" and "in-person service" jobs have become disproportionately concentrated in lower-cost suburban and exurban PUMAs, leading to increased spatial mismatch.

**Structured specification**

```json
{
"novelty_rating": "medium",
"feasibility_rating": "high",
"complexity_rating": "medium",
"whimsy_rating": "low",
"geographic_level": "PUMA",
"primary_metrics": ["dissimilarity index", "location quotient"],
"proposed_method": "calculation of segregation indices over time",
"robustness_checks": ["using different occupational classification schemes", "testing at the tract level for select metros", "controlling for industrial structure"],
"expected_runtime": "4–12 hr",
"ethical_flags": []
}
```

**Narrative plan**

1.  **Data sources** – The study will use **ACS 5-Year Estimates** to compare two time periods (e.g., 2011-2015 vs 2018-2022).

      * `C24010` (Sex by Occupation for the Civilian Employed Population): The primary data table, providing counts for detailed occupations at the PUMA level.
      * `DP04`: To get median home value and rent as a proxy for PUMA cost level.

2.  **Methodology** – First, occupations will be grouped into broad categories (e.g., following Reich's "symbolic analysts," "routine production," "in-person services"). Second, for each metro area, we will calculate the Index of Dissimilarity ($D$) between pairs of these occupational groups across the constituent PUMAs. We will then test whether $D$ has systematically increased over time, particularly the segregation between high-skill professional and other work.

3.  **Why it matters / what could go wrong** – Documenting this spatial polarization is key to understanding growing inequality, residential segregation, and political polarization. The choice of occupational categories is subjective and can drive the results. Additionally, this analysis describes a pattern but doesn't explain the cause, which could be a combination of firm location choices, residential preferences, and housing costs.

**Key references**
• Reich, R. B. (1991). *The Work of Nations*. Alfred A. Knopf.
• Massey, D. S., & Denton, N. A. (1988). *The Dimensions of Residential Segregation*. Social Forces, 67(2), 281-315.

-----

## HYPOTHESIS\_TITLE: Synthetic School Quality Index from Housing Value Premiums *(BUCKET: Exploratory)*

**Abstract (≤ 60 words)**
A "synthetic school quality" index can be derived for each census tract by modeling the premium on median home values for households with school-aged children versus those without, after controlling for detailed housing and demographic characteristics. This Census-derived index will strongly correlate with, and can serve as a proxy for, external measures of school performance.

**Structured specification**

```json
{
"novelty_rating": "high",
"feasibility_rating": "medium",
"complexity_rating": "high",
"whimsy_rating": "low",
"geographic_level": "tract",
"primary_metrics": ["hedonic housing price premium", "synthetic quality score"],
"proposed_method": "hedonic regression modeling",
"robustness_checks": ["comparison with external (non-Census) school data if available for validation", "using different model specifications", "spatial filtering to account for spillover effects"],
"expected_runtime": ">12 hr",
"ethical_flags": ["could create self-fulfilling prophecies in real estate markets"]
}
```

**Narrative plan**

1.  **Data sources** – This requires detailed, cross-tabulated data from the **ACS 5-Year Estimates**, likely requiring custom table requests or PUMS analysis.

      * `B25081` (Median Value by Presence and Age of Own Children): Provides the core data on home values for households with/without children.
      * `DP04`, `DP02`: Tables needed to source a rich set of control variables about the housing stock (age, size) and neighborhood demographics.

2.  **Methodology** – We will employ a hedonic pricing model at the tract level. The model will regress median home value on a dummy variable for "presence of school-aged children" and a host of control variables (e.g., median rooms, median year built, population density, racial composition). The coefficient on the "children present" variable is interpreted as the capitalized price of perceived school quality for that tract. These coefficients become the synthetic index.

3.  **Why it matters / what could go wrong** – This could create a powerful, nationally consistent, small-area proxy for school quality, which is notoriously difficult to measure and compare. The main assumption is that we can adequately control for all other factors that might make a neighborhood attractive to families with children (e.g., parks, safety), which is very difficult with Census data alone. Omitted variable bias is the primary risk.

**Key references**
• Black, S. E. (1999). *Do Better Schools Matter? Parental Valuation of Elementary Education*. The Quarterly Journal of Economics, 114(2), 577-599.
• Gibbons, S., & Machin, S. (2008). *Valuing school quality, better transport, and lower crime: evidence from house prices*. Oxford Review of Economic Policy, 24(1), 99-119.

-----

## HYPOTHESIS\_TITLE: Information Theoretic Decay: Quantifying Data Loss in Geographic Aggregation *(BUCKET: Exploratory)*

**Abstract (≤ 60 words)**
The process of aggregating demographic data from the block group to the census tract, and then to the county level, results in a quantifiable and spatially variable loss of information about racial and ethnic diversity. We hypothesize that this information loss, measured by the Kullback-Leibler (KL) divergence, is greatest in highly-segregated metropolitan areas.

**Structured specification**
{
"novelty\_rating": "high",
"feasibility\_rating": "high",
"complexity\_rating": "high",
"whimsy\_rating": "medium",
"geographic\_level": "block group / tract / county",
"primary\_metrics": ["Kullback-Leibler divergence", "Shannon entropy"],
"proposed\_method": "information theory calculations and spatial analysis",
"robustness\_checks": ["using Theil's H as an alternative measure", "testing on different variables (e.g., income, tenure)", "comparing metros of different sizes"],
"expected\_runtime": "4–12 hr",
"ethical\_flags": []
}

````

**Narrative plan**

1.  **Data sources** – The analysis will use racial and ethnic composition data from the **2020 Decennial Census PL-94-171 Redistricting Data Files**.
    * Table `P1` or `P2`: Provides race/ethnicity counts at the block group, tract, and county levels.

2.  **Methodology** – For each county, we will perform the following calculation:
    1.  Define the racial distribution $P$ at the county level (e.g., {% White, % Black, % Asian, etc.}).
    2.  For each tract $i$ within that county, define its racial distribution $Q_i$.
    3.  Calculate the KL divergence from the county distribution to the tract distribution: $D_{KL}(Q_i || P)$.
    4.  The total information loss for that county is the population-weighted average of these tract-level divergences.
    We will then test if this county-level "information loss" score is correlated with standard segregation measures like the Index of Dissimilarity.

3.  **Why it matters / what could go wrong** – This provides a novel, theoretically grounded way to measure segregation and the impact of the Modifiable Areal Unit Problem (MAUP). It gives researchers a concrete number for how much detail is lost when using larger geographies. The interpretation can be tricky; high information loss means the county average is a poor representation of its parts, which is the definition of a segregated/heterogeneous area. It's more of a new measurement technique than a causal test.

**Key references**
• Kullback, S., & Leibler, R. A. (1951). *On Information and Sufficiency*. The Annals of Mathematical Statistics, 22(1), 79-86.
• Reardon, S. F., & O'Sullivan, D. (2004). *Measures of Spatial Segregation*. Sociological Methodology, 34(1), 121-162.

---

## HYPOTHESIS_TITLE: The "Empty Nester" Housing Inefficiency Index *(BUCKET: Exploratory)*

**Abstract (≤ 60 words)**
We can construct an "Empty Nester Housing Inefficiency" index at the PUMA level by measuring the proportion of households led by persons aged 60+ with no children present who live in homes with 4 or more bedrooms. We hypothesize this index is highest in post-war, auto-oriented suburbs and is negatively correlated with new housing construction.

**Structured specification**
```json
{
"novelty_rating": "medium",
"feasibility_rating": "high",
"complexity_rating": "medium",
"whimsy_rating": "medium",
"geographic_level": "PUMA",
"primary_metrics": ["percent of 60+ householders in 4+ bedroom homes", "housing under-utilization rate"],
"proposed_method": "spatial correlation analysis",
"robustness_checks": ["controlling for PUMA-level median income", "examining different age cutoffs for 'empty nester'", "comparing owners vs. renters"],
"expected_runtime": "1–4 hr",
"ethical_flags": ["potential for ageist interpretations"]
}
````

**Narrative plan**

1.  **Data sources** – The analysis will primarily use cross-tabulated data from the **ACS 5-Year Estimates** at the PUMA level.

      * `B25009` (Tenure by Household Size by Age of Householder): Can be used to identify older householders in potentially oversized homes.
      * `B25041` (Bedrooms by Tenure): Provides data on number of bedrooms. A custom cross-tabulation of this with `B25009` would be ideal.
      * `B25005` (Median Number of Rooms).
      * `DP04`: To get data on new housing units (`UNITS IN STRUCTURE` by `YEAR STRUCTURE BUILT`).

2.  **Methodology** – The core of the study is the creation and mapping of the index. For each PUMA, we will calculate: (Number of householders 60+ in 4+ bedroom units) / (Total number of householders 60+). We will then use spatial regression to test the correlation of this index with variables like the median year the housing stock was built, population density, and the rate of new housing unit construction in the PUMA.

3.  **Why it matters / what could go wrong** – This index provides a tangible measure of housing stock "mismatch" or "under-utilization," a critical component of housing affordability debates. It can highlight areas where policies encouraging downsizing or accessory dwelling units (ADUs) might be most effective. The key weakness is inferring "inefficiency." Older residents may use extra rooms for hobbies, offices, or visiting family, and choosing to remain is a valid preference, not necessarily an inefficiency.

**Key references**
• Myers, D., & Ryu, S. (2008). *Aging Baby Boomers and the Generational Housing Bubble: Foresight and Mitigation of an Epic Transition*. Journal of the American Planning Association, 74(1), 17-33.
• Belsky, E. S., & Duda, M. (2011). *The changing landscape of the US housing market*. In *The US housing crisis: lessons learned* (pp. 58-86). University of Pennsylvania Press.

-----

## HYPOTHESIS\_TITLE: Generational Housing Mismatch and Youth Out-Migration *(BUCKET: Exploratory)*

**Abstract (≤ 60 words)**
Public Use Microdata Areas (PUMAs) with a high ratio of large, owner-occupied homes (proxy for Boomer housing) to smaller rental units (proxy for Millennial/Gen Z housing) experience significantly higher rates of net out-migration among young adults (25-34). This structural mismatch in the housing market effectively pushes younger generations to more affordable and suitable markets.

**Structured specification**

```json
{
"novelty_rating": "medium",
"feasibility_rating": "high",
"complexity_rating": "medium",
"whimsy_rating": "low",
"geographic_level": "PUMA",
"primary_metrics": ["ratio of large single-family homes to small rental units", "net migration rate (age 25-34)"],
"proposed_method": "spatial panel regression",
"robustness_checks": ["controlling for local job growth by industry", "using alternative definitions of housing types", "lagging the migration data by one year"],
"expected_runtime": "1–4 hr",
"ethical_flags": []
}
```

**Narrative plan**

1.  **Data sources** – The analysis combines migration data with housing stock characteristics.

      * **ACS Migration Flows**: Provides PUMA-to-PUMA migration flows, allowing for the calculation of net migration for the 25-34 age group.
      * **ACS 5-Year Estimates**: Table `B25024` (Units in Structure) and `B25033` (Tenure by Units in Structure) to create the housing mismatch ratio for each PUMA.
      * `DP03`: To source control variables like youth unemployment and median earnings.

2.  **Methodology** – A spatial panel regression model will be estimated using annual data for all PUMAs. The dependent variable is the net migration rate for young adults. The key independent variable is the housing mismatch ratio: `(Number of owner-occupied single-family units) / (Number of renter-occupied units in 2-19 unit structures)`. The model will include PUMA fixed effects and year fixed effects, as well as spatial lags to account for spillover effects from neighboring PUMAs.

3.  **Why it matters / what could go wrong** – This hypothesis provides a direct test of how the physical housing stock, not just prices, influences the geographic sorting of generations. It has direct implications for zoning reform and housing construction policy. A confounding factor is that PUMAs with lots of single-family homes may simply be less desirable to young adults for other reasons (e.g., lack of amenities, poor transit), and the housing stock is merely a symptom of this.

**Key references**
• Park, J. (2020). *Housing Mismatch and the Faltering Creation of Millennial Households*. Housing Policy Debate, 30(5), 793-813.
• Florida, R. (2002). *The Rise of the Creative Class*. Basic Books.

-----

## HYPOTHESIS\_TITLE: Reverse Causality Test: Does Upzoning Increase Neighborhood Turnover? *(BUCKET: Exploratory)*

**Abstract (≤ 60 words)**
Leveraging sharp tract boundaries as a quasi-experiment, we hypothesize that tracts that have been "upzoned" (inferred by a significant increase in the share of multi-unit housing) exhibit a subsequent decrease in median resident tenure and an increase in in-migration from within the same county, compared to adjacent, unchanged tracts.

**Structured specification**

```json
{
"novelty_rating": "high",
"feasibility_rating": "low",
"complexity_rating": "high",
"whimsy_rating": "low",
"geographic_level": "tract",
"primary_metrics": ["change in share of multi-unit structures", "median years in unit", "in-migration rate"],
"proposed_method": "regression discontinuity design (geographic)",
"robustness_checks": ["donut RDD", "testing for discontinuities in baseline covariates", "using different bandwidths around the boundary"],
"expected_runtime": ">12 hr",
"ethical_flags": ["results could be weaponized in zoning debates"]
}
```

**Narrative plan**

1.  **Data sources** – This requires precise, small-area data over time from **ACS 5-Year Estimates**.

      * `B25024` (Units in Structure): To identify the "treatment" – a significant shift towards multi-unit structures between two ACS 5-year periods.
      * `B25039` (Median Year Householder Moved into Unit): The primary outcome variable for tenure.
      * `B07001` (Geographical Mobility in the Past Year): To measure turnover.
      * **TIGER/Line Shapefiles**: Essential for identifying adjacent tracts.

2.  **Methodology** – This is a Geographic Regression Discontinuity Design (GeoRDD). We would first need to identify tract boundaries where on one side, there was a significant increase in multi-unit housing (the "treatment") and on the other side, there was not. We then compare the change in resident tenure for households located very close to this boundary. The assumption is that, within a small distance of the boundary, residents are otherwise similar, and the sharp change in housing stock is the only difference.

3.  **Why it matters / what could go wrong** – This would provide rare, causal evidence on the neighborhood-level impacts of new housing supply, a hotly debated topic. The feasibility is low because finding clean "treatment" boundaries that align perfectly with tract lines is difficult. Census data may not be granular enough to detect the zoning change, and other unobserved changes might occur at the same boundary, violating the RDD assumptions.

**Key references**
• Lalonde, R. (1986). *Evaluating the econometric evaluations of training programs with experimental data*. The American economic review, 604-620.
• Keele, L. J. (2015). *Geographic boundaries as regression discontinuities*. Political Analysis, 23(1), 127-153.

-----

## HYPOTHESIS\_TITLE: The Inter-Ethnic Fertility Differential *(BUCKET: Exploratory)*

**Abstract (≤ 60 words)**
Within specific racial categories (e.g., "Asian"), fertility rates vary significantly by detailed ethnic group (e.g., Korean, Vietnamese, Filipino). We hypothesize that these differentials are strongly predicted by the group's median age at first marriage and educational attainment for women, suggesting that socio-economic factors are stronger drivers of fertility than broad racial categorization.

**Structured specification**

```json
{
"novelty_rating": "medium",
"feasibility_rating": "medium",
"complexity_rating": "medium",
"whimsy_rating": "low",
"geographic_level": "national",
"primary_metrics": ["children ever born per 1,000 women", "median age at first marriage", "percent with bachelor's degree"],
"proposed_method": "regression analysis on group-level data",
"robustness_checks": ["controlling for nativity (foreign-born vs. native-born)", "examining different age cohorts of women", "using PUMS for individual-level modeling"],
"expected_runtime": "1–4 hr",
"ethical_flags": ["risk of stereotyping or oversimplification of complex cultural factors"]
}
```

**Narrative plan**

1.  **Data sources** – This analysis requires detailed demographic data, available at the national level from the **ACS 1-Year Estimates** or more robustly from the **ACS PUMS data**.

      * Table `B13002` (Women 15 to 50 Years Who Had a Birth in the Past 12 Months by Marital Status and Age), with detailed race/ethnicity iterations (e.g., `B13002D`, `B13002E`, etc.).
      * Table `S1201` (Marital Status) and `S1501` (Educational Attainment) for the same detailed groups.
      * The PUMS data (`FER` variable) would allow for more precise, individual-level analysis.

2.  **Methodology** – The simplest approach is a regression at the group level. The unit of observation is the detailed ethnic group (e.g., Chinese, Japanese, Hmong). The dependent variable is the fertility rate. The independent variables are the median age at first marriage, female educational attainment, and median household income for that group. This tests whether those variables explain the variation in fertility across groups.

3.  **Why it matters / what could go wrong** – This research deconstructs broad racial categories, highlighting the diversity of behaviors within them and emphasizing the role of socio-economic drivers over simplistic racial explanations. The primary risk is ecological fallacy—drawing inferences about individual behavior from group-level aggregates. An analysis using PUMS microdata would be superior to mitigate this.

**Key references**
• Becker, G. S. (1960). *An Economic Analysis of Fertility*. In *Demographic and Economic Change in Developed Countries* (pp. 209-240). Princeton University Press.
• Alba, R., & Nee, V. (2003). *Remaking the American Mainstream: Assimilation and Contemporary Immigration*. Harvard University Press.

-----

## HYPOTHESIS\_TITLE: The Longest Commutes to Nowhere: Arts Workers' Journey to Work *(BUCKET: Whimsical)*

**Abstract (≤ 60 words)**
The cohort with the highest proportion of "super commuters" (90+ minutes each way) is not high-finance executives, but rather workers in the "Arts, Design, Entertainment, Sports, and Media Occupations." We hypothesize this is due to a spatial mismatch between affordable artist housing/studios and the location of performance venues and cultural districts in high-cost cities.

**Structured specification**

```json
{
"novelty_rating": "high",
"feasibility_rating": "high",
"complexity_rating": "low",
"whimsy_rating": "high",
"geographic_level": "metro",
"primary_metrics": ["percent of workers with 90+ minute commute", "occupation code"],
"proposed_method": "descriptive statistics and correlation",
"robustness_checks": ["comparing across different metros", "examining sub-occupations (e.g., 'musicians' vs. 'designers')", "controlling for income"],
"expected_runtime": "<1 hr",
"ethical_flags": []
}
```

**Narrative plan**

1.  **Data sources** – The analysis requires a cross-tabulation of commute time and occupation from the **ACS 1-Year Estimates** at the metropolitan statistical area (MSA) level.

      * Table `S0804` (Means of Transportation to Work by Selected Characteristics) provides commute times by occupation group.
      * A more detailed analysis could be done with the **ACS PUMS** data, linking `OCCP` (Occupation), `JWMNP` (Travel time to work), and `POWPUMA` (Place of Work PUMA).

2.  **Methodology** – This is a straightforward descriptive analysis. For each major occupation group within a large MSA (e.g., New York, Los Angeles), we will calculate the percentage of workers who report a travel time to work of 90 minutes or more. The hypothesis is that the percentage for the "Arts..." category is the highest, or among the highest.

3.  **Why it matters / what could go wrong** – While whimsical, this highlights the precarious economic and geographic position of creative workers, a key part of the urban economy. It's a simple, data-driven story about affordability and spatial inequality. The finding could be spurious or explained by other factors (e.g., artists choosing to live in remote, rural areas for non-economic reasons). It's a correlation, not a causal statement.

**Key references**
• Currid, E. (2007). *The Warhol Economy: How Fashion, Art, and Music Drive New York City*. Princeton University Press.
• Markusen, A. (2006). *Urban development and the politics of a creative class: evidence from a study of artists*. Environment and Planning A, 38(10), 1921-1940.

-----

## HYPOTHESIS\_TITLE: The "Basement Dweller" Index: Geography of Young Adults Living with Parents *(BUCKET: Whimsical)*

**Abstract (≤ 60 words)**
The proportion of 25-34 year olds living in their parents' household (the "Basement Dweller" Index) is highest in high-cost coastal metropolitan areas. This index is more strongly correlated with local median rent than with the local youth unemployment rate, suggesting that housing affordability is a greater driver of this phenomenon than labor market weakness.

**Structured specification**

```json
{
"novelty_rating": "medium",
"feasibility_rating": "high",
"complexity_rating": "low",
"whimsy_rating": "high",
"geographic_level": "PUMA",
"primary_metrics": ["percent of 25-34 year olds living with parents", "median gross rent", "youth unemployment rate"],
"proposed_method": "correlation and multiple regression",
"robustness_checks": ["controlling for racial/ethnic composition", "examining males and females separately", "using home values as an alternative cost metric"],
"expected_runtime": "1–4 hr",
"ethical_flags": ["stigmatizing a living arrangement"]
}
```

**Narrative plan**

1.  **Data sources** – All data comes from **ACS 5-Year Estimates** at the Public Use Microdata Area (PUMA) level for geographic granularity.

      * Table `B11016` (Household Type by Age of Householder) can be used to identify householders living with relatives. A more direct measure comes from table `B09001` (Relationship to Householder for the Population Under 18 Years) - no, that's for children. The best source is `S1101` (Households and Families), which shows "child of householder" for various age groups.
      * `DP04`: Median Gross Rent.
      * `S2301`: Unemployment Rate for age 20-34.

2.  **Methodology** – For each PUMA, we will calculate the percentage of all residents aged 25-34 who are classified as "child of householder." We will then run a simple multiple regression model where this index is the dependent variable, and the key independent variables are median gross rent and the youth unemployment rate, plus controls like population density.

3.  **Why it matters / what could go wrong** – This provides a playful but insightful look into a major demographic trend, testing two competing popular explanations (jobs vs. rent). The results speak directly to the economic pressures facing young adults. A key issue is cultural variation; in some cultures, co-residence is more common irrespective of economic conditions. Controlling for the ethnic composition of the PUMA is therefore crucial.

**Key references**
• Fry, R. (2020). *A rising share of young adults are living with their parents*. Pew Research Center.
• Kaplan, G. (2012). *Moving Back Home: Insurance Against Labor Market Risk*. Journal of Political Economy, 120(3), 446-512.

-----

## HYPOTHESIS\_TITLE: The Bicycle Commuter's Paradox *(BUCKET: Whimsical)*

**Abstract (≤ 60 words)**
Census tracts with the highest rates of bicycle commuting also have rates of working-from-home that are significantly above the metropolitan average. This suggests that bike commuting is not just a mode of transport, but a cultural marker for neighborhoods populated by a professional class that also has the privilege of remote work flexibility.

**Structured specification**

```json
{
"novelty_rating": "high",
"feasibility_rating": "high",
"complexity_rating": "low",
"whimsy_rating": "high",
"geographic_level": "tract",
"primary_metrics": ["percent who bike to work", "percent who work from home"],
"proposed_method": "bivariate correlation and mapping",
"robustness_checks": ["controlling for median income and educational attainment", "looking at data from before and after 2020", "restricting analysis to urbanized areas"],
"expected_runtime": "1–4 hr",
"ethical_flags": []
}
```

**Narrative plan**

1.  **Data sources** – The analysis uses **ACS 5-Year Estimates** at the census tract level.

      * `B08301` (Means of Transportation to Work): This table provides counts for "Bicycle" and "Worked from home."

2.  **Methodology** – The methodology is simple. For all tracts within a set of large MSAs, we will calculate the percentage of workers who commute by bike and the percentage who work from home. We will then calculate the correlation coefficient between these two variables. We predict a positive and statistically significant correlation. Mapping the tracts that are high on both metrics would provide a powerful visualization.

3.  **Why it matters / what could go wrong** – This pokes fun at the idea of the "virtuous" bike commuter, suggesting it's intertwined with other forms of socio-economic privilege. It's a critique of how we interpret lifestyle choices, grounding it in census data. The correlation could be explained by an omitted variable: urban design. Neighborhoods with good bike lanes (encouraging bike commuting) may also be desirable places to live for professionals who can work from home.

**Key references**
• Florida, R. (2017). *The New Urban Crisis*. Basic Books.
• Buehler, R., & Pucher, J. (2012). *Cycling to work in 90 large American cities: new evidence on the role of bike paths and lanes*. Transportation, 39(2), 409-432.

-----

## HYPOTHESIS\_TITLE: The Monotony of Babel: Does Linguistic Diversity Predict Mover churn? *(BUCKET: Whimsical)*

**Abstract (≤ 60 words)**
Contrary to the idea that diversity attracts talent, counties with a higher number of distinct languages spoken (a "Babel Index") actually have a lower proportion of residents who moved from a different state in the last year. This suggests that extreme linguistic fragmentation, as opposed to simple diversity, may create social friction that deters domestic migrants.

**Structured specification**

```json
{
"novelty_rating": "high",
"feasibility_rating": "high",
"complexity_rating": "low",
"whimsy_rating": "medium",
"geographic_level": "county",
"primary_metrics": ["count of unique languages spoken", "percent of population who moved from another state"],
"proposed_method": "correlation analysis",
"robustness_checks": ["controlling for total population and foreign-born share", "using Shannon entropy of languages instead of a simple count", "weighting by population"],
"expected_runtime": "<1 hr",
"ethical_flags": []
}
```

**Narrative plan**

1.  **Data sources** – The study uses **ACS 5-Year Estimates** at the county level.

      * `B16001` (Language Spoken at Home): This table will be used to count the number of distinct languages reported in each county, creating the "Babel Index."
      * `B07001` (Geographical Mobility in the Past Year by Race for Current Residence in the United States): This table provides the number of residents who moved from a different state.

2.  **Methodology** – For every county, we will compute two metrics: the Babel Index (count of languages with at least one speaker) and the recent mover share (% of population from out-of-state). We will then run a regression of the mover share on the Babel Index, controlling for total population, the share of the population that is foreign-born, and median income. The hypothesis is a negative coefficient on the Babel Index.

3.  **Why it matters / what could go wrong** – This is a playful challenge to the "diversity is good for growth" narrative, suggesting the relationship might be non-linear. It forces a more nuanced look at what "diversity" means. The result is purely correlational. It's more likely that both extreme linguistic fragmentation and low in-migration are features of specific types of communities (e.g., established, low-growth immigrant enclaves) rather than one causing the other.

**Key references**
• Ottaviano, G. I., & Peri, G. (2006). *The economic value of cultural diversity: evidence from US cities*. Journal of Economic geography, 6(1), 9-44.
• Putnam, R. D. (2007). *E Pluribus Unum: Diversity and Community in the Twenty-first Century -- The 2006 Johan Skytte Prize Lecture*. Scandinavian Political Studies, 30(2), 137-174.

-----

## HYPOTHESIS\_TITLE: The Rise of the Plumber Barons *(BUCKET: Whimsical)*

**Abstract (≤ 60 words)**
In a reversal of 20th-century trends, the median personal income for workers in "Installation, Maintenance, and Repair Occupations" has grown faster over the last decade than income for "Business and Financial Operations Occupations" in a specific subset of rapidly gentrifying PUMAs. This reflects a premium on skilled manual labor in high-cost service economies.

**Structured specification**

```json
{
"novelty_rating": "medium",
"feasibility_rating": "high",
"complexity_rating": "medium",
"whimsy_rating": "medium",
"geographic_level": "PUMA",
"primary_metrics": ["percent change in median personal income by occupation"],
"proposed_method": "comparative descriptive analysis",
"robustness_checks": ["controlling for hours worked", "examining different time periods", "comparing against other occupation groups like 'tech' or 'legal'"],
"expected_runtime": "1–4 hr",
"ethical_flags": []
}
```

**Narrative plan**

1.  **Data sources** – The study compares two non-overlapping **ACS 5-Year Estimates** (e.g., 2010-2014 and 2018-2022) at the PUMA level.

      * Table `S2414` (Occupation by Sex and Median Earnings in the Past 12 Months) or `B24011` (Median Earnings by Occupation) provides the core income data for the specified occupation groups.
      * `DP04` will be used to identify "rapidly gentrifying" PUMAs based on the percent change in median home value.

2.  **Methodology** – First, we identify the top quartile of PUMAs by growth in median home value over the period. Then, within this subset of PUMAs, we calculate the percentage change in median earnings for the two occupational groups of interest. The hypothesis is that `Δ%Income_Plumbers > Δ%Income_Finance` in these specific geographic areas.

3.  **Why it matters / what could go wrong** – This is a fun, data-grounded way to explore shifts in the value of different kinds of labor in the modern economy, challenging assumptions about white-collar vs. blue-collar work. The finding might only apply to a very small and specific set of places. Furthermore, "Business and Finance" is a very broad category, and the result could be skewed by changes in the composition of those jobs rather than wage stagnation.

**Key references**
• Crawford, M. B. (2009). *Shop Class as Soulcraft: An Inquiry into the Value of Work*. Penguin Press.
• Autor, D. H. (2015). *Why Are There Still So Many Jobs? The History and Future of Workplace Automation*. Journal of Economic Perspectives, 29(3), 3-30.

-----

## HYPOTHESIS\_TITLE: The Great Un-Coupling: A Geographic Imbalance of the Sexes *(BUCKET: Whimsical)*

**Abstract (≤ 60 words)**
Public Use Microdata Areas (PUMAs) with a higher sex ratio (more men than women) among adults aged 22-35 also exhibit a higher proportion of men in that age group living alone. This suggests that local dating market imbalances directly manifest in household formation statistics, creating geographic "hotspots" of bachelorhood driven by demographic scarcity.

**Structured specification**

```json
{
"novelty_rating": "medium",
"feasibility_rating": "high",
"complexity_rating": "low",
"whimsy_rating": "high",
"geographic_level": "PUMA",
"primary_metrics": ["sex ratio (age 22-35)", "percent of males (22-35) living alone"],
"proposed_method": "scatter plot and linear regression",
"robustness_checks": ["controlling for PUMA-level income and employment", "testing the inverse for women (low sex ratio -> more women living alone)", "using different age brackets"],
"expected_runtime": "1–4 hr",
"ethical_flags": []
}
```

**Narrative plan**

1.  **Data sources** – The analysis will use **ACS 1-Year PUMS data** to get a large sample of individual records that can be aggregated to the PUMA.

      * `PUMS Person Record`: Variables for `AGEP`, `SEX`, `PUMA`.
      * `PUMS Housing Record` cross-referenced with the Person Record: To determine living arrangements (e.g., householder of a one-person household).

2.  **Methodology** – Using the PUMS data, we will calculate two metrics for every PUMA:

    1.  The sex ratio for the 22-35 age group: (Number of Males / Number of Females).
    2.  The "male living alone" rate: (% of males aged 22-35 who are householders in a single-person household).
        We will then plot these two variables and run a simple linear regression to test for a positive association.

3.  **Why it matters / what could go wrong** – This provides a whimsical, demographic explanation for a sociological phenomenon (single-person households), linking it to the structure of local "mating markets." It's a fun application of demographic data to social life. The primary confounder is the local economy. PUMAs with industries that attract more men (e.g., oil and gas, tech) might also have high wages that allow more people to afford to live alone, regardless of the sex ratio.

**Key references**
• Guttentag, M., & Secord, P. F. (1983). *Too Many Women? The Sex Ratio Question*. Sage Publications.
• Klinenberg, E. (2012). *Going Solo: The Extraordinary Rise and Surprising Appeal of Living Alone*. Penguin Press.

-----

## HYPOTHESIS\_TITLE: The "Some Other Race" Archipelago *(BUCKET: Whimsical)*

**Abstract (≤ 60 words)**
A map of the population density of individuals identifying as "Some Other Race" alone in the 2020 Census reveals a distinct geographic "archipelago." These clusters correspond almost perfectly to areas with high concentrations of Hispanic/Latino populations who do not identify with the standard OMB race categories, illustrating a collision between lived identity and bureaucratic classification.

**Structured specification**

```json
{
"novelty_rating": "medium",
"feasibility_rating": "high",
"complexity_rating": "low",
"whimsy_rating": "medium",
"geographic_level": "tract",
"primary_metrics": ["percent 'Some Other Race' alone", "percent Hispanic"],
"proposed_method": "choropleth mapping and bivariate correlation",
"robustness_checks": ["comparing 2010 vs. 2020 data", "calculating the correlation at the county level", "examining areas with high vs. low diversity"],
"expected_runtime": "1–4 hr",
"ethical_flags": []
}
```

**Narrative plan**

1.  **Data sources** – The analysis will use the **2020 Decennial Census PL-94-171 Redistricting Data Files** at the census tract level.

      * Table `P1`: Race. This provides counts for "Some Other Race alone."
      * Table `P2`: Hispanic or Latino, and Not Hispanic or Latino by Race. This provides counts for the Hispanic population.

2.  **Methodology** – The methodology is straightforward. For each census tract, we will calculate two percentages: (% of total population selecting "Some Other Race alone") and (% of total population identifying as "Hispanic or Latino"). We will then generate a scatterplot of these two variables and calculate the Pearson correlation coefficient. We will also produce a choropleth map of the "Some Other Race" percentage to visualize the geographic clustering.

3.  **Why it matters / what could go wrong** – This hypothesis provides a stark visualization of how Census categories fail to capture the identity of a large and growing segment of the U.S. population. It is a powerful educational tool for data literacy about race and ethnicity. The finding itself is not surprising to demographers, but the visualization and framing make it impactful. It's not a causal test but a descriptive statement on the nature of official data.

**Key references**
• Tafoya, S. M. (2004). *Shades of Belonging: Latinos and the U.S. Census*. Pew Hispanic Center.
• Prewitt, K. (2013). *What is Your Race? The Census and Our Flawed Efforts to Classify Americans*. Princeton University Press.

-----

## HYPOTHESIS\_TITLE: The Roommate Recession *(BUCKET: Whimsical)*

**Abstract (≤ 60 words)**
In counties that experienced a large influx of high-income movers (from ACS Migration Flows), the proportion of young adults (25-34) living with non-family roommates declined. The influx of wealth, driving up rents, made the shared-housing model less tenable, paradoxically leading to fewer, not more, roommate households as lower-income individuals were priced out entirely.

**Structured specification**

```json
{
"novelty_rating": "high",
"feasibility_rating": "medium",
"complexity_rating": "medium",
"whimsy_rating": "high",
"geographic_level": "county",
"primary_metrics": ["percent of households with non-relative roommates", "in-migration of high-income households"],
"proposed_method": "difference-in-differences",
"robustness_checks": ["using different income thresholds for 'high-income'", "controlling for new housing construction", "examining pre-trends"],
"expected_runtime": "4–12 hr",
"ethical_flags": []
}
```

**Narrative plan**

1.  **Data sources** – This combines migration data with household characteristics.

      * **ACS Migration Flows**: The 1-year flows data provides county-to-county flows by income level, allowing us to identify the "treatment" (a spike in high-income in-migration).
      * **ACS 1-Year Estimates**: Table `B11001` (Household Type) can be used to identify "Nonfamily households," and further tables on relationship to householder (`B09019`) can specify roommates.

2.  **Methodology** – We will use a difference-in-differences approach. The "treatment group" will be counties that saw a top-quartile spike in the in-migration of households earning over $200k in a given year (e.g., 2021). The "control group" will be other counties. The outcome variable is the change in the share of 25-34 year olds living in non-family, multi-person households from pre- to post-treatment.

3.  **Why it matters / what could go wrong** – This presents a counter-intuitive outcome of gentrification, suggesting that the classic "friends sharing an apartment" model can be a casualty of rapid economic change. The key challenge is isolating the causal effect. High-income movers may be attracted to counties that already had a declining roommate share for other reasons. A careful selection of the control group and analysis of pre-trends is essential.

**Key references**
• Moos, M. (2018). *The Rise of the Millennial-Filled ‘Youth-dified’ Suburb*. Urban Geography, 39(8), 1159-1182.
• Schafer, A., & Victor, G. N. (2022). *The financial returns to moving for work*. Journal of Urban Economics, 129, 103432.

-----

## HYPOTHESIS\_TITLE: The Geography of Night Owls: A Spatial Correlation of Night-Shift Work and Single Living *(BUCKET: Whimsical)*

**Abstract (≤ 60 words)**
Census tracts with a higher proportion of workers who commute to work between 12:00 AM and 4:59 AM (night-shift workers) also have a significantly higher share of single-person households. This suggests that the unconventional schedules of night-shift work may be less compatible with family or partnered living arrangements, manifesting in the housing landscape.

**Structured specification**

```json
{
"novelty_rating": "high",
"feasibility_rating": "high",
"complexity_rating": "low",
"whimsy_rating": "high",
"geographic_level": "tract",
"primary_metrics": ["percent of workers on night shift", "percent of households with one person"],
"proposed_method": "spatial correlation (Local Moran's I)",
"robustness_checks": ["controlling for tract-level median income and industry mix", "examining renters vs. owners", "testing for non-linear relationships"],
"expected_runtime": "4–12 hr",
"ethical_flags": []
}
```

**Narrative plan**

1.  **Data sources** – This analysis relies on detailed **ACS 5-Year Estimates** at the census tract level.

      * Table `B08132` (Time Leaving Home to Go to Work): Provides counts of workers leaving at different times, allowing us to create a "night shift" proxy (e.g., those leaving between midnight and 5 AM).
      * Table `B11001` (Household Type): Provides counts of single-person households.
      * `DP03`: For control variables like the industry mix of the tract (e.g., high share of hospitals or manufacturing).

2.  **Methodology** – The primary analysis will be a spatial one. After calculating the simple correlation, we will use a Local Moran's I analysis to identify statistically significant spatial clusters. This will reveal "hot spots" (tracts high in both night-shift work and single living), "cold spots" (low in both), and spatial outliers (high in one, low in the other), providing a rich geographic portrait of the relationship.

3.  **Why it matters / what could go wrong** – This offers a novel social-geographic insight into the lives of night-shift workers, a critical but often invisible part of the labor force. The correlation is not causal. It is highly likely that both night-shift work and single-person households are common in areas with certain industries (e.g., hospitals, logistics centers) and affordable small apartments. The analysis describes this co-location.

**Key references**
• Presser, H. B. (2003). *Working in a 24/7 Economy: Challenges for American Families*. Russell Sage Foundation.
• Anselin, L. (1995). *Local Indicators of Spatial Association—LISA*. Geographical analysis, 27(2), 93-115.

-----

## HYPOTHESIS\_TITLE: The Commuting Dead: Mapping the Geography of Vehicle-less, Transit-Poor Households *(BUCKET: Whimsical)*

**Abstract (≤ 60 words)**
We identify "transit deserts" by mapping census tracts with a high proportion of households having zero vehicles available AND low usage of public transportation for commuting. These "commuting dead" zones are hypothesized to correlate with high unemployment and low labor force participation, revealing populations that are physically disconnected from economic opportunity.

**Structured specification**

```json
{
"novelty_rating": "medium",
"feasibility_rating": "high",
"complexity_rating": "low",
"whimsy_rating": "medium",
"geographic_level": "tract",
"primary_metrics": ["percent households with no vehicle", "percent using public transit", "unemployment rate"],
"proposed_method": "quadrant analysis and choropleth mapping",
"robustness_checks": ["controlling for population density", "using 'walk or bike to work' as an alternative mobility measure", "comparing central city vs. suburban tracts"],
"expected_runtime": "1–4 hr",
"ethical_flags": ["risk of stigmatizing neighborhoods as 'dead'"]
}
```

**Narrative plan**

1.  **Data sources** – All data from the **ACS 5-Year Estimates** at the census tract level.

      * `B25044` (Tenure by Vehicles Available): To identify households with zero vehicles.
      * `B08301` (Means of Transportation to Work): To identify the share of workers using public transit.
      * `S2301` (Employment Status): For unemployment and labor force participation rates.

2.  **Methodology** – A quadrant analysis will be performed. For each tract, we will plot (% No Vehicle) on the Y-axis and (% Public Transit Use) on the X-axis. Tracts in the upper-left quadrant (high % no vehicle, low % transit use) are our "commuting dead" zones. We will map these tracts and then calculate the average unemployment rate within them, comparing it to tracts in the other three quadrants.

3.  **Why it matters / what could go wrong** – The whimsical name belies a serious policy issue: transit and mobility gaps. The map provides a clear, data-driven tool for transportation planners and social service agencies to identify areas of acute need. The main limitation is that "means of transportation to work" only measures commuters, potentially underestimating transit use for other purposes. It also doesn't capture the quality or frequency of the available transit.

**Key references**
• Krizek, K. J. (2003). *Neighborhood services, trip purpose, and tour-based travel*. Transportation, 30(4), 387-410.
• Sanchez, T. W., & Lang, R. E. (2002). *Security versus status: The two worlds of gated communities*. Center on Urban & Metropolitan Policy, The Brookings Institution.

--

## The Commute Complexity Paradox: Testing Whether Longer Commutes Predict Higher Local Wages *(BUCKET: Serious)*

**Abstract (≤ 60 words)**  
Using ACS journey-to-work data, we test whether counties with longer average commutes paradoxically show higher wage growth, suggesting workers accept distant jobs only for premium pay. Instrumental variables using pre-interstate highway routes address endogeneity. We examine heterogeneous effects by occupation and education, revealing which workers successfully monetize their commute tolerance in tight labor markets.

**Structured specification**
```json
{
  "novelty_rating": "high",
  "feasibility_rating": "high",
  "complexity_rating": "medium",
  "whimsy_rating": "low",
  "geographic_level": "county",
  "primary_metrics": ["mean travel time to work", "median earnings growth", "wage-commute elasticity"],
  "proposed_method": "instrumental variables with historical infrastructure",
  "robustness_checks": ["exclude metro cores", "test by occupation categories", "control for housing costs"],
  "expected_runtime": "1-4 hr",
  "ethical_flags": []
}
```

**Narrative plan**

1. **Data sources** – ACS Tables B08303 (travel time to work), B24011 (occupation by earnings), B25077 (median home value), B15003 (educational attainment).
2. **Methodology** – Instrument current commute patterns with 1950s highway planning routes that create exogenous variation in travel times. First stage: historical routes predict commutes. Second stage: commute times' effect on wage growth 2015-2023.
3. **Why it matters / what could go wrong** – Reveals labor market spatial friction costs. Risk: reverse causality if high wages enable suburban living. Solution: historical instrument addresses this.

**Key references**
• Monte et al. (2018) *Commuting, Migration, and Local Employment Elasticities*. American Economic Review 108(12).
• Heblich et al. (2020) *The Making of the Modern Metropolis*. Quarterly Journal of Economics 135(4).

-----

## Housing Ladder Lockout: Measuring Starter Home Extinction via Unit Size Evolution *(BUCKET: Serious)*

**Abstract (≤ 60 words)**  
We document the disappearance of small housing units using ACS bedroom count data 2010-2023. Defining "starter homes" as 0-2 bedroom units, we test whether their declining share predicts reduced household formation rates among young adults. Natural experiments from zoning changes provide causal identification of how unit size restrictions affect generational wealth building.

**Structured specification**
```json
{
  "novelty_rating": "medium",
  "feasibility_rating": "high",
  "complexity_rating": "medium",
  "whimsy_rating": "low",
  "geographic_level": "tract",
  "primary_metrics": ["small unit share", "young adult household formation rate", "median bedrooms"],
  "proposed_method": "difference-in-differences with zoning law changes",
  "robustness_checks": ["control for student populations", "test different size thresholds", "examine rental vs owned"],
  "expected_runtime": "1-4 hr",
  "ethical_flags": []
}
```

**Narrative plan**

1. **Data sources** – ACS Tables B25041 (bedrooms), B25007 (tenure by age), B11007 (households by presence of children), B25003 (tenure).
2. **Methodology** – Track share of 0-2 bedroom units by tract. Identify jurisdictions with zoning changes affecting minimum unit sizes. DiD comparing young household formation pre/post in treated vs control tracts.
3. **Why it matters / what could go wrong** – Critical for understanding wealth inequality reproduction. Challenge: zoning changes often coincide with other development. Solution: match on pre-trends.

**Key references**
• Gyourko & Molloy (2015) *Regulation and Housing Supply*. Handbook of Regional and Urban Economics 5.
• Glaeser & Gyourko (2018) *The Economic Implications of Housing Supply*. Journal of Economic Perspectives 32(1).

---

## Digital Divide Deserts: Mapping Work-From-Home Impossibility Zones *(BUCKET: Serious)*

**Abstract (≤ 60 words)**  
We identify "WFH deserts"—places where remote work is structurally impossible due to occupation mix and digital infrastructure. Using ACS data on occupations, commuting, and computer access, we create a Remote Work Impossibility Index. Panel analysis tests whether these deserts experienced worse economic outcomes during COVID-19, revealing a new dimension of spatial inequality.

**Structured specification**
```json
{
  "novelty_rating": "high",
  "feasibility_rating": "high",
  "complexity_rating": "medium",
  "whimsy_rating": "low",
  "geographic_level": "PUMA",
  "primary_metrics": ["remote work possibility index", "computer/internet access rate", "unemployment spike 2020"],
  "proposed_method": "spatial panel regression with COVID shock interaction",
  "robustness_checks": ["vary occupation classifications", "test urban/rural separately", "control for industry mix"],
  "expected_runtime": "4-12 hr",
  "ethical_flags": []
}
```

**Narrative plan**

1. **Data sources** – ACS Tables B24010 (occupation), B28002 (internet subscriptions), B08301 (means of transportation), B23025 (employment status).
2. **Methodology** – Code occupations by remote feasibility. Combine with internet access to create impossibility index. Interact with COVID period dummy to test differential employment impacts. Spatial models for spillovers.
3. **Why it matters / what could go wrong** – Identifies structurally disadvantaged places in new economy. Risk: occupation coding imprecision. Solution: validate with actual WFH rates post-2020.

**Key references**
• Dingel & Neiman (2020) *How Many Jobs Can be Done at Home?*. Journal of Public Economics 189.
• Barrero et al. (2021) *Why Working From Home Will Stick*. NBER Working Paper 28731.

---

## The Care Economy Cascade: Eldercare Needs Driving Youth Out-Migration *(BUCKET: Serious)*

**Abstract (≤ 60 words)**  
We test whether counties with high elderly dependency ratios experience youth out-migration due to care burden expectations. Using PEP age structures and ACS migration flows, we identify places where eldercare demands may push young adults elsewhere. Instrumental variables using historical age structures address endogeneity, revealing how demographic dependency shapes geographic opportunity.

**Structured specification**
```json
{
  "novelty_rating": "high",
  "feasibility_rating": "high",
  "complexity_rating": "medium",
  "whimsy_rating": "low",
  "geographic_level": "county",
  "primary_metrics": ["elderly dependency ratio", "youth out-migration rate", "care occupation share"],
  "proposed_method": "instrumental variables using lagged demographics",
  "robustness_checks": ["test gender differences", "control for wages", "examine family structure effects"],
  "expected_runtime": "1-4 hr",
  "ethical_flags": []
}
```

**Narrative plan**

1. **Data sources** – PEP age components, ACS migration flows by age, ACS Tables B23022 (sex by work status by presence of children), B24010 (healthcare occupations).
2. **Methodology** – Calculate elderly (65+) to working age (25-44) ratios. Instrument with 20-year lagged age structure. Test if high ratios predict youth out-migration, especially among women. Control for economic opportunities.
3. **Why it matters / what could go wrong** – Reveals hidden cost of aging in place. Challenge: cultural factors affect family caregiving. Solution: exploit variation within cultural groups.

**Key references**
• Skira (2015) *Dynamic Wage and Employment Effects of Elder Parent Care*. International Economic Review 56(1).
• Van Houtven et al. (2013) *The Effect of Informal Care on Work and Wages*. Journal of Health Economics 32(1).

---

## Eviction Echo Effects: Displacement Cascades Through Social Networks *(BUCKET: Serious)*

**Abstract (≤ 60 words)**  
Using ACS household relationship and mobility data, we test whether eviction concentrations predict subsequent moves by non-evicted neighbors. We hypothesize that evictions trigger "displacement cascades" through social networks. Spatial lag models with instrumental variables (using court closures for exogenous variation) identify causal peer effects in housing instability beyond direct displacement.

**Structured specification**
```json
{
  "novelty_rating": "high",
  "feasibility_rating": "medium",
  "complexity_rating": "high",
  "whimsy_rating": "low",
  "geographic_level": "tract",
  "primary_metrics": ["residential mobility rate", "network displacement index", "tenure duration change"],
  "proposed_method": "spatial autoregressive model with IV",
  "robustness_checks": ["vary network definitions", "test different time lags", "control for rent changes"],
  "expected_runtime": "4-12 hr",
  "ethical_flags": []
}
```

**Narrative plan**

1. **Data sources** – ACS Tables B07001 (geographic mobility), B25038 (year householder moved), B11001 (household type), B25070 (rent burden).
2. **Methodology** – Proxy eviction risk using extreme rent burden and recent moves. Create spatial weight matrix for social networks. IV using differential court closure policies. Test if high-eviction tracts predict neighbor mobility.
3. **Why it matters / what could go wrong** – Reveals hidden social costs of eviction. Challenge: can't directly observe evictions. Solution: validate proxy using known eviction hotspots.

**Key references**
• Desmond & Gershenson (2017) *Who Gets Evicted? Assessing Individual, Neighborhood, and Network Factors*. Social Science Research 62.
• Collyer et al. (2023) *The Spillover Effects of Eviction on Neighborhoods*. American Sociological Review 88(2).

---

## Climate Refugee Receiving Zones: Detecting Disaster-Driven Demographics *(BUCKET: Serious)*

**Abstract (≤ 60 words)**  
We identify counties experiencing population surges following distant climate disasters, revealing America's internal climate refugee destinations. Using PEP population spikes and ACS origin data, we map disaster-to-destination corridors. Machine learning classifies receiving counties by shared characteristics, predicting future climate haven locations before infrastructure stress emerges.

**Structured specification**
```json
{
  "novelty_rating": "high",
  "feasibility_rating": "high",
  "complexity_rating": "high",
  "whimsy_rating": "low",
  "geographic_level": "county",
  "primary_metrics": ["population surge index", "disaster-origin share", "infrastructure stress indicators"],
  "proposed_method": "event study with machine learning classification",
  "robustness_checks": ["placebo with non-disaster years", "test different disaster types", "validate predictions out-of-sample"],
  "expected_runtime": "4-12 hr",
  "ethical_flags": []
}
```

**Narrative plan**

1. **Data sources** – PEP annual estimates with components, ACS migration flows, ACS Tables B25001 (housing units), B01003 (population).
2. **Methodology** – Identify population spikes exceeding 2 standard deviations following major disasters. Trace origins using migration flows. Random forest to classify receiving county characteristics. Predict future havens.
3. **Why it matters / what could go wrong** – Critical for climate adaptation planning. Risk: conflating economic and climate migration. Solution: compare disaster vs non-disaster origin patterns.

**Key references**
• Hauer (2017) *Migration Induced by Sea-Level Rise Could Reshape the US Population Landscape*. Nature Climate Change 7(5).
• Robinson et al. (2023) *Modeling Climate Migration*. Science 380(6650).

---

## The Loneliness Gradient: Social Isolation by Settlement Density *(BUCKET: Serious)*

**Abstract (≤ 60 words)**  
We construct a multidimensional loneliness risk index using ACS household composition, age, and commute data. Testing the hypothesis that mid-density suburbs show highest isolation risk—lacking both urban amenities and rural community bonds—we map America's "loneliness belt." Panel analysis examines whether high-isolation areas show subsequent health and mortality effects.

**Structured specification**
```json
{
  "novelty_rating": "high",
  "feasibility_rating": "high",
  "complexity_rating": "medium",
  "whimsy_rating": "low",
  "geographic_level": "tract",
  "primary_metrics": ["single-person household rate", "social isolation index", "density-isolation correlation"],
  "proposed_method": "nonparametric regression with mortality outcomes",
  "robustness_checks": ["test age-specific patterns", "control for income", "examine pre-COVID vs during"],
  "expected_runtime": "1-4 hr",
  "ethical_flags": []
}
```

**Narrative plan**

1. **Data sources** – ACS Tables B11001 (household type), B08303 (travel time), B25001 (housing units), B01001 (age/sex), density from land area.
2. **Methodology** – Combine single-person households, long solo commutes, and age into isolation index. Nonparametric regression on density reveals U-shaped pattern. Link to mortality changes using PEP deaths data.
3. **Why it matters / what could go wrong** – Maps social infrastructure needs. Challenge: ecological fallacy—tract patterns ≠ individual loneliness. Solution: focus on structural isolation factors.

**Key references**
• Holt-Lunstad et al. (2015) *Loneliness and Social Isolation as Risk Factors for Mortality*. Perspectives on Psychological Science 10(2).
• McPherson et al. (2006) *Social Isolation in America*. American Sociological Review 71(3).

---

## Language Extinction Hotspots: Mapping Intergenerational Transmission Failure *(BUCKET: Serious)*

**Abstract (≤ 60 words)**  
Using detailed ACS language tables by age, we identify where immigrant languages disappear between parent and child generations. Calculating intergenerational transmission rates, we map "language extinction hotspots" where heritage languages vanish fastest. Causal analysis using school district boundaries tests how educational policies affect language maintenance versus assimilation pressures.

**Structured specification**
```json
{
  "novelty_rating": "high",
  "feasibility_rating": "high",
  "complexity_rating": "medium",
  "whimsy_rating": "low",
  "geographic_level": "PUMA",
  "primary_metrics": ["intergenerational transmission rate", "language diversity loss index", "age-specific speaker rates"],
  "proposed_method": "regression discontinuity at school district boundaries",
  "robustness_checks": ["test specific language families", "control for intermarriage", "examine weekend school effects"],
  "expected_runtime": "4-12 hr",
  "ethical_flags": []
}
```

**Narrative plan**

1. **Data sources** – ACS Tables B16001 (language by age), B05002 (place of birth), B16007 (age by language at home), B06007 (place of birth by language).
2. **Methodology** – Calculate ratio of child to parent speakers for each language. Map transmission rates. RD design using school district boundaries that differ in bilingual education policies. Test policy effects on transmission.
3. **Why it matters / what could go wrong** – Informs cultural preservation and education policy. Risk: confounding with residential selection. Solution: instrument with pre-policy language patterns.

**Key references**
• Portes & Hao (1998) *Bilingualism and Loss of Language in the Second Generation*. Sociology of Education 71(4).
• Alba et al. (2002) *Only English by the Third Generation?*. Demography 39(3).

---

## Mortgage Prison Geography: Mapping Negative Equity's Mobility Trap *(BUCKET: Serious)*

**Abstract (≤ 60 words)**  
We identify "mortgage prisons"—places where underwater mortgages trap residents despite better opportunities elsewhere. Combining ACS mortgage status, home values, and migration data, we test whether high negative equity areas show reduced out-migration even when facing economic decline. Natural experiments from localized housing busts provide causal identification of financial lock-in effects.

**Structured specification**
```json
{
  "novelty_rating": "medium",
  "feasibility_rating": "high",
  "complexity_rating": "medium",
  "whimsy_rating": "low",
  "geographic_level": "county",
  "primary_metrics": ["estimated negative equity share", "out-migration rate", "job opportunity index"],
  "proposed_method": "instrumental variables using housing supply elasticity",
  "robustness_checks": ["test by mortgage vintage", "control for attachment factors", "examine renter comparison"],
  "expected_runtime": "1-4 hr",
  "ethical_flags": []
}
```

**Narrative plan**

1. **Data sources** – ACS Tables B25077 (home value), B25101 (mortgage status), B25088 (mortgage payment), ACS migration flows, B23025 (employment).
2. **Methodology** – Estimate negative equity using mortgage/value ratios and origination timing. Instrument with Saiz housing supply elasticity. Test if high negative equity reduces migration response to unemployment shocks.
3. **Why it matters / what could go wrong** – Reveals financial barriers to economic mobility. Challenge: unobserved household debt. Solution: focus on relative patterns across areas.

**Key references**
• Ferreira et al. (2010) *Housing Busts and Household Mobility*. Journal of Urban Economics 68(1).
• Schulhofer-Wohl (2011) *Negative Equity Does Not Reduce Homeowners' Mobility*. Federal Reserve Bank of Minneapolis.

---

## The Surname Diversity Dividend: Testing Onomastic Variety as Innovation Proxy *(BUCKET: Exploratory)*

**Abstract (≤ 60 words)**  
We create a surname diversity index using ACS microdata samples, hypothesizing that places with more varied surnames exhibit greater economic dynamism. Using information theory metrics on name distributions, we test whether high onomastic diversity predicts patent rates, firm formation, and income growth. Historical immigration waves provide exogenous variation in surname variety.

**Structured specification**
```json
{
  "novelty_rating": "high",
  "feasibility_rating": "medium",
  "complexity_rating": "high",
  "whimsy_rating": "medium",
  "geographic_level": "metro",
  "primary_metrics": ["surname Shannon entropy", "economic dynamism indicators", "innovation output proxies"],
  "proposed_method": "instrumental variables using historical immigration",
  "robustness_checks": ["control for raw diversity", "test specific origin groups", "examine selection effects"],
  "expected_runtime": "4-12 hr",
  "ethical_flags": []
}
```

**Narrative plan**

1. **Data sources** – ACS PUMS for surname data (special request), ACS Tables B24010 (occupation mix), B19013 (income), B15003 (education).
2. **Methodology** – Calculate Shannon entropy of surname distribution by metro. Instrument using 1920s immigration quotas that create exogenous variation. Test if historical surname diversity predicts current economic outcomes.
3. **Why it matters / what could go wrong** – Novel measure of deep cultural diversity. Challenge: surnames unavailable in public data. Workaround: petition for aggregated diversity metrics.

**Key references**
• Ottaviano & Peri (2006) *The Economic Value of Cultural Diversity*. Journal of Economic Geography 6(1).
• Docquier et al. (2020) *Birthplace Diversity and Economic Growth*. Journal of Economic Growth 25(1).

---

## Demographic Turbulence: Measuring Population Churn via Entropy Dynamics *(BUCKET: Exploratory)*

**Abstract (≤ 60 words)**  
We apply fluid dynamics concepts to demographics, calculating "turbulence" in age-race-income distributions over time. High-turbulence areas show rapid compositional change without net growth—pure churn. Using spectral analysis on annual ACS data, we identify demographic oscillations and test whether turbulent places exhibit distinct economic outcomes, treating population mixing as a measurable force.

**Structured specification**
```json
{
  "novelty_rating": "high",
  "feasibility_rating": "medium",
  "complexity_rating": "high",
  "whimsy_rating": "medium",
  "geographic_level": "tract",
  "primary_metrics": ["demographic turbulence index", "spectral power coefficients", "mixing rate"],
  "proposed_method": "spectral analysis with Reynolds number analog",
  "robustness_checks": ["vary time windows", "test different demographic dimensions", "compare to simple turnover"],
  "expected_runtime": ">12 hr",
  "ethical_flags": []
}
```

**Narrative plan**

1. **Data sources** – ACS Tables B01001 (age/sex), B03002 (race/ethnicity), B19001 (income), annual 2010-2023, B07001 (mobility).
2. **Methodology** – Calculate year-over-year changes in joint distributions. Apply Fourier transform to identify oscillation frequencies. Define Reynolds number analog for demographic flow. Test if turbulence predicts economic volatility.
3. **Why it matters / what could go wrong** – Introduces physics-inspired demographic metrics. Challenge: assumes population as continuous fluid. Solution: validate against discrete agent models.

**Key references**
• Batty (2013) *The New Science of Cities*. MIT Press.
• Schelling (1971) *Dynamic Models of Segregation*. Journal of Mathematical Sociology 1(2).

---

## Transit Shadow Zones: Detecting Accessibility Deserts via Commute Impossibility *(BUCKET: Exploratory)*

**Abstract (≤ 60 words)**  
We identify "transit shadows"—areas where car-free commuting is mathematically impossible given reported work locations and travel times. Using constraint satisfaction algorithms on ACS commute data, we map zones of forced car dependence. These reveal hidden transportation deserts where non-drivers face de facto employment exclusion, with implications for environmental justice.

**Structured specification**
```json
{
  "novelty_rating": "high",
  "feasibility_rating": "high",
  "complexity_rating": "high",
  "whimsy_rating": "low",
  "geographic_level": "tract",
  "primary_metrics": ["transit impossibility score", "mode choice constraints", "accessibility desert index"],
  "proposed_method": "constraint satisfaction problem with spatial optimization",
  "robustness_checks": ["vary time thresholds", "test different modes", "validate with known transit maps"],
  "expected_runtime": ">12 hr",
  "ethical_flags": []
}
```

**Narrative plan**

1. **Data sources** – ACS Tables B08301 (means of transportation), B08303 (travel time), B08101 (workplace geography), B08201 (household vehicles).
2. **Methodology** – For each tract, solve: can observed non-car commutes reach reported workplace counties within stated times? Where impossible, measure "shadow depth." Validate against known transit networks.
3. **Why it matters / what could go wrong** – Reveals hidden transportation inequity. Challenge: assumes direct routes. Solution: add buffer for transfers and actual network topology.

**Key references**
• Levinson & Kumar (1994) *The Rational Locator: Why Travel Times Have Remained Stable*. Journal of the American Planning Association 60(3).
• Grengs (2010) *Job Accessibility and the Modal Mismatch in Detroit*. Journal of Transport Geography 18(1).

---

## Population Momentum Paradox: Where Demographics Defy Destiny *(BUCKET: Exploratory)*

**Abstract (≤ 60 words)**  
We identify counties where population growth opposes demographic fundamentals—places growing despite aging and low fertility, or shrinking despite youth and high fertility. Using demographic momentum calculations from age structures, we find "paradox counties" defying their destiny. Extreme value theory identifies statistical outliers, revealing hidden forces overriding natural population dynamics.

**Structured specification**
```json
{
  "novelty_rating": "high",
  "feasibility_rating": "high",
  "complexity_rating": "high",
  "whimsy_rating": "low",
  "geographic_level": "county",
  "primary_metrics": ["intrinsic growth rate", "actual growth rate", "momentum-reality gap"],
  "proposed_method": "demographic momentum models with extreme value statistics",
  "robustness_checks": ["test different projection horizons", "exclude high-migration counties", "vary momentum calculations"],
  "expected_runtime": "4-12 hr",
  "ethical_flags": []
}
```

**Narrative plan**

1. **Data sources** – Decennial Census age structures, PEP components of change, ACS Tables B01001 (age/sex), county-to-county migration flows.
2. **Methodology** – Calculate intrinsic growth rates from age structures using Leslie matrices. Compare to actual PEP growth. Apply extreme value theory to identify outliers. Investigate what overrides demographic momentum.
3. **Why it matters / what could go wrong** – Reveals limits of demographic determinism. Challenge: migration dominates natural increase. Solution: decompose growth sources explicitly.

**Key references**
• Preston et al. (2001) *Demography: Measuring and Modeling Population Processes*. Blackwell.
• Blue & Espenshade (2011) *Population Momentum Across the Demographic Transition*. Population and Development Review 37(4).

---

## The Gentrification Genome: Sequencing Neighborhood Change via Transition Matrices *(BUCKET: Exploratory)*

**Abstract (≤ 60 words)**  
We treat neighborhood change as DNA, creating "genomes" from sequences of demographic transitions. Using Markov chain analysis on tract-level changes, we identify characteristic sequences preceding gentrification. Machine learning on these transition patterns predicts which neighborhoods will gentrify next, enabling proactive policy interventions before displacement accelerates.

**Structured specification**
```json
{
  "novelty_rating": "high",
  "feasibility_rating": "high",
  "complexity_rating": "high",
  "whimsy_rating": "medium",
  "geographic_level": "tract",
  "primary_metrics": ["transition sequence similarity", "gentrification probability", "sequence entropy"],
  "proposed_method": "hidden Markov models with sequence alignment algorithms",
  "robustness_checks": ["vary sequence length", "test different metro contexts", "out-of-sample validation"],
  "expected_runtime": ">12 hr",
  "ethical_flags": []
}
```

**Narrative plan**

1. **Data sources** – ACS Tables B19013 (income), B25077 (home value), B15003 (education), B03002 (race/ethnicity), 2010-2023 annual.
2. **Methodology** – Encode yearly changes as state transitions. Apply bioinformatics sequence alignment to find common gentrification "genes." Train HMM to recognize early sequences. Predict future gentrification probability.
3. **Why it matters / what could go wrong** – Early warning system for displacement. Risk: assumes deterministic sequences. Solution: incorporate stochastic elements and multiple pathways.

**Key references**
• Freeman (2005) *Displacement or Succession? Residential Mobility in Gentrifying Neighborhoods*. Urban Affairs Review 40(4).
• Hwang & Lin (2016) *What Have We Learned About the Causes of Recent Gentrification?*. Cityscape 18(3).

---

## Hyperbolic Discounting Districts: Mapping Time Preference via Tenure Choices *(BUCKET: Exploratory)*

**Abstract (≤ 60 words)**  
We infer population-level time preferences from housing decisions, hypothesizing that areas with more renters despite favorable buy/rent ratios contain residents with higher discount rates. Using dynamic optimization models on ACS tenure and cost data, we map "impatience geography." These revealed preferences predict other outcomes like education investment and retirement saving.

**Structured specification**
```json
{
  "novelty_rating": "high",
  "feasibility_rating": "medium",
  "complexity_rating": "high",
  "whimsy_rating": "medium",
  "geographic_level": "PUMA",
  "primary_metrics": ["implied discount rate", "rent-buy deviation", "time preference index"],
  "proposed_method": "structural estimation of dynamic choice model",
  "robustness_checks": ["control for mobility expectations", "test income effects", "vary interest rate assumptions"],
  "expected_runtime": ">12 hr",
  "ethical_flags": []
}
```

**Narrative plan**

1. **Data sources** – ACS Tables B25003 (tenure), B25071 (median rent), B25077 (home value), B25101 (mortgage status), B07401 (migration).
2. **Methodology** – Model tenure choice as optimal stopping problem. Estimate discount rates that rationalize observed choices given costs. Map implied time preferences. Test if they predict education and savings behavior.
3. **Why it matters / what could go wrong** – Links housing to behavioral economics. Challenge: many unobserved factors affect tenure. Solution: focus on relative differences across areas.

**Key references**
• Laibson (1997) *Golden Eggs and Hyperbolic Discounting*. Quarterly Journal of Economics 112(2).
• Davis et al. (2023) *The Rent-Price Ratio in the Cross-Section*. American Economic Review 113(5).

---

## Migration Matchmaking: Revealing Complementary County Pairs via Flow Asymmetry *(BUCKET: Exploratory)*

**Abstract (≤ 60 words)**  
We identify "demographic dating"—county pairs exchanging different population types, creating mutual benefit. Using bidirectional flow decomposition, we find pairs where A→B migrants differ systematically from B→A migrants in age, education, or income. Network analysis reveals matchmaking hubs facilitating efficient demographic exchange, suggesting natural pairing markets in migration.

**Structured specification**
```json
{
  "novelty_rating": "high",
  "feasibility_rating": "high",
  "complexity_rating": "high",
  "whimsy_rating": "medium",
  "geographic_level": "county",
  "primary_metrics": ["demographic exchange index", "flow complementarity score", "matching efficiency"],
  "proposed_method": "bipartite network analysis with flow decomposition",
  "robustness_checks": ["test different demographic dimensions", "control for size effects", "examine stability over time"],
  "expected_runtime": "4-12 hr",
  "ethical_flags": []
}
```

**Narrative plan**

1. **Data sources** – ACS county-to-county migration flows with characteristics, ACS Tables B07401 (migration by age), B07409 (by education), B07410 (by income).
2. **Methodology** – Decompose bidirectional flows by demographics. Calculate complementarity: how different are A→B vs B→A migrants? Apply stable marriage algorithm to find optimal pairings. Identify natural exchange partnerships.
3. **Why it matters / what could go wrong** – Reveals migration as demographic exchange market. Challenge: assumes intentional sorting. Solution: test against random flow null model.

**Key references**
• Roth & Sotomayor (1990) *Two-Sided Matching: A Study in Game-Theoretic Modeling*. Cambridge University Press.
• Choo & Siow (2006) *Who Marries Whom and Why*. Journal of Political Economy 114(1).

---

## Census Tract Thermodynamics: Measuring Demographic Heat and Pressure *(BUCKET: Exploratory)*

**Abstract (≤ 60 words)**  
We apply thermodynamic principles to census tracts, defining demographic "temperature" (population kinetic energy via mobility rates), "pressure" (density forces), and "heat capacity" (resistance to change). Using statistical mechanics formalism, we test whether demographic phase transitions follow physical laws. Critical points identify when gradual changes trigger sudden demographic transformations.

**Structured specification**
```json
{
  "novelty_rating": "high",
  "feasibility_rating": "medium",
  "complexity_rating": "high",
  "whimsy_rating": "high",
  "geographic_level": "tract",
  "primary_metrics": ["demographic temperature", "population pressure", "phase transition indicators"],
  "proposed_method": "statistical mechanics with mean field theory",
  "robustness_checks": ["test different analogies", "vary parameter definitions", "compare to simple thresholds"],
  "expected_runtime": ">12 hr",
  "ethical_flags": []
}
```

**Narrative plan**

1. **Data sources** – ACS Tables B07001 (mobility as kinetic energy), B01003 (density as pressure), B25038 (tenure as inertia), time series 2010-2023.
2. **Methodology** – Define demographic temperature T = variance(mobility rates). Pressure P = population density. Apply Ising model to predict phase transitions. Test if critical points predict sudden changes.
3. **Why it matters / what could go wrong** – Novel physics-based demographic theory. Risk: forcing inappropriate physical analogies. Solution: validate predictions empirically, treat as useful metaphor.

**Key references**
• Wilson (2000) *Complex Spatial Systems: The Modelling Foundations of Urban and Regional Analysis*. Pearson.
• Pumain (2006) *Hierarchy in Natural and Social Sciences*. Springer.

---

## The Cognitive Load Census: Mental Bandwidth Depletion Geography *(BUCKET: Exploratory)*

**Abstract (≤ 60 words)**  
We construct a "cognitive load index" from ACS variables theoretically linked to mental bandwidth depletion: complex households, multiple jobs, long commutes, linguistic isolation. Mapping this reveals "high cognitive tax" areas. We test whether these places show decision-making patterns consistent with depleted bandwidth: lower college enrollment, reduced preventive health behaviors, suboptimal financial choices.

**Structured specification**
```json
{
  "novelty_rating": "high",
  "feasibility_rating": "high",
  "complexity_rating": "medium",
  "whimsy_rating": "low",
  "geographic_level": "PUMA",
  "primary_metrics": ["cognitive load index", "bandwidth depletion score", "decision quality proxies"],
  "proposed_method": "principal components with behavioral validation",
  "robustness_checks": ["test individual components", "control for income", "examine urban/rural differences"],
  "expected_runtime": "1-4 hr",
  "ethical_flags": []
}
```

**Narrative plan**

1. **Data sources** – ACS Tables B11001 (complex households), B23022 (multiple job holders), B08303 (commute time), B16001 (linguistic isolation), B15003 (education decisions).
2. **Methodology** – Combine bandwidth-depleting factors via PCA. Map high-load areas. Test if cognitive load predicts suboptimal decisions controlling for income. Natural experiments from policy changes reducing specific loads.
3. **Why it matters / what could go wrong** – Links environment to decision-making capacity. Risk: ecological fallacy. Solution: focus on structural factors affecting whole populations.

**Key references**
• Mullainathan & Shafir (2013) *Scarcity: Why Having Too Little Means So Much*. Times Books.
• Mani et al. (2013) *Poverty Impedes Cognitive Function*. Science 341(6149).

---

## Intergenerational Mobility Mirages: False Signals in Age-Structured Data *(BUCKET: Exploratory)*

**Abstract (≤ 60 words)**  
We identify statistical mirages in mobility data caused by age structure dynamics. Places appearing to have high economic mobility may simply have favorable age pyramids creating mechanical income growth. Using demographic standardization techniques, we separate true opportunity from compositional effects, revealing which counties offer genuine versus illusory mobility.

**Structured specification**
```json
{
  "novelty_rating": "high",
  "feasibility_rating": "high",
  "complexity_rating": "high",
  "whimsy_rating": "low",
  "geographic_level": "county",
  "primary_metrics": ["raw mobility measure", "age-adjusted mobility", "mirage index"],
  "proposed_method": "demographic standardization with decomposition analysis",
  "robustness_checks": ["vary standard populations", "test different mobility metrics", "examine cohort effects"],
  "expected_runtime": "4-12 hr",
  "ethical_flags": []
}
```

**Narrative plan**

1. **Data sources** – ACS Tables B19037 (age-specific income), B01001 (age structure), B19013 (median income), PEP age pyramids over time.
2. **Methodology** – Calculate apparent income mobility as income growth over time. Decompose into age structure effects vs true growth using standardization. Identify places where age dynamics create false mobility signals.
3. **Why it matters / what could go wrong** – Corrects misallocation of opportunity-enhancing resources. Challenge: defining "true" mobility. Solution: multiple decomposition methods for robustness.

**Key references**
• Chetty et al. (2014) *Where is the Land of Opportunity?*. Quarterly Journal of Economics 129(4).
• Kitagawa (1955) *Components of a Difference Between Two Rates*. Journal of the American Statistical Association 50(272).

---

## The Birthday Paradox Places: Statistical Anomalies in Small Populations *(BUCKET: Whimsical)*

**Abstract (≤ 60 words)**  
We identify places where birthday statistics defy probability—small towns where everyone seems born in summer, or neighborhoods with inexplicable January clusters. Using binomial tests on birth month distributions from ACS age data, we map America's statistical outliers. These "birthday paradox places" might reveal hidden seasonal migration, historical events, or pure randomness manifest.

**Structured specification**
```json
{
  "novelty_rating": "high",
  "feasibility_rating": "medium",
  "complexity_rating": "low",
  "whimsy_rating": "high",
  "geographic_level": "tract",
  "primary_metrics": ["birth month concentration", "seasonality index", "probability of observed pattern"],
  "proposed_method": "exact binomial tests with multiple testing correction",
  "robustness_checks": ["test different age groups", "control for known seasonality", "examine historical events"],
  "expected_runtime": "1-4 hr",
  "ethical_flags": []
}
```

**Narrative plan**

1. **Data sources** – ACS Table B01001 (single-year age data), special tabulation for birth months if available, or inferred from age-date patterns.
2. **Methodology** – Calculate expected uniform distribution of birth months. Test each tract for significant deviation. Apply false discovery rate correction. Map outliers and investigate historical explanations.
3. **Why it matters / what could go wrong** – Playful exploration of statistical anomalies. Expected many false positives—that's part of the fun. Teaches multiple testing issues.

**Key references**
• Diaconis & Mosteller (1989) *Methods for Studying Coincidences*. Journal of the American Statistical Association 84(408).
• Hand (2014) *The Improbability Principle*. Scientific American Books.

---

## Vowel Valley, Consonant County: Testing Toponymic Sound Effects *(BUCKET: Whimsical)*

**Abstract (≤ 60 words)**  
We test whether places with vowel-heavy names attract different demographics than consonant-cluster locations. Calculating vowel-to-consonant ratios in place names, we examine correlations with resident characteristics. Do mellifluous "Aiea" or "Eaulie" attract artists while harsh "Pflugerville" draws pragmatists? Instrumental variables using indigenous names address endogeneity.

**Structured specification**
```json
{
  "novelty_rating": "high",
  "feasibility_rating": "high",
  "complexity_rating": "low",
  "whimsy_rating": "high",
  "geographic_level": "county",
  "primary_metrics": ["vowel ratio", "phonetic complexity score", "resident characteristic correlations"],
  "proposed_method": "OLS with historical naming instruments",
  "robustness_checks": ["test syllable count", "control for language origin", "examine pronunciation vs spelling"],
  "expected_runtime": "<1 hr",
  "ethical_flags": []
}
```

**Narrative plan**

1. **Data sources** – County names from TIGER files, ACS Tables B24010 (occupations), B15003 (education), B19013 (income).
2. **Methodology** – Calculate vowel/consonant ratios and phonetic complexity. Instrument with pre-settlement indigenous names for exogenous variation. Test correlations with creative occupations, education levels.
3. **Why it matters / what could go wrong** – Whimsical exploration of sound symbolism in geography. Obviously spurious correlations likely. Fun exercise in controlling confounders.

**Key references**
• Sapir (1929) *A Study in Phonetic Symbolism*. Journal of Experimental Psychology 12(3).
• Abel & Glinert (2008) *Chemists and Clusters: A Study of Name-Career Congruity*. Names 56(4).

---

## The Goldilocks Zone: Places That Are Demographically "Just Right" *(BUCKET: Whimsical)*

**Abstract (≤ 60 words)**  
We identify counties that are maximally average across all demographic dimensions—America's most thoroughly unremarkable places. Using Mahalanobis distance from national means across 50+ variables, we find the "Goldilocks Zones" of perfect ordinariness. Paradoxically, we test whether being comprehensively average makes these places unique in outcomes like stability and satisfaction.

**Structured specification**
```json
{
  "novelty_rating": "medium",
  "feasibility_rating": "high",
  "complexity_rating": "medium",
  "whimsy_rating": "high",
  "geographic_level": "county",
  "primary_metrics": ["multivariate distance from average", "stability index", "outcome mediocrity score"],
  "proposed_method": "Mahalanobis distance with principal components",
  "robustness_checks": ["vary included variables", "test different distance metrics", "examine temporal stability"],
  "expected_runtime": "1-4 hr",
  "ethical_flags": []
}
```

**Narrative plan**

1. **Data sources** – Comprehensive ACS tables including B01001, B03002, B15003, B19013, B25077, etc. (50+ demographic variables).
2. **Methodology** – Standardize all variables. Calculate Mahalanobis distance from national means. Identify minimum-distance counties. Test if extreme averageness predicts stability, growth, or satisfaction proxies.
3. **Why it matters / what could go wrong** – Celebrates radical normalcy. Philosophical question: is perfect averageness actually exceptional? Probably finds random rural counties.

**Key references**
• Mahalanobis (1936) *On the Generalised Distance in Statistics*. Proceedings of the National Institute of Sciences of India 2(1).
• Florida (2008) *Who's Your City?*. Basic Books.

---

## Even-Odd Orthodoxy: Testing Numerical Superstitions in Housing *(BUCKET: Whimsical)*

**Abstract (≤ 60 words)**  
We test whether census tracts with predominantly even-numbered addresses show different characteristics than odd-numbered areas. Using geocoded address data, we explore if numerical superstitions manifest in resident sorting. Do even-numbered places attract order-seeking personalities reflected in higher education or income? Pure nonsense, but testable nonsense.

**Structured specification**
```json
{
  "novelty_rating": "medium",
  "feasibility_rating": "low",
  "complexity_rating": "low",
  "whimsy_rating": "high",
  "geographic_level": "tract",
  "primary_metrics": ["even-odd address ratio", "resident characteristics", "housing values"],
  "proposed_method": "simple correlation with multiple testing correction",
  "robustness_checks": ["test different address components", "control for street age", "examine cultural variations"],
  "expected_runtime": "1-4 hr",
  "ethical_flags": []
}
```

**Narrative plan**

1. **Data sources** – Address data from TIGER/Line, ACS Tables B15003 (education), B19013 (income), B25077 (home values).
2. **Methodology** – Geocode addresses within tracts. Calculate even/odd ratios. Correlate with resident characteristics. Heavy multiple testing correction for spurious findings. Mostly an exercise in null results.
3. **Why it matters / what could go wrong** – Demonstrates importance of null findings. Will find nothing real, teaching statistical humility. Any "findings" are false positives.

**Key references**
• Simmons et al. (2011) *False-Positive Psychology*. Psychological Science 22(11).
• Gelman & Loken (2014) *The Statistical Crisis in Science*. American Scientist 102(6).

---

## Friday the 13th Flight: Testing Superstition in Migration Timing *(BUCKET: Whimsical)*

**Abstract (≤ 60 words)**  
We examine whether interstate moves avoid "unlucky" dates like Friday the 13th. Using ACS migration data with move timing, we test for systematic avoidance of superstitiously significant dates. Do educated populations show less date avoidance? This reveals how cultural superstitions influence major life decisions, or more likely, reveals nothing at all.

**Structured specification**
```json
{
  "novelty_rating": "high",
  "feasibility_rating": "low",
  "complexity_rating": "low",
  "whimsy_rating": "high",
  "geographic_level": "state",
  "primary_metrics": ["Friday 13th move rate", "superstition avoidance index", "education interaction"],
  "proposed_method": "time series analysis with cultural controls",
  "robustness_checks": ["test other unlucky dates", "examine different cultures", "control for practical factors"],
  "expected_runtime": "<1 hr",
  "ethical_flags": []
}
```

**Narrative plan**

1. **Data sources** – ACS Table B07001 (migration timing if available in special tabs), B15003 (education), B05002 (place of birth for cultural background).
2. **Methodology** – Count moves on Friday 13th vs other Fridays. Test for systematic avoidance. Interact with education and cultural origin. Control for moving company availability.
3. **Why it matters / what could go wrong** – Fun exploration of superstition in big decisions. Challenge: move timing not in standard ACS. Would need special tabulation unlikely to exist.

**Key references**
• Kolb & Rodriguez (1987) *Friday the Thirteenth: Part VII*. Journal of Finance 42(5).
• Delacroix & Guillén (2008) *Superstition and Sportsmanship*. Organization Science 19(4).

---

## ZIP Code Jealousy: Status Competition in Numeric Neighborhoods *(BUCKET: Whimsical)*

**Abstract (≤ 60 words)**  
We test whether neighboring ZIP codes with "better" numbers (lower digits, repeated sequences) show demographic differences suggesting status sorting. Do residents of 90210 look down on 90211? Using boundary discontinuity analysis, we examine if arbitrary numeric differences create real social boundaries through pure status association effects.

**Structured specification**
```json
{
  "novelty_rating": "high",
  "feasibility_rating": "high",
  "complexity_rating": "medium",
  "whimsy_rating": "high",
  "geographic_level": "tract",
  "primary_metrics": ["ZIP code status score", "boundary demographic gaps", "sorting intensity"],
  "proposed_method": "regression discontinuity at ZIP boundaries",
  "robustness_checks": ["test different status metrics", "control for actual amenities", "examine historical boundaries"],
  "expected_runtime": "1-4 hr",
  "ethical_flags": []
}
```

**Narrative plan**

1. **Data sources** – ACS Tables B19013 (income), B15003 (education), B25077 (home values) by tract, mapped to ZIP codes via TIGER.
2. **Methodology** – Create ZIP "status score" (low numbers, repetition, cultural cache). RD design comparing adjacent ZIPs with different status. Test for demographic discontinuities at arbitrary numeric boundaries.
3. **Why it matters / what could go wrong** – Explores pure status effects in residential sorting. Some real effects possible (90210 has actual cultural significance). Control for true amenities.

**Key references**
• Charles et al. (2009) *Conspicuous Consumption and Race*. Quarterly Journal of Economics 124(2).
• Bursztyn et al. (2018) *Status Goods: Experimental Evidence from Platinum Credit Cards*. Quarterly Journal of Economics 133(3).

---

## The Alliteration Effect: Do Repeated Initials Predict Place Prosperity? *(BUCKET: Whimsical)*

**Abstract (≤ 60 words)**  
We test whether places with alliterative names (Buffalo, New York; Casa Grande, Arizona) show different economic outcomes than non-alliterative places. The hypothesis: memorable names attract investment and migration. Using phonetic analysis of place names, we examine correlations with growth, income, and resident satisfaction. Instrumental variables using indigenous names address endogeneity.

**Structured specification**
```json
{
  "novelty_rating": "high",
  "feasibility_rating": "high",
  "complexity_rating": "low",
  "whimsy_rating": "high",
  "geographic_level": "county",
  "primary_metrics": ["alliteration score", "economic growth rate", "migration attractiveness"],
  "proposed_method": "instrumental variables with indigenous names",
  "robustness_checks": ["test rhyming names", "control for name length", "examine marketing spending"],
  "expected_runtime": "<1 hr",
  "ethical_flags": []
}
```

**Narrative plan**

1. **Data sources** – County names from TIGER, ACS Tables B01003 (population growth), B19013 (income), migration flows, PEP components.
2. **Methodology** – Code alliteration in county names (matching initial sounds). Instrument with pre-European names. Test if alliterative places show better outcomes. Control for actual characteristics.
3. **Why it matters / what could go wrong** – Playful test of marketing principles in geography. Likely null but fun. Any findings probably spurious or via real correlates.

**Key references**
• Berger & Fitzsimons (2008) *Dogs on the Street, Pumas on Your Feet*. Journal of Marketing Research 45(1).
• Brendl et al. (2005) *Name Letter Branding*. Journal of Consumer Research 31(4).

---

## Demographic Déjà Vu: Finding America's Temporal Twin Towns *(BUCKET: Whimsical)*

**Abstract (≤ 60 words)**  
We identify "temporal twins"—pairs of places whose current demographics mirror each other's past. Using dynamic time warping on demographic trajectories, we find counties experiencing the same transitions decades apart. Does 2024 Boise resemble 1995 Austin? These déjà vu discoveries might predict future trajectories, or merely amuse with historical rhymes.

**Structured specification**
```json
{
  "novelty_rating": "high",
  "feasibility_rating": "high",
  "complexity_rating": "high",
  "whimsy_rating": "high",
  "geographic_level": "county",
  "primary_metrics": ["temporal similarity score", "lag years", "trajectory correlation"],
  "proposed_method": "dynamic time warping with multivariate time series",
  "robustness_checks": ["vary similarity metrics", "test different variables", "validate predictions"],
  "expected_runtime": "4-12 hr",
  "ethical_flags": []
}
```

**Narrative plan**

1. **Data sources** – Decennial Census 1990-2020, ACS 2010-2023: comprehensive demographics including age, race, income, education, housing.
2. **Methodology** – Create multivariate time series for each county. Apply DTW to find minimum-distance matches across time. Identify temporal twins. Test if past trajectories predict future paths.
3. **Why it matters / what could go wrong** – Fun pattern matching with potential predictive value. Risk: overfitting to noise. Solution: out-of-sample validation on held-out years.

**Key references**
• Sakoe & Chiba (1978) *Dynamic Programming Algorithm Optimization*. IEEE Transactions ASSP-26(1).
• Morrison & Schmittlein (1988) *Generalizing the NBD Model*. Management Science 34(12).

---

## Peak America: Finding the Demographic Summit via Optimization *(BUCKET: Whimsical)*

**Abstract (≤ 60 words)**  
We use multiobjective optimization to find America's "peak place"—the location simultaneously maximizing income, minimizing commute time, maximizing education, optimizing age diversity, etc. Using Pareto frontier analysis on dozens of ACS variables, we identify the efficient frontier of American places. Which county is demographically optimal? (Spoiler: it depends on your weights.)

**Structured specification**
```json
{
  "novelty_rating": "medium",
  "feasibility_rating": "high",
  "complexity_rating": "high",
  "whimsy_rating": "high",
  "geographic_level": "county",
  "primary_metrics": ["Pareto optimality score", "objective function value", "frontier distance"],
  "proposed_method": "multiobjective optimization with evolutionary algorithms",
  "robustness_checks": ["vary objective weights", "test different variable sets", "examine sensitivity"],
  "expected_runtime": "4-12 hr",
  "ethical_flags": []
}
```

**Narrative plan**

1. **Data sources** – Comprehensive ACS tables for all desirable/undesirable characteristics: income, education, commute, crime proxies, housing cost, diversity, etc.
2. **Methodology** – Define objective functions for 20+ dimensions. Use NSGA-II to find Pareto frontier. Map efficient places. Allow users to weight preferences to find their personal optimum.
3. **Why it matters / what could go wrong** – Playful take on "best places" rankings using rigorous optimization. Shows there's no single "best"—only tradeoffs. Probably finds college towns.

**Key references**
• Deb et al. (2002) *A Fast and Elitist Multiobjective Genetic Algorithm: NSGA-II*. IEEE Transactions on Evolutionary Computation 6(2).
• Keeney & Raiffa (1976) *Decisions with Multiple Objectives*. Cambridge University Press.

---

## The Procrastination Peninsula: Late Census Response as Personality Proxy *(BUCKET: Whimsical)*

**Abstract (≤ 60 words)**  
We map "Procrastination Geography" using Census response timing data, identifying areas with disproportionately late submissions. Testing whether late-responding places show other procrastination proxies—late tax filings, driver license renewals, voter registration—we create America's comprehensive procrastination map. Do chronic late responders cluster geographically, suggesting regional personality differences?

**Structured specification**
```json
{
  "novelty_rating": "high",
  "feasibility_rating": "medium",
  "complexity_rating": "low",
  "whimsy_rating": "high",
  "geographic_level": "county",
  "primary_metrics": ["response lateness index", "procrastination score", "deadline behavior patterns"],
  "proposed_method": "factor analysis with spatial clustering",
  "robustness_checks": ["control for mail delivery times", "test different deadlines", "examine cultural factors"],
  "expected_runtime": "<1 hr",
  "ethical_flags": []
}
```

**Narrative plan**

1. **Data sources** – Census 2020 response timing data, ACS Tables B15003 (education as conscientiousness proxy), B16001 (language barriers), B01001 (age).
2. **Methodology** – Calculate average response delay by county. Create procrastination index. Test spatial clustering. Correlate with education, age, and other behavioral proxies. Control for legitimate barriers.
3. **Why it matters / what could go wrong** – Maps collective personality traits. Challenge: response timing affected by operations, not just personality. Solution: focus on relative patterns within states.

**Key references**
• Steel (2007) *The Nature of Procrastination*. Psychological Bulletin 133(1).
• Ameriks et al. (2003) *Wealth Accumulation and the Propensity to Plan*. Quarterly Journal of Economics 118(3).