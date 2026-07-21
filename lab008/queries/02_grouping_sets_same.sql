-- Задача 2. Тот же отчёт (категории + общий итог) через GROUPING SETS — коротко и за один проход.
SET search_path TO lab008;

-- GROUPING SETS перечисляет наборы группировки: (category) — детализация по
-- категориям, () — пустой набор = общий итог по всей таблице. Один GROUP BY
-- заменяет UNION ALL двух запросов из задачи 1 и сканирует sales ОДИН раз.
-- В строке общего итога category = NULL (psql по умолчанию печатает его пусто) —
-- это «итоговый NULL»: колонка category здесь свёрнута. Строгое доказательство
-- эквивалентности этой формы и UNION ALL нескольких GROUP BY — в задаче 3.
SELECT category, SUM(amount) AS revenue
FROM sales
GROUP BY GROUPING SETS ((category), ())
ORDER BY revenue;
