/* Cleaning Used Car Data */

SELECT * 
FROM UsedCars


--Change Petrol to Gasoline in 'fuel' field

SELECT DISTINCT(fuel), COUNT(fuel)
FROM UsedCars
GROUP BY fuel

SELECT fuel,
	CASE WHEN fuel = 'Petrol' THEN 'Gasoline'
	ELSE fuel
	END
FROM UsedCars

UPDATE UsedCars
SET fuel = CASE WHEN fuel = 'Petrol' THEN 'Gasoline'
	ELSE fuel
	END


--Populate 'region' field for null values

SELECT a.sales_ID, a.region, b.[state or province], ISNULL(NULL, 'West')
FROM UsedCars a
JOIN UsedCars b
	ON a.sales_ID = b.sales_ID
WHERE a.region is null

UPDATE a
SET region = ISNULL(NULL, 'West')
FROM UsedCars a
JOIN UsedCars b
	ON a.sales_ID = b.sales_ID
WHERE a.region is null


--Remove duplicate rows

WITH row_countCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY sales_ID,
				name,
				selling_price,
				km_driven,
				mileage,
				location
				ORDER BY
					sales_ID
					) row_count

FROM UsedCars
)
DELETE
FROM row_countCTE
WHERE row_count >1


--Combine state and city into one column

SELECT [state or province], city
FROM UsedCars

SELECT CONCAT(city, ', ', [state or province]) AS location
FROM UsedCars

ALTER TABLE UsedCars
ADD location NVARCHAR(255);

UPDATE UsedCars
SET location = CONCAT(city, ', ', [state or province])


-- Delete unused columns

SELECT * 
FROM UsedCars

ALTER TABLE UsedCars
DROP COLUMN [state or province], city
