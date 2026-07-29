# 🎬 MovieLens Rating Intelligence

**User Behavior, Genre Analytics, Hidden Gems, and Ranking Sensitivity with SQL**

A structured SQL portfolio project exploring movie popularity, audience approval, user rating behavior, genre-level performance, ranking methods, hidden-gem detection, and ranking sensitivity using the MovieLens dataset.

**🧠 15 SQL analyses · 📊 1,000,000 ratings · 🎞️ 27,278 movies · 👥 6,743 users · 🛠️ SQLite · Python · pandas**

[Project Overview](#project-overview) · [Query Catalog](#query-catalog) · [SQL Skills](#sql-skills-demonstrated) · [Key Findings](#key-findings) · [Methodology](#methodological-decisions) · [Results](#selected-results) · [Setup](#how-to-run-the-project)

---

## Project Overview

This project uses SQL to investigate how users interact with movies in the MovieLens dataset. The analysis progresses from foundational dataset exploration to more advanced analytical problems involving user segmentation, recursive genre normalization, window functions, percentile-based scoring, and ranking sensitivity.

The project was designed to demonstrate more than SQL syntax. It focuses on translating analytical questions into reproducible query logic, selecting appropriate levels of aggregation, documenting methodological decisions, validating calculations, and distinguishing between closely related concepts such as:

- Popularity and audience approval
- Rating-level and user-level behavior
- Global and genre-specific rankings
- Raw metrics and distribution-based measures
- Stable and methodology-sensitive rankings

The final repository contains:

- 15 documented SQL analyses
- A Python script for building the local SQLite database
- A reusable movie-level SQL view
- Selected analysis results exported as CSV files
- Explicit validation checks, assumptions, and limitations

**Project status:** Complete — 15 documented analyses, reusable SQL components, and exported results.

---

## Dataset and Scope

The project is based on the MovieLens 20M dataset.

The local analysis database contains:

| Metric | Value |
|---|---:|
| Movie metadata records | 27,278 |
| Distinct users in the loaded rating data | 6,743 |
| Rating records analyzed | 1,000,000 |
| Rating scale | 0.5–5.0 |
| Rating years represented | 1996–2015 |

The complete movie metadata file is included in the repository. To keep the project lightweight and practical to run locally, the database creation script loads the first 1,000,000 rows of `rating.csv`.

The analysis therefore represents the **loaded MovieLens subset**, not the complete 20-million-rating dataset.

### Main analytical entities

| Table | Main columns | Description |
|---|---|---|
| `movies` | `movieId`, `title`, `genres` | Movie metadata and pipe-delimited genre labels |
| `ratings` | `userId`, `movieId`, `rating`, `timestamp` | Individual user rating records |

The `genres` column contains multiple values in a single pipe-delimited field, such as:

```text
Action|Adventure|Sci-Fi
```

Queries 10–12 use a recursive CTE to transform this field into a movie–genre analytical structure.

---

## Tech Stack

| Tool | Role |
|---|---|
| SQLite | Local relational database and SQL execution environment |
| SQL | Data exploration, aggregation, segmentation, ranking, and analytical modeling |
| Python | Database creation workflow |
| pandas | CSV ingestion and SQLite table creation |
| pathlib | Portable project-relative file paths |
| Git and GitHub | Version control and project presentation |
| Visual Studio Code | Development and SQL execution environment |

The database creation script also creates indexes on:

- `ratings.movieId`
- `ratings.userId`

These indexes support the join and user-level aggregation patterns used throughout the project.

---

## Data Model

The intended table structure is documented in [`schema/create_tables.sql`](schema/create_tables.sql).

```sql
movies
------
movieId INTEGER
title   TEXT
genres  TEXT


ratings
-------
userId    INTEGER
movieId   INTEGER
rating    REAL
timestamp INTEGER
```

The actual local database is created and populated by [`scripts/create_database.py`](scripts/create_database.py) using `pandas.DataFrame.to_sql()`.

The schema file is retained as human-readable documentation of the analytical table structure; it is not required by the Python database creation workflow.

---

## Repository Structure

```text
movie-rating-insights-sql/
│
├── data/
│   ├── movie.csv
│   └── rating.csv                  # Local only; excluded from Git
│
├── database/
│   └── movielens.db               # Generated locally; excluded from Git
│
├── queries/
│   ├── 01_dataset_overview.sql
│   ├── 02_most_rated_movies.sql
│   ├── 03_top_rated_movies_with_threshold.sql
│   ├── 04_rating_distribution.sql
│   ├── 05_popularity_vs_average_rating.sql
│   ├── 06_rating_trends_over_time.sql
│   ├── 07_user_activity_segmentation.sql
│   ├── 08_strict_vs_generous_users.sql
│   ├── 09_user_rating_behavior_by_segment.sql
│   ├── 10_genre_level_rating_behavior.sql
│   ├── 11_genre_popularity_analysis.sql
│   ├── 12_top_movies_by_genre.sql
│   ├── 13_hidden_gems.sql
│   ├── 14_reusable_movie_metrics_view.sql
│   └── 15_combined_movie_score_analysis.sql
│
├── results/
│   └── Selected query outputs exported as CSV files
│
├── schema/
│   └── create_tables.sql
│
├── scripts/
│   └── create_database.py
│
├── .gitignore
├── README.md
└── requirements.txt
```

The repository intentionally excludes:

- The large `rating.csv` source file
- Locally generated `.db` files
- The entire `database/` directory
- Python cache files

---

## Analysis Workflow

```text
MovieLens CSV files
        │
        ▼
Python and pandas ingestion
        │
        ▼
Local SQLite database
        │
        ├── movies table
        ├── ratings table
        └── analytical indexes
        │
        ▼
Documented SQL analyses
        │
        ├── dataset exploration
        ├── movie-level analysis
        ├── time-based analysis
        ├── user segmentation
        ├── genre normalization
        ├── ranking analysis
        └── percentile scoring
        │
        ▼
Reusable movie metrics view
        │
        ▼
Exported CSV results
```

The query sequence intentionally progresses from foundational SQL concepts to more advanced analytical methods.

---

## Query Catalog

| Query | Analytical objective | Main SQL concepts |
|---|---|---|
| [01 — Dataset Overview](queries/01_dataset_overview.sql) | Establish the size of the loaded analysis database | Scalar subqueries, `COUNT`, `DISTINCT` |
| [02 — Most Rated Movies](queries/02_most_rated_movies.sql) | Identify movies with the greatest rating activity | `INNER JOIN`, `GROUP BY`, aggregation, `LIMIT` |
| [03 — Top Rated Movies with Threshold](queries/03_top_rated_movies_with_threshold.sql) | Rank highly rated movies after applying a minimum support threshold | CTE, `AVG`, `HAVING`, threshold filtering |
| [04 — Rating Distribution](queries/04_rating_distribution.sql) | Examine individual rating values and grouped low, moderate, and high rating behavior | `CASE`, conditional aggregation, aggregate window functions |
| [05 — Popularity vs. Average Rating](queries/05_popularity_vs_average_rating.sql) | Compare sample-based popularity with audience approval | Movie-level aggregation, validation through weighted averages |
| [06 — Rating Trends Over Time](queries/06_rating_trends_over_time.sql) | Measure year-over-year changes in rating activity and average ratings | Date extraction, chained CTEs, `LAG`, change calculations |
| [07 — User Activity Segmentation](queries/07_user_activity_segmentation.sql) | Compare distribution-based and fixed-threshold user activity segments | `NTILE`, aggregate windows, segmentation, contribution analysis |
| [08 — Strict vs. Generous Users](queries/08_strict_vs_generous_users.sql) | Classify sufficiently active users relative to the overall sample average | User-level aggregation, scalar subquery, `CASE`, window percentages |
| [09 — Rating Behavior by Activity](queries/09_user_rating_behavior_by_segment.sql) | Compare low, high, and extreme rating tendencies across activity segments | Conditional aggregation, user-level weighting, chained CTEs |
| [10 — Genre-Level Rating Behavior](queries/10_genre_level_rating_behavior.sql) | Normalize multi-valued genres and compare genre-level evaluation behavior | Recursive CTE, string parsing, distinct counts, conditional aggregation |
| [11 — Genre Popularity Analysis](queries/11_genre_popularity_analysis.sql) | Compare genre rankings under four definitions of popularity | `DENSE_RANK`, multiple metric rankings, rank-spread analysis |
| [12 — Top Movies by Genre](queries/12_top_movies_by_genre.sql) | Rank sufficiently rated movies within each genre and demonstrate tie handling | `PARTITION BY`, `ROW_NUMBER`, `RANK`, `DENSE_RANK` |
| [13 — Hidden Gems](queries/13_hidden_gems.sql) | Detect high-quality, lower-visibility movies using distribution-based criteria | `PERCENT_RANK`, support filtering, sensitivity analysis, heuristic scoring |
| [14 — Reusable Movie Metrics View](queries/14_reusable_movie_metrics_view.sql) | Centralize repeated movie-level rating calculations | `CREATE VIEW`, `DROP VIEW`, reusable analytical layer, grain validation |
| [15 — Combined Movie Score](queries/15_combined_movie_score_analysis.sql) | Combine quality and popularity and test ranking sensitivity to alternative weights | Percentile normalization, weighted scoring, `DENSE_RANK`, sensitivity analysis |

---

## SQL Skills Demonstrated

### Relational querying and aggregation

- Inner joins
- Grouped aggregation
- Distinct counting
- Scalar subqueries
- `WHERE` and `HAVING`
- Conditional aggregation
- Multi-level aggregation

### Common table expressions

- Single-purpose CTEs
- Chained analytical CTEs
- Recursive CTEs
- Separation of calculation, ranking, and presentation layers

### Window functions

- `LAG`
- `NTILE`
- `ROW_NUMBER`
- `RANK`
- `DENSE_RANK`
- `PERCENT_RANK`
- Aggregate window functions such as `SUM(COUNT(*)) OVER ()`

### Analytical design

- User segmentation
- Support thresholds
- User-level and rating-level weighting
- Percentile normalization
- Sensitivity analysis
- Multi-metric rankings
- Tie-aware leaderboards
- Heuristic scoring
- Rank-stability analysis

### Reusability and validation

- Reusable SQL views
- Explicit analytical grain
- Manual weighted-average validation
- Threshold sensitivity checks
- Row-count and uniqueness validation
- Separation of raw calculations from final rounding

---

## Key Findings

All findings below were rechecked against the CSV outputs in the [`results`](results/) directory. They describe the loaded one-million-rating subset.

### 1. Rating activity is highly concentrated among a minority of users

The most active quartile contains approximately one quarter of users but produces **69.12% of all ratings**.

| Activity quartile | Users | User share | Rating share | Average ratings per user |
|---:|---:|---:|---:|---:|
| 1 — Least active | 1,686 | 25.00% | 4.37% | 25.90 |
| 2 | 1,686 | 25.00% | 8.47% | 50.21 |
| 3 | 1,686 | 25.00% | 18.04% | 107.01 |
| 4 — Most active | 1,685 | 24.99% | 69.12% | 410.23 |

The fixed-threshold segmentation produces a similar conclusion:

| Segment | Users | User share | Rating share | Average ratings per user |
|---|---:|---:|---:|---:|
| Low Activity | 2,586 | 38.35% | 8.16% | 31.54 |
| Medium Activity | 2,362 | 35.03% | 20.99% | 88.87 |
| High Activity | 1,795 | 26.62% | 70.85% | 394.72 |

Although High Activity users represent only **26.62%** of users, they generate **70.85%** of rating activity.

---

### 2. Neutral users are the largest behavioral group, but strict users contribute disproportionately high activity

Among the 4,157 users with at least 51 ratings:

| Behavior | Users | User share | Rating share | Average user rating |
|---|---:|---:|---:|---:|
| Generous | 1,526 | 36.71% | 27.29% | 4.04 |
| Neutral | 1,820 | 43.78% | 46.36% | 3.55 |
| Strict | 811 | 19.51% | 26.35% | 2.98 |

Neutral users form the largest group at **43.78%**.

Strict users account for only **19.51%** of eligible users but generate **26.35%** of their rating activity, indicating that this smaller behavioral group is comparatively active.

The average user rating also separates the groups clearly:

- Generous: **4.04**
- Neutral: **3.55**
- Strict: **2.98**

---

### 3. Highly active users use the rating scale differently

The Medium Activity segment has the highest average user rating and the highest high-rating frequency.

| Segment | Average user rating | Low-rating frequency | High-rating frequency | Extreme-rating frequency |
|---|---:|---:|---:|---:|
| Low Activity | 3.62 | 12.36% | 54.96% | 31.97% |
| Medium Activity | 3.67 | 10.97% | 56.98% | 31.69% |
| High Activity | 3.54 | 12.73% | 50.93% | 26.70% |

High Activity users:

- Have the lowest average user rating at **3.54**
- Give high ratings less frequently than the other segments
- Use extreme scores less frequently, at **26.70%**, compared with approximately 32% for Low and Medium Activity users

This suggests that the most active users use a more compressed rating pattern and are less likely to rely on the most extreme ends of the scale.

---

### 4. Audience evaluation differs substantially across genres

Film-Noir receives the strongest audience evaluations in the analyzed sample.

| Genre | Average rating | High-rating share |
|---|---:|---:|
| Film-Noir | 3.96 | 69.23% |
| War | 3.82 | 62.47% |
| Documentary | 3.75 | 61.47% |
| Crime | 3.68 | 56.31% |
| Drama | 3.68 | 56.20% |

Horror ranks lowest on both evaluation measures:

- Average rating: **3.26**
- High-rating share: **40.70%**

These genre averages are rating-weighted, meaning frequently rated movies contribute more heavily than sparsely rated movies.

---

### 5. Genre popularity depends strongly on how popularity is defined

Popularity was measured using:

1. Total rating volume
2. Unique audience reach
3. Number of rated movies
4. Average ratings per rated movie

The resulting rankings are not interchangeable.

| Genre | Rating-volume rank | Audience-reach rank | Rated-movie rank | Ratings-per-movie rank | Rank spread |
|---|---:|---:|---:|---:|---:|
| Drama | 1 | 1 | 1 | 17 | 16 |
| Adventure | 5 | 4 | 8 | 1 | 7 |
| IMAX | 16 | 16 | 18 | 3 | 15 |
| Action | 3 | 4 | 5 | 4 | 2 |

Drama dominates total volume, audience reach, and rated-movie representation, but falls to **17th** in ratings per movie.

Adventure ranks fifth in total volume but first in ratings per movie.

IMAX has relatively low total volume and catalog representation, yet ranks third in ratings per movie.

This demonstrates why a single popularity metric can produce an incomplete interpretation.

---

### 6. The percentile-based method identified 113 hidden-gem candidates

The hidden-gem analysis first required at least 50 ratings and then selected movies that met both conditions:

- Quality percentile at or above the 85th percentile
- Visibility percentile at or below the 35th percentile

The balanced definition retained **113 movies**.

The highest-ranked candidates by quality–visibility gap include:

| Movie | Ratings | Average rating | Quality percentile | Visibility percentile | Gap |
|---|---:|---:|---:|---:|---:|
| *A Day at the Races* | 51 | 4.1176 | 0.9648 | 0.0107 | 0.9542 |
| *3-Iron* | 51 | 4.1078 | 0.9626 | 0.0107 | 0.9520 |
| *The Palm Beach Story* | 52 | 4.1442 | 0.9739 | 0.0229 | 0.9510 |
| *Cosmos* | 55 | 4.3273 | 0.9984 | 0.0549 | 0.9435 |

The method avoids defining hidden gems through a single fixed average-rating cutoff. Instead, both approval and visibility are evaluated relative to the distribution of eligible movies.

---

### 7. Some movie rankings are stable, while others depend heavily on weighting choices

The combined-score analysis compared three scenarios:

- Balanced: 50% quality, 50% popularity
- Quality-focused: 70% quality, 30% popularity
- Popularity-focused: 30% quality, 70% popularity

*The Shawshank Redemption* ranks first in all three scenarios:

| Movie | Balanced rank | Quality-focused rank | Popularity-focused rank | Rank spread |
|---|---:|---:|---:|---:|
| *The Shawshank Redemption* | 1 | 1 | 1 | 0 |

This makes it a highly stable top-ranked movie under the tested weighting decisions.

Other movies are much more sensitive:

| Movie | Balanced rank | Quality-focused rank | Popularity-focused rank | Rank spread |
|---|---:|---:|---:|---:|
| *A Day at the Races* | 1,294 | 816 | 2,320 | 1,504 |
| *3-Iron* | 1,299 | 828 | 2,321 | 1,493 |
| *The Palm Beach Story* | 1,255 | 772 | 2,264 | 1,492 |
| *Ace Ventura: When Nature Calls* | 1,204 | 2,166 | 780 | 1,386 |

High-quality, low-visibility films improve substantially in the quality-focused scenario and decline under popularity-focused weighting.

The reverse occurs for widely rated movies with weaker audience approval, such as *Ace Ventura: When Nature Calls*.

This result illustrates that a combined ranking score is not methodologically neutral: the selected weights directly influence which movies are promoted.

---

### 8. Year-over-year rating activity varies substantially within the loaded sample

The largest relative increase in annual rating activity occurred in **1999**, when rating volume rose by **233.88%** compared with the previous year.

The same year also recorded a **+0.15** increase in average rating.

The largest decline in average rating occurred in **2015**:

- Average-rating change: **−0.24**
- Rating-volume change: **−50.06%**

The 2015 result should be interpreted cautiously because the source dataset ends on March 31, 2015. Its rating-volume decline therefore reflects partial-year coverage rather than a complete year-over-year comparison.

More generally, these trends describe rating timestamps within the loaded, non-random subset and should not be interpreted as complete MovieLens platform trends.

---

## Methodological Decisions

| Decision | Implementation | Rationale |
|---|---|---|
| Rating subset | First 1,000,000 rows of `rating.csv` | Keeps the project practical to run locally |
| High-support movie threshold | At least 400 ratings | Reduces the influence of small rating samples in top-movie rankings |
| Eligibility threshold for Queries 13 and 15 | At least 50 ratings | Retains a broad comparison universe while excluding movies supported by very small samples |
| User activity segments | Low: 20–50, Medium: 51–150, High: 151+ | Provides interpretable fixed ranges informed by the activity distribution |
| Eligible behavioral users | At least 51 ratings | Excludes the Low Activity segment from user-average classification |
| Neutral behavior band | Within ±0.25 of the overall sample average | Prevents minor deviations from being classified as meaningful strictness or generosity |
| Low ratings | 0.5–2.0 | Captures clearly negative ratings |
| High ratings | 4.0–5.0 | Captures strongly positive ratings |
| Extreme ratings | 0.5–1.0 or 4.5–5.0 | Measures use of the outer ends of the rating scale |
| Genre normalization | Recursive splitting of the pipe-delimited genre field | Creates a usable movie–genre analytical structure |
| Hidden-gem definition | Quality ≥ 85th percentile and visibility ≤ 35th percentile | Balances strong approval with limited sample visibility |
| Combined-score scenarios | 50/50, 70/30, and 30/70 | Tests sensitivity to alternative quality–popularity priorities |
| Rank sensitivity | Maximum rank minus minimum rank across scenarios | Provides an interpretable movie-level measure of ranking instability |

### Analytical weighting

Some analyses are calculated at the **rating-record level**, while others first calculate metrics at the **user level**.

For example:

- Genre averages are rating-weighted, so frequently rated movies contribute more heavily.
- Query 09 calculates behavior percentages for each user first and then averages them within activity segments, giving every user equal weight.

This distinction is documented because the two methods answer different analytical questions.

### Multi-genre movies

Ratings for a multi-genre movie contribute to every associated genre.

As a result:

- Genre-level totals overlap
- Genre totals cannot be added to recover the dataset-wide rating total
- A movie may appear independently in multiple genre rankings

### Rounding

Calculations, percentiles, weighted scores, and rankings use unrounded values.

Rounding is applied only in final output columns to avoid:

- Artificial ties
- Altered ranking order
- Unnecessary precision in presentation

---

## Limitations

- The analysis uses the first 1,000,000 rows of the MovieLens 20M rating file rather than the complete dataset.
- The first 1,000,000 rows do not form a random rating sample. The source `ratings.csv` file is ordered by `userId` and then `movieId`, so the loaded subset represents the lower user-ID portion of the file.
- `rating_count` measures visibility within the loaded MovieLens subset; it is not a direct measure of real-world viewership, revenue, or cultural recognition.
- Rating timestamps represent when users submitted ratings, not movie release dates.
- The source dataset contains only partial coverage for 2015, ending on March 31; comparisons involving 2015 are therefore not full-year comparisons.
- Thresholds, percentile boundaries, and score weights are analytical decisions rather than statistically estimated or externally validated parameters.
- Percentile normalization preserves relative ordering but not the magnitude of the original differences between movies.
- Genre-level metrics overlap because multi-genre movies contribute to multiple categories.
- `rank_spread` is a heuristic measure of movie-level sensitivity and not a formal measure of agreement between complete ranking lists.
- The project produces descriptive rankings and analytical comparisons; it is not a personalized recommendation system.
- Tags, genome scores, and user demographic attributes are not included, and the project does not model individual preferences for personalized recommendations.

---

## How to Run the Project

### 1. Clone the repository

```bash
git clone https://github.com/arda-aydinn/movie-rating-insights-sql.git
cd movie-rating-insights-sql
```

### 2. Install the dependency

```bash
pip install -r requirements.txt
```

The only external Python dependency is:

```text
pandas
```

`sqlite3` and `pathlib` are included in the Python standard library.

### 3. Prepare the data

Download the MovieLens 20M dataset from GroupLens.

The official GroupLens archive uses the filenames:

```text
movies.csv
ratings.csv
```

Rename them before running the database creation script:

```text
movies.csv  → movie.csv
ratings.csv → rating.csv
```

Place `rating.csv` in the `data/` directory:

```text
data/
├── movie.csv
└── rating.csv
```

`movie.csv` is included in the repository. `rating.csv` is excluded from Git because of its size.

### 4. Create the local database

From the project root, run:

```bash
python scripts/create_database.py
```

The script will:

1. Read all records from `movie.csv`
2. Read the first 1,000,000 rows from `rating.csv`
3. Create `database/movielens.db`
4. Replace and populate the `movies` and `ratings` tables
5. Create indexes on `ratings.movieId` and `ratings.userId`
6. Print the number of loaded movies and ratings

### 5. Run the SQL analyses

Open `database/movielens.db` using any SQLite-compatible client.

The SQL files can be executed from the [`queries`](queries/) directory.

They are numbered in the recommended analytical order:

```text
01 → 02 → ... → 15
```

Query 15 depends on the reusable view created by Query 14. Therefore, run:

```text
14_reusable_movie_metrics_view.sql
```

before:

```text
15_combined_movie_score_analysis.sql
```

The remaining result-oriented queries can be executed independently after the database has been created.

---

## Selected Results

Selected outputs are available as CSV files so that the main findings can be inspected without rerunning every query.

| Result | Description |
|---|---|
| [Dataset overview](results/01_dataset_overview.csv) | Database scale and loaded record counts |
| [Yearly rating trends](results/06_yearly_rating_trends.csv) | Annual volume, averages, and year-over-year changes |
| [Activity quartiles](results/07a_activity_quartiles.csv) | Distribution-based user activity segmentation |
| [Fixed activity segments](results/07b_activity_segments.csv) | Low, Medium, and High Activity user groups |
| [User rating behaviors](results/08_user_rating_behaviors.csv) | Strict, Neutral, and Generous user classification |
| [Behavior by activity](results/09_rating_behavior_by_activity.csv) | Low, high, and extreme rating tendencies by segment |
| [Genre rating behavior](results/10_genre_rating_behavior.csv) | Genre reach, volume, average rating, and high-rating frequency |
| [Genre popularity rankings](results/11_genre_popularity_rankings.csv) | Four definitions of genre popularity and their rank differences |
| [Top movies by genre](results/12_top_movies_by_genre.csv) | Genre-level ranking-function comparison |
| [Hidden gems](results/13_hidden_gems.csv) | Percentile-based high-quality, lower-visibility candidates |
| [Combined movie scores](results/15_combined_movie_scores.csv) | Weighted scores, alternative rankings, and rank sensitivity |

---

## Future Improvements

Possible extensions include:

1. **Run the analysis on the complete MovieLens 20M rating dataset** using PostgreSQL or another database designed for larger analytical workloads.
2. **Parameterize thresholds and weights** instead of defining them directly inside individual queries.
3. **Compare percentile normalization with z-score normalization**, including a log transformation of rating volume.
4. **Measure complete-ranking agreement** using Spearman correlation or Kendall’s tau.
5. **Add visual reporting** through Python, Tableau, or Power BI.
6. **Build a personalized recommendation layer** using collaborative filtering or matrix-factorization methods.
7. **Integrate additional MovieLens data**, including tags and genome scores.
8. **Add automated data-quality and SQL validation tests** to the database creation workflow.

---

## Project Summary

This project demonstrates an end-to-end SQL analytical workflow covering data ingestion, exploratory analysis, user segmentation, recursive genre normalization, window functions, reusable views, percentile-based scoring, and ranking-sensitivity analysis.

Detailed SQL methodology is documented inside each query, while selected outputs are available in the [`results`](results/) directory.