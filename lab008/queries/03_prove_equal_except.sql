-- Задача 3. Доказать эквивалентность GROUPING SETS и UNION ALL нескольких GROUP BY (равенство наборов через EXCEPT).
SET search_path TO lab008;

-- GROUPING SETS ((category), ()) обязан давать РОВНО то же, что UNION ALL двух
-- GROUP BY. Проверим это формально приёмом из lab003 + lab004: два набора равны,
-- если обе «разности» (EXCEPT) пусты. Симметрично через NOT EXISTS(A EXCEPT B) и
-- NOT EXISTS(B EXCEPT A): если ни в одном направлении нет «лишних» строк — наборы
-- идентичны. Ожидаемый результат: TRUE.
-- (EXCEPT считает два NULL равными — поэтому строки общего итога с category = NULL
--  из обеих версий тоже сматчатся; см. lab003 про NULL при дедупе.)
SELECT
    NOT EXISTS (
        (SELECT category, SUM(amount) FROM sales GROUP BY GROUPING SETS ((category), ()))
        EXCEPT
        (SELECT category, SUM(amount) FROM sales GROUP BY category
         UNION ALL
         SELECT NULL, SUM(amount) FROM sales)
    )
    AND
    NOT EXISTS (
        (SELECT category, SUM(amount) FROM sales GROUP BY category
         UNION ALL
         SELECT NULL, SUM(amount) FROM sales)
        EXCEPT
        (SELECT category, SUM(amount) FROM sales GROUP BY GROUPING SETS ((category), ()))
    ) AS наборы_совпадают;
