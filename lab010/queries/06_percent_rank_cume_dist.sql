-- Задача 6. Относительное положение товара по цене: PERCENT_RANK и CUME_DIST.
SET search_path TO lab010;

-- Две меры «насколько строка впереди/позади» по цене среди всех товаров:
--   percent_rank() = (rank-1)/(n-1) — доля СТРОГО обойдённых, 0..1 (у самого
--                    дешёвого 0, у самого дорогого 1);
--   cume_dist()    = (сколько цен ≤ текущей)/n — кумулятивная доля «не дороже него».
-- Это ОКОННЫЕ версии гипотетических percent_rank/cume_dist WITHIN GROUP из lab009:
-- там примеряли ОДНО значение (10000) и получали одно число; здесь каждая реальная
-- строка получает свою долю. У равных цен (две по 1000) значения совпадают.
SELECT
    name                                                        AS товар,
    price                                                       AS цена,
    round(percent_rank() OVER (ORDER BY price)::numeric, 4)     AS percent_rank,
    round(cume_dist()    OVER (ORDER BY price)::numeric, 4)     AS cume_dist
FROM products
ORDER BY price, id;
