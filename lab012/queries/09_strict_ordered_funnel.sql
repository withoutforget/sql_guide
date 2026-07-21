-- Задача 9. 🔥 Строгая воронка: шаг засчитан, только если шаги 1..k прошли строго по порядку (seq).
SET search_path TO lab012;

-- Посетитель засчитан на шаг k, только если события шагов 1..k идут строго по возрастанию времени
-- (seq). Сравниваем со «свободной» воронкой из задачи 8.

-- Приём в три хода:
--   (1) ПИВОТ (условная агрегация): для каждого посетителя собираем seq каждого
--       шага в отдельные колонки s1..s5 (нет шага → NULL);
--   (2) флаги «дошёл ПО ПОРЯДКУ до k»: s1..sk заданы и строго возрастают
--       (s1 < s2 < ... < sk). Сравнение с NULL даёт NULL → в FILTER не считается;
--   (3) UNPIVOT флагов (LATERAL VALUES, приём из зад. 2) и подсчёт по шагам.
-- Посетитель 4 положил в корзину РАНЬШЕ просмотра (s3 < s2), поэтому по порядку до
-- корзины НЕ доходит: строгая воронка на шаге «Корзина» даёт 4 вместо 5.
WITH seqs AS (
    SELECT visitor_id,
           min(seq) FILTER (WHERE step = 1) AS s1,
           min(seq) FILTER (WHERE step = 2) AS s2,
           min(seq) FILTER (WHERE step = 3) AS s3,
           min(seq) FILTER (WHERE step = 4) AS s4,
           min(seq) FILTER (WHERE step = 5) AS s5
    FROM funnel_events
    GROUP BY visitor_id
),
flags AS (
    SELECT
        (s1 IS NOT NULL)                                                 AS f1,
        (s2 > s1)                                                        AS f2,
        (s2 > s1 AND s3 > s2)                                            AS f3,
        (s2 > s1 AND s3 > s2 AND s4 > s3)                                AS f4,
        (s2 > s1 AND s3 > s2 AND s4 > s3 AND s5 > s4)                    AS f5
    FROM seqs
)
SELECT
    fs.step_name                          AS шаг,
    count(*) FILTER (WHERE u.reached)     AS строгая_воронка
FROM flags
CROSS JOIN LATERAL (VALUES
    (1, f1), (2, f2), (3, f3), (4, f4), (5, f5)
) AS u(step, reached)
JOIN funnel_steps AS fs ON fs.step = u.step
GROUP BY fs.step, fs.step_name
ORDER BY fs.step;
