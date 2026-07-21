-- Задача 7. Цена товара против средней цены его категории (avg(...) OVER (PARTITION BY ...)).
SET search_path TO lab010;

-- avg(price) OVER (PARTITION BY категория) даёт среднюю цену категории РЯДОМ с каждым
-- товаром — можно тут же посчитать отклонение и вынести вердикт, не теряя строки.
-- Это типовой приём «сравнить строку со средним по её группе». diff = цена − среднее.
SELECT
    c.name                                                         AS категория,
    p.name                                                         AS товар,
    p.price                                                        AS цена,
    round(avg(p.price) OVER (PARTITION BY c.name), 2)              AS средняя_по_кат,
    round(p.price - avg(p.price) OVER (PARTITION BY c.name), 2)    AS отклонение,
    CASE
        WHEN p.price > avg(p.price) OVER (PARTITION BY c.name) THEN 'дороже среднего'
        WHEN p.price < avg(p.price) OVER (PARTITION BY c.name) THEN 'дешевле среднего'
        ELSE 'ровно среднее'
    END                                                            AS вердикт
FROM products  AS p
JOIN categories AS c ON c.id = p.category_id
ORDER BY c.name, p.price DESC, p.id;
