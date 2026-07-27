-- Question:
-- How can repeated movie-level rating logic be centralized in a reusable SQL view?

-- Purpose:
-- To create a reusable and consistent movie-level metrics layer that centralizes
-- commonly used calculations, reduces repeated query logic, and supports
-- subsequent analyses from a single standardized data source.

-- General Notes:
-- The view uses one movie as its analytical grain, so each movieId should
-- appear exactly once.

-- An INNER JOIN intentionally limits the view to movies with at least one
-- rating, since rating_count and avg_rating cannot be calculated for unrated movies.

-- DROP VIEW IF EXISTS allows this script to be rerun safely when the view
-- definition is updated.

DROP VIEW IF EXISTS vw_movie_rating_metrics
;

-- The view stores reusable movie-level metrics without analysis-specific
-- thresholds, rankings, or filters. These decisions are left to downstream queries.

-- Aggregate values retain their full precision in the view; rounding is applied
-- only in final analytical outputs.

CREATE VIEW vw_movie_rating_metrics AS
SELECT
    mov.movieId,
    mov.title,
    mov.genres,
    COUNT(rat.rating) AS rating_count,
    AVG(rat.rating) AS avg_rating

FROM movies AS mov
JOIN ratings AS rat
    ON mov.movieId = rat.movieId
GROUP BY
    mov.movieId,
    mov.title,
    mov.genres
;

-- Validation 1: Inspect the highest-volume movies and compare their metrics
-- with results from earlier analyses.

SELECT
    movieId,
    title,
    genres,
    rating_count,
    avg_rating

FROM vw_movie_rating_metrics
ORDER BY rating_count DESC
LIMIT 10
;

-- Validation 2: Confirm the one-movie grain by verifying that the total row
-- count equals the number of distinct movieIds.

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT movieId) AS unique_movies
FROM vw_movie_rating_metrics
;