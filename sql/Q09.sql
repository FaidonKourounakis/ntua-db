SELECT visitor_id, first_name, last_name, year, attendances
FROM (
    SELECT 
        visitor_id, 
        EXTRACT(YEAR FROM event.date_time) AS year, 
        COUNT(*) AS attendances
    FROM ticket
    JOIN event USING (event_id)
    WHERE ticket.used = TRUE
    GROUP BY visitor_id, EXTRACT(YEAR FROM event.date_time))
JOIN visitor USING (visitor_id)
WHERE attendances > 3
ORDER BY year DESC, attendances DESC;