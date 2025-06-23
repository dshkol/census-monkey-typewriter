## The Great Dispersion: Quantifying Remote Work's Demographic Reshuffling via Intercensal Estimates *(BUCKET: Serious)*

**Abstract (≤ 60 words)**  
We leverage Population Estimates Program (PEP) annual data 2019-2024 to identify counties experiencing anomalous population growth beyond pre-pandemic trends. Comparing PEP components of change with ACS occupation data, we test whether counties gaining population show decreases in physically-present occupations. This reveals the geographic extent of remote work adoption and its demographic implications for receiving communities.

**Structured specification**
```json
{
  "novelty_rating":       "high",
  "feasibility_rating":   "high",
  "complexity_rating":    "medium",
  "whimsy_rating":        "low",
  "geographic_level":     "county",
  "primary_metrics":      ["PEP net migration rate", "remote-capable occupation share", "population growth deviation"],
  "proposed_method":      "interrupted time series with synthetic controls",
  "robustness_checks":    ["exclude college counties", "test metro vs non-metro", "vary trend periods"],
  "expected_runtime":     "1-4 hr",
  "ethical_flags":        []
}
```

**Narrative plan**

1. **Data sources** – PEP county totals and components (PEPANNRES), ACS Table B24010 (occupation by sex), B24011 (occupation by median earnings).
2. **Methodology** – Identify counties with 2020-2024 growth exceeding 2015-2019 trends by >2 standard deviations. Create synthetic controls from similar pre-2020 counties. Test if anomalous growth correlates with remote-capable occupation increases.
3. **Why it matters / what could go wrong** – Critical for infrastructure planning in receiving areas. Risk: PEP estimates revised significantly in 2030 census. Mitigation: sensitivity analysis with confidence intervals.

**Key references**
• Ramani & Bloom (2021) *The Donut Effect of COVID-19 on Cities*. NBER Working Paper 28876.
• Althoff et al. (2022) *The Geography of Remote Work*. Regional Science and Urban Economics 93.

---

## Birth Dearth Dominoes: Predicting School Infrastructure Needs from Fertility Collapse *(BUCKET: Serious)*

**Abstract (≤ 60 words)**  
Using detailed age pyramids from ACS 2018-2023, we document the acceleration of birth rate decline and project its spatial implications. We develop a model predicting which school districts face closure risks based on age 0-4 cohort shrinkage. Comparing against districts' current capacity utilization reveals mismatches between demographic destiny and infrastructure planning, particularly in high-cost metros.

**Structured specification**
```json
{
  "novelty_rating":       "medium",
  "feasibility_rating":   "high",
  "complexity_rating":    "medium",
  "whimsy_rating":        "low",
  "geographic_level":     "county",
  "primary_metrics":      ["age 0-4 population change", "school-age dependency ratio", "fertility rate proxy"],
  "proposed_method":      "cohort component projection with spatial panel models",
  "robustness_checks":    ["test different projection horizons", "sensitivity to migration assumptions", "compare with PEP births data"],
  "expected_runtime":     "4-12 hr",
  "ethical_flags":        []
}
```

**Narrative plan**

1. **Data sources** – ACS Tables B01001 (age by sex), B09001 (children by age), PEP births component (PEPBYAGE), B14001 (school enrollment).
2. **Methodology** – Calculate year-over-year changes in age 0-4 populations by county. Project forward assuming current trends. Model tipping points where school consolidation becomes necessary based on minimum viable enrollment.
3. **Why it matters / what could go wrong** – Essential for education finance planning. Challenge: migration can offset fertility declines. Solution: incorporate ACS migration flows in projections.

**Key references**
• Kearney & Levine (2023) *The US Birth Dearth*. Journal of Economic Perspectives 37(1).
• Doepke et al. (2022) *The Economics of Fertility: A New Era*. NBER Working Paper 29948.

---

## Heat Refuge Highways: Mapping Climate-Driven Migration Corridors *(BUCKET: Serious)*

**Abstract (≤ 60 words)**  
We identify emerging climate migration patterns using ACS county-to-county flows 2015-2022. Classifying origin counties by extreme heat exposure days, we test whether flows increasingly favor cooler destinations. Network analysis reveals specific corridors repeatedly used for climate-motivated moves. Demographic composition of these flows indicates which populations successfully adapt through migration versus those trapped in place.

**Structured specification**
```json
{
  "novelty_rating":       "high",
  "feasibility_rating":   "high",
  "complexity_rating":    "high",
  "whimsy_rating":        "low",
  "geographic_level":     "county",
  "primary_metrics":      ["migration flow volume", "temperature differential", "corridor persistence index"],
  "proposed_method":      "gravity model with climate covariates and network analysis",
  "robustness_checks":    ["control for economic factors", "test different heat metrics", "placebo with non-climate pairs"],
  "expected_runtime":     "4-12 hr",
  "ethical_flags":        []
}
```

**Narrative plan**

1. **Data sources** – ACS Migration Flows county-to-county tables, ACS Tables B01001 (demographics of movers), B19013 (income), B25077 (home values).
2. **Methodology** – Code counties by heat exposure using latitude and elevation proxies. Estimate gravity model where temperature differential increasingly predicts flows over time. Map persistent corridors using edge betweenness.
3. **Why it matters / what could go wrong** – Reveals climate adaptation patterns and equity concerns. Limitation: can't directly observe climate motivation. Solution: instrument with wildfire/hurricane exposure patterns.

**Key references**
• Hauer et al. (2023) *Assessing Population Exposure to Climate Migration*. Environmental Research Letters 18(5).
• Kaczan & Orgill-Meyer (2020) *The Impact of Climate Change on Migration: A Synthesis*. Environmental Research Letters 15(6).

---

## The Rent Burden Exodus: Threshold Effects in Housing-Driven Displacement *(BUCKET: Serious)*

**Abstract (≤ 60 words)**  
Using ACS rent burden data, we identify displacement thresholds where out-migration spikes. Panel models test whether crossing 40%, 50%, or 60% median rent burden triggers population loss. We examine heterogeneous effects by age and family structure, revealing which groups exit versus endure extreme housing costs. Natural experiments from rapid rent increases provide causal identification.

**Structured specification**
```json
{
  "novelty_rating":       "medium",
  "feasibility_rating":   "high",
  "complexity_rating":    "medium",
  "whimsy_rating":        "low",
  "geographic_level":     "PUMA",
  "primary_metrics":      ["gross rent as percentage of income", "out-migration rate", "household composition change"],
  "proposed_method":      "regression discontinuity with panel fixed effects",
  "robustness_checks":    ["vary burden thresholds", "test income quintiles separately", "control for housing supply"],
  "expected_runtime":     "1-4 hr",
  "ethical_flags":        []
}
```

**Narrative plan**

1. **Data sources** – ACS Tables B25070 (gross rent as percentage of income), B07401 (migration by tenure), B11016 (household type), B25003 (tenure).
2. **Methodology** – Create panel of PUMAs 2015-2023. Identify sharp rent burden increases. RD design around 50% burden threshold. Test if crossing threshold predicts next-year out-migration controlling for fixed effects.
3. **Why it matters / what could go wrong** – Quantifies housing crisis tipping points. Challenge: simultaneous job loss may drive both. Solution: instrument with housing supply shocks from ACS building permit data.

**Key references**
• Mast & Hardman (2023) *Displacement and Rent Burden in Urban America*. Journal of Urban Economics 134.
• Collinson et al. (2022) *Eviction and Poverty in American Cities*. Quarterly Journal of Economics 137(1).

---

## Silver Tsunami Stagnation: How Aging in Place Freezes Housing Markets *(BUCKET: Serious)*

**Abstract (≤ 60 words)**  
We test whether counties with rapid elderly population growth experience housing market stagnation. Using PEP age components and ACS tenure duration data, we identify places where 65+ homeowners increasingly age in place. Panel models examine effects on housing turnover, young adult homeownership rates, and household formation. Natural variation in age structure provides identification.

**Structured specification**
```json
{
  "novelty_rating":       "medium",
  "feasibility_rating":   "high",
  "complexity_rating":    "medium",
  "whimsy_rating":        "low",
  "geographic_level":     "county",
  "primary_metrics":      ["65+ homeownership rate", "median tenure duration", "young adult ownership rate"],
  "proposed_method":      "instrumental variables using lagged age structure",
  "robustness_checks":    ["exclude retirement destinations", "test mortgage status effects", "vary age cutoffs"],
  "expected_runtime":     "1-4 hr",
  "ethical_flags":        []
}
```

**Narrative plan**

1. **Data sources** – PEP age components (PEPAGESEX), ACS Tables B25007 (tenure by age), B25038 (tenure duration), B25026 (mortgage status).
2. **Methodology** – Instrument current elderly share with 20-year lagged age structure. First stage: predict 65+ growth. Second stage: effect on housing turnover and young ownership. Compare high/low elderly growth counties.
3. **Why it matters / what could go wrong** – Critical for understanding intergenerational wealth transfers. Risk: reverse causality if young avoid elderly areas. Solution: use predetermined age structure as instrument.

**Key references**
• Myers & Lee (2024) *Peak Millennials and the Future of Homeownership*. Urban Studies 61(2).
• Begley & Chan (2018) *The Effect of Housing Wealth Shocks on Work and Retirement*. Journal of Public Economics 165.

---

## Migration Momentum: Testing Social Network Effects in County-to-County Flows *(BUCKET: Exploratory)*

**Abstract (≤ 60 words)**  
We test whether migration flows exhibit momentum—do people follow previous movers from their origin? Using ACS flows data, we examine if year t-1 flows predict year t flows beyond gravity model fundamentals. Network autocorrelation models identify "migration chains" where social ties create self-reinforcing corridors. Instrumental variables using historical settlement patterns address endogeneity.

**Structured specification**
```json
{
  "novelty_rating":       "high",
  "feasibility_rating":   "medium",
  "complexity_rating":    "high",
  "whimsy_rating":        "low",
  "geographic_level":     "county",
  "primary_metrics":      ["flow autocorrelation coefficient", "network density", "chain persistence"],
  "proposed_method":      "spatial autoregressive models with network lags",
  "robustness_checks":    ["vary lag structure", "test by distance bands", "control for economic shocks"],
  "expected_runtime":     "4-12 hr",
  "ethical_flags":        []
}
```

**Narrative plan**

1. **Data sources** – ACS Migration Flows (multiple years), ACS Tables B05002 (place of birth), B16001 (language), B03002 (Hispanic origin).
2. **Methodology** – Construct year-over-year flow matrices. Test if Flow[i,j,t] predicts Flow[i,j,t+1] controlling for gravity factors. Use 1990 foreign-born settlement as instrument for initial networks. Identify persistent chains.
3. **Why it matters / what could go wrong** – Reveals how social capital shapes migration. Challenge: distinguishing social effects from correlated shocks. Solution: leverage quasi-random refugee resettlement as natural experiment.

**Key references**
• Munshi (2003) *Networks in the Modern Economy: Mexican Migrants in the US Labor Market*. Quarterly Journal of Economics 118(2).
• Stuart (2022) *The Geography of Opportunity: Migration Networks and Economic Mobility*. American Economic Review 112(8).

---

## Demographic Fractals: Self-Similar Age Structures Across Geographic Scales *(BUCKET: Exploratory)*

**Abstract (≤ 60 words)**  
We test whether age distributions exhibit fractal properties—do neighborhood age structures mirror their containing cities and metros? Using multiscale entropy analysis on age pyramids from block group to state level, we quantify self-similarity. Places with high fractal dimensions may indicate integrated communities, while low dimensions suggest age segregation. Spatial analysis reveals geographic patterns.

**Structured specification**
```json
{
  "novelty_rating":       "high",
  "feasibility_rating":   "medium",
  "complexity_rating":    "high",
  "whimsy_rating":        "medium",
  "geographic_level":     "multi-scale",
  "primary_metrics":      ["fractal dimension", "cross-scale correlation", "age dissimilarity index"],
  "proposed_method":      "multifractal analysis with box-counting algorithm",
  "robustness_checks":    ["vary box sizes", "test different age bins", "compare to random null"],
  "expected_runtime":     ">12 hr",
  "ethical_flags":        []
}
```

**Narrative plan**

1. **Data sources** – Decennial Census 2020 P12 (age/sex) at multiple geographies, ACS Table B01001 for intercensal updates.
2. **Methodology** – Calculate age distributions at nested geographies. Apply box-counting to measure fractal dimension of age structure. Test if places with high self-similarity show different social/economic outcomes.
3. **Why it matters / what could go wrong** – Novel approach to measuring demographic integration. Challenge: edge effects at boundaries. Solution: use interior tracts only for cleanest measurement.

**Key references**
• Batty & Longley (1994) *Fractal Cities: A Geometry of Form and Function*. Academic Press.
• Lee et al. (2022) *Multiscale Segregation in US Metropolitan Areas*. PNAS 119(44).

---

## Bilingual Buffer Zones: Mapping Language Transition Gradients *(BUCKET: Exploratory)*

**Abstract (≤ 60 words)**  
We identify and characterize zones where monolingual communities meet, creating bilingual buffers. Using kernel density estimation on tract-level language data, we map gradient surfaces between English-only and Spanish-only areas. Testing whether these transition zones exhibit distinct socioeconomic characteristics—higher income diversity, unique occupation mixes, or different educational patterns—reveals the role of bilingualism in spatial integration.

**Structured specification**
```json
{
  "novelty_rating":       "high",
  "feasibility_rating":   "high",
  "complexity_rating":    "medium",
  "whimsy_rating":        "medium",
  "geographic_level":     "tract",
  "primary_metrics":      ["language gradient magnitude", "bilingual speaker percentage", "socioeconomic diversity index"],
  "proposed_method":      "kernel density gradient estimation with threshold detection",
  "robustness_checks":    ["vary kernel bandwidth", "test other language pairs", "control for immigration recency"],
  "expected_runtime":     "4-12 hr",
  "ethical_flags":        []
}
```

**Narrative plan**

1. **Data sources** – ACS Tables B16001 (language by ability to speak English), B03002 (Hispanic origin), B15003 (education), B24010 (occupation).
2. **Methodology** – Create continuous surfaces of English/Spanish prevalence using KDE. Calculate gradients to identify transition zones. Compare socioeconomic profiles of high-gradient (transition) versus low-gradient (homogeneous) areas.
3. **Why it matters / what could go wrong** – Reveals how linguistic diversity shapes neighborhoods. Risk: conflating language with ethnicity. Solution: control for Hispanic origin independent of language.

**Key references**
• Rumbaut et al. (2006) *Linguistic Life Expectancies*. Population and Development Review 32(3).
• Alba et al. (2002) *Only English by the Third Generation?*. Demography 39(3).

---

## Economic Shock Topology: Mapping Resilience Through Recovery Patterns *(BUCKET: Exploratory)*

**Abstract (≤ 60 words)**  
We apply topological data analysis to county-level economic indicators, creating "resilience maps" that reveal recovery patterns from shocks. Using persistent homology on unemployment and income trajectories 2015-2023, we identify counties that recover similarly despite geographic separation. These topological features predict future shock responses better than traditional geographic or industrial classifications.

**Structured specification**
```json
{
  "novelty_rating":       "high",
  "feasibility_rating":   "medium",
  "complexity_rating":    "high",
  "whimsy_rating":        "medium",
  "geographic_level":     "county",
  "primary_metrics":      ["persistence diagram features", "Betti numbers", "recovery trajectory similarity"],
  "proposed_method":      "topological data analysis with persistent homology",
  "robustness_checks":    ["vary filtration parameters", "test different distance metrics", "bootstrap stability"],
  "expected_runtime":     ">12 hr",
  "ethical_flags":        []
}
```

**Narrative plan**

1. **Data sources** – ACS Tables B23025 (employment status), B19013 (median income), PEP economic time series, B24050 (industry by occupation).
2. **Methodology** – Create high-dimensional trajectory vectors for each county's economic indicators. Apply TDA to find topological features. Cluster counties by persistence diagrams. Test if topology predicts COVID recovery better than geography.
3. **Why it matters / what could go wrong** – Novel approach to economic resilience. Challenge: interpretability of topological features. Solution: validate against known recession/recovery patterns.

**Key references**
• Carlsson (2009) *Topology and Data*. Bulletin of the AMS 46(2).
• Feng & Porter (2023) *Topological Data Analysis of Economic Networks*. Nature Communications 14.

---

## Generation Replacement Dynamics: Youth Magnetism in Elderly Exit Markets *(BUCKET: Exploratory)*

**Abstract (≤ 60 words)**  
We test whether counties experiencing elderly population decline through mortality attract young adult in-migrants who occupy vacated housing. Using PEP components and ACS age-specific migration, we identify "generational replacement" markets. Comparing demographic and economic characteristics of high-replacement versus low-replacement counties reveals whether age succession represents opportunity or decline for receiving communities.

**Structured specification**
```json
{
  "novelty_rating":       "medium",
  "feasibility_rating":   "high",
  "complexity_rating":    "medium",
  "whimsy_rating":        "low",
  "geographic_level":     "county",
  "primary_metrics":      ["elderly mortality rate", "young adult in-migration rate", "replacement ratio"],
  "proposed_method":      "two-stage least squares with mortality as instrument",
  "robustness_checks":    ["exclude college counties", "test different age bands", "control for housing prices"],
  "expected_runtime":     "1-4 hr",
  "ethical_flags":        []
}
```

**Narrative plan**

1. **Data sources** – PEP deaths by age (PEPAGESEX), ACS Tables B07001 (migration by age), B25007 (tenure by age), B19037 (age of householder by income).
2. **Methodology** – Calculate elderly mortality rates from PEP. Instrument young adult migration with elderly deaths (addresses endogeneity). Test if high-mortality counties attract young migrants. Examine housing and income dynamics.
3. **Why it matters / what could go wrong** – Reveals intergenerational housing transitions. Risk: morbid framing. Reframe as natural demographic succession and opportunity creation.

**Key references**
• Myers & Pitkin (2009) *Demographic Forces and Turning Points in the American City*. Cityscape 11(2).
• Lee & Myers (2023) *Generational Housing Dynamics*. Housing Policy Debate 33(4).

---

## Round Number Magnetism: Population Clustering at Psychological Thresholds *(BUCKET: Whimsical)*

**Abstract (≤ 60 words)**  
We test whether county populations cluster around round numbers (100,000, 250,000, 500,000) more than random chance predicts. Using PEP annual estimates, we examine if growth rates slow as counties approach these thresholds and accelerate after crossing. This "round number stickiness" might reflect psychological anchoring in migration decisions or municipal policies targeting symbolic population goals.

**Structured specification**
```json
{
  "novelty_rating":       "high",
  "feasibility_rating":   "high",
  "complexity_rating":    "low",
  "whimsy_rating":        "high",
  "geographic_level":     "county",
  "primary_metrics":      ["distance to round number", "growth rate change", "threshold clustering index"],
  "proposed_method":      "regression discontinuity around round number thresholds",
  "robustness_checks":    ["test different round numbers", "placebo with random thresholds", "examine policy changes"],
  "expected_runtime":     "<1 hr",
  "ethical_flags":        []
}
```

**Narrative plan**

1. **Data sources** – PEP annual county population estimates (PEPANNRES) 2010-2024, ACS Table B01003 for verification.
2. **Methodology** – Calculate each county's distance to nearest round number threshold. Test if growth rates differ within 5% of thresholds. RD design comparing counties just below/above 100k, 500k. Check for bunching.
3. **Why it matters / what could go wrong** – Playful exploration of numerical psychology in demographics. Likely null result teaches statistical discipline. If significant, investigate municipal incentives at thresholds.

**Key references**
• Pope & Simonsohn (2011) *Round Numbers as Goals*. Psychological Science 22(1).
• Allen et al. (2016) *Reference-Dependent Preferences: Evidence from Marathon Runners*. Management Science 63(6).

---

## The Toponymic Travel Test: Do Long County Names Deter Migration? *(BUCKET: Whimsical)*

**Abstract (≤ 60 words)**  
We examine whether counties with longer names experience lower in-migration rates, testing if toponymic complexity creates psychological friction. Character count and syllable count serve as complexity measures. Controlling for actual distance and economic factors, we isolate the "name length penalty" in migration decisions. Heterogeneous effects by education level test if cognitive load affects different populations.

**Structured specification**
```json
{
  "novelty_rating":       "high",
  "feasibility_rating":   "high",
  "complexity_rating":    "low",
  "whimsy_rating":        "high",
  "geographic_level":     "county",
  "primary_metrics":      ["county name character count", "in-migration rate", "Google search difficulty score"],
  "proposed_method":      "OLS with name length as key variable",
  "robustness_checks":    ["use syllables instead", "test pronunciation difficulty", "control for name etymology"],
  "expected_runtime":     "<1 hr",
  "ethical_flags":        []
}
```

**Narrative plan**

1. **Data sources** – ACS county-to-county migration flows, ACS Tables B15003 (education), B01003 (population). County names from TIGER/Line files.
2. **Methodology** – Code county name length in characters and syllables. Regression: in-migration rate ~ name_length + gravity controls + economic factors. Test interaction with education levels.
3. **Why it matters / what could go wrong** – Whimsical test of cognitive friction in migration. Obviously spurious but fun. Real factors like Native American names may correlate with remoteness—control carefully.

**Key references**
• Alter & Oppenheimer (2009) *Uniting the Tribes of Fluency to Form a Metacognitive Nation*. Personality and Social Psychology Review 13(3).
• Shah & Oppenheimer (2007) *Easy Does It: The Role of Fluency in Cue Weighting*. Judgment and Decision Making 2(6).

---

## Birthday Bunching: Detecting Micro-Seasonality in Birth Timing *(BUCKET: Whimsical)*

**Abstract (≤ 60 words)**  
We test for non-random birth timing patterns at tract level, examining if certain dates show systematic over-representation. Using special ACS tabulations, we identify "birthday clusters" and test whether they correlate with parental characteristics like education or occupation. Poisson regression tests deviation from uniform distribution, revealing potential tax-timing, holiday effects, or cultural preferences in birth scheduling.

**Structured specification**
```json
{
  "novelty_rating":       "medium",
  "feasibility_rating":   "low",
  "complexity_rating":    "medium",
  "whimsy_rating":        "high",
  "geographic_level":     "county",
  "primary_metrics":      ["birth date concentration index", "deviation from uniform", "parental education level"],
  "proposed_method":      "Poisson regression with overdispersion tests",
  "robustness_checks":    ["test different aggregation levels", "control for hospital capacity", "examine c-section rates"],
  "expected_runtime":     "1-4 hr",
  "ethical_flags":        []
}
```

**Narrative plan**

1. **Data sources** – Requires special ACS tabulation for birth dates (potentially from vital statistics linkage), ACS Tables B15003 (education), B25010 (household size).
2. **Methodology** – Aggregate birth dates to county level for confidentiality. Test for clustering around specific dates (1st, 15th, holidays). Correlate patterns with parental demographics.
3. **Why it matters / what could go wrong** – Reveals birth timing manipulation for tax/benefits. Challenge: Census doesn't typically release birth dates. Workaround: may need to infer from age patterns.

**Key references**
• Dickert-Conlin & Chandra (1999) *Taxes and the Timing of Births*. Journal of Political Economy 107(1).
• LaLumia et al. (2015) *The EITC, Tax Refunds, and Unemployment Spells*. American Economic Journal: Policy 7(2).

---

## Migration Symmetry Breaking: When A→B ≠ B→A *(BUCKET: Whimsical)*

**Abstract (≤ 60 words)**  
We identify county pairs with maximally asymmetric migration flows—where many move A→B but few move B→A. Creating an "asymmetry index," we test whether these imbalanced pairs share systematic characteristics: elevation differences, name alphabetization, or pure randomness. The most extremely asymmetric flows might reveal hidden hierarchies in how Americans conceptualize geographic mobility.

**Structured specification**
```json
{
  "novelty_rating":       "high",
  "feasibility_rating":   "high",
  "complexity_rating":    "low",
  "whimsy_rating":        "high",
  "geographic_level":     "county",
  "primary_metrics":      ["flow asymmetry index", "directional flow ratio", "geographic hierarchy score"],
  "proposed_method":      "paired t-tests with asymmetry rankings",
  "robustness_checks":    ["weight by total flow volume", "test temporal stability", "exclude adjacent counties"],
  "expected_runtime":     "<1 hr",
  "ethical_flags":        []
}
```

**Narrative plan**

1. **Data sources** – ACS county-to-county migration flows (multiple years), ACS Tables B01003 (population), B19013 (median income).
2. **Methodology** – Calculate (Flow_AB - Flow_BA) / (Flow_AB + Flow_BA) for all pairs. Rank by asymmetry. Test if extreme pairs share attributes: always west→east? downhill? alphabetically forward?
3. **Why it matters / what could go wrong** – Playful exploration of migration psychology. Reveals how Americans conceptualize "moving up" geographically. Mostly just fun patterns in flow data.

**Key references**
• Kahneman & Tversky (1979) *Prospect Theory*. Econometrica 47(2).
• Ravenstein (1885) *The Laws of Migration*. Journal of the Statistical Society 48(2).

---

## Census Enthusiasm Geography: Early Response as Personality Proxy *(BUCKET: Whimsical)*

**Abstract (≤ 60 words)**  
We hypothesize that counties with higher week-one Census response rates contain more conscientious, civically-engaged populations. Testing whether early response rates correlate with other collective behaviors—voter turnout proxies, educational attainment, or household maintenance indicators—we map "civic enthusiasm geography." This reveals whether Census responsiveness captures broader community characteristics beyond mere compliance.

**Structured specification**
```json
{
  "novelty_rating":       "medium",
  "feasibility_rating":   "medium",
  "complexity_rating":    "low",
  "whimsy_rating":        "high",
  "geographic_level":     "county",
  "primary_metrics":      ["self-response rate", "week-one response rate", "civic engagement proxies"],
  "proposed_method":      "cross-sectional OLS with civic behavior outcomes",
  "robustness_checks":    ["control for demographics", "test urban/rural differences", "examine language barriers"],
  "expected_runtime":     "<1 hr",
  "ethical_flags":        []
}
```

**Narrative plan**

1. **Data sources** – Census 2020 response rate data (from Census Bureau operational metrics), ACS Tables B15003 (education), B16001 (language), B25035 (year built).
2. **Methodology** – Obtain county-level response rate data for first week of Census 2020. Correlate with education levels, housing upkeep proxies, and other civic indicators. Control for internet access and demographics.
3. **Why it matters / what could go wrong** – Maps collective personality traits geographically. Challenge: response rates affected by operational factors. Solution: focus on relative differences within states.

**Key references**
• Tourangeau et al. (2023) *Hard-to-Survey Populations*. Cambridge University Press.
• Groves & Couper (1998) *Nonresponse in Household Interview Surveys*. Wiley.