-- Задача 14. 🔥 Мини-ETL: разобрать логи вида «key=value» и агрегировать по пользователю.
SET search_path TO lab015;

-- Строки логов: 'user=anna action=buy amount=1990'. Разбор в два этапа (ETL):
--   1) parsed — вытаскиваем нужные поля регулярками с группами и сразу приводим
--      сумму к числу (::int, приведение типов — lab013);
--   2) агрегируем: число событий, число покупок и потраченное — по каждому юзеру.
-- FILTER считает агрегат только по строкам-покупкам; COALESCE ставит 0 тем, у кого
-- покупок не было. (Если ключи заранее не известны — все пары можно развернуть
-- через regexp_matches(line, '(\w+)=(\w+)', 'g') в LATERAL, как в задаче 12.)
WITH parsed AS (
    SELECT id,
           substring(line FROM 'user=(\w+)')        AS usr,
           substring(line FROM 'action=(\w+)')      AS action,
           substring(line FROM 'amount=(\d+)')::int AS amount
    FROM logs
)
SELECT
    usr                                                    AS "user",
    count(*)                                               AS events,
    count(*) FILTER (WHERE action = 'buy')                 AS buys,
    COALESCE(sum(amount) FILTER (WHERE action = 'buy'), 0) AS spent
FROM parsed
GROUP BY usr
ORDER BY spent DESC, usr;
