-- Задача 10. Линия тренда «спрос по цене»: наклон, свободный член, R² по категориям.
SET search_path TO lab009;

-- Линейная регрессия строит прямую  units_sold ≈ intercept + slope · price :
--   regr_slope(Y, X)     — наклон: на сколько изменится спрос при +1 ₽ цены (обычно «−»);
--   regr_intercept(Y, X) — свободный член: прогноз спроса при цене 0;
--   regr_r2(Y, X)        — доля разброса спроса, объяснённая ценой (0..1), = corr².
-- ВАЖЕН порядок (Y, X): Y — что предсказываем, X — по чему.
-- «Дом»: R²=0.86 (точки почти на прямой). «Книги»: R²≈0 (цена спрос не объясняет).
SELECT
    category                                          AS категория,
    count(*)                                          AS n,
    round(regr_slope(units_sold, price)::numeric, 6)  AS наклон,     -- шт. на 1 ₽
    round(regr_intercept(units_sold, price)::numeric, 2) AS свободный_член,
    round(regr_r2(units_sold, price)::numeric, 4)     AS r2
FROM products
GROUP BY category
ORDER BY r2 DESC;
