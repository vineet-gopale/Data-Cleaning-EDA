-- DATA CLEANING

-- CREATING COPY OF ORIGINAL DATASET (best practice)
select * from layoffs;

create table layoffs_copy
like layoffs;

insert into layoffs_copy
select * from layoffs;

select * from layoffs_copy;


-- REMOVE DUPLICATES
with duplicate_cte as
(
select *, row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_copy
)
select * from duplicate_cte
where row_num > 1;


-- CANNOT DELETE FROM CTE, SO CREATE NEW TABLE COPY2
create table layoffs_copy2
like layoffs_copy;

alter table layoffs_copy2
add column row_num int;

insert into layoffs_copy2
select *, row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_copy;

select * from layoffs_copy2;


-- DELETE DUPLICATES FROM COPY2
select * from layoffs_copy2
where row_num > 1;

delete
from layoffs_copy2
where row_num > 1;


-- STANDARDIZING DATA
select * from layoffs_copy2;

-- 	REMOVE SPACES BEFORE AND AFTER TEXT IN COMPANY
update layoffs_copy2
set company = trim(company);

-- 	STANDARDIZED CRYPTO IN INDUSTRY
update layoffs_copy2
set industry = 'Crypto'
where industry like 'Crypto%';

-- CORRECT SPELLING OF LOCATION
update layoffs_copy2
set location = 'Florianopolis' where location = 'FlorianÃ³polis';
update layoffs_copy2
set location = 'Dusseldorf' where location = 'DÃ¼sseldorf';

-- STANDARDIZED UNITED STATES IN COUNTRY
update layoffs_copy2
set country = trim(trailing '.' from country);

-- DATE FORMATTING
update layoffs_copy2
set `date`= str_to_date(`date`, '%m/%d/%Y');

-- MODIFY DATE DATA TPYE ONLY AFTER CONVERTING STRING TO DATE
alter table layoffs_copy2
modify column `date` date;


-- REMOVE NULL AND BLANKS
 
 -- INDUSTRY
select * from layoffs_copy2 where industry is null or industry = '';
select * from layoffs_copy2 where company = 'Airbnb'; -- Travel
select * from layoffs_copy2 where company = "Bally's Interactive"; -- N/A
select * from layoffs_copy2 where company = 'Carvana'; -- Transportation
select * from layoffs_copy2 where company = 'Juul'; -- Consumer

-- POPULATE DATA
-- METHOD 1
update layoffs_copy2
set industry = null
where industry = '';

select * 
from layoffs_copy2 t1
join layoffs_copy2 t2
on t1.company = t2.company
where t1.industry is null and t2.industry is not null;

update layoffs_copy2 t1
join layoffs_copy2 t2
on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null and t2.industry is not null;

-- METHOD 2
update layoffs_copy2
set industry = 'Travel'
where company = 'Airbnb' and (industry = '' or industry is null);

update layoffs_copy2
set industry = 'Transportation'
where company = 'Carvana' and (industry = '' or industry is null);

update layoffs_copy2
set industry = 'Consumer'
where company = 'Juul' and (industry = '' or industry is null);

-- REMOVE ROWS WHERE TOTAL AND PERCENTAGE LAID_OFF VALUES ARE NULL
delete
from layoffs_copy2
where total_laid_off is null and percentage_laid_off is null;

-- FINALLY DELETE COLUMN ROW_NUM
alter table layoffs_copy2
drop column row_num;

-- CLEAN DATASET
select * from layoffs_copy2;



-- EXPLORATORY DATA ANALYSIS

select min(`date`), max(`date`)
from layoffs_copy2;
-- March 2020 - 2023 (major factor : covid)

select min(total_laid_off), max(total_laid_off),  min(percentage_laid_off), max(percentage_laid_off)
from layoffs_copy2;
-- data distributuion

select * 
from layoffs_copy2
where percentage_laid_off = 1
order by funds_raised_millions desc;
-- billions invested gone

select * 
from layoffs_copy2
where percentage_laid_off = 1
order by total_laid_off desc;
-- company shutdown or bankrupcy

select company, sum(total_laid_off)
from layoffs_copy2
group by company
order by 2 desc;
-- big company layoff numbers

select industry, sum(total_laid_off)
from layoffs_copy2
group by industry
order by 2 desc;
-- consumer, retail and transportation had highest layoffs

select industry, ROUND(AVG(percentage_laid_off),2)
from layoffs_copy2
group by industry
order by 2 desc;
-- aerospace, education, travel, food had highest proportion of layoffs

select country, sum(total_laid_off)
from layoffs_copy2
group by country
order by 2 desc;
-- USA alone has more than twice the sum of rest all country's layoffs combined in 3 years

select country, ROUND(AVG(percentage_laid_off),2)*100
from layoffs_copy2
group by country
order by 2 desc;
-- vietnam : avg 83% layoff(highest) and colombia : avg 3% layoff(lowest)

select year(`date`), month(`date`), sum(total_laid_off)
from layoffs_copy2
group by year(`date`), month(`date`)
order by 3 desc;
-- peak layoffs were in late 2022, early 2023 and mid 2020 i.e. start of covid

SELECT stage, sum(total_laid_off)
FROM layoffs_copy2
GROUP BY stage
ORDER BY 2 DESC;
-- highest no of layoffs in bigger i.e. post-ipo and acquired comapnies

SELECT stage, ROUND(AVG(percentage_laid_off),2)
FROM layoffs_copy2
GROUP BY stage
ORDER BY 2 DESC;
-- highest proportion of layoffs in smaller i.e seed, series A,B,C,etc.


with rolling as
(
select year(`date`) as `year`, month(`date`) as `month`, sum(total_laid_off) as monthly_layoff
from layoffs_copy2
where year(`date`) is not null
group by year(`date`), month(`date`)
order by 1
)
select *, sum(monthly_layoff) over(order by `year`,`month`) as rolling_total
from rolling;
-- in 3 years, more than 3.8 lakh employees laid off 


with company_year(comapny, years, layoffs) as
(
select company, year(`date`), sum(total_laid_off)
from layoffs_copy2
group by company, year(`date`)
)
, company_year_rank as 
(
select *, dense_rank() over(partition by years order by layoffs desc) as ranking
from company_year
where years is not null
)
select * 
from company_year_rank
where ranking <= 5;
-- top 5 companies with highest no of layoffs each year


with company_year(comapny, years, layoffs_percentage, layoffs_total) as
(
select company, year(`date`), ROUND(AVG(percentage_laid_off),2)*100, sum(total_laid_off)
from layoffs_copy2
group by company, year(`date`)
)
, company_year_rank as 
(
select *, dense_rank() over(partition by years order by layoffs_percentage desc) as ranking
from company_year
where years is not null
)
select * 
from company_year_rank
where ranking <= 5;

































