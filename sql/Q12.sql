SELECT
    event.date_time::DATE as day,
    CEIL(SUM(capacity) * 0.02) AS assistant,
    CEIL(SUM(capacity) * 0.05) AS security,
    CEIL(SUM(capacity) * 0.02) + CEIL(SUM(capacity) * 0.05) AS total_personnel
FROM event
JOIN stage USING (stage_id)
GROUP BY event.date_time::DATE
ORDER BY day DESC


-- The above calculates the required personnel for everyday of the festival,
-- from the occupied stages and the requirement of 5% security, 2% assistants

-- The below, calculates the number of actually assigned employees per day on the festival.

-- SELECT
--     event.date_time::DATE as day,
--     COUNT(*) AS total_personnel,
--     COUNT(*) FILTER (WHERE job.name = 'Assistant') AS assistant,
--     COUNT(*) FILTER (WHERE job.name = 'Security') AS security,
--     COUNT(*) FILTER (WHERE job.name = 'Technical') AS technical
-- FROM event
-- JOIN event_personnel USING (event_id)
-- JOIN personnel USING (personnel_id)
-- JOIN job USING (job_id)
-- GROUP BY event.date_time::DATE
-- ORDER BY day ASC;

-- The above puts all roles of a single year in one row, while 
-- this puts the roles (including 'all roles') in different rows.

-- SELECT
--     event.date_time::DATE as day,
--     COALESCE(job.name, 'All Personnel') AS role,
--     COUNT(*) AS count
-- FROM event
-- JOIN event_personnel USING (event_id)
-- JOIN personnel USING (personnel_id)
-- JOIN job USING (job_id)
-- GROUP BY GROUPING SETS (
--     (event.date_time::DATE, job_id, job.name),
--     (event.date_time::DATE))
-- ORDER BY day ASC, role ASC