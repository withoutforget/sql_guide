-- Задача 11. Гипотетический ранг: какое место по цене занял бы товар за 10 000 ₽.
SET search_path TO lab009;

-- Гипотетические агрегаты примеряют аргумент к группе, НЕ вставляя его:
--   rank(10000)         — место с пропусками (1 + сколько цен строго меньше);
--   dense_rank(10000)   — плотное место, без пропусков;
--   percent_rank(10000) — относительный ранг 0..1: (rank−1)/n;
--   cume_dist(10000)    — доля «не дороже него» с учётом самого товара.
-- ЭТО НЕ оконные rank() OVER (...) — те дают ранг каждой строки (это lab010).
-- Здесь у функции ЕСТЬ аргумент и WITHIN GROUP → одна строка на группу.
SELECT
    category                                                         AS категория,
    count(*)                                                         AS товаров,
    rank(10000)         WITHIN GROUP (ORDER BY price)                AS место_rank,
    dense_rank(10000)   WITHIN GROUP (ORDER BY price)                AS место_dense,
    round(percent_rank(10000) WITHIN GROUP (ORDER BY price)::numeric, 4) AS percent_rank,
    round(cume_dist(10000)    WITHIN GROUP (ORDER BY price)::numeric, 4) AS cume_dist
FROM products
GROUP BY category
ORDER BY категория;
