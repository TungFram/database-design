CREATE MATERIALIZED VIEW evil_rates AS
    SELECT
        -- https://postgresql-anonymizer.readthedocs.io/en/stable/masking_functions/#generalization
        anon.generalize_int4range(r.rate_id, 10) AS id,
        -- https://postgresql-anonymizer.readthedocs.io/en/stable/masking_functions/#randomization
        anon.random_date() as works_unil,
        -- https://postgresql-anonymizer.readthedocs.io/en/stable/masking_functions/#adding-noise
        anon.noise(r.gigabytes, 0.4) as gbs,
        anon.noise(r.minutes,   0.6) as mins,
        anon.noise(r.sms,       0.3) as sms,
        -- Decay.
        'RESTRICTED'::text AS description
FROM postgres.public.rates AS r
;

SELECT anon.init();
CREATE MATERIALIZED VIEW evil_products_XD AS
    SELECT
--         https://postgresql-anonymizer.readthedocs.io/en/latest/masking_functions/#pseudonymization
        anon.pseudo_iban(p.product_id  ,'salt') AS product_id,
--         https://postgresql-anonymizer.readthedocs.io/en/latest/masking_functions/#faking
        anon.fake_address() AS title,
--         https://postgresql-anonymizer.readthedocs.io/en/latest/masking_functions/#randomization
        anon.random_string(12) AS categoty,
        anon.random_in(ARRAY[288, 337, 100500, 0]) AS current_price,
--         https://postgresql-anonymizer.readthedocs.io/en/latest/masking_functions/#adding-noise
        anon.noise(pp.old_price,0.5) AS old_price,
--         https://postgresql-anonymizer.readthedocs.io/en/latest/masking_functions/#generalization
        anon.generalize_tsrange(pp.date,'decade') AS price_creation_date,
--         https://postgresql-anonymizer.readthedocs.io/en/latest/masking_functions/#partial-scrambling
        anon.partial(t.title,2,'~',4) AS tag,
--         https://postgresql-anonymizer.readthedocs.io/en/latest/masking_functions/#generic-hashing
        pg_catalog.left(anon.hash(t.color),12) AS tag_color
        FROM public.products AS p
        LEFT JOIN public.product_price pp on p.product_id = pp.prodict_id
        LEFT JOIN public.catalog_nodes cn on p.catalog_node_id = cn.catalog_node_id
        LEFT JOIN public.tags_products tp on p.product_id = tp.product_id
        LEFT JOIN public.tags t on t.tag_id = tp.tag_id
--     GROUP BY p.product_id
    ORDER BY p.product_id
;

SELECT * from evil_products_XD;

DROP MATERIALIZED VIEW evil_products_XD;

