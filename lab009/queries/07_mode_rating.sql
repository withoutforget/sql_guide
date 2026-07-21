-- Задача 7. Самая частая оценка (mode) — по всему магазину и по категориям.
SET search_path TO lab009;

-- mode() WITHIN GROUP (ORDER BY x) — самое ЧАСТОЕ значение группы (это всегда
-- реальное значение из данных). Аргумент у mode() пустой; что считать «частым»,
-- задаёт ORDER BY. При ничье побеждает первое по этому ORDER BY.
-- По всем товарам чаще всего встречается рейтинг 5 (10 раз против 8 и 2).

-- 7a) По всему магазину:
SELECT mode() WITHIN GROUP (ORDER BY rating) AS частый_рейтинг_всего
FROM products;

-- 7b) По каждой категории (рядом — распределение оценок для проверки):
SELECT
    category                                     AS категория,
    mode() WITHIN GROUP (ORDER BY rating)        AS частый_рейтинг,
    count(*) FILTER (WHERE rating = 5)           AS "★5",
    count(*) FILTER (WHERE rating = 4)           AS "★4",
    count(*) FILTER (WHERE rating = 3)           AS "★3"
FROM products
GROUP BY category
ORDER BY category;
