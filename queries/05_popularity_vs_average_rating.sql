-- Question:
-- How do average rating and rating volume compare across movies, and which
-- frequently rated movies also receive strong audience approval?

-- Purpose:
-- To compare movie-level audience approval with rating activity and distinguish
-- average rating quality from sample-based popularity.

-- General Notes:
-- The analysis grain is one movie.

-- avg_rating represents audience approval, while rating_count represents the
-- volume of rating activity within the analyzed MovieLens sample.

-- rating_count is used as a proxy for sample-based popularity and does not
-- directly measure real-world viewership or commercial success.

-- This is a descriptive comparison rather than a formal statistical test of
-- association between average rating and popularity.

WITH movieMetricsCTE AS (
    SELECT
        mov.movieId,
        mov.title,
        COUNT(*) AS rating_count,
        AVG(rat.rating) AS avg_rating

    FROM ratings AS rat
    JOIN movies AS mov
        ON rat.movieId = mov.movieId

    GROUP BY
        mov.movieId,
        mov.title
)

SELECT
    movieId,
    title,
    rating_count,
    ROUND(avg_rating, 4) AS avg_rating

FROM movieMetricsCTE

ORDER BY
    rating_count DESC,
    avg_rating DESC,
    movieId ASC
;


/*
-- Validation:
-- Recalculate each movie's average rating manually using the frequency of
-- individual rating values as weights. The result should match AVG(rating).

WITH movieRatingFrequencyCTE AS (
    SELECT
        mov.movieId,
        mov.title,
        rat.rating,
        COUNT(*) AS rating_frequency

    FROM ratings AS rat
    JOIN movies AS mov
        ON rat.movieId = mov.movieId

    GROUP BY
        mov.movieId,
        mov.title,
        rat.rating
)

SELECT
    movieId,
    title,

    ROUND(SUM(rating * rating_frequency) * 1.0
        / SUM(rating_frequency), 4) AS manually_calculated_avg_rating,

    SUM(rating_frequency) AS rating_count

FROM movieRatingFrequencyCTE

GROUP BY
    movieId,
    title

ORDER BY
    rating_count DESC,
    manually_calculated_avg_rating DESC,
    movieId ASC
;
*/