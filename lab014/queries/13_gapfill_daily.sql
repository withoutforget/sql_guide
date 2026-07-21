-- Задача 13. Заказы и выручка по каждому дню 1-10 июня, включая пустые дни (gap-filling).
SET search_path TO lab014;
SET TIME ZONE 'UTC';   -- детерминизм

-- Классический gap-filling. Если просто сгруппировать заказы по дню, дни БЕЗ заказов
-- исчезнут — в отчёте появятся дыры. Поэтому строим сплошной каркас дней через
-- generate_series (шаг interval '1 day'), а факты приклеиваем LEFT JOIN. Дни без
-- заказов сохраняются (LEFT JOIN), а count(o.id) и coalesce(sum,0) дают на них ЧЕСТНЫЕ
-- нули. ВАЖНО: считаем count(o.id) (не count(*)!) — иначе пустой день дал бы 1
-- (сама строка календаря). Условие попадания — полуоткрытый интервал [d, d+1 день).
-- В окне 01-10 июня заказы только 01 (1 шт), 03 (2 шт), 08 (1 шт) — остальные дни 0.
SELECT
    cal.d::date                         AS день,
    count(o.id)                         AS заказов,
    coalesce(sum(o.amount), 0)          AS выручка
FROM generate_series(date '2024-06-01', date '2024-06-10', interval '1 day') AS cal(d)
LEFT JOIN orders AS o
       ON o.created_at >= cal.d
      AND o.created_at <  cal.d + interval '1 day'
GROUP BY cal.d
ORDER BY cal.d;
