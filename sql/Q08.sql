WITH vars AS (SELECT
    '2023-07-23'::DATE AS target_date)
SELECT personnel_id, first_name, last_name
FROM personnel
JOIN job USING (job_id)
WHERE 
    personnel_id NOT IN (
        SELECT personnel_id
        FROM personnel
        JOIN event_personnel USING (personnel_id)
        JOIN event USING (event_id)
        JOIN vars ON event.date_time::DATE = target_date)
    AND job.name = 'Assistant';