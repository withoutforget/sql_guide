-- Задача 11. Именованное окно (клауза WINDOW): несколько функций делят одно определение.
SET search_path TO lab011;

-- Когда одно и то же окно нужно многим функциям, его определение выносят в клаузу
-- WINDOW и ссылаются по имени — пишется ОДИН раз. Клауза WINDOW стои́т после HAVING
-- и перед ORDER BY. Здесь показано и НАСЛЕДОВАНИЕ окон:
--   wp  — только разбиение по товару (PARTITION BY);
--   w   — наследует wp и добавляет порядок по дате (ряд товара во времени);
--   wr  — наследует wp и добавляет порядок по выручке (для ранга дня).
-- Окно w переиспользуют сразу три функции. (Наследовать можно окно БЕЗ своего
-- ORDER BY, добавляя свой; PARTITION BY переопределять нельзя.)
SELECT
    p.name                     AS товар,
    s.sale_date                AS дата,
    s.revenue                  AS выручка,
    row_number()   OVER w      AS день_ряда,
    sum(s.revenue) OVER w      AS нарастающий_итог,
    lag(s.revenue) OVER w      AS вчера,
    rank()         OVER wr     AS место_по_выручке
FROM sales AS s
JOIN products AS p ON p.id = s.product_id
WINDOW wp AS (PARTITION BY s.product_id),
       w  AS (wp ORDER BY s.sale_date),
       wr AS (wp ORDER BY s.revenue DESC)
ORDER BY p.name, s.sale_date;
