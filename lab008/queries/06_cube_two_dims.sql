-- Задача 6. Полный куб по двум независимым измерениям: категория × канал (CUBE).
SET search_path TO lab008;

-- CUBE (category, channel) = все подмножества: (category, channel), (category),
-- (channel), () → 2^2 = 4 набора, 12 строк. В отличие от ROLLUP, CUBE добавляет
-- «одинокий» разрез по каналу (строки, где category свёрнута, а channel — нет):
--   ∅ | online  | 600000   ← итог по онлайну по ВСЕМ категориям
--   ∅ | offline | 400000   ← итог по офлайну
-- Такого ROLLUP (category, channel) не даёт. Проверка: online 600k + offline
-- 400k = 1 000 000; по категориям 600k + 150k + 250k = 1 000 000.
SELECT category, channel, SUM(amount) AS revenue
FROM sales
GROUP BY CUBE (category, channel)
ORDER BY category NULLS LAST, channel NULLS LAST;
