-- Задача 9. Границы месяца для набора дат: первый/последний день, дней в месяце, сколько осталось.
SET search_path TO lab014;
SET TIME ZONE 'UTC';   -- детерминизм

-- Бизнес-календарь на скалярных функциях, без справочников. Берём несколько
-- фиксированных дат (в т.ч. високосный февраль 2024 и 31-дневный март) и считаем:
--   первый день  = date_trunc('month', d)
--   последний    = начало след. месяца минус 1 день (сам учитывает 28/29/30/31)
--   дней в месяце= день последней даты месяца
--   осталось     = последний день − d  (date − date = число дней)
-- generate_series здесь не нужен — это разбор одной даты; ряд дат берём из VALUES.
WITH sample(d) AS (
    VALUES (date '2024-02-10'), (date '2024-03-15'), (date '2024-06-12'), (date '2024-09-05')
)
SELECT
    d,
    date_trunc('month', d)::date                                        AS первый_день,
    (date_trunc('month', d) + interval '1 month' - interval '1 day')::date AS последний_день,
    EXTRACT(day FROM (date_trunc('month', d) + interval '1 month' - interval '1 day')) AS дней_в_месяце,
    (date_trunc('month', d) + interval '1 month' - interval '1 day')::date - d          AS осталось_до_конца
FROM sample
ORDER BY d;
