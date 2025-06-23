SUBURBAN POVERTY DRIFT (BUCKET: Serious)

Abstract (≤ 60 words)
Poverty rates may be rising faster in suburban tracts adjacent to historically high-poverty urban cores, suggesting outward diffusion of disadvantage since 2014-2018.

Structured specification

{
  "novelty_rating":       "medium",
  "feasibility_rating":   "high",
  "complexity_rating":    "medium",
  "whimsy_rating":        "low",
  "geographic_level":     "tract",
  "primary_metrics":      ["poverty rate change", "spatial lag of poverty"],
  "proposed_method":      "spatial lag regression",
  "robustness_checks":    ["alternate contiguity", "MOE propagation"],
  "expected_runtime":     "1–4 hr",
  "ethical_flags":        []
}

Narrative plan
	1.	Data sources – ACS 5-year C17002 (income-to-poverty ratio) 2014-2018 & 2020-2024.
	2.	Methodology – Compute spatially lagged baseline poverty; regress poverty-rate change on neighbor baseline values with controls.
	3.	Why it matters / what could go wrong – Informs suburban service planning; differential-privacy noise mitigated by tract-level aggregation.

Key references
• Kneebone & Berube (2022) Confronting Suburban Poverty.

RURAL YOUTH OUT-MIGRATION ACCELERATION (BUCKET: Serious)

Abstract (≤ 60 words)
Hypothesis: rural counties lost prime 18-34 population more rapidly 2019-2023 compared with pre-2015 trends, measured by PEP components and ACS migration flows.

Structured specification

{
  "novelty_rating":       "medium",
  "feasibility_rating":   "high",
  "complexity_rating":    "medium",
  "whimsy_rating":        "low",
  "geographic_level":     "county",
  "primary_metrics":      ["PEP net migration 18-34", "ACS flow rate"],
  "proposed_method":      "event-study panel",
  "robustness_checks":    ["placebo periods", "regional FE"],
  "expected_runtime":     "1–4 hr",
  "ethical_flags":        []
}

Narrative plan
	1.	Data sources – PEP age-specific migration components 2010-2023; ACS county-to-county flow files 2011-2023.
	2.	Methodology – Event study with 2019 shock; compare rural vs metro counties (USDA RUCC crosswalk optional).
	3.	Why it matters / what could go wrong – Highlights workforce challenges; flow MOEs large—weight inversely.

Key references
• Johnson (2024) Rural Demographic Change.

HOUSING VACANCY PERSISTENCE HOTSPOTS (BUCKET: Serious)

Abstract (≤ 60 words)
Tracts with the highest 2020 vacancy rates continued to diverge through 2024, indicating sticky oversupply clusters.

Structured specification

{
  "novelty_rating":       "medium",
  "feasibility_rating":   "high",
  "complexity_rating":    "medium",
  "whimsy_rating":        "low",
  "geographic_level":     "tract",
  "primary_metrics":      ["vacancy rate change"],
  "proposed_method":      "quantile regression",
  "robustness_checks":    ["alt vacancy thresholds", "MOE simulation"],
  "expected_runtime":     "1–4 hr",
  "ethical_flags":        []
}

Narrative plan
	1.	Data sources – Decennial 2020 H4 vacancy; ACS 5-year B25002 2020-2024.
	2.	Methodology – Quantile regression of vacancy-rate change on baseline vacancy with housing-age controls.
	3.	Why it matters / what could go wrong – Guides revitalization; DP noise moderate.

Key references
• Mallach (2022) Vacant Housing Dynamics.

METRO-LEVEL POPULATION ESTIMATE DIVERGENCE (BUCKET: Serious)

Abstract (≤ 60 words)
Identify large metros where PEP total-population estimates diverge most from ACS 1-year totals 2010-2024, hypothesizing systematic undercount in fast-growing areas.

Structured specification

{
  "novelty_rating":       "high",
  "feasibility_rating":   "high",
  "complexity_rating":    "medium",
  "whimsy_rating":        "low",
  "geographic_level":     "metro",
  "primary_metrics":      ["PEP-ACS percent gap"],
  "proposed_method":      "time-series clustering",
  "robustness_checks":    ["alt error metrics", "sensitivity to MOE"],
  "expected_runtime":     "1–4 hr",
  "ethical_flags":        []
}

Narrative plan
	1.	Data sources – PEP total population (metropolitan); ACS 1-year B01003 2010-2024.
	2.	Methodology – Calculate annual percent gaps; cluster metros by trajectory; test predictors (growth rate).
	3.	Why it matters / what could go wrong – Flags allocation formula risks; ACS MOE incorporated.

Key references
• Spielman (2023) Population Estimation Uncertainty.

SENIOR MIGRATION TO TAX-FRIENDLY STATES (BUCKET: Serious)

Abstract (≤ 60 words)
Hypothesis: net in-migration of 65+ residents rose faster 2018-2023 in states without income tax, measured via ACS migration flows and PEP components.

Structured specification

{
  "novelty_rating":       "medium",
  "feasibility_rating":   "medium",
  "complexity_rating":    "medium",
  "whimsy_rating":        "low",
  "geographic_level":     "state",
  "primary_metrics":      ["65+ net migration rate"],
  "proposed_method":      "difference-in-differences",
  "robustness_checks":    ["placebo age groups", "income controls"],
  "expected_runtime":     "1–4 hr",
  "ethical_flags":        []
}

Narrative plan
	1.	Data sources – PEP age-specific migration; ACS state-to-state flows 2017-2023.
	2.	Methodology – Treat no-tax states as treated; DiD on senior migration rates.
	3.	Why it matters / what could go wrong – Retirement-policy insight; migration flow MOE large.

Key references
• Partridge (2024) Retirement Migration & Amenities.

HOUSEHOLD SIZE COMPRESSION REVERSAL (BUCKET: Exploratory)

Abstract (≤ 60 words)
Assess whether tracts with largest rent increases 2014-2024 show declining average household size, indicating loosening crowding.

Structured specification

{
  "novelty_rating":       "medium",
  "feasibility_rating":   "high",
  "complexity_rating":    "medium",
  "whimsy_rating":        "medium",
  "geographic_level":     "tract",
  "primary_metrics":      ["median rent change", "household size change"],
  "proposed_method":      "fixed-effects regression",
  "robustness_checks":    ["income controls", "lag structure"],
  "expected_runtime":     "1–4 hr",
  "ethical_flags":        []
}

Narrative plan
	1.	Data sources – ACS 5-year B25064 (rent), B25010 (household size) 2010-2024.
	2.	Methodology – FE panel regressions; rent growth predicting household-size change.
	3.	Why it matters / what could go wrong – Signals affordability impacts; rent MOE handled.

Key references
• Ganong & Shoag (2021) Housing Constraints and Households.

WORK-FROM-HOME AND TRAFFIC TIME REBOUND (BUCKET: Exploratory)

Abstract (≤ 60 words)
Did tracts with highest 2020 work-from-home shares see slower increases in average commute time through 2024?

Structured specification

{
  "novelty_rating":       "medium",
  "feasibility_rating":   "high",
  "complexity_rating":    "medium",
  "whimsy_rating":        "medium",
  "geographic_level":     "tract",
  "primary_metrics":      ["WFH share", "commute time change"],
  "proposed_method":      "propensity-score matching",
  "robustness_checks":    ["alt WFH cutoff", "placebo years"],
  "expected_runtime":     "1–4 hr",
  "ethical_flags":        []
}

Narrative plan
	1.	Data sources – ACS 5-year B08006 (means of transportation) & B08303 (commute time) 2014-2024.
	2.	Methodology – Match high-WFH tracts to controls; estimate ATT on commute-time change.
	3.	Why it matters / what could go wrong – Evaluates mobility impacts; self-selection bias.

Key references
• Dingel & Neiman (2022) Remote Work Geography.

DENSITY VS CELL-ONLY HOUSEHOLDS (BUCKET: Exploratory)

Abstract (≤ 60 words)
Hypothesis: higher tract population density correlates with greater share of cell-only (no landline) households.

Structured specification

{
  "novelty_rating":       "low",
  "feasibility_rating":   "high",
  "complexity_rating":    "low",
  "whimsy_rating":        "medium",
  "geographic_level":     "tract",
  "primary_metrics":      ["population density", "cell-only share"],
  "proposed_method":      "Spearman correlation",
  "robustness_checks":    ["log density", "metro FE"],
  "expected_runtime":     "<1 hr",
  "ethical_flags":        []
}

Narrative plan
	1.	Data sources – ACS 5-year B01003 (population); TIGER land area; B28002 (phone service).
	2.	Methodology – Compute density; correlate with cell-only share.
	3.	Why it matters / what could go wrong – Tech-adoption geography; small counts in rural tracts noisy.

Key references
• Pew (2022) Mobile-Only Households.

PEP-ACS AGE PYRAMID MISALIGNMENT (BUCKET: Exploratory)

Abstract (≤ 60 words)
Identify counties where PEP age-group estimates differ most from ACS 5-year distributions, exploring consistency of age-pyramid inputs.

Structured specification

{
  "novelty_rating":       "high",
  "feasibility_rating":   "medium",
  "complexity_rating":    "high",
  "whimsy_rating":        "medium",
  "geographic_level":     "county",
  "primary_metrics":      ["absolute age-share gap"],
  "proposed_method":      "hierarchical clustering",
  "robustness_checks":    ["alternate age bins"],
  "expected_runtime":     "4–12 hr",
  "ethical_flags":        []
}

Narrative plan
	1.	Data sources – PEP county age estimates 2010-2023; ACS 5-year age table S0101.
	2.	Methodology – Compute absolute share gaps by age; cluster counties; examine correlates.
	3.	Why it matters / what could go wrong – Improves estimate reconciliation; ACS DP noise minor at county.

Key references
• Spielman (2023) Population Estimation Uncertainty.

MULTI-SCALE SEGREGATION SURGE INDEX (BUCKET: Exploratory)

Abstract (≤ 60 words)
Compute diffusion-based multiscale segregation for tracts 2010 vs 2020 to flag metros with the sharpest increases.

Structured specification

{
  "novelty_rating":       "high",
  "feasibility_rating":   "medium",
  "complexity_rating":    "high",
  "whimsy_rating":        "medium",
  "geographic_level":     "metro",
  "primary_metrics":      ["multiscale segregation score"],
  "proposed_method":      "time-series clustering",
  "robustness_checks":    ["alt spatial weights"],
  "expected_runtime":     "4–12 hr",
  "ethical_flags":        []
}

Narrative plan
	1.	Data sources – Decennial 2010 & 2020 PL race counts.
	2.	Methodology – Build tract adjacency; compute diffusion segregation; cluster metro trajectories.
	3.	Why it matters / what could go wrong – Early inequality warning; DP noise considered.

Key references
• Reardon (2024) Multiscale Inequality.

DONUT-SHAPED TRACT IDs & POP GROWTH (BUCKET: Whimsical)

Abstract (≤ 60 words)
Do tracts whose GEOID ends with “00” (“donut” IDs) grow faster than others since 2010? A playful numerology test.

Structured specification

{
  "novelty_rating":       "high",
  "feasibility_rating":   "high",
  "complexity_rating":    "low",
  "whimsy_rating":        "high",
  "geographic_level":     "tract",
  "primary_metrics":      ["percent population change"],
  "proposed_method":      "t-test",
  "robustness_checks":    ["state FE", "placebo suffixes"],
  "expected_runtime":     "<1 hr",
  "ethical_flags":        []
}

Narrative plan
	1.	Data sources – Decennial 2010 & 2020 B01003 population.
	2.	Methodology – Compare growth rates for GEOIDs ending “00” vs others.
	3.	Why it matters / what could go wrong – Pure whimsy; suffix assignment arbitrary but harmless.

Key references
• None (playful analysis).

PRIME-NUMBERED COUNTY FIPS & HOUSING PRICES (BUCKET: Whimsical)

Abstract (≤ 60 words)
Are counties with prime-numbered FIPS codes richer? Test median housing value differences 2020-2024.

Structured specification

{
  "novelty_rating":       "medium",
  "feasibility_rating":   "high",
  "complexity_rating":    "low",
  "whimsy_rating":        "high",
  "geographic_level":     "county",
  "primary_metrics":      ["median housing value"],
  "proposed_method":      "Mann-Whitney U",
  "robustness_checks":    ["regional FE", "income controls"],
  "expected_runtime":     "<1 hr",
  "ethical_flags":        []
}

Narrative plan
	1.	Data sources – ACS 5-year B25077 (median value) 2020-2024.
	2.	Methodology – Flag prime FIPS; compare distributions.
	3.	Why it matters / what could go wrong – Numerology fun; ensures no policy inference.

Key references
• None.

SAME-NAME COUNTY MIGRATION MAGNETISM (BUCKET: Whimsical)

Abstract (≤ 60 words)
Do people move more often between counties that share the same name (e.g., “Franklin” to “Franklin”)? Examine ACS flow counts 2017-2023.

Structured specification

{
  "novelty_rating":       "high",
  "feasibility_rating":   "medium",
  "complexity_rating":    "medium",
  "whimsy_rating":        "high",
  "geographic_level":     "county",
  "primary_metrics":      ["same-name flow share"],
  "proposed_method":      "baseline-adjusted ratio",
  "robustness_checks":    ["population weighting"],
  "expected_runtime":     "1–4 hr",
  "ethical_flags":        []
}

Narrative plan
	1.	Data sources – ACS county-to-county flow files 2017-2023.
	2.	Methodology – Identify flows where origin & destination county names match; compare to expected by chance.
	3.	Why it matters / what could go wrong – Lighthearted toponymy; small flows noisy.

Key references
• None.

WORK-FROM-HOME & BABY BOOMLETS (BUCKET: Whimsical)

Abstract (≤ 60 words)
Hypothesis: tracts above 50 % work-from-home share in 2021 saw greater 2022 fertility-rate bumps than on-site tracts.

Structured specification

{
  "novelty_rating":       "medium",
  "feasibility_rating":   "medium",
  "complexity_rating":    "medium",
  "whimsy_rating":        "high",
  "geographic_level":     "tract",
  "primary_metrics":      ["general fertility rate", "WFH share"],
  "proposed_method":      "difference-in-means",
  "robustness_checks":    ["income controls", "alt cutoff"],
  "expected_runtime":     "1–4 hr",
  "ethical_flags":        []
}

Narrative plan
	1.	Data sources – ACS 5-year B08006 (WFH) 2021; B13016 (fertility) 2022.
	2.	Methodology – Compare fertility-rate change by WFH threshold.
	3.	Why it matters / what could go wrong – Playful lifestyle-demography link; fertility counts small.

Key references
• Martin (2023) Fertility Trends Post-COVID.

LATITUDE & SINGLE-PERSON HOUSEHOLD SHARE (BUCKET: Whimsical)

Abstract (≤ 60 words)
Are northerly counties lonelier? Test if higher latitude predicts larger share of single-person households.

Structured specification

{
  "novelty_rating":       "low",
  "feasibility_rating":   "high",
  "complexity_rating":    "low",
  "whimsy_rating":        "high",
  "geographic_level":     "county",
  "primary_metrics":      ["latitude", "single-person household share"],
  "proposed_method":      "OLS with quadratic term",
  "robustness_checks":    ["region FE"],
  "expected_runtime":     "<1 hr",
  "ethical_flags":        []
}

Narrative plan
	1.	Data sources – County centroids (TIGER); ACS 5-year B11001 (household composition) 2020-2024.
	2.	Methodology – Regress single-person household share on latitude, quadratic term.
	3.	Why it matters / what could go wrong – Fun climate-culture angle; causality spurious.

Key references
• None.

TRACT GEOID DIGIT SUM & POPULATION GROWTH (BUCKET: Whimsical)

Abstract (≤ 60 words)
Do tracts whose GEOID digit sum is divisible by 9 boast higher 2010-2020 growth? Numerology meets demography.

Structured specification

{
  "novelty_rating":       "high",
  "feasibility_rating":   "high",
  "complexity_rating":    "low",
  "whimsy_rating":        "high",
  "geographic_level":     "tract",
  "primary_metrics":      ["population growth 2010-2020"],
  "proposed_method":      "χ² test",
  "robustness_checks":    ["state FE", "alternate divisors"],
  "expected_runtime":     "<1 hr",
  "ethical_flags":        []
}

Narrative plan
	1.	Data sources – Decennial 2010 & 2020 B01003 population.
	2.	Methodology – Compute digit-sum of GEOID; classify divisible by 9; compare growth distributions.
	3.	Why it matters / what could go wrong – Purely whimsical; ensures disclosure safety.

Key references
• None.