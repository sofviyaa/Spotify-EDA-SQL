--SQL project --Spotify Dataset

-- create table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

--EDA
SELECT COUNT(*)FROM spotify;

SELECT COUNT(DISTINCT artist) FROM spotify;

SELECT DISTINCT album_type FROM spotify;

SELECT MAX(duration_min) FROM spotify;

SELECT MIN(duration_min) FROM spotify;

SELECT * FROM spotify
WHERE duration_min=0;

DELETE FROM spotify
WHERE duration_min=0;
SELECT * FROM spotify
WHERE duration_min=0;

SELECT DISTINCT channel FROM spotify;

SELECT DISTINCT most_played_on FROM spotify;

-- ----------------------------------------------
-- Data Analysis 
-- ----------------------------------------------

-- What factors influence streaming numbers on Spotify?
SELECT 
	CORR(stream, danceability) AS correlation_stream_energy,
    CORR(stream, energy) AS correlation_stream_energy,
    CORR(stream, loudness) AS correlation_stream_loudness,
    CORR(stream, CASE WHEN official_video THEN 1 ELSE 0 END) AS correlation_stream_video
FROM 
    spotify;

-- Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
WITH cte AS (
    SELECT 
        album,
        MAX(energy) AS highest_energy,
        MIN(energy) AS lowest_energy
    FROM 
        spotify
    GROUP BY 
        album
)

SELECT 
    album,
    highest_energy - lowest_energy AS energy_diff
FROM 
    cte
ORDER BY 
    energy_diff DESC;

-- Identify the top 3 most popular tracks (by streams) for each album type (e.g., single, compilation) and calculate their average energy levels
WITH RankedTracks AS (
    SELECT 
        album_type,
        track,
        stream,
        energy,
        DENSE_RANK() OVER (PARTITION BY album_type ORDER BY stream DESC) AS rank
    FROM 
        spotify
)

SELECT 
    album_type,
    track,
    stream,
    energy
FROM 
    RankedTracks
WHERE 
    rank <= 3;

-- For each artist, calculate the total number of streams and the average loudness of their tracks, and identify the artist with the highest average loudness.
SELECT 
    artist,
    SUM(stream) AS total_streams,
    AVG(loudness) AS average_loudness
FROM 
    spotify
GROUP BY 
    artist
ORDER BY 
    average_loudness DESC
LIMIT 1;

-- Determine the percentage of tracks that have an official video and compare the average number of streams for tracks with and without official videos.
SELECT 
    (SUM(CASE WHEN official_video THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS percentage_with_video,
    AVG(CASE WHEN official_video THEN stream END) AS avg_streams_with_video,
    AVG(CASE WHEN NOT official_video THEN stream END) AS avg_streams_without_video
FROM 
    spotify;

-- Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
SELECT 
    artist,
    track,
    views,
    likes,
    SUM(likes) OVER (ORDER BY views DESC) AS cumulative_likes
FROM 
    spotify
ORDER BY 
    views DESC;

-- Query Optimization
EXPLAIN ANALYZE
SELECT
	artist,
	track,
	views
FROM spotify
WHERE artist = 'Gorillaz'
	AND
		most_played_on='Youtube'
ORDER BY stream DESC LIMIT 25

CREATE INDEX artist_index ON spotify (artist);
