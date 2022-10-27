/* Credit Score Data Exploration */

SELECT *
FROM Portfolio..CScore

SELECT *
FROM Portfolio..CCustomer


-- Calculating the interest paid on each line of credit

SELECT Num_Credit_Card, Interest_Rate, Total_EMI_per_month, 
(Total_EMI_per_month*(Interest_Rate/100)) AS Interest_Paid
FROM Portfolio..CScore
ORDER BY Interest_Paid desc


-- Classifying severity of interest rates with CASE statement as low, moderate, and high

SELECT MIN(Interest_Rate), MAX(Interest_Rate)
FROM Portfolio..CScore

SELECT Customer_ID, Total_EMI_per_month, Interest_Rate,
	CASE 
		WHEN Interest_Rate <= 12 THEN 'LOW'
		WHEN Interest_Rate >12
			AND Interest_Rate <25 THEN 'MODERATE'
		ELSE 'HIGH'
	END AS Interest_Rate_Class
FROM Portfolio..CScore


-- EMI vs monthly balance

SELECT Total_EMI_per_month, Monthly_Balance,
(Total_EMI_per_month/Monthly_Balance)*100 AS EMI_Percentage
FROM Portfolio..CScore


-- Looking at each customer's monthly balance by calculating: average, minimum, maximum, and sum

SELECT Customer_ID,
	AVG(Monthly_Balance) AS Monthly_Balance_Avg,
	MIN(Monthly_Balance) AS Monthly_Balance_Min,
	MAX(Monthly_Balance) AS Monthly_Balance_Max,
	SUM(Monthly_Balance) AS Monthly_Balance_Sum
FROM Portfolio..CScore
GROUP BY Customer_ID
ORDER BY 1,2


-- Creating a rank of outstanding debt

SELECT Customer_ID, Outstanding_Debt,
	RANK() OVER (ORDER BY Outstanding_Debt DESC) AS RankByDebt
FROM Portfolio..CScore
ORDER BY Outstanding_Debt DESC


-- Joining tables and looking at each customer's monthly pay after deducting (EMI + interest)

SELECT credit.Customer_ID, customer.Name,customer.Occupation, credit.Interest_Rate, 
SUM(credit.Total_EMI_per_month) AS EMI_Sum, customer.Monthly_Inhand_Salary, 
(customer.Monthly_Inhand_Salary - (credit.Total_EMI_per_month*(credit.Interest_Rate/100)))
AS [Pay-(EMI+interest)]
FROM Portfolio..CScore credit
INNER JOIN Portfolio..CCustomer customer
	ON credit.Customer_ID = customer.Customer_ID
GROUP BY credit.Customer_ID, customer.Name, customer.Occupation, credit.Interest_Rate, 
customer.Monthly_Inhand_Salary, credit.Total_EMI_per_month
ORDER BY [Pay-(EMI+interest)] DESC


--Creating a view of the above query for later use

CREATE VIEW RealisticMonthlyIncome AS
SELECT credit.Customer_ID, customer.Name, customer.Occupation, credit.Interest_Rate, 
SUM(credit.Total_EMI_per_month) AS EMI_Sum, customer.Monthly_Inhand_Salary, 
(customer.Monthly_Inhand_Salary - (credit.Total_EMI_per_month*(credit.Interest_Rate/100)))
AS [Pay-(EMI+interest)]
FROM Portfolio..CScore credit
INNER JOIN Portfolio..CCustomer customer
	ON credit.Customer_ID = customer.Customer_ID
GROUP BY credit.Customer_ID, customer.Name, customer.Occupation, credit.Interest_Rate, 
customer.Monthly_Inhand_Salary, credit.Total_EMI_per_month
--ORDER BY [Pay-(EMI+interest)] DESC


-- Calculating average # lines of credit and average EMI

SELECT customer.Customer_ID, Name, Monthly_Inhand_Salary, Credit_Score,
AVG(Num_Credit_Card + Num_of_Loan) OVER (PARTITION BY (Num_Credit_Card + Num_of_Loan)) AS Avg_Lines_Credit,
AVG(Monthly_Balance) OVER (PARTITION BY Monthly_Balance) AS Avg_Monthly_Balance
FROM Portfolio..CScore credit
INNER JOIN Portfolio..CCustomer customer
	ON credit.Customer_ID = customer.Customer_ID



-- Creating a CTE for calculating average monthly balance per line of credit

WITH CTE_Credit (Customer_ID, Name, Monthly_Inhand_Salary, Credit_Score, Avg_Lines_Credit, Avg_Monthly_Balance)
AS 
(
SELECT customer.Customer_ID, Name, Monthly_Inhand_Salary, Credit_Score,
AVG(Num_Credit_Card + Num_of_Loan) OVER (PARTITION BY (Num_Credit_Card + Num_of_Loan)) AS Avg_Lines_Credit,
AVG(Monthly_Balance) OVER (PARTITION BY Monthly_Balance) AS Avg_Monthly_Balance
FROM Portfolio..CScore credit
INNER JOIN Portfolio..CCustomer customer
	ON credit.Customer_ID = customer.Customer_ID
)
SELECT *, (Avg_Monthly_Balance/Avg_Lines_Credit) AS Avg_MB_Per_Line
FROM CTE_Credit
WHERE Avg_Lines_Credit <> 0
AND Avg_Monthly_Balance <> 0


-- Experts recommend keeping your credit utilization below 30%.
-- Creating a temp table to compare credit scores of people that utilize more than 30% of their credit

DROP TABLE IF EXISTS #CreditUtilization
CREATE TABLE #CreditUtilization
(Customer_ID NVARCHAR(MAX),
Name NVARCHAR(MAX),
Monthly_Inhand_Salary NUMERIC,
Age NUMERIC,
Avg_Credit_Utilization_Ratio NUMERIC,
Credit_Score NVARCHAR(MAX))

INSERT INTO #CreditUtilization
SELECT customer.Customer_ID, Name, Monthly_Inhand_Salary, Age, 
AVG(Credit_Utilization_Ratio) AS Avg_Credit_Utilization_Ratio, Credit_Score
FROM Portfolio..CScore credit
INNER JOIN Portfolio..CCustomer customer
	ON credit.Customer_ID = customer.Customer_ID
GROUP BY customer.Customer_ID, Name, Monthly_Inhand_Salary, Age, Credit_Score
ORDER BY Avg_Credit_Utilization_Ratio DESC


-- Calculating total customers 
-- = 15742

SELECT COUNT(Name)
FROM #CreditUtilization
WHERE Avg_Credit_Utilization_Ratio > 30


-- Calculating # of customers with good credit & utilize over 30% of credit
-- = 3056

SELECT COUNT(Name)
FROM #CreditUtilization
WHERE Avg_Credit_Utilization_Ratio > 30
AND Credit_Score LIKE '%Good%'


-- Calculating # of customers with standard credit & utilize over 30% of credit
-- = 8667

SELECT COUNT(Name)
FROM #CreditUtilization
WHERE Avg_Credit_Utilization_Ratio > 30
AND Credit_Score LIKE '%Standard%'


-- Calculating # of customers with poor credit & utilize over 30% of credit
-- = 4019

SELECT COUNT(Name)
FROM #CreditUtilization
WHERE Avg_Credit_Utilization_Ratio > 30
AND Credit_Score LIKE '%Poor%'


-- Creating a temp table with our findings above

DROP TABLE IF EXISTS #Over30PercentUtilization
CREATE TABLE #Over30PercentUtilization
(Good NVARCHAR(MAX),
Standard NVARCHAR(MAX),
Poor NVARCHAR(MAX))

INSERT INTO #Over30PercentUtilization VALUES('19%', '55%', '26%')

SELECT *
FROM #Over30PercentUtilization

