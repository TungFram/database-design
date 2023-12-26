

CREATE TABLE public.client(
    client_id       SERIAL PRIMARY KEY,
    name            TEXT,
    surname         TEXT,
    password_hash   TEXT,
    email            TEXT,
    bio             TEXT,
    registered_at       DATE NOT NULL,
    last_logged_on      DATE NOT NULL,
    status              BOOLEAN DEFAULT false

);



INSERT INTO public.client(
    name,
    surname,
    password_hash,
    email,
    bio,
    registered_at,
    last_logged_on,
    status
)
SELECT
    substr(md5(random()::text), 0, (random() * 10 + 1)::int4) AS name,
    substr(md5(random()::text), 0, (random() * 10 + 1)::int4) AS surname,
    substr(md5(random()::text), 0, 32) AS password_hash,
    substr(md5(random()::text), 0, (random() * 10)::int4) || '@' || (
    CASE (RANDOM() * 2)::INT
        WHEN 0 THEN 'gmail'
        WHEN 1 THEN 'rambler'
        WHEN 2 THEN 'yahoo'
    END
    ) || '.com' AS email,
    substr(md5(random()::text), 0, (random() * 20)::int4) AS bio,
    (now() - '10 years'::interval * random())::date AS registered_at,
    (now() - '10 years'::interval * random())::date AS last_logged_on,
    (round(random())::int)::boolean
FROM
    generate_series(1, 10000000);





-- CREATE FUNCTION create_date_bounds(
--     d_from timestamp with time zone,
--     d_to timestamp with time zone
-- )
--     RETURNS VOID
--     AS
--     $$
--     DECLARE
--         date_from ALIAS FOR $1;
--         date_to ALIAS FOR $2;
--         table_name TEXT := 'public.date_bounds';
--     BEGIN
--         EXECUTE format('CREATE TABLE ' || table_name || '( id SERIAL, month DATE)');
--         EXECUTE format('INSERT INTO ' || table_name || ' ( month )' ||
--                        'SELECT * FROM' ||
--                        'generate_series(' ||
--                             'date_trunc(''month'', '|| date_from ||' ),' ||
--                             'date_trunc(''month'', '|| date_to ||'),' ||
--                             '1 month' ||
--                        ')::date AS month' ||
--                        'ORDER BY 1'
--                 );
--     END;
--     $$
-- LANGUAGE plpgsql;

CREATE TABLE date_bounds ( id SERIAL PRIMARY KEY , month DATE);
-- https://stackoverflow.com/questions/41232002/create-a-row-for-every-month-between-2-dates-in-postgresql
INSERT INTO date_bounds  ( month )
SELECT
generate_series(
    date_trunc('month',  (SELECT min(last_logged_on) FROM client)),
    date_trunc('month', (SELECT (max(last_logged_on)+('1 month'::interval * 1)) FROM client)),
    '1 month'
)::date
ORDER BY 1;

SELECT * FROM public.date_bounds;
SELECT date_trunc('month',(max(last_logged_on)+('1 month'::interval * 1)))::date FROM client;
DO
    $$
    DECLARE
        table_name TEXT := 'client';
        range_field TEXT := 'last_logged_on';
        curr_partition_name TEXT;
        next_i INT;
        curr_date DATE;
        curr_date_text TEXT;
        next_date DATE;
        next_date_text TEXT;
    BEGIN
        SET constraint_exclusion = partition;
        FOR i IN 1..(SELECT COUNT(*) FROM date_bounds)-1
        LOOP
            next_i := i + 1;
            curr_date := (SELECT month FROM date_bounds AS db WHERE db.id = i);
            next_date := (SELECT month FROM date_bounds AS db WHERE db.id = next_i);
            curr_date_text := TO_CHAR(curr_date, 'annumYYYY_mMM');
            next_date_text := TO_CHAR(next_date, 'annumYYYY_mMM');
            curr_partition_name := format( '' ||table_name|| '_' ||curr_date_text|| '' );

			raise notice 'tablename: %', curr_partition_name;
            EXECUTE format('CREATE TABLE '||curr_partition_name||' (LIKE '||table_name||' INCLUDING ALL);');
            EXECUTE format('ALTER TABLE '||curr_partition_name||' ADD CONSTRAINT '||curr_date_text||' '||
                'CHECK ( '||range_field||' >= '''||curr_date||''' AND '||range_field||' < '''||next_date||''' );');
            EXECUTE format('ALTER TABLE '||curr_partition_name||' INHERIT '||table_name||';');
            EXECUTE format('CREATE INDEX '||curr_partition_name||'_'||range_field||' ON '||curr_partition_name||' ('||range_field||');');
        END LOOP;

    END;
    $$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION client_insert_partitions_trigger()
RETURNS TRIGGER AS $$
    DECLARE
        table_name TEXT := 'client';
        curr_partition_name TEXT;
        curr_date DATE;
        curr_date_text TEXT;
    BEGIN
        curr_date := date_trunc('month',  NEW.last_logged_on);
        curr_date_text := TO_CHAR(curr_date, 'annumYYYY_mMM');
        curr_partition_name := format( '' ||table_name|| '_' ||curr_date_text|| '' );
        EXECUTE 'INSERT INTO ' || curr_partition_name || ' VALUES ( ($1).* )' USING NEW;
        RETURN NULL;
    END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER partition_clients BEFORE INSERT ON client FOR EACH ROW EXECUTE PROCEDURE client_insert_partitions_trigger();

-- DO
--     $$
--     DECLARE
--         table_name TEXT := 'client';
--         curr_partition_name TEXT;
--         curr_date DATE;
--         curr_date_text TEXT;
--     BEGIN
--         FOR i IN 1..(SELECT COUNT(*) FROM date_bounds)-1
--         LOOP
--             curr_date := (SELECT month FROM date_bounds AS db WHERE db.id = i);
--             curr_date_text := TO_CHAR(curr_date, 'annumYYYY_mMM');
--             curr_partition_name := format( '' ||table_name|| '_' ||curr_date_text|| '' );
--             EXECUTE format('DROP TABLE '||curr_partition_name||';');
--             END LOOP;
--
--     END;
--     $$
-- LANGUAGE plpgsql;
-- DROP TRIGGER partition_clients ON client;
-- DROP FUNCTION client_insert_partitions_trigger;
-- DROP TABLE client;
-- DROP TABLE date_bounds;

INSERT INTO public.client(
    name,
    surname,
    password_hash,
    email,
    bio,
    registered_at,
    last_logged_on,
    status
)
VALUES
(
 'test_name',
 'test_surname',
 'test_password_hash',
 'test_email',
 'test_bio',
 (now() - '10 years'::interval * random())::date,
 (now() - '10 years'::interval * random())::date,
 false
);
-- SELECT * FROM client WHERE name = 'test_name';
-- EXPLAIN ANALYSE SELECT * FROM client WHERE last_logged_on = DATE '2019-07-07'; -- Works.
-- EXPLAIN ANALYSE SELECT * FROM client WHERE last_logged_on = (SELECT last_logged_on FROM client WHERE name = 'test_name'); -- Does not work.

-- SELECT * FROM ONLY client WHERE name = 'test_name';


DO
    $$
    DECLARE
        table_name TEXT := 'client';
        range_field TEXT := 'last_logged_on';
        curr_partition_name TEXT;
        next_i INT;
        curr_date DATE;
        curr_date_text TEXT;
        next_date DATE;
    BEGIN
        FOR i IN 1..(SELECT COUNT(*) FROM date_bounds)-1
        LOOP
            next_i := i + 1;
            curr_date := (SELECT month FROM date_bounds AS db WHERE db.id = i);
            next_date := (SELECT month FROM date_bounds AS db WHERE db.id = next_i);
            curr_date_text := TO_CHAR(curr_date, 'annumYYYY_mMM');
            curr_partition_name := format( '' ||table_name|| '_' ||curr_date_text|| '' );

            EXECUTE format('WITH row AS (' ||
                           'DELETE FROM ONLY '||table_name||' ' ||
                           'WHERE '||range_field||' >= '''||curr_date||''' AND '||range_field||' < '''||next_date||''' ' ||
                           'RETURNING *) ' ||
                           'INSERT INTO '||curr_partition_name||' SELECT * FROM row;');
        END LOOP;

    END;
    $$
LANGUAGE plpgsql;


--
-- SELECT count(*) FROM client;
-- SELECT * FROM ONLY client;
-- SELECT * FROM ONLY client;
-- SELECT count(*) FROM ONLY client WHERE date_trunc('month', last_logged_on) = '2023-12-01';

-- DO
--     $$
--     BEGIN
--         IF (SELECT count(*) FROM ONLY client) =
--             (SELECT count(*) FROM ONLY client WHERE date_trunc('month', last_logged_on) =
--             (SELECT max(date_bounds.month) FROM date_bounds)
--         )
--            THEN
--             RAISE NOTICE 'Equal!';
--         ELSE
--             RAISE NOTICE 'Whatta HELL?! Am I Stupid?'; -- Without any doubt.
--         END IF;
--
--     END;
--     $$
-- LANGUAGE plpgsql;

-- CREATE TABLE client_annum2023_m12 (LIKE client INCLUDING ALL);
-- ALTER TABLE client_annum2023_m12 ADD CONSTRAINT annum2023_m12
--                 CHECK  (last_logged_on >= '2023-12-01' AND last_logged_on < '2024-01-01');
-- ALTER TABLE client_annum2023_m12 INHERIT client;
-- CREATE INDEX client_annum2023_m12_last_logged_on ON client_annum2023_m12 (last_logged_on);
--
-- WITH row AS
--     ( DELETE FROM ONLY client WHERE last_logged_on >= '2023-12-01' AND last_logged_on < '2024-01-01' RETURNING *)
-- INSERT INTO client_annum2023_m12 SELECT * FROM row;
-- SELECT count(*) FROM client_annum2023_m05;


-- https://drive.google.com/file/d/1C_9kxP6cRK6GJ21Skz40rTPIwvqWoWHT/view?usp=sharing