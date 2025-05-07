SELECT 
    CASE WHEN a.artist_id IS NULL THEN 'Band' ELSE 'Artist' END AS performer_type,
    COALESCE(a.artist_id, b.band_id) AS id,
    COALESCE(ANY_VALUE(a.name), ANY_VALUE(b.name)) AS name,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, COALESCE(a.birth_date, b.established))) AS age,
    COUNT(*) AS performances
FROM performance p
LEFT JOIN artist a USING (artist_id)
LEFT JOIN band b USING (band_id)
WHERE COALESCE(a.birth_date, b.established) > CURRENT_DATE - INTERVAL '30 years'
GROUP BY a.artist_id, b.band_id
ORDER BY performances DESC

-- Following old version, treats performers as either solo artists or band member artists:
-- thus if for example a band performs in 2023, its members with the Rock genre
-- would be included in this query, and not the band itself (provided the band has the Rock genre)

-- WITH young_artist AS (
--     SELECT 
--         artist_id,
--         band_id
--         name, 
--         EXTRACT(YEAR FROM AGE(CURRENT_DATE, birth_date)) AS age
--     FROM (artist UNION ALL band)
--     WHERE birth_date > CURRENT_DATE - INTERVAL '30 years'
-- ),
-- performance_artist AS (
--     SELECT artist_id FROM performance WHERE artist_id IS NOT NULL
--     UNION ALL
--     SELECT ba.artist_id 
--     FROM performance
--     JOIN band_artist ba USING (band_id)
-- )
-- SELECT 
--     ya.name,
--     COUNT(*) AS performances,
--     ya.age
-- FROM performance_artist pa
-- JOIN young_artist ya USING (artist_id)
-- GROUP BY ya.artist_id, ya.name, ya.age
-- ORDER BY performances DESC;


