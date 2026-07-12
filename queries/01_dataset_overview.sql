-- Question:
-- How many movies, users, and ratings are available in the dataset?

-- Purpose:
-- To understand the basic scale of the dataset by counting the number of movies, users, and ratings included in the sample.

-- Notes:
-- This query serves as a sanity check to confirm that the data was loaded correctly into the SQLite database.

SELECT
    (SELECT COUNT(*) FROM movies) AS total_movies,
    (SELECT COUNT(DISTINCT userId) FROM ratings) AS total_users,
    (SELECT COUNT(*) FROM ratings) AS total_ratings;
