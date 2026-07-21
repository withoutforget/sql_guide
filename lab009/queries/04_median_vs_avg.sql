-- Задача 4. Медиана против среднего по категориям: где среднее «врёт» из-за перекоса.
SET search_path TO lab009;

-- median = percentile_cont(0.5) — цена ровно посередине набора; на неё НЕ влияют
-- выбросы. avg — влияют. Разрыв (avg − median) — индикатор перекоса:
--   большой положительный разрыв → перекос вправо (дорогие «хвосты» задрали среднее).
-- Смотри «Электронику»: один ноутбук за 90 000 утянул среднее до 21 500,
-- хотя типичный товар стоит 8 000 (медиана). В «Книгах»/«Играх» разрыв ≈ 0.
SELECT
    category                                            AS категория,
    count(*)                                            AS n,
    round(avg(price), 2)                                AS среднее,
    percentile_cont(0.5) WITHIN GROUP (ORDER BY price)  AS медиана,
    round(avg(price) - percentile_cont(0.5)
          WITHIN GROUP (ORDER BY price)::numeric, 2)    AS разрыв_avg_median
FROM products
GROUP BY category
ORDER BY разрыв_avg_median DESC;
