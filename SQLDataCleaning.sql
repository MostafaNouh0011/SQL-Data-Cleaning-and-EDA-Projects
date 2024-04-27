/*
Data Cleaning

This dataset contains layoff data from around the world.

1. Remove Duplicates
2. Standardize the Data
3. Handle Null or Blank Values
4. Remove Irrelevant Columns (with caution)
*/

SELECT *
FROM Layoffs;

-- To safeguard our data from loss, Let's create a new table mirroring the original one.
CREATE TABLE IF NOT EXISTS layoffs_staging
LIKE Layoffs;

-- Copy data from the original table to the new table
INSERT INTO layoffs_staging 
SELECT * FROM Layoffs;

-- Displaying the data in the new table
SELECT *
FROM layoffs_staging;

/*
1. Removing Duplicates 
*/

-- Identify the duplicate rows
WITH DUP_CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY company, 
                            location, 
                            industry, 
                            total_laid_off, 
                            percentage_laid_off, 
                            date, 
                            stage, 
                            country, 
                            funds_raised_millions
           ) AS row_num
    FROM layoffs_staging
)
SELECT *
FROM DUP_CTE
WHERE row_num > 1;

-- Deleting duplicate rows
WITH DUP_CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY company, 
                            location, 
                            industry, 
                            total_laid_off, 
                            percentage_laid_off, 
                            date, 
                            stage, 
                            country, 
                            funds_raised_millions
           ) AS row_num
    FROM layoffs_staging
)
DELETE                   -- This here will not work
FROM DUP_CTE
WHERE row_num > 1;

-- So let's create another table that has the 'row_num' column and deleting rows where 'row_num' > 1

CREATE TABLE layoffs_staging2
LIKE layoffs_staging;

ALTER TABLE layoffs_staging2
ADD row_num INT;

INSERT INTO layoffs_staging2
SELECT *, ROW_NUMBER() OVER (
                   PARTITION BY company, 
                                location, 
                                industry, 
                                total_laid_off, 
                                percentage_laid_off, 
                                date, 
                                stage, 
                                country, 
                                funds_raised_millions
               ) AS row_num
FROM layoffs_staging;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

/*
2. Standardizing the Data - Identifying and fixing data issues
*/

-- Standardizing company names by removing leading and trailing spaces
SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- Standardizing 'Crypto' industry name
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

SELECT * FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Standardizing country names by removing trailing dots
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Converting the 'date' column to DATE type
SELECT date
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET date = STR_TO_DATE(date, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN date DATE;

/*
3. Handling Null or Blank Values - Populating null or missing values
*/

-- Populating missing 'industry' values based on the same company
SELECT * FROM layoffs_staging2
WHERE industry IS NULL 
OR industry = '';

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Removing rows with null values for 'total_laid_off' and 'percentage_laid_off' columns
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Finally removing the 'row_num' column as it is no longer needed
ALTER TABLE layoffs_staging2
DROP row_num;