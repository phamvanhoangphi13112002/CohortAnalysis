SELECT *
FROM datasource_online_retail_clean AS d
--------------BEGIN COHORT ANALYSIS----------------------------
---Data Required:
--Unique Identifier (CustomerID)
--Initial Start Date (First	Invoice Date)
--Revenue Data (Quantity*UnitPrice)
SELECT CustomerID,
		MIN(InvoiceDate) AS First_purchase_date,
		DATEFROMPARTS(YEAR(MIN(InvoiceDate)), MONTH(MIN(InvoiceDate)),1) AS Cohort_Date
into #cohort
FROM datasource_online_retail_clean
GROUP BY CustomerID

--Create Cohort index
SELECT 
	mm.*,
	cohort_index = Year_diff*12+Month_diff+1
INTO #cohort_retention 
FROM
	(
	SELECT
		m.*,
		Year_diff = InvoiceYear - CohortYear,
		Month_diff = InvoiceMonth - CohortMonth	
	FROM
		(
		SELECT d.*, c.Cohort_Date,
				YEAR(d.InvoiceDate) AS InvoiceYear,
				MONTH(d.InvoiceDate) AS InvoiceMonth,
				YEAR(c.Cohort_Date) AS CohortYear,
				MONTH(c.Cohort_Date) AS CohortMonth
		FROM datasource_online_retail_clean AS d
		LEFT JOIN #cohort AS c
			ON c.CustomerID = d.CustomerID
	) AS m
) AS mm
--WHERE CustomerID = 18168
---cohort_retention.csv table--
SELECT *
FROM #cohort_retention
--
--Pivot Data to see the cohort table
SELECT
	*
INTO #cohort_pivot
FROM
	(
	SELECT DISTINCT 
			CustomerID,
			Cohort_Date,
			cohort_index
	FROM #cohort_retention
) AS TBL
	PIVOT(
		COUNT(CustomerID)
		FOR Cohort_Index In 
		(
		[1],
		[2],
		[3],
		[4],
		[5],
		[6],
		[7],
		[8],
		[9],
		[10],
		[11],
		[12],
		[13]
		)
   ) AS Pivot_Table
ORDER BY Cohort_Date

--Cohort_table_count
SELECT *
FROM #cohort_pivot
ORDER BY Cohort_Date

--Cohort_table_percentage
select Cohort_Date ,
	(1.0 * [1]/[1] * 100) as [1], 
    1.0 * [2]/[1] * 100 as [2], 
    1.0 * [3]/[1] * 100 as [3],  
    1.0 * [4]/[1] * 100 as [4],  
    1.0 * [5]/[1] * 100 as [5], 
    1.0 * [6]/[1] * 100 as [6], 
    1.0 * [7]/[1] * 100 as [7], 
	1.0 * [8]/[1] * 100 as [8], 
    1.0 * [9]/[1] * 100 as [9], 
    1.0 * [10]/[1] * 100 as [10],   
    1.0 * [11]/[1] * 100 as [11],  
    1.0 * [12]/[1] * 100 as [12],  
	1.0 * [13]/[1] * 100 as [13]
from #cohort_pivot
order by Cohort_Date
