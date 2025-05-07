WITH vars AS (SELECT
    42 AS target_artist_id)
SELECT 
    ANY_VALUE(artist.name) AS name,
    ROUND(AVG(artist_performance)::numeric, 2) AS average_artist_performance,
    ROUND(AVG(overall_impression)::numeric, 2) AS average_overal_impression
FROM performance
JOIN artist USING (artist_id)
JOIN rating USING (performance_id)
JOIN vars ON artist_id = target_artist_id
GROUP BY artist_id;

SELECT 'Sequential Scans + Nested Loop Join' AS "Combination 1";
SET enable_seqscan = on;
SET enable_indexscan = off;
SET enable_nestloop = on;
SET enable_hashjoin = off;
SET enable_mergejoin = off;

EXPLAIN ANALYZE
WITH vars AS (SELECT
    42 AS target_artist_id)
SELECT 
    ANY_VALUE(artist.name) AS name,
    ROUND(AVG(artist_performance)::numeric, 2) AS average_artist_performance,
    ROUND(AVG(overall_impression)::numeric, 2) AS average_overal_impression
FROM performance
JOIN artist USING (artist_id)
JOIN rating USING (performance_id)
JOIN vars ON artist_id = target_artist_id
GROUP BY artist_id;

SELECT 'Sequential Scans + Hash Join' AS "Combination 2";
SET enable_nestloop = off;
SET enable_hashjoin = on;

EXPLAIN ANALYZE
WITH vars AS (SELECT
    42 AS target_artist_id)
SELECT 
    ANY_VALUE(artist.name) AS name,
    ROUND(AVG(artist_performance)::numeric, 2) AS average_artist_performance,
    ROUND(AVG(overall_impression)::numeric, 2) AS average_overal_impression
FROM performance
JOIN artist USING (artist_id)
JOIN rating USING (performance_id)
JOIN vars ON artist_id = target_artist_id
GROUP BY artist_id;

SELECT 'Sequential Scans + Merge Join' AS "Combination 3";
SET enable_hashjoin = off;
SET enable_mergejoin = on;

EXPLAIN ANALYZE
WITH vars AS (SELECT
    42 AS target_artist_id)
SELECT 
    ANY_VALUE(artist.name) AS name,
    ROUND(AVG(artist_performance)::numeric, 2) AS average_artist_performance,
    ROUND(AVG(overall_impression)::numeric, 2) AS average_overal_impression
FROM performance
JOIN artist USING (artist_id)
JOIN rating USING (performance_id)
JOIN vars ON artist_id = target_artist_id
GROUP BY artist_id;

SELECT 'Force Index Scans + Nested Loop Join' AS "Combination 4";
SET enable_seqscan = off;
SET enable_indexscan = on;
SET enable_nestloop = on;
SET enable_mergejoin = off;

EXPLAIN ANALYZE
WITH vars AS (SELECT
    42 AS target_artist_id)
SELECT 
    ANY_VALUE(artist.name) AS name,
    ROUND(AVG(artist_performance)::numeric, 2) AS average_artist_performance,
    ROUND(AVG(overall_impression)::numeric, 2) AS average_overal_impression
FROM performance
JOIN artist USING (artist_id)
JOIN rating USING (performance_id)
JOIN vars ON artist_id = target_artist_id
GROUP BY artist_id;

SELECT 'Force Index Scans + Hash Join' AS "Combination 5";
SET enable_nestloop = off;
SET enable_hashjoin = on;

EXPLAIN ANALYZE
WITH vars AS (SELECT
    42 AS target_artist_id)
SELECT 
    ANY_VALUE(artist.name) AS name,
    ROUND(AVG(artist_performance)::numeric, 2) AS average_artist_performance,
    ROUND(AVG(overall_impression)::numeric, 2) AS average_overal_impression
FROM performance
JOIN artist USING (artist_id)
JOIN rating USING (performance_id)
JOIN vars ON artist_id = target_artist_id
GROUP BY artist_id;

SELECT 'Force Index Scans + Merge Join' AS "Combination 6";
SET enable_hashjoin = off;
SET enable_mergejoin = on;

EXPLAIN ANALYZE
WITH vars AS (SELECT
    42 AS target_artist_id)
SELECT 
    ANY_VALUE(artist.name) AS name,
    ROUND(AVG(artist_performance)::numeric, 2) AS average_artist_performance,
    ROUND(AVG(overall_impression)::numeric, 2) AS average_overal_impression
FROM performance
JOIN artist USING (artist_id)
JOIN rating USING (performance_id)
JOIN vars ON artist_id = target_artist_id
GROUP BY artist_id;

-- Reset planner settings to default after testing
RESET enable_seqscan;
RESET enable_indexscan;
RESET enable_nestloop;
RESET enable_hashjoin;
RESET enable_mergejoin;
