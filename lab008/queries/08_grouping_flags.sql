-- Задача 8. Пометить уровень каждой строки флагами GROUPING() и битовой маской.
SET search_path TO lab008;

-- GROUPING(col) = 1, если col в этой строке СВЁРНУТА (итог по ней), иначе 0 —
-- и это не зависит от значения, поэтому надёжно отмечает строки-итоги.
-- GROUPING(a, b) = 2*GROUPING(a) + GROUPING(b) — «номер уровня» битовой маской:
--   mask 0 = деталь (обе колонки на месте)
--   mask 1 = подытог по категории (subcategory свёрнута)
--   mask 3 = общий итог (обе свёрнуты)
-- Маска 2 (свёрнута только категория) при ROLLUP НЕ появляется — он не
-- сворачивает старшую колонку раньше младшей; она была бы у CUBE.
SELECT category, subcategory,
       GROUPING(category)              AS g_cat,
       GROUPING(subcategory)           AS g_sub,
       GROUPING(category, subcategory) AS mask,
       SUM(amount) AS revenue
FROM sales
GROUP BY ROLLUP (category, subcategory)
ORDER BY category NULLS LAST, subcategory NULLS LAST;
