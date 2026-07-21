-- Задача 11. RFM-скор: каждую метрику раскладываем на 5 квинтилей через NTILE(5).
SET search_path TO lab012;

-- NTILE(5) OVER (ORDER BY метрика) делит клиентов на 5 корзин 1..5 по позиции в
-- порядке. НАПРАВЛЕНИЕ важно: больший скор должен значить «лучше».
--   R: свежее (больше последний период) — лучше → ORDER BY r ASC даёт скор 5 самым
--      свежим. (Если бы recency считали как «периодов НАЗАД», меньше=лучше — порядок
--      пришлось бы развернуть; см. теорию.)
--   F, M: больше — лучше → ORDER BY ASC даёт скор 5 самым частым/щедрым.
-- Тай-брейкер id добавлен, чтобы NTILE делил РАВНЫЕ значения детерминированно:
-- NTILE режет по позиции строки, поэтому при ничьих порядок влияет на корзину.
WITH rfm AS (
    SELECT c.id, c.name,
           max(o.period) AS r, count(*) AS f, sum(o.amount) AS m
    FROM orders AS o JOIN customers AS c ON c.id = o.customer_id
    GROUP BY c.id, c.name
)
SELECT
    name AS клиент, r, f, m,
    ntile(5) OVER (ORDER BY r ASC, id) AS r_скор,
    ntile(5) OVER (ORDER BY f ASC, id) AS f_скор,
    ntile(5) OVER (ORDER BY m ASC, id) AS m_скор,
    ( ntile(5) OVER (ORDER BY r ASC, id)
    + ntile(5) OVER (ORDER BY f ASC, id)
    + ntile(5) OVER (ORDER BY m ASC, id) ) AS rfm_сумма
FROM rfm
ORDER BY rfm_сумма DESC, m DESC;
