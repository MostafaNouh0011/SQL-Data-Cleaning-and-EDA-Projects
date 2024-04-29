
/*
	Exploratory Data Analysis (EDA) of Layoffs Dataset
*/


-- Display all data from the "layoffs_staging2" table
SELECT *
FROM layoffs_staging2;

-- Count the total number of records in the table
SELECT COUNT(*) AS total_records
FROM layoffs_staging2;

-- Calculate the total number of laid-off employees
SELECT SUM(total_laid_off) AS total_laid_off_count
FROM layoffs_staging2;

-- Find the maximum values of key columns
SELECT MAX(total_laid_off), 
	   MAX(percentage_laid_off), 
	   MAX(funds_raised_millions)
FROM layoffs_staging2;

-- Identify companies with a 100% layoff rate, sorted by total laid-off employees
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

-- Calculate the total number of laid-off employees for each company, sorted in descending order
SELECT company, SUM(total_laid_off) AS total_laid_off_count
FROM layoffs_staging2
GROUP BY company
ORDER BY total_laid_off_count DESC;

-- Calculate total funds raised by each company per year
WITH Company_Funds AS (
    SELECT company, YEAR(date) AS year, SUM(funds_raised_millions) AS total_funds_raised
    FROM layoffs_staging2
    GROUP BY company, YEAR(date)
    ORDER BY company ASC
)
SELECT company, year, total_funds_raised
FROM Company_Funds;


-- Analyze layoffs by industry
SELECT industry, SUM(total_laid_off) AS total_laid_off_count
FROM layoffs_staging2
GROUP BY industry
ORDER BY total_laid_off_count DESC;

-- Analyze layoffs by country
SELECT country, SUM(total_laid_off) AS total_laid_off_count
FROM layoffs_staging2
GROUP BY country
ORDER BY total_laid_off_count DESC;

-- Analyze layoffs by location
SELECT location, SUM(total_laid_off) AS total_laid_off_count
FROM layoffs_staging2
GROUP BY location
ORDER BY total_laid_off_count DESC;

-- Analyze layoffs by stage
SELECT stage, SUM(total_laid_off) AS total_laid_off_count
FROM layoffs_staging2
GROUP BY stage
ORDER BY total_laid_off_count DESC;


-- Determine the date range of the dataset
SELECT MIN(date), MAX(date)
FROM layoffs_staging2;

-- Analyze layoffs by date
SELECT date, SUM(total_laid_off) AS total_laid_off_count
FROM layoffs_staging2
GROUP BY date
ORDER BY total_laid_off_count DESC;

-- Analyze layoffs by year
SELECT YEAR(date) AS year, SUM(total_laid_off) AS total_laid_off_count
FROM layoffs_staging2
GROUP BY YEAR(date)
ORDER BY total_laid_off_count DESC;

-- Analyze layoffs by month
SELECT SUBSTRING(date, 1, 7) AS month, SUM(total_laid_off) AS total_laid_off_count
FROM layoffs_staging2
WHERE date IS NOT NULL
GROUP BY month
ORDER BY month ASC;

-- Calculate rolling total of layoffs by month
WITH Rolling_Total AS (
    SELECT SUBSTRING(date, 1, 7) AS month, SUM(total_laid_off) AS total_laid_off_count
    FROM layoffs_staging2
    WHERE date IS NOT NULL
    GROUP BY month
    ORDER BY month ASC
)
SELECT month, total_laid_off_count, SUM(total_laid_off_count) OVER(ORDER BY month) AS cumulative_total
FROM Rolling_Total;


-- Display all data from the "layoffs_staging2" table
SELECT *
FROM layoffs_staging2;


-- Analyze layoffs by company and year, displaying the top 5 companies with the highest total layoffs each year
WITH Company_Year AS (
    SELECT company, YEAR(date) AS year, SUM(total_laid_off) AS total_laid_off_count
    FROM layoffs_staging2
    GROUP BY company, YEAR(date)
), Company_Year_Rank AS (
    SELECT *, 
           DENSE_RANK() OVER(PARTITION BY year ORDER BY total_laid_off_count DESC) AS ranking
    FROM Company_Year
    WHERE year IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE ranking <= 5;
