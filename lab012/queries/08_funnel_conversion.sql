-- Задача 8. Воронка конверсии: дошедшие до каждого шага, конверсия шаг-к-шагу и от вершины.
SET search_path TO lab012;

-- Считаем уникальных посетителей на каждом шаге воронки.

-- «Дошёл до шага» = у посетителя есть событие этого шага (без учёта порядка —
-- строгий порядок в задаче 9). LEFT JOIN от справочника шагов гарантирует строку
-- на КАЖДЫЙ шаг, даже если на него никто не дошёл. Дальше:
--   • конверсия к предыдущему = дошло / дошло_на_пред_шаге (LAG из lab011);
--   • от вершины = дошло / дошло_на_шаге_1 (first_value окна).
-- NULLIF(..., 0) защищает от деления на ноль, если на шаге вдруг никого.
WITH reached AS (
    SELECT fs.step, fs.step_name,
           count(DISTINCT fe.visitor_id) AS посетителей
    FROM funnel_steps AS fs
    LEFT JOIN funnel_events AS fe ON fe.step = fs.step
    GROUP BY fs.step, fs.step_name
)
SELECT
    step_name                                                     AS шаг,
    посетителей,
    round(100.0 * посетителей
          / NULLIF(lag(посетителей) OVER (ORDER BY step), 0), 1)  AS конв_к_пред_проц,
    round(100.0 * посетителей
          / first_value(посетителей) OVER (ORDER BY step), 1)     AS от_вершины_проц
FROM reached
ORDER BY step;
