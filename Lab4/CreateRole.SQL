-- https://postgresql-anonymizer.readthedocs.io/en/stable/dynamic_masking/

-- Activate the dynamic masking engine.
CREATE EXTENSION IF NOT EXISTS anon CASCADE;
SELECT anon.start_dynamic_masking();
--
-- Declare a masked user.
CREATE ROLE evil LOGIN;
SECURITY LABEL FOR anon ON ROLE evil IS 'MASKED';

-- Declare the masking rules.
SECURITY LABEL FOR anon ON COLUMN products.title
IS 'MASKED WITH FUNCTION anon.random_string(10)';

SECURITY LABEL FOR anon ON COLUMN products.description
IS 'MASKED WITH FUNCTION anon.random_string(10)';

SECURITY LABEL FOR anon ON COLUMN products.is_delivery_enabled
IS 'MASKED WITH VALUE ''false'' ';

SECURITY LABEL FOR anon ON COLUMN products.is_pickup_enabled
IS 'MASKED WITH VALUE ''false'' ';

SECURITY LABEL FOR anon ON COLUMN products.product_id
IS 'MASKED WITH FUNCTION anon.noise(products.product_id,0.2) ';

SECURITY LABEL FOR anon ON COLUMN products.product_id
IS 'MASKED WITH FUNCTION anon.noise(products.product_id,0.2) ';
