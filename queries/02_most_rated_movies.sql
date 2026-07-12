-- Question:
-- Which movies received the highest number of ratings?

-- Purpose:
-- To identify the most frequently rated movies and use rating count as a proxy for popularity.

-- Notes:
-- This query measures popularity, not necessarily perceived quality. A movie can be highly rated by many users or simply widely watched.

SELECT mov.movieId, mov.title, COUNT(rating) AS no_ratings
FROM movies AS mov
INNER JOIN ratings AS rat
    ON mov.movieId = rat.movieId
GROUP BY mov.movieId, mov.title
ORDER BY no_ratings DESC
LIMIT 20
;


--with CTE
WITH rating_counts AS (
    SELECT
        movieId,
        COUNT(*) AS no_ratings
    FROM ratings
    GROUP BY movieId
)

SELECT
    mov.movieId,
    mov.title,
    rc.no_ratings
FROM movies AS mov
INNER JOIN rating_counts AS rc
    ON mov.movieId = rc.movieId
ORDER BY rc.no_ratings DESC
LIMIT 20;

--with LEFT JOIN to see the table with null values (movies with no ratings)
SELECT
    mov.movieId,
    mov.title,
    COUNT(rat.rating) AS no_ratings
FROM movies AS mov
LEFT JOIN ratings AS rat
    ON mov.movieId = rat.movieId
GROUP BY mov.movieId, mov.title
ORDER BY no_ratings DESC
LIMIT 20;