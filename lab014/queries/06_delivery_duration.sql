-- Задача 6. Длительность доставки: как interval и как число часов (EXTRACT epoch).
SET search_path TO lab014;
SET TIME ZONE 'UTC';   -- детерминизм

-- Вычитание двух timestamptz даёт INTERVAL (напр. '2 days 05:30:00') — «человеческая»
-- длительность. Чтобы получить ЧИСЛО (для сравнения/сортировки/усреднения), берём
-- EXTRACT(epoch FROM интервал) — это ВСЯ длительность в секундах; делим на 3600 → часы.
-- delivered_at может быть NULL (заказ ещё едет) — тогда и разность, и epoch дают NULL;
-- такие заказы отсекаем в WHERE, чтобы считать только доставленные.
SELECT
    id,
    delivered_at - created_at                                        AS длительность,
    round(EXTRACT(epoch FROM (delivered_at - created_at)) / 3600.0, 1) AS часов,
    round(EXTRACT(epoch FROM (delivered_at - created_at)) / 60.0)      AS минут
FROM orders
WHERE delivered_at IS NOT NULL
ORDER BY (delivered_at - created_at) DESC, id;
