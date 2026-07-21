-- Задача 14. 🔥 RFM-сегменты с человекочитаемыми названиями.
SET search_path TO lab012;

-- Собираем R- и F-скоры (NTILE(5), как в зад. 11), затем правилами на скорах
-- назначаем сегмент (M оставляем для сортировки/приоритета). Порядок веток в CASE
-- важен: первая подошедшая выигрывает.
--   «Чемпионы»    — свежие и частые   (R≥4 и F≥4);
--   «Верные»      — частые, но не топ по свежести (F≥4);
--   «Новички»     — свежие, но покупали мало (R≥4 и F≤2);
--   «В зоне риска» — были частыми, но давно не заходили (R≤2 и F≥3);
--   «Спящие»      — давно и редко (R≤2 и F≤2);
--   «Прочие»      — середняки, не попавшие ни в одно правило.
WITH rfm AS (
    SELECT c.id, c.name,
           max(o.period) AS r, count(*) AS f, sum(o.amount) AS m
    FROM orders AS o JOIN customers AS c ON c.id = o.customer_id
    GROUP BY c.id, c.name
),
scored AS (
    SELECT name, r, f, m,
           ntile(5) OVER (ORDER BY r ASC, id) AS r_скор,
           ntile(5) OVER (ORDER BY f ASC, id) AS f_скор
    FROM rfm
)
SELECT
    name AS клиент, r, f, m, r_скор, f_скор,
    CASE
        WHEN r_скор >= 4 AND f_скор >= 4 THEN 'Чемпионы'
        WHEN f_скор >= 4                 THEN 'Верные'
        WHEN r_скор >= 4 AND f_скор <= 2 THEN 'Новички'
        WHEN r_скор <= 2 AND f_скор >= 3 THEN 'В зоне риска'
        WHEN r_скор <= 2 AND f_скор <= 2 THEN 'Спящие'
        ELSE 'Прочие'
    END AS сегмент
FROM scored
ORDER BY r_скор DESC, f_скор DESC, m DESC;
