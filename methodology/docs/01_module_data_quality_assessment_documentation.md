# Module 1: Data Quality Assessment (DQA)

## 1. Overview (What & Why)

### What does this module do?

The Data Quality Assessment (DQA) module evaluates the reliability of Health Management Information System (HMIS) data from health facilities. It acts as a quality control checkpoint in the FASTR pipeline, examining monthly facility reports to identify data issues before the information is used for decision-making.

The module assesses data quality through three complementary lenses: **detecting outliers** (unusually high values that may indicate reporting errors), **assessing completeness** (whether facilities consistently submit their reports), and **measuring consistency** (whether related health indicators align with expected patterns). These assessments are combined into an overall DQA score that provides a single measure of data reliability.

Routinely reported health facility data are an important source for health indicators at the facility and population levels. Health facilities report on events such as immunizations given or live births attended by a skilled provider. As with any data, quality is an issue. The FASTR approach conducts an analysis of monthly data by facility and by indicator to assess data quality. Results are presented as annual estimates but may comprise a partial year of data given the availability of data at the time the analysis is conducted (e.g., an analysis conducted in June 2024 may contain data from January-May 2024, and this will be presented as the analysis for 2024).

### Why is it needed in the FASTR pipeline?

Data quality directly impacts the reliability of health indicators and coverage estimates. Before calculating service utilization rates or estimating population coverage, we must ensure the underlying facility data is trustworthy. This module identifies problematic data patterns that could skew results, allowing analysts to make informed decisions about data adjustments or exclusions in subsequent pipeline steps.

### Quick Summary

| Component | Details |
|-----------|---------|
| **Inputs** | Raw HMIS data (`hmis_ISO3.csv`) containing facility service volumes by month and indicator<br>Geographic/administrative area identifiers<br>Standardized indicator names |
| **Outputs** | - Outlier flags and lists<br>- Completeness status by facility-indicator-month<br>- Consistency results at geographic level<br>- Overall DQA scores |
| **Purpose** | Evaluate HMIS data reliability through outlier detection, completeness assessment, and consistency checking to ensure trustworthy inputs for coverage estimation |

---

## 2. How It Works

### High-Level Workflow

The module follows a logical sequence of quality checks, building from individual data points to an overall quality score:

**Step 1: Load and Prepare Data**
The module reads monthly facility reports and organizes them for analysis. It converts dates to a standard format and identifies which geographic areas and health indicators are present in the dataset.

**Step 2: Detect Outliers**
For each health facility and indicator (like pentavalent vaccine doses or antenatal care visits), the module identifies unusually high values that might indicate data entry errors. It uses two methods: statistical outliers (values far from the facility's typical volume) and proportional outliers (a single month accounting for most of the year's services).

**Step 3: Assess Completeness**
The module checks whether facilities are consistently reporting data. It creates a complete timeline for each facility and indicator, identifying months with missing reports. Facilities that stop reporting for 6+ months are flagged as inactive rather than incomplete.

**Step 4: Measure Consistency**
Related indicators should follow predictable patterns. For example, more women should receive their first antenatal visit (ANC1) than their fourth visit (ANC4). The module calculates ratios between paired indicators at the district level (to account for patients visiting multiple facilities) and flags relationships that don't meet expectations.

**Step 5: Validate Indicator Availability**
Before running consistency checks, the module verifies that the required indicator pairs actually exist in the dataset. Missing indicators are handled gracefully, with the analysis adapting to available data.

**Step 6: Calculate DQA Scores**
For a defined set of core indicators (typically pentavalent vaccine, first antenatal visit, and outpatient visits), the module combines the three quality dimensions. A facility-month receives a perfect DQA score only if all core indicators are complete, free of outliers, and meet consistency benchmarks.

**Step 7: Export Results**
The module produces several output files containing outlier lists, completeness flags, consistency results, and final DQA scores. These outputs inform subsequent modules and provide actionable insights for data quality improvement.

### Workflow Diagram

<iframe src="../images/mod1_workflow.html" width="100%" height="800" style="border: 1px solid #ccc; border-radius: 4px;" title="Module 1 Interactive Workflow"></iframe>

### Key Decision Points

**When is a value considered an outlier?**
An observation is flagged as an outlier if it meets EITHER of two criteria AND the count exceeds 100:
- It's more than 10 times the Median Absolute Deviation (MAD) away from the facility's typical volume, OR
- It represents more than 80% of that facility's annual total for that indicator

**Why measure consistency at the district level instead of facility level?**
Patients often visit different facilities within their local district for different services. A woman might get her first antenatal visit at one health center but deliver at a district hospital. Measuring consistency at the district level accounts for this patient movement and provides a more accurate picture of service utilization patterns.

**What happens when required indicators are missing?**
The module adapts to available data. If consistency pairs cannot be evaluated, the DQA score is calculated using only completeness and outlier checks. The analysis continues with the dimensions that can be assessed.

**How are inactive facilities handled?**
If a facility doesn't report for 6 or more consecutive months at the start or end of their reporting period, those months are flagged as "inactive" rather than "incomplete." This prevents penalizing facilities that haven't yet started reporting or have permanently closed.

### What Happens to the Data

**Transformation Overview:**

The module transforms raw facility reports into quality-flagged datasets:

1. **Input Format**: Monthly rows with facility ID, period, indicator name, and count
2. **Enrichment**: Adds calculated fields like median volume, MAD residuals, proportional contributions
3. **Completion**: Generates explicit rows for missing months (turning implicit gaps into explicit records)
4. **Aggregation**: Rolls up facility data to district level for consistency calculations
5. **Flagging**: Adds binary quality flags (outlier yes/no, complete yes/no, consistent yes/no)
6. **Scoring**: Combines flags into continuous scores (0-1) and binary pass/fail indicators
7. **Output Format**: Multiple files optimized for different use cases (quick outlier review, full analysis, downstream modules)

The data flows through the module in long format (one row per facility-indicator-period combination) and emerges with quality dimensions that subsequent modules use to weight, adjust, or exclude observations.

### Analysis Outputs and Visualization

The FASTR analysis generates six main visual outputs:

**1. Outliers Heatmap**

Heatmap table with zones as rows and health indicators as columns, color-coded by outlier percentage.

![Percentage of facility-months that are outliers.](images/Default_1._Proportion_of_outliers.png)

**2. Indicator Completeness**

Heatmap table with zones as rows and health indicators as columns, color-coded by completeness percentage.

![Percentage of facility-months with complete data.](images/Default_2._Proportion_of_completed_records.png)

**3. Indicator Completeness Over Time**

Horizontal timeline charts showing completeness trends for each indicator over the analysis period.

![Percentage of facility-months with complete data over time.](images/Default_3._Proportion_of_completed_records_over_time.png)

**4. Internal Consistency**

Heatmap table with zones as rows and consistency benchmark categories as columns, color-coded by performance.

![Percentage of sub-national areas meeting consistency benchmarks.](images/Default_4._Proportion_of_sub-national_areas_meeting_consistency_criteria.png)

**5. Overall DQA Score**

Heatmap table with zones as rows and time periods as columns, color-coded by DQA score percentage.

![Percentage of facility-months with adequate data quality over time.](images/Default_5._Overall_DQA_score.png)

**6. Mean DQA Score**

Heatmap table with zones as rows and time periods as columns, color-coded by average DQA score.

![Average data quality score across facility-months.](images/Default_6._Mean_DQA_score.png)

**Color Coding System:**
- **Green**: 90% or above (completeness/consistency), Below 1% (outliers)
- **Yellow**: 80% to 89% (completeness), 1% to 2% (outliers)
- **Red**: Below 80% (completeness/consistency), 3% or above (outliers)

---

## 3. Detailed Reference

This section provides technical details for implementers, developers, and analysts who need to understand the underlying methodology.

### Configuration Parameters

The module uses several configurable parameters that control analysis behavior:

???+ "Geographic Settings"

    ```r
    # Country identifier
    COUNTRY_ISO3 <- "GIN"  # ISO3 country code

    # Geographic level for consistency analysis
    GEOLEVEL <- "admin_area_3"  # Admin level (1=national, 2=region, 3=district, etc.)
    ```

    The `GEOLEVEL` parameter determines the aggregation level for consistency analysis. Lower administrative levels (3-4) capture local patterns but may have sparse data. Higher levels (2) provide more stable estimates but may mask local inconsistencies.

??? "Outlier Detection Parameters"

    ```r
    # Proportion threshold for outlier detection
    OUTLIER_PROPORTION_THRESHOLD <- 0.8  # Flag if single month > 80% of annual total

    # Minimum count to consider for outlier flagging
    MINIMUM_COUNT_THRESHOLD <- 100  # Only flag outliers with count >= 100

    # Number of Median Absolute Deviations for statistical outlier detection
    MADS <- 10  # Flag if value > 10 MADs from median
    ```

    **Tuning Guidance:**
    - **More sensitive detection**: Lower `OUTLIER_PROPORTION_THRESHOLD` to 0.6-0.7, reduce `MADS` to 8
    - **Less sensitive detection**: Increase `OUTLIER_PROPORTION_THRESHOLD` to 0.9, increase `MADS` to 12-15
    - **Small facilities**: Lower `MINIMUM_COUNT_THRESHOLD` to 50
    - **Large facilities only**: Increase `MINIMUM_COUNT_THRESHOLD` to 200+

??? "DQA Indicator Selection"

    ```r
    # Core indicators used for DQA scoring
    DQA_INDICATORS <- c("penta1", "anc1", "opd")

    # Consistency pairs to evaluate
    CONSISTENCY_PAIRS_USED <- c("penta", "anc")
    ```

    **Standard Indicator Sets:**
    - **Maternal-child focus**: `c("anc1", "anc4", "delivery", "penta1", "penta3")`
    - **Immunization focus**: `c("bcg", "penta1", "penta3", "measles1")`
    - **Comprehensive**: `c("penta1", "anc1", "opd", "delivery", "pnc1")`

??? "Consistency Benchmark Ranges"

    ```r
    all_consistency_ranges <- list(
      pair_penta    = c(lower = 0.95, upper = Inf),  # Penta1 >= 0.95 * Penta3
      pair_anc      = c(lower = 0.95, upper = Inf),  # ANC1 >= 0.95 * ANC4
      pair_delivery = c(lower = 0.7, upper = 1.3),   # 0.7 <= BCG/Delivery <= 1.3
      pair_malaria  = c(lower = 0.9, upper = 1.1)    # Malaria indicators within 10%
    )
    ```

    The ranges reflect programmatic expectations. For example, ANC1 should always be at least 95% of ANC4 (more women start care than complete four visits). The 5% tolerance accounts for data entry variations. BCG, as a birth dose vaccine, should approximately equal facility deliveries, with 30% tolerance for variation.

### Input/Output Specifications

#### Input File Structure

**Required File**: `hmis_[COUNTRY_ISO3].csv`

**Required Columns:**
- `facility_id` (character/integer): Unique identifier for each health facility
- `period_id` (integer): Time period in YYYYMM format (e.g., 202401 for January 2024)
- `indicator_common_id` (character): Standardized indicator names (e.g., "penta1", "anc1", "opd")
- `count` (numeric): Service volume or count for the indicator
- `admin_area_1` through `admin_area_8` (character): Geographic/administrative area columns

**Format Example:**

```csv
facility_id,period_id,indicator_common_id,count,admin_area_1,admin_area_2,admin_area_3
FAC001,202401,penta1,45,Country_A,Province_A,District_A
FAC001,202401,anc1,67,Country_A,Province_A,District_A
FAC001,202402,penta1,52,Country_A,Province_A,District_A
```

**Data Requirements:**
- At least 12 months of data recommended for robust outlier detection
- Missing values represented as NA or absent rows (both handled)
- Zero counts should be explicit zeros, not missing
- Geographic columns detected automatically (columns 2-8 are optional)

#### Output Files

??? "M1_output_outlier_list.csv - Flagged Outliers Only"

    **Purpose**: Quick reference list of only the observations flagged as outliers

    **Columns:**

    - `facility_id`: Facility identifier
    - `admin_area_[2-8]`: Geographic areas (dynamically included based on data)
    - `indicator_common_id`: Health indicator name
    - `period_id`: Time period (YYYYMM)
    - `year`, `month`: Extracted time components
    - `count`: Reported service volume
    - `median_volume`: Facility-indicator median
    - `mad_volume`: Median Absolute Deviation
    - `mad_residual`: Standardized residual
    - `pc`: Proportion of annual total
    - `outlier_mad`: MAD-based outlier flag
    - `outlier_pc`: Proportion-based outlier flag
    - `outlier_flag`: Final combined outlier flag

    **Use Case**: Data managers reviewing specific outliers for investigation or correction

??? "M1_output_outliers.csv - All Records with Outlier Flags"

    **Purpose**: Complete dataset with outlier metrics for all facility-indicator-period combinations

    **Columns**: Same as outlier_list.csv but includes all observations

    **Use Case**:

    - Input for Module 2 (Data Quality Adjustments)
    - Statistical analysis of outlier patterns
    - Generating visualizations of outlier prevalence

??? "M1_output_completeness.csv - Completeness Status"

    **Purpose**: Completeness flags for all facility-indicator-period combinations, including explicitly created records for missing months

    **Columns:**

    - `facility_id`: Facility identifier
    - `admin_area_[2-8]`: Geographic areas
    - `indicator_common_id`: Health indicator name
    - `period_id`: Time period (YYYYMM)
    - `year`, `month`, `quarter_id`: Time components
    - `count`: Reported volume (NA if missing)
    - `completeness_flag`: 0=Incomplete, 1=Complete, 2=Inactive (removed from output)

    **Special Features**:

    - Contains explicit rows for non-reporting months
    - Inactive periods (6+ months at start/end) excluded
    - Full time series for each facility-indicator combination

    **Use Case**:

    - Calculating completeness percentages
    - Identifying reporting gaps
    - Trend analysis of reporting behavior

??? "M1_output_consistency_geo.csv - Geographic-Level Consistency"

    **Purpose**: Consistency ratios calculated at the specified geographic level (e.g., district)

    **Columns:**

    - `admin_area_1` through `admin_area_[X]`: Geographic identifiers up to specified GEOLEVEL
    - `period_id`: Time period (YYYYMM)
    - `ratio_type`: Name of consistency pair (e.g., "pair_penta", "pair_anc")
    - `consistency_ratio`: Calculated ratio value
    - `sconsistency`: Binary flag (1=consistent, 0=inconsistent, NA=cannot calculate)

    **Format**: Long format with one row per geographic area-period-ratio type

    **Use Case**:

    - Understanding district-level service delivery patterns
    - Identifying geographic areas with consistency issues
    - Creating consistency heatmaps by zone

??? "M1_output_consistency_facility.csv - Facility-Level Consistency"

    **Purpose**: Geographic consistency results expanded to facility level, pivoted to wide format

    **Columns:**

    - `facility_id`: Facility identifier
    - `period_id`: Time period
    - `pair_[X]`: One column per consistency pair with flag values

    **Format**: Wide format with one row per facility-period

    **Use Case**:

    - Input for DQA scoring
    - Merging consistency flags with facility-level analyses
    - Facility-specific quality reports

??? "M1_output_dqa.csv - Final DQA Scores"

    **Purpose**: Composite data quality scores by facility and time period

    **Columns:**

    - `facility_id`: Facility identifier
    - `admin_area_[2-8]`: Geographic areas
    - `period_id`: Time period (YYYYMM)
    - `completeness_outlier_score`: Proportion of DQA indicators passing completeness & outlier checks (0-1)
    - `consistency_score`: Proportion of consistency pairs passing benchmarks (0-1, or NA if no pairs)
    - `dqa_mean`: Average of component scores (0-1)
    - `dqa_score`: Binary overall pass/fail (1 = all checks passed, 0 = any check failed)

    **Use Case**:

    - Filtering data for subsequent modules (e.g., only use facility-months with dqa_score=1)
    - Tracking data quality trends over time
    - Identifying facilities needing data quality improvement support

### Key Functions Documentation

??? "load_and_preprocess_data()"

    **Signature**: `load_and_preprocess_data(file_path)`

    **Purpose**: Loads HMIS data and prepares it for analysis by creating necessary date fields and composite indicators

    **Parameters:**

    - `file_path` (character): Path to HMIS CSV file

    **Returns**: List containing:

    - `data`: Preprocessed dataframe with date field added
    - `geo_cols`: Vector of detected geographic column names

    **Process:**
    1. Reads CSV file with HMIS data
    2. Converts `period_id` (YYYYMM format) to Date objects for temporal ordering
    3. Detects all administrative area columns (admin_area_1 through admin_area_8)
    4. Creates composite malaria indicator if component indicators exist:
       - Combines `rdt_positive` + `micro_positive` into `rdt_positive_plus_micro`
       - This composite is used for malaria consistency checks

    **Example:**

    ```r
    inputs <- load_and_preprocess_data("hmis_ISO3.csv")
    data <- inputs$data
    geo_cols <- inputs$geo_cols
    ```

??? "validate_consistency_pairs()"

    **Signature**: `validate_consistency_pairs(consistency_params, data)`

    **Purpose**: Validates that required indicator pairs exist in the dataset before running consistency analysis

    **Parameters:**

    - `consistency_params`: List containing consistency_pairs and consistency_ranges
    - `data`: The HMIS dataset

    **Returns**: Updated consistency_params with only valid pairs (empty list if no valid pairs)

    **Process:**
    1. Checks which indicators are available in the dataset
    2. Removes consistency pairs where one or both indicators are missing
    3. Issues warnings about removed pairs
    4. Returns empty list if no valid pairs remain

    **Example Output:**

    ```
    Warning: Skipping pair_delivery - indicator 'delivery' not found in data
    Warning: Skipping pair_malaria - indicator 'rdt_positive_plus_micro' not found in data
    Remaining consistency pairs: pair_penta, pair_anc
    ```

??? "outlier_analysis()"

    **Signature**: `outlier_analysis(data, geo_cols, outlier_params)`

    **Purpose**: Identifies statistical outliers in facility service volumes using dual detection methods

    **Parameters:**

    - `data`: HMIS data with facility_id, indicator_common_id, period_id, count
    - `geo_cols`: Vector of geographic column names
    - `outlier_params`: List containing:
      - `outlier_pc_threshold`: Proportion threshold (default 0.8)
      - `count_threshold`: Minimum count threshold (default 100)

    **Returns**: Dataframe with outlier flags and diagnostic metrics for each facility-indicator-period

    **Calculated Fields:**

    - `median_volume`: Median count by facility-indicator
    - `mad_volume`: MAD calculated on values >= median
    - `mad_residual`: Standardized residual (|count - median| / MAD)
    - `outlier_mad`: Binary flag (1 if mad_residual > MADS)
    - `pc`: Proportional contribution to annual total
    - `outlier_pc`: Binary flag (1 if pc > threshold)
    - `outlier_flag`: Final flag (1 if either method flags AND count > minimum threshold)

    **Algorithm Steps:**

    **Step 1**: Calculate median volume for each facility-indicator combination

    **Step 2**: Compute MAD using only values equal to or above the median
    - Avoids bias from facilities with many low-volume months
    - Standardizes residuals by dividing (count - median) by MAD
    - Flags outlier_mad = 1 if mad_residual > MADS parameter

    **Step 3**: Calculate proportional contribution
    - For each facility-indicator-year, sum total annual count
    - Calculate pc = count / annual_total
    - Flags outlier_pc = 1 if pc > OUTLIER_PROPORTION_THRESHOLD

    **Step 4**: Combine flags
    - Final outlier_flag = 1 if (outlier_mad = 1 OR outlier_pc = 1) AND count > MINIMUM_COUNT_THRESHOLD
    - This ensures only substantial volumes are flagged

??? "process_completeness()"

    **Signature**: `process_completeness(outlier_data_main)`

    **Purpose**: Main orchestration function that generates complete time series and assigns completeness flags for all indicators

    **Parameters:**

    - `outlier_data_main`: Outlier analysis results (contains all facility-indicator-period combinations with counts)

    **Returns**: Long format dataset with completeness flags for all facility-indicator-period combinations

    **Process:**

    1. Identifies first and last reporting period for each indicator globally
    2. Calls `generate_full_series_per_indicator()` for each indicator
    3. Applies completeness tagging logic (complete/incomplete/inactive)
    4. Merges with geographic metadata
    5. Combines results across all indicators
    6. Removes inactive periods (completeness_flag = 2)

    **Output Structure:**

    - Explicit rows for both reported and non-reported periods
    - Completeness flag: 0 (incomplete), 1 (complete), 2 (inactive - removed)
    - Full time series from first to last reporting period per indicator

??? "generate_full_series_per_indicator()"

    **Signature**: `generate_full_series_per_indicator(outlier_data, indicator_id, timeframe)`

    **Purpose**: Creates a complete monthly time series for a specific indicator, filling in gaps where facilities did not report

    **Parameters:**

    - `outlier_data`: data.table with outlier results
    - `indicator_id`: Specific indicator to process (e.g., "penta1")
    - `timeframe`: Data table with first_pid and last_pid for each indicator

    **Returns**: Complete time series with explicit rows for both reported and non-reported periods

    **Process:**

    1. Subsets data to specific indicator
    2. Generates monthly sequence from first to last period_id for that indicator
    3. Creates complete facility-period grid (all facilities × all months) using `CJ()` cross join
    4. Merges with actual reported data
    5. Missing counts indicate non-reporting periods
    6. Applies inactive detection algorithm

    **Inactive Detection Algorithm:**

    ```r
    # A facility is flagged inactive (offline_flag = 2) if:
    # 1. Missing 6+ consecutive months BEFORE first report, OR
    # 2. Missing 6+ consecutive months AFTER last report

    offline_flag := fifelse(
      (missing_group == 1 & missing_count >= 6 & !first_report_idx) |
      (missing_group == max(missing_group) & missing_count >= 6 & !last_report_idx),
      2L, 0L
    )
    ```

    **Example Timeline:**

    ```
    Facility A reporting pattern for indicator "penta1":
    Period:  202001 202002 202003 202004 202005 202006 202007 202008 202009 202010
    Count:   NA     NA     NA     NA     50     30     NA     NA     40     35
    Flag:    2      2      2      2      1      1      0      0      1      1
             [----Inactive----] [---Active period with gaps---]

    Explanation:
    - First 4 months: Inactive (6+ months missing before first report at 202005)
    - 202005-202006: Complete (reported)
    - 202007-202008: Incomplete (gaps in active period)
    - 202009-202010: Complete (reported)
    ```

??? "geo_consistency_analysis()"

    **Signature**: `geo_consistency_analysis(data, geo_cols, geo_level, consistency_params)`

    **Purpose**: Calculates consistency ratios at the geographic level to account for patients seeking services across multiple facilities within a district/ward

    **Parameters:**

    - `data`: Outlier data (with outliers already flagged)
    - `geo_cols`: Vector of geographic column names
    - `geo_level`: Geographic level for aggregation (e.g., "admin_area_3")
    - `consistency_params`: List with consistency_pairs and consistency_ranges

    **Returns**: Long format dataframe with geographic-level consistency results

    **Process:**

    1. Excludes outliers (sets count to NA where outlier_flag = 1)
    2. Aggregates data to specified geographic level by period (sums across facilities)
    3. Reshapes to wide format (one column per indicator)
    4. Calculates ratio for each indicator pair
    5. Flags consistency based on predefined ranges

    **Output Columns:**

    - Geographic identifiers (up to specified level)
    - `period_id`: Time period
    - `ratio_type`: Name of the consistency pair (e.g., "pair_penta")
    - `consistency_ratio`: Calculated ratio value
    - `sconsistency`: Binary flag (1 = consistent, 0 = inconsistent, NA = cannot calculate)

    **Example Output:**

    ```
    admin_area_2  admin_area_3  period_id  ratio_type    consistency_ratio  sconsistency
    District_A    Ward_1        202401     pair_penta    1.05               1
    District_A    Ward_1        202401     pair_anc      0.88               0
    District_A    Ward_2        202401     pair_penta    0.97               1
    ```

    **Rationale**: Measuring consistency at the geographic level accounts for patient movement between facilities and provides a more accurate picture of service utilization patterns across a community.

??? "expand_geo_consistency_to_facilities()"

    **Signature**: `expand_geo_consistency_to_facilities(facility_metadata, geo_consistency_results, geo_level)`

    **Purpose**: Assigns geographic-level consistency results to individual facilities

    **Parameters:**

    - `facility_metadata`: Facility list with geographic assignments
    - `geo_consistency_results`: Output from geo_consistency_analysis()
    - `geo_level`: Geographic level used in consistency analysis

    **Returns**: Facility-level dataset with consistency flags

    **Process:**

    - Extracts facility list with their geographic assignments
    - Performs left join to replicate geo-level consistency scores to all facilities in that area
    - Uses many-to-many relationship to handle multiple periods and ratio types

    **Rationale**: Since consistency is measured at the geographic level (accounting for patient movement between facilities), all facilities within the same district/ward receive the same consistency scores.

??? "dqa_with_consistency()"

    **Signature**: `dqa_with_consistency(completeness_data, consistency_data, outlier_data, geo_cols, dqa_rules)`

    **Purpose**: Calculates comprehensive DQA scores including consistency checks when consistency pairs are available

    **Parameters:**

    - `completeness_data`: Output from process_completeness()
    - `consistency_data`: Wide-format facility consistency results
    - `outlier_data`: Output from outlier_analysis()
    - `geo_cols`: Vector of geographic column names
    - `dqa_rules`: List specifying required values for each dimension

    **DQA Rules Configuration:**

    ```r
    dqa_rules <- list(
      completeness = 1,   # Must be complete (flag = 1)
      outlier_flag = 0,   # Must NOT be an outlier (flag = 0)
      sconsistency = 1    # Must be consistent (flag = 1)
    )
    ```

    **Scoring Algorithm:**

    **1. Completeness-Outlier Score** (per facility-period):
    - Each DQA indicator scores 0-2 points (1 for completeness + 1 for no outlier)
    - Maximum possible = 2 × number of DQA indicators
    - Score = Total Points / Maximum Points

    **2. Consistency Score** (per facility-period):
    - Only counts pairs where both indicators exist (NA pairs excluded from denominator)
    - Score = Number of passing pairs / Number of available pairs
    - If no pairs available, score = 0

    **3. Mean DQA Score:**
    - Average of completeness-outlier score and consistency score
    - Formula: `(completeness_outlier_score + consistency_score) / 2`

    **4. Binary DQA Score:**
    - 1 if ALL available consistency pairs pass AND completeness-outlier score is perfect
    - 0 otherwise

    **Handling Missing Indicators:**
    The function intelligently handles cases where some consistency indicators are missing:
    - NA values in consistency pairs are NOT replaced with 0
    - Only available pairs contribute to the denominator
    - This prevents penalizing facilities for indicators they don't provide

    **Example Calculation:**

    ```
    Facility X in period 202401:
    - DQA Indicators: penta1, anc1, opd (3 indicators)
    - Completeness: All 3 complete → 3 points
    - Outliers: None → 3 points
    - Total: 6/6 → completeness_outlier_score = 1.0

    Consistency Pairs:
    - pair_penta (penta1/penta3): Pass (1)
    - pair_anc (anc1/anc4): Fail (0)
    - pair_delivery: NA (bcg not a DQA indicator)

    Consistency calculation:
    - Available pairs: 2 (penta, anc)
    - Passing pairs: 1 (penta)
    - consistency_score = 1/2 = 0.5

    Final scores:
    - dqa_mean = (1.0 + 0.5) / 2 = 0.75
    - dqa_score = 0 (not all pairs passed)
    ```

??? "dqa_without_consistency()"

    **Signature**: `dqa_without_consistency(completeness_data, outlier_data, geo_cols, dqa_rules)`

    **Purpose**: Calculates DQA scores using only completeness and outlier checks when consistency data is unavailable or no valid consistency pairs exist

    **When Used:**

    - No consistency pairs defined in configuration
    - All consistency pairs have missing indicators
    - Dataset doesn't contain paired indicators

    **Scoring:**

    - Uses only completeness and outlier components
    - `dqa_mean` = `completeness_outlier_score`
    - `dqa_score` = 1 if all completeness and outlier checks pass, 0 otherwise

    **Output Structure:**

    ```r
    dqa_results <- data.frame(
      facility_id,
      admin_area_X,              # Dynamic geographic columns
      period_id,
      completeness_outlier_score, # Range: 0-1
      dqa_mean,                   # Range: 0-1 (equals completeness_outlier_score)
      dqa_score                   # Binary: 0 or 1
    )
    ```

### Statistical Methods & Algorithms

??? "Median Absolute Deviation (MAD) Calculation"

    The MAD is a robust measure of variability that is less sensitive to outliers than standard deviation.

    **Standard MAD Algorithm:**
    1. Compute the median of the dataset
    2. Calculate absolute deviations: |value - median| for each data point
    3. Find the median of these absolute deviations

    **FASTR Modification:**
    The module calculates MAD using only values at or above the median, making it more sensitive to high outliers while avoiding bias from facilities with many low-volume months.

    **Outlier Degree Calculation:**

    $$
    \text{MAD Residual} = \frac{|\text{volume} - \text{median volume}|}{\text{MAD}}
    $$

    **Outlier Classification:**
    - If MAD Residual > 10 (configurable via `MADS` parameter), the value is flagged as a statistical outlier

    **Example:**

    ```
    Facility ABC, Indicator: penta1
    Monthly counts: 20, 25, 22, 28, 24, 26, 150, 23, 27, 25, 21, 24

    Step 1: Calculate median = 24.5
    Step 2: Values >= median: 25, 28, 24.5, 26, 150, 27, 25, 24.5
    Step 3: Absolute deviations from median: 0.5, 3.5, 0, 1.5, 125.5, 2.5, 0.5, 0
    Step 4: MAD = median(0, 0, 0.5, 0.5, 1.5, 2.5, 3.5, 125.5) = 1.0
    Step 5: For count=150: MAD residual = |150 - 24.5| / 1.0 = 125.5
    Step 6: 125.5 > 10, therefore 150 is flagged as an outlier
    ```

??? "Proportional Outlier Detection"

    This method identifies months where a single observation represents an unusually large proportion of the annual total for a facility-indicator combination.

    **Algorithm:**
    1. For each facility-indicator-year, sum the total annual count
    2. Calculate the proportion: `pc = monthly_count / annual_total`
    3. Flag as outlier if `pc > OUTLIER_PROPORTION_THRESHOLD` (default 0.8)

    **Rationale:**
    A facility reporting 80% of its annual volume in a single month likely indicates a data entry error (e.g., cumulative reporting instead of monthly, extra digit entered).

    **Example:**

    ```
    Facility XYZ, Indicator: anc1, Year: 2024
    Monthly counts: 15, 18, 12, 16, 890, 14, 17, 13, 16, 15, 14, 12
    Annual total: 1052

    For May (count=890):
    pc = 890 / 1052 = 0.846
    0.846 > 0.8, therefore May is flagged as a proportional outlier
    ```

??? "Consistency Ratio Benchmarks"

    The module applies programmatically defined benchmarks for indicator pairs:

    **ANC Consistency:**

    $$
    \text{ANC Consistency} =
    \begin{cases}
    1, & \frac{\text{ANC1 Volume}}{\text{ANC4 Volume}} \geq 0.95 \\
    0, & \text{otherwise}
    \end{cases}
    $$

    **Interpretation**: More women should start antenatal care (ANC1) than complete four visits (ANC4). The ratio is expected to be ≥ 0.95, allowing up to 5% tolerance for data variations.

    **Penta Consistency:**

    $$
    \text{Penta Consistency} =
    \begin{cases}
    1, & \frac{\text{Penta1 Volume}}{\text{Penta3 Volume}} \geq 0.95 \\
    0, & \text{otherwise}
    \end{cases}
    $$

    **Interpretation**: More children should receive the first pentavalent dose (Penta1) than complete the three-dose series (Penta3).

    **BCG/Delivery Consistency:**

    $$
    \text{BCG/Delivery Consistency} =
    \begin{cases}
    1, & 0.7 \leq \frac{\text{BCG Volume}}{\text{Delivery Volume}} \leq 1.3 \\
    0, & \text{otherwise}
    \end{cases}
    $$

    **Interpretation**: BCG is a birth dose vaccine, so BCG vaccinations should approximately equal facility deliveries. The wider range (±30%) accounts for infants born elsewhere receiving BCG at the facility or facility-born infants receiving BCG elsewhere.

    **Implementation Detail:**
    Consistency is assessed at the district/ward level (specified by `GEOLEVEL`) to account for patients visiting multiple facilities within their local area for different services.

??? "Completeness Calculation"

    For a given indicator in a given month:

    $$
    \text{Completeness} = \frac{\text{Number of reporting facilities}}{\text{Number of expected facilities}} \times 100
    $$

    **Expected Facilities Definition:**
    A facility is expected to report for an indicator if it has ever reported for that indicator within the analysis timeframe AND is not flagged as inactive.

    **Inactive Facility Definition:**
    A facility is flagged as inactive for periods where it did not report for six or more consecutive months before its first report or after its last report.

    **Example:**

    ```
    District has 20 facilities that have ever reported penta1 data in 2024
    In March 2024:
    - 18 facilities submitted penta1 data
    - 2 facilities did not submit (but are not inactive)

    Completeness = 18 / 20 × 100 = 90%
    ```

    **Important Note**: A high level of completeness does not necessarily indicate that the HMIS is representative of all service delivery in the country, as some services may not be delivered in facilities or some facilities may not report. For countries where DHIS2 does not store zeros, indicator completeness may be underestimated if there are many low-volume facilities.

??? "DQA Composite Score Calculation"

    The DQA score combines three quality dimensions for a defined set of core indicators.

    **Component Scores:**

    **1. Completeness-Outlier Score:**

    $$
    \text{Completeness-Outlier Score} = \frac{\sum (\text{completeness pass} + \text{outlier pass})}{2 \times \text{number of DQA indicators}}
    $$

    **2. Consistency Score:**

    $$
    \text{Consistency Score} = \frac{\text{Number of pairs passing benchmarks}}{\text{Number of available pairs}}
    $$

    **3. Mean DQA Score:**

    $$
    \text{DQA Mean} = \frac{\text{Completeness-Outlier Score} + \text{Consistency Score}}{2}
    $$

    **4. Binary DQA Score:**

    $$
    \text{DQA Score} =
    \begin{cases}
    1, & \text{if all checks passed} \\
    0, & \text{otherwise}
    \end{cases}
    $$

    **Passing Criteria for Binary Score:**
    - ALL DQA indicators must be complete (completeness_flag = 1)
    - ALL DQA indicators must be free of outliers (outlier_flag = 0)
    - ALL available consistency pairs must pass benchmarks (sconsistency = 1)

    **Example Calculation:**

    ```
    Facility 123, Period 202403
    DQA Indicators: penta1, anc1, opd

    Completeness: penta1=1, anc1=1, opd=1 → 3 points
    Outliers: penta1=0, anc1=0, opd=0 → 3 points
    Completeness-Outlier Score = 6 / (2×3) = 1.0

    Consistency Pairs:
    - pair_penta: 1 (pass)
    - pair_anc: 1 (pass)
    Consistency Score = 2 / 2 = 1.0

    DQA Mean = (1.0 + 1.0) / 2 = 1.0
    DQA Score = 1 (all checks passed)
    ```

### Code Examples

??? "Example 1: Running the Module with Default Settings"

    ```r
    # Set working directory
    setwd("/path/to/module/directory")

    # Load required libraries
    library(zoo)
    library(stringr)
    library(dplyr)
    library(tidyr)
    library(data.table)

    # The module will automatically:
    # 1. Load hmis_ISO3.csv
    # 2. Run all analyses with default parameters
    # 3. Generate output CSV files in the working directory

    source("01_module_data_quality_assessment.R")
    ```

??? "Example 2: Adjusting Outlier Detection Sensitivity"

    ```r
    # Make outlier detection more sensitive (lower thresholds)
    OUTLIER_PROPORTION_THRESHOLD <- 0.6   # Flag if >60% of annual volume (was 80%)
    MINIMUM_COUNT_THRESHOLD <- 50         # Consider counts >=50 (was 100)
    MADS <- 8                             # Flag at 8 MADs (was 10)

    # Run the module
    source("01_module_data_quality_assessment.R")
    ```

    **Use Case**: Countries with generally low service volumes where the default thresholds are too conservative.

??? "Example 3: Different Geographic Level for Consistency"

    ```r
    # Use district level (admin_area_2) instead of sub-district (admin_area_3)
    GEOLEVEL <- "admin_area_2"

    # This affects consistency analysis aggregation level
    source("01_module_data_quality_assessment.R")
    ```

    **Use Case**: Sub-district level has sparse data or too few facilities per area, making district-level aggregation more stable.

??? "Example 4: Custom DQA Indicators"

    ```r
    # Focus DQA on maternal health indicators only
    DQA_INDICATORS <- c("anc1", "anc4", "delivery", "pnc1")

    # Only evaluate anc consistency pair
    CONSISTENCY_PAIRS_USED <- c("anc")

    source("01_module_data_quality_assessment.R")
    ```

    **Use Case**: Specialized analysis focusing on a specific service area.

??? "Example 5: Running for Different Country"

    ```r
    # Configure for your country
    COUNTRY_ISO3 <- "ISO3"  # Replace with your country code
    PROJECT_DATA_HMIS <- "hmis_ISO3.csv"
    GEOLEVEL <- "admin_area_3"

    # Adjust for country-specific indicators if needed
    DQA_INDICATORS <- c("penta1", "anc1", "opd", "fp_new")

    source("01_module_data_quality_assessment.R")
    ```

??? "Example 6: Programmatic Use of Outputs"

    ```r
    # After running the module, work with outputs

    # Load DQA results
    dqa_results <- read.csv("M1_output_dqa.csv")

    # Filter to high-quality facility-months only
    high_quality <- dqa_results %>%
      filter(dqa_score == 1)

    # Calculate percentage of facility-months passing DQA by district
    quality_by_district <- dqa_results %>%
      group_by(admin_area_2, period_id) %>%
      summarize(
        total_facility_months = n(),
        passing_quality = sum(dqa_score == 1),
        pct_passing = 100 * passing_quality / total_facility_months
      )

    # Identify facilities with consistently poor quality (never passing)
    poor_quality_facilities <- dqa_results %>%
      group_by(facility_id) %>%
      summarize(
        months_analyzed = n(),
        months_passed = sum(dqa_score == 1),
        pct_passed = 100 * months_passed / months_analyzed
      ) %>%
      filter(pct_passed == 0)
    ```

### Troubleshooting

??? "Problem: Module skips consistency analysis"

    **Symptoms:**
    - Console message: "No valid consistency pairs found"
    - M1_output_consistency_geo.csv has only headers
    - DQA scores calculated without consistency component

    **Diagnosis:**
    Check that both indicators in each pair exist in your dataset:

    ```r
    # Load your data
    data <- read.csv("hmis_[COUNTRY].csv")

    # Check available indicators
    print(unique(data$indicator_common_id))

    # Compare with required pairs
    # For pair_penta: need "penta1" and "penta3"
    # For pair_anc: need "anc1" and "anc4"
    # For pair_delivery: need "bcg" and "delivery" (or "sba")
    ```

    **Solutions:**
    1. Adjust `CONSISTENCY_PAIRS_USED` to only include pairs with available indicators
    2. Modify indicator names in your data to match expected names
    3. Accept that DQA will be calculated without consistency component

??? "Problem: All facilities flagged as outliers"

    **Symptoms:**
    - Very high percentage of outlier_flag = 1 in M1_output_outliers.csv
    - Most observations in outlier_list.csv

    **Diagnosis:**
    Your thresholds may be too sensitive for your data context.

    **Solutions:**

    1. Increase MAD threshold:

    ```r
    MADS <- 15  # Increase from default 10
    ```

    2. Increase proportion threshold:

    ```r
    OUTLIER_PROPORTION_THRESHOLD <- 0.9  # Increase from 0.8
    ```

    3. Increase minimum count threshold (focus on larger facilities):

    ```r
    MINIMUM_COUNT_THRESHOLD <- 200  # Increase from 100
    ```

    4. Review the data: Check if there are genuine quality issues requiring data cleaning rather than parameter adjustment

??? "Problem: No DQA results generated"

    **Symptoms:**
    - M1_output_dqa.csv is empty or has only headers
    - Console message: "Skipping DQA analysis - none of the required indicators found"

    **Diagnosis:**
    None of the indicators specified in `DQA_INDICATORS` exist in your dataset.

    **Solution:**
    Check which DQA indicators are missing:

    ```r
    # Load data
    data <- read.csv("hmis_[COUNTRY].csv")

    # Check which DQA indicators are missing
    available_indicators <- unique(data$indicator_common_id)
    missing_indicators <- setdiff(DQA_INDICATORS, available_indicators)
    print(paste("Missing DQA indicators:", paste(missing_indicators, collapse=", ")))

    # Available DQA indicators
    available_dqa <- intersect(DQA_INDICATORS, available_indicators)
    print(paste("Available DQA indicators:", paste(available_dqa, collapse=", ")))
    ```

    Then update `DQA_INDICATORS` to include only available indicators:

    ```r
    DQA_INDICATORS <- c("penta1", "anc1")  # Only use what's available
    ```

??? "Problem: Consistency ratios seem incorrect"

    **Symptoms:**
    - All consistency flags are 0 (inconsistent)
    - Consistency ratios are unexpectedly high or low

    **Diagnosis:**
    The geographic aggregation level may be inappropriate for your data.

    **Investigation:**

    ```r
    # Load geographic consistency results
    geo_cons <- read.csv("M1_output_consistency_geo.csv")

    # Check distribution of consistency ratios
    summary(geo_cons$consistency_ratio)

    # Check sample sizes at geographic level
    outliers <- read.csv("M1_output_outliers.csv")
    geo_summary <- outliers %>%
      group_by(admin_area_3, period_id) %>%
      summarize(
        n_facilities = n_distinct(facility_id),
        total_volume = sum(count, na.rm = TRUE)
      )
    summary(geo_summary$n_facilities)
    ```

    **Solutions:**

    1. If geographic areas have very few facilities (1-2), use higher level:

    ```r
    GEOLEVEL <- "admin_area_2"  # Use district instead of sub-district
    ```

    2. If ratios are generally below 0.95 for ANC/Penta pairs, this may indicate genuine programmatic issues (high dropout) rather than data quality problems

    3. Review the consistency benchmark ranges - they may need adjustment for your context:

    ```r
    # Example: Allow higher dropout (lower ratio) for Penta
    all_consistency_ranges$pair_penta <- c(lower = 0.85, upper = Inf)
    ```

??? "Problem: Completeness percentages seem low"

    **Symptoms:**
    - High proportion of completeness_flag = 0 in M1_output_completeness.csv

    **Diagnosis:**
    This could be legitimate (poor reporting) or an artifact of how your DHIS2 stores zero values.

    **Investigation:**

    ```r
    # Load completeness data
    completeness <- read.csv("M1_output_completeness.csv")

    # Check pattern: Are there explicit zeros or just missing values?
    outliers <- read.csv("M1_output_outliers.csv")
    table(is.na(outliers$count), outliers$count == 0)

    # Check completeness by indicator
    comp_by_indicator <- completeness %>%
      group_by(indicator_common_id) %>%
      summarize(
        pct_complete = 100 * mean(completeness_flag == 1),
        pct_incomplete = 100 * mean(completeness_flag == 0)
      )
    print(comp_by_indicator)
    ```

    **Considerations:**
    1. If your DHIS2 doesn't store zeros, low-volume facilities may appear incomplete when they legitimately had no services to report
    2. Completeness percentages should be interpreted in context - 70% completeness may be acceptable depending on the health system
    3. Use the completeness_flag in subsequent modules to weight estimates appropriately

??? "Problem: Error reading input file"

    **Symptoms:**
    - Error: "Cannot open file 'hmis_[COUNTRY].csv'"
    - Module crashes during data loading

    **Solutions:**

    1. Check file path and working directory:

    ```r
    getwd()  # Verify working directory
    list.files()  # Check if HMIS file is present
    ```

    2. Verify file name matches `PROJECT_DATA_HMIS` parameter

    3. Check file format (CSV, proper encoding, comma-separated)

    4. Ensure required columns exist:

    ```r
    # After loading
    names(data)  # Should include: facility_id, period_id, indicator_common_id, count
    ```

### Usage Notes

??? "Data Type Handling"

    **period_id Flexibility:**
    The module accepts `period_id` in multiple formats:
    - Integer: `202401`
    - String: `"202401"`
    - Numeric: `202401.0`

    All formats are internally converted to Date objects for correct chronological ordering:

    ```r
    # Internal conversion
    as.Date(sprintf("%04d-%02d-01", year, month))
    ```

    This ensures proper temporal ordering even with gaps in reporting periods.

    **Count Values:**
    - Numeric values required (integers or decimals)
    - Zero counts should be explicit `0`, not `NA`
    - Missing counts represented as `NA` or absent rows

    **Geographic Columns:**
    - Character type recommended
    - Can contain spaces and special characters
    - Case-sensitive in some operations

??? "Missing Value Strategy"

    The module uses context-specific approaches to missing values:

    **Outlier Analysis:**
    - NA values excluded from median/MAD calculations
    - Only non-NA values contribute to statistics
    - Prevents bias from sparse reporting

    **Completeness:**
    - Explicit NA in count column indicates non-reporting
    - Assigned completeness_flag = 0 (incomplete)
    - Distinguished from inactive periods (flag = 2, removed)

    **Consistency:**
    - NA ratios (from division by zero) kept as NA, not converted to 0
    - NA pairs excluded from consistency scoring denominator
    - Prevents penalizing facilities for unavailable indicators

    **DQA Scoring:**
    - NA consistency pairs excluded from denominator
    - Only available pairs affect consistency score
    - Allows partial scoring when some indicators missing

??? "Memory Considerations"

    For large datasets (>1 million rows), the module implements several optimizations:

    **data.table Usage:**
    - Completeness processing uses `data.table` for in-place operations
    - Significantly faster and more memory-efficient than `dplyr` for large data

    **Filtering Strategy:**
    - Filters to relevant indicators before expensive operations
    - Reduces memory footprint during calculations

    **Object Management:**
    - Removes intermediate objects after use
    - Prevents memory accumulation during sequential processing

    **Recommendations for Large Datasets:**
    - Allocate at least 8GB RAM for countries with >1000 facilities
    - Consider processing by year if multi-year datasets cause memory issues
    - Monitor memory usage: `pryr::mem_used()` at various stages

??? "Performance Optimization Opportunities"

    **Current Implementation:**
    The completeness analysis processes indicators sequentially using `lapply()`.

    **Potential Enhancement:**
    For datasets with many indicators, parallelization could improve performance:

    ```r
    # Future enhancement (not in current code)
    library(parallel)

    # Detect available cores
    n_cores <- detectCores() - 1

    # Parallel processing of indicators
    completeness_list <- mclapply(
      unique(outlier_data_main$indicator_common_id),
      function(ind) generate_full_series_per_indicator(
        outlier_data = outlier_data_main,
        indicator_id = ind,
        timeframe = indicator_timeframe
      ),
      mc.cores = n_cores
    )

    # Combine results
    completeness_data <- rbindlist(completeness_list)
    ```

    **Expected Speedup:**
    - 3-4x faster with 4 cores on datasets with 10+ indicators
    - Most beneficial for countries with many indicators and long time series

??? "Dynamic Indicator Selection"

    The module intelligently adapts to available data:

    **Delivery Indicator Selection:**

    ```r
    # Automatically chooses between "delivery" and "sba" for BCG consistency pair
    if ("delivery" %in% available_indicators) {
      PAIR_DELIVERY_B <- "delivery"
    } else if ("sba" %in% available_indicators) {
      PAIR_DELIVERY_B <- "sba"  # Skilled birth attendant
    } else {
      PAIR_DELIVERY_B <- "delivery"  # Default fallback
    }
    ```

    **DQA Indicator Validation:**

    ```r
    # Only use DQA indicators that exist in the dataset
    dqa_indicators_to_use <- intersect(DQA_INDICATORS, unique(data$indicator_common_id))

    # If none found, skip DQA analysis with informative message
    if (length(dqa_indicators_to_use) == 0) {
      print("Skipping DQA analysis - none of the required indicators found")
    }
    ```

    **Consistency Pair Validation:**
    The module checks each consistency pair and removes those with missing indicators, providing clear warnings about which pairs were skipped.

??? "Error Handling and Fallbacks"

    The module includes robust error handling:

    **Missing Consistency Pairs:**
    - If no valid pairs exist, skips consistency analysis
    - Uses `dqa_without_consistency()` for scoring
    - Outputs dummy files with proper headers

    **Missing Geographic Levels:**
    - Falls back to lowest available admin level if specified `GEOLEVEL` not found
    - Issues warning about the fallback

    **Empty Results:**
    - Creates CSV files with proper headers even when no data
    - Ensures downstream processes don't break

    **Missing Indicators:**
    - Validates all indicator requirements before analysis
    - Warns about removed pairs
    - Continues with available indicators

??? "Interpretation Guidelines"

    **Outlier Flags:**
    - outlier_flag = 1 suggests potential data quality issues, but require investigation
    - Not all flagged outliers are errors (genuine service campaigns can trigger flags)
    - Use mad_residual and pc values to prioritize review

    **Completeness:**
    - Completeness % varies by health system context
    - 80-90%+ is generally good, but depends on country
    - Trend over time more informative than absolute percentage
    - Low completeness for specific indicators may reflect genuine service gaps

    **Consistency:**
    - sconsistency = 0 may indicate data quality issues OR programmatic performance issues (e.g., high dropout)
    - Requires programmatic knowledge to interpret
    - Geographic patterns can help distinguish systematic issues from random errors

    **DQA Scores:**
    - dqa_score = 1 indicates data passed all checks, suitable for unadjusted use
    - dqa_score = 0 requires further investigation
    - dqa_mean provides nuanced view (0.75 = mostly good, 0.25 = mostly poor)

### Data Quality Metrics Summary

| Metric                        | Type        | Range      | Interpretation                                                            |
|-------------------------------|-------------|------------|---------------------------------------------------------------------------|
| outlier_flag                  | Binary      | 0 or 1     | 1 = Outlier detected by either method and count > threshold              |
| outlier_mad                   | Binary      | 0 or 1     | 1 = Statistical outlier (MAD-based)                                       |
| outlier_pc                    | Binary      | 0 or 1     | 1 = Proportional outlier (>80% of annual volume)                          |
| mad_residual                  | Continuous  | 0 to ∞     | Standardized deviation from median (higher = more extreme)                |
| pc                            | Continuous  | 0 to 1     | Proportion of annual volume (closer to 1 = more concentrated)             |
| completeness_flag             | Categorical | 0, 1, 2    | 0=Incomplete (missing), 1=Complete (reported), 2=Inactive (removed)      |
| sconsistency                  | Binary      | 0, 1, NA   | 1=Consistent (passes benchmark), 0=Inconsistent, NA=Cannot calculate     |
| consistency_ratio             | Continuous  | 0 to ∞     | Ratio of paired indicators (interpretation depends on pair)               |
| completeness_outlier_score    | Continuous  | 0 to 1     | Proportion of DQA indicators passing completeness & outlier checks        |
| consistency_score             | Continuous  | 0 to 1     | Proportion of consistency pairs passing benchmarks                        |
| dqa_mean                      | Continuous  | 0 to 1     | Average of component scores (overall quality measure)                     |
| dqa_score                     | Binary      | 0 or 1     | 1 = All checks passed (high quality), 0 = Any check failed               |


### Execution Workflow

The module follows this sequence:

```
1. DATA LOADING & PREPROCESSING
   ├─ Load HMIS CSV file
   ├─ Convert period_id to dates
   ├─ Detect geographic columns
   └─ Create composite malaria indicator (if applicable)

2. CONFIGURATION & VALIDATION
   ├─ Detect available indicators
   ├─ Dynamically select delivery indicator (delivery vs sba)
   ├─ Build consistency pairs based on available indicators
   ├─ Validate consistency pairs
   └─ Filter DQA indicators to available ones

3. OUTLIER ANALYSIS
   ├─ Calculate median and MAD by facility-indicator
   ├─ Flag MAD-based outliers (>10 MADs)
   ├─ Flag proportion-based outliers (>80% of annual volume)
   └─ Combine flags (either method + count > 100)

4. COMPLETENESS ANALYSIS
   ├─ Identify reporting timeframe per indicator
   ├─ Generate full time series (all facilities × all months)
   ├─ Tag reporting status (complete/incomplete/inactive)
   └─ Remove inactive periods (6+ months before first/after last report)

5. CONSISTENCY ANALYSIS (if applicable)
   ├─ Exclude outliers from data
   ├─ Aggregate to geographic level (e.g., district)
   ├─ Calculate ratios for indicator pairs
   ├─ Flag consistency based on predefined ranges
   ├─ Expand geo-level results to facilities
   └─ Pivot to wide format (one column per pair)

6. DQA SCORING
   ├─ Filter to DQA indicators only
   ├─ Merge completeness, outlier, and consistency results
   ├─ Calculate component scores:
   │  ├─ Completeness-outlier score (0-1)
   │  └─ Consistency score (0-1, if applicable)
   ├─ Calculate mean DQA score
   └─ Assign binary DQA pass/fail flag

7. EXPORT RESULTS
   ├─ M1_output_outlier_list.csv (outliers only)
   ├─ M1_output_outliers.csv (all records with flags)
   ├─ M1_output_completeness.csv (completeness flags)
   ├─ M1_output_consistency_geo.csv (geo-level consistency)
   ├─ M1_output_consistency_facility.csv (facility-level consistency)
   └─ M1_output_dqa.csv (final DQA scores)
```

---

**Last updated**: 10-11-2025
**Contact**: FASTR Project Team

