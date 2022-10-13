/* Selecting data I want to use for Tableau Project */




--1.

SELECT  Age, AVG(MonthlyIncome), Count(WorkLifeBalance)
FROM Portfolio..HR
GROUP BY Age
ORDER BY Age asc


--2.

SELECT Gender, AVG(TotalWorkingYears), AVG(YearsAtCompany), AVG(YearsInCurrentRole)
FROM Portfolio..HR
GROUP BY Gender


--3.

SELECT JobRole, SUM(JobSatisfaction)
FROM Portfolio..HR
GROUP BY JobRole


--4.

SELECT JobRole, SUM(WorkLifeBalance)
FROM Portfolio..HR
GROUP BY JobRole