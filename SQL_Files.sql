use bigbasket;

--- "Data Cleaning" 

--- 1.Identify duplicate products
SELECT product,
COUNT(*) AS Duplicate_Product 
FROM bigbasket
GROUP BY product
HAVING COUNT(*) > 1;

--- 2.Find NULL values in every column
SELECT * FROM bigbasket
WHERE product IS NULL
OR
 category IS NULL
OR
sub_category IS NULL
OR
 brand IS NULL
OR
 sale_price = 0
OR
 market_price = 0 
OR
 type IS NULL
OR
 rating = 0
OR 
 description IS NULL;
 
 --- 3.	Find missing brand names
 SELECT brand FROM bigbasket 
 WHERE brand IS NULL;
 
 --- 4.	Find products with zero or negative prices	
 SELECT product FROM bigbasket
 WHERE market_price = 0
 or
 market_price < 0;
 
--- 5. Find products where sale price exceeds market price
SELECT * FROM bigbasket
WHERE sale_price > market_price;

--- 6. Identify ratings inside 0–5	
SELECT * FROM bigbasket 
WHERE rating BETWEEN 0 AND 5;

--- 7. Remove unnecessary spaces from brand names
UPDATE bigbasket 
SET brand = TRIM(brand);

--- 8. Standardize category 
UPDATE bigbasket
SET category = 
CASE 
WHEN category in ('BEVERAGES', 'beverages', 'Beverages') then 'Beverages'
ELSE category 
END;

--- 9. Handle missing ratings
UPDATE bigbasket
SET rating = COALSECE(rating, 0);

--- 10.	Verify cleaned data
SELECT * FROM bigbasket;

---- "Exploratory Data Analysis (EDA)"

--- 1.Find total products.
SELECT COUNT(product) 
FROM bigbasket;

--- 2. Count unique brands.
SELECT COUNT(DISTINCT(brand)) AS Unique_Brand
FROM bigbasket;

--- 3. Count unique categories.
SELECT COUNT(DISTINCT(category)) AS Unique_Category 
FROM bigbasket;

--- 4. Find the average sale price.
SELECT AVG(market_price) 
FROM bigbasket;

--- 5. Find the maximum and minimum sale price.
SELECT MAX(market_price)
FROM bigbasket
UNION
SELECT MIN(market_price) 
FROM bigbasket;

--- 6. Calculate average product rating.
SELECT AVG(rating)
FROM bigbasket;

--- 7. Find the most expensive product.
SELECT product 
FROM bigbasket
ORDER BY sale_price DESC
LIMIT 1;

--- 8. Find the cheapest product.
SELECT product 
FROM bigbasket
ORDER BY sale_price
LIMIT 1;

--- 9. Count products in each category.
SELECT category , count(*) 
FROM bigbasket
GROUP BY category;

--- 10. Find the number of products in each brand.
SELECT brand , COUNT(*)
FROM bigbasket
GROUP BY brand;

---- "Product & Category Analysis"

--- 1. Find the top 10 expensive products.
SELECT * FROM bigbasket
ORDER BY market_Price DESC
LIMIT 10;

--- 2. Find the 10 cheapest products.
SELECT * FROM bigbasket
ORDER BY market_Price 
LIMIT 10;

--- 3. Find the top 10 highest-rated products.
SELECT * FROM bigbasket
ORDER BY rating DESC
LIMIT 10;

--- 4. Find the average rating by category.
SELECT category, AVG(rating) 
FROM bigbasket
GROUP BY category 
ORDER BY AVG(rating) DESC;

--- 5. ind the average sale price by category.
SELECT category, AVG(sale_price) 
FROM bigbasket
GROUP BY category 
ORDER BY AVG(sale_price) DESC;

--- 6. Identify the category having the highest number of products.
SELECT category , COUNT(*)
FROM bigbasket 
GROUP BY category 
ORDER BY COUNT(*) DESC
LIMIT 1;

--- 7. Find brands with more than 50 products.
SELECT brand, COUNT(*)
FROM bigbasket
GROUP BY brand
HAVING COUNT(*) > 50;

--- 8. Find the top 5 brands by average rating.
SELECT brand , AVG(rating) 
FROM bigbasket
GROUP BY brand 
ORDER BY AVG(rating) DESC
LIMIT 5;

--- 9. Find the second-most expensive product in each category.
WITH second_highest AS(
SELECT 
product,
category,
rating,
market_price,
DENSE_RANK() OVER( PARTITION BY category ORDER BY market_Price) as 'Ranker' 
FROM bigbasket)
SELECT * 
FROM second_highest 
WHERE Ranker = 2;

--- 10. Find categories having an average rating above 4.
SELECT category, AVG(rating) as Avg_Rating
FROM bigbasket 
GROUP BY category
HAVING AVG(rating) > 4;

---- "Pricing & Discount Analysis"

--- 1. Create Discount_Amount Column
ALTER TABLE bigbasket
ADD COLUMN discount_amount int;

--- 2. Calculate Discount_Amount 
UPDATE bigbasket
SET discount_amount = market_price - sale_price;

--- 3. Calculate discount amount for every product.
SELECT product, SUM(discount_amount) as TOTAL_DISCOUNT 
FROM bigbasket
GROUP BY product
ORDER BY SUM(discount_amount) DESC;

--- 4. Create Dicount_Percentage Column 
ALTER TABLE bigbasket
 ADD COLUMN Discount_Percentage int ;
 
--- 5. Calculate discount percentage.
SELECT 
product,
SUM(discount_amount) as Total_Discount, 
ROUND( SUM(discount_amount) *100.0 /(SELECT SUM(market_price) FROM bigbasket) ,2)
AS Discount_Percentage 
FROM bigbasket
GROUP BY product 
ORDER BY Discount_Percentage DESC;

--- 6.Update Table for Dicount_Percentage
UPDATE bigbasket
SET Discount_Percentage = ROUND(
    discount_amount * 100.0 / market_price, 2
);

--- 5. Find products offering the highest discount.
SELECT Product 
FROM bigbasket
ORDER BY Discount_Amount DESC
LIMIT 1;

--- 6. Find products with no discount.
SELECT Product
FROM bigbasket
WHERE discount_amount = 0;

--- 7. Calculate average discount percentage by category.
SELECT category , AVG(Discount_Percentage) 
FROM bigbasket 
GROUP BY category
ORDER BY AVG(Discount_Percentage) DESC;

--- 8. Identify categories offering the highest average discount.
SELECT category , AVG(Discount_Percentage) 
FROM bigbasket 
GROUP BY category
ORDER BY AVG(Discount_Percentage) DESC
LIMIT 1;

--- 9. Find brands offering discounts above 30%.
SELECT brand, SUM(discount_percentage) 
FROM bigbasket
GROUP BY brand
HAVING  SUM(discount_percentage) > 30;

--- 10. Count products with discounts above 20%.
SELECT Discount_Percentage, COUNT(*) 
FROM bigbasket 
GROUP  BY Discount_Percentage
HAVING Discount_Percentage > 20;

---- "Advnace SQL Quiry"

--- 1. 	Rank products by sale price
SELECT product, category , sub_category ,
DENSE_RANK() OVER(PARTITION BY category ORDER BY sale_price desc) AS 'Rank'
FROM bigbasket;

--- 2. Find second-highest-priced product
SELECT MAX(sale_price) 
FROM bigbasket
WHERE sale_price<(
SELECT MAX(sale_price)
FROM bigbasket
);

--- 3. Find top 3 products in each category
WITH Three_Product AS (
SELECT 
product,
category,
DENSE_RANK() OVER( PARTITION BY category ORDER BY sale_price desc)
AS 'Ranker'
FROM bigbasket )
SELECT * 
FROM Three_Product
WHERE Ranker BETWEEN 1 AND 3;

--- 4. Find categories with above-average prices
SELECT category,
sale_price
FROM bigbasket 
WHERE sale_price >(
SELECT AVG(sale_price) 
FROM bigbasket);

--- 5. Calculate Contribution of each Brand in Sales.
SELECT 
Brand,
SUM(sale_Price),
ROUND( SUM(sale_price) * 100.0/ (SELECT SUM(sale_price) FROM bigbasket) ,2) 
AS Contribution 
FROM bigbasket
GROUP BY brand
ORDER BY Contribution DESC;

--- 6. Calculate category-wise price contribution.
SELECT 
category,
SUM(sale_Price),
ROUND( SUM(sale_price) * 100.0/ (SELECT SUM(sale_price) FROM bigbasket) ,2) 
AS Contribution 
FROM bigbasket
GROUP BY category
ORDER BY Contribution DESC;

--- 7. Find the highest discount product in each category
SELECT
ROW_NUMBER() OVER(PARTITION BY category ORDER BY SUM(Discount_Amount) DESC) 
AS 'Rank',
Category,
SUM(Discount_Amount) as Total_Discount
FROM bigbasket
GROUP BY category;

--- 8. Create a product analysis view
CREATE VIEW product_analysis AS
SELECT Product, sale_price, market_price
FROM bigbasket;

--- 9. Create a procedure for category analysis	
DELIMITER // 

     CREATE PROCEDURE category_analysis()
BEGIN
      SELECT category , SUM(sale_price) as Total_Sales
      FROM bigbasket 
      GROUP BY category
      ORDER BY SUM(sale_price);
END //

DELIMITER ;

--- 10. Shifting the location of discount columns after market_price
ALTER TABLE  bigbasket 
MODIFY COLUMN discount_percentage INT
AFTER market_price;

