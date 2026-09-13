-- ============================================================
-- HR Workforce, Attrition & Employee Performance Analytics
-- 03 - Staging Layer Transformation
-- PostgreSQL
-- ============================================================


-- ============================================================
-- 1. Employee staging
-- ============================================================

DROP TABLE IF EXISTS staging.employee_data;

CREATE TABLE staging.employee_data AS
SELECT
    NULLIF(TRIM(emp_id), '')::INTEGER AS emp_id,
    TRIM(first_name) AS first_name,
    TRIM(last_name) AS last_name,

    CASE
        WHEN NULLIF(TRIM(start_date), '') IS NULL THEN NULL
        ELSE TO_DATE(TRIM(start_date), 'DD-Mon-YY')
    END AS start_date,

    CASE
        WHEN NULLIF(TRIM(exit_date), '') IS NULL THEN NULL
        ELSE TO_DATE(TRIM(exit_date), 'DD-Mon-YY')
    END AS exit_date,

    TRIM(title) AS title,
    TRIM(supervisor) AS supervisor,
    TRIM(email) AS email,
    TRIM(business_unit) AS business_unit,
    TRIM(employee_status) AS employee_status,
    TRIM(employee_type) AS employee_type,
    TRIM(pay_zone) AS pay_zone,
    TRIM(employee_classification_type) AS employee_classification_type,
    TRIM(termination_type) AS termination_type,
    TRIM(termination_description) AS termination_description,
    TRIM(department) AS department,
    TRIM(division) AS division,

    CASE
        WHEN NULLIF(TRIM(dob), '') IS NULL THEN NULL
        ELSE TO_DATE(TRIM(dob), 'DD-MM-YYYY')
    END AS dob,

    TRIM(state) AS state,
    TRIM(job_function) AS job_function,
    TRIM(gender_code) AS gender_code,
    TRIM(location_code) AS location_code,
    TRIM(race_desc) AS race_desc,
    TRIM(marital_desc) AS marital_desc,
    TRIM(performance_score) AS performance_score,

    NULLIF(TRIM(current_employee_rating), '')::INTEGER
        AS current_employee_rating

FROM raw.employee_data;


-- ============================================================
-- 2. Employee engagement survey staging
-- ============================================================

DROP TABLE IF EXISTS staging.employee_engagement_survey_data;

CREATE TABLE staging.employee_engagement_survey_data AS
SELECT
    NULLIF(TRIM(employee_id), '')::INTEGER AS employee_id,

    CASE
        WHEN NULLIF(TRIM(survey_date), '') IS NULL THEN NULL
        ELSE TO_DATE(TRIM(survey_date), 'DD-MM-YYYY')
    END AS survey_date,

    NULLIF(TRIM(engagement_score), '')::INTEGER
        AS engagement_score,

    NULLIF(TRIM(satisfaction_score), '')::INTEGER
        AS satisfaction_score,

    NULLIF(TRIM(work_life_balance_score), '')::INTEGER
        AS work_life_balance_score

FROM raw.employee_engagement_survey_data
WHERE TRIM(employee_id) <> 'Employee ID';


-- ============================================================
-- 3. Recruitment staging
-- ============================================================

DROP TABLE IF EXISTS staging.recruitment_data;

CREATE TABLE staging.recruitment_data AS
SELECT
    NULLIF(TRIM(applicant_id), '')::INTEGER AS applicant_id,

    CASE
        WHEN NULLIF(TRIM(application_date), '') IS NULL THEN NULL
        ELSE TO_DATE(TRIM(application_date), 'DD-Mon-YY')
    END AS application_date,

    TRIM(first_name) AS first_name,
    TRIM(last_name) AS last_name,
    TRIM(gender) AS gender,

    CASE
        WHEN NULLIF(TRIM(date_of_birth), '') IS NULL THEN NULL

        WHEN TRIM(date_of_birth) LIKE '%/%'
            THEN TO_DATE(TRIM(date_of_birth), 'MM/DD/YYYY')

        ELSE TO_DATE(TRIM(date_of_birth), 'DD-MM-YYYY')
    END AS date_of_birth,

    TRIM(phone_number) AS phone_number,
    TRIM(email) AS email,
    TRIM(address) AS address,
    TRIM(city) AS city,
    TRIM(state) AS state,
    NULLIF(TRIM(zip_code), '') AS zip_code,
    TRIM(country) AS country,
    TRIM(education_level) AS education_level,

    NULLIF(TRIM(years_of_experience), '')::NUMERIC
        AS years_of_experience,

    NULLIF(TRIM(desired_salary), '')::NUMERIC
        AS desired_salary,

    TRIM(job_title) AS job_title,
    TRIM(status) AS status

FROM raw.recruitment_data
WHERE TRIM(applicant_id) <> 'Applicant ID';


-- ============================================================
-- 4. Training & development staging
-- ============================================================

DROP TABLE IF EXISTS staging.training_and_development_data;

CREATE TABLE staging.training_and_development_data AS
SELECT
    NULLIF(TRIM(employee_id), '')::INTEGER AS employee_id,

    CASE
        WHEN NULLIF(TRIM(training_date), '') IS NULL THEN NULL
        ELSE TO_DATE(TRIM(training_date), 'DD-Mon-YY')
    END AS training_date,

    TRIM(training_program_name) AS training_program_name,
    TRIM(training_type) AS training_type,
    TRIM(training_outcome) AS training_outcome,
    TRIM(location) AS location,
    TRIM(trainer) AS trainer,

    NULLIF(TRIM(training_duration_days), '')::NUMERIC
        AS training_duration_days,

    NULLIF(TRIM(training_cost), '')::NUMERIC
        AS training_cost

FROM raw.training_and_development_data
WHERE TRIM(employee_id) <> 'Employee ID';


-- ============================================================
-- 5. Validate staging row counts
-- ============================================================

SELECT 'employee_data' AS table_name, COUNT(*) AS row_count
FROM staging.employee_data

UNION ALL

SELECT 'employee_engagement_survey_data', COUNT(*)
FROM staging.employee_engagement_survey_data

UNION ALL

SELECT 'recruitment_data', COUNT(*)
FROM staging.recruitment_data

UNION ALL

SELECT 'training_and_development_data', COUNT(*)
FROM staging.training_and_development_data;