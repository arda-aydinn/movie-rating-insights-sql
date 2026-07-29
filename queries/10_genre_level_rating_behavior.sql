-- Question:
-- How do genres differ in audience reach, rating volume, average rating, and high-rating frequency, and which 
-- genres receive the strongest audience evaluations?

-- Purpose:
-- To normalize the multi-valued genre field into a usable movie–genre structure and compare genres by rated-movie
-- coverage, unique audience reach, rating volume, rating-weighted average score, and the share of ratings between
-- 4.0 and 5.0.

-- Data quality check: count movies with missing genre metadata.
SELECT
    COUNT(*) AS no_genre_listed_rows
FROM movies
WHERE genres = '(no genres listed)'
;

SELECT
    COUNT(*) AS null_genre_rows
FROM movies
WHERE genres IS NULL
;
-- Result: 246 movies had missing genre metadata.
-- The missing values were represented by "(no genres listed)", not SQL NULL.
-- Only 5 of these movies received ratings in the analyzed rating sample.


WITH RECURSIVE genreSplitCTE(
        movieId,
        title,
        genre,
        remaining_text
) AS (
    SELECT
        movieId,
        title,
        '' AS genre,
        genres || '|' AS remaining_text
    FROM movies

    UNION ALL

    SELECT
        movieId,
        title,

        SUBSTR(
            remaining_text,
            1,
            INSTR(remaining_text, '|') -1
        ) AS genre,

        SUBSTR(
            remaining_text,
            INSTR(remaining_text, '|') + 1
        ) AS remaining_text

    FROM genreSplitCTE
    WHERE remaining_text != ''
)

SELECT 
    cte.genre,

    COUNT(DISTINCT cte.movieId) AS rated_movies,
    COUNT(DISTINCT rat.userId) AS unique_users,
    COUNT(rat.rating) AS total_ratings,
    ROUND(AVG(rat.rating), 2) AS avg_rating,

-- High ratings were defined as scores between 4.0 and 5.0,
-- consistent with the threshold used in Query 09.

    SUM(CASE
        WHEN rat.rating BETWEEN 4.0 AND 5.0 
            THEN 1
            ELSE 0
        END) AS total_high_ratings,

    ROUND(AVG(CASE
          WHEN rat.rating BETWEEN 4.0 AND 5.0 
              THEN 1
              ELSE 0
          END) * 100.0, 2) AS high_rating_pct

    
FROM genreSplitCTE AS cte
JOIN ratings AS rat
    ON cte.movieId = rat.movieId
WHERE cte.genre != ''
  AND cte.genre != '(no genres listed)'
GROUP BY 
    cte.genre
ORDER BY 
    AVG(rat.rating) DESC,
    total_ratings DESC
;

-- Movies labeled "(no genres listed)" were excluded because this value
-- represents missing genre metadata rather than an actual genre.

-- Average ratings and high-rating percentages were calculated across individual
-- rating records. Therefore, frequently rated movies contribute more weight to
-- genre-level results than sparsely rated movies.

-- Because the analysis uses an inner join with ratings, rated_movies includes
-- only movies that received at least one rating in the analyzed sample.

-- Ratings for multi-genre movies contribute to each associated genre.
-- Therefore, genre-level rating totals are not mutually exclusive and their
-- combined total may exceed the number of rating records in the dataset.