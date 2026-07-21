-- Задача 3. Конверсия каналов: безопасное деление через NULLIF (+ снова int-деление).
SET search_path TO lab013;

-- Конверсия = заказы / визиты. Две ловушки сразу:
--   1) orders_cnt / visits — оба integer → целочисленное деление даёт 0
--      (заказов всегда меньше, чем визитов);
--   2) у канала «Баннеры» visits = 0 → прямое деление упало бы с ошибкой
--      «division by zero». NULLIF(visits, 0) превращает 0 в NULL, а деление на
--      NULL даёт NULL (пустую конверсию), а не ошибку.
SELECT
    name,
    visits,
    orders_cnt,
    orders_cnt / NULLIF(visits, 0)                              AS conv_int_naive, -- всегда 0
    round(orders_cnt::numeric / NULLIF(visits, 0) * 100, 2)     AS conv_percent    -- реальная %, у «Баннеров» NULL
FROM channels
ORDER BY conv_percent DESC NULLS LAST, id;
