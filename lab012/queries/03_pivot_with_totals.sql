-- Задача 3. Сводная с итогами: месяцы × категории + столбец «Итого» + строка «ВСЕГО» (GROUPING SETS).
SET search_path TO lab012;

-- Строки — месяцы, столбцы — категории, плюс столбец «Итого за месяц» и итоговая строка «ВСЕГО».

-- Пивот (категории → столбцы через FILTER) и группировки из lab008 работают
-- вместе. GROUPING SETS ((период, ярлык), ()) даёт и детальные строки по месяцам,
-- и одну итоговую строку, где период свёрнут в NULL (набор ()). Итоговую строку
-- узнаём по NULL в period и подписываем «ВСЕГО».
SELECT
    COALESCE(pr.label, 'ВСЕГО')                                        AS месяц,
    COALESCE(SUM(o.amount) FILTER (WHERE o.category = 'Электроника'),0) AS электроника,
    COALESCE(SUM(o.amount) FILTER (WHERE o.category = 'Книги'), 0)      AS книги,
    COALESCE(SUM(o.amount) FILTER (WHERE o.category = 'Дом'), 0)        AS дом,
    SUM(o.amount)                                                      AS итого_за_месяц
FROM orders AS o
JOIN periods AS pr ON pr.period = o.period
GROUP BY GROUPING SETS ((o.period, pr.label), ())
ORDER BY o.period NULLS LAST;
