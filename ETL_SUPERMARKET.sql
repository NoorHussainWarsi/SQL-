-- ========================================
-- SQL Script: ETL for Supermarket Data
-- 
-- Description: Cleans, transforms, and ensures data integrity for the marketing table.
-- ========================================

-- ================================
-- STEP 1: Extract/Initial Exploration
-- ================================

-- Take a look at the raw data in the table.
SELECT * 
FROM dbo.marketing;

-- Check the table schema to understand column names, data types, and nullability.
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'marketing';

-- Identify any duplicate rows based on the ID column.
SELECT ID, COUNT(*) AS duplicate_count
FROM dbo.marketing
GROUP BY ID
HAVING COUNT(*) > 1;

-- ================================
-- STEP 2: Transform/Data Cleaning
-- ================================

-- Remove unnecessary columns to streamline the table for analysis.
ALTER TABLE dbo.marketing
DROP COLUMN AcceptedCmp1, AcceptedCmp2, AcceptedCmp3, AcceptedCmp4, AcceptedCmp5, 
            Complain, Z_CostContact, Z_Revenue, Response;

-- Check for rows with missing income values. We'll address these next.
SELECT * 
FROM dbo.marketing
WHERE Income IS NULL;

-- Remove rows where Income is NULL, as they are not useful for analysis.
DELETE 
FROM dbo.marketing
WHERE Income IS NULL;

-- Remove rows with Income below 10,000, as they may represent outliers.
DELETE 
FROM dbo.marketing
WHERE Income < 10000;

-- Validate and clean up the Marital_Status column.
SELECT DISTINCT Marital_Status 
FROM dbo.marketing;

-- Remove invalid marital status entries (e.g., "Absurd").
DELETE 
FROM dbo.marketing
WHERE Marital_Status = 'Absurd';

-- Standardize values in the Education column to make it consistent.
UPDATE dbo.marketing
SET Education = 'Bachelors'
WHERE Education = 'Basic';

-- Identify outliers in the Date column (e.g., year 1900).
SELECT * 
FROM dbo.marketing
WHERE YEAR(Date) = 1900;

-- Remove rows with invalid dates.
DELETE 
FROM dbo.marketing
WHERE YEAR(Date) = 1900;

-- Further standardize Column names for better understanding.

EXEC sp_rename 'dbo.marketing.Mntwines','Wines_Spent', 'column';
EXEC sp_rename 'dbo.marketing.MntFruits','Fruits_Spent', 'column';
EXEC sp_rename 'dbo.marketing.MntMeatproducts', 'Meatproducts_spent', 'column';
EXEC sp_rename 'dbo.marketing.MntFishproducts', 'Fishproducts_spent', 'column';
EXEC sp_rename 'dbo.marketing.MntSweetproducts', 'Sweetproducts_spent', 'column';
EXEC sp_rename 'dbo.marketing.MntGoldprods', 'Goldproducts_spent', 'column';



-- ================================
-- STEP 3: Data Integrity Enforcement
-- ================================

-- Ensure the ID column is not NULL and enforce a unique primary key constraint.
ALTER TABLE dbo.marketing
ALTER COLUMN ID INT NOT NULL;

-- Add a primary key constraint on the ID column.
ALTER TABLE dbo.marketing
ADD CONSTRAINT Customer_ID PRIMARY KEY (ID);

-- Remove any rows with invalid ID values (e.g., ID = 0).
DELETE 
FROM dbo.marketing
WHERE ID = 0;

-- Verify the schema to ensure the integrity of the table.
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'marketing';

-- ================================
-- STEP 4: Load/Final Analysis
-- ================================

-- Check distinct Education values after cleaning.
SELECT DISTINCT Education 
FROM dbo.marketing;

-- Retrieve a small sample of the data to verify the results.
SELECT TOP 5 * 
FROM dbo.marketing;

-- Sort the data by Year_Birth for chronological analysis.
SELECT * 
FROM dbo.marketing
ORDER BY Year_Birth ASC;

-- Add a row number for each Education level, ordered by Recency.
SELECT *, 
       ROW_NUMBER() OVER (PARTITION BY Education ORDER BY Recency) AS [The Most Recent]
FROM dbo.marketing;

-- Rank customers by Year_Birth within each marital status group.
SELECT *, 
       RANK() OVER (PARTITION BY Marital_Status ORDER BY Year_Birth) AS [BirthYr Order]
FROM dbo.marketing;

-- ================================
-- Final Check
-- ================================

-- Perform a final check of the cleaned and transformed data. And then load/export the cleaned data 
SELECT *
FROM dbo.marketing;
