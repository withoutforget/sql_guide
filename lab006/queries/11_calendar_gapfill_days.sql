-- Задача 11. Число заказов и выручка по каждому дню первой декады июня, включая пустые дни (gap-filling).
SET search_path TO lab006;

-- Классическая задача «календарь без дыр». Если просто сгруппировать заказы по
-- дате, дни БЕЗ заказов в результат не попадут — в отчёте появятся провалы. Чтобы
-- их не было, сначала строим сплошной ряд дат через generate_series (задача 2),
-- а потом LEFT JOIN'им к нему фактические заказы. Дни без заказов сохраняются
-- (LEFT JOIN), а COUNT(o.id) и COALESCE(SUM(...), 0) дают на них честные нули.
-- Условие про попадание заказа в день — обычное o.ordered_at = cal.day.
-- В окне 2024-06-01..2024-06-10 пустыми окажутся 04, 06, 07, 09 июня (в них 0).
SELECT cal.day::date                                AS day,
       COUNT(o.id)                                  AS orders_count,
       COALESCE(SUM(p.price * o.quantity), 0)       AS revenue
FROM generate_series(date '2024-06-01', date '2024-06-10', interval '1 day') AS cal(day)
LEFT JOIN orders   AS o ON o.ordered_at = cal.day::date
LEFT JOIN products AS p ON p.id = o.product_id
GROUP BY cal.day
ORDER BY cal.day;
