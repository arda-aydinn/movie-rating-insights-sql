-- Question:
-- Which movies received the highest number of ratings in the analyzed sample?

-- Purpose:
-- To identify the movies with the greatest rating activity and use rating count
-- as a sample-based proxy for popularity.

-- General Notes:
-- rating_count measures the number of rating records associated with each movie.
-- It reflects visibility within the analyzed MovieLens sample rather than
-- real-world viewership, box-office performance, or audience approval.

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

ORDER BY
    rating_count DESC,
    mov.movieId ASC

LIMIT 20
;