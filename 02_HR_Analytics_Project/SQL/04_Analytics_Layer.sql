-- ============================================================
-- HR Workforce, Attrition & Employee Performance Analytics
-- 04 - Analytics Layer
-- PostgreSQL
-- ============================================================


-- ============================================================
-- 1. Date Dimension
-- ============================================================

DROP TABLE IF EXISTS analytics.dim_date;

CREATE TABLE analytics.dim_date AS
SELECT
    date_value::DATE AS date,
    EXTRACT(YEAR FROM date_value)::INTEGER AS year,
    EXTRACT(QUARTER FROM date_value)::INTEGER AS quarter,
    EXTRACT(MONTH FROM date_value)::INTEGER AS month_number,
    TO_CHAR(date_value, 'Month') AS month_name,
    TO_CHAR(date_value, 'Mon') AS month_short,
    EXTRACT(WEEK FROM date_value)::INTEGER AS week_number,
    EXTRACT(DAY FROM date_value)::INTEGER AS day_number,
    TO_CHAR(date_value, 'Day') AS day_name

FROM generate_series(

    LEAST(
        (SELECT MIN(start_date)
         FROM staging.employee_data),

        (SELECT MIN(survey_date)
         FROM staging.employee_engagement_survey_data),

        (SELECT MIN(application_date)
         FROM staging.recruitment_data),

        (SELECT MIN(training_date)
         FROM staging.training_and_development_data)
    ),

    GREATEST(
        (SELECT MAX(start_date)
         FROM staging.employee_data),

        (SELECT MAX(exit_date)
         FROM staging.employee_data),

        (SELECT MAX(survey_date)
         FROM staging.employee_engagement_survey_data),

        (SELECT MAX(application_date)
         FROM staging.recruitment_data),

        (SELECT MAX(training_date)
         FROM staging.training_and_development_data)
    ),

    INTERVAL '1 day'

) AS date_value;


-- ============================================================
-- 2. Employee Dimension
-- ============================================================

DROP TABLE IF EXISTS analytics.dim_employee;

CREATE TABLE analytics.dim_employee AS
SELECT
    emp_id AS employee_id,
    first_name,
    last_name,
    start_date,
    exit_date,
    title,
    supervisor,
    business_unit,
    employee_status,
    employee_type,
    pay_zone,
    employee_classification_type,
    termination_type,
    termination_description,
    department,
    division,
    state,
    job_function,
    gender_code,
    location_code,
    race_desc,
    marital_desc,
    performance_score,
    current_employee_rating

FROM staging.employee_data;


-- ============================================================
-- 3. Engagement Fact
-- ============================================================

DROP TABLE IF EXISTS analytics.fact_engagement;

CREATE TABLE analytics.fact_engagement AS
SELECT
    employee_id,
    survey_date,
    engagement_score,
    satisfaction_score,
    work_life_balance_score

FROM staging.employee_engagement_survey_data;


-- ============================================================
-- 4. Training Fact
-- ============================================================

DROP TABLE IF EXISTS analytics.fact_training;

CREATE TABLE analytics.fact_training AS
SELECT
    employee_id,
    training_date,
    training_program_name,
    training_type,
    training_outcome,
    location,
    trainer,
    training_duration_days,
    training_cost

FROM staging.training_and_development_data;


-- ============================================================
-- 5. Recruitment Fact
-- ============================================================

DROP TABLE IF EXISTS analytics.fact_recruitment;

CREATE TABLE analytics.fact_recruitment AS
SELECT
    applicant_id,
    application_date,
    first_name,
    last_name,
    gender,
    date_of_birth,
    education_level,
    years_of_experience,
    desired_salary,
    job_title,
    status

FROM staging.recruitment_data;


-- ============================================================
-- 6. Workforce Movement Fact
-- ============================================================

DROP TABLE IF EXISTS analytics.fact_workforce;

CREATE TABLE analytics.fact_workforce AS

SELECT
    e.employee_id,
    e.start_date AS date,
    'Joined' AS event_type

FROM analytics.dim_employee e

UNION ALL

SELECT
    e.employee_id,
    e.exit_date AS date,
    'Exited' AS event_type

FROM analytics.dim_employee e

WHERE e.exit_date IS NOT NULL;


-- ============================================================
-- 7. Monthly Attrition / Workforce Movement View
-- ============================================================

CREATE OR REPLACE VIEW analytics.vw_attrition_monthly AS

SELECT
    DATE_TRUNC('month', date)::DATE AS month,

    COUNT(*) FILTER (
        WHERE event_type = 'Joined'
    ) AS joined_count,

    COUNT(*) FILTER (
        WHERE event_type = 'Exited'
    ) AS exited_count

FROM analytics.fact_workforce

GROUP BY DATE_TRUNC('month', date)

ORDER BY month;