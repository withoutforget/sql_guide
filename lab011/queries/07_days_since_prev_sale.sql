-- Задача 7. Сколько дней прошло с прошлой продажи товара (LAG по дате, поиск разрывов).
SET search_path TO lab011;

-- lag(sale_date) даёт дату ПРЕДЫДУЩЕЙ продажи товара; вычитание двух дат в PostgreSQL
-- возвращает ЧИСЛО ДНЕЙ между ними (целое). У «Робота-пылесоса» есть пропуски, поэтому
-- увидим интервалы не только по 1 дню, но и по 2 — это и есть разрывы в ряду. В первый
-- день предыдущей продажи нет → LAG вернёт NULL. Флаг помечает дни после паузы.
WITH d AS (
    SELECT
        p.name AS товар, s.sale_date, s.revenue,
        lag(s.sale_date) OVER (PARTITION BY s.product_id
                               ORDER BY s.sale_date) AS прошлая_продажа
    FROM sales AS s
    JOIN products AS p ON p.id = s.product_id
)
SELECT
    товар,
    sale_date                     AS дата,
    прошлая_продажа,
    sale_date - прошлая_продажа   AS дней_с_прошлой,
    CASE WHEN sale_date - прошлая_продажа > 1 THEN '⚠ был пропуск' ELSE '' END AS разрыв
FROM d
WHERE товар = 'Робот-пылесос'
ORDER BY дата;
