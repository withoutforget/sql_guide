-- Задача 13. 🔥 Клиенты, купившие И книги, И электронику, но НИЧЕГО из категории «Дом».
SET search_path TO lab003;

-- Цепочка из трёх множеств:
--     (покупатели книг  ∩  покупатели электроники)  \  покупатели «Дома».
-- Здесь INTERSECT связывает сильнее EXCEPT, поэтому скобки вокруг пересечения
-- фактически НЕОБЯЗАТЕЛЬНЫ (СУБД и так посчитает INTERSECT первым) — но мы их
-- ставим для читаемости. Сравните с задачей 11, где без скобок ответ был бы ДРУГИМ.
-- Каждое множество — покупатели товаров нужной категории (JOIN до categories).
-- Ответ: Вера. Анна тоже купила и книги, и электронику, но она брала лампу
-- (категория «Дом»), поэтому EXCEPT её убрал.
(
    SELECT c.id, c.name
    FROM orders     AS o
    JOIN customers  AS c    ON c.id  = o.customer_id
    JOIN products   AS p    ON p.id  = o.product_id
    JOIN categories AS cat  ON cat.id = p.category_id
    WHERE cat.name = 'Книги'
  INTERSECT
    SELECT c.id, c.name
    FROM orders     AS o
    JOIN customers  AS c    ON c.id  = o.customer_id
    JOIN products   AS p    ON p.id  = o.product_id
    JOIN categories AS cat  ON cat.id = p.category_id
    WHERE cat.name = 'Электроника'
)
EXCEPT
SELECT c.id, c.name
FROM orders     AS o
JOIN customers  AS c    ON c.id  = o.customer_id
JOIN products   AS p    ON p.id  = o.product_id
JOIN categories AS cat  ON cat.id = p.category_id
WHERE cat.name = 'Дом'
ORDER BY name;
