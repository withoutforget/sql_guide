-- Задача 2. Для каждого товара: его цена, средняя по каталогу, отклонение и доля от максимума.
SET search_path TO lab004;

-- Скалярный подзапрос можно ставить и в список SELECT — тогда его единственное
-- значение подставляется в КАЖДУЮ строку. Здесь три подзапроса-ориентира:
-- средняя цена (дважды — для показа и для отклонения) и максимальная цена.
-- Каждый вычисляется один раз и одинаково подставляется во все строки.
SELECT
    name,
    price,
    (SELECT ROUND(AVG(price), 2) FROM products)              AS avg_all,
    ROUND(price - (SELECT AVG(price) FROM products), 2)      AS diff_from_avg,
    ROUND(price / (SELECT MAX(price) FROM products) * 100, 1) AS pct_of_max
FROM products
ORDER BY price DESC;
