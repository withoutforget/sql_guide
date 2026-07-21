-- Задача 8. Разброс цен по категориям: стандартное отклонение и дисперсия.
SET search_path TO lab009;

-- stddev_samp — «типичное отклонение цены от средней» в тех же единицах (₽).
-- var_samp — дисперсия (стандартное отклонение в квадрате), в ₽² (читать неудобно).
-- Суффикс _samp = ВЫБОРОЧНАЯ версия (делитель n−1), _pop = ГЕНЕРАЛЬНАЯ (делитель n).
-- Коэффициент вариации (стд.откл / среднее) сравнивает разброс категорий с разным
-- масштабом цен: у «Электроники» он > 1 (разброс больше самого среднего!).
SELECT
    category                                 AS категория,
    count(*)                                 AS n,
    round(avg(price), 2)                     AS среднее,
    round(stddev_samp(price), 2)             AS стд_откл_samp,
    round(stddev_pop(price), 2)              AS стд_откл_pop,
    round(var_samp(price), 2)                AS дисперсия_samp,
    round(stddev_samp(price) / avg(price), 2) AS коэф_вариации
FROM products
GROUP BY category
ORDER BY стд_откл_samp DESC;
