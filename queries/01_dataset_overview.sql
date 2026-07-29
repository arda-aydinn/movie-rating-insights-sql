-- Question:
-- How many movies, active users, and rating records are available in the
-- loaded analysis database?

-- Purpose:
-- To establish the scale of the analysis sample and verify that the movie
-- metadata and rating records were loaded successfully into SQLite.

-- General Notes:
-- total_movies counts all records in the movies table, including movies that
-- may not have received a rating in the analyzed rating sample.

-- total_users represents distinct users appearing in the loaded ratings table,
-- rather than the full user population of the original MovieLens dataset.

-- total_ratings reflects the rating sample loaded into the local database.

SELECT
    (SELECT COUNT(*) FROM movies) AS total_movies,
    (SELECT COUNT(DISTINCT userId) FROM ratings) AS total_users,
    (SELECT COUNT(*) FROM ratings) AS total_ratings
;