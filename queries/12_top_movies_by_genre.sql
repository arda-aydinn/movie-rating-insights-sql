-- Question:
-- Which movies occupy the top five average-rating levels within each genre
-- among movies with at least 400 ratings, and how do ROW_NUMBER, RANK,
-- and DENSE_RANK handle ties in these genre-level rankings?

-- Purpose:
-- To identify the highest-rated, sufficiently reviewed movies within each genre,
-- compare genre-specific rankings rather than relying on a single global ranking,
-- and demonstrate how alternative ranking functions treat tied average ratings.

-- General Notes:
-- A minimum threshold of 400 ratings is applied, matching the threshold used
-- in Query 03. This threshold is intentionally reused to maintain methodological
-- consistency and make the global and genre-level movie rankings comparable.

-- Genre normalization follows the methodology established in Query 10.
-- Empty genres and "(no genres listed)" are excluded from the analysis.

-- The analytical grain is one movie-genre combination. Multi-genre movies
-- therefore appear once within each of their associated genres and may rank
-- independently in multiple genre-level lists.

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
),

-- rating_count is used as an eligibility threshold, while avg_rating is used
-- as the ranking metric. The 400-rating threshold is applied before ranking
-- so that low-sample movies do not enter any genre-level leaderboard.

-- A movie's rating_count and avg_rating remain identical across its genre rows;
-- genre membership changes the comparison group, not the underlying ratings.

movieGenreMetricsCTE AS (
SELECT
    cte.movieId,
    cte.genre,
    cte.title,
    COUNT(rat.rating) AS rating_count,
    AVG(rat.rating) AS avg_rating

FROM genreSplitCTE AS cte
JOIN ratings AS rat
    ON cte.movieId = rat.movieId

WHERE cte.genre != ''
  AND cte.genre != '(no genres listed)'

GROUP BY 
    cte.movieId,
    cte.title,
    cte.genre

HAVING COUNT(rat.rating) >= 400

),

-- PARTITION BY genre resets each ranking at 1 within every genre, allowing
-- movies to be compared with genre peers rather than in one global ranking.

-- All three ranking functions use the same unrounded avg_rating ordering so
-- that differences in their outputs arise only from how they handle ties.

-- ROW_NUMBER assigns a unique position to every movie.
-- RANK assigns the same position to tied movies and leaves gaps afterward.
-- DENSE_RANK assigns the same position to tied movies without leaving gaps.

-- Because no secondary tie-breaker is used, ROW_NUMBER may assign tied movies
-- in an arbitrary order. This preserves a pure comparison of tie behavior,
-- while RANK and DENSE_RANK continue to recognize the tie.

movieGenreRankingCTE AS (
    SELECT
        movieId,
        genre,
        title,
        rating_count,
        avg_rating,

        ROW_NUMBER() OVER(
            PARTITION BY genre
            ORDER BY avg_rating DESC
        ) AS row_number_position,

        RANK() OVER(
            PARTITION BY genre
            ORDER BY avg_rating DESC
        ) AS rank_position,

        DENSE_RANK() OVER(
            PARTITION BY genre
            ORDER BY avg_rating DESC
        ) AS dense_rank_position

    FROM movieGenreMetricsCTE
)

-- Rankings are calculated using unrounded average ratings. Average ratings are
-- rounded only in the final output to avoid creating artificial ties.

-- The final filter uses DENSE_RANK <= 5, retaining the top five distinct
-- average-rating levels within each genre. Exact ties may therefore cause
-- more than five movies to appear for a genre.

SELECT
    movieId,
    genre,
    title,
    rating_count,
    ROUND(avg_rating, 4) AS avg_rating,
    row_number_position,
    rank_position,
    dense_rank_position

FROM movieGenreRankingCTE
WHERE dense_rank_position <= 5
ORDER BY
    genre,
    row_number_position
;
