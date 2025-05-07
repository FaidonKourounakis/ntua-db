
WITH genre_occurrence AS (
    SELECT
        EXTRACT(YEAR FROM p.date_time) AS yr,
        COALESCE(ag.genre_id, bg.genre_id) AS genre_id,
        COUNT(*) AS occurrences
    FROM performance p
    LEFT JOIN (SELECT DISTINCT band_id, genre_id FROM band_subgenre) AS bg USING (band_id)
    LEFT JOIN (SELECT DISTINCT artist_id, genre_id FROM artist_subgenre) AS ag USING (artist_id)
    GROUP BY (COALESCE(ag.genre_id, bg.genre_id), EXTRACT(YEAR FROM p.date_time))
    HAVING COUNT(*) >= 3
), pair AS (
    SELECT 
        o1.genre_id AS genre_1_id, o2.genre_id AS genre_2_id,
        yr, occurrences
    FROM genre_occurrence o1
    JOIN genre_occurrence o2 USING (yr, occurrences)
    WHERE o1.genre_id < o2.genre_id
) SELECT
    g1.name AS "1st Genre",
    g2.name AS "2nd Genre",
    p1.yr || ', ' || p2.yr AS "Years",
    p1.occurrences || ', ' || p2.occurrences AS "Occurrences"
FROM pair p1
JOIN pair p2 USING (genre_1_id, genre_2_id)
JOIN genre g1 ON g1.genre_id = genre_1_id
JOIN genre g2 ON g2.genre_id = genre_2_id
WHERE p1.yr + 1 = p2.yr