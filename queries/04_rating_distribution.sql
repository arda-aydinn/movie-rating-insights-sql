-- Question:
-- Part A:
-- How are individual rating values distributed?

-- Part B:
-- How are ratings distributed across low, moderate, and high rating categories?

-- Purpose:
-- To understand overall user rating behavior and identify whether users tend to give low, moderate, or high ratings.

WITH rcountCTE AS (
SELECT 
    rating, 
    COUNT(movieId) AS rating_count
FROM ratings
GROUP BY rating
ORDER BY rating 
)

--SELECT *
--FROM rcountCTE; --> this is for checking our CTE and 
--                    continuing with this information

SELECT 
    (CASE
        WHEN rating >= 0.5 AND rating <= 2.0 THEN "0.5 - 2.0"
        WHEN rating >= 2.5 AND rating <= 3.5 THEN "2.5 - 3.5"
        WHEN rating >= 4.0 AND rating <= 5.0 THEN "4.0 - 5.0"
    END) AS interval,

    SUM(rating_count) AS rating_count,

   (CASE 
        WHEN rating >= 0.5 AND rating <= 2.0 THEN "Low"
        WHEN rating >= 2.5 AND rating <= 3.5 THEN "Moderate"
        WHEN rating >= 4.0 AND rating <= 5.0 THEN "High"
    END) AS class,

    ROUND(
        SUM(rating_count) * 100.0
        / (SELECT SUM(rating_count) FROM rcountCTE),
        2
        ) AS total_percentage

FROM rcountCTE
GROUP BY interval, class
;
