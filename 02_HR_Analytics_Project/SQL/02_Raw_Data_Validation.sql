-- ============================================================
-- HR Workforce, Attrition & Employee Performance Analytics
-- 02 - Raw Data Validation
-- PostgreSQL
-- ============================================================

-- ============================================================
-- 1. Raw table row counts
-- ============================================================

SELECT 'employee_data' AS table_name, COUNT(*) AS row_count
FROM raw.employee_data

UNION ALL

SELECT 'employee_engagement_survey_data', COUNT(*)
FROM raw.employee_engagement_survey_data

UNION ALL

SELECT 'recruitment_data', COUNT(*)
FROM raw.recruitment_data

UNION ALL

SELECT 'training_and_development_data', COUNT(*)
FROM raw.training_and_development_data;


-- ============================================================
-- 2. Check for accidentally loaded header rows
-- ============================================================

SELECT COUNT(*) AS header_rows
FROM raw.employee_data
WHERE emp_id LIKE '%EmpID%';

SELECT COUNT(*) AS header_rows
FROM raw.employee_engagement_survey_data
WHERE employee_id LIKE '%Employee ID%';

SELECT COUNT(*) AS header_rows
FROM raw.recruitment_data
WHERE applicant_id LIKE '%Applicant ID%';

SELECT COUNT(*) AS header_rows
FROM raw.training_and_development_data
WHERE employee_id LIKE '%Employee ID%';


-- ============================================================
-- 3. Remove accidental header rows
-- ============================================================

DELETE FROM raw.employee_data
WHERE emp_id LIKE '%EmpID%';

DELETE FROM raw.employee_engagement_survey_data
WHERE employee_id LIKE '%Employee ID%';