-- Задача 15. 🔥 Тепловая карта активности июня: каждый день с днём недели, пометкой выходных и числом заказов.
SET search_path TO lab014;
SET TIME ZONE 'UTC';   -- детерминизм

-- Собираем вместе gap-filling + календарь. generate_series даёт ВСЕ дни июня (даже
-- пустые), LEFT JOIN подтягивает заказы, count(o.id) считает их (0 в пустой день).
-- День недели пишем по-русски через CASE по isodow (1..7) — НЕ через to_char('Day'),
-- т.к. то зависит от локали lc_time и «поплыло» бы (см. theory/05). Выходной =
-- isodow IN (6,7). Псевдо-«тепло» рисуем текстом: чем больше заказов, тем длиннее
-- полоска (repeat не проходили — обходимся CASE). Видно: заказы кучкуются по
-- субботам, будни в основном пустые — «карта» продаж без единой дыры.
SELECT
    cal.d::date                                        AS день,
    CASE EXTRACT(isodow FROM cal.d)
        WHEN 1 THEN 'пн' WHEN 2 THEN 'вт' WHEN 3 THEN 'ср' WHEN 4 THEN 'чт'
        WHEN 5 THEN 'пт' WHEN 6 THEN 'сб' WHEN 7 THEN 'вс'
    END                                                AS день_недели,
    CASE WHEN EXTRACT(isodow FROM cal.d) IN (6,7) THEN 'выходной' ELSE '' END AS выходной,
    count(o.id)                                        AS заказов,
    CASE count(o.id) WHEN 0 THEN '·' WHEN 1 THEN '█' WHEN 2 THEN '██' ELSE '███' END AS тепло
FROM generate_series(date '2024-06-01', date '2024-06-30', interval '1 day') AS cal(d)
LEFT JOIN orders AS o
       ON o.created_at >= cal.d
      AND o.created_at <  cal.d + interval '1 day'
GROUP BY cal.d
ORDER BY cal.d;
