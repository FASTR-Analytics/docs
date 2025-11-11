# Module 3: Service Utilization

## 1. Overview (What & Why)

### What does this module do?

The Service Utilization module analyzes health service delivery patterns to detect and quantify disruptions in service volumes over time. It identifies when health services deviate significantly from expected patterns and measures the magnitude of these disruptions at national, provincial, and district levels.

Using statistical process control methods and regression analysis, the module compares actual service volumes against historical trends and seasonal patterns. This helps distinguish between normal fluctuations (like expected increases in malaria cases during rainy season) and genuine disruptions that require investigation (like sudden drops in antenatal care during a pandemic or conflict).

The analysis produces quantified estimates of service shortfalls and surpluses, enabling evidence-based resource allocation, policy decisions, and health system monitoring.

### Why is it needed in the FASTR pipeline?

Service utilization data reflects how populations access essential healthcare, but this data can fluctuate due to various factors: seasonal patterns, policy changes, external shocks (pandemics, natural disasters, conflicts), data quality issues, or service availability problems. Without systematic analysis, it's difficult to know whether observed changes represent normal variation or significant disruptions requiring action.

This module provides objective, data-driven identification of service delivery problems and quantifies their impact. It enables health system managers to detect emerging issues early, target resources to affected areas, and monitor recovery after disruptions. The module's outputs support dashboard monitoring, impact assessments, and policy evaluation.

### Quick Summary

| Component | Details |
|-----------|---------|
| **Inputs** | Raw HMIS data (`hmis_ISO3.csv`)<br>Outlier flags from Module 1 (`M1_output_outliers.csv`)<br>Adjusted service volumes from Module 2 (`M2_adjusted_data.csv`) |
| **Outputs** | Disruption flags (`M3_chartout.csv`)<br>Quantified impacts by geographic level (`M3_disruptions_analysis_*.csv`)<br>Shortfall/surplus summaries (`M3_all_indicators_shortfalls_*.csv`) |
| **Purpose** | Detect and quantify service delivery disruptions through two-stage analysis: control charts identify when disruptions occur, panel regression quantifies their magnitude |

---

## 2. How It Works

### High-Level Workflow

The module operates in two sequential stages, each with a distinct purpose:

**Stage 1: Control Chart Analysis** - Identifies unusual patterns in service volumes

1. **Prepare the data**: Load health service data, remove previously identified outliers, aggregate to the appropriate geographic level, and fill in missing months using interpolation.

2. **Model expected patterns**: For each combination of health indicator and geographic area, use robust statistical methods to estimate what service volumes should look like based on historical trends and seasonal patterns (e.g., accounting for predictable increases in malaria cases during rainy season).

3. **Detect deviations**: Compare actual service volumes to expected patterns and identify significant deviations using multiple detection rules:
   - **Sharp disruptions**: Single months with extreme deviations
   - **Sustained drops**: Gradual declines over several months
   - **Sustained dips**: Periods consistently below expected levels
   - **Sustained rises**: Periods consistently above expected levels
   - **Missing data patterns**: Gaps in reporting that may signal problems

4. **Flag disrupted periods**: Mark months where any disruption pattern is detected, ensuring recent months are always flagged for review.

**Stage 2: Disruption Analysis** - Quantifies the impact of identified disruptions

5. **Apply regression models**: Use panel regression at multiple geographic levels (national, provincial, district) to estimate how much service volumes changed during flagged disruption periods, controlling for trends and seasonality.

6. **Calculate shortfalls and surpluses**: Compare predicted volumes to actual volumes to quantify the magnitude of disruptions in absolute numbers and percentages.

7. **Generate outputs**: Create summary files showing disruption impacts at each geographic level, ready for visualization and reporting.

### Workflow Diagram

<iframe src="../images/mod3_workflow.html" width="100%" height="800" style="border: 1px solid #ccc; border-radius: 4px;" title="Module 3 Interactive Workflow"></iframe>

### Key Decision Points

**Geographic Level Selection**: The module can analyze disruptions at different geographic scales. You can choose to run analysis at national and provincial levels only (faster, suitable for routine monitoring) or include district and ward levels (slower, provides detailed local information for targeted interventions).

**Control Chart Level Selection**: This determines at which geographic level the control charts are calculated. The module uses two configuration flags:

- **Default (both flags FALSE)**: Control charts calculated at **provincial level (admin_area_2)** - data aggregated to provinces, control limits and disruption detection performed for each province-indicator combination. This is the fastest option suitable for routine monitoring.

- **RUN_DISTRICT_MODEL = TRUE**: Control charts calculated at **district level (admin_area_3)** - data aggregated to districts, enabling detection of local disruptions that might be masked in provincial aggregates. Slower but provides more detailed local information.

- **RUN_ADMIN_AREA_4_ANALYSIS = TRUE**: Control charts calculated at **ward/facility level (admin_area_4)** - finest level analysis detecting disruptions at individual health facilities or wards. Slowest option but identifies facility-specific issues for highly targeted interventions.

The control chart level determines where the statistical modeling occurs (trend estimation, control limits, disruption flagging). Disruption analysis outputs are then aggregated and reported at all available geographic levels (national, admin2, admin3, admin4), regardless of which level the control charts were calculated at.

**Sensitivity Settings**: The module uses configurable thresholds to determine what constitutes a "disruption." More sensitive settings (lower thresholds) will flag smaller deviations, useful for early warning systems. More conservative settings (higher thresholds) will only flag major disruptions, useful for focusing on critical issues.

**Data Completeness Approach**: The module accepts different versions of service counts from Module 2, allowing you to choose whether to adjust for reporting completeness or use raw counts.

### What Happens to the Data

**Input Transformation**: The module starts with facility-level service counts (e.g., number of deliveries at each clinic each month) and aggregates them to geographic areas (provinces, districts). Outliers identified in Module 1 are removed to prevent anomalous data points from skewing the analysis.

**Pattern Detection**: Using robust statistical methods, the module learns what "normal" looks like for each service and area based on historical patterns. It then identifies months where actual volumes deviate significantly from these patterns, accounting for predictable variations like seasonal changes.

**Impact Quantification**: For months flagged as disrupted, the module uses regression models to estimate what service volumes would have been without the disruption. By comparing predicted to actual volumes, it calculates how many services were missed (shortfalls) or how much service delivery increased (surpluses).

**Output Generation**: The final outputs provide disruption impacts at multiple geographic scales, enabling users to see both national-level summaries and local-level details. All calculations preserve the original data while adding predicted values and disruption metrics.

### Analysis Outputs and Visualization

The FASTR analysis generates four main visual outputs for disruption analysis:

**1. Change in Service Volume**

Time series showing percentage change in service volumes over time, identifying periods of significant increases or decreases across indicators.

![Change in service volume over time.](images/Module3_1_Change_in_service_volume.png)

**2. Actual vs Expected Services (National)**

Line charts comparing actual service delivery to expected volumes at the national level, with disrupted periods highlighted.

![Actual vs expected number of services at national level.](images/Module3_2_Actual_vs_expected_national.png)

**3. Actual vs Expected Services (Subnational)**

Line charts comparing actual service delivery to expected volumes at admin area 2 level, enabling identification of geographic variation in disruptions.

![Actual vs expected number of services at subnational level.](images/Module3_3_Actual_vs_expected_subnational.png)

**4. Volume Change Due to Data Quality Adjustments**

Comparison showing the impact of data quality adjustments from Module 2 on disruption detection and volume estimates.

![Volume change due to data quality adjustments.](images/Module3_4_Volume_change_adjustments.png)

**Interpretation Guide:**
- **Disrupted periods**: Indicated by shaded regions or highlighting where actual volumes deviate significantly from expected
- **Positive deviations**: Service volumes exceed expected (surpluses)
- **Negative deviations**: Service volumes fall below expected (shortfalls)
- **Control limits**: Statistical thresholds indicating normal variation vs. significant disruption

---

## 3. Detailed Reference

### Configuration Parameters

??? "Core Analysis Parameters"

    | Parameter | Default | Type | Description | Tuning Guidance |
    |-----------|---------|------|-------------|-----------------|
    | `COUNTRY_ISO3` | "ISO3" | String | Three-letter country code | Set to your country code (e.g., "RWA", "UGA", "ZMB") |
    | `SELECTEDCOUNT` | "count_final_both" | String | Data column used for analysis | Options: `count_final_none`, `count_final_completeness`, `count_final_both` |
    | `VISUALIZATIONCOUNT` | "count_final_both" | String | Data column used for visualization | Should match or complement `SELECTEDCOUNT` |

??? "Control Chart Parameters"

    | Parameter | Default | Type | Description | Tuning Guidance |
    |-----------|---------|------|-------------|-----------------|
    | `SMOOTH_K` | 7 | Integer (odd) | Rolling median window size in months | Larger values = smoother trends, less sensitivity. Must be odd number (e.g., 5, 7, 9, 11) |
    | `MADS_THRESHOLD` | 1.5 | Numeric | MAD units threshold for sharp disruptions | Lower = more sensitive (e.g., 1.0), higher = more conservative (e.g., 2.0) |
    | `DIP_THRESHOLD` | 0.90 | Numeric | Proportion threshold for sustained dips | 0.90 = flag if below 90% of expected (10% drop). Use 0.80 for 20% drop threshold |
    | `DIFFPERCENT` | 10 | Numeric | Percentage threshold for plotting disruptions | If actual differs from predicted by >10%, use predicted value in visualizations |

    **Note**: `RISE_THRESHOLD` is automatically calculated as `1 / DIP_THRESHOLD` (default: ~1.11) to mirror dip detection symmetrically.

??? "Geographic Analysis Parameters"

    | Parameter | Default | Type | Description | Tuning Guidance |
    |-----------|---------|------|-------------|-----------------|
    | `CONTROL_CHART_LEVEL` | Auto-set | String | Geographic level for control charts | Automatically set based on `RUN_DISTRICT_MODEL` and `RUN_ADMIN_AREA_4_ANALYSIS` |
    | `RUN_DISTRICT_MODEL` | FALSE | Logical | Whether to run admin_area_3 regressions | Set TRUE for district-level analysis (increases runtime) |
    | `RUN_ADMIN_AREA_4_ANALYSIS` | FALSE | Logical | Whether to run admin_area_4 analysis | Set TRUE for finest-level analysis (very slow for large datasets) |

??? "Data Source Parameters"

    | Parameter | Default | Type | Description |
    |-----------|---------|------|-------------|
    | `PROJECT_DATA_HMIS` | "hmis_ISO3.csv" | String | Filename for raw HMIS data |

??? "Parameter Selection Guide"

    **For High-Sensitivity Analysis** (detecting smaller disruptions):
    - `MADS_THRESHOLD = 1.0`
    - `DIP_THRESHOLD = 0.95` (5% drop)
    - `SMOOTH_K = 5` (less smoothing)

    **For Conservative Analysis** (only major disruptions):
    - `MADS_THRESHOLD = 2.0`
    - `DIP_THRESHOLD = 0.80` (20% drop)
    - `SMOOTH_K = 9` or `11` (more smoothing)

    **For Faster Runtime**:
    - `RUN_DISTRICT_MODEL = FALSE`
    - `RUN_ADMIN_AREA_4_ANALYSIS = FALSE`
    - `CONTROL_CHART_LEVEL = "admin_area_2"`

### Input/Output Specifications

??? "Input Requirements"

    #### Primary Inputs

    1. **`hmis_ISO3.csv`** (country-specific HMIS file where ISO3 is the 3-letter country code)
       - Raw HMIS service utilization data
       - Required columns: `facility_id`, `admin_area_1`, `admin_area_2`, `admin_area_3`, `admin_area_4`, `indicator_common_id`, `period_id`, service count columns

    2. **`M1_output_outliers.csv`**
       - Output from Module 1 (Data Quality Assessment)
       - Contains `outlier_flag` to exclude anomalous data points
       - Required columns: `facility_id`, `indicator_common_id`, `period_id`, `outlier_flag`

    3. **`M2_adjusted_data.csv`**
       - Output from Module 2 (Data Quality Adjustments)
       - Contains adjusted service counts with different completeness assumptions
       - Required columns: `facility_id`, `indicator_common_id`, `period_id`, `count_final_none`, `count_final_completeness`, `count_final_both`

    #### Data Requirements

    - **Temporal coverage**: Minimum 12 months of data for seasonal modeling
    - **Data completeness**: Missing months are filled using interpolation
    - **Geographic completeness**: Data at specified administrative levels
    - **Count data**: Non-negative integer counts (predictions are bounded at zero)

    ### Outputs

    #### 1. Control Chart Results

    **`M3_chartout.csv`**

    **Purpose**: Contains flagged disruptions from the control chart analysis

    **Columns**:

    - `admin_area_*`: Geographic identifier (level depends on `CONTROL_CHART_LEVEL`)
    - `indicator_common_id`: Health service indicator code
    - `period_id`: Time period in YYYYMM format
    - `tagged`: Binary flag (1 = disruption detected, 0 = normal)
    - `count_original`: Actual service volume
    - `count_predict`: Predicted volume from regression
    - `count_smooth`: Smoothed prediction
    - `residual`: Deviation from expected
    - `robust_control`: Standardized residual
    - `tag_sharp`, `tag_sustained`, `tag_sustained_dip`, `tag_sustained_rise`, `tag_missing`: Individual disruption flags

    **Use**: Identifies which months require further investigation for each indicator-geography combination

    **`M3_service_utilization.csv`**

    **Purpose**: Pass-through copy of adjusted data for visualization

    **Source**: Direct copy of `M2_adjusted_data.csv`

    **Use**: Provides baseline data for plotting actual service volumes

    **`M3_memory_log.txt`**

    **Purpose**: Tracks memory usage throughout execution

    **Use**: Diagnostics for performance optimization and troubleshooting

    #### 2. Disruption Analysis Results

    **`M3_disruptions_analysis_admin_area_1.csv`** (National level - always generated)

    **Columns**:

    - `admin_area_1`: Country name
    - `indicator_common_id`: Health service indicator
    - `period_id`: Time period (YYYYMM)
    - `count_sum`: Actual service volume (sum across all facilities)
    - `count_expect_sum`: Expected service volume (sum of predictions)
    - `count_expected_if_above_diff_threshold`: Value for plotting (expected if |difference| > DIFFPERCENT, otherwise actual)

    **`M3_disruptions_analysis_admin_area_2.csv`** (Province level - always generated)

    **Additional column**: `admin_area_2` (province/region name)

    **Same structure**: As admin_area_1 file but disaggregated by province

    **`M3_disruptions_analysis_admin_area_3.csv`** (District level - conditional)

    **Generated when**: `RUN_DISTRICT_MODEL = TRUE`

    **Additional columns**: `admin_area_2`, `admin_area_3`

    **Same structure**: As above but disaggregated by district

    **`M3_disruptions_analysis_admin_area_4.csv`** (Ward level - conditional)

    **Generated when**: `RUN_ADMIN_AREA_4_ANALYSIS = TRUE`

    **Additional columns**: `admin_area_2`, `admin_area_3`, `admin_area_4`

    **Warning**: Very large file size for countries with many wards

    #### 3. Shortfall/Surplus Summary Files

    **`M3_all_indicators_shortfalls_admin_area_*.csv`** (one for each geographic level)

    **Purpose**: Pre-calculated shortfall and surplus metrics for reporting

    **Common columns**:

    - Geographic identifier(s): `admin_area_*`
    - `indicator_common_id`: Health service indicator
    - `period_id`: Time period (YYYYMM)
    - `count_sum`: Actual service volume
    - `count_expect_sum`: Expected service volume
    - `shortfall_absolute`: Absolute number of missing services (if negative disruption)
    - `shortfall_percent`: Percentage shortfall relative to expected
    - `surplus_absolute`: Absolute number of excess services (if positive disruption)
    - `surplus_percent`: Percentage surplus relative to expected

    **Note**: If optional geographic levels are disabled, empty placeholder files are created for compatibility with downstream processes.

    #### Temporary Files (Automatically Cleaned)

    During execution, the module creates temporary batch files for memory management:
    - `M3_temp_controlchart_batch_*.csv`
    - `M3_temp_indicator_batch_*.csv`
    - `M3_temp_province_batch_*.csv`
    - `M3_temp_district_batch_*.csv`
    - `M3_temp_admin4_batch_*.csv`

    These are automatically deleted upon successful completion. If the script crashes, these files may remain and will be cleaned up on the next run.

### Key Functions Documentation

??? "`robust_control_chart(panel_data, selected_count)`"

    **Purpose**: Identifies anomalies in service utilization using robust regression and MAD-based control limits.

    **Inputs**:

    - `panel_data`: Time series data for a specific indicator-geography combination
    - `selected_count`: Column name containing service volume counts to analyze

    **Process**:

    1. Fits a robust linear model (using `MASS::rlm()`) with seasonal controls and time trends
    2. Applies rolling median smoothing to predicted values to reduce noise
    3. Calculates residuals and standardizes them using Median Absolute Deviation (MAD)
    4. Applies rule-based tagging logic to identify different disruption types
    5. Flags recent months automatically to ensure timely detection

    **Outputs**:

    - `count_predict`: Predicted service volume from robust regression
    - `count_smooth`: Smoothed predictions using rolling median
    - `residual`: Difference between actual and smoothed values
    - `robust_control`: Standardized residual (residual/MAD)
    - `tagged`: Binary flag (1 = disruption detected, 0 = normal variation)
    - Additional flags: `tag_sharp`, `tag_sustained`, `tag_sustained_dip`, `tag_sustained_rise`, `tag_missing`

    **Key Features**:

    - Handles missing data gracefully with interpolation
    - Uses robust regression to minimize influence of outliers
    - Employs multiple disruption detection rules for different patterns
    - Ensures non-negative predictions (counts cannot be negative)

    ### Panel Regression Models

    The disruption analysis uses fixed-effects panel regression models (`fixest::feols()`) at multiple geographic levels.

    **Country-wide Model** (Admin Area 1):

    ```r
    count ~ date + factor(month) + tagged
    ```

    Clustered standard errors at district level (`admin_area_3`)

    **Province-level Models** (Admin Area 2):

    ```r
    count ~ date + factor(month) + tagged | admin_area_2
    ```

    Separate regression for each province, clustered at district level

    **District-level Models** (Admin Area 3 - optional):

    ```r
    count ~ date + factor(month) + tagged | admin_area_3
    ```

    Separate regression for each district, clustered at ward level (`admin_area_4`)

    **Ward-level Models** (Admin Area 4 - optional):

    ```r
    count ~ date + factor(month) + tagged | admin_area_4
    ```

    Separate regression for each ward/finest unit

    ### Supporting Functions

    **`mem_usage(msg)`**: Tracks and logs memory consumption throughout execution

    **Data Processing**:

    - Batch processing with disk-based temporary files for memory efficiency
    - Efficient data.table operations for large datasets
    - Progressive aggregation and merging strategies

### Statistical Methods & Algorithms

??? "Control Chart Analysis"

    Service volumes are aggregated at the specified geographic level (configurable via `CONTROL_CHART_LEVEL`). The pipeline removes outliers (`outlier_flag == 1`), fills in missing months, and filters low-volume months (<50% of global mean volume).

    A robust regression model estimates expected service volumes per indicator × geographic area (`panelvar`). A centered rolling median is applied to smooth the predicted values. Residuals (actual - smoothed) are standardized using MAD. Disruptions are identified using a rule-based tagging system.

    #### Disruption Detection Rules

    Each rule is controlled by user-defined parameters, allowing customization of the sensitivity and behavior of the detection logic:

    **Sharp Disruptions**: Flags a single month when the standardized residual (residual divided by MAD) exceeds a threshold:

    $$ \left| \frac{\text{residual}}{\text{MAD}} \right| \geq \text{MADS_THRESHOLD} $$

    - **Parameter:** `MADS_THRESHOLD` (default: `1.5`)
    - Lower values make the detection more sensitive to sudden spikes or dips.

    **Sustained Drops**: Flags a sustained drop if:

    - Three consecutive months show mild deviations (standardized residual ≥ 1), and
    - The final month also exceeds the `MADS_THRESHOLD`.

    This captures slower, compounding declines.

    **Sustained Dips**: Flags periods where the actual volume falls consistently below a defined proportion of expected volume (smoothed prediction):

    $$ \text{count_original} < \text{DIP_THRESHOLD} \times \text{count_smooth} $$

    - **Parameter:** `DIP_THRESHOLD` (default: `0.90`)
    - Users can adjust this to detect deeper or shallower dips (e.g., `0.80` for a 20% drop).

    **Sustained Rises**: Symmetric to dips, flags periods of consistent overperformance:

    $$ \text{count_original} > \text{RISE_THRESHOLD} \times \text{count_smooth} $$

    - **Parameter:** `RISE_THRESHOLD` (default: `1 / DIP_THRESHOLD`, e.g., `1.11`)
    - Users can adjust this to detect upward surges in volume.

    **Missing Data**: Flags when 2 or more of the past 3 months have missing (`NA`) or zero service volume.

    - **Fixed rule**.

    **Recent Tail Override**: Automatically flags all months in the last 6 months of data to ensure recent trends are reviewed, even if model-based tagging is not conclusive.

    - **Fixed rule**.

    **Final Flag**: A month is assigned `tagged = 1` if **any** of the following conditions are met:

    - `tag_sharp == 1`
    - `tag_sustained == 1`
    - `tag_sustained_dip == 1`
    - `tag_sustained_rise == 1`
    - `tag_missing == 1`
    - It falls within the most recent 6 months (`last_6_months == 1`)

    ### Robust Regression Model

    **Model fitting**:

    If ≥12 observations and >12 unique dates:

    $$Y_{it} = \beta_0 + \sum \gamma_m \cdot \text{month}_m + \beta_1 \cdot \text{date} + \epsilon_{it}$$

    If only ≥12 observations:

    $$Y_{it} = \beta_0 + \beta_1 \cdot \text{date} + \epsilon_{it}$$

    If insufficient data: use the median of observed values.

    **Apply rolling median smoothing to predictions**:

    $$ \text{count_smooth}_{it} = \text{Median}(\text{count_predict}_{t-k}, \dots, \text{count_predict}_t, \dots, \text{count\_predict}_{t+k}) $$

    - **Parameter:** `SMOOTH_K` (default: 7, must be odd)
    - Larger `SMOOTH_K` smooths more; smaller retains more variation.

    **Calculate residuals**:

    $$ \text{residual}_{it} = \text{count_original}_{it} - \text{count_smooth}_{it} $$

    **Standardize residuals using MAD**:

    $$ \text{robust_control}_{it} = \text{residual}_{it} / \text{MAD}_i $$

    ### Disruption Analysis Regression Models

    Once anomalies are identified and saved in `M3_chartout.csv`, the disruption analysis quantifies their impact using regression models. These models estimate how much service utilization changed during the flagged disruption periods by adjusting for long-term trends and seasonal variations.

    For each indicator, we estimate:

    $$ Y_{it} = \beta_0 + \beta_1 \cdot \text{date} + \sum_{m=1}^{12} \gamma_m \cdot \text{month}_m + \beta_2 \cdot \text{tagged} + \epsilon_{it} $$

    where:
    - $Y_{it}$ is the observed service volume,
    - $\text{date}$ captures time trends,
    - $\text{month}_m$ controls for seasonality,
    - $\text{tagged}$ is the disruption dummy (from the control chart analysis),
    - $\epsilon_{it}$ is the error term.

    The coefficient on `tagged` ($\beta_2$) measures the relative change in service utilization during flagged disruptions. Separate regressions are run at the national, province and district levels to assess the impact across different geographic scales.

    #### Country-wide Regression

    The country-wide regression estimates how service utilization changes at the national level when a disruption occurs. Instead of analyzing individual provinces or districts separately, this model considers the entire country's data in a single regression. Errors are clustered at the lowest available geographic level (`lowest_geo_level`), typically districts.

    **Model Specification:**

    $$Y_{it} = \beta_0 + \beta_1 \cdot \text{date} + \sum_{m=1}^{12} \gamma_m \cdot \text{month} + \beta_2 \cdot \text{tagged} + \epsilon_{it}$$

    Where:
    - $Y_{it}$ = volume (e.g., number of deliveries)
    - $\text{date}$ = time trend
    - $\text{month}_m$ = controls for seasonality (factor variable)
    - $\text{tagged}$ = dummy for disruption period
    - $\epsilon_{it}$ = error term, clustered at the district level (`admin_area_3`)

    #### Province-level Regression

    The province-level disruption regression estimates how service utilization changes at the province level when a disruption occurs. Unlike the country-wide model, this approach runs separate regressions for each province to capture regional variations.

    **Model specification:**

    $$Y_{it} = \beta_0 + \beta_1 \cdot \text{date} + \sum_{m=1}^{12} \gamma_m \cdot \text{month} + \beta_2 \cdot \text{tagged} + \alpha_{\text{province}} + \epsilon_{it}$$

    Where:
    - $Y_{it}$ = volume (e.g., number of deliveries)
    - $\text{date}$ = time trend
    - $\text{month}_m$ = controls for seasonality (factor variable)
    - $\text{tagged}$ = dummy for disruption period
    - $\alpha_{\text{province}}$ = province fixed effects
    - $\epsilon_{it}$ = error term, clustered at the district level

    #### District-level Regression

    The district-level disruption regression estimates how service utilization changes at the district level when a disruption occurs. This approach runs separate regressions for each district to capture localized variations.

    **Model specification:**

    $$Y_{it} = \beta_0 + \beta_1 \cdot \text{date} + \sum_{m=1}^{12} \gamma_m \cdot \text{month} + \beta_2 \cdot \text{tagged} + \alpha_{\text{district}} + \epsilon_{it}$$

    Where:
    - $Y_{it}$ = volume (e.g., number of deliveries)
    - $\text{date}$ = time trend
    - $\text{month}_m$ = controls for seasonality (factor variable)
    - $\text{tagged}$ = dummy for disruption period
    - $\alpha_{\text{district}}$ = district fixed effects
    - $\epsilon_{it}$ = error term

    #### Regression Outputs

    Each regression level produces the following outputs:

    **Expected values (`expect_admin_area_*`)**: Predicted service volume adjusted for seasonality and trends.

    **Disruption effect (`b_admin_area_*`)**: Estimated relative change during disruptions:

    $$ b_{\text{admin_area_*}} = -\frac{\text{diff mean}}{\text{predict mean}} $$

    **Trend coefficient (`b_trend_admin_area_*`)**: Reflects long-term trend.

    - Positive = increasing service use
    - Negative = declining service use
    - Near zero = stable trend

    **P-value (`p_admin_area_*`)**: Measures statistical significance of the disruption effect.

    - Lower values = stronger evidence of true disruption

    ### Statistical Methods Used

    **Robust Regression (`MASS::rlm`)**:

    - Uses iteratively reweighted least squares (IRLS)
    - Minimizes influence of outliers and extreme values
    - More resistant to model misspecification than ordinary least squares
    - Default: Huber weighting with maximum 100 iterations

    **MAD (Median Absolute Deviation)**:

    - Robust measure of scale/variability
    - Formula: `MAD = median(|x - median(x)|)`
    - More resistant to outliers than standard deviation
    - Used to standardize residuals for anomaly detection

    **Panel Regression (`fixest::feols`)**:

    - Fixed-effects estimation with clustered standard errors
    - Accounts for within-group correlation in errors
    - More efficient than traditional panel regression packages
    - Handles unbalanced panels gracefully

    **Geographic Clustering**:

    - Regressions use clustered standard errors at the lowest available geographic level
    - This accounts for within-area correlation in service delivery patterns
    - Example: Country-wide model clusters by district, province model clusters by district
    - Prevents underestimation of standard errors and false positives

### Detailed Analysis Steps

??? "Part 1: Control Chart Analysis"

    #### Step 1: Prepare the Data

    - Load raw HMIS service utilization data.
    - Merge in outlier flags (`outlier_flag`) by facility × indicator × month.
    - Remove rows flagged as outliers (`outlier_flag == 1`).
    - Create a `date` variable from `period_id` and extract `year` and `month`.
    - Create a unique `panelvar` for each geographic area-indicator combination.
    - Aggregate data to the specified geographic level by summing `count_model` (based on `SELECTEDCOUNT`) by date.
    - Fill in missing months within each panel to ensure continuity.
    - Fill missing metadata using forward and backward fill.

    #### Step 2: Filter Out Low-Volume Months

    - Compute the global mean service volume for each `panelvar`.
    - If `count_original` is <50% of the global mean, drop the value by setting it to `NA`.

    #### Step 3: Apply Regression and Smoothing

    Estimate expected service volume using robust regression, then smooth the predicted trend.

    - Fit robust regression (`rlm`) for each panel using one of three model specifications based on data availability.
    - Apply rolling median smoothing to predictions using window size `SMOOTH_K`.
    - If smoothing is not possible (e.g., at series edges), fallback to model predictions.
    - Calculate residuals: actual - smoothed
    - Standardize residuals using MAD

    This standardized control variable is used to detect anomalies in Step 4.

    #### Step 4: Tag Disruptions

    Apply rule-based tagging to identify potential disruptions. Each rule is governed by user-defined parameters that can be tuned for sensitivity:

    - **Sharp Disruptions**: Tag if `|robust_control| ≥ MADS_THRESHOLD`
    - **Sustained Drops**: Tag final month if 3 consecutive months have mild deviations and final month exceeds threshold
    - **Sustained Dips**: Tag entire sequence if `count_original < DIP_THRESHOLD × count_smooth` for 3+ months
    - **Sustained Rises**: Tag entire sequence if `count_original > RISE_THRESHOLD × count_smooth` for 3+ months
    - **Missing Data**: Tag if 2+ of past 3 months are missing or zero
    - **Recent Tail Override**: Automatically tag all months in last 6 months of data

    A month is assigned `tagged = 1` if any of the above conditions are met. Tagged records are saved in `M3_chartout.csv` and passed to the disruption analysis.

??? "Part 2: Disruption Analysis"

    #### Step 1: Data Preparation

    - The `M3_chartout` dataset is merged with the main dataset to integrate the `tagged` variable, which identifies flagged disruptions.
    - The lowest available geographic level (`lowest_geo_level`) is identified for clustering, based on the highest-resolution `admin_area_*` column available.

    #### Step 2: Country-Wide Regression

    For each `indicator_common_id`, estimate the national-level model with errors clustered at district level.

    - A panel regression model is applied at the country-wide level, estimating the expected service volume (`expect_admin_area_1`) for each indicator.
    - The model adjusts for historical trends and seasonal variations.
    - If a disruption (`tagged` = 1) is detected, the predicted service volume is adjusted by subtracting the estimated effect of the disruption to isolate its impact.

    #### Step 3: Province-Level Regression

    For each `indicator_common_id` × `admin_area_2` combination, estimate province-specific models with errors clustered at district level.

    - A fixed effects panel regression model is applied at the province level, estimating expected service volume (`expect_admin_area_2`) while controlling for province-specific factors.
    - The model adjusts for historical trends and seasonal variations.
    - If a disruption is detected, predicted volumes are adjusted to isolate the impact.

    #### Step 4: District-Level Regression (if enabled)

    For each `indicator_common_id` × `admin_area_3` combination, estimate district-specific models with errors clustered at ward level.

    - A fixed effects panel regression model is applied at the district level, estimating expected service volume (`expect_admin_area_3`).
    - The model adjusts for historical trends and seasonal variations.
    - If a disruption is detected, predicted volumes are adjusted to isolate the impact.

    #### Step 5: Prepare Outputs for Visualization

    Once expected values have been calculated for each level (country, province, district), the pipeline compares predicted and actual values to assess the magnitude of disruption.

    For each month and indicator, the pipeline calculates:

    - **Absolute and percentage difference** between predicted and actual values:

    $$ \text{diff_percent} = 100 \times \frac{\text{predicted} - \text{actual}}{\text{predicted}} $$

    - A configurable threshold parameter `DIFFPERCENT` (default: `10`) is used to determine when a disruption is significant.

        If the percentage difference exceeds ±10%, the expected (predicted) value is retained and used for plotting and summary statistics. Otherwise, the actual observed value is used.

        This ensures that minor fluctuations do not lead to artificial disruptions in the visualization, while meaningful deviations are preserved.

    - The final adjusted value for plotting is stored in a field such as `count_expected_if_above_diff_threshold`.

        This value reflects either:
        - The predicted count (if deviation > threshold), or
        - The actual count (if within acceptable range).

    This logic is applied consistently across all admin levels. These adjusted values are then exported as part of the final output files for each level.


### Troubleshooting

??? "Common Issues and Solutions"

    #### Issue: Script crashes with "out of memory" error

    **Solutions**:

    - Reduce batch sizes (e.g., `BATCH_SIZE_IND <- 3`)
    - Set `RUN_DISTRICT_MODEL <- FALSE`
    - Set `RUN_ADMIN_AREA_4_ANALYSIS <- FALSE`
    - Close other applications
    - Run on machine with more RAM

    ---

    #### Issue: Warning "model failed to converge"

    **Explanation**: Robust regression didn't fully converge within 100 iterations

    **Impact**: Usually minimal - partial convergence often sufficient

    **Solutions**:

    - Check data quality for that panel
    - Increase `maxit` parameter in `rlm()` call (line 229, 247)
    - Generally safe to ignore if only a few panels affected

    ---

    #### Issue: Many empty rows in output files

    **Explanation**: Insufficient data for certain indicator-geography combinations

    **Solutions**:

    - Expected behavior for sparse indicators
    - Filter outputs to non-missing values
    - Consider aggregating to higher geographic level

    ---

    #### Issue: All recent months flagged as disruptions

    **Explanation**: Automatic flagging of last 6 months

    **Purpose**: Ensures recent trends reviewed even without strong statistical evidence

    **Solutions**:

    - Expected behavior, not a bug
    - Review recent months manually
    - Adjust `last_6_months` logic if needed (line 333)

    ---

    #### Issue: `tagged` variable dropped from regression

    **Message**: Variable automatically set to 0

    **Explanation**: No variation in `tagged` within that panel (all 0 or all 1)

    **Solutions**:

    - Expected in panels with no disruptions or constant disruption
    - Not an error - disruption effect correctly set to 0

    ---

    #### Issue: Temporary files remain after run

    **Cause**: Script crashed before cleanup

    **Solutions**:

    - Delete manually: `M3_temp_*.csv`
    - Or re-run script (automatic cleanup at start)

    ---

    #### Issue: Very different results at different geographic levels

    **Explanation**: Different geographic aggregation captures different patterns

    **Example**: National trend may be stable while some districts have large disruptions

    **Solutions**:

    - Expected behavior - not a bug
    - Use appropriate level for your research question
    - Cross-check patterns across levels for robustness

### Usage Notes

??? "Interpretation Guidelines"

    **Disruption Effects (b_admin_area_*)**:

    - Negative values indicate service volume shortfalls during disrupted periods
    - Positive values indicate service volume surpluses during disrupted periods
    - Values closer to zero indicate smaller disruption impacts

    **P-values (p_admin_area_*)**:

    - Values < 0.05 suggest statistically significant disruptions
    - Values > 0.05 may indicate normal variation rather than true disruptions

    **Trend Coefficients (b_trend_admin_area_*)**:

    - Positive values indicate increasing service utilization over time
    - Negative values indicate declining service utilization over time
    - Values near zero indicate stable utilization patterns

    ### Performance Considerations

    **Runtime Factors**:

    - **Number of indicators**: Linear scaling
    - **Number of geographic units**: Linear scaling within each level
    - **Time series length**: Minimal impact (efficient regression)
    - **Geographic detail**: Exponential scaling (many more units at finer levels)

    **Estimated Runtimes** (example dataset: 50 indicators, 100 districts):

    - Country-wide + Province models: ~5-10 minutes
    - Add District models: ~30-60 minutes
    - Add Ward models: Several hours (depends on number of wards)

    **Optimization Strategies**:

    - Set `RUN_DISTRICT_MODEL = FALSE` for faster execution (skips district level)
    - Set `RUN_ADMIN_AREA_4_ANALYSIS = FALSE` (default) to avoid ward-level analysis
    - Reduce `SMOOTH_K` for faster rolling median calculation
    - Use `SELECTEDCOUNT = "count_final_none"` to avoid completeness adjustments

    ### Data Processing Details

    **Memory Management**:

    - Uses `data.table` for efficient operations on large datasets
    - Batch processing: Results saved to disk periodically
    - Progressive cleanup: Objects deleted when no longer needed
    - Temporary files enable processing datasets larger than RAM

    **Batch Sizes** (tunable for memory constraints):

    - Control chart: 100 panels per batch
    - Indicators: 5 indicators per batch
    - Provinces: 20 results per batch
    - Districts: 15 results per batch
    - Admin area 4: 10 results per batch

    **Missing Data Handling**:

    1. Missing months filled via `tidyr::complete()`
    2. Forward/backward fill for metadata
    3. Linear interpolation (`zoo::na.approx`) for count values
    4. Maximum gap: Unlimited (rule = 2 extends endpoints)

    ### Model Fallback Logic

    The control chart analysis uses adaptive model selection based on data availability:

    **Full Model** (requires ≥12 obs AND >12 unique dates):

    ```r
    count ~ month_factor + as.numeric(date)
    ```

    Accounts for both seasonality and linear trend

    **Trend-Only Model** (requires ≥12 obs):

    ```r
    count ~ as.numeric(date)
    ```

    Accounts for linear trend only (insufficient data for seasonality)

    **Median Fallback** (<12 observations):

    ```r
    count_predict = median(count)
    ```

    Uses global median when insufficient data for regression

    **Convergence Checks**:

    - Models checked for convergence status
    - Warnings issued for non-convergent models
    - Non-convergent models still used (partial convergence often sufficient)

    ### Quality Assurance

    **Data Cleaning**:

    - Outliers removed prior to control chart analysis (based on Module 1 flags)
    - Low-volume months (<50% of mean) excluded to improve model stability
    - Predictions bounded at zero (counts cannot be negative)

    **Automatic Flagging**:

    - Recent months (last 6 months) automatically flagged to ensure current disruptions captured
    - Prevents missing ongoing disruptions due to insufficient deviation from trend

    **Robustness Checks**:

    - Model coefficients checked for `NA` values before use
    - If `tagged` variable dropped from model (no variation), disruption effect set to 0
    - P-values calculated only when valid standard errors available

    **Edge Case Handling**:

    - Single-cluster panels: No clustering applied (would fail)
    - Insufficient data: Skip analysis for that panel/level
    - Missing predictions: Filled with original values where possible

    ### Workflow Integration

    This module is **Module 3** in the FASTR analytical pipeline:

    **Prerequisites**:

    1. **Module 1**: Data Quality Assessment (generates `M1_output_outliers.csv`)
    2. **Module 2**: Data Quality Adjustments (generates `M2_adjusted_data.csv`)

    ### Dependencies

    **R Packages Required**:

    - `data.table`: Efficient data manipulation
    - `lubridate`: Date handling
    - `zoo`: Rolling statistics and interpolation
    - `MASS`: Robust regression (rlm)
    - `fixest`: Fixed-effects panel regression
    - `dplyr`: Data manipulation
    - `tidyr`: Data tidying


---

**Last updated**: 10-11-2025
**Contact**: FASTR Project Team
