-- Задача 1. Разложить момент заказа на части: год, месяц, день, час, день недели, квартал.
SET search_path TO lab014;
SET TIME ZONE 'UTC';   -- детерминизм: created_at (timestamptz) читаем в UTC

-- EXTRACT(поле FROM момент) достаёт одно числовое поле. dow (0=вс..6=сб) и
-- isodow (1=пн..7=вс) — разные нумерации дня недели; для «выходных» удобнее isodow
-- (сб=6, вс=7 идут подряд). quarter — номер квартала 1..4. Показываем несколько
-- заказов из разных месяцев/дней недели.
SELECT
    id,
    created_at,
    EXTRACT(year    FROM created_at) AS год,
    EXTRACT(month   FROM created_at) AS месяц,
    EXTRACT(day     FROM created_at) AS день,
    EXTRACT(hour    FROM created_at) AS час,
    EXTRACT(isodow  FROM created_at) AS день_недели_1пн,
    EXTRACT(quarter FROM created_at) AS квартал
FROM orders
ORDER BY created_at;
