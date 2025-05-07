SELECT
    f.festival_year AS "Festival Year",
    SUM(t.price) AS "Total Income",
    ROUND((100.0 * SUM(t.price) FILTER (WHERE pm.name = 'Credit')) / SUM(t.price), 2) 
        AS "Credit (%)",
    ROUND((100.0 * SUM(t.price) FILTER (WHERE pm.name = 'Debit')) / SUM(t.price), 2)
        AS "Debit (%)",
    ROUND((100.0 * SUM(t.price) FILTER (WHERE pm.name = 'Bank Transfer')) / SUM(t.price), 2)
        AS "Bank Transfer (%)"
FROM ticket t
JOIN event e USING (event_id)
JOIN festival f USING (festival_id)
LEFT JOIN payment_method pm USING (payment_method_id)
GROUP BY f.festival_year
ORDER BY f.festival_year;


-- The above puts all categories of a single year in one row, while 
-- this puts the categories (including 'All Categories') in different rows.

-- SELECT
--     festival_year,
--     COALESCE(ticket_category.name, 'All Categories') AS category,
--     SUM(price) AS total_income
-- FROM ticket t
-- JOIN event e USING (event_id)
-- JOIN festival f USING (festival_id)
-- LEFT JOIN ticket_category USING (ticket_category_id)
-- GROUP BY GROUPING SETS (
--     (festival_year, ticket_category.name),  -- Income per year per category
--     (festival_year)               -- Total income per year
-- )
-- ORDER BY f.festival_year, category;