# World Layoffs Data Analysis Project (SQL) 

## Project Overview
This project performs **Data Cleaning** and **Exploratory Data Analysis (EDA)** on a dataset of world layoffs from 2020 to 2023. The goal was to transform raw data into a usable format and then uncover trends, patterns, and insights regarding company layoffs globally using **MySQL**.

## Files in this Repository
* `layoffs.csv`: The raw dataset containing layoff information (Company, Location, Industry, Total Laid Off, Date, etc.).
* `layoffs_cleaned.sql`: The complete SQL script containing:
    * Staging table creation.
    * Data cleaning queries.
    * Exploratory data analysis queries.

## Part 1: Data Cleaning
The raw data contained duplicates, null values, and inconsistent formatting. The following steps were taken to clean the data:

1.  **Remove Duplicates**: 
    * Used `ROW_NUMBER()` and `PARTITION BY` to identify and remove duplicate rows based on company, industry, total laid off, and date.
2.  **Standardize Data**: 
    * Fixed spelling errors (e.g., standardizing "Crypto", "Crypto Currency", "CryptoCurrency" to just "Crypto").
    * Standardized country names (e.g., removing trailing periods from "United States.").
    * Converted the `date` column from text format to standard `DATE` format using `STR_TO_DATE`.
3.  **Null & Blank Values**:
    * Populated null `Industry` values by performing a self-join to look up the same company in other rows where the industry was not null.
    * Removed rows where both `total_laid_off` and `percentage_laid_off` were null, as they provided no actionable data.
4.  **Remove Unnecessary Columns**:
    * Dropped helper columns used during the cleaning process.

## Part 2: Exploratory Data Analysis (EDA)
After cleaning, specific questions were answered to find trends:

* **Overall Impact**: What was the maximum number of people laid off in a single day?
* **Company Failures**: Which companies went under completely (100% layoffs)?
* **Industry Analysis**: Which industries were hit the hardest by layoffs?
* **Geographical Analysis**: Which countries had the highest number of layoffs?
* **Temporal Trends**:
    * Layoffs by Year (2020 vs 2021 vs 2022).
    * Rolling Total of Layoffs month-by-month.
* **Top Companies**: Ranking the top 5 companies with the most layoffs per year using `DENSE_RANK`.

## Key Insights
* **Industry Impact**: The Consumer and Retail sectors faced significant layoffs during the analysis period.
* **Geographic Trends**: The United States had the highest reported volume of layoffs, followed by India.
* **Time Series**: 2022 and early 2023 showed a massive spike in layoffs compared to the previous years.

