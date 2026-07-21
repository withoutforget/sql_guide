-- Задача 16. 🔥 Месячный отчёт с ростом месяц-к-месяцу (MoM) на НЕПРЕРЫВНОМ ряду месяцев.
SET search_path TO lab014;
SET TIME ZONE 'UTC';   -- детерминизм

-- Суть: чтобы MoM был корректен, пустой месяц (август — заказов нет) обязан
-- появиться строкой с нулём, иначе lag сравнил бы сентябрь напрямую с июлем
-- (август «съелся») и рост соврал бы. Поэтому:
--   months — сплошной ряд первых чисел месяцев (generate_series, шаг '1 month');
--   rev    — LEFT JOIN заказов на месяцы, coalesce(sum,0) → у августа выручка 0;
--   итог   — lag(выручка) даёт прошлый месяц, рост % = (тек−пред)/пред·100.
-- nullif(пред,0) спасает от деления на ноль: у сентября предыдущий (август) = 0,
-- поэтому рост показать нельзя → NULL. Ожидаемо: июнь NULL, июль −61.5%,
-- август −100% (провал в ноль), сентябрь NULL (база — нулевой август).
WITH months AS (
    SELECT m::date AS месяц
    FROM generate_series(date '2024-06-01', date '2024-09-01', interval '1 month') AS g(m)
),
rev AS (
    SELECT ms.месяц,
           coalesce(sum(o.amount), 0) AS выручка
    FROM months AS ms
    LEFT JOIN orders AS o ON o.created_at >= ms.месяц
                         AND o.created_at <  ms.месяц + interval '1 month'
    GROUP BY ms.месяц
)
SELECT
    to_char(месяц, 'YYYY-MM')                     AS месяц,
    выручка,
    lag(выручка) OVER (ORDER BY месяц)            AS прошлый_месяц,
    round(100.0 * (выручка - lag(выручка) OVER (ORDER BY месяц))
          / nullif(lag(выручка) OVER (ORDER BY месяц), 0), 1) AS рост_mom_проц
FROM rev
ORDER BY месяц;
