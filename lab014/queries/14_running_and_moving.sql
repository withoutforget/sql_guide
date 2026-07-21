-- Задача 14. На сплошном ряду дней июня: running total и 7-дневное скользящее среднее.
SET search_path TO lab014;
SET TIME ZONE 'UTC';   -- детерминизм

-- Сначала выравниваем ряд (gap-filling из задачи 13, но на весь июнь), затем поверх
-- БЕЗ ДЫР применяем оконные функции (lab011). Почему сначала выравниваем: lag и
-- рамка ROWS считают «строки», и только на сплошном ряду «строка назад» = «день
-- назад». running_total (sum OVER ORDER BY day) копит выручку нарастающим итогом,
-- проходя и через нулевые дни; ma7 (avg по рамке ROWS 6 PRECEDING..CURRENT ROW) —
-- среднее за текущий и 6 предыдущих дней (в начале месяца рамка короче).
WITH daily AS (
    SELECT cal.d::date               AS день,
           coalesce(sum(o.amount),0) AS выручка
    FROM generate_series(date '2024-06-01', date '2024-06-30', interval '1 day') AS cal(d)
    LEFT JOIN orders AS o ON o.created_at >= cal.d
                         AND o.created_at <  cal.d + interval '1 day'
    GROUP BY cal.d
)
SELECT
    день,
    выручка,
    sum(выручка) OVER (ORDER BY день)                                    AS нараст_итог,
    round(avg(выручка) OVER (ORDER BY день
                             ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 0) AS скольз_ср_7д
FROM daily
ORDER BY день;
