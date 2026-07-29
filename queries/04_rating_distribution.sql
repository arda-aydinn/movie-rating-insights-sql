-- Question:
-- Part A:
-- How are individual rating values distributed across the analyzed sample?

-- Part B:
-- What share of rating activity falls into low, moderate, and high
-- rating categories?

-- Purpose:
-- To examine the distribution of individual rating values and summarize
-- rating activity into interpretable low, moderate, and high categories.

-- General Notes:
-- The analysis is weighted at the rating-record level rather than the user
-- level. Users who submitted more ratings therefore contribute more heavily
-- to the overall distribution.

-- The categories are analyst-defined as:
-- Low: 0.5–2.0
-- Moderate: 2.5–3.5
-- High: 4.0–5.0

-- Part A: Distribution of individual rating values.

SELECT
    rating,
    COUNT(*) AS rating_count,

    ROUND(COUNT(*) * 100.0
         / SUM(COUNT(*)) OVER (), 2) AS total_percentage

FROM ratings

GROUP BY rating

ORDER BY rating
;


-- Part B: Distribution across grouped rating categories.

WITH categorizedRatingsCTE AS (
    SELECT
        CASE
            WHEN rating BETWEEN 0.5 AND 2.0 THEN '0.5 - 2.0'
            WHEN rating BETWEEN 2.5 AND 3.5 THEN '2.5 - 3.5'
            WHEN rating BETWEEN 4.0 AND 5.0 THEN '4.0 - 5.0'
        END AS rating_interval,

        CASE
            WHEN rating BETWEEN 0.5 AND 2.0 THEN 'Low'
            WHEN rating BETWEEN 2.5 AND 3.5 THEN 'Moderate'
            WHEN rating BETWEEN 4.0 AND 5.0 THEN 'High'
        END AS rating_class,

        CASE
            WHEN rating BETWEEN 0.5 AND 2.0 THEN 1
            WHEN rating BETWEEN 2.5 AND 3.5 THEN 2
            WHEN rating BETWEEN 4.0 AND 5.0 THEN 3
        END AS class_order

    FROM ratings
)

SELECT
    rating_interval,
    rating_class,
    COUNT(*) AS rating_count,

    ROUND(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (),
        2
    ) AS total_percentage

FROM categorizedRatingsCTE

GROUP BY
    rating_interval,
    rating_class,
    class_order

ORDER BY class_order
;