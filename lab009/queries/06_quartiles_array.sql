-- Задача 6. Квартили по категориям одним вызовом: percentile_cont от массива долей.
SET search_path TO lab009;

-- Вместо одной доли перцентилю можно передать МАССИВ долей — вернётся массив
-- значений за один проход. ARRAY[0.25, 0.5, 0.75] — это квартили:
--   Q1 — ниже него 25% товаров, Q2 — медиана, Q3 — ниже 75%.
-- Достаём элементы массива по индексу ([1],[2],[3]). IQR = Q3 − Q1 —
-- «межквартильный размах», устойчивая к выбросам мера разброса центра.
WITH q AS (
    SELECT
        category,
        count(*) AS n,
        percentile_cont(ARRAY[0.25, 0.5, 0.75])
            WITHIN GROUP (ORDER BY price) AS p     -- p[1]=Q1, p[2]=медиана, p[3]=Q3
    FROM products
    GROUP BY category
)
SELECT
    category           AS категория,
    n,
    p[1]               AS q1,
    p[2]               AS медиана,
    p[3]               AS q3,
    p[3] - p[1]        AS iqr
FROM q
ORDER BY категория;
