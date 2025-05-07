WITH p AS (
    SELECT artist_id AS id, 'Artist' AS performer_type, ANY_VALUE(name) AS name, COUNT(*) AS performances
    FROM performance
    JOIN artist USING (artist_id)
    GROUP BY artist_id
    UNION
    SELECT band_id AS id, 'Band' AS performer_type, ANY_VALUE(name), COUNT(*) AS performances
    FROM performance
    JOIN band USING (band_id)
    GROUP BY band_id)
SELECT *
FROM p
WHERE performances <= (SELECT MAX(performances) - 5 FROM p)
ORDER BY performances DESC;