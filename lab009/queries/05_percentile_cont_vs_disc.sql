-- Задача 5. percentile_cont vs percentile_disc на одних данных: в чём разница.
SET search_path TO lab009;

-- Обе функции считают медиану (перцентиль 0.5), но по-разному:
--   percentile_cont — ИНТЕРПОЛИРУЕТ середину (значения может не быть в данных);
--   percentile_disc — берёт РЕАЛЬНОЕ значение из набора (без интерполяции).
-- При ЧЁТНОМ числе товаров они РАЗЛИЧАЮТСЯ:
--   Электроника (6 шт): cont=8000 ≠ disc=7000;  Книги (4 шт): cont=800 ≠ disc=700.
-- При НЕЧЁТНОМ — совпадают (медиана падает на реальный средний элемент):
--   Дом (5 шт): 3000 = 3000;  Игры (5 шт): 2000 = 2000.
SELECT
    category                                            AS категория,
    count(*)                                            AS n,
    percentile_cont(0.5) WITHIN GROUP (ORDER BY price)  AS median_cont,
    percentile_disc(0.5) WITHIN GROUP (ORDER BY price)  AS median_disc,
    percentile_cont(0.5) WITHIN GROUP (ORDER BY price)
        <> percentile_disc(0.5) WITHIN GROUP (ORDER BY price) AS различаются
FROM products
GROUP BY category
ORDER BY category;
