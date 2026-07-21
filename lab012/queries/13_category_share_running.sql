-- Задача 13. Доля каждой категории в выручке и накопленная (running) доля.
SET search_path TO lab012;

-- share of total: выручка_категории / sum(выручка) OVER () — вклад категории в
-- общую выручку. running share: нарастающая доля по убыванию — сколько «набирают»
-- топ-категории вместе (тот же приём накопленной доли, что в ABC, но по категориям).
WITH cat AS (
    SELECT category, sum(amount) AS выручка
    FROM orders GROUP BY category
)
SELECT
    category AS категория,
    выручка,
    round(100.0 * выручка / sum(выручка) OVER (), 1)                  AS доля_проц,
    round(100.0 * sum(выручка) OVER (ORDER BY выручка DESC, category)
                / sum(выручка) OVER (), 1)                            AS накопл_проц
FROM cat
ORDER BY выручка DESC;
