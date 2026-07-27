-- Question:
-- Which movies combine unusually high audience approval with below-mainstream
-- visibility, using percentile-based measures rather than fixed raw-score cutoffs?

-- Purpose:
-- To identify movies that combine strong audience approval with relatively
-- limited visibility using distribution-based measures, while excluding titles
-- without enough rating support to be meaningfully compared.

-- General Notes:
-- rating_count is treated as a proxy for visibility within the analyzed
-- MovieLens sample; it does not directly measure real-world viewership,
-- box-office performance, or general public recognition.

-- Movies with no ratings are excluded because audience approval and visibility
-- cannot be estimated for them within the analyzed sample.

WITH movieMetricsCTE AS (
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
),

-- A pragmatic minimum support threshold of 50 ratings was selected after
-- comparing several candidate thresholds. This retained 3,187 movies while
-- excluding titles supported by very small rating samples.

/*

-- Validation query used to compare alternative minimum support thresholds.
SELECT
    COUNT(CASE
        WHEN rating_count >= 10 THEN 1
          END) AS _10_rated_movies,

    COUNT(CASE
        WHEN rating_count >= 25 THEN 1
          END) AS _25_rated_movies,

    COUNT(CASE
        WHEN rating_count >= 50 THEN 1
          END) AS _50_rated_movies,

    COUNT(CASE
        WHEN rating_count >= 100 THEN 1
          END) AS _100_rated_movies,

    COUNT(CASE
        WHEN rating_count >= 200 THEN 1
          END) AS _200_rated_movies,

    COUNT(CASE
        WHEN rating_count >= 400 THEN 1
          END) AS _400_rated_movies

FROM movieMetricsCTE
*/

eligibleMoviesCTE AS (
    SELECT 
        movieId,
        title,
        genres,
        rating_count,
        avg_rating

    FROM movieMetricsCTE
    WHERE rating_count >= 50
),

-- PERCENT_RANK assigns identical percentile positions to tied metric values.
-- As a result, percentile thresholds may retain slightly more or fewer movies
-- than the nominal percentage boundaries suggest.

-- Quality and visibility percentiles are calculated globally across all
-- eligible movies rather than separately within genres. The results therefore
-- represent platform-wide relative positions.

moviePercentilesCTE AS (
    SELECT
        movieId,
        title,
        genres,
        rating_count,
        avg_rating,

        PERCENT_RANK() OVER(
            ORDER BY avg_rating ASC
        ) AS quality_percent_rank,

        PERCENT_RANK() OVER (
            ORDER BY rating_count ASC
        ) AS visibility_percent_rank

    FROM eligibleMoviesCTE
),


-- Sensitivity Check to Determine Percentiles
/* SELECT
    COUNT(CASE
        WHEN quality_percent_rank >= 0.80 
        AND visibility_percent_rank <= 0.40
        THEN 1
    END) AS wide_hidden_gem_count,

    COUNT(CASE
        WHEN quality_percent_rank >= 0.85 
        AND visibility_percent_rank <=0.35
        THEN 1
    END) AS balanced_hidden_gem_count,

    COUNT(CASE
        WHEN quality_percent_rank >= 0.90 
        AND visibility_percent_rank <=0.30
        THEN 1
    END) AS strict_hidden_gem_count

FROM moviePercentilesCTE */

-- A sensitivity check compared three percentile-based definitions:
-- wide (80th/40th), balanced (85th/35th), and strict (90th/30th).
-- The balanced definition was selected because it retained a sufficiently
-- diverse candidate pool while maintaining strong quality and limited-
-- visibility requirements.


-- quality_visibility_gap is an interpretable heuristic defined as the
-- difference between quality and visibility percentile positions. It is used
-- to order eligible candidates, not as a validated predictive score.

hiddenGemsCTE AS (
    SELECT
        movieId,
        title,
        genres,
        rating_count,
        avg_rating,
        quality_percent_rank,
        visibility_percent_rank,

        quality_percent_rank - visibility_percent_rank AS quality_visibility_gap
    
    FROM moviePercentilesCTE

    WHERE
        quality_percent_rank >= 0.85
        AND
        visibility_percent_rank <= 0.35
)

SELECT
    movieId,
    title,
    genres,
    rating_count,
    ROUND(avg_rating, 4) AS avg_rating,
    ROUND(quality_percent_rank, 4) AS quality_percent_rank,
    ROUND(visibility_percent_rank, 4) AS visibility_percent_rank,
    ROUND(quality_visibility_gap, 4) AS quality_visibility_gap
    
FROM hiddenGemsCTE AS hg
ORDER BY
    hg.quality_visibility_gap DESC,
    hg.quality_percent_rank DESC,
    hg.visibility_percent_rank ASC,
    hg.avg_rating DESC,
    hg.rating_count ASC,
    hg.title ASC,
    hg.movieId ASC
;