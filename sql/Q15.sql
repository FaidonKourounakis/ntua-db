
SELECT 
    visitor_id,
    ANY_VALUE(visitor.first_name) || ' ' || ANY_VALUE(visitor.last_name) AS visitor_name,
    CASE WHEN artist_id IS NOT NULL THEN 'Artist' ELSE 'Band' END AS performer_type,
    COALESCE(artist_id, band_id) AS performer_id,
    COALESCE(ANY_VALUE(artist.name), ANY_VALUE(band.name)) AS performer_name,
    ROUND(AVG(overall_impression + artist_performance)/2, 2) AS rated
FROM rating
JOIN performance USING (performance_id)
JOIN visitor USING (visitor_id)
LEFT JOIN artist USING (artist_id)
LEFT JOIN band USING (band_id)
GROUP BY (visitor_id, artist_id, band_id)
ORDER BY rated DESC
LIMIT 5;