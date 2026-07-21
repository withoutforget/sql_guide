-- Задача 8. Клиенты, купившие И «SQL за месяц» (id 5), И «Чистый код» (id 6).
SET search_path TO lab003;

-- «И то, и другое» — это INTERSECT двух множеств покупателей:
--   первый запрос  — кто купил товар 5;
--   второй запрос  — кто купил товар 6;
--   INTERSECT      — оставит тех, кто есть в обоих списках.
-- Имя достаём JOIN'ом orders→customers прямо в каждой ветке, а сравнение идёт по
-- паре (id, name); id добавлен, чтобы не слить возможных тёзок и чтобы было по
-- чему сортировать. Ответ: Анна и Дарья.
SELECT c.id, c.name
FROM orders    AS o
JOIN customers AS c  ON c.id = o.customer_id
WHERE o.product_id = 5
INTERSECT
SELECT c.id, c.name
FROM orders    AS o
JOIN customers AS c  ON c.id = o.customer_id
WHERE o.product_id = 6
ORDER BY name;
