--  Question:
--  Which movies have the highest average rating among movies with a substantial number of ratings?

-- Purpose:
-- To identify highly rated movies while reducing the effect of very small sample sizes.

-- Notes:
-- A data-driven minimum rating threshold is used to reduce the small sample problem and make average ratings more reliable.


---- Exploratory query for selecting the threshold:
---- Calculate the average rating count among movies with at least 100 ratings.


WITH movie_rating_counts AS    
    (SELECT 
            mov.movieId, 
            mov.title, 
            COUNT(rat.rating) AS no_ratings

        FROM movies AS mov
        INNER JOIN ratings AS rat
            ON mov.movieId = rat.movieId

        GROUP BY mov.movieId, mov.title
        HAVING COUNT(rat.rating) >= 100 
        )

SELECT AVG(no_ratings) AS avg_rating_count
FROM movie_rating_counts
;

---- Final query
SELECT 
    mov.movieId, 
    mov.title,
    COUNT(rat.rating) AS no_ratings,
    ROUND(AVG(rat.rating), 2) AS avg_rating
FROM movies AS mov
INNER JOIN ratings AS rat
    ON mov.movieId = rat.movieId
GROUP BY mov.movieId, mov.title
HAVING COUNT(rat.rating) >= 400
ORDER BY avg_rating DESC
LIMIT 20
;