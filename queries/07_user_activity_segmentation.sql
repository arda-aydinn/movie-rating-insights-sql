-- Question:
-- How are users distributed across activity segments, and how much of the total
-- rating activity does each segment generate? How do fixed thresholds
-- compare with distribution-based segments?

-- Purpose:
-- To examine how users are distributed across different activity levels and
-- determine how much of the analyzed sample's total rating volume each segment
-- contributes. The analysis also compares fixed activity thresholds with
-- distribution-based segmentation.

-- General Notes:
-- The analysis grain is one user. Each user's activity level is measured by
-- the number of rating records associated with that user in the analyzed sample.

-- In the distribution-based analysis, activity_quartile 1 represents the
-- least active users and activity_quartile 4 represents the most active users.

-- NTILE creates approximately equal-sized user groups based on relative
-- position, whereas fixed thresholds create interpretable activity ranges
-- whose group sizes are allowed to differ.

-- Both approaches are compared descriptively through user shares, rating
-- shares, and ratings-per-user statistics; no formal similarity measure is
-- calculated between the two segmentation systems.

-- The fixed thresholds cover all 6,743 users in the current analysis sample.


-- Distribution-Based Segmentation

WITH mainCTE AS (
    SELECT 
        userId, 
        COUNT(*) AS total_ratings
    FROM ratings
    GROUP BY userId
),

quartileCTE AS (
    SELECT
        *,
        NTILE(4) OVER(
            ORDER BY total_ratings
        ) AS activity_quartile
    FROM mainCTE
)

SELECT  
    activity_quartile,

    COUNT(*) AS total_users,
    ROUND(COUNT(*) * 100.0 / 
          SUM(COUNT(*)) OVER(), 2) AS user_share_pct,

    MIN(total_ratings) AS min_ratings_per_user,
    MAX(total_ratings) AS max_ratings_per_user,
    ROUND(AVG(total_ratings), 2) AS avg_ratings_per_user,
    SUM(total_ratings) AS total_ratings_generated,

    ROUND(SUM(total_ratings) * 100.0 / 
          SUM(SUM(total_ratings)) OVER(), 2) AS rating_share_pct

FROM quartileCTE
GROUP BY activity_quartile
ORDER BY activity_quartile
;


-- Fixed thresholds were selected after examining user-level rating counts
-- and quartile boundaries. Rounded, interpretable cutoffs were used instead
-- of directly reproducing the NTILE groups.
-- Fixed thresholds: Low = 20–50, Medium = 51–150, High = 151+.
-- NTILE balances the number of users across groups, so identical rating
-- counts may be split between adjacent quartiles.


-- Fixed-Threshold Segmentation

WITH mainCTE AS (
    SELECT 
        userId, 
        COUNT(*) AS total_ratings
    FROM ratings
    GROUP BY userId
),

segmentationCTE AS (
    SELECT 
        *,
    CASE 
        WHEN total_ratings >= 20 AND total_ratings <= 50 THEN 'Low Activity'
        WHEN total_ratings >= 51 AND total_ratings <= 150 THEN 'Medium Activity'
        WHEN total_ratings >= 151 THEN 'High Activity'
    END AS activity_segment

    FROM mainCTE
)

SELECT 
    activity_segment,

    COUNT(*) AS total_users,
    ROUND(COUNT(*) * 100.0 / 
          SUM(COUNT(*)) OVER(), 2) AS user_share_pct,

    SUM(total_ratings) AS total_ratings_generated,
    ROUND(SUM(total_ratings) * 100.0 /
          SUM(SUM(total_ratings)) OVER(), 2) AS rating_share_pct,

    ROUND(AVG(total_ratings), 2) AS avg_ratings_per_user

FROM segmentationCTE
GROUP BY activity_segment
ORDER BY total_ratings_generated
;