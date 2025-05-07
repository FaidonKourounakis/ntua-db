-- Dependencies

CREATE EXTENSION IF NOT EXISTS btree_gist;

-- Drop old triggers

DO $$ 
DECLARE
    r RECORD;
BEGIN
    -- Loop through all triggers in the database
    FOR r IN (SELECT trigger_name, event_object_table
              FROM information_schema.triggers
              WHERE trigger_schema = 'public')  -- Specify schema if needed (e.g., 'public')
    LOOP
        -- Drop each trigger dynamically
        EXECUTE 'DROP TRIGGER IF EXISTS ' || r.trigger_name || ' ON ' || r.event_object_table;
    END LOOP;
END $$;

-- Tables Declaration

-- Tables used as enums to restrict values

DROP TABLE IF EXISTS job CASCADE;
CREATE TABLE job (
    job_id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

DROP TABLE IF EXISTS payment_method CASCADE;
CREATE TABLE payment_method (
    payment_method_id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

DROP TABLE IF EXISTS ticket_category CASCADE;
CREATE TABLE ticket_category (
    ticket_category_id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

DROP TABLE IF EXISTS experience CASCADE;
CREATE TABLE experience (
    experience_id INT PRIMARY KEY CHECK (experience_id BETWEEN 1 AND 5),
    name VARCHAR(50) NOT NULL
);

DROP TABLE IF EXISTS performance_type CASCADE;
CREATE TABLE performance_type (
    performance_type_id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

DROP TABLE IF EXISTS continent CASCADE;
CREATE TABLE continent (
    continent_id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

-- Data tables

DROP TABLE IF EXISTS location CASCADE;
CREATE TABLE location (
    location_id SERIAL PRIMARY KEY,
    address VARCHAR(255) NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    city VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    continent_id INT NOT NULL REFERENCES continent(continent_id) ON DELETE RESTRICT
);

DROP TABLE IF EXISTS stage CASCADE;
CREATE TABLE stage (
    stage_id SERIAL PRIMARY KEY,
    location_id INT NOT NULL REFERENCES location(location_id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    capacity INT NOT NULL CHECK (capacity >= 0)
);

DROP TABLE IF EXISTS festival CASCADE;
CREATE TABLE festival (
    festival_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    begin_date DATE NOT NULL,
    end_date DATE NOT NULL,
    location_id INT NOT NULL REFERENCES location(location_id) ON DELETE CASCADE,
    
    festival_year INT GENERATED ALWAYS AS (EXTRACT(YEAR FROM begin_date)) STORED,
    CONSTRAINT same_begin_end_year CHECK (festival_year = EXTRACT(YEAR FROM end_date)),
    CONSTRAINT unique_festival_per_year UNIQUE (festival_year)
);

DROP TABLE IF EXISTS event CASCADE;
CREATE TABLE event (
    event_id SERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    festival_id INT NOT NULL REFERENCES festival(festival_id) ON DELETE RESTRICT,
    stage_id INT NOT NULL REFERENCES stage(stage_id) ON DELETE CASCADE,
    date_time TIMESTAMP NOT NULL,
    duration INTERVAL NOT NULL,


    CONSTRAINT stage_single_event_per_time EXCLUDE USING gist (
        stage_id WITH =,
        tsrange(date_time, date_time + duration, '[]') WITH &&
    )
);

DROP TABLE IF EXISTS stage_equipment CASCADE;
CREATE TABLE stage_equipment (
    stage_id INT NOT NULL REFERENCES stage(stage_id) ON DELETE CASCADE,
    equipment VARCHAR(100) NOT NULL,
    PRIMARY KEY (stage_id, equipment)
);

DROP TABLE IF EXISTS personnel CASCADE;
CREATE TABLE personnel (
    personnel_id SERIAL PRIMARY KEY,
    job_id INT NOT NULL REFERENCES job(job_id) ON DELETE RESTRICT,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    birth_date DATE NOT NULL,
    experience_id INT NOT NULL REFERENCES experience(experience_id) ON DELETE RESTRICT,
    email VARCHAR(100) NOT NULL UNIQUE CHECK (email ~'^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-z]{2,}$')
);

DROP TABLE IF EXISTS event_personnel CASCADE;
CREATE TABLE event_personnel (
    event_id INT NOT NULL REFERENCES event(event_id) ON DELETE RESTRICT,
    personnel_id INT NOT NULL REFERENCES personnel(personnel_id) ON DELETE CASCADE,
    PRIMARY KEY (event_id, personnel_id)
);

DROP TABLE IF EXISTS artist CASCADE;
CREATE TABLE artist (
    artist_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    nickname VARCHAR(100),
    birth_date DATE NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE CHECK (email ~'^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-z]{2,}$'),
    website VARCHAR(255),
    instagram VARCHAR(255),

    name VARCHAR(100) GENERATED ALWAYS AS (COALESCE(nickname, first_name || ' ' || last_name)) STORED
);

DROP TABLE IF EXISTS genre CASCADE;
CREATE TABLE genre (
    genre_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

DROP TABLE IF EXISTS subgenre CASCADE;
CREATE TABLE subgenre (
    genre_id INT NOT NULL REFERENCES genre(genre_id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    PRIMARY KEY (genre_id, name)
);

DROP TABLE IF EXISTS artist_subgenre CASCADE;
CREATE TABLE artist_subgenre (
    artist_id INT NOT NULL REFERENCES artist(artist_id) ON DELETE CASCADE,
    genre_id INT NOT NULL,
    subgenre_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (artist_id, genre_id, subgenre_name),
    FOREIGN KEY (genre_id, subgenre_name) REFERENCES subgenre(genre_id, name) ON DELETE CASCADE
);

DROP TABLE IF EXISTS band CASCADE;
CREATE TABLE band (
    band_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    established DATE NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE CHECK (email ~'^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-z]{2,}$'),
    website VARCHAR(255),
    instagram VARCHAR(255)
);

DROP TABLE IF EXISTS band_artist CASCADE;
CREATE TABLE band_artist (
    band_id INT NOT NULL REFERENCES band(band_id) ON DELETE CASCADE,
    artist_id INT NOT NULL REFERENCES artist(artist_id) ON DELETE CASCADE,
    PRIMARY KEY (band_id, artist_id)
);

DROP TABLE IF EXISTS band_subgenre CASCADE;
CREATE TABLE band_subgenre (
    band_id INT NOT NULL REFERENCES band(band_id) ON DELETE CASCADE,
    genre_id INT NOT NULL,
    subgenre_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (band_id, genre_id, subgenre_name),
    FOREIGN KEY (genre_id, subgenre_name) REFERENCES subgenre(genre_id, name) ON DELETE CASCADE
);

DROP TABLE IF EXISTS performance CASCADE;
CREATE TABLE performance (
    performance_id SERIAL PRIMARY KEY,
    event_id INT NOT NULL REFERENCES event(event_id) ON DELETE RESTRICT,
    stage_id INT NOT NULL REFERENCES stage(stage_id) ON DELETE CASCADE,
    date_time TIMESTAMP NOT NULL,
    duration INTERVAL NOT NULL CHECK (duration < '3 hours'),
    performance_type_id INT NOT NULL REFERENCES performance_type(performance_type_id) ON DELETE RESTRICT,
    artist_id INT REFERENCES artist(artist_id) ON DELETE CASCADE,
    band_id INT REFERENCES band(band_id) ON DELETE CASCADE CHECK (
        (artist_id IS NOT NULL AND band_id IS NULL) OR
        (artist_id IS NULL AND band_id IS NOT NULL)
    )
);

DROP TABLE IF EXISTS visitor CASCADE;
CREATE TABLE visitor (
    visitor_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(50),
    email VARCHAR(100) NOT NULL UNIQUE CHECK (email ~'^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-z]{2,}$'),
    birth_date DATE NOT NULL
);

DROP TABLE IF EXISTS ticket CASCADE;
CREATE TABLE ticket (
    visitor_id INT NOT NULL REFERENCES visitor(visitor_id) ON DELETE CASCADE,
    event_id INT NOT NULL REFERENCES event(event_id) ON DELETE RESTRICT,
    ticket_category_id INT NOT NULL REFERENCES ticket_category(ticket_category_id) ON DELETE RESTRICT,
    purchase_date_time TIMESTAMP NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    payment_method_id INT NOT NULL REFERENCES payment_method(payment_method_id) ON DELETE RESTRICT,
    barcode VARCHAR(20) NOT NULL,
    used BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (visitor_id, event_id)
);

DROP TABLE IF EXISTS resales_buyer CASCADE;
CREATE TABLE resales_buyer (
    visitor_id INT NOT NULL REFERENCES visitor(visitor_id) ON DELETE CASCADE,
    event_id INT NOT NULL REFERENCES event(event_id) ON DELETE RESTRICT,
    date_time TIMESTAMP NOT NULL,
    ticket_category_id INT NOT NULL REFERENCES ticket_category(ticket_category_id) ON DELETE RESTRICT,
    PRIMARY KEY (visitor_id, event_id)
);

DROP TABLE IF EXISTS resales_seller CASCADE;
CREATE TABLE resales_seller (
    visitor_id INT NOT NULL REFERENCES visitor(visitor_id) ON DELETE CASCADE,
    event_id INT NOT NULL REFERENCES event(event_id) ON DELETE RESTRICT,
    date_time TIMESTAMP NOT NULL,
    PRIMARY KEY (visitor_id, event_id),
    FOREIGN KEY (visitor_id, event_id) REFERENCES ticket(visitor_id, event_id) ON DELETE CASCADE
);

DROP TABLE IF EXISTS rating CASCADE;
CREATE TABLE rating (
    visitor_id INT NOT NULL REFERENCES visitor(visitor_id) ON DELETE CASCADE,
    performance_id INT NOT NULL REFERENCES performance(performance_id) ON DELETE CASCADE,
    artist_performance SMALLINT NOT NULL CHECK (artist_performance BETWEEN 1 AND 5),
    sound_lighting SMALLINT NOT NULL CHECK (sound_lighting BETWEEN 1 AND 5),
    stage_presence SMALLINT NOT NULL CHECK (stage_presence BETWEEN 1 AND 5),
    organization SMALLINT NOT NULL CHECK (organization BETWEEN 1 AND 5),
    overall_impression SMALLINT NOT NULL CHECK (overall_impression BETWEEN 1 AND 5),
    PRIMARY KEY (visitor_id, performance_id)
);

DROP TABLE IF EXISTS images CASCADE;
CREATE TABLE images (
    image_id SERIAL PRIMARY KEY,
    link VARCHAR(255) NOT NULL,
    description TEXT
);

DROP TABLE IF EXISTS festival_image CASCADE;
CREATE TABLE festival_image (
    festival_id INT NOT NULL REFERENCES festival(festival_id) ON DELETE RESTRICT,
    image_id INT NOT NULL REFERENCES images(image_id) ON DELETE CASCADE,
    PRIMARY KEY (festival_id, image_id)
);

DROP TABLE IF EXISTS artist_image CASCADE;
CREATE TABLE artist_image (
    artist_id INT NOT NULL REFERENCES artist(artist_id) ON DELETE CASCADE,
    image_id INT NOT NULL REFERENCES images(image_id) ON DELETE CASCADE,
    PRIMARY KEY (artist_id, image_id)
);

DROP TABLE IF EXISTS band_image CASCADE;
CREATE TABLE band_image (
    band_id INT NOT NULL REFERENCES band(band_id) ON DELETE CASCADE,
    image_id INT NOT NULL REFERENCES images(image_id) ON DELETE CASCADE,
    PRIMARY KEY (band_id, image_id)
);

DROP TABLE IF EXISTS stage_image CASCADE;
CREATE TABLE stage_image (
    stage_id INT NOT NULL REFERENCES stage(stage_id) ON DELETE CASCADE,
    image_id INT NOT NULL REFERENCES images(image_id) ON DELETE CASCADE,
    PRIMARY KEY (stage_id, image_id)
);

DROP TABLE IF EXISTS stage_equipment_image CASCADE;
CREATE TABLE stage_equipment_image (
    stage_id INT NOT NULL REFERENCES stage(stage_id) ON DELETE CASCADE,
    equipment VARCHAR(100) NOT NULL,
    image_id INT NOT NULL REFERENCES images(image_id) ON DELETE CASCADE,
    PRIMARY KEY (stage_id, equipment, image_id),
    FOREIGN KEY (stage_id, equipment) REFERENCES stage_equipment(stage_id, equipment) ON DELETE CASCADE
);


-- Indexes

-- Many indexes are ommited due to being impliciτ (primary keys)
-- Also some queries already benefit from indexes for previous queries

-- Speedup resales triggers

DROP INDEX IF EXISTS idx_resales_buyer_event_category_date;
CREATE INDEX idx_resales_buyer_event_category_date ON resales_buyer(event_id, ticket_category_id, date_time);

DROP INDEX IF EXISTS idx_resales_seller_event_date;
CREATE INDEX idx_resales_seller_event_date ON resales_seller(event_id, date_time);

DROP INDEX IF EXISTS idx_ticket_event_category_used;
CREATE INDEX idx_ticket_event_category_used ON ticket(event_id, ticket_category_id, used);

-- Q01
CREATE INDEX idx_ticket_event_id_payment_method_id ON ticket(event_id, payment_method_id)
CREATE INDEX idx_event_festival_id ON event(festival_id);
CREATE INDEX idx_festival_year ON festival(festival_year);

-- Q02
CREATE INDEX idx_performance_year_date_time ON performance (EXTRACT(YEAR FROM date_time));
CREATE INDEX idx_performance_artist_id ON performance(artist_id);
CREATE INDEX idx_performance_band_id ON performance(band_id);
CREATE INDEX idx_performance_event_id ON performance(event_id);
CREATE INDEX idx_artist_subgenre_genre_id ON artist_subgenre(genre_id);
CREATE INDEX idx_band_subgenre_genre_id ON band_subgenre(genre_id);
CREATE INDEX idx_genre_name ON genre(name);

-- Q03
CREATE INDEX idx_performance_type_event_artist_band ON performance(performance_type_id, event_id, artist_id, band_id);

-- Q04
CREATE INDEX idx_rating_performance ON rating(performance_id);

-- Q05
CREATE INDEX idx_artist_birth_date ON artist(birth_date);
CREATE INDEX idx_band_established ON band(established);

-- Q07
CREATE INDEX idx_job_name ON job(name);
CREATE INDEX idx_personnel_job_id ON personnel(job_id);

-- Q08
CREATE INDEX idx_event_date_time ON event (date_time);

-- Q09
CREATE INDEX idx_ticket_used ON ticket (used, event_id, visitor_id);

-- Q

-- Triggers for constraint enforcement

-- (Some of the following constraints are simple, yet putting them as table checks could lead to incosistency,
-- as checks are only meant to check values of the new/updated row, not access other rows/tables.)

-- In order to defer constraints/checks:
-- BEGIN;
-- SET CONSTRAINTS ALL DEFERRED
-- ALTER TABLE my_table DISABLE TRIGGER my_trigger;
-- ...
-- ...statements
-- ...
-- ALTER TABLE my_table ENABLE TRIGGER my_trigger;
-- END
    
CREATE OR REPLACE FUNCTION event_during_festival()
RETURNS TRIGGER AS $$
DECLARE
  festival_row festival;
BEGIN
  SELECT INTO festival_row * FROM festival WHERE festival_id = NEW.festival_id;
  IF NEW.date_time < festival_row.begin_date OR
     (NEW.date_time + NEW.duration) > (festival_row.end_date + INTERVAL '1 day') THEN
    RAISE EXCEPTION 'Event dates must fall within festival % (% to %)',
      NEW.festival_id, festival_row.begin_date, festival_row.end_date;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_event_during_festival
BEFORE INSERT OR UPDATE ON event
FOR EACH ROW EXECUTE FUNCTION event_during_festival();

CREATE OR REPLACE FUNCTION personnel_requirements()
RETURNS TRIGGER AS $$
DECLARE
    stage_capacity INT;
    security_count INT;
    assistant_count INT;
    violation_text TEXT;
BEGIN
    SELECT string_agg(
        format('Event %s: Security (%s/%s) | Assistants (%s/%s)',
               e.event_id,
               pc.security_count, ceil(st.capacity * 0.05),
               pc.assistant_count, ceil(st.capacity * 0.02)),
        E'\n'
    )
    INTO violation_text
    FROM (
        SELECT
            event_id,
            stage_id,
            COUNT(CASE WHEN job.name = 'Security' THEN 1 END) AS security_count,
            COUNT(CASE WHEN job.name = 'Assistant' THEN 1 END) AS assistant_count
        FROM events e
        LEFT JOIN event_personnel USING (event_id)
        LEFT JOIN personnel USING (personnel_id)
        LEFT JOIN job USING (job_id)
        GROUP BY event_id, stage_id
    )
    JOIN stage USING (stage_id)
    WHERE security_count < 0.05 * capacity OR assistant_count < 0.02 * st.capacity;
    
    IF violation_text IS NOT NULL THEN
        RAISE EXCEPTION 'Personnel requirements not met:%\n%s',
            	E'\n-----------------------------',
            violation_text
        USING HINT = 'Add Security and/or Assistant personnel to these events';
    END IF;

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_personnel_requirements_on_personnel
AFTER UPDATE OR DELETE ON event_personnel
FOR EACH STATEMENT EXECUTE FUNCTION personnel_requirements();

CREATE TRIGGER trigger_personnel_requirements_on_event
AFTER INSERT OR UPDATE ON event
FOR EACH STATEMENT EXECUTE FUNCTION personnel_requirements();

CREATE OR REPLACE FUNCTION performance_duration_breaks()
RETURNS TRIGGER AS $$
DECLARE
--   event_begin TIMESTAMP;
--   event_end TIMESTAMP;
--   prev_end TIMESTAMP;
--   next_start TIMESTAMP;
--   gap_before INTERVAL;
--   gap_after INTERVAL;
BEGIN
    -- 1. Check if performance is within the festival's dates
    IF EXISTS (
        SELECT 1
        FROM event e
        WHERE 
            e.event_id = NEW.event_id AND
            (NEW.date_time < e.date_time OR NEW.date_time + NEW.duration > event_end))
    THEN RAISE EXCEPTION 'Performance not within event duration'
    END IF;

    -- 2. Check breaks between performances
    IF EXISTS (
        WITH t AS (
            SELECT date_time, (date_time + duration) AS end_time
            FROM performance
            WHERE event_id = NEW.event_id AND performance_id IS DISTINCT FROM NEW.performance_id
            ORDER BY date_time) 
        SELECT 1
        FROM (
            SELECT (NEW.date_time - MAX(end_time)) AS break
            FROM t
            WHERE date_time < NEW.date_time
            UNION ALL
            SELECT (MIN(date_time) - (NEW.date_time + NEW.duration)) AS break
            FROM t
            WHERE date_time > NEW.date_time)
        WHERE break < '5 minutes' OR break > '30 minutes'
    ) THEN RAISE EXCEPTION 'Performance break before or after is out of bounds (5-30 min)'
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_performance_duration_breaks
BEFORE INSERT OR UPDATE ON performance
FOR EACH ROW EXECUTE FUNCTION performance_duration_breaks();

-- CREATE OR REPLACE FUNCTION prevent_delete()
-- RETURNS TRIGGER AS $$
-- BEGIN
--     RAISE EXCEPTION 'Deletion (Cancellation) of events or festivals is not allowed';
-- END;
-- $$ LANGUAGE plpgsql;

-- CREATE TRIGGER trigger_prevent_delete_festival
-- BEFORE DELETE ON festival FOR EACH STATEMENT EXECUTE FUNCTION prevent_delete();

-- CREATE TRIGGER trigger_prevent_delete_event
-- BEFORE DELETE ON event FOR EACH STATEMENT EXECUTE FUNCTION prevent_delete();

CREATE OR REPLACE FUNCTION check_artist_overlap()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        WITH involved_artists AS (
            SELECT NEW.artist_id AS artist_id
            WHERE NEW.artist_id IS NOT NULL
            UNION ALL
            SELECT artist_id
            FROM band_artist
            WHERE band_id = NEW.band_id
        )
        SELECT 1
        FROM performance p
        WHERE (
            p.artist_id IN (SELECT artist_id FROM involved_artists)
            OR EXISTS (
                SELECT 1
                FROM band_artist ba
                WHERE ba.band_id = p.band_id
                AND ba.artist_id IN (SELECT artist_id FROM involved_artists)
            )
        )
        AND (p.date_time, p.date_time + p.duration) 
            OVERLAPS (NEW.date_time, NEW.date_time + NEW.duration)
        AND p.performance_id IS DISTINCT FROM NEW.performance_id
    ) THEN
        RAISE EXCEPTION 'Artist(s) have overlapping performances';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_check_artist_overlap
BEFORE INSERT OR UPDATE ON performance
FOR EACH ROW EXECUTE FUNCTION check_artist_overlap();

CREATE OR REPLACE FUNCTION limit_consecutive_artist_festivals()
RETURNS TRIGGER AS $$
BEGIN    
    IF EXISTS (
        WITH involved_artists AS (
            SELECT NEW.artist_id AS artist_id
            WHERE NEW.artist_id IS NOT NULL
            UNION ALL
            SELECT artist_id FROM band_artist
            WHERE band_id = NEW.band_id
        ), all_years AS (
            SELECT DISTINCT
                ia.artist_id,
                EXTRACT(YEAR FROM p.date_time)::INT AS performance_year
            FROM involved_artists ia
            LEFT JOIN performance p ON p.artist_id = ia.artist_id
            OR p.band_id IN (SELECT band_id FROM band_artist WHERE artist_id = ia.artist_id)
            UNION
            SELECT DISTINCT
                ia.artist_id,
                EXTRACT(YEAR FROM NEW.date_time)::INT AS performance_year
            FROM involved_artists ia
        ), consecutive_check AS (
            -- Check for 4+ consecutive years using window functions
            SELECT artist_id, performance_year - ROW_NUMBER() OVER (
                PARTITION BY artist_id ORDER BY performance_year
            ) AS consecutive_group_id
            FROM all_years
        )
        SELECT 1
        FROM consecutive_check
        GROUP BY artist_id, consecutive_group_id
        HAVING COUNT(*) >= 4
    ) THEN
        RAISE EXCEPTION 'Artist(s) cannot perform for more than 3 consecutive years';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_limit_consecutive_artist_festivals
BEFORE INSERT OR UPDATE ON performance
FOR EACH ROW EXECUTE FUNCTION limit_consecutive_artist_festivals();

CREATE OR REPLACE FUNCTION limit_ticket_count_on_insert()
RETURNS TRIGGER AS $$
DECLARE
    max_capacity INT;
    tickets_sold INT;
    vip_sold INT;
    exception_message TEXT;
BEGIN
    SELECT s.capacity INTO max_capacity
    FROM event e
    JOIN stage s ON e.stage_id = s.stage_id
    WHERE e.event_id = NEW.event_id;

    SELECT COUNT(*), SUM(CASE WHEN ticket_category.name = 'VIP' THEN 1 ELSE 0 END) 
    INTO tickets_sold, vip_sold
    FROM ticket
    JOIN ticket_category USING (ticket_category_id)
    WHERE event_id = NEW.event_id;

    IF tickets_sold >= max_capacity THEN
        exception_message := format('Ticket count (%s) will exceed stage capacity (%s).', tickets_sold, max_capacity);
        RAISE EXCEPTION '%', exception_message;
    END IF;
    IF vip_sold >= 0.1 * max_capacity THEN
        exception_message := format('VIP Ticket count (%s) will exceed 10%% of stage capacity (%s).', vip_sold, max_capacity);
        RAISE EXCEPTION '%', exception_message;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trigger_limit_ticket_count_on_insert
BEFORE INSERT ON ticket
FOR EACH ROW EXECUTE FUNCTION limit_ticket_count_on_insert();

CREATE OR REPLACE FUNCTION add_resales_buyer()
RETURNS TRIGGER AS $$
DECLARE
    seller_id INT;
BEGIN
    -- Find a matching seller offer:
    SELECT rs.visitor_id
    INTO seller_id
    FROM resales_seller rs
    JOIN ticket t ON t.visitor_id = rs.visitor_id AND t.event_id = rs.event_id
    WHERE rs.event_id = NEW.event_id
      AND t.ticket_category_id = NEW.ticket_category_id
      AND t.used = FALSE  -- only consider unused tickets
    ORDER BY rs.date_time ASC
    LIMIT 1;
    
    IF FOUND THEN
        -- Transfer the ticket: change the ticket owner from the seller to the new buyer.
        UPDATE ticket
        SET visitor_id = NEW.visitor_id
        WHERE visitor_id = seller_id
          AND event_id = NEW.event_id;
          
        -- Remove the seller's resale offer.
        DELETE FROM resales_seller
        WHERE visitor_id = seller_id
          AND event_id = NEW.event_id;
          
        -- Skip inserting the buyer row since the resale is now complete.
        RETURN NULL;
    ELSE
        -- No matching seller found: proceed with inserting the buyer offer.
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_add_resales_buyer
BEFORE INSERT ON resales_buyer
FOR EACH ROW EXECUTE FUNCTION add_resales_buyer();

CREATE OR REPLACE FUNCTION add_resales_seller()
RETURNS TRIGGER AS $$
DECLARE
    seller_ticket_category_id; INT
    buyer_id INT; -- Specify data type
    ticket_used BOOLEAN;
BEGIN
    SELECT t.ticket_category_id, t.used
      INTO seller_ticket_category_id, ticket_used
    FROM ticket t
    WHERE t.visitor_id = NEW.visitor_id
      AND t.event_id = NEW.event_id;
      
    IF ticket_used THEN
        RAISE EXCEPTION 'Cannot offer resale: Ticket is already used.';
    END IF;
      
    -- Look for a matching buyer offer based on event and category.
    SELECT rb.visitor_id
      INTO buyer_id
    FROM resales_buyer rb
    WHERE rb.event_id = NEW.event_id
      AND rb.ticket_category_id = seller_ticket_category_id
    ORDER BY rb.date_time ASC
    LIMIT 1;
    
    IF FOUND THEN
        -- Transfer ticket ownership from seller to buyer.
        UPDATE ticket
        SET visitor_id = buyer_id
        WHERE visitor_id = NEW.visitor_id
          AND event_id = NEW.event_id;
          
        -- Remove the buyer offer since the resale is complete.
        DELETE FROM resales_buyer
        WHERE visitor_id = buyer_id
          AND event_id = NEW.event_id;
          
        -- Cancel the insertion of the seller row.
        RETURN NULL;
    ELSE
        -- No matching buyer: allow the seller offer to be inserted.
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Fix trigger syntax
CREATE TRIGGER trigger_add_resales_seller
BEFORE INSERT ON resales_seller
FOR EACH ROW EXECUTE FUNCTION add_resales_seller();

