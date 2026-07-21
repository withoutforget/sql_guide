-- Задача 14. 🔥 Правильный «средний чек оплаченных заказов»: три ловушки типов сразу.
SET search_path TO lab013;

-- Считаем средний чистый чек (выручка минус скидка) ТОЛЬКО по оплаченным заказам.
-- Наивная формула ошибается в трёх местах одновременно (она НЕ падает — просто
-- выдаёт неверное число):
--   1) NULL: discount_rub бывает NULL, и revenue_rub - discount_rub на таких
--      строках становится NULL → sum() их выкидывает и занижает выручку;
--   2) целочисленное деление: sum(...)/count(...) режет дробную часть;
--   3) счёт не по тем строкам: делит на ВСЕ заказы (count(*)), а не только
--      оплаченные, — искажает средний чек (у Глеба наивно выйдет 1300, хотя
--      оплаченных заказов у него нет вовсе).
-- Правильная формула чинит всё: COALESCE(discount,0), приведение к numeric с
-- round(_, 2), FILTER (WHERE is_paid) в числителе и знаменателе. И вот тут нужен
-- NULLIF: знаменатель «оплаченных» у Глеба = 0, и NULLIF(0,0) → NULL спасает от
-- деления на ноль (у Глеба correct = NULL — «оплаченных заказов нет»).
SELECT
    customer,
    count(*)                            AS orders_all,
    count(*) FILTER (WHERE is_paid)     AS orders_paid,
    -- НАИВНО (неверно): NULL-скидки теряются, int-деление, считаем по всем заказам
    sum(revenue_rub - discount_rub) / count(*)                          AS avg_check_naive,
    -- ПРАВИЛЬНО: coalesce + filter + numeric + round + защита от деления на ноль
    round(
        (sum(revenue_rub - coalesce(discount_rub, 0)) FILTER (WHERE is_paid))::numeric
        / NULLIF(count(*) FILTER (WHERE is_paid), 0),
        2
    )                                                                   AS avg_check_correct
FROM orders
GROUP BY customer
ORDER BY customer;
