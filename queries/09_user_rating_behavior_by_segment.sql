-- Question:
-- How do users in different activity segments differ in their average rating behavior
-- and their tendencies to give low, high, and extreme scores?

-- Purpose:
-- To compare how users from different activity segments use the rating scale, 
-- examining not only their average ratings but also their tendencies to give low, high, and extreme scores.

WITH mainCTE AS (
    SELECT 
        userId, 
        COUNT(*) AS total_ratings
    FROM ratings
    GROUP BY userId
),

-- Activity thresholds were carried forward from the user activity segmentation
-- defined in Query 07:
-- Low = 20–50, Medium = 51–150, High = 151+ ratings.

segmentationCTE AS (
    SELECT 
        *,
    CASE 
        WHEN total_ratings >= 20 AND total_ratings <=50 THEN 'Low Activity'
        WHEN total_ratings >= 51 AND total_ratings <= 150 THEN 'Medium Activity'
        WHEN total_ratings >= 151 THEN 'High Activity'
    END AS activity_segment

    FROM mainCTE
),

-- Rating behavior thresholds:
-- Low ratings: 0.5–2.0
-- High ratings: 4.0–5.0
-- Extreme ratings: 0.5–1.0 or 4.5–5.0

-- Extreme ratings overlap with the low and high categories and are analyzed
-- independently; therefore, low, high, and extreme percentages do not sum to 100%.

userBehaviorCTE AS(
    SELECT
        seg.userId,
        seg.total_ratings,
        seg.activity_segment,
        AVG(rat.rating) AS avg_rating,

        AVG(
            CASE
                WHEN rat.rating BETWEEN 0.5 AND 2.0 
                    THEN 1
                ELSE 0
            END) * 100.0 AS low_rating_pct,

        SUM(
            CASE
                WHEN rat.rating BETWEEN 0.5 AND 2.0 
                    THEN 1
                ELSE 0
            END) AS low_rating_count,

        AVG(
            CASE
                WHEN rat.rating BETWEEN 4.0 AND 5.0
                    THEN 1
                ELSE 0
            END) * 100.0 AS high_rating_pct,

        SUM(
            CASE
                WHEN rat.rating BETWEEN 4.0 AND 5.0
                    THEN 1
                ELSE 0
            END) AS high_rating_count,

        AVG(
            CASE
                WHEN rat.rating BETWEEN 0.5 AND 1.0
                    OR
                    rat.rating BETWEEN 4.5 AND 5.0
                    THEN 1
                ELSE 0
            END) * 100.0 AS extreme_rating_pct,

        SUM(
            CASE
                WHEN rat.rating BETWEEN 0.5 AND 1.0
                    OR
                    rat.rating BETWEEN 4.5 AND 5.0
                    THEN 1
                ELSE 0
            END) AS extreme_rating_count

    FROM segmentationCTE AS seg
    JOIN ratings AS rat
        ON seg.userId = rat.userId
    GROUP BY 
        seg.userId,
        seg.total_ratings,
        seg.activity_segment
)

-- User-level behavior metrics, including average rating and low, high, and
-- extreme rating percentages, were calculated first and then averaged within
-- each activity segment. This gives every user equal weight regardless of
-- how many ratings they submitted.

-- Conditional rating counts were retained for validation but excluded from the
-- final comparison because raw counts are strongly influenced by users' activity levels.
-- Percentages provide a more comparable measure of rating behavior across segments.

SELECT
    activity_segment,
    COUNT(*) AS total_users,
    ROUND(AVG(avg_rating), 2) AS avg_user_rating,
    ROUND(AVG(low_rating_pct), 2) AS avg_low_rating_pct,
    ROUND(AVG(high_rating_pct), 2) AS avg_high_rating_pct,
    ROUND(AVG(extreme_rating_pct), 2) AS avg_extreme_rating_pct
FROM userBehaviorCTE
GROUP BY activity_segment
ORDER BY total_users DESC
;