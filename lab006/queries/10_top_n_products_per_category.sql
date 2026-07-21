-- Задача 10. Два самых дорогих товара в каждой категории (top-N на группу через LATERAL).
SET search_path TO lab006;

-- Тот же приём top-N, но группа — категория, а не клиент. Слева перебираем
-- категории; правый LATERAL-подзапрос для каждой категории берёт её товары
-- (p.category_id = cat.id — корреляция), сортирует по цене и оставляет два самых
-- дорогих. CROSS JOIN LATERAL здесь безопасен: в каждой категории есть товары,
-- пустых справа наборов не будет (иначе взяли бы LEFT JOIN LATERAL).
-- В «Спорте» всего два товара — вернутся оба; в остальных категориях — ровно
-- топ-2 по цене. Это тот запрос, который без LATERAL/оконных пришлось бы собирать
-- заметно многословнее.
SELECT cat.name    AS category,
       t.name      AS product,
       t.price
FROM categories AS cat
CROSS JOIN LATERAL (
    SELECT p.name, p.price
    FROM products AS p
    WHERE p.category_id = cat.id          -- корреляция: товары этой категории
    ORDER BY p.price DESC
    LIMIT 2                               -- top-2 внутри группы
) AS t
ORDER BY cat.name, t.price DESC;
