-- Задача 11. Расставить итоги по местам сортировкой ORDER BY с GROUPING().
SET search_path TO lab008;

-- Итоги содержат NULL в свёрнутых колонках, и обычный ORDER BY по измерению
-- раскидал бы их непредсказуемо (зависит от NULLS FIRST/LAST). Надёжный шаблон
-- для иерархического отчёта: GROUPING(старшая), старшая, GROUPING(младшая),
-- младшая. Так каждый подытог встаёт СРАЗУ ПОД своими деталями, а общий итог —
-- в самый низ. GROUPING(category) первым отправляет общий итог (=1) вниз; внутри
-- категории GROUPING(subcategory) ставит детали (0) выше подытога (1).
SELECT category, subcategory, SUM(amount) AS revenue
FROM sales
GROUP BY ROLLUP (category, subcategory)
ORDER BY
    GROUPING(category),      -- общий итог — в самый низ
    category,                -- категории по алфавиту
    GROUPING(subcategory),   -- внутри категории: детали выше подытога
    subcategory;             -- детали по алфавиту
