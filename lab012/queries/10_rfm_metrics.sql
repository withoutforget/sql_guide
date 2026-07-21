-- Задача 10. RFM-метрики каждого клиента: Recency, Frequency, Monetary.
SET search_path TO lab012;

-- R (recency) — давность последней покупки; здесь последний активный период
--   max(period): чем БОЛЬШЕ номер, тем свежее (лучше).
-- F (frequency) — число покупок (строк заказов), count(*).
-- M (monetary) — суммарная выручка клиента, sum(amount), ₽.
SELECT
    c.name        AS клиент,
    max(o.period) AS r_последний_период,
    count(*)      AS f_покупок,
    sum(o.amount) AS m_сумма
FROM orders AS o
JOIN customers AS c ON c.id = o.customer_id
GROUP BY c.id, c.name
ORDER BY m_сумма DESC;
