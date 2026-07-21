-- Задача 1. Какой ТИП у выражений и литералов? Разглядываем систему типов через pg_typeof.
SET search_path TO lab013;

-- (а) Типы колонок и типы, которые «рождаются» в арифметике.
SELECT
    pg_typeof(id)          AS t_id,        -- smallint  (int2, ключ)
    pg_typeof(price)       AS t_price,     -- numeric   (деньги)
    pg_typeof(weight_kg)   AS t_weight,    -- double precision (float8)
    pg_typeof(sku)         AS t_sku,       -- character varying (varchar)
    pg_typeof(in_stock)    AS t_in_stock,  -- boolean
    pg_typeof(units / 2)   AS t_int_div,   -- integer   (int/int → int!)
    pg_typeof(price / 2)   AS t_num_div,   -- numeric   (в арифметике int→numeric)
    pg_typeof(price * units) AS t_mix      -- numeric   (numeric * int → numeric)
FROM products
LIMIT 1;

-- (б) Тип ЛИТЕРАЛА зависит от того, как он записан.
SELECT
    pg_typeof(100)               AS int_lit,      -- integer
    pg_typeof(3.14)              AS numeric_lit,  -- numeric  (с точкой → numeric, не float!)
    pg_typeof(9999999999)        AS bigint_lit,   -- bigint   (не влезло в integer)
    pg_typeof(100::smallint)     AS forced_small, -- smallint (явное приведение)
    pg_typeof('42')              AS unknown_lit,  -- unknown  (нетипизированный строковый литерал)
    pg_typeof('42'::int)         AS cast_to_int,  -- integer
    pg_typeof(true)              AS bool_lit,     -- boolean
    pg_typeof('2024-01-01'::date) AS date_lit;    -- date
