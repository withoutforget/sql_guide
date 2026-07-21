-- Задача 12. Выручка по месяцам с июня по сентябрь 2024, включая месяцы без заказов (gap-filling).
SET search_path TO lab006;

-- То же gap-filling, но шаг ряда — МЕСЯЦ: generate_series с interval '1 month'
-- порождает первые числа июня, июля, августа, сентября. Каждая такая дата — начало
-- месяца; заказ попадает в месяц, если его дата в полуинтервале [начало, начало+1
-- месяц). Диапазонное условие в ON (а не date_trunc в GROUP BY) удобно тем, что не
-- требует функций форматирования дат и хорошо ложится на индекс по ordered_at.
-- Заказы у нас только в июне и июле, поэтому август и сентябрь дают нули — ровно
-- то, что gap-filling и должен показать (без сплошного ряда их бы просто не было).
SELECT to_char(m.month, 'YYYY-MM')                  AS month,
       COUNT(o.id)                                  AS orders_count,
       COALESCE(SUM(p.price * o.quantity), 0)       AS revenue
FROM generate_series(date '2024-06-01', date '2024-09-01', interval '1 month') AS m(month)
LEFT JOIN orders   AS o ON o.ordered_at >= m.month
                       AND o.ordered_at <  m.month + interval '1 month'
LEFT JOIN products AS p ON p.id = o.product_id
GROUP BY m.month
ORDER BY m.month;
