-- Задача 8. Топ-1 товар по выручке в каждой категории (ROW_NUMBER в обёртке-CTE).
SET search_path TO lab010;

-- Оконную функцию нельзя писать в WHERE (она считается ПОЗЖЕ него). Поэтому классика:
-- посчитать row_number ВНУТРИ CTE, а фильтровать по нему СНАРУЖИ (там rn — обычный
-- столбец). row_number() = 1 берёт РОВНО ОДНОГО лидера на категорию.
-- Ничьи: в Доме два товара по 24000 делят 1-е место; доводчик ", p.id" в ORDER BY
-- окна делает выбор однозначным (меньший id — Кофеварка). Это чистое разрешение
-- ничьих, которого не давал приём "= MAX(...)" из lab005 (тот вернул бы ОБОИХ).
-- Нужно «при ничьей показать всех лидеров» — заменили бы на rank() = 1.
WITH ranked AS (
    SELECT c.name AS category, p.name AS product, p.revenue,
           row_number() OVER (PARTITION BY c.name ORDER BY p.revenue DESC, p.id) AS rn
    FROM products  AS p
    JOIN categories AS c ON c.id = p.category_id
)
SELECT category AS категория,
       product  AS товар_лидер,
       revenue  AS выручка
FROM ranked
WHERE rn = 1
ORDER BY revenue DESC;
