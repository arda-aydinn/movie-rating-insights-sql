-- Question:
-- Which genres rank highest under different definitions of popularity,
-- and how consistent are those rankings across genres?

-- Purpose:
-- To compare genre popularity using total rating volume, unique audience reach,
-- rated-movie coverage, and ratings per movie, and quantify how much each
-- genre's rank changes across these definitions.

-- Genre normalization and missing-metadata handling follow the methodology
-- established in Query 10. Empty genres and "(no genres listed)" are excluded.

WITH RECURSIVE genreSplitCTE(
        movieId,
        genre,
        remaining_text
) AS (
    SELECT
        movieId,
        '' AS genre,
        genres || '|' AS remaining_text
    FROM movies

    UNION ALL

    SELECT
        movieId,

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
),

-- Popularity is evaluated using four complementary measures:
-- total_ratings represents overall interaction volume;
-- unique_users represents audience reach;
-- rated_movies represents rated catalog coverage;
-- ratings_per_movie represents average attention per rated movie.

-- Because ratings are joined using an inner join, rated_movies includes only
-- movies that received at least one rating in the analyzed sample.

-- Ratings for multi-genre movies contribute to every associated genre.
-- Therefore, genre-level totals are not mutually exclusive and cannot be
-- summed to recover the dataset-wide rating total.

genrePopularityCTE AS (
SELECT
    cte.genre,
    COUNT(rat.rating) AS total_ratings,
    COUNT(DISTINCT rat.userId) AS unique_users,
    COUNT(DISTINCT cte.movieId) AS rated_movies,
    COUNT(rat.rating) * 1.0 / COUNT(DISTINCT cte.movieId) AS ratings_per_movie

FROM genreSplitCTE AS cte
JOIN ratings AS rat
    ON cte.movieId = rat.movieId

WHERE cte.genre != ''
  AND cte.genre != '(no genres listed)'
GROUP BY cte.genre
),

-- Higher values indicate greater popularity for all four measures, so rankings
-- are calculated in descending order. DENSE_RANK is used to assign equal,
-- gap-free ranks to genres with identical metric values.

-- Rankings are calculated using unrounded metric values. Ratings per movie is
-- rounded only in the final output to avoid creating artificial ties.

genreRankingCTE AS (
    SELECT
        genre,
        
        total_ratings,
        DENSE_RANK() OVER(
            ORDER BY total_ratings DESC
        ) AS total_ratings_rank,

        unique_users,
        DENSE_RANK() OVER(
            ORDER BY unique_users DESC
        ) AS unique_users_rank,

        rated_movies,
        DENSE_RANK() OVER(
            ORDER BY rated_movies DESC
        ) AS rated_movies_rank,

        ratings_per_movie,
        DENSE_RANK() OVER(
            ORDER BY ratings_per_movie DESC
        ) AS ratings_per_movie_rank
        
    FROM genrePopularityCTE
)

-- ranking_spread is the difference between a genre's highest and lowest numeric
-- rank across the four popularity measures. A value of 0 indicates complete
-- agreement, while larger values indicate greater dependence on the chosen
-- definition of popularity.

-- ranking_spread summarizes disagreement for each genre but is not a formal
-- statistical measure of overall similarity between the complete rankings.

SELECT
    genre,
    total_ratings,
    total_ratings_rank,
    unique_users,
    unique_users_rank,
    rated_movies,
    rated_movies_rank,
    ROUND(ratings_per_movie, 2) AS ratings_per_movie,
    ratings_per_movie_rank,

    MAX(
        total_ratings_rank,
        unique_users_rank,
        rated_movies_rank,
        ratings_per_movie_rank
    )
    -
    MIN(
        total_ratings_rank,
        unique_users_rank,
        rated_movies_rank,
        ratings_per_movie_rank
    ) AS ranking_spread

FROM genreRankingCTE
ORDER BY total_ratings_rank, genre
;