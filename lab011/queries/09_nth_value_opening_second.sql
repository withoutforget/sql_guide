-- Задача 9. Открытие, второй день и закрытие ряда каждого товара (first_value/nth_value/last_value).
SET search_path TO lab011;

-- Все три функции считаем по ПОЛНОЙ рамке партиции (ROWS BETWEEN UNBOUNDED PRECEDING
-- AND UNBOUNDED FOLLOWING), чтобы они смотрели на ВЕСЬ ряд товара, а не «до текущей
-- строки»:
--   first_value      — выручка ПЕРВОГО дня ряда;
--   nth_value(...,2) — выручка ВТОРОГО дня (n отсчитывается от начала рамки, с 1);
--   last_value       — выручка ПОСЛЕДНЕГО дня ряда (полная рамка снимает ловушку из задачи 8).
-- Значения одинаковы во всех строках товара — это опорные точки ряда; берём по одной
-- строке на товар через DISTINCT.
SELECT DISTINCT
    p.name AS товар,
    first_value(s.revenue)  OVER (PARTITION BY s.product_id ORDER BY s.sale_date
                                  ROWS BETWEEN UNBOUNDED PRECEDING
                                           AND UNBOUNDED FOLLOWING) AS открытие,
    nth_value(s.revenue, 2) OVER (PARTITION BY s.product_id ORDER BY s.sale_date
                                  ROWS BETWEEN UNBOUNDED PRECEDING
                                           AND UNBOUNDED FOLLOWING) AS второй_день,
    last_value(s.revenue)   OVER (PARTITION BY s.product_id ORDER BY s.sale_date
                                  ROWS BETWEEN UNBOUNDED PRECEDING
                                           AND UNBOUNDED FOLLOWING) AS закрытие
FROM sales AS s
JOIN products AS p ON p.id = s.product_id
ORDER BY товар;
