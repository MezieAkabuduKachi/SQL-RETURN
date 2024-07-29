Select *
From imdb_top_1000;

-- Retrieve all columns for movies released after the year 2000.
Select *
From imdb_top_1000
Where Released_Year> 2000;

-- Find the top 10 movies with the highest IMDB ratings.
Select *
From imdb_top_1000
Order by IMDB_Rating DESC
limit 10;

-- List all movies that have a runtime of over 2 hours (120 minutes).
Select *
From imdb_top_1000
Where Runtime> 120;

-- Count the number of movies for each genre.
Select Genre, count(Genre)
From imdb_top_1000
group by Genre; 

-- Retrieve the movies directed by a specific director (e.g., Christopher Nolan).
Select *
From imdb_top_1000
where Director= 'Christopher Nolan';

-- Find the average IMDB rating for movies released in the 1990s.
SELECT AVG(IMDB_Rating) AS Average_IMDB_Rating
FROM imdb_top_1000
WHERE Released_Year BETWEEN 1990 AND 1999;

-- List the movies that have more than 1 million votes.
Select *
From imdb_top_1000
where No_of_Votes > 1000000;

-- Retrieve movies with a Meta score above 80.
Select *
From imdb_top_1000
where Meta_score > 80;

-- Find the top 5 movies with the highest gross revenue.
Select *
From imdb_top_1000
order by Gross DESC
limit 5;

-- List all the movies that star a specific actor (e.g., Tom Hanks).
Select *
From imdb_top_1000
where Star1= 'Tom Hanks';

-- Count the number of movies with a certificate of 'PG-13'.
Select count(*)
From imdb_top_1000
where Certificate= 'PG13';

-- Find the most common genre in the dataset.
SELECT Genre, COUNT(*) AS Genre_Count
FROM imdb_top_1000
GROUP BY Genre
ORDER BY Genre_Count DESC
LIMIT 1;

-- Retrieve movies that 'Drama' as genre.
SELECT *
FROM imdb_top_1000
WHERE Genre = 'Drama';

-- Calculate the total gross revenue for all movies in the dataset.
SELECT SUM(Gross) AS Total_Gross_Revenue
FROM imdb_top_1000;

-- List the top 5 directors with the most movies in the dataset.
SELECT Director, count(*) AS Most_Movies
FROM imdb_top_1000
Group by Director
Order by Most_Movies DESC
limit 5;

-- Find movies that have an overview containing a specific keyword (e.g., "love").
Select *
From imdb_top_1000
Where Overview LIKE '%love%';

-- Retrieve the top 10 movies based on IMDB rating and released in the last decade.
Select *
From imdb_top_1000
Where Released_Year between 2009 AND 2019
Order by IMDB_Rating DESC
limit 10;

-- List movies that were released in the same year as a specific movie (e.g., "The Matrix").
SELECT *
FROM imdb_top_1000
WHERE Released_Year = (SELECT Released_Year
                       FROM imdb_top_1000
                       WHERE Series_Title = 'The Matrix');

-- Find movies that have at least two of the same leading stars.
SELECT a.Series_Title AS Movie1, b.Series_Title AS Movie2, a.Star1, a.Star2, a.Star3, a.Star4
FROM imdb_top_1000 a
JOIN imdb_top_1000 b ON a.Series_Title <> b.Series_Title
WHERE (a.Star1 IN (b.Star1, b.Star2, b.Star3, b.Star4) OR
       a.Star2 IN (b.Star1, b.Star2, b.Star3, b.Star4) OR
       a.Star3 IN (b.Star1, b.Star2, b.Star3, b.Star4) OR
       a.Star4 IN (b.Star1, b.Star2, b.Star3, b.Star4))
GROUP BY a.Series_Title, b.Series_Title, a.Star1, a.Star2, a.Star3, a.Star4
HAVING COUNT(*) >= 2;

-- Calculate the average runtime of movies for each genre.
Select avg(Runtime) AS Runtime, Genre
From imdb_top_1000
group by Genre;









-- Find the top 3 genres with the highest average IMDB rating.
SELECT Genre, AVG(IMDB_Rating) AS Average_IMDB_Rating
FROM imdb_top_1000
GROUP BY Genre
ORDER BY Average_IMDB_Rating DESC
LIMIT 3;

-- Retrieve movies that have a gross revenue in the top 10% of all movies.
WITH RankedGross AS (
    SELECT
        Gross,
        PERCENT_RANK() OVER (ORDER BY Gross) AS PercentRank
    FROM imdb_top_1000
)
SELECT *
FROM imdb_top_1000
WHERE Gross > (
    SELECT MIN(Gross)
    FROM RankedGross
    WHERE PercentRank >= 0.9
);

-- List the directors who have directed movies in at least three different genres.
SELECT Director
FROM (
    SELECT Director, Genre, COUNT(*) AS Movie_Count
    FROM imdb_top_1000
    GROUP BY Director, Genre
) AS DirectorGenres
GROUP BY Director
HAVING COUNT(DISTINCT Genre) >= 3;

-- Calculate the median IMDB rating for movies released in each decade.
WITH Ratings AS (
    SELECT 
        IMDB_Rating,
        FLOOR(Released_Year / 10) * 10 AS Decade,
        ROW_NUMBER() OVER (PARTITION BY FLOOR(Released_Year / 10) * 10 ORDER BY IMDB_Rating) AS RowAsc,
        ROW_NUMBER() OVER (PARTITION BY FLOOR(Released_Year / 10) * 10 ORDER BY IMDB_Rating DESC) AS RowDesc,
        COUNT(*) OVER (PARTITION BY FLOOR(Released_Year / 10) * 10) AS CountPerDecade
    FROM imdb_top_1000
)
SELECT 
    Decade,
    AVG(IMDB_Rating) AS Median_IMDB_Rating
FROM Ratings
WHERE RowAsc IN (RowDesc, RowDesc - 1)
GROUP BY Decade;

-- Find the actor who has starred in the most movies and list their top 5 movies by IMDB rating.
-- Step 1: Find the actor with the most movies
WITH MostMoviesActor AS (
    SELECT Actor
    FROM (
        SELECT Star1 AS Actor FROM imdb_top_1000
        UNION ALL
        SELECT Star2 AS Actor FROM imdb_top_1000
        UNION ALL
        SELECT Star3 AS Actor FROM imdb_top_1000
        UNION ALL
        SELECT Star4 AS Actor FROM imdb_top_1000
    ) AS AllActors
    GROUP BY Actor
    ORDER BY COUNT(*) DESC
    LIMIT 1
)
-- Step 2: List the top 5 movies by IMDB rating for that actor
SELECT Series_Title, IMDB_Rating
FROM imdb_top_1000
WHERE Star1 = (SELECT Actor FROM MostMoviesActor)
   OR Star2 = (SELECT Actor FROM MostMoviesActor)
   OR Star3 = (SELECT Actor FROM MostMoviesActor)
   OR Star4 = (SELECT Actor FROM MostMoviesActor)
ORDER BY IMDB_Rating DESC
LIMIT 5;

-- Retrieve the top 5 movies based on IMDB rating, and include the number of votes for each movie.
Select Series_Title, IMDB_Rating, No_of_Votes
From imdb_top_1000
order by IMDB_Rating DESC
limit 5;

-- Identify movies with the longest runtime and group them by genre.
SELECT *
FROM imdb_top_1000 a
JOIN (
    SELECT Genre, MAX(Runtime) AS Max_Runtime
    FROM imdb_top_1000
    GROUP BY Genre
) b
ON a.Genre = b.Genre AND a.Runtime = b.Max_Runtime;

-- Calculate the percentage increase in average gross revenue for each decade compared to the previous decade.
WITH DecadeAverages AS (
    SELECT 
        FLOOR(Released_Year / 10) * 10 AS Decade,
        AVG(Gross) AS Avg_Gross
    FROM imdb_top_1000
    GROUP BY FLOOR(Released_Year / 10) * 10
)
SELECT 
    d1.Decade AS Current_Decade,
    d1.Avg_Gross AS Current_Avg_Gross,
    d2.Avg_Gross AS Previous_Avg_Gross,
    ((d1.Avg_Gross - d2.Avg_Gross) / d2.Avg_Gross) * 100 AS Percentage_Increase
FROM 
    DecadeAverages d1
LEFT JOIN 
    DecadeAverages d2
ON 
    d1.Decade = d2.Decade + 10
WHERE 
    d2.Avg_Gross IS NOT NULL;

-- List all movies where the director has directed at least two movies with an IMDB rating of 8.0 or higher.
WITH HighRatedDirectors AS (
    SELECT Director
    FROM imdb_top_1000
    WHERE IMDB_Rating >= 8.0
    GROUP BY Director
    HAVING COUNT(*) >= 2
)
SELECT *
FROM imdb_top_1000
WHERE Director IN (SELECT Director FROM HighRatedDirectors);

-- Find movies that have a higher Meta score than the average Meta score of movies in their genre.
WITH GenreAverages AS (
    SELECT 
        Genre,
        AVG(Meta_score) AS Avg_Meta_Score
    FROM imdb_top_1000
    GROUP BY Genre
)
SELECT 
    imdb_top_1000.*
FROM 
    imdb_top_1000
JOIN 
    GenreAverages
ON 
    imdb_top_1000.Genre = GenreAverages.Genre
WHERE 
    imdb_top_1000.Meta_score > GenreAverages.Avg_Meta_Score;

-- List movies released in consecutive years and have the same director.
WITH ConsecutiveMovies AS (
    SELECT 
        Series_Title,
        Director,
        Released_Year,
        LEAD(Released_Year) OVER (PARTITION BY Director ORDER BY Released_Year) AS Next_Year
    FROM 
        imdb_top_1000
)
SELECT 
    Series_Title,
    Director,
    Released_Year,
    Next_Year
FROM 
    ConsecutiveMovies
WHERE 
    Next_Year = Released_Year + 1;

-- Identify the top 3 actors who have the highest average IMDB rating across all movies they starred in.
WITH UnpivotedActors AS (
    SELECT 
        Star1 AS Actor,
        IMDB_Rating
    FROM imdb_top_1000
    UNION ALL
    SELECT 
        Star2 AS Actor,
        IMDB_Rating
    FROM imdb_top_1000
    UNION ALL
    SELECT 
        Star3 AS Actor,
        IMDB_Rating
    FROM imdb_top_1000
    UNION ALL
    SELECT 
        Star4 AS Actor,
        IMDB_Rating
    FROM imdb_top_1000
),
ActorAverages AS (
    SELECT 
        Actor,
        AVG(IMDB_Rating) AS Avg_IMDB_Rating
    FROM UnpivotedActors
    GROUP BY Actor
)
SELECT 
    Actor,
    Avg_IMDB_Rating
FROM 
    ActorAverages
ORDER BY 
    Avg_IMDB_Rating DESC
LIMIT 3;

-- Find the top 5 movies by gross revenue for each genre.
WITH RankedMovies AS (
    SELECT 
        Series_Title,
        Genre,
        Gross,
        RANK() OVER (PARTITION BY Genre ORDER BY Gross DESC) AS 'Rank'
    FROM imdb_top_1000
)
SELECT 
    Series_Title,
    Genre,
    Gross
FROM 
    RankedMovies
WHERE 
    'Rank' <= 5;

-- Retrieve movies with the lowest Meta scores but have an IMDB rating above 7.0.
Select Series_Title, Meta_score , IMDB_Rating
From imdb_top_1000
Where IMDB_Rating> 7.0
ORDER BY Meta_score ASC
LIMIT 10;

-- List the movies with the highest IMDB rating in each year.
WITH RankedMovies AS (
    SELECT 
        Series_Title,
        Released_Year,
        IMDB_Rating,
        ROW_NUMBER() OVER (PARTITION BY Released_Year ORDER BY IMDB_Rating DESC) AS RowNum
    FROM imdb_top_1000
)
SELECT 
    Series_Title,
    Released_Year,
    IMDB_Rating
FROM 
    RankedMovies
WHERE 
    RowNum = 1;
    
-- Calculate the total runtime of all movies for each director and list the top 5 directors by total runtime.
SELECT Director, SUM(Runtime) AS TotalRuntime
FROM imdb_top_1000
GROUP BY Director
ORDER BY TotalRuntime DESC
LIMIT 5;

-- Identify movies that have the same title but were released in different years.
SELECT 
    Series_Title,
    Released_Year
FROM 
    imdb_top_1000
WHERE 
    Series_Title IN (
        SELECT 
            Series_Title
        FROM 
            imdb_top_1000
        GROUP BY 
            Series_Title
        HAVING 
            COUNT(DISTINCT Released_Year) > 1
    )
ORDER BY 
    Series_Title, Released_Year;

-- List movies where all leading stars (Star1, Star2, Star3, Star4) have appeared in at least one other movie in the dataset.
SELECT 
    Series_Title,
    Released_Year,
    Star1,
    Star2,
    Star3,
    Star4
FROM 
    imdb_top_1000 AS main
WHERE 
    Star1 IN (SELECT Star1 FROM imdb_top_1000 WHERE Series_Title != main.Series_Title)
    AND Star2 IN (SELECT Star2 FROM imdb_top_1000 WHERE Series_Title != main.Series_Title)
    AND Star3 IN (SELECT Star3 FROM imdb_top_1000 WHERE Series_Title != main.Series_Title)
    AND Star4 IN (SELECT Star4 FROM imdb_top_1000 WHERE Series_Title != main.Series_Title)
ORDER BY 
    Series_Title, Released_Year;

-- Find the top 10 movies with the most votes and calculate the average IMDB rating for these movies.
WITH Top10Movies AS (
    SELECT 
        Series_Title,
        IMDB_Rating,
        No_of_Votes
    FROM 
        imdb_top_1000
    ORDER BY 
        No_of_Votes DESC
    LIMIT 10
)
SELECT 
    AVG(IMDB_Rating) AS Average_IMDB_Rating
FROM 
    Top10Movies;

-- List the movies where the gross revenue is greater than the average gross revenue of movies released in the same year.
WITH YearlyAverageGross AS (
    SELECT 
        Released_Year,
        AVG(Gross) AS Avg_Gross
    FROM 
        imdb_top_1000
    GROUP BY 
        Released_Year
)
SELECT 
    imdb.Series_Title,
    imdb.Released_Year,
    imdb.Gross,
    yag.Avg_Gross
FROM 
    imdb_top_1000 imdb
JOIN 
    YearlyAverageGross yag
ON 
    imdb.Released_Year = yag.Released_Year
WHERE 
    imdb.Gross > yag.Avg_Gross
ORDER BY 
    imdb.Released_Year, imdb.Gross DESC;
