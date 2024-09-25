# SQL-Data-Cleaning---Bootcamp-Project
Data cleaning project using MySQL to prepare a database for further analysis.

This document outlines the data cleaning process applied to a layoffs database using MySQL. The goal was to transform raw data into a clean and consistent format suitable for further analysis.

**Key Steps:**

**1. Data Duplication Removal:**
  - Identified duplicate rows based on a combination of columns (company, location, industry, etc.).
  - Assigned row numbers to identify duplicates efficiently.
  - Created a new table excluding duplicate entries based on row numbers.
  
**2. Data Standardization:**
  - Removed leading and trailing spaces from string columns (e.g., company names).
  - Standardized industry labels (e.g., "Crypto," "CryptoCurrency," all became "Crypto").
  - Formatted the date column from string to a proper date type using STR_TO_DATE function.
  - Ensured consistent country names (e.g., "United States" for all variations).

**3. Handling Null or Blank Values:**
  - Identified rows with missing or blank values in the "industry" column.
  - Used self-joins to leverage industry information from other rows with the same company (if available).
  - Optionally, rows with missing values in both "total_laid_off" and "percentage_laid_off" were removed (consider data context before applying).

**4. Removing Unnecessary Columns:**
  - The "row_num" column, used for identifying duplicates, was removed after serving its purpose.

**Skills Used:**
  - Joins (self-joins)
  - Common Table Expressions (CTEs)
  - Data Type Conversion
  - Data Manipulation Techniques (UPDATE, DELETE)
