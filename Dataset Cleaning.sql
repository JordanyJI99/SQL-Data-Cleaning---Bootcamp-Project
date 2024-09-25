-- Data Cleaning --

-- Skills used: Joins, CTE's, Creating and Updating Tables, Converting Data Types. --

SELECT * 
FROM layoffs;

-- 1. Removing Duplicates if they exist. --
-- 2. Standardize the Data --
-- 3. Null or Blank Values --
-- 4. Remove any columns -- 

-- Creating a new table to work with in order to not make changes to the raw data --
CREATE TABLE layoffs_to_work
SELECT *
FROM layoffs;

-- 1. *REMOVING DUPLICATES IF EXISTS* --
-- In order to first know if I have duplicate rows, I have to assign row numbers to each row to see if they are duplicated --
WITH duplicate_cte AS
(SELECT *, 
	ROW_NUMBER() OVER(
		PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions
    ) AS row_num
FROM layoffs_to_work
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- Now, all the columns with row_num bigger than 1 mean that it's duplicated so I have
-- to create now a new table where I insert all this data except those columns that are duplicated. --

CREATE TABLE `layoffs_to_work2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL, 
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Now I insert data within the new table but without including any row with the row number greater
-- than 1 and in that way I'm making a new table without duplicates. --
INSERT INTO layoffs_to_work2
WITH duplicate_cte AS
(SELECT *, 
	ROW_NUMBER() OVER(
		PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions
    ) AS row_num
FROM layoffs_to_work
)
SELECT *
FROM duplicate_cte
WHERE row_num = 1;

SELECT *
FROM layoffs_to_work2
WHERE row_num > 1;

-- 2. *STANDARDIZING DATA* --
-- Removing the extra spaces from strings --
UPDATE layoffs_to_work2
SET company = TRIM(company);

SELECT *
FROM layoffs_to_work2;

-- On our industry column we can see inconsitency on the labeling of the industries like crypto, CryptoCurrency
-- or Crypto Currency that all make reference to the same thing so we want to name all in the same way. --

-- We have to make a review of our names to determine if there is any inconsistency, we should do it with every column. --
SELECT DISTINCT industry
FROM layoffs_to_work2
ORDER BY 1;

SELECT *
FROM layoffs_to_work2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_to_work2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT country
FROM layoffs_to_work2
ORDER BY 1;
-- we have United States and Unite States. but is the same country so we have solve this issue.

UPDATE layoffs_to_work2
SET country = 'United States'
WHERE country LIKE 'United States%';

-- Now our date column is a string type and I want to format it as a date type, and we can use the str_to_date() function to do that. --
SELECT `date`
FROM layoffs_to_work2;

-- Next step is to standardize the date column --
UPDATE layoffs_to_work2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
-- now we're changing the data type from our column from text to date type --
ALTER TABLE layoffs_to_work2
MODIFY COLUMN `date` DATE;

-- 3. *WORKING WITH NULL OR BLANK VALUES* --
-- We already saw that industry columns have some NULL or blank spaces so we're 
-- going to try to find a solution to that issue in the first instance. --
SELECT *
FROM layoffs_to_work2
WHERE industry IS NULL OR 
	industry = '';
    
-- The previous query shows us that one of the rows with industry blank is Airbnb, and we're 
-- now going to look if we have another row with Airbnb and if that one has the industry type on it.
SELECT *
FROM layoffs_to_work2
WHERE company LIKE '%Airbnb%';

UPDATE layoffs_to_work2
SET industry = NULL
WHERE industry = '';

-- We're doing a self-join to find if there are rows for the same company with any information 
-- in the industry column that we can use to fill the missing information. --
SELECT t1.company, t1.industry, t2.industry
FROM layoffs_to_work2 t1
JOIN layoffs_to_work2 t2
ON t1.company = t2.company
WHERE t1.industry IS NULL AND
	t2.industry IS NOT NULL;

UPDATE layoffs_to_work2 t1
JOIN layoffs_to_work2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry 
WHERE (t1.industry IS NULL or t1.industry = '') AND
	t2.industry IS NOT NULL;

-- Now we're deleting the rows in which we don't have a way to bring this information (let's say that we were allowed to do such a thing). --
SELECT *
FROM layoffs_to_work2
WHERE total_laid_off IS NULL
	AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_to_work2
WHERE total_laid_off IS NULL
	AND percentage_laid_off IS NULL;
    
-- 4. *REMOVING ANY COLUMN WE DON'T NEED* --

-- In this case, we're going to remove just the "row_num" column we created at the
-- beginning to get rid of the duplicates because that column we don't need anymore. --

ALTER TABLE layoffs_to_work2
DROP COLUMN row_num;

SELECT *
FROM layoffs_to_work2;