-- ============================================================
-- HR Workforce, Attrition & Employee Performance Analytics
-- 05 - Analysis & Validation Queries
-- PostgreSQL
-- ============================================================


-- ============================================================
-- 1. Employee Key Validation
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT emp_id) AS unique_emp_ids,
    COUNT(*) - COUNT(DISTINCT emp_id) AS duplicate_emp_ids,
    COUNT(emp_id) AS non_null_emp_ids
FROM staging.employee_data;


-- ============================================================
-- 2. Engagement Key Validation
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT employee_id) AS unique_employee_ids,
    COUNT(*) - COUNT(DISTINCT employee_id) AS duplicate_employee_ids,
    COUNT(employee_id) AS non_null_employee_ids
FROM staging.employee_engagement_survey_data;


-- ============================================================
-- 3. Engagement -> Employee Relationship Validation
-- ============================================================

SELECT
    COUNT(*) AS engagement_records,
    COUNT(e.emp_id) AS matched_employee_ids,
    COUNT(*) - COUNT(e.emp_id) AS orphan_employee_ids
FROM staging.employee_engagement_survey_data s
LEFT JOIN staging.employee_data e
    ON s.employee_id = e.emp_id;


-- ============================================================
-- 4. Training -> Employee Relationship Validation
-- ============================================================

SELECT
    COUNT(*) AS training_records,
    COUNT(e.emp_id) AS matched_employee_ids,
    COUNT(*) - COUNT(e.emp_id) AS orphan_employee_ids
FROM staging.training_and_development_data t
LEFT JOIN staging.employee_data e
    ON t.employee_id = e.emp_id;


-- ============================================================
-- 5. Recruitment Key Validation
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT applicant_id) AS unique_applicant_ids,
    COUNT(*) - COUNT(DISTINCT applicant_id) AS duplicate_applicant_ids,
    COUNT(applicant_id) AS non_null_applicant_ids
FROM staging.recruitment_data;


-- ============================================================
-- 6. Recruitment ID Investigation
-- ============================================================
-- Applicant IDs numerically overlap with employee IDs in the
-- dataset, but the names do not represent the same people.
-- Therefore recruitment is kept as a separate business process
-- and is NOT related to dim_employee using applicant_id = employee_id.
-- ============================================================

SELECT
    r.applicant_id,
    r.first_name AS applicant_first_name,
    r.last_name AS applicant_last_name,
    e.first_name AS employee_first_name,
    e.last_name AS employee_last_name
FROM staging.recruitment_data r
JOIN staging.employee_data e
    ON r.applicant_id = e.emp_id
WHERE r.first_name <> e.first_name
   OR r.last_name <> e.last_name
LIMIT 20;


-- ============================================================
-- 7. Employee Status Distribution
-- ============================================================

SELECT
    employee_status,
    COUNT(*) AS employee_count
FROM staging.employee_data
GROUP BY employee_status
ORDER BY employee_count DESC;


-- ============================================================
-- 8. Department Distribution
-- ============================================================

SELECT
    department,
    COUNT(*) AS employee_count
FROM staging.employee_data
GROUP BY department
ORDER BY employee_count DESC;


-- ============================================================
-- 9. Recruitment Status Distribution
-- ============================================================

SELECT
    status,
    COUNT(*) AS applicant_count
FROM staging.recruitment_data
GROUP BY status
ORDER BY applicant_count DESC;


-- ============================================================
-- 10. Workforce Movement Summary
-- ============================================================

SELECT
    event_type,
    COUNT(DISTINCT employee_id) AS employee_count
FROM analytics.fact_workforce
GROUP BY event_type
ORDER BY event_type;


-- ============================================================
-- 11. Monthly Workforce Movement
-- ============================================================

SELECT
    *
FROM analytics.vw_attrition_monthly
ORDER BY month;


-- ============================================================
-- 12. Employee Date Range
-- ============================================================

SELECT
    MIN(start_date) AS earliest_start_date,
    MAX(start_date) AS latest_start_date,
    MIN(exit_date) AS earliest_exit_date,
    MAX(exit_date) AS latest_exit_date
FROM staging.employee_data;


-- ============================================================
-- 13. Training Outcome Distribution
-- ============================================================

SELECT
    training_outcome,
    COUNT(*) AS training_records
FROM staging.training_and_development_data
GROUP BY training_outcome
ORDER BY training_records DESC;


-- ============================================================
-- 14. Training Programs by Employees Trained
-- ============================================================

SELECT
    training_program_name,
    COUNT(DISTINCT employee_id) AS employees_trained
FROM analytics.fact_training
GROUP BY training_program_name
ORDER BY employees_trained DESC;


-- ============================================================
-- 15. Employee Exits by Department
-- ============================================================

SELECT
    e.department,
    COUNT(DISTINCT w.employee_id) AS exited_employees
FROM analytics.fact_workforce w
JOIN analytics.dim_employee e
    ON w.employee_id = e.employee_id
WHERE w.event_type = 'Exited'
GROUP BY e.department
ORDER BY exited_employees DESC;


-- ============================================================
-- 16. Employee Exits by Termination Type
-- ============================================================

SELECT
    e.termination_type,
    COUNT(DISTINCT w.employee_id) AS exited_employees
FROM analytics.fact_workforce w
JOIN analytics.dim_employee e
    ON w.employee_id = e.employee_id
WHERE w.event_type = 'Exited'
GROUP BY e.termination_type
ORDER BY exited_employees DESC;


-- ============================================================
-- 17. Employee Exits by Employee Type
-- ============================================================

SELECT
    e.employee_type,
    COUNT(DISTINCT w.employee_id) AS exited_employees
FROM analytics.fact_workforce w
JOIN analytics.dim_employee e
    ON w.employee_id = e.employee_id
WHERE w.event_type = 'Exited'
GROUP BY e.employee_type
ORDER BY exited_employees DESC;


-- ============================================================
-- 18. Employee Exits by Pay Zone
-- ============================================================

SELECT
    e.pay_zone,
    COUNT(DISTINCT w.employee_id) AS exited_employees
FROM analytics.fact_workforce w
JOIN analytics.dim_employee e
    ON w.employee_id = e.employee_id
WHERE w.event_type = 'Exited'
GROUP BY e.pay_zone
ORDER BY
    CASE e.pay_zone
        WHEN 'Zone A' THEN 1
        WHEN 'Zone B' THEN 2
        WHEN 'Zone C' THEN 3
        ELSE 4
    END;


-- ============================================================
-- 19. Employee Exits by Tenure Band
-- ============================================================
-- Tenure is calculated using completed calendar months between
-- employee start date and exit date.
-- ============================================================

SELECT
    CASE
        WHEN tenure_months < 12 THEN '< 1 year'
        WHEN tenure_months < 36 THEN '1–3 years'
        WHEN tenure_months < 60 THEN '3–5 years'
        WHEN tenure_months < 120 THEN '5–10 years'
        ELSE '> 10 years'
    END AS exit_tenure_band,

    COUNT(*) AS exited_employees

FROM
(
    SELECT
        employee_id,

        (
            EXTRACT(
                YEAR FROM age(exit_date, start_date)
            ) * 12

            +

            EXTRACT(
                MONTH FROM age(exit_date, start_date)
            )
        )::INTEGER AS tenure_months

    FROM analytics.dim_employee

    WHERE exit_date IS NOT NULL
) AS tenure_data

GROUP BY 1

ORDER BY
    MIN(
        CASE
            WHEN tenure_months < 12 THEN 1
            WHEN tenure_months < 36 THEN 2
            WHEN tenure_months < 60 THEN 3
            WHEN tenure_months < 120 THEN 4
            ELSE 5
        END
    );


-- ============================================================
-- END OF ANALYSIS QUERIES
-- ============================================================