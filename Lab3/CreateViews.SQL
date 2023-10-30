CREATE VIEW products_info AS
    SELECT
        p.product_id            AS product_id,
        p.title                 AS title,
        p.is_delivery_enabled   AS delivery,
        p.is_pickup_enabled     AS pickup,
        cn.title                AS categoty,
        pp.old_price            AS old_price,
        pp.current_price        AS current_price,
        pp.date                 AS price_date
        FROM public.products AS p
        LEFT JOIN public.product_price pp on p.product_id = pp.prodict_id
        LEFT JOIN public.catalog_nodes cn on p.catalog_node_id = cn.catalog_node_id
    ORDER BY product_id
;

DROP view products_info;

SELECT * FROM products_info;