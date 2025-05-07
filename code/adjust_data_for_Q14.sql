-- Stupid fix to have some results in Q14, 
-- because without it, it is too specialized and does not produce results 
-- We just pick 2 subgenres of different genres, and add the to all artists and bands
-- performing during 2020, 2021!

-- Create a temporary table to hold candidates data accessible to both INSERT statements
CREATE TEMP TABLE candidates AS
SELECT DISTINCT
    p.artist_id, 
    p.band_id, 
    sg.genre_id, 
    sg.subgenre_name
FROM 
    performance p
CROSS JOIN (
    (SELECT genre_id, name AS subgenre_name FROM subgenre WHERE genre_id = 1 LIMIT 1)
    UNION ALL
    (SELECT genre_id, name AS subgenre_name FROM subgenre WHERE genre_id = 2 LIMIT 1)
) AS sg  -- Alias for the subquery in CROSS JOIN
WHERE 
    EXTRACT(YEAR FROM p.date_time) IN (2020, 2021);

INSERT INTO artist_subgenre (artist_id, genre_id, subgenre_name)
SELECT 
    c.artist_id, 
    c.genre_id, 
    c.subgenre_name
FROM 
    candidates c
WHERE 
    c.artist_id IS NOT NULL 
    AND NOT EXISTS (
        SELECT 1
        FROM artist_subgenre asg
        WHERE 
            asg.artist_id = c.artist_id
            AND asg.genre_id = c.genre_id
            AND asg.subgenre_name = c.subgenre_name
    );

INSERT INTO band_subgenre (band_id, genre_id, subgenre_name)
SELECT 
    c.band_id, 
    c.genre_id, 
    c.subgenre_name
FROM 
    candidates c
WHERE 
    c.band_id IS NOT NULL 
    AND NOT EXISTS (
        SELECT 1
        FROM band_subgenre bsg
        WHERE 
            bsg.band_id = c.band_id
            AND bsg.genre_id = c.genre_id
            AND bsg.subgenre_name = c.subgenre_name
    );
