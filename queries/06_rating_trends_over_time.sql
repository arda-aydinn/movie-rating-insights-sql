-- Question:
-- How did rating volume and average rating change year over year,
-- and which years experienced the largest shifts?

-- Purpose:
-- To measure both absolute and relative year-over-year changes in rating
-- activity and average rating, allowing the years with the largest shifts
-- to be identified.

-- Initial Yearly Overview
SELECT
    STRFTIME('%Y', timestamp) AS year,
    COUNT(*) AS total_ratings,
    ROUND(AVG(rating), 2) AS avg_rating
FROM ratings
GROUP BY year
;

-- Year-over-Year Change Analysis

WITH ratingsByYearCTE AS (
        SELECT
            STRFTIME('%Y', timestamp) AS year,
            COUNT(*) AS total_ratings,

            AVG(rating) AS avg_rating,
            
            ( COUNT(*) * 100.0) / (SELECT 
                                COUNT(*)
                                FROM ratings ) AS percentage

        FROM ratings
        GROUP BY year
),

previousYearCTE AS (
    SELECT
    year,
    total_ratings,
    avg_rating,
    percentage,

    LAG(total_ratings) OVER(
        ORDER BY year
    ) AS previous_total_ratings,

    LAG(avg_rating) OVER(
        ORDER BY year
    ) AS previous_avg_rating,

    LAG(percentage) OVER(
        ORDER BY year
    ) AS previous_percentage

    FROM ratingsByYearCTE

)

SELECT 
    year,
    total_ratings,
    previous_total_ratings,
    ROUND(avg_rating,2) AS avg_rating,
    ROUND(previous_avg_rating, 2) AS previous_avg_rating,
    ROUND(percentage, 2) AS percentage,
    ROUND(previous_percentage, 2) AS previous_percentage,

    total_ratings 
    -
    previous_total_ratings AS rating_change,

    ROUND(avg_rating
          -
          previous_avg_rating, 2) AS avg_rating_change,

    ROUND( (percentage
           -
           previous_percentage) / previous_percentage * 100.0, 2) AS percentage_change

FROM previousYearCTE
;
