-- Задача 8. Плановый срок доставки (заказ + 3 дня) и уложились ли в него.
SET search_path TO lab014;
SET TIME ZONE 'UTC';   -- детерминизм

-- Прибавляем к моменту заказа INTERVAL (created_at + interval '3 days') → плановый
-- дедлайн доставки (SLA 3 дня). Прибавление к timestamptz требует именно interval,
-- а не голого числа. Сравниваем факт с планом:
--   delivered_at IS NULL → «ещё едет» (доставки не было);
--   delivered_at <= дедлайн → «в срок»; иначе «просрочено».
-- Для просроченных показываем, на сколько опоздали (delivered_at - дедлайн → interval).
-- В наших данных просрочен только заказ 4 (доставлен на 5.5 ч позже дедлайна).
SELECT
    id,
    created_at,
    created_at + interval '3 days'                      AS дедлайн,
    delivered_at,
    CASE
        WHEN delivered_at IS NULL                        THEN 'ещё едет'
        WHEN delivered_at <= created_at + interval '3 days' THEN 'в срок'
        ELSE 'просрочено'
    END                                                 AS статус,
    CASE WHEN delivered_at > created_at + interval '3 days'
         THEN delivered_at - (created_at + interval '3 days')
    END                                                 AS опоздание
FROM orders
ORDER BY created_at;
