-- Задача 12. 🔥 Для каждой категории — топ-2 товара И их доля в выручке категории.
SET search_path TO lab010;

-- Хардкор-«сборка»: в одном отчёте top-N на группу (row_number) + доля в разделе
-- (sum OVER PARTITION). Изюм — в ПОРЯДКЕ вычислений:
--   * И row_number, И итог категории cat_total считаем в CTE по ВСЕМ товарам
--     категории — ДО фильтрации. Поэтому доля берётся от ПОЛНОГО итога категории.
--   * Если бы мы сперва оставили топ-2, а потом суммировали — знаменатель был бы
--     неверным (сумма только двух товаров, а не всей категории). Окно считается
--     раньше, чем внешний WHERE отбросит строки, — на этом и построен приём.
-- Снаружи оставляем rn <= 2 и делим выручку на cat_total. В Доме два лидера по 24000
-- делят топ и дают одинаковую долю 42.11%; доводчик ", p.id" фиксирует их порядок.
WITH ranked AS (
    SELECT
        c.name   AS category,
        p.name   AS product,
        p.revenue,
        row_number() OVER (PARTITION BY c.name ORDER BY p.revenue DESC, p.id) AS rn,
        sum(p.revenue) OVER (PARTITION BY c.name)                             AS cat_total
    FROM products  AS p
    JOIN categories AS c ON c.id = p.category_id
)
SELECT
    category                             AS категория,
    rn                                   AS место,
    product                              AS товар,
    revenue                              AS выручка,
    cat_total                            AS итог_категории,
    round(100.0 * revenue / cat_total, 2) AS доля_в_кат_проц
FROM ranked
WHERE rn <= 2
ORDER BY cat_total DESC, место;
