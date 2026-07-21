-- Задача 11. Клиенты, купившие ХОТЯ БЫ ОДНУ из книг (5 или 6) И хоть что-то из электроники.
SET search_path TO lab003;

-- Логика: (покупатели книги 5  ∪  покупатели книги 6)  ∩  покупатели электроники.
-- Здесь СКОБКИ ОБЯЗАТЕЛЬНЫ. Без них сработал бы приоритет операторов: INTERSECT
-- связывает сильнее, чем UNION, поэтому «A UNION B INTERSECT C» СУБД прочитает
-- как «A UNION (B INTERSECT C)» — это другой (неверный для нашей задачи) ответ.
-- Скобки заставляют сначала объединить покупателей обеих книг, а уже потом
-- пересечь с покупателями электроники.
-- Ответ: Анна и Вера (Дарья купила обе книги, но электронику — нет, поэтому её нет).
(
    SELECT c.id, c.name
    FROM orders    AS o
    JOIN customers AS c  ON c.id = o.customer_id
    WHERE o.product_id = 5
  UNION
    SELECT c.id, c.name
    FROM orders    AS o
    JOIN customers AS c  ON c.id = o.customer_id
    WHERE o.product_id = 6
)
INTERSECT
SELECT c.id, c.name
FROM orders     AS o
JOIN customers  AS c    ON c.id  = o.customer_id
JOIN products   AS p    ON p.id  = o.product_id
JOIN categories AS cat  ON cat.id = p.category_id
WHERE cat.name = 'Электроника'
ORDER BY name;
