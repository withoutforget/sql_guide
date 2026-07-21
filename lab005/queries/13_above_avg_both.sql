-- Задача 13. 🔥 Категории, которые выше среднего И по выручке, И по числу покупателей.
SET search_path TO lab005;

-- Изюм: собираем аналитику по ДВУМ измерениям сразу и пересекаем результаты.
-- Категория может быть сильной в деньгах, но узкой по аудитории (Дом: много
-- выручки, всего 2 покупателя) или популярной, но дешёвой (Книги: 4 покупателя,
-- но мало денег). Ищем категории, сильные в ОБОИХ измерениях.
--   ШАГ 1 (cat_stats)    — по каждой категории сразу два показателя: выручка и
--                          число уникальных покупателей (COUNT(DISTINCT ...));
--   ШАГ 2 (rev_above)    — категории выше средней выручки (цепочка на шаг 1);
--   ШАГ 3 (buyers_above) — категории выше среднего числа покупателей (тоже на шаг 1);
--   ФИНАЛ — пересечение двух наборов (INTERSECT из lab003; можно и через IN).
-- cat_stats переиспользован тремя шагами. Средняя выручка = 27464, среднее число
-- покупателей = 3. Выше по деньгам: Электроника, Дом; выше по охвату: Электроника,
-- Книги. В обоих измерениях сильна ТОЛЬКО Электроника.
WITH
    cat_stats AS (
        SELECT p.category_id,
               SUM(p.price * o.quantity)          AS revenue,
               COUNT(DISTINCT o.customer_id)      AS buyers
        FROM orders   AS o
        JOIN products AS p ON p.id = o.product_id
        GROUP BY p.category_id
    ),
    rev_above AS (
        SELECT category_id
        FROM cat_stats
        WHERE revenue > (SELECT AVG(revenue) FROM cat_stats)
    ),
    buyers_above AS (
        SELECT category_id
        FROM cat_stats
        WHERE buyers > (SELECT AVG(buyers) FROM cat_stats)
    )
SELECT cat.name
FROM categories AS cat
WHERE cat.id IN (
        SELECT category_id FROM rev_above
      INTERSECT
        SELECT category_id FROM buyers_above
      )
ORDER BY cat.name;
