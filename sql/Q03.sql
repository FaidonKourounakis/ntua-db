WITH warm_up_performances AS (
    SELECT 
        p.artist_id,
        p.band_id,
        f.festival_year AS festival_year,
        COUNT(*) AS warm_up_count
    FROM performance p
    JOIN event e USING (event_id)
    JOIN festival f USING (festival_id)
    JOIN performance_type USING (performance_type_id)
    WHERE performance_type.name = 'Warm Up'
    GROUP BY p.artist_id, p.band_id, f.festival_id
    HAVING COUNT(*) > 2
)

SELECT 
    'Artist' AS performer_type,
    a.artist_id AS performer_id,
    a.name AS name,
    w.festival_year,
    w.warm_up_count
FROM warm_up_performances w
JOIN artist a ON w.artist_id = a.artist_id

UNION ALL

SELECT 
    'Band' AS performer_type,
    b.band_id AS performer_id,
    b.name AS name,
    w.festival_year,
    w.warm_up_count
FROM warm_up_performances w
JOIN band b ON w.band_id = b.band_id

ORDER BY warm_up_count DESC;