-- Задача 2. Целочисленное деление врёт: наивный «средний чек» против правильного.
SET search_path TO lab013;

-- revenue_rub и items — ЦЕЛЫЕ (integer). Деление int/int в SQL — целочисленное:
-- дробная часть отбрасывается. sum() от integer даёт bigint, но bigint/bigint —
-- всё равно целочисленное деление. Итог: «средний чек» и «среднее число товаров»
-- получаются заниженными. Лечение — привести числитель к numeric (или взять avg()).
SELECT
    count(*)                                      AS orders,
    sum(revenue_rub)                              AS revenue_total,
    -- ловушка №1: средний чек
    sum(revenue_rub) / count(*)                   AS avg_check_naive,    -- 4735  (int-деление)
    round(sum(revenue_rub)::numeric / count(*), 2) AS avg_check_correct, -- 4735.56
    -- ловушка №2: среднее число товаров в заказе
    sum(items) / count(*)                         AS avg_items_naive,    -- 1     (int-деление)
    round(sum(items)::numeric / count(*), 2)      AS avg_items_correct   -- 1.44
FROM orders;
