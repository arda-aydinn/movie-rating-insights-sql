-- Question:
-- How did rating volume and average rating change year over year,
-- and which years experienced the largest shifts?

-- Purpose:
-- To measure both absolute and relative year-over-year changes in rating
-- activity and average rating, allowing the years with the largest shifts
-- to be identified.

-- General Notes:
-- The year is derived from each rating record's timestamp. It therefore
-- represents the year in which the rating was submitted, not the movie's
-- release year.

-- total_ratings measures annual rating activity within the loaded MovieLens
-- sample.

-- percentage represents each year's share of all rating records in the
-- analyzed sample. It does not represent an average rating or a proportion
-- of users.

-- Because the total number of ratings used as the denominator is constant,
-- percentage_change is equivalent to the relative year-over-year change in
-- annual rating volume.

-- LAG compares each year with the immediately preceding year available in
-- the dataset. The first observed year therefore has NULL previous-year
-- values and NULL change metrics.

-- The output is ordered chronologically. The largest shifts can be identified
-- by comparing the absolute sizes of rating_change, avg_rating_change, and
-- percentage_change; the query does not assign formal shift rankings.

-- Initial Yearly Overview:
-- This exploratory query was used to inspect annual rating volume and average
-- rating before calculating year-over-year changes.

/* SELECT
    STRFTIME('%Y', timestamp) AS year,
    COUNT(*) AS total_ratings,
    ROUND(AVG(rating), 2) AS avg_rating
FROM ratings
GROUP BY year
; */

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
ORDER BY year
;
