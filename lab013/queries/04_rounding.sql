-- Задача 4. Округление: round(double) и round(numeric) — это РАЗНОЕ. Плюс trunc/ceil/floor.
SET search_path TO lab013;

-- weight_kg — double precision. round(double) использует «банковское» округление
-- (половина — к ЧЁТНОМУ): round(2.5) = 2, round(0.5) = 0.
-- Если тот же вес привести к numeric, round(numeric) округляет «половину вверх»:
-- round(2.5) = 3, round(0.5) = 1. Смотрите строки «Колонка Mini»/«Кофеварка» (2.5)
-- и «Пазл 1000» (0.5) — там r_double и r_numeric РАСХОДЯТСЯ.
-- Ещё нюанс: round(double, 1) не существует — второй аргумент есть только у numeric,
-- поэтому цену в рассрочку (numeric) округляем с точностью до копеек.
SELECT
    name,
    weight_kg,
    round(weight_kg)              AS r_double,      -- банковское (к чётному)
    round(weight_kg::numeric)     AS r_numeric,     -- половина вверх
    trunc(weight_kg::numeric)     AS truncated,     -- отбросить дробную часть
    ceil(weight_kg)               AS rounded_up,    -- вверх
    floor(weight_kg)              AS rounded_down,  -- вниз
    round(price / 3, 2)           AS installment_3x -- цена в 3 платежа, numeric round(_, 2)
FROM products
ORDER BY id;
