-- Question:
-- How can rating quality and popularity be normalized using percentile-based
-- measures and combined into a movie score, and how sensitive are rankings
-- to different weighting choices?

-- Purpose:
-- To combine audience approval and popularity into a normalized movie score,
-- examine how different weighting choices affect movie rankings, and evaluate
-- the sensitivity of those rankings to methodological decisions.

-- A minimum support threshold of 50 ratings is applied before normalization.
-- This threshold follows the sensitivity analysis conducted in Query 13 and
-- reduces the influence of unstable averages based on very small samples.

WITH eligibleMoviesCTE AS (
    SELECT
        movieId,
        title,
        genres,
        rating_count,
        avg_rating

    FROM vw_movie_rating_metrics
    WHERE rating_count >= 50
),

-- Expected eligible movie count: 3,187.

-- Quality is represented by avg_rating, while popularity is represented by
-- rating_count within the analyzed MovieLens sample.

-- PERCENT_RANK places both measures on a comparable 0–1 scale. Higher values
-- indicate stronger audience approval or greater rating activity.

-- Percentile normalization preserves relative ordering but does not preserve
-- the magnitude of the original differences between movies.

percentileCTE AS (
    SELECT
        movieId,
        title,
        genres,

        rating_count,

        PERCENT_RANK() OVER(
            ORDER BY rating_count ASC
        ) AS popularity_percent_rank,

        avg_rating,

        PERCENT_RANK() OVER(
            ORDER BY avg_rating ASC
        ) AS quality_percent_rank

    FROM eligibleMoviesCTE
),

-- Three illustrative weighting scenarios are evaluated:
-- balanced assigns equal importance to quality and popularity;
-- quality-focused assigns 70% to quality and 30% to popularity;
-- popularity-focused applies the reverse weighting.

-- The weights are methodological scenarios used for sensitivity analysis;
-- they are not statistically estimated or externally validated.

weightingScenarioCTE AS (
    SELECT
        movieId,
        title,
        genres,

        rating_count,
        popularity_percent_rank,

        avg_rating,
        quality_percent_rank,

        popularity_percent_rank * 0.5 + quality_percent_rank * 0.5 AS balanced_score,
        popularity_percent_rank * 0.3 + quality_percent_rank * 0.7 AS quality_focused_score,
        popularity_percent_rank * 0.7 + quality_percent_rank * 0.3 AS popularity_focused_score

    FROM percentileCTE
),

-- DENSE_RANK assigns identical, gap-free positions to movies with equal
-- unrounded combined scores. Rankings are calculated before presentation
-- rounding to avoid artificial ties.

rankingCTE AS (
    SELECT
        movieId,
        title,
        genres,

        rating_count,
        popularity_percent_rank,

        avg_rating,
        quality_percent_rank,

        balanced_score,
        quality_focused_score,
        popularity_focused_score,

        DENSE_RANK() OVER(
            ORDER BY balanced_score DESC
        ) AS balanced_position,

        DENSE_RANK() OVER(
            ORDER BY quality_focused_score DESC
        ) AS quality_focused_position,

        DENSE_RANK() OVER(
            ORDER BY popularity_focused_score DESC
        ) AS popularity_focused_position

    FROM weightingScenarioCTE
)

-- Because DENSE_RANK is used, rank_spread compares gap-free rank levels rather
-- than absolute row positions. Tied scores therefore compress the ranking scale.

-- rank_spread is the difference between a movie's worst and best numeric
-- position across the three weighting scenarios. Larger values indicate
-- greater sensitivity to the selected quality-popularity weighting.

-- rank_spread summarizes movie-level instability; it is not a formal measure
-- of overall agreement between the complete ranking lists.

SELECT
        movieId,
        title,
        genres,

        rating_count,
        ROUND(popularity_percent_rank, 4) AS popularity_percent_rank,

        ROUND(avg_rating, 4) AS avg_rating,
        ROUND(quality_percent_rank, 4) AS quality_percent_rank,

        ROUND(balanced_score, 4) AS balanced_score,
        ROUND(quality_focused_score, 4) AS quality_focused_score,
        ROUND(popularity_focused_score, 4) AS popularity_focused_score,
        
        balanced_position,
        quality_focused_position,
        popularity_focused_position,

    MAX(
        balanced_position,
        quality_focused_position,
        popularity_focused_position
    )
    -
    MIN(
        balanced_position,
        quality_focused_position,
        popularity_focused_position
    ) AS rank_spread

FROM rankingCTE

ORDER BY
    balanced_position ASC,
    quality_focused_position ASC,
    popularity_focused_position ASC,
    title ASC,
    movieId ASC
;
