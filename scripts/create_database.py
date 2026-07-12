import sqlite3
import pandas as pd
from pathlib import Path

# Project paths
BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR / "data"
DB_DIR = BASE_DIR / "database"

DB_DIR.mkdir(exist_ok=True)

db_path = DB_DIR / "movielens.db"
movies_path = DATA_DIR / "movie.csv"
ratings_path = DATA_DIR / "rating.csv"

# Use a sample first so the project starts fast and does not overload the computer
RATING_SAMPLE_SIZE = 1_000_000

print("Reading movies.csv...")
movies = pd.read_csv(movies_path)

print(f"Reading first {RATING_SAMPLE_SIZE:,} rows from rating.csv...")
ratings = pd.read_csv(ratings_path, nrows=RATING_SAMPLE_SIZE)

print("Creating SQLite database...")
conn = sqlite3.connect(db_path)

movies.to_sql("movies", conn, if_exists="replace", index=False)
ratings.to_sql("ratings", conn, if_exists="replace", index=False)

print("Creating indexes...")
conn.execute("CREATE INDEX IF NOT EXISTS idx_ratings_movieId ON ratings(movieId);")
conn.execute("CREATE INDEX IF NOT EXISTS idx_ratings_userId ON ratings(userId);")

conn.commit()
conn.close()

print(f"Database created successfully at: {db_path}")
print(f"Movies loaded: {len(movies):,}")
print(f"Ratings loaded: {len(ratings):,}")