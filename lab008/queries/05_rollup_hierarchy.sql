-- Задача 5. Иерархия «категория → подкатегория»: детали, подытог по категории, общий итог (ROLLUP).
SET search_path TO lab008;

-- ROLLUP (category, subcategory) = GROUPING SETS ((category, subcategory),
-- (category), ()): сворачивание справа налево. Три уровня в одном ответе:
--   6 детальных строк (по подкатегориям)
-- + 3 подытога по категориям (subcategory свёрнута → NULL)
-- + 1 общий итог (обе колонки свёрнуты) = 10 строк.
-- Проверка сумм: Кухня 150k + Освещение 100k = 250k (подытог «Дом»);
-- 250k + 150k + 600k = 1 000 000 (общий итог). NULLS LAST ставит итоги под их
-- деталями (аккуратную сортировку через GROUPING() см. в задаче 11).
SELECT category, subcategory, SUM(amount) AS revenue
FROM sales
GROUP BY ROLLUP (category, subcategory)
ORDER BY category NULLS LAST, subcategory NULLS LAST;
