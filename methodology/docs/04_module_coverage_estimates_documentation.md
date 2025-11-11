# Module 4: Coverage Estimates

## 1. Overview (What & Why)

### What does this module do?

This module estimates health service coverage by integrating three key data sources: adjusted health service volumes from HMIS (Module 2), population projections from the United Nations, and household survey data from MICS/DHS. It helps answer the question: "What percentage of the target population received this health service?"

The module operates in two distinct parts.

**Part 1** calculates target population sizes (denominators) using multiple methods and automatically selects the best option for each health indicator by comparing results against survey benchmarks.

**Part 2** allows users to refine these selections, choose specific denominators based on programmatic knowledge, and project survey estimates forward in time using administrative data trends to fill gaps where surveys are unavailable.

Together, these parts transform raw service counts into meaningful coverage estimates that can be analyzed for trends, compared across regions, and used for policy decisions.

### Why is it needed in the FASTR pipeline?

Understanding coverage is essential for monitoring health system performance and equity. While Module 2 provides adjusted service volumes, these numbers alone don't tell us whether services are reaching their intended populations. Coverage estimates provide context by comparing service delivery to population need.

This module addresses some challenges in coverage estimation:

- **Multiple data sources**: Integrates HMIS data with survey data

- **Denominator uncertainty**: Different methods for estimating target populations may yield different results; the module systematically evaluates options

- **Temporal gaps**: Surveys occur every 3-5 years; the module projects estimates for intervening years using administrative trends

- **Subnational analysis**: Enables coverage monitoring at national, provincial, and district levels

### Quick Summary

| Component | Details |
|-----------|---------|
| **Inputs** | M2_adjusted_data (national & subnational) from Module 2<br>Survey data (MICS/DHS) from GitHub repository<br>Population data (UN WPP) from GitHub repository |
| **Outputs** | M4_denominators (national, admin2, admin3) - calculated target populations<br>M4_combined_results (national, admin2, admin3) - coverage estimates with all denominators<br>M5_coverage_estimation (national, admin2, admin3) - final coverage with projections |
| **Purpose** | Estimate health service coverage by comparing service volumes to target populations, validated against survey benchmarks |

### Part 1 and Part 2 Explained

**Part 1: Denominator Calculation and Selection**

- Calculates target populations (denominators) using multiple approaches: HMIS-based (from ANC1, delivery, BCG, Penta1) and population-based (UN WPP)

- Compares coverage estimates from each denominator against survey data

- Automatically selects the "best" denominator for each indicator by minimizing error

- Outputs: Denominator datasets and combined results showing all options

**Part 2: Denominator Selection and Survey Projection**

- Allows users to override automatic selections and choose specific denominators

- Calculates year-over-year coverage trends from administrative data

- Projects survey estimates forward using HMIS trends to fill temporal gaps

- Outputs: Final coverage estimates combining HMIS, survey, and projected values

---

## 2. How It Works

### High-Level Workflow

#### Part 1: Denominator Calculation and Selection

**Step 1: Load and Prepare Data Sources**
The module begins by loading three data sources and ensuring they're compatible. HMIS data is aggregated from monthly to annual totals. Survey data is harmonized (DHS prioritized over MICS) and forward-filled to create continuous time series. Population data is filtered to the target country.

**Step 2: Calculate Multiple Denominator Options**
For each health indicator, the module calculates several possible target populations:

- **Service-based denominators**: Using HMIS volumes divided by survey coverage (e.g., if 10,000 women received ANC1 and survey says coverage is 80%, estimated pregnancies = 10,000/0.80 = 12,500)

- **Population-based denominators**: Using UN population projections and birth rates

- Each denominator is adjusted for demographic factors (pregnancy loss, stillbirths, mortality rates) to match the indicator's target age group

**Step 3: Calculate Coverage for Each Denominator**
The module computes coverage by dividing the service volume by each denominator option. This produces multiple coverage estimates per indicator, each based on a different population assumption.

**Step 4: Compare to Survey Benchmarks**
Each coverage estimate is compared to survey data using squared error calculation. The survey serves as the "truth" benchmark since it's based on representative household sampling.

**Step 5: Select the Best Denominator**
The denominator producing the lowest error (closest match to survey) is automatically selected as "best." The selection prioritizes HMIS-based denominators over population projections to ensure data is driven by observed service delivery.

**Step 6: Generate Outputs**
The module saves denominator datasets for transparency and combined results files showing coverage from all denominators plus the selected best option.

**Step 7: Repeat for Subnational Levels**
If subnational data is available, the process repeats for administrative level 2 (e.g., provinces) and level 3 (e.g., districts), with fallback mechanisms to handle missing local survey data.

#### Part 2: Denominator Selection and Survey Projection

**Step 1: User Configuration**
Users review Part 1 results and configure denominator selections for each indicator. Options include using the automatic "best" selection or overriding with a specific denominator based on programmatic knowledge.

**Step 2: Filter to Selected Denominators**
The module filters Part 1's combined results to include only user-selected denominators, creating a focused dataset for analysis.

**Step 3: Calculate Coverage Trends**
Year-over-year changes (deltas) in HMIS-based coverage are calculated. This shows whether coverage is increasing, decreasing, or stable over time.

**Step 4: Identify Survey Baseline**
For each geographic area and indicator, the most recent survey observation is identified as the baseline anchor point for projections.

**Step 5: Project Survey Estimates Forward**
The module extends survey coverage estimates into years without surveys by applying HMIS trends. The projection uses: Last survey value + (Current year HMIS coverage - Survey year HMIS coverage). This preserves the survey calibration while incorporating observed trends.

**Step 6: Combine All Estimates**
The final output merges three types of estimates:

- **HMIS-based coverage**: Direct calculation from service volumes and selected denominators

- **Original survey values**: Actual household survey observations

- **Projected survey coverage**: Survey estimates extended using HMIS trends

**Step 7: Save Final Outputs**
Results are saved with standardized column structures for each administrative level, ready for visualization and reporting.

### Workflow Diagram

<iframe src="../images/mod4_workflow.html" width="100%" height="800" style="border: 1px solid #ccc; border-radius: 4px;" title="Module 4 Interactive Workflow"></iframe>

### Key Decision Points

**1. Which denominator to use?**
Part 1 automatically selects based on alignment with survey data, but users can override in Part 2. The choice affects whether coverage is anchored to service delivery patterns (HMIS-based) or demographic projections (population-based).

**2. How to handle survey gaps?**
Surveys occur infrequently (every 3-5 years). The module forward-fills survey values in Part 1 (assumes constant coverage until next survey) and uses projection in Part 2 (incorporates HMIS trends).

**3. Should subnational analysis use local or national survey data?**
For **immunization indicators only**, when local survey data is unavailable at the subnational level, the module imputes national survey values. This assumes national immunization coverage rates apply to subnational areas, which may not hold in all contexts. This fallback mechanism is **not applied** to other health indicators (maternal health, child health), which require local survey data for subnational analysis.

**4. How to adjust denominators for different target populations?**
Each health indicator targets a specific population (e.g., pregnant women for ANC, infants for vaccines). The module applies sequential demographic adjustments (pregnancy loss, stillbirths, mortality) to align denominators with target populations.

### What Happens to the Data

**Input Integration**: The module combines three distinct data sources: facility-level service volumes from HMIS (aggregated annually by geographic area), household survey coverage estimates (harmonized across different survey years and forward-filled to create continuous time series), and population projections (filtered to extract age-specific target populations for each health indicator).

**Denominator Construction**: Using the relationship between HMIS service volumes and survey-based coverage estimates, the module calculates HMIS-implied denominators that represent the population that would need to exist for the observed service volumes to match survey coverage rates. These denominators are adjusted for indicator-specific target populations through sequential demographic corrections accounting for pregnancy loss, stillbirths, and mortality.

**Coverage Calculation**: The module calculates multiple coverage estimates by dividing service volumes by different denominator options (population-based, HMIS-implied, hybrid approaches). Each coverage estimate is then compared against survey benchmarks to identify which denominator produces the most plausible results for each indicator, balancing between HMIS data quality and population estimate accuracy.

**Temporal Projection**: For years beyond the most recent survey, the module projects coverage estimates forward by combining the last observed survey value with HMIS-based trends. This produces complete coverage time series that leverage both the validity of survey data and the timeliness of routine HMIS reporting, with all estimates accompanied by metadata indicating data source and projection methodology.

### Analysis Outputs and Visualization

The FASTR analysis generates coverage estimate visualizations at multiple geographic levels:

**1. Coverage Calculated from HMIS Data (National)**

Time series showing coverage estimates calculated from HMIS service volumes at the national level, comparing HMIS-based estimates with survey benchmarks.

![Coverage calculated from HMIS data at national level.](images/Module4_1_Coverage_HMIS_National.png)

**2. Coverage Calculated from HMIS Data (Admin Area 2)**

Coverage estimates disaggregated to admin area 2 level, enabling identification of subnational variation in service coverage.

![Coverage calculated from HMIS data at admin area 2 level.](images/Module4_2_Coverage_HMIS_Admin2.png)

**3. Coverage Calculated from HMIS Data (Admin Area 3)**

Highly disaggregated coverage estimates at admin area 3 level for detailed geographic analysis where data quality permits.

![Coverage calculated from HMIS data at admin area 3 level.](images/Module4_3_Coverage_HMIS_Admin3.png)

**Interpretation Guide:**

- **Survey points**: Black line with black points representing validated household survey coverage estimates

- **HMIS-based estimates**: Grey line with grey points showing coverage calculated from routine facility data

- **Projected coverage**: Red line with red points showing forward projections combining survey benchmarks with HMIS trends

- **Geographic disaggregation**: Lower administrative levels enable targeting of interventions to areas with coverage gaps

---

## 3. Detailed Reference

### Part 1: Denominator Calculation (Technical Details)

#### Configuration Parameters

The module begins with several configurable parameters that control the analysis:

```r
COUNTRY_ISO3 <- "ISO3"                         # ISO3 country code (e.g., "RWA", "UGA", "ZMB")
SELECTED_COUNT_VARIABLE <- "count_final_both"  # Which adjusted count to use
ANALYSIS_LEVEL <- "NATIONAL_PLUS_AA2"          # Geographic scope
```

**Analysis Level Options:**

- `NATIONAL_ONLY`: National-level analysis only
- `NATIONAL_PLUS_AA2`: National + administrative area 2 (e.g., provinces)
- `NATIONAL_PLUS_AA2_AA3`: National + admin area 2 + admin area 3 (e.g., districts)

**Demographic Adjustment Rates:**
```r
PREGNANCY_LOSS_RATE <- 0.03      # 3% pregnancy loss
TWIN_RATE <- 0.015               # 1.5% twin births
STILLBIRTH_RATE <- 0.02          # 2% stillbirths
P1_NMR <- 0.039                  # Neonatal mortality rate
P2_PNMR <- 0.028                 # Post-neonatal mortality rate
INFANT_MORTALITY_RATE <- 0.063   # Infant mortality rate
UNDER5_MORTALITY_RATE <- 0.103   # Under-5 mortality rate
```

**Count Variable Options:**

- `count_final_none`: No adjustments (raw reported data)
- `count_final_outlier`: Outlier adjustment only
- `count_final_completeness`: Completeness adjustment only
- `count_final_both`: Both adjustments **(recommended)**


#### Input Data Sources

Part 1 integrates three primary data sources:

**1. HMIS Adjusted Data** (from Module 2)

- National: `M2_adjusted_data_national.csv`
- Subnational: `M2_adjusted_data_admin_area.csv`
- Contains service volumes by indicator, area, and time period

**2. Survey Data** (DHS/MICS)

- Source: GitHub repository (unified survey dataset)
- Provides coverage benchmarks for comparison
- DHS data prioritized over MICS when both available

**3. Population Data** (UN WPP)

- Source: GitHub repository
- Provides population-based denominators
- Includes total population, births, under-1, and under-5 populations

**Additional Data Context:**

**Population Projections (UN WPP)**
Sourced from the United Nations World Population Prospects, these estimates provide age-specific and total population figures used to calculate denominators for coverage estimates. These projections account for demographic trends, including fertility, mortality, and migration.

**Survey Data - MICS**
The Multiple Indicator Cluster Surveys (MICS), conducted by UNICEF, provide household survey-based estimates for key health indicators, including coverage of maternal and child health services.

**Survey Data - DHS**
The Demographic and Health Surveys (DHS), conducted by USAID, provide survey data on health service utilization, including immunization rates and maternal care coverage.

#### Core Functions Documentation

??? "`process_hmis_adjusted_volume()`"

    **Purpose**: Prepares HMIS data for denominator calculation

    **Input**:

    - Adjusted volume data from Module 2
    - Selected count variable (e.g., `count_final_both`)

    **Processing**:

    - Aggregates monthly data to annual totals
    - Counts number of reporting months per year
    - Pivots data to wide format (one column per indicator)

    **Output**:

    - `annual_hmis`: Annual service counts by area and year
    - `hmis_countries`: List of countries in dataset
    - `hmis_iso3`: ISO3 code(s) present

    **Example Structure**:

    ```
    admin_area_1  admin_area_2  year  countanc1  countdelivery  ...  nummonth
    Country_Name  Province_A    2020  12500      10200          ...  12
    Country_Name  Province_A    2021  13000      10500          ...  11
    ```

??? "`process_survey_data()`"

    **Purpose**: Harmonizes and extends survey data for use as coverage benchmarks

    **Input**:

    - Survey data (DHS/MICS)
    - HMIS country names and ISO3 codes
    - Optional national reference (for subnational fallback)

    **Key Processing Steps**:

    1. **Harmonization**
       - Recodes indicator names (e.g., `polio1` → `opv1`, `vitamina` → `vitaminA`)
       - Normalizes source labels (`dhs`, `mics`)
       - Filters by country and date range

    2. **Source Prioritization**
       - When both DHS and MICS exist for same year/area/indicator
       - DHS is selected preferentially
       - Preserves source details for transparency

    3. **Fallback Logic**
       - If `sba` missing, uses `delivery` values
       - If `pnc1_mother` missing, uses `pnc1` values
       - Subnational areas use national values when local data unavailable (for BCG, Penta1, Penta3)

    4. **Forward-Filling**
       - Creates complete time series for each area
       - Carries forward last observed value (`na.locf`)
       - Creates "carry" columns (e.g., `anc1carry`, `bcgcarry`)

    **Output**:

    - `carried`: Extended survey data with forward-filled values
    - `raw`: Raw survey observations (wide format)
    - `raw_long`: Raw survey observations (long format) with source details

??? "`process_national_population_data()`"

    **Purpose**: Prepares UN WPP population estimates for denominator calculation

    **Input**:

    - Population estimates (UN WPP)
    - HMIS country identifiers

    **Processing**:

    - Filters to national level and target country
    - Extracts key population indicators:
      - `crudebr_unwpp`: Crude birth rate
      - `poptot_unwpp`: Total population
      - `totu1pop_unwpp`: Under-1 population

    **Output**:

    - `wide`: Population indicators in wide format
    - `raw_long`: Population data in long format with source tracking

??? "`calculate_denominators()`"

    **Purpose**: Calculates all possible denominators from HMIS and population data. This is the core function that generates multiple denominator estimates.

    **Input**:

    - `hmis_data`: Annual service counts
    - `survey_data`: Survey reference values (carried forward)
    - `population_data`: UN WPP estimates (national only)

    **Denominator Types Calculated**:

    **A. Service-Based Denominators** (using HMIS numerator ÷ survey coverage):

    1. **From ANC1**:
       - `danc1_pregnancy`: Estimated pregnancies
       - `danc1_delivery`: Estimated deliveries
       - `danc1_birth`: Estimated births (live + stillbirths)
       - `danc1_livebirth`: Estimated live births
       - `danc1_dpt`: Eligible for DPT (adjusted for neonatal mortality)
       - `danc1_measles1`: Eligible for MCV1
       - `danc1_measles2`: Eligible for MCV2

    2. **From Delivery**:
       - `ddelivery_livebirth`, `ddelivery_birth`, `ddelivery_pregnancy`
       - `ddelivery_dpt`, `ddelivery_measles1`, `ddelivery_measles2`

    3. **From SBA** (Skilled Birth Attendance):
       - Same structure as delivery denominators
       - `dsba_livebirth`, `dsba_birth`, `dsba_pregnancy`
       - `dsba_dpt`, `dsba_measles1`, `dsba_measles2`

    4. **From BCG** (national only):
       - `dbcg_pregnancy`, `dbcg_livebirth`, `dbcg_dpt`

    5. **From Penta1**:
       - `dpenta1_dpt`, `dpenta1_measles1`, `dpenta1_measles2`

    **B. Population-Based Denominators** (national only):

    - `dwpp_pregnancy`: From crude birth rate × total population ÷ (1 + twin rate)
    - `dwpp_livebirth`: From crude birth rate × total population
    - `dwpp_dpt`: Under-1 population
    - `dwpp_measles1`: Under-1 population adjusted for neonatal mortality
    - `dwpp_measles2`: Further adjusted for post-neonatal mortality

    **C. Vitamin A and Full Immunization**:

    For each livebirth denominator, additional denominators are automatically created:

    - `d*_vitaminA`: Livebirth × (1 - U5MR) × 4.5 (children 6-59 months)
    - `d*_fully_immunized`: Livebirth × (1 - IMR)

    **Adjustment for Incomplete Reporting**:

    When `nummonth < 12`, population-based denominators are scaled:

    ```
    denominator_adjusted = denominator × (nummonth / 12)
    ```

    **Output**:

    Data frame with all calculated denominators plus original HMIS and survey data

??? "`classify_source_type()`"

    **Purpose**: Categorizes denominators to prevent circular references

    **Logic**:

    - `reference_based`: Denominator calculated from same indicator (e.g., `danc1_pregnancy` for ANC1)
    - `unwpp_based`: Denominator from UN WPP population data
    - `independent`: Denominator from a different service indicator

    **Importance**:

    This classification ensures that when selecting "best" denominators, we avoid using reference-based denominators (which would artificially show 100% coverage equal to the survey value).

??? "`compare_coverage_to_survey()`"

    **Purpose**: Selects the best-performing denominator for each indicator

    **Input**:

    - Coverage estimates from all denominators
    - Survey reference values (forward-filled)

    **Selection Algorithm**:

    1. **Calculate Coverage**: For each denominator option

       ```
       coverage = (service_volume / denominator) × 100
       ```

    2. **Calculate Error**: Compare to survey benchmark

       ```
       squared_error = (HMIS_coverage - survey_coverage)²
       ```

    3. **Classify Source Type**: Label each denominator as independent, reference-based, or UNWPP

    4. **Selection Hierarchy**:

       ```
       Priority 1: Independent denominators (non-reference, non-UNWPP) → lowest error
       Priority 2: Reference-based denominators (only if no independent available)
       Priority 3: UNWPP denominators (last resort fallback)
       ```

    5. **Geographic Consistency**: Best denominator selected per geographic area × indicator (not per year)

    **Output**:

    Coverage data filtered to only the best-performing denominator for each indicator, with ranking

    **Key Design Decision**:

    - UNWPP denominators excluded from "best" selection by default
    - Prevents over-reliance on population projections
    - Ensures HMIS data drives coverage when available
    - UNWPP used only when no HMIS-based options exist

??? "`create_combined_results_table()`"

    **Purpose**: Merges coverage estimates and survey observations into unified output

    **Input**:

    - Coverage comparison results (best denominator selected)
    - Raw survey observations
    - All coverage data (optional, includes all denominators)

    **Output Structure**:

    ```
    admin_area_1  year  indicator_common_id  denominator_best_or_survey  value
    Country_Name  2020  anc1                 best                        85.3
    Country_Name  2020  anc1                 survey                      84.2
    Country_Name  2020  anc1                 danc1_pregnancy             85.3
    Country_Name  2020  anc1                 dwpp_pregnancy              82.1
    ```

    **Denominator Categories**:

    - `best`: Selected optimal denominator
    - `survey`: Actual survey observation
    - `d*_*`: Individual denominator results (all options)

#### Statistical Methods & Algorithms

??? "Forward-Filling (Last Observation Carried Forward)"

    Survey data typically has gaps (e.g., DHS every 5 years). To create continuous denominators:

    ```r
    na.locf(survey_value, na.rm = FALSE)
    ```

    **Example**:

    ```
    Year:   2015  2016  2017  2018  2019  2020
    Raw:    85.3  NA    NA    NA    87.2  NA
    Filled: 85.3  85.3  85.3  85.3  87.2  87.2
    ```

    This assumes coverage remains constant until next observation.

??? "Squared Error Minimization"

    To select the best denominator:

    $$
    \text{Best denominator} = \arg \min_d \sum_{t} (C_{d,t} - S_t)^2
    $$

    Where:

    - $C_{d,t}$ = Coverage using denominator $d$ in year $t$
    - $S_t$ = Survey coverage in year $t$
    - Summation is across all years with survey data

#### Conceptual Framework: Demographic Cascades

Before diving into the specific formulas, it's important to understand the **conceptual flow** of denominator calculations. Denominators are derived through sequential demographic adjustments that reflect the biological cascade from pregnancy to specific health service target populations.

**Illustrative Example: From Pregnancy to DPT-eligible Population**

Consider how an estimated 10,000 pregnancies translate to the population eligible for DPT vaccination:

```
Starting point (pregnancies):           10,000
→ After pregnancy loss (3%):            10,000 × (1 - 0.03) = 9,700 deliveries
→ After twin adjustment (1.5% rate):    9,700 × (1 - 0.015/2) = 9,627 births
→ After stillbirths (2%):               9,627 × (1 - 0.02) = 9,435 live births
→ After neonatal deaths (3.9%):         9,435 × (1 - 0.039) = 9,067 DPT-eligible children
```

This cascade demonstrates how each demographic factor sequentially reduces the population size as we move through life stages. The detailed mathematical formulas in the following sections follow this same logic, but work in **both directions**:

- **Forward cascade**: Starting from earlier indicators (ANC1, Delivery) and adjusting toward later target populations
- **Backward cascade**: Starting from later indicators (BCG, Penta1) and working backwards to estimate earlier populations

The specific rates and formulas for each denominator source are provided in detail below.

#### HMIS-based Denominator Calculations

**Denominators Derived from ANC1**

Starting from ANC1 service counts and survey coverage, we calculate:

**Estimated pregnancies** (base calculation):

$$
d_{\text{anc1-pregnancy}} = \frac{\text{count}_{\text{anc1}} \times 100}{\text{coverage}_{\text{anc1}}}
$$

**Estimated deliveries** (adjusted for pregnancy loss):

$$
d_{\text{anc1-delivery}} = d_{\text{anc1-pregnancy}} \times (1 - \text{pregnancy loss rate})
$$

**Estimated births** (adjusted for twin births):

$$
d_{\text{anc1-birth}} = d_{\text{anc1-delivery}} / (1 - 0.5 \times \text{twin rate})
$$

**Estimated live births** (adjusted for stillbirths):

$$
d_{\text{anc1-livebirth}} = d_{\text{anc1-birth}} \times (1 - \text{stillbirth rate})
$$

**Population eligible for DPT/Penta vaccines** (adjusted for neonatal mortality):

$$
d_{\text{anc1-dpt}} = d_{\text{anc1-livebirth}} \times (1 - \text{neonatal mortality rate})
$$

**Population eligible for MCV1** (adjusted for post-neonatal mortality):

$$
d_{\text{anc1-measles1}} = d_{\text{anc1-dpt}} \times (1 - \text{post-neonatal mortality rate})
$$

**Population eligible for MCV2** (adjusted for additional post-neonatal mortality):

$$
d_{\text{anc1-measles2}} = d_{\text{anc1-dpt}} \times (1 - 2 \times \text{post-neonatal mortality rate})
$$

---

**Denominators Derived from Delivery**

Starting from institutional delivery counts and survey coverage:

**Estimated live births** (base calculation):

$$
d_{\text{delivery-livebirth}} = \frac{\text{count}_{\text{delivery}} \times 100}{\text{coverage}_{\text{delivery}}}
$$

**Estimated births** (adjusted for stillbirths):

$$
d_{\text{delivery-birth}} = d_{\text{delivery-livebirth}} / (1 - \text{stillbirth rate})
$$

**Estimated pregnancies** (adjusted for twin births and pregnancy loss):

$$
d_{\text{delivery-pregnancy}} = d_{\text{delivery-birth}} \times (1 - 0.5 \times \text{twin rate}) / (1 - \text{pregnancy loss rate})
$$

**Population eligible for DPT/Penta vaccines**:

$$
d_{\text{delivery-dpt}} = d_{\text{delivery-livebirth}} \times (1 - \text{neonatal mortality rate})
$$

**Population eligible for MCV1**:

$$
d_{\text{delivery-measles1}} = d_{\text{delivery-dpt}} \times (1 - \text{post-neonatal mortality rate})
$$

**Population eligible for MCV2**:

$$
d_{\text{delivery-measles2}} = d_{\text{delivery-dpt}} \times (1 - 2 \times \text{post-neonatal mortality rate})
$$

*Note: Denominators derived from Skilled Birth Attendance (SBA) follow the same formulas as delivery denominators.*

---

**Denominators Derived from BCG** *(National analysis only)*

Starting from BCG vaccination counts and survey coverage:

**Estimated live births** (base calculation):

$$
d_{\text{bcg-livebirth}} = \frac{\text{count}_{\text{bcg}} \times 100}{\text{coverage}_{\text{bcg}}}
$$

**Estimated pregnancies** (working backwards through demographic adjustments):

$$
d_{\text{bcg-pregnancy}} = \frac{d_{\text{bcg-livebirth}}}{(1 - \text{pregnancy loss rate}) \times (1 + \text{twin rate}) \times (1 - \text{stillbirth rate})}
$$

**Population eligible for DPT/Penta vaccines**:

$$
d_{\text{bcg-dpt}} = d_{\text{bcg-livebirth}} \times (1 - \text{neonatal mortality rate})
$$

---

**Denominators Derived from Penta1**

Starting from Penta1 vaccination counts and survey coverage:

**Population eligible for DPT/Penta vaccines** (base calculation):

$$
d_{\text{penta1-dpt}} = \frac{\text{count}_{\text{penta1}} \times 100}{\text{coverage}_{\text{penta1}}}
$$

**Population eligible for MCV1**:

$$
d_{\text{penta1-measles1}} = d_{\text{penta1-dpt}} \times (1 - \text{post-neonatal mortality rate})
$$

**Population eligible for MCV2**:

$$
d_{\text{penta1-measles2}} = d_{\text{penta1-dpt}} \times (1 - 2 \times \text{post-neonatal mortality rate})
$$

---

**Denominators Derived from Live Birth Counts**

When live birth data is directly reported in HMIS:

**Estimated live births** (base calculation):

$$
d_{\text{livebirths-livebirth}} = \frac{\text{count}_{\text{livebirth}} \times 100}{\text{coverage}_{\text{livebirth}}}
$$

**Estimated pregnancies** (working backwards):

$$
d_{\text{livebirths-pregnancy}} = \frac{d_{\text{livebirths-livebirth}} \times (1 - 0.5 \times \text{twin rate})}{(1 - \text{stillbirth rate}) \times (1 - \text{pregnancy loss rate})}
$$

**Estimated deliveries**:

$$
d_{\text{livebirths-delivery}} = d_{\text{livebirths-pregnancy}} \times (1 - \text{pregnancy loss rate})
$$

**Estimated births**:

$$
d_{\text{livebirths-birth}} = d_{\text{livebirths-livebirth}} / (1 - \text{stillbirth rate})
$$

**Population eligible for DPT/Penta vaccines**:

$$
d_{\text{livebirths-dpt}} = d_{\text{livebirths-livebirth}} \times (1 - \text{neonatal mortality rate})
$$

**Population eligible for MCV1**:

$$
d_{\text{livebirths-measles1}} = d_{\text{livebirths-dpt}} \times (1 - \text{post-neonatal mortality rate})
$$

**Population eligible for MCV2**:

$$
d_{\text{livebirths-measles2}} = d_{\text{livebirths-dpt}} \times (1 - 2 \times \text{post-neonatal mortality rate})
$$

#### UNWPP-based Denominator Calculations

**Denominators Derived from UN World Population Prospects (WPP)** *(National analysis only)*

Instead of using service volumes, these denominators are calculated directly from population projections and demographic rates:

**Estimated pregnancies** (from crude birth rate and total population):

$$
d_{\text{wpp-pregnancy}} = \frac{\text{Crude birth rate}}{1000} \times \text{Total population} \times \frac{1}{1 + \text{twin rate}}
$$

**Estimated live births** (from crude birth rate):

$$
d_{\text{wpp-livebirth}} = \frac{\text{Crude birth rate}}{1000} \times \text{Total population}
$$

**Population eligible for DPT/Penta vaccines** (under-1 population):

$$
d_{\text{wpp-dpt}} = \text{Total under-1 population from WPP}
$$

**Population eligible for MCV1** (adjusted for neonatal mortality):

$$
d_{\text{wpp-measles1}} = d_{\text{wpp-dpt}} \times (1 - \text{neonatal mortality rate})
$$

**Population eligible for MCV2** (adjusted for post-neonatal mortality):

$$
d_{\text{wpp-measles2}} = d_{\text{wpp-dpt}} \times (1 - \text{neonatal mortality rate}) \times (1 - 2 \times \text{post-neonatal mortality rate})
$$

**Adjustment for Incomplete Reporting:**

When HMIS data contains fewer than 12 months of reported data in a year, all UNWPP denominators are scaled to match the reporting period:

$$
d_{\text{adjusted}} = d_{\text{wpp}} \times \frac{\text{months reported}}{12}
$$

This adjustment ensures denominators are comparable to service volumes that may only represent partial-year reporting.

---

**Denominators Derived from Live Birth Estimates (Secondary Calculations)**

After all primary live birth denominators are calculated (from ANC1, Delivery, BCG, Penta1, Live Birth Counts, and WPP), the module generates additional target population estimates for specific interventions by applying age-specific mortality adjustments:

**Children Aged 6-59 Months (Vitamin A Supplementation Target Population)**

For each live birth denominator source, the estimated number of children aged 6-59 months is calculated:

$$
d_{\text{source-vitaminA}} = d_{\text{source-livebirth}} \times (1 - \text{under-5 mortality rate}) \times 4.5
$$

Where:

- `source` represents any of: anc1, delivery, bcg, penta1, livebirths, or wpp
- The factor **4.5** represents the approximate duration (in years) of the Vitamin A target age range (6-59 months ≈ 4.5 years)
- Under-5 mortality rate adjusts for child survival to reach the 6-59 month age range
- Result: **Estimated population of children aged 6-59 months** eligible for Vitamin A supplementation

**Infants Under 12 Months (Fully Immunized Child Target Population)**

For each live birth denominator source, the estimated number of infants under 12 months is calculated:

$$
d_{\text{source-fully-immunized}} = d_{\text{source-livebirth}} \times (1 - \text{infant mortality rate})
$$

Where:

- `source` represents any of: anc1, delivery, bcg, penta1, livebirths, or wpp
- Infant mortality rate adjusts for survival to 12 months of age
- Result: **Estimated population of infants under 1 year old** eligible for full immunization assessment

These target population estimates are calculated automatically for **all available live birth denominators**, ensuring consistent methodology across different source indicators.

#### Workflow Execution Steps

Part 1 executes the following workflow for each administrative level (national, admin2, admin3):

**Step 1: Load and Validate Input Data**

- Load HMIS adjusted data from Module 2 (national and subnational files)
- Load survey data from GitHub repository (unified DHS/MICS dataset)
- Load UN WPP population data from GitHub repository
- Validate ISO3 codes match across datasets
- Aggregate monthly HMIS data to annual totals
- Harmonize survey data (DHS prioritized over MICS)
- Forward-fill survey values to create continuous time series

**Step 2: Calculate HMIS-based Denominators**

- For each health indicator with survey coverage data:
  - Calculate base denominator: `count ÷ survey_coverage`
  - Apply demographic cascades to derive related denominators
  - Generate denominators from all available source indicators (ANC1, Delivery, BCG, Penta1, Live Births)

**Step 3: Calculate WPP-based Denominators**

- Extract population projections for target country
- Calculate pregnancy estimates from crude birth rate
- Calculate live birth estimates
- Generate under-1 population denominators
- Apply mortality adjustments for vaccine-eligible populations
- Adjust for incomplete reporting periods (months reported < 12)

**Step 4: Calculate Secondary Denominators**

- For each `*_livebirth` denominator:
  - Calculate Vitamin A denominator: `livebirth × (1 - U5MR) × 4.5`
  - Calculate Fully Immunized denominator: `livebirth × (1 - IMR)`

**Step 5: Calculate Coverage Estimates**

- Divide HMIS service volume by each denominator option
- Create coverage estimates for all indicator-denominator combinations
- Preserve survey-based coverage as benchmark

**Step 6: Select Best Denominator**

- For each indicator, compare all denominator-based coverage estimates to survey data
- Calculate squared error: `Σ(coverage_d,t - survey_t)²`
- Select denominator with minimum error as "best"
- Apply preference rules (HMIS-based preferred over WPP)
- Flag denominators as "reference" if from same service

**Step 7: Format and Save Outputs**

- Save denominator files with source and target metadata
- Save combined results with all coverage estimates
- Mark best denominator for easy filtering
- Include survey values in output
- Create separate files for national, admin2, and admin3 levels
- Generate empty files with correct structure for unavailable admin levels

??? "Output Files Specification"

    Part 1 generates six CSV files:

    **Denominator Files**

    **1. M4_denominators_national.csv**

    **2. M4_denominators_admin2.csv**

    **3. M4_denominators_admin3.csv**

    **Structure**:

    ```
    admin_area_1, [admin_area_2/3], year, denominator, source_indicator, target_population, value
    ```

    **Fields**:

    - `denominator`: Full denominator name (e.g., `danc1_livebirth`)
    - `source_indicator`: Service used (e.g., `source_anc1`, `source_wpp`)
    - `target_population`: Target group (e.g., `target_livebirth`, `target_dpt`)
    - `value`: Calculated denominator size

    **Combined Results Files**

    **4. M4_combined_results_national.csv**

    **5. M4_combined_results_admin2.csv**

    **6. M4_combined_results_admin3.csv**

    **Structure**:

    ```
    admin_area_1, [admin_area_2/3], year, indicator_common_id, denominator_best_or_survey, value
    ```

    **Fields**:

    - `indicator_common_id`: Health indicator (e.g., `anc1`, `penta3`)
    - `denominator_best_or_survey`: Either `best`, `survey`, or specific denominator name
    - `value`: Coverage percentage (0-100+)

    **Special "best" Entry**: Duplicates the selected optimal denominator for easy filtering

??? "Data Safeguards and Validation"

    Part 1 includes multiple validation checks:

    1. **ISO3 Validation**: Ensures survey and population data match HMIS country

    2. **Geographic Matching**: Validates admin area names between HMIS and survey
       - Reports match rate (e.g., "15/20 regions match")
       - Falls back to higher geographic level if mismatch detected

    3. **Fallback Mechanisms**:
       - Subnational → National if no local survey data
       - SBA → Delivery if SBA missing
       - PNC1_mother → PNC1 if missing

    4. **Edge Case Handling**: Detects when admin_area_3 should be used as admin_area_2 in certain country contexts

    5. **Empty Data Handling**: Creates empty CSVs with correct structure when data unavailable

    6. **Error Handling**: Wraps survey processing in `tryCatch` to handle mismatches gracefully

??? "Indicators Supported"

    Part 1 processes the following health indicators:

    **Maternal Health**:

    - `anc1`: Antenatal care 1st visit
    - `anc4`: Antenatal care 4+ visits
    - `delivery`: Institutional delivery
    - `sba`: Skilled birth attendance
    - `pnc1`: Postnatal care (child)
    - `pnc1_mother`: Postnatal care (mother)

    **Immunization**:

    - `bcg`: BCG vaccine
    - `penta1`, `penta2`, `penta3`: Pentavalent vaccine
    - `measles1`, `measles2`: Measles-containing vaccine
    - `rota1`, `rota2`: Rotavirus vaccine
    - `opv1`, `opv2`, `opv3`: Oral polio vaccine
    - `fully_immunized`: Full immunization status

    **Child Health**:

    - `nmr`: Neonatal mortality rate (survey only)
    - `imr`: Infant mortality rate (survey only)
    - `vitaminA`: Vitamin A supplementation

??? "Usage Notes and Best Practices"

    **When to Use Which Count Variable**

    - `count_final_none`: No adjustments (raw reported data)
    - `count_final_outlier`: Outlier adjustment only
    - `count_final_completeness`: Completeness adjustment only
    - `count_final_both`: Both adjustments **(recommended)**

    **Interpreting "best" Denominators**

    The "best" denominator may vary by indicator and area based on:

    - Data availability (some services not universally reported)
    - Reporting completeness (affects HMIS-based denominators)
    - Population projection quality (affects WPP denominators)
    - Survey coverage levels (extreme values reduce denominator options)

    **Why Multiple Denominators?**

    Different denominators serve different purposes:

    - **Independent denominators**: Provide cross-validation between services
    - **Reference denominators**: Show internal HMIS consistency (but excluded from "best" by default)
    - **WPP denominators**: Offer population-based benchmarks
    - Comparing multiple options reveals data quality issues

??? "Troubleshooting Common Issues"

    **Issue**: No matching admin areas between HMIS and survey

    - **Solution**: Check ISO3 code is correct; verify admin area naming conventions; module will fall back to national analysis

    **Issue**: All denominators show >100% coverage

    - **Solution**: May indicate under-reporting in survey or over-reporting in HMIS; check data quality from Module 2

    **Issue**: UNWPP selected as "best" for most indicators

    - **Solution**: May indicate poor HMIS data quality or completeness; review Module 2 adjustments

---

### Part 2: Denominator Selection and Survey Projection (Technical Details)

#### Purpose and Objectives

Part 2 serves three key purposes:

1. **User-Driven Denominator Selection**: While Part 1 automatically selects the "best" denominator by minimizing error against survey data, Part 2 allows users to override this selection and choose specific denominators based on programmatic knowledge or policy priorities

2. **Temporal Trend Analysis**: Computes year-over-year changes (deltas) in coverage to understand service delivery trends over time

3. **Survey Projection**: Projects survey-based coverage estimates forward in time using trends observed in administrative (HMIS) data, filling gaps where survey data is unavailable

#### User Configuration

Users configure Part 2 through two key parameter sets:

??? "1. Denominator Selection Configuration"

    At the top of the script, users specify which denominator to use for each indicator:

    ```r
    DENOMINATOR_SELECTION <- list(
      # PREGNANCY-RELATED INDICATORS
      anc1 = "best",                    # Options: "best", "danc1_pregnancy", "ddelivery_pregnancy", "dbcg_pregnancy", "dlivebirths_pregnancy", "dwpp_pregnancy"
      anc4 = "best",

      # LIVE BIRTH-RELATED INDICATORS
      delivery = "best",                # Options: "best", "danc1_livebirth", "ddelivery_livebirth", "dbcg_livebirth", "dlivebirths_livebirth", "dwpp_livebirth"
      bcg = "best",
      sba = "best",
      pnc1_mother = "best",
      pnc1 = "best",

      # DPT-ELIGIBLE AGE GROUP INDICATORS
      penta1 = "best",                  # Options: "best", "danc1_dpt", "ddelivery_dpt", "dpenta1_dpt", "dbcg_dpt", "dlivebirths_dpt", "dwpp_dpt"
      penta2 = "best",
      penta3 = "best",
      opv1 = "best",
      opv2 = "best",
      opv3 = "best",

      # MEASLES-ELIGIBLE AGE GROUP INDICATORS
      measles1 = "best",                # Options: "best", "danc1_measles1", "ddelivery_measles1", "dpenta1_measles1", "dbcg_measles1", "dlivebirths_measles1", "dwpp_measles1"
      measles2 = "best",

      # ADDITIONAL INDICATORS
      vitaminA = "best",                # Options: "best", "danc1_vitaminA", "dbcg_vitaminA", "ddelivery_vitaminA", "dwpp_vitaminA"
      fully_immunized = "best"          # Options: "best", "danc1_fully_immunized", "dbcg_fully_immunized", "ddelivery_fully_immunized", "dwpp_fully_immunized"
    )
    ```

    **Denominator Options by Indicator Type:**

    The available denominators vary by indicator type based on the appropriate target population:

    - **Pregnancy-based indicators** (ANC1, ANC4): Use pregnancy-adjusted denominators
    - **Live birth-based indicators** (Delivery, BCG, SBA, PNC): Use live birth-adjusted denominators
    - **DPT-eligible age group** (Penta1-3, OPV1-3): Use DPT-adjusted denominators (children eligible for DPT)
    - **Measles-eligible age group** (Measles1, Measles2): Use measles-adjusted denominators (children eligible for measles vaccine)

    Each denominator option combines a source (ANC1, Delivery, BCG, Penta1, or WPP) with an age-adjustment factor.

??? "2. Administrative Level Configuration"

    ```r
    RUN_NATIONAL <- TRUE  # Always TRUE - national analysis is mandatory
    RUN_ADMIN2 <- TRUE    # Enable/disable admin level 2 analysis
    RUN_ADMIN3 <- TRUE    # Enable/disable admin level 3 analysis
    ```

    The script automatically checks data availability and disables admin levels with no data.

#### Core Functions and Methods

??? "Function 1: `coverage_deltas()`"

    **Purpose**: Calculates year-over-year changes in coverage for each indicator-denominator-geography combination.

    **Algorithm**:

    ```r
    coverage_deltas <- function(coverage_df, lag_n = 1, complete_years = TRUE)
    ```

    **Process**:

    1. Groups data by geography (admin areas), indicator, and denominator
    2. Optionally fills in missing years to create a complete time series
    3. Sorts data chronologically within each group
    4. Calculates delta as: $\Delta\text{coverage}_t = \text{coverage}_t - \text{coverage}_{t-1}$

    **Mathematical Formulation**:
    $$
    \Delta C_{i,d,g,t} = C_{i,d,g,t} - C_{i,d,g,t-1}
    $$

    where:
    - $C$ = coverage estimate
    - $i$ = indicator
    - $d$ = denominator
    - $g$ = geographic area
    - $t$ = time (year)

    **Input**:

    - `coverage_df`: Data frame with coverage estimates
    - `lag_n`: Number of years to lag (default = 1 for year-over-year)
    - `complete_years`: Whether to fill missing years (default = TRUE)

    **Output**:

    Data frame with original coverage values plus a `delta` column showing year-over-year change.

    **Example Output**:

    | admin_area_1 | indicator_common_id | denominator | year | coverage | delta |
    |--------------|---------------------|-------------|------|----------|-------|
    | Country A | penta3 | dpenta1_dpt | 2018 | 75.2 | NA |
    | Country A | penta3 | dpenta1_dpt | 2019 | 78.5 | 3.3 |
    | Country A | penta3 | dpenta1_dpt | 2020 | 80.1 | 1.6 |

??? "Function 2: `project_survey_from_deltas()`"

    **Purpose**: Projects survey-based coverage estimates forward using administrative data trends.

    **Algorithm**:

    ```r
    project_survey_from_deltas <- function(deltas_df, survey_raw_long)
    ```

    **Process**:

    1. **Identify Baseline**: For each geography-indicator combination, find the most recent survey observation
       - Extract the last observed survey year
       - Record the baseline coverage value at that year

    2. **Attach Baseline to Each Denominator Path**: Since Part 2 operates on specific denominator selections, attach the baseline to each denominator series

    3. **Compute Cumulative Deltas**: For years after the baseline year, calculate cumulative sum of deltas:

       $$\text{cumulative delta}_t = \sum_{\tau = \text{baseline year} + 1}^{t} \Delta C_\tau$$

    4. **Calculate Projection**: Add cumulative delta to baseline value:

       $$\text{Projected coverage}_t = \text{Baseline coverage} + \text{cumulative delta}_t$$

    **Mathematical Formulation**:

    For each indicator $i$, denominator $d$, and geography $g$:

    1. Find baseline:

    $$
    y_{\text{baseline}} = \max\{t : S_{i,g,t} \text{ exists}\}
    $$

    $$
    S_{\text{baseline}} = S_{i,g,y_{\text{baseline}}}
    $$

    2. For $t > y_{\text{baseline}}$:

    $$
    \hat{S}_{i,d,g,t} = S_{\text{baseline}} + \sum_{\tau = y_{\text{baseline}} + 1}^{t} \Delta C_{i,d,g,\tau}
    $$

    where:

    - $S$ = survey-based coverage estimate
    - $\hat{S}$ = projected survey coverage
    - $\Delta C$ = year-over-year change in administrative coverage

    **Assumptions**:

    - Trends observed in administrative data reflect true changes in service coverage
    - The baseline survey provides an accurate reference point
    - Administrative data trends can be applied to survey estimates

    **Input**:

    - `deltas_df`: Output from `coverage_deltas()` containing coverage changes
    - `survey_raw_long`: Raw survey data with years and values

    **Output**:

    Data frame with projected coverage for each year, indicator, denominator, and geography combination.

    **Example Output**:

    | admin_area_1 | indicator_common_id | denominator | year | baseline_year | projected |
    |--------------|---------------------|-------------|------|---------------|-----------|
    | Country A | penta3 | dpenta1_dpt | 2018 | 2018 | 75.0 |
    | Country A | penta3 | dpenta1_dpt | 2019 | 2018 | 78.3 |
    | Country A | penta3 | dpenta1_dpt | 2020 | 2018 | 79.9 |

??? "Function 3: `build_final_results()`"

    **Purpose**: Combines HMIS coverage, projected survey estimates, and original survey values into a unified output dataset.

    **Algorithm**:

    ```r
    build_final_results <- function(coverage_df, proj_df, survey_raw_df = NULL)
    ```

    **Process**:

    1. **Prepare HMIS Coverage**: Extract coverage estimates from administrative data
       - Rename coverage column to `coverage_cov` for clarity

    2. **Merge Projections**: Join projected survey estimates
       - Match by geography, year, indicator, and denominator
       - Create `coverage_avgsurveyprojection` column

    3. **Process Original Survey Data** (if available):
       - Collapse multiple survey sources by taking mean value
       - Preserve source metadata (source, source_detail)
       - Expand survey values across all denominators for that indicator

    4. **Calculate Final Projections**: Use an improved projection formula that anchors to the last survey value:

       For years after the last survey year:

       $$
       \text{Projected coverage}_t = \text{Last survey value} + (C_{\text{HMIS},t} - C_{\text{HMIS, last survey year}})
       $$

       This additive approach:
       - Preserves the calibration to survey data
       - Applies the HMIS trend (delta) to extend the estimate forward
       - Avoids compounding errors from year-to-year deltas

    5. **Combine Results**: Merge all components using full outer join to preserve:
       - Years with only HMIS data
       - Years with only survey data
       - Years with both data sources

    **Mathematical Formulation**:

    Let:

    - $t_s$ = year of last survey
    - $S_{t_s}$ = survey coverage at year $t_s$
    - $C_{\text{HMIS},t}$ = HMIS-based coverage at year $t$

    For $t > t_s$:

    $$
    \hat{C}_t = S_{t_s} + (C_{\text{HMIS},t} - C_{\text{HMIS},t_s})
    $$

    **Input**:

    - `coverage_df`: HMIS-based coverage estimates from selected denominators
    - `proj_df`: Projected survey estimates from `project_survey_from_deltas()`
    - `survey_raw_df`: Original survey data (optional)

    **Output**:

    Comprehensive data frame with columns:

    - Geographic identifiers (admin_area_1, admin_area_2, admin_area_3)
    - year, indicator_common_id, denominator
    - `coverage_cov`: HMIS-based coverage
    - `coverage_original_estimate`: Original survey values
    - `coverage_avgsurveyprojection`: Projected survey coverage
    - `survey_raw_source`: Survey data source (e.g., "DHS", "MICS")
    - `survey_raw_source_detail`: Detailed source information

#### Helper Functions

??? "Helper Function: `filter_by_denominator_selection()`"

    **Purpose**: Filters the combined results from Part 1 based on user's denominator selection.

    **Algorithm**:

    1. Iterate through each indicator in `DENOMINATOR_SELECTION`
    2. For each indicator:
       - If selection is "best": Keep rows where `denominator_best_or_survey == "best"`
       - If selection is a specific denominator: Keep rows where `denominator_best_or_survey == selected_denominator`
    3. Convert selected rows to coverage format (rename columns, filter out survey entries)
    4. Combine results across all indicators

    **Input**:

    - `combined_results_df`: Output from Part 1 with all denominator options
    - `selection_list`: The DENOMINATOR_SELECTION configuration list

    **Output**:

    Filtered data frame containing only the user-selected denominators.

??? "Helper Function: `extract_survey_from_combined()`"

    **Purpose**: Extracts raw survey values from Part 1 combined results.

    **Algorithm**:

    1. Filter for rows where `denominator_best_or_survey == "survey"`
    2. Rename `value` column to `survey_value`
    3. Select relevant columns dynamically based on admin levels present

    **Input**:

    Combined results data frame from Part 1

    **Output**:

    Survey data frame with columns: admin areas, year, indicator_common_id, survey_value

#### Workflow Execution Steps

Part 2 executes the following workflow for each administrative level (national, admin2, admin3):

**Step 1: Load Data**

- Load combined results from Part 1 for all admin levels
- Check which admin levels have data
- Extract survey data for use as projection baseline
- Display messages about data availability

**Step 2: For Each Admin Level**

**Sub-step 1: Filter by Denominator Selection**

- Apply user's denominator choices using `filter_by_denominator_selection()`
- Message: Number of records selected

**Sub-step 2: Compute Deltas**

- Calculate year-over-year coverage changes using `coverage_deltas()`
- Creates complete time series with gaps filled

**Sub-step 3: Project Survey Values**

- Use `project_survey_from_deltas()` to extend survey estimates
- Baseline is anchored to most recent survey
- Projections use cumulative deltas from HMIS trends

**Sub-step 4: Build Final Results**

- Combine HMIS coverage, projections, and original surveys
- Calculate final projected estimates using additive formula
- Preserve all metadata

**Step 3: Standardize and Save Outputs**

- Define required columns for each admin level
- Ensure all required columns exist (add as NA if missing)
- Order columns correctly
- Remove inappropriate admin level columns
- Save as CSV with UTF-8 encoding
- Create empty files for admin levels with no data

#### Output Specifications

Part 2 produces three output files:

#### 1. National Output: `M5_coverage_estimation_national.csv`

**Columns**:

- `admin_area_1`: Country name
- `year`: Year of estimate
- `indicator_common_id`: Standardized indicator code
- `denominator`: Selected denominator source
- `coverage_original_estimate`: Original survey-based coverage (NA for years without surveys)
- `coverage_avgsurveyprojection`: Projected survey coverage using HMIS trends
- `coverage_cov`: HMIS-based coverage estimate
- `survey_raw_source`: Survey source (e.g., "DHS 2018")
- `survey_raw_source_detail`: Additional source details

#### 2. Admin Level 2 Output: `M5_coverage_estimation_admin2.csv`

**Columns**:

Same as national, plus:

- `admin_area_2`: Second-level administrative division name (e.g., province, region)


#### 3. Admin Level 3 Output: `M5_coverage_estimation_admin3.csv`

**Columns**:

- `admin_area_1`: Country name
- `admin_area_3`: Third-level administrative division name (e.g., district)
- `year`: Year of estimate
- `indicator_common_id`: Standardized indicator code
- `denominator`: Selected denominator source
- `coverage_original_estimate`: Original survey coverage
- `coverage_avgsurveyprojection`: Projected survey coverage
- `coverage_cov`: HMIS-based coverage
- `survey_raw_source`: Survey source
- `survey_raw_source_detail`: Source details

#### Methodological Considerations

??? "1. Denominator Selection Strategy"

    **When to use "best"**:

    - Uncertain about which denominator is most appropriate
    - Want to rely on data-driven selection from Part 1
    - Starting point for analysis

    **When to specify a denominator**:

    - Programmatic knowledge suggests a specific denominator is most accurate
    - Policy requirements dictate use of specific population estimates
    - Conducting sensitivity analyses
    - Known issues with certain data sources

??? "2. Projection Methodology"

    The projection approach in Part 2 uses an **additive delta method** rather than multiplicative or direct replacement:

    **Advantages**:

    - Preserves the level calibration from survey data
    - Smoothly extends survey estimates using administrative trends
    - Avoids compounding errors from year-to-year changes
    - Maintains consistency when HMIS coverage is stable

    **Limitations**:

    - Assumes HMIS trends reflect true coverage changes
    - May diverge from reality if administrative data quality declines
    - Projections become less reliable further from baseline survey
    - Does not account for systematic biases in HMIS data

    **Best Practice**: Projections should be validated against new survey data when available, and the baseline should be updated with the most recent survey.

??? "3. Handling Missing Data"

    Part 2 implements several strategies for missing data:

    - **Complete time series**: The `coverage_deltas()` function can fill missing years, creating a continuous series
    - **Survey gaps**: Projections extend estimates forward, but years before the first survey remain NA
    - **Admin level gaps**: Script automatically detects and skips admin levels with no data
    - **Missing denominators**: If a selected denominator doesn't exist for an indicator, that indicator-denominator combination is omitted

??? "4. Multi-Level Analysis Consistency"

    Part 2 processes each administrative level independently:

    - **National**: Aggregated country-level estimates
    - **Admin 2**: Provincial/regional estimates (may not sum to national due to different denominators)
    - **Admin 3**: District-level estimates

    **Important**: Estimates across levels may not be directly comparable if different denominators are selected or if data quality varies by level.

??? "Validation and Quality Checks"

    Users should validate Part 2 outputs by:

    1. **Checking projection reasonableness**:
       - Are projected values within plausible ranges (0-100%)?
       - Do trends make programmatic sense?

    2. **Comparing denominators**:
       - Run Part 2 with different denominator selections
       - Assess sensitivity of results to denominator choice

    3. **Validating against new surveys**:
       - When new survey data becomes available, compare projections to actual values
       - Update baseline and re-run if necessary

    4. **Reviewing HMIS trends**:
       - Large deltas may indicate data quality issues
       - Sudden changes should be investigated

    5. **Admin level consistency**:
       - Check if subnational trends align with national patterns
       - Investigate large discrepancies


??? "Troubleshooting Common Issues"

    **Issue**: "No data in admin2 combined results"

    - **Cause**: Part 1 didn't process admin level 2, or no subnational data exists
    - **Solution**: Set `RUN_ADMIN2 <- FALSE` or check Part 1 inputs

    **Issue**: Projections show implausible values (>100% or <0%)

    - **Cause**: Large errors in HMIS data or inappropriate denominator
    - **Solution**: Review denominator selection, check HMIS data quality, consider different denominator

    **Issue**: Missing denominators in output

    - **Cause**: Selected denominator not calculated in Part 1 for that indicator
    - **Solution**: Check Part 1 denominator options, verify indicator-denominator compatibility

    **Issue**: Gaps in projected coverage

    - **Cause**: Missing HMIS data for some years
    - **Solution**: Review Module 2 outputs, check data completeness adjustments

---

**Last updated**: 10-11-2025
**Contact**: FASTR Project Team
