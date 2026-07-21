-- Задача 4. Три разреза сразу: выручка по категориям, по каналам и по регионам плюс общий итог.
SET search_path TO lab008;

-- Один GROUP BY GROUPING SETS с четырьмя наборами по РАЗНЫМ колонкам заменяет
-- четыре отдельных GROUP BY + UNION ALL (и четыре прохода по таблице). В каждой
-- строке «не-NULL» ровно те колонки, по которым считался её набор:
--   (category) → 3 строки, (channel) → 2, (region) → 3, () → 1 общий итог = 9 строк.
-- ВНИМАНИЕ: среди строк набора (region) есть строка с region = NULL — это продажи
-- с НЕуказанным регионом (настоящий NULL в данных, 70 000), а НЕ общий итог
-- (он самый нижний, 1 000 000). Отличать их надёжно научимся в задачах 8–9
-- через GROUPING().
SELECT category, channel, region, SUM(amount) AS revenue
FROM sales
GROUP BY GROUPING SETS ((category), (channel), (region), ())
ORDER BY revenue;
