# Executive Summary

## FASTR RMNCAH-N Service Use Monitoring

The FASTR Analytics Platform enables systematic monitoring of reproductive, maternal, newborn, child, and adolescent health and nutrition (RMNCAH-N) service delivery using routine health management information system (HMIS) data. By connecting directly to DHIS2 systems, the platform retrieves facility-level data, processes it through four analytical modules, and produces actionable insights on data quality, service utilization patterns, disruption impacts, and population coverage estimates.

## The Challenge

Health systems in low- and middle-income countries generate substantial routine data through HMIS, yet this data often goes underutilized due to quality concerns and analytical capacity constraints. Traditional household surveys provide validated coverage estimates but occur infrequently (every 3-5 years) and cannot support timely decision-making. Decision-makers need reliable, continuous monitoring of health service delivery to:

- Identify and respond to service disruptions rapidly
- Allocate resources based on current service delivery patterns
- Track progress toward health targets between surveys
- Distinguish genuine service changes from data quality artifacts

## The Solution: Four-Module Analytical Pipeline

### Module 1: Data Quality Assessment

Evaluates the reliability of facility reporting by identifying statistical outliers, tracking reporting completeness, and validating logical consistency between related indicators. Each facility receives quality scores highlighting outliers, reporting gaps, and inconsistencies, enabling targeted data quality improvements.

### Module 2: Data Quality Adjustments

Creates four parallel data scenarios to accommodate different analytical needs: (1) original unadjusted data, (2) outlier-adjusted data, (3) missing data filled, and (4) both adjustments applied. For outliers, abnormal values are replaced with 6-month rolling medians. For missing months, gaps are filled using hierarchical imputation methods. This multi-scenario approach allows analysts to assess result sensitivity to data quality assumptions.

### Module 3: Service Utilization & Disruption Analysis

Identifies disrupted service delivery periods using statistical control charts, then quantifies the magnitude of service shortfalls or surpluses. The module employs robust regression models accounting for seasonality and trends to establish normal service patterns, flags months with significant deviations, and calculates the precise number of missed (or excess) services during disruption periods. Analysis runs at national, regional, and district levels.

### Module 4: Coverage Estimation & Projection

**Part 1 - Denominators**: Estimates target populations by working backward from HMIS service counts using survey-reported coverage rates. Multiple denominator options are calculated from different HMIS indicators (ANC1-derived, delivery-derived, BCG-derived, Penta1-derived) plus UN population estimates. Each denominator is adjusted for biological factors including pregnancy loss, stillbirths, and mortality. The module identifies the optimal denominator per indicator by comparing which produces coverage closest to survey benchmarks.

**Part 2 - Projections**: Projects future survey estimates by anchoring to the most recent survey value and applying year-specific changes observed in HMIS trends. This enables annual monitoring between infrequent surveys while maintaining survey validity as the baseline. Outputs include actual survey values when available, projected survey estimates, and direct HMIS-based coverage.

## How Modules Connect

The four modules form an integrated pipeline where outputs from earlier modules inform downstream analysis:

- Module 2 uses quality flags from Module 1 to determine which values require adjustment
- Module 3 loads all four adjustment scenarios from Module 2; users select which scenario to use for disruption modeling
- Module 4 Part 1 loads all four scenarios from Module 2; users select which scenario serves as the numerator for coverage calculations
- Module 4 Part 2 loads all coverage estimates from Part 1; users select the preferred denominator per indicator for projections

## Key Capabilities

**Flexible Analysis**: Multiple data quality scenarios and denominator options allow analysts to understand how methodological choices affect results, increasing confidence in findings.

**Geographic Granularity**: Analysis operates at national, regional (admin area 2), and district (admin area 3) levels where data permits, enabling both high-level monitoring and local action.

**Continuous Monitoring**: By leveraging timely HMIS data calibrated against periodic survey benchmarks, the platform enables annual or more frequent monitoring without waiting years between surveys.

**Transparent Methodology**: All calculations are fully documented with clear parameter configurations, allowing replication, customization to country contexts, and integration with existing monitoring systems.

## Value Proposition

The FASTR platform transforms routine HMIS data from an underutilized resource into a cornerstone of evidence-based health system management. By systematically addressing data quality issues, detecting service disruptions early, and producing reliable coverage estimates between surveys, the platform empowers health system managers and policymakers to make informed decisions based on current, validated data rather than relying solely on infrequent surveys or accepting questionable routine data at face value.
