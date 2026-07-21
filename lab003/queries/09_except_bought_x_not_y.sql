-- Задача 9. Клиенты, купившие «SQL за месяц» (id 5), но НЕ купившие «Чистый код» (id 6).
SET search_path TO lab003;

-- «Купили X, но не Y» — это EXCEPT:
--   первый запрос  — покупатели товара 5;
--   второй запрос  — покупатели товара 6;
--   EXCEPT         — из первых убрать всех, кто есть во вторых.
-- Порядок важен (EXCEPT несимметричен): нам нужно именно «5, но не 6».
-- Ответ: Вера (Анна и Дарья отпали — они купили и «Чистый код»).
SELECT c.id, c.name
FROM orders    AS o
JOIN customers AS c  ON c.id = o.customer_id
WHERE o.product_id = 5
EXCEPT
SELECT c.id, c.name
FROM orders    AS o
JOIN customers AS c  ON c.id = o.customer_id
WHERE o.product_id = 6
ORDER BY name;
