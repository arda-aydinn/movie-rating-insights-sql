-- Schema documentation for the MovieLens SQL analysis project.
-- The SQLite database is created and populated using scripts/create_database.py.
-- This file documents the intended table structure used in the analysis.

DROP TABLE IF EXISTS movies;
DROP TABLE IF EXISTS ratings;

CREATE TABLE movies (
    movieId INTEGER PRIMARY KEY,
    title TEXT,
    genres TEXT
);

CREATE TABLE ratings (
    userId INTEGER,
    movieId INTEGER,
    rating REAL,
    timestamp INTEGER,
    FOREIGN KEY (movieId) REFERENCES movies(movieId)
);