-- Question:
-- Which movies have the highest average ratings among titles with sufficient
-- rating support in the analyzed sample?

-- Purpose:
-- To identify strongly rated movies while reducing the influence of unstable
-- averages based on very small rating samples.

-- General Notes:
-- A minimum threshold of 400 ratings is applied as a pragmatic support
-- requirement. The threshold was informed by an exploratory calculation of
-- rating activity among movies with at least 100 ratings.

-- rating_count is used as an eligibility condition, while avg_rating is the
-- movie-ranking metric. Rankings use unrounded averages; rounding is applied
-- only in the final output.

 /*
-- Exploratory query used to inform the minimum support threshold.

WITH movieRatingCountsCTE AS (
    SELECT
        mov.movieId,
        mov.title,
        COUNT(rat.rating) AS rating_count

    FROM movies AS mov
    JOIN ratings AS rat
        ON mov.movieId = rat.movieId

    GROUP BY
        mov.movieId,
        mov.title

    HAVING COUNT(rat.rating) >= 100
)

SELECT
    AVG(rating_count) AS avg_rating_count
FROM movieRatingCountsCTE
;
*/

WITH movieMetricsCTE AS (
    SELECT
        mov.movieId,
        mov.title,
        COUNT(rat.rating) AS rating_count,
        AVG(rat.rating) AS avg_rating

    FROM movies AS mov
    JOIN ratings AS rat
        ON mov.movieId = rat.movieId

    GROUP BY
        mov.movieId,
        mov.title

    HAVING COUNT(rat.rating) >= 400
)

SELECT
    movieId,
    title,
    rating_count,
    ROUND(avg_rating, 4) AS avg_rating

FROM movieMetricsCTE

ORDER BY
    avg_rating DESC,
    rating_count DESC,
    movieId ASC

LIMIT 20
;