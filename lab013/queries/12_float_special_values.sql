-- Задача 12. Спецзначения float: Infinity, -Infinity, NaN и их необычное поведение.
SET search_path TO lab013;

-- Типы с плавающей точкой (real/double precision), а также numeric, умеют хранить
-- три особых значения: 'Infinity', '-Infinity' и 'NaN' (не-число). У них в
-- PostgreSQL нестандартная семантика:
--   • NaN СЧИТАЕТСЯ РАВНЫМ самому себе ('NaN' = 'NaN' → true), хотя в математике
--     это не так, — чтобы NaN можно было группировать и индексировать;
--   • NaN считается БОЛЬШЕ любого другого числа, поэтому в ORDER BY он уходит
--     в самый конец (после +Infinity).
-- Моделируем показания датчиков через VALUES и сортируем по возрастанию.
WITH readings(sensor, value) AS (
    VALUES
        ('датчик A',  1.5::float8),
        ('датчик B',  'Infinity'::float8),
        ('датчик C',  'NaN'::float8),
        ('датчик D',  '-Infinity'::float8),
        ('датчик E',  42.0::float8)
)
SELECT
    sensor,
    value,
    ('NaN'::float8 = value) AS is_nan,       -- true только у NaN (NaN = NaN → true)
    (value > 1e308)         AS greater_huge  -- true у +Infinity и у NaN
FROM readings
ORDER BY value;                              -- NaN окажется ПОСЛЕДНИМ (он «самый большой»)
