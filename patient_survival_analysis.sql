-- Update missing ethnicity
UPDATE patient_survival.ps_data
SET ethnicity = CASE
    WHEN ethnicity = '' THEN 'Mixed'
    ELSE ethnicity
END;

-- 1. Total hospital deaths and mortality rate
SELECT 
    COUNT(CASE WHEN hospital_death = 1 THEN 1 END) AS total_hospital_deaths, 
    ROUND(COUNT(CASE WHEN hospital_death = 1 THEN 1 END)*100.0/COUNT(*), 2) AS mortality_rate
FROM patient_survival.ps_data;

-- 2. Death count by ethnicity
SELECT 
    ethnicity, 
    COUNT(*) AS total_hospital_deaths
FROM patient_survival.ps_data
WHERE hospital_death = '1'
GROUP BY ethnicity;

-- 3. Death count by gender
SELECT 
    gender, 
    COUNT(*) AS total_hospital_deaths
FROM patient_survival.ps_data
WHERE hospital_death = '1'
GROUP BY gender;

-- 4. Avg and max age: died vs survived
SELECT 
    ROUND(AVG(age), 2) AS avg_age,
    MAX(age) AS max_age, 
    hospital_death
FROM patient_survival.ps_data
GROUP BY hospital_death;

-- 5. Death and survival count by age
SELECT 
    age,
    COUNT(CASE WHEN hospital_death = '1' THEN 1 END) AS amount_that_died,
    COUNT(CASE WHEN hospital_death = '0' THEN 1 END) AS amount_that_survived
FROM patient_survival.ps_data
GROUP BY age
ORDER BY age ASC;

-- 6. Age distribution in 10-year intervals
SELECT
    CONCAT(FLOOR(age / 10) * 10, '-', FLOOR(age / 10) * 10 + 9) AS age_interval,
    COUNT(*) AS patient_count
FROM patient_survival.ps_data
GROUP BY age_interval
ORDER BY age_interval;

-- 7. Survival/death by age group: over 65 vs 50–65
SELECT 
    COUNT(CASE WHEN age > 65 AND hospital_death = '0' THEN 1 END) AS survived_over_65,
    COUNT(CASE WHEN age BETWEEN 50 AND 65 AND hospital_death = '0' THEN 1 END) AS survived_between_50_and_65,
    COUNT(CASE WHEN age > 65 AND hospital_death = '1' THEN 1 END) AS died_over_65,
    COUNT(CASE WHEN age BETWEEN 50 AND 65 AND hospital_death = '1' THEN 1 END) AS died_between_50_and_65
FROM patient_survival.ps_data;

-- 8. Avg death probability by age group
SELECT
    CASE
        WHEN age < 40 THEN 'Under 40'
        WHEN age >= 40 AND age < 60 THEN '40-59'
        WHEN age >= 60 AND age < 80 THEN '60-79'
        ELSE '80 and above'
    END AS age_group,
    ROUND(AVG(apache_4a_hospital_death_prob), 3) AS average_death_prob
FROM patient_survival.ps_data
GROUP BY age_group;

-- ... [TRUNCATED for brevity in code block]
-- 24. Death probability for SICU patients with BMI > 30
SELECT 
    patient_id,
    apache_4a_hospital_death_prob AS hospital_death_prob
FROM patient_survival.ps_data
WHERE icu_type = 'SICU' AND bmi > 30
ORDER BY hospital_death_prob DESC;