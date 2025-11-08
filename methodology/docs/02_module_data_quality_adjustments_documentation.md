# Module 2: Data Quality Adjustment

## 1. Overview (What & Why)

### What does this module do?

The Data Quality Adjustment module systematically corrects two common problems in routine health facility data: **outliers** (extreme values caused by reporting errors or data entry mistakes) and **missing data** (from incomplete reporting). Rather than simply deleting problematic data, this module replaces questionable values with statistically sound estimates based on each facility's own historical patterns.

The module uses sophisticated temporal smoothing techniques that analyze trends over time. By calculating rolling averages and examining facility-specific historical patterns, it preserves the underlying trends in the data while correcting anomalous values. This approach ensures that adjusted data remains grounded in real service delivery patterns rather than arbitrary replacements.

To accommodate different analytical needs, the module produces four parallel versions of the data: one with no adjustments (the original data), one with only outlier corrections, one with only missing data filled in, and one with both types of corrections applied. This multi-scenario approach allows analysts to understand how sensitive their results are to different data quality assumptions and choose the most appropriate version for their analysis.

### Why is it needed in the FASTR pipeline?

Routine health management information system (HMIS) data often contains errors and gaps that can seriously distort trends, mask true patterns, and lead to incorrect conclusions. A single extreme outlier can make service volumes appear to spike dramatically, while missing data can make it seem like services stopped entirely. These issues are particularly problematic when:

- Tracking progress toward health goals and targets
- Comparing facilities or regions to identify high and low performers
- Allocating resources based on service delivery patterns
- Detecting genuine changes in health service utilization versus data quality issues

By systematically addressing these data quality issues before analysis, this module ensures that downstream calculations and decisions are based on reliable, consistent data rather than artifacts of poor data quality.

### Quick Summary

| Component | Details |
|-----------|---------|
| **Inputs** | Raw HMIS data (`hmis_ISO3.csv`)<br>Outlier flags from Module 1 (`M1_output_outliers.csv`)<br>Completeness flags from Module 1 (`M1_output_completeness.csv`) |
| **Outputs** | Facility-level adjusted data (`M2_adjusted_data.csv`)<br>Subnational aggregated data (`M2_adjusted_data_admin_area.csv`)<br>National aggregated data (`M2_adjusted_data_national.csv`)<br>Exclusion metadata (`M2_low_volume_exclusions.csv`) |
| **Purpose** | Replace outlier values and fill missing data using facility-specific historical patterns; produces four adjustment scenarios (none, outliers only, completeness only, both) |

---

## 2. How It Works

### High-Level Workflow

The module follows a systematic seven-step process to clean and adjust health facility data:

**Step 1: Load and Prepare Data**
The module brings together three datasets: the raw facility service volumes, the outlier flags identifying suspicious values (from Module 1), and the completeness flags showing which months had incomplete reporting (from Module 1). It also identifies certain sensitive indicators like deaths that should never be adjusted.

**Step 2: Identify Low-Volume Indicators**
Before making any adjustments, the module checks each indicator to see if it has meaningful variation. Indicators that never have values above 100 across the entire dataset are flagged and excluded from outlier adjustment, since outlier detection isn't meaningful for consistently low-count indicators.

**Step 3: Adjust Outlier Values**
For each value flagged as an outlier, the module calculates what the value "should have been" based on that facility's historical pattern. It uses a hierarchy of methods, preferring to use surrounding months when possible (like averaging the 3 months before and 3 months after), but falling back to other approaches if needed (like using the same month from the previous year for seasonal indicators).

**Step 4: Fill Missing and Incomplete Data**
For months where data is missing or marked as incomplete, the module imputes (fills in) values using the same rolling average approach. This ensures that temporary reporting gaps don't create artificial drops to zero in the data.

**Step 5: Create Multiple Scenarios**
The module runs the adjustment logic four different ways: with no adjustments (baseline), only outlier corrections, only completeness corrections, and both types of corrections together. This allows analysts to see how different choices affect their results.

**Step 6: Aggregate to Geographic Levels**
After adjustments are complete, the facility-level data is aggregated (summed up) to create subnational and national-level datasets. Each geographic level maintains all four scenarios, so analysts can work at whichever level they need.

**Step 7: Export Results**
The module saves four CSV files: one for facility-level data, one for subnational areas, one for national totals, and one documenting which indicators were excluded from adjustment and why.

### Visual Workflow

```
┌─────────────────────────────────────────────────────────────┐
│ INPUTS                                                      │
│                                                             │
│  Raw HMIS Data          Outlier Flags      Completeness    │
│  (service volumes)      (from Module 1)    Flags           │
│                                            (from Module 1)  │
└──────────────┬──────────────────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────────────────┐
│ STEP 1: Data Preparation                                    │
│  • Merge datasets by facility, indicator, and month         │
│  • Identify excluded indicators (deaths)                    │
│  • Check for low-volume indicators                          │
└──────────────┬──────────────────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────────────────┐
│ STEP 2: Calculate Rolling Averages                          │
│  • Centered 6-month average (3 before + 3 after)            │
│  • Forward 6-month average (next 6 months)                  │
│  • Backward 6-month average (previous 6 months)             │
│  • Facility-specific historical mean                        │
└──────────────┬──────────────────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────────────────┐
│ STEP 3: Apply Adjustment Hierarchy                          │
│                                                             │
│  For Outliers:                 For Missing/Incomplete:      │
│  1. Use centered average       1. Use centered average      │
│  2. Use forward average        2. Use forward average       │
│  3. Use backward average       3. Use backward average      │
│  4. Use same month last year   4. Use historical mean       │
│  5. Use historical mean                                     │
└──────────────┬──────────────────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────────────────┐
│ STEP 4: Create Four Scenarios                               │
│                                                             │
│  ┌─────────────┐  ┌──────────────┐  ┌─────────────────┐   │
│  │   None      │  │   Outliers   │  │  Completeness   │   │
│  │ (original)  │  │   Only       │  │     Only        │   │
│  └─────────────┘  └──────────────┘  └─────────────────┘   │
│                                                             │
│                   ┌──────────────┐                          │
│                   │     Both     │                          │
│                   │  Adjustments │                          │
│                   └──────────────┘                          │
└──────────────┬──────────────────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────────────────┐
│ STEP 5: Geographic Aggregation                              │
│                                                             │
│  Facility Level → Subnational Level → National Level        │
│  (individual)     (provinces/         (country total)       │
│                    districts)                               │
│                                                             │
│  Each level maintains all 4 scenarios                       │
└──────────────┬──────────────────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────────────────┐
│ OUTPUTS                                                     │
│                                                             │
│  M2_adjusted_data.csv           (facility level)            │
│  M2_adjusted_data_admin_area.csv (subnational)             │
│  M2_adjusted_data_national.csv  (national)                 │
│  M2_low_volume_exclusions.csv   (metadata)                 │
└─────────────────────────────────────────────────────────────┘
```

### Key Decision Points

**Which values should be adjusted?**
The module adjusts two types of problematic values:
- Values flagged as outliers by Module 1's statistical detection algorithms
- Values from months marked as incomplete or entirely missing

However, certain indicators are NEVER adjusted:
- Death counts (under-5 deaths, maternal deaths, neonatal deaths) because these represent discrete events that should not be smoothed
- Low-volume indicators (those that never exceed 100) where outlier detection isn't meaningful

**How are replacement values calculated?**
The module follows a hierarchy from most to least reliable:

1. **Best option**: Use the average of surrounding months (3 before and 3 after) if available
2. **Good option**: If surrounding months aren't available, use either future months or past months
3. **Acceptable option**: For seasonal indicators, use the same month from last year (e.g., June 2022 to replace June 2023)
4. **Fallback option**: Use the facility's overall average for that indicator if nothing else works

This hierarchy ensures that replacements are as contextually relevant as possible, using the most recent and similar data available.

**Which scenario should analysts use?**
By producing four scenarios, the module allows different use cases:

- **None**: Use for validation or when data quality is already excellent
- **Outliers only**: Use when completeness is good but occasional extreme values are problematic
- **Completeness only**: Use when you trust the reported values but reporting is sporadic
- **Both**: Use when both data quality issues are prevalent (most common choice)

### What Happens to the Data

**Before adjustment**, a facility's monthly service volume data might look like this:

```
Month      Deliveries   Issue
Jan 2023   78           OK
Feb 2023   450          OUTLIER (data entry error)
Mar 2023   [missing]    INCOMPLETE REPORTING
Apr 2023   82           OK
May 2023   85           OK
```

**After adjustment** (using the "both" scenario), the same data becomes:

```
Month      Original   Adjusted   Method Used
Jan 2023   78         78         No adjustment needed
Feb 2023   450        82         Replaced using 6-month average
Mar 2023   [missing]  80         Filled using 6-month average
Apr 2023   82         82         No adjustment needed
May 2023   85         85         No adjustment needed
```

The adjusted data maintains realistic values that fit the facility's typical pattern, making it suitable for trend analysis, comparison with other facilities, and resource planning.

---

## 3. Detailed Reference

<details>
<summary><strong>Configuration Parameters</strong></summary>

### Excluded Indicators

Some indicators are excluded from all adjustments due to their sensitive nature:

```r
EXCLUDED_FROM_ADJUSTMENT <- c("u5_deaths", "maternal_deaths", "neonatal_deaths")
```

**Rationale**: Death counts should not be smoothed or imputed as they represent discrete events that may have genuine temporal variation. Adjusting these could mask important epidemiological patterns or outbreak signals.

### Low Volume Exclusions

Indicators are also automatically excluded from **outlier adjustment** if they have zero observations above 100 across the entire dataset. This prevents meaningless outlier detection on indicators with consistently low counts.

**Exclusion Logic**:
```r
volume_check <- raw_data[, .(
  above_100 = sum(count > 100, na.rm = TRUE),
  total = .N
), by = indicator_common_id]

no_outlier_adj <- volume_check[above_100 == 0, indicator_common_id]
```

This information is saved to `M2_low_volume_exclusions.csv` for transparency.

### Rolling Window Configuration

The module uses a **6-month window** for all rolling averages. This choice balances:

**Advantages**:
- Captures medium-term trends
- Reduces impact of short-term fluctuations
- Sufficient data points for stable averages
- Works well for both stable and seasonal indicators

**Trade-offs**:
- May not capture rapid changes in service delivery
- Could over-smooth in cases of genuine programmatic shifts
- Requires at least 6 valid observations for optimal centered average

</details>

<details>
<summary><strong>Input/Output Specifications</strong></summary>

### Input Files

The module requires three input files from previous processing steps:

| File | Source | Description | Key Variables |
|------|--------|-------------|---------------|
| `hmis_ISO3.csv` | Raw HMIS data | Facility-level service volumes | `facility_id`, `indicator_common_id`, `period_id`, `count`, admin area columns |
| `M1_output_outliers.csv` | Module 1 | Outlier flags for each facility-month-indicator | `facility_id`, `indicator_common_id`, `period_id`, `outlier_flag` |
| `M1_output_completeness.csv` | Module 1 | Completeness flags for each facility-month-indicator | `facility_id`, `indicator_common_id`, `period_id`, `completeness_flag` |

### Input Data Structure

**Raw HMIS Data (`hmis_ISO3.csv`)**:
```
facility_id | admin_area_1 | admin_area_2 | admin_area_3 | period_id | indicator_common_id | count
------------|--------------|--------------|--------------|-----------|---------------------|-------
FAC001      | ISO3         | Province_A   | District_A   | 202301    | anc1                | 145
FAC001      | ISO3         | Province_A   | District_A   | 202302    | anc1                | 152
FAC001      | ISO3         | Province_A   | District_A   | 202303    | anc1                | 890  # Outlier
```

**Outlier Flags (`M1_output_outliers.csv`)**:
```
facility_id | indicator_common_id | period_id | outlier_flag
------------|---------------------|-----------|-------------
FAC001      | anc1                | 202301    | 0
FAC001      | anc1                | 202302    | 0
FAC001      | anc1                | 202303    | 1           # Flagged as outlier
```

**Completeness Flags (`M1_output_completeness.csv`)**:
```
facility_id | indicator_common_id | period_id | completeness_flag
------------|---------------------|-----------|------------------
FAC001      | anc1                | 202301    | 1             # Complete
FAC001      | anc1                | 202302    | 0             # Incomplete
FAC001      | anc1                | 202303    | 1             # Complete
```

### Output Files

The module generates four output files:

| File | Level | Description | Key Columns |
|------|-------|-------------|-------------|
| `M2_adjusted_data.csv` | Facility | Adjusted volumes for all scenarios at facility level | `facility_id`, admin areas (excl. admin_area_1), `period_id`, `indicator_common_id`, `count_final_*` |
| `M2_adjusted_data_admin_area.csv` | Subnational | Aggregated adjusted volumes at subnational admin areas | Admin areas (excl. admin_area_1), `period_id`, `indicator_common_id`, `count_final_*` |
| `M2_adjusted_data_national.csv` | National | Aggregated adjusted volumes at national level | `admin_area_1`, `period_id`, `indicator_common_id`, `count_final_*` |
| `M2_low_volume_exclusions.csv` | Metadata | Indicators excluded from outlier adjustment due to low volumes | `indicator_common_id`, `low_volume_exclude` |

### Output Data Structure

**Facility-Level Output** (`M2_adjusted_data.csv`):
```
facility_id | admin_area_2 | admin_area_3 | period_id | indicator_common_id | count_final_none | count_final_outliers | count_final_completeness | count_final_both
------------|--------------|--------------|-----------|---------------------|------------------|----------------------|--------------------------|------------------
FAC001      | Province_A   | District_A   | 202301    | anc1                | 145              | 145                  | 145                      | 145
FAC001      | Province_A   | District_A   | 202302    | anc1                | 152              | 152                  | 148                      | 148
FAC001      | Province_A   | District_A   | 202303    | anc1                | 890              | 148                  | 890                      | 148
```

Each `count_final_*` column represents a different adjustment scenario:
- `count_final_none`: No adjustments applied (original values)
- `count_final_outliers`: Only outlier adjustment applied
- `count_final_completeness`: Only completeness adjustment applied
- `count_final_both`: Both outlier and completeness adjustments applied

</details>

<details>
<summary><strong>Key Functions Documentation</strong></summary>

### Required Libraries

The module depends on the following R packages:

-   `data.table` - High-performance data manipulation and aggregation
-   `zoo` - Rolling window calculations (`frollmean` for rolling averages)
-   `lubridate` - Date handling and manipulation

### 1. `apply_adjustments()`

Core function that implements the adjustment logic for a single scenario.

**Purpose**: Replaces outlier and/or incomplete values using rolling averages and historical patterns.

**Parameters**:
- `raw_data` (data.table): Original HMIS data with service counts
- `completeness_data` (data.table): Completeness flags from Module 1
- `outlier_data` (data.table): Outlier flags from Module 1
- `adjust_outliers` (logical): Whether to apply outlier adjustment
- `adjust_completeness` (logical): Whether to apply completeness adjustment

**Returns**: data.table with adjusted values in `count_working` column and adjustment metadata

**Key Operations**:
1. Merges input datasets by `facility_id`, `indicator_common_id`, and `period_id`
2. Converts `period_id` to dates for temporal ordering
3. Calculates rolling averages (centered, forward, backward) for valid values
4. Applies adjustment hierarchy based on data availability
5. Tracks adjustment method used for each replaced value

### 2. `apply_adjustments_scenarios()`

Wrapper function that runs adjustments across all four scenarios.

**Purpose**: Applies the adjustment logic under different combinations of outlier and completeness adjustments.

**Parameters**:
- `raw_data` (data.table): Original HMIS data
- `completeness_data` (data.table): Completeness flags
- `outlier_data` (data.table): Outlier flags

**Returns**: data.table with four `count_final_*` columns, one per scenario

**Scenarios Processed**:
1. `none`: No adjustments (baseline)
2. `outliers`: Outlier adjustment only
3. `completeness`: Completeness adjustment only
4. `both`: Sequential outlier then completeness adjustment

**Processing Logic**:
- Calls `apply_adjustments()` once per scenario
- Preserves original values for excluded indicators (deaths)
- Merges all scenario results into a single wide-format table

</details>

<details>
<summary><strong>Statistical Methods & Algorithms</strong></summary>

### Outlier Adjustment Methodology

Outlier adjustment is applied to any facility-month value flagged in Module 1 (`outlier_flag == 1`). The goal is to replace these outlier values using valid historical data from the same facility and indicator.

**Statistical Approach**: Rolling averages are used to estimate expected values. A rolling average (also called moving average) is the mean of a set of time periods surrounding the target period. This technique smooths short-term fluctuations and highlights longer-term trends.

**Valid Values Definition**: Only values meeting ALL of the following criteria are used in calculations:
- `count > 0` (positive non-zero values)
- `!is.na(count)` (non-missing)
- `outlier_flag == 0` (not flagged as outlier)

**Implementation**: The module uses `frollmean()` from the `zoo` package for efficient rolling calculations:
```r
data_adj[, valid_count := fifelse(outlier_flag == 0L & !is.na(count), count, NA_real_)]
data_adj[, `:=`(
  roll6   = frollmean(valid_count, 6, na.rm = TRUE, align = "center"),
  fwd6    = frollmean(valid_count, 6, na.rm = TRUE, align = "left"),
  bwd6    = frollmean(valid_count, 6, na.rm = TRUE, align = "right"),
  fallback= mean(valid_count, na.rm = TRUE)
), by = .(facility_id, indicator_common_id)]
```

### Adjustment Hierarchy for Outliers

The adjustment process follows this **hierarchical order** (stopping at the first available method):

1.  **Centered 6-Month Average (`roll6`)**
    -   Uses the three months before and three months after the outlier month
    -   Provides a balanced average based on nearby trends
    -   Applied when enough valid values exist on both sides of the month
    -   Method tag: `roll6`

2.  **Forward-Looking 6-Month Average (`fwd6`)**
    -   Used if the centered average can't be calculated (e.g. early in the time series)
    -   Takes the average of the next six valid months
    -   Method tag: `forward`

3.  **Backward-Looking 6-Month Average (`bwd6`)**
    -   Used if neither `roll6` nor `fwd6` are available
    -   Takes the average of the six most recent valid months before the outlier
    -   Method tag: `backward`

4.  **Same Month from Previous Year**
    -   If no valid 6-month average exists, the value from the **same calendar month in the previous year** is used (e.g., Jan 2023 for Jan 2024)
    -   Only applied if that previous value is valid (not an outlier, and > 0)
    -   Particularly useful for seasonal indicators (e.g., malaria, respiratory infections)
    -   Method tag: `same_month_last_year`
    -   **Implementation**:
    ```r
    data_adj[, `:=`(mm = month(date), yy = year(date))]
    data_adj <- data_adj[, {
      for (i in which(outlier_flag == 1L & is.na(adj_method))) {
        j <- which(mm == mm[i] & yy == yy[i] - 1 & outlier_flag == 0L & !is.na(count))
        if (length(j) == 1L) {
          count_working[i] <- count[j]
          adj_method[i]    <- "same_month_last_year"
          adjust_note[i]   <- format(date[j], "%b-%Y")
        }
      }
      .SD
    }, by = .(facility_id, indicator_common_id)]
    ```

5.  **Mean of All Historical Values (Fallback)**
    -   If all previous methods fail, the mean of all valid historical values for that facility-indicator is used
    -   Provides a facility-specific baseline when no temporal pattern is available
    -   Method tag: `fallback`

**Edge Case**: If no valid replacement can be found from any of these methods, the original outlier value is retained.

### Completeness Adjustment Methodology

Completeness adjustment is applied to any facility-month where:
- The month is flagged as incomplete (`completeness_flag != 1`) in Module 1, OR
- The value is missing (`is.na(count_working)`)

**Statistical Approach**: The same rolling average methodology is applied, but the definition of "valid values" differs slightly:

**Valid Values for Completeness Adjustment**:
- `!is.na(count_working)` (non-missing, possibly already adjusted for outliers)
- `outlier_flag == 0` (not flagged as outlier in original data)

**Key Difference from Outlier Adjustment**:
- Completeness adjustment can use values that were already adjusted for outliers (when scenarios include both adjustments)
- No same-month-last-year method is used (only rolling averages and fallback)

**Implementation**:
```r
data_adj[, valid_count := fifelse(!is.na(count_working) & outlier_flag == 0L, count_working, NA_real_)]
data_adj[, `:=`(
  roll6   = frollmean(valid_count, 6, na.rm = TRUE, align = "center"),
  fwd6    = frollmean(valid_count, 6, na.rm = TRUE, align = "left"),
  bwd6    = frollmean(valid_count, 6, na.rm = TRUE, align = "right"),
  fallback= mean(valid_count, na.rm = TRUE)
), by = .(facility_id, indicator_common_id)]
```

### Adjustment Hierarchy for Completeness

The replacement follows this **hierarchical order**:

1.  **Centered 6-Month Average (`roll6`)**
    -   Uses three valid months before and after the missing or incomplete month
    -   Preferred method when sufficient surrounding data exists
    -   Method tag: `roll6`

2.  **Forward-Looking 6-Month Average (`fwd6`)**
    -   Used if the centered average cannot be calculated (e.g., at start of time series)
    -   Method tag: `forward`

3.  **Backward-Looking 6-Month Average (`bwd6`)**
    -   Used if no centered or forward-looking values are available (e.g., at end of time series)
    -   Method tag: `backward`

4.  **Mean of All Historical Values (Fallback)**
    -   If no rolling averages can be calculated, uses the mean of all valid values for that facility-indicator
    -   Provides a facility-specific baseline
    -   Method tag: `fallback`

**Edge Case**: If no valid replacement is found, the value remains missing (`NA`).

### Scenario Processing Logic

The module processes all four adjustment scenarios simultaneously using the `apply_adjustments_scenarios()` function:

**Scenario 1: None** (`count_final_none`)
- `adjust_outliers = FALSE`, `adjust_completeness = FALSE`
- Original raw data with no modifications
- Serves as baseline for comparison

**Scenario 2: Outliers** (`count_final_outliers`)
- `adjust_outliers = TRUE`, `adjust_completeness = FALSE`
- Only outlier values are replaced
- Missing/incomplete values remain as-is
- Use case: When completeness is high but outliers are a concern

**Scenario 3: Completeness** (`count_final_completeness`)
- `adjust_outliers = FALSE`, `adjust_completeness = TRUE`
- Only missing/incomplete values are imputed
- Outliers are retained in the data
- Use case: When data quality is good but reporting is sporadic

**Scenario 4: Both** (`count_final_both`)
- `adjust_outliers = TRUE`, `adjust_completeness = TRUE`
- **Sequential processing**: Outliers adjusted first, then completeness
- Most comprehensive adjustment
- Use case: When both data quality issues are prevalent

**Processing Order for "Both" Scenario**:
1. Outlier adjustment creates `count_working` with outliers replaced
2. Completeness adjustment then operates on `count_working`, using the already-adjusted values
3. This ensures completeness imputation uses cleaned (non-outlier) values when available

**Important**: After scenario-specific adjustments, excluded indicators (deaths) are reset to their original values:
```r
dat[indicator_common_id %in% EXCLUDED_FROM_ADJUSTMENT, count_working := count]
```

### Aggregation Methods

All geographic aggregations use **simple sums**:

```r
sum(count_final_both, na.rm = TRUE)
```

**Rationale**:
- Service volumes are additive (e.g., total deliveries = sum of facility deliveries)
- Missing values (`NA`) are treated as zero in aggregation
- Consistent with standard HMIS reporting practices

**Caution**: If many facilities have `NA` values after adjustment, subnational/national totals may be underestimated. The `count_final_none` scenario provides a reference point for assessing impact.

### Handling Missing Data in Calculations

The module applies `na.rm = TRUE` in all rolling calculations:

```r
frollmean(valid_count, 6, na.rm = TRUE, align = "center")
```

**Implication**: Rolling averages are calculated from available valid values only. If fewer than 6 values exist, the average is computed from whatever is available. If no valid values exist, the result is `NA`.

</details>

<details>
<summary><strong>Code Examples</strong></summary>

### Example 1: Outlier Adjustment

**Scenario**: A facility reports an unusually high ANC1 visit count in March 2023.

**Data**:
```
period_id | count | outlier_flag | Surrounding valid values
----------|-------|--------------|-------------------------
202301    | 145   | 0            | valid
202302    | 152   | 0            | valid
202303    | 890   | 1            | OUTLIER
202304    | 148   | 0            | valid
202305    | 155   | 0            | valid
202306    | 147   | 0            | valid
```

**Adjustment Calculation** (centered 6-month average):
- Valid values: [145, 152, 148, 155, 147] (excludes outlier 890)
- Average: (145 + 152 + 148 + 155 + 147) / 5 = 149.4
- **Adjusted value**: 149.4

**Method used**: `roll6`

### Example 2: Completeness Adjustment

**Scenario**: A facility fails to report malaria tests in February 2023.

**Data**:
```
period_id | count | completeness_flag | Surrounding valid values
----------|-------|-------------------|-------------------------
202301    | 45    | 1                 | valid
202302    | NA    | 0                 | INCOMPLETE
202303    | 48    | 1                 | valid
202304    | 52    | 1                 | valid
202305    | 50    | 1                 | valid
```

**Adjustment Calculation** (centered 6-month average):
- Valid values: [45, 48, 52, 50, ...]
- Average: 48.75 (using available surrounding months)
- **Imputed value**: 48.75

**Method used**: `roll6`

### Example 3: Seasonal Indicator with Same-Month-Last-Year

**Scenario**: Malaria cases show strong seasonality, and a June 2023 outlier needs adjustment.

**Data**:
```
period_id | count | outlier_flag | Notes
----------|-------|--------------|-------
202206    | 234   | 0            | June 2022 (valid)
202306    | 1850  | 1            | June 2023 (OUTLIER)
```

**Adjustment Logic**:
1. Centered, forward, and backward rolling averages unavailable (insufficient data)
2. Same-month-last-year method activated
3. June 2022 value = 234 (valid)
4. **Adjusted value**: 234

**Method used**: `same_month_last_year`

### Example 4: Scenario Comparison

**Facility**: FAC001
**Indicator**: Institutional deliveries
**Period**: Q1 2023

**Original Data**:
```
Month    | Count | Outlier? | Complete?
---------|-------|----------|----------
Jan 2023 | 78    | No       | Yes
Feb 2023 | 450   | Yes      | Yes       # Outlier
Mar 2023 | NA    | -        | No        # Incomplete
```

**Scenario Results**:

| Month    | None | Outliers | Completeness | Both |
|----------|------|----------|--------------|------|
| Jan 2023 | 78   | 78       | 78           | 78   |
| Feb 2023 | 450  | 82*      | 450          | 82*  |
| Mar 2023 | NA   | NA       | 80**         | 80** |

*Adjusted using rolling average
**Imputed using rolling average

**Interpretation**:
- **None**: Raw data with obvious issues
- **Outliers**: February corrected, but March remains missing
- **Completeness**: March filled in, but February outlier retained
- **Both**: Most complete and clean dataset

### Example 5: Geographic Aggregation

**Subnational Aggregation Code**:
```r
adjusted_data_admin_area_final <- adjusted_data_export[
  ,
  .(
    count_final_none         = sum(count_final_none,         na.rm = TRUE),
    count_final_outliers     = sum(count_final_outliers,     na.rm = TRUE),
    count_final_completeness = sum(count_final_completeness, na.rm = TRUE),
    count_final_both         = sum(count_final_both,         na.rm = TRUE)
  ),
  by = c(geo_admin_area_sub, "indicator_common_id", "period_id")
]
```

**National Aggregation Code**:
```r
adjusted_data_national_final <- adjusted_data_export[
  ,
  .(
    count_final_none         = sum(count_final_none,         na.rm = TRUE),
    count_final_outliers     = sum(count_final_outliers,     na.rm = TRUE),
    count_final_completeness = sum(count_final_completeness, na.rm = TRUE),
    count_final_both         = sum(count_final_both,         na.rm = TRUE)
  ),
  by = .(admin_area_1, indicator_common_id, period_id)
]
```

</details>

<details>
<summary><strong>Troubleshooting</strong></summary>

### Common Issues

**Issue 1: All values remain unadjusted**
- **Possible causes**:
  - Indicator is in the excluded list (deaths)
  - Indicator flagged as low-volume
  - No outlier or completeness flags in input data
- **Solution**: Check `M2_low_volume_exclusions.csv` and verify Module 1 outputs contain flags

**Issue 2: Adjusted values seem unreasonable**
- **Possible causes**:
  - Insufficient valid historical data for rolling averages
  - Genuine program changes being smoothed out
  - Seasonal patterns not captured by 6-month window
- **Solution**:
  - Review facility-specific time series plots
  - Consider using "outliers only" scenario if completeness is good
  - Validate against program implementation records

**Issue 3: Many NA values after adjustment**
- **Possible causes**:
  - Facility has very sparse data
  - No valid values available for any adjustment method
  - Early months in time series lack historical data
- **Solution**:
  - Expected for facilities with limited reporting history
  - Consider facility-level data quality filtering
  - National/subnational aggregates will sum available values

**Issue 4: Subnational/national totals don't match expectations**
- **Possible causes**:
  - NA values treated as zero in aggregation
  - Different scenarios produce different totals
  - Low reporting completeness overall
- **Solution**:
  - Compare `count_final_none` vs `count_final_both` to assess adjustment impact
  - Review Module 1 completeness statistics
  - Consider data quality threshold for inclusion

### Quality Assurance Checks

The module includes several quality checks:

1. **Low Volume Exclusions**: Automatically identifies and excludes indicators with zero high-value observations
2. **Adjustment Tracking**: Counts and reports number of values adjusted by each method
3. **Excluded Indicators**: Ensures deaths are never adjusted
4. **Console Logging**: Provides detailed progress and summary statistics

**Example Console Output**:
```
Running adjustments...
 -> Adjusting outliers...
     Roll6 adjusted: 1,245
     Forward-filled: 89
     Backward-filled: 67
     Same-month LY: 34
     Fallback mean: 12
 -> Adjusting for completeness...
     Roll6 filled: 2,103
     Forward-filled: 234
     Backward-filled: 178
     Fallback mean: 45
```

</details>

<details>
<summary><strong>Usage Notes & Recommendations</strong></summary>

### Choosing the Right Scenario

| Situation | Recommended Scenario | Rationale |
|-----------|---------------------|-----------|
| High data quality, minimal issues | `none` | No adjustment needed |
| Sporadic outliers, good completeness | `outliers` | Address quality without imputation |
| Good quality, poor reporting frequency | `completeness` | Fill gaps while preserving actual values |
| Poor quality and completeness | `both` | Comprehensive cleaning |
| Uncertainty about data quality | Compare all scenarios | Sensitivity analysis |

### Validation Steps

After running this module, consider:

1. **Compare scenarios**: Examine differences between `count_final_none` and `count_final_both`
2. **Review exclusions**: Check `M2_low_volume_exclusions.csv` for unexpected indicators
3. **Aggregate analysis**: Ensure subnational and national totals are reasonable
4. **Temporal plots**: Visualize trends before/after adjustment to identify over-smoothing
5. **Facility-level spot checks**: Review adjustments for a sample of facilities

### Limitations

1. **Rolling windows assume stability**: Adjustments work best when service delivery is relatively stable. Genuine program changes (e.g., new campaigns) may be incorrectly smoothed.

2. **No adjustment uncertainty**: The module provides point estimates without confidence intervals. Adjusted values should be treated as estimates.

3. **Facility-specific adjustments**: No cross-facility borrowing of information. Facilities with very sparse data may have unstable adjustments.

4. **Seasonal patterns**: While same-month-last-year helps, strong within-year seasonality may not be fully captured by 6-month windows.

5. **NA treatment in aggregation**: Missing values are treated as zero when summing to higher geographic levels, which may underestimate totals if missingness is high.

### Best Practices

1. **Always produce all four scenarios**: Even if you plan to use only one, having all scenarios allows for sensitivity analysis and validation

2. **Document your scenario choice**: When using adjusted data for analysis, clearly document which scenario was used and why

3. **Cross-validate with program data**: Compare adjusted trends with known programmatic events (campaigns, stockouts, facility closures)

4. **Consider data recency**: Be cautious with adjustments for the most recent months, which have less surrounding data for rolling averages

5. **Monitor excluded indicators**: Review the exclusion files to ensure appropriate indicators are being adjusted

</details>

---

Last edit 2025 November 8
