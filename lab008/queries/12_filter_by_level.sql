-- Задача 12. Оставить только строки-подытоги по категориям (фильтр по уровню через HAVING GROUPING).
SET search_path TO lab008;

-- Уровень строки задаётся GROUPING(), поэтому фильтр «оставить только подытоги
-- категории» — это HAVING по GROUPING (а НЕ по IS NULL!). Условие
-- GROUPING(subcategory)=1 AND GROUPING(category)=0 = ровно набор (category):
-- отбрасывает и детали (обе 0), и общий итог (обе 1). То же можно записать
-- маской: HAVING GROUPING(category, subcategory) = 1. Из 10 строк ROLLUP
-- остаётся 3 — подытоги по категориям.
SELECT category, subcategory, SUM(amount) AS revenue
FROM sales
GROUP BY ROLLUP (category, subcategory)
HAVING GROUPING(subcategory) = 1 AND GROUPING(category) = 0
ORDER BY category;
