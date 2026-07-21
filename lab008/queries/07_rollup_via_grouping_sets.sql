-- Задача 7. Выразить ROLLUP (category, subcategory) явным GROUPING SETS (тот же результат).
SET search_path TO lab008;

-- ROLLUP — лишь СОКРАЩЕНИЕ. ROLLUP (category, subcategory) разворачивается в
-- GROUPING SETS с наборами-префиксами: полный (category, subcategory), затем
-- (category), затем пустой (). Этот запрос выдаёт строка-в-строку то же, что
-- задача 5, — но наборы выписаны руками. Понимание этого раскрытия снимает всю
-- «магию» ROLLUP/CUBE: любой из них мысленно превращается в список наборов
-- (проверить равенство с задачей 5 можно тем же приёмом EXCEPT, что в задаче 3).
SELECT category, subcategory, SUM(amount) AS revenue
FROM sales
GROUP BY GROUPING SETS ((category, subcategory), (category), ())
ORDER BY category NULLS LAST, subcategory NULLS LAST;
