WITH vars AS (
  SELECT 1234 AS target_visitor_id
)
SELECT
  event_id,
  ANY_VALUE(event.title) AS event_title,
  (AVG(artist_performance)
    + AVG(sound_lighting)
    + AVG(stage_presence)
    + AVG(organization)
    + AVG(overall_impression)) / 5 AS average_event_rating
FROM visitor
JOIN vars ON visitor_id = target_visitor_id
JOIN ticket USING (visitor_id)
JOIN performance USING (event_id)
JOIN event USING (event_id)
LEFT JOIN rating USING (visitor_id, performance_id)
WHERE ticket.used = TRUE
GROUP BY event_id;

SELECT 'Sequential Scans + Nested Loop Join' AS "Combination 1";
SET enable_seqscan = on;
SET enable_indexscan = off;
SET enable_nestloop = on;
SET enable_hashjoin = off;
SET enable_mergejoin = off;

EXPLAIN ANALYZE
WITH vars AS (
  SELECT 1234 AS target_visitor_id
)
SELECT
  event_id,
  ANY_VALUE(event.title) AS event_title,
  (AVG(artist_performance)
    + AVG(sound_lighting)
    + AVG(stage_presence)
    + AVG(organization)
    + AVG(overall_impression)) / 5 AS average_event_rating
FROM visitor
JOIN vars ON visitor_id = target_visitor_id
JOIN ticket USING (visitor_id)
JOIN performance USING (event_id)
JOIN event USING (event_id)
LEFT JOIN rating USING (visitor_id, performance_id)
WHERE ticket.used = TRUE
GROUP BY event_id;

SELECT 'Sequential Scans + Hash Join' AS "Combination 2";
SET enable_nestloop = off;
SET enable_hashjoin = on;

EXPLAIN ANALYZE
WITH vars AS (
  SELECT 1234 AS target_visitor_id
)
SELECT
  event_id,
  ANY_VALUE(event.title) AS event_title,
  (AVG(artist_performance)
    + AVG(sound_lighting)
    + AVG(stage_presence)
    + AVG(organization)
    + AVG(overall_impression)) / 5 AS average_event_rating
FROM visitor
JOIN vars ON visitor_id = target_visitor_id
JOIN ticket USING (visitor_id)
JOIN performance USING (event_id)
JOIN event USING (event_id)
LEFT JOIN rating USING (visitor_id, performance_id)
WHERE ticket.used = TRUE
GROUP BY event_id;

SELECT 'Sequential Scans + Merge Join' AS "Combination 3";
SET enable_hashjoin = off;
SET enable_mergejoin = on;

EXPLAIN ANALYZE
WITH vars AS (
  SELECT 1234 AS target_visitor_id
)
SELECT
  event_id,
  ANY_VALUE(event.title) AS event_title,
  (AVG(artist_performance)
    + AVG(sound_lighting)
    + AVG(stage_presence)
    + AVG(organization)
    + AVG(overall_impression)) / 5 AS average_event_rating
FROM visitor
JOIN vars ON visitor_id = target_visitor_id
JOIN ticket USING (visitor_id)
JOIN performance USING (event_id)
JOIN event USING (event_id)
LEFT JOIN rating USING (visitor_id, performance_id)
WHERE ticket.used = TRUE
GROUP BY event_id;

SELECT 'Force Index Scans + Nested Loop Join' AS "Combination 4";
SET enable_seqscan = off;
SET enable_indexscan = on;
SET enable_nestloop = on;
SET enable_mergejoin = off;

EXPLAIN ANALYZE
WITH vars AS (
  SELECT 1234 AS target_visitor_id
)
SELECT
  event_id,
  ANY_VALUE(event.title) AS event_title,
  (AVG(artist_performance)
    + AVG(sound_lighting)
    + AVG(stage_presence)
    + AVG(organization)
    + AVG(overall_impression)) / 5 AS average_event_rating
FROM visitor
JOIN vars ON visitor_id = target_visitor_id
JOIN ticket USING (visitor_id)
JOIN performance USING (event_id)
JOIN event USING (event_id)
LEFT JOIN rating USING (visitor_id, performance_id)
WHERE ticket.used = TRUE
GROUP BY event_id;

SELECT 'Force Index Scans + Hash Join' AS "Combination 5";
SET enable_nestloop = off;
SET enable_hashjoin = on;

EXPLAIN ANALYZE
WITH vars AS (
  SELECT 1234 AS target_visitor_id
)
SELECT
  event_id,
  ANY_VALUE(event.title) AS event_title,
  (AVG(artist_performance)
    + AVG(sound_lighting)
    + AVG(stage_presence)
    + AVG(organization)
    + AVG(overall_impression)) / 5 AS average_event_rating
FROM visitor
JOIN vars ON visitor_id = target_visitor_id
JOIN ticket USING (visitor_id)
JOIN performance USING (event_id)
JOIN event USING (event_id)
LEFT JOIN rating USING (visitor_id, performance_id)
WHERE ticket.used = TRUE
GROUP BY event_id;

SELECT 'Force Index Scans + Merge Join' AS "Combination 6";
SET enable_hashjoin = off;
SET enable_mergejoin = on;

EXPLAIN ANALYZE
WITH vars AS (
  SELECT 1234 AS target_visitor_id
)
SELECT
  event_id,
  ANY_VALUE(event.title) AS event_title,
  (AVG(artist_performance)
    + AVG(sound_lighting)
    + AVG(stage_presence)
    + AVG(organization)
    + AVG(overall_impression)) / 5 AS average_event_rating
FROM visitor
JOIN vars ON visitor_id = target_visitor_id
JOIN ticket USING (visitor_id)
JOIN performance USING (event_id)
JOIN event USING (event_id)
LEFT JOIN rating USING (visitor_id, performance_id)
WHERE ticket.used = TRUE
GROUP BY event_id;

-- Reset planner settings to default after testing
RESET enable_seqscan;
RESET enable_indexscan;
RESET enable_nestloop;
RESET enable_hashjoin;
RESET enable_mergejoin;
