-- Задача 12. ABC-анализ клиентов (принцип Парето): накопленная доля выручки и класс.
SET search_path TO lab012;

-- Шаги: (1) выручка клиента; (2) доля от общей = x / sum(x) OVER (); (3)
-- НАКОПЛЕННАЯ доля — нарастающий итог доли по убыванию выручки (running total из
-- lab011): sum(...) OVER (ORDER BY выручка DESC ...); (4) класс по накопленной
-- доле: A ≤ 80 %, B ≤ 95 %, C — остальное. Клиент, чья накопленная доля ПЕРЕСЕКАЕТ
-- границу, попадает в БОЛЕЕ КРУПНЫЙ класс (Глеб на 81 % → B; см. теорию о границе).
WITH rev AS (
    SELECT c.id, c.name, sum(o.amount) AS выручка
    FROM orders AS o JOIN customers AS c ON c.id = o.customer_id
    GROUP BY c.id, c.name
),
shares AS (
    SELECT id, name, выручка,
           round(100.0 * выручка / sum(выручка) OVER (), 1)               AS доля_проц,
           round(100.0 * sum(выручка) OVER (ORDER BY выручка DESC, id)
                       / sum(выручка) OVER (), 1)                         AS накопл_проц
    FROM rev
)
SELECT
    name AS клиент, выручка, доля_проц, накопл_проц,
    CASE WHEN накопл_проц <= 80 THEN 'A'
         WHEN накопл_проц <= 95 THEN 'B'
         ELSE 'C' END AS класс
FROM shares
ORDER BY выручка DESC;
