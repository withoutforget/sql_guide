-- Задача 9. Топ-2 товара по выручке в каждой категории (тот же приём, WHERE rn <= 2).
SET search_path TO lab010;

-- Ровно паттерн top-N: та же обёртка, что в задаче 8, но условие снаружи — rn <= 2.
-- Менять N теперь тривиально (rn <= 3 и т.д.). Это оконный аналог LATERAL ... LIMIT 2
-- из lab006 (queries/10): один проход по таблице вместо подзапроса на каждую группу.
-- В Доме ничья за 1-е место — доводчик ", p.id" оставляет по одному товару на позицию
-- (иначе row_number среди равных был бы произволен). Хотите включить ВСЕХ, кто попал
-- в топ-2 по значению (при ничьих строк может стать больше) — взяли бы rank() <= 2.
WITH ranked AS (
    SELECT c.name AS category, p.name AS product, p.revenue,
           row_number() OVER (PARTITION BY c.name ORDER BY p.revenue DESC, p.id) AS rn
    FROM products  AS p
    JOIN categories AS c ON c.id = p.category_id
)
SELECT category AS категория,
       rn       AS место,
       product  AS товар,
       revenue  AS выручка
FROM ranked
WHERE rn <= 2
ORDER BY категория, место;
