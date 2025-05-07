SELECT 
    name AS "Festival with min. avg. exp. of technical personnel",
    yr AS "Year",
    avg_experience AS "Average Experience (1-5)"
FROM (
    SELECT 
        ANY_VALUE(festival.festival_year) AS yr, 
        ANY_VALUE(festival.name) AS name, 
        AVG(personnel.experience_id) AS avg_experience
    FROM personnel
    JOIN event_personnel USING (personnel_id)
    JOIN event USING (event_id)
    JOIN festival USING (festival_id)
    JOIN job USING (job_id)
    WHERE job.name = 'Technical'
    GROUP BY festival_id)
ORDER BY avg_experience ASC
LIMIT 1;