
SELECT 
    ANY_VALUE(g1.name) AS first_genre, 
    ANY_VALUE(g2.name) AS second_genre,
    COUNT(*) AS total_occurences
FROM (
    SELECT 
        COALESCE(bg1.genre_id, ag1.genre_id) AS genre_1_id,
        COALESCE(bg2.genre_id, ag2.genre_id) AS genre_2_id
    FROM performance p
    LEFT JOIN (SELECT DISTINCT band_id, genre_id FROM band_subgenre) AS bg1 USING (band_id)
    LEFT JOIN (SELECT DISTINCT band_id, genre_id FROM band_subgenre) AS bg2 USING (band_id)
    LEFT JOIN (SELECT DISTINCT artist_id, genre_id FROM artist_subgenre) AS ag1 USING (artist_id)
    LEFT JOIN (SELECT DISTINCT artist_id, genre_id FROM artist_subgenre) AS ag2 USING (artist_id))
JOIN genre g1 ON genre_1_id = g1.genre_id
JOIN genre g2 ON genre_2_id = g2.genre_id
WHERE genre_1_id < genre_2_id
GROUP BY (g1.genre_id, g2.genre_id)
ORDER BY total_occurences DESC
LIMIT 3;