SELECT
    event.date_time::DATE as day,
    COUNT(*) AS total_personnel,
    COUNT(*) FILTER (WHERE job.name = 'Assistant') AS assistant,
    COUNT(*) FILTER (WHERE job.name = 'Security') AS security,
    COUNT(*) FILTER (WHERE job.name = 'Technical') AS technical
FROM event
JOIN event_personnel USING (event_id)
JOIN personnel USING (personnel_id)
JOIN job USING (job_id)
GROUP BY event.date_time::DATE
ORDER BY day ASC;


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