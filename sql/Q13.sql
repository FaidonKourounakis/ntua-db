SELECT 
    CASE WHEN b.band_id IS NULL THEN 'Artist' ELSE 'Band' END AS performer_type,
    COALESCE(a.artist_id, b.band_id) AS performer_id,
    COALESCE(ANY_VALUE(a.name), ANY_VALUE(b.name)) AS performer_name, 
    STRING_AGG(DISTINCT continent.name, ', ') AS continents
FROM performance p
LEFT JOIN band b USING (band_id)
LEFT JOIN artist a USING (artist_id)
JOIN event USING (event_id)
JOIN festival USING (festival_id)
JOIN location USING (location_id)
JOIN continent USING (continent_id)
GROUP BY (a.artist_id, b.band_id)
HAVING COUNT(DISTINCT continent_id) >= 3


-- Following old version, treats performers as either solo artists or band member artists:
-- thus if for example a band performs in 2023, its members with the Rock genre
-- would be included in this query, and not the band itself (provided the band has the Rock genre)

-- SELECT 
--     a.name AS artist_name, 
--     STRING_AGG(DISTINCT continent.name, ', ') AS continents
-- FROM performance p
-- LEFT JOIN band_artist ba USING (band_id)
-- JOIN artist a ON a.artist_id = COALESCE(p.artist_id, ba.artist_id)
-- JOIN event USING (event_id)
-- JOIN festival USING (festival_id)
-- JOIN location USING (location_id)
-- JOIN continent USING (continent_id)
-- GROUP BY (a.artist_id, a.name)
-- HAVING COUNT(DISTINCT continent_id) >= 3