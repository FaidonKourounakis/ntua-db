WITH vars AS (SELECT
        'Rock' AS target_genre,
        2023 AS target_year)
SELECT DISTINCT
    CASE WHEN p.artist_id IS NOT NULL THEN 'Artist' ELSE 'Band' END AS performer_type,
    COALESCE(p.artist_id, p.band_id) AS performer_id,
    COALESCE(ANY_VALUE(a.name), ANY_VALUE(b.name)) AS performer_name,
    CASE WHEN BOOL_OR(EXTRACT(YEAR FROM p.date_time) = vars.target_year) THEN 'Yes' ELSE 'No' END AS performed_on_target_year
FROM performance p
LEFT JOIN artist a USING (artist_id)
LEFT JOIN band b USING (band_id)
LEFT JOIN artist_subgenre asg USING (artist_id)
LEFT JOIN band_subgenre bsg USING (band_id)
JOIN genre g ON g.genre_id = COALESCE(asg.genre_id, bsg.genre_id)
JOIN vars ON vars.target_genre = g.name
GROUP BY p.artist_id, p.band_id

-- Following old version, treats performers as either solo artists or band member artists:
-- thus if for example a band performs in 2023, its members with the Rock genre
-- would be included in this query, and not the band itself (provided the band has the Rock genre)

-- WITH vars AS (SELECT
--         'Rock' AS target_genre,
--         2023 AS target_year),
-- target_artists AS (
--         SELECT DISTINCT a.artist_id, a.first_name, a.last_name, a.nickname
--         FROM artist a
--         JOIN artist_subgenre asg ON a.artist_id = asg.artist_id
--         JOIN subgenre sg ON asg.genre_id = sg.genre_id
--         JOIN genre g ON sg.genre_id = g.genre_id
--         CROSS JOIN vars
--         WHERE g.name = vars.target_genre),
--     participation_check AS (
--         SELECT 
--             a.artist_id,
--             CASE WHEN EXISTS (
--                 SELECT 1
--                 FROM performance p
--                 JOIN event e ON p.event_id = e.event_id
--                 JOIN festival f ON e.festival_id = f.festival_id
--                 CROSS JOIN vars
--                 WHERE f.festival_year = vars.target_year
--                 AND (p.artist_id = a.artist_id
--                     OR EXISTS (
--                         SELECT 1
--                         FROM band_artist ba
--                         WHERE ba.band_id = p.band_id
--                         AND ba.artist_id = a.artist_id
--                     ))
--             ) THEN 'Yes' ELSE 'No' END AS participated
--         FROM target_artists a)
-- SELECT 
--     ta.first_name AS "First Name",
--     ta.last_name AS "Last Name",
--     COALESCE(ta.nickname, '') AS "Nickname",
--     pc.participated AS "Participated"
-- FROM target_artists ta
-- JOIN participation_check pc ON ta.artist_id = pc.artist_id
-- ORDER BY ta.last_name, ta.first_name;