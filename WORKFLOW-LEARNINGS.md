# Workflow Meta-Learnings & Continuous Improvement

*Last updated: 2024-12-24*  
*Sessions covered: 1*

## Quick Reference - Current Best Practices

### Analysis Development
- **Always start with .R script** → debug & iterate → transfer to .Rmd when stable
- **Test incrementally**: Small samples first, build complexity gradually
- **Robust error handling**: Use `tryCatch()` for all API calls
- **Validate variables early**: Check ACS table availability before full analysis

### Statistical Standards
- **Multiple validation methods**: Correlation + t-tests + chi-square as appropriate
- **Report effect sizes**: Not just significance—quantify practical importance
- **Geographic controls**: Include state/regional analysis for context
- **Honest null reporting**: Contradicted/null findings equally valuable scientifically

### Documentation Quality
- **Executive summary first**: Lead with key findings and policy implications
- **Peer review simulation**: Use simulated Opus 4 critique to improve methodology
- **Inline statistics**: Embed results directly in text with `` `r` `` syntax
- **Professional formatting**: Consistent themes, accessible colors, multiple plot types

### Project Management
- **Real-time todo tracking**: Update TodoWrite throughout, not in batches
- **Logical git commits**: Group by analysis type (R scripts, supported, contradicted)
- **Clear file naming**: Avoid confusion between hypothesis files
- **Scope management**: Deep analysis of fewer hypotheses > shallow coverage of many

---

## Session Log

### 2024-12-24: Comprehensive Hypothesis Testing Session
**Scope**: 9 demographic hypotheses from Gemini generator, full R analysis + comprehensive .Rmd reports  
**Duration**: Full day session  
**Outcome**: 5 supported, 1 contradicted, 1 null, 1 strong evidence, 1 inconclusive

#### What Worked Exceptionally Well

**R-First Development Workflow**
- Starting with `.R` scripts for all analyses enabled rapid iteration and debugging
- Moving to `.Rmd` only after resolving technical issues prevented rendering failures
- Incremental testing (county samples before national analysis) caught issues early

**Comprehensive .Rmd Documentation**
- Simulated peer review process significantly improved analysis quality
- Executive summaries leading with policy implications enhanced readability
- Consistent formatting across reports created professional appearance
- Inline R statistics eliminated copy-paste errors and improved reproducibility

**Mixed Outcome Scientific Value**
- Contradicted hypothesis (Bachelor Pad Index) proved more scientifically valuable than weak support
- Null findings (Old House New Language) provided important baselines for future research
- Range of outcomes demonstrated methodological rigor rather than confirmation bias

#### Technical Lessons Learned

**Census API Management**
- Rate limits require strategic sampling - start with 8-10 counties maximum for flow analysis
- Variable validation essential: `load_variables()` to confirm availability across years
- PEP data post-2020 requires `vintage` parameter and `POPESTIMATE` variable
- County-level analysis more reliable than tract-level for API constraints

**Statistical Analysis Patterns**
- Multiple measures (correlation, t-tests, chi-square) provide robust validation
- Geographic controls (state, region) add crucial context to findings
- Effect size reporting more valuable than significance testing alone
- Visualization variety (scatter, box plots, maps) tells complete story

**Common tidycensus Issues Resolved**
- Variable name errors: B11007_017 doesn't exist for 65+ living alone (use B11010_005/012)
- GEOID format mismatches in flows data require string manipulation for joins
- `st_drop_geometry()` function requires explicit `library(sf)` loading
- PEP vintage parameters essential for post-2020 data accuracy

#### Workflow Process Improvements

**Hypothesis Selection Strategy**
- Initial confusion between opus vs gemini files → establish clear file naming conventions
- Mixed outcomes more valuable than cherry-picking supported hypotheses
- Comprehensive documentation should be planned from start, not afterthought

**Quality Assurance Framework**
- Peer review simulation using Opus 4 "Think Hard" mode catches methodological issues
- Documentation of revisions in response to review improves transparency
- Alternative explanation consideration strengthens causal interpretation

**Git Workflow Optimization**
- Logical commit groupings: R scripts → supported analyses → contradicted → supporting files
- Descriptive commit messages including key findings improve project navigation
- Progressive commits enable rollback if needed during development

#### Time Management Insights

**Realistic Duration Estimates**
- R script development: 1-2 hours per hypothesis including debugging
- Comprehensive .Rmd with peer review: 2-3 hours per report
- Supporting file organization and git workflow: 30-60 minutes
- Total for 9 analyses: Full day session realistic for quality output

**Efficiency Multipliers**
- Template reuse for .Rmd structure speeds development significantly
- Code snippet library for common visualizations and statistical tests
- Error pattern recognition makes debugging faster in later analyses

#### Most Valuable Analysis Insights

**Strongest Methodological Approaches**
- Solo Boomers: Clear empirical support + immediate policy relevance + robust methodology
- Round Number Magnetism: Novel statistical approach revealing hidden biases in official data
- Migration Symmetry Breaking: Sophisticated network analysis uncovering invisible patterns

**Scientific Integrity Demonstrations**
- Bachelor Pad Index contradiction more valuable than weak confirmation
- Heat Refuge Highways inconclusive findings establish important baseline
- Old House New Language null result challenges conventional urban theory

**Policy Bridge Success**
- Executive summaries connecting statistical findings to actionable recommendations
- Regional variation analysis informing targeted policy approaches
- Future research agendas providing clear next steps for practitioners

#### Areas Identified for Future Enhancement

**Technical Infrastructure**
- Implement caching strategy for intermediate data to reduce API calls
- Develop automated variable validation before full analysis
- Create parallel processing approach for independent county analyses

**Methodological Sophistication**
- Incorporate temporal analysis for stronger causal inference
- Add spatial analysis methods (Moran's I, spatial regression)
- Develop instrumental variable approaches for causal identification

**Communication Optimization**
- Strengthen policy bridge between findings and recommendations
- Balance technical rigor with accessibility for broader audiences
- Create quick-reference summaries for policy makers

---

## Evolved Standards

### Analysis Development Standards (Established 2024-12-24)
- **R-first workflow**: Always develop in .R before .Rmd transfer
- **Incremental complexity**: Start small, build systematically
- **Multiple validation**: Use diverse statistical tests for robustness
- **Geographic context**: Include state/regional controls

### Documentation Standards (Established 2024-12-24)
- **Executive summary priority**: Lead with findings and implications
- **Peer review simulation**: Systematic critique improves quality
- **Inline statistics**: Embed results directly in narrative
- **Professional formatting**: Consistent themes and accessible visualization

### Quality Assurance Standards (Established 2024-12-24)
- **Mixed outcome value**: Null and contradicted findings equally important
- **Methodological transparency**: Document limitations and assumptions
- **Revision tracking**: Record responses to peer review feedback
- **Reproducibility priority**: Code should run without modification

---

## Common Pitfalls & Solutions

### Technical Issues
**API Rate Limits**
- *Problem*: Census API throttling during large data requests
- *Solution*: Start with 8-10 county samples, use `tryCatch()` error handling
- *Prevention*: Test API calls with minimal data before full analysis

**Variable Availability**
- *Problem*: Variables may not exist across all years/geographies
- *Solution*: Use `load_variables()` for validation before analysis
- *Prevention*: Check variable definitions in Census documentation

**GEOID Format Mismatches**
- *Problem*: Different functions return different GEOID formats
- *Solution*: Use string manipulation to align formats before joins
- *Prevention*: Print sample GEOIDs from each dataset before joining

### Methodological Issues
**Confirmation Bias**
- *Problem*: Tendency to emphasize supporting evidence over contradictions
- *Solution*: Plan for comprehensive documentation regardless of outcome
- *Prevention*: Establish analysis plan before seeing results

**Correlation vs Causation**
- *Problem*: Overinterpreting correlational findings as causal
- *Solution*: Explicit discussion of alternative explanations and limitations
- *Prevention*: Frame hypotheses clearly as associational vs causal from start

**Geographic Aggregation**
- *Problem*: County-level analysis may miss important local variation
- *Solution*: Acknowledge scale limitations and recommend finer analysis
- *Prevention*: Consider appropriate geographic scale during hypothesis design

### Workflow Issues
**Scope Creep**
- *Problem*: Analysis expanding beyond manageable complexity
- *Solution*: Focus on fewer hypotheses with deeper analysis
- *Prevention*: Establish clear scope boundaries before beginning

**Documentation Lag**
- *Problem*: Delaying comprehensive write-up until after analysis
- *Solution*: Plan .Rmd documentation from beginning of analysis
- *Prevention*: Consider documentation time in project estimates

**File Organization**
- *Problem*: Confusion over which files contain which hypotheses
- *Solution*: Clear naming conventions and directory structure
- *Prevention*: Establish file naming standards before analysis begins

---

*This document evolves with each analysis session. Next session should add new learnings and update best practices based on experience.*