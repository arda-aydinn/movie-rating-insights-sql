-- Question:
-- Do highly rated movies also tend to be the most frequently rated movies?

-- Purpose: Examine whether highly rated movies are also widely rated, 
--          distinguishing audience approval from popularity.

SELECT
    mov.movieId,
    mov.title,
    ROUND (AVG(rat.rating), 2) AS avg_rating_score,
    COUNT(*) AS total_ratings

FROM ratings AS rat
JOIN movies AS mov
    ON rat.movieId = mov.movieId
GROUP BY mov.movieId, mov.title
ORDER BY total_ratings DESC
;


-- Validation: Recalculate the average rating manually
--             using rating frequencies as weights.

WITH highly_rated_movCTE AS (
        SELECT 
                mov.movieId,
                mov.title, 
                rat.rating, 
                COUNT(*) AS total_votes
        FROM ratings AS rat
        JOIN movies AS mov
            ON mov.movieId = rat.movieId
        GROUP BY mov.movieId, mov.title, rat.rating
)

--SELECT * FROM highly_rated_movCTE;

SELECT 
    movieId,
    title, 
    ROUND( 
        (SUM(rating * total_votes) * 1.0 
        / SUM(total_votes)), 2) AS avg_rank_score,

    SUM(total_votes) AS total_no_ratings

FROM highly_rated_movCTE
GROUP BY movieId, title
ORDER BY 
    total_no_ratings DESC
;