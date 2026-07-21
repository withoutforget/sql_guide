-- Задача 2. Доля товара в выручке СВОЕЙ категории (sum(...) OVER (PARTITION BY ...)).
SET search_path TO lab010;

-- Добавили PARTITION BY c.name — и знаменателем стал итог РАЗДЕЛА (категории), а не
-- всего магазина. Итог категории приписан каждому её товару (не схлопывая строки).
-- Внутри каждой категории доли складываются в 100% (с точностью до округления).
SELECT
    c.name                                                                    AS категория,
    p.name                                                                    AS товар,
    p.revenue                                                                 AS выручка,
    sum(p.revenue) OVER (PARTITION BY c.name)                                 AS итог_категории,
    round(100.0 * p.revenue / sum(p.revenue) OVER (PARTITION BY c.name), 2)   AS доля_в_кат_проц
FROM products  AS p
JOIN categories AS c ON c.id = p.category_id
ORDER BY c.name, p.revenue DESC, p.id;
