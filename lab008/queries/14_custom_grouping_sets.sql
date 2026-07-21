-- Задача 14. 🔥 Ровно нужные подытоги, которых не даёт ни ROLLUP, ни CUBE (произвольный GROUPING SETS).
SET search_path TO lab008;

-- Нужен отчёт РОВНО с тремя блоками и ничем лишним:
--   (1) по каждой паре (категория, канал);
--   (2) по каждому региону;
--   (3) общий итог.
-- Ни ROLLUP, ни CUBE так не умеют: ROLLUP (category, channel, region) дал бы
-- иерархию префиксов, а CUBE (category, channel, region) — все 2^3 = 8 наборов
-- (куча лишнего). Такой НЕСТАНДАРТНЫЙ набор задаётся только явным GROUPING SETS —
-- три набора: (category, channel), (region) и пустой ().
-- Каждую строку помечаем «секцией» по маске GROUPING: если пара (category,
-- channel) не свёрнута — блок 1; иначе если region не свёрнут — блок 2; иначе
-- общий итог. Настоящий NULL региона в блоке 2 подписываем «(не указан)» — по
-- GROUPING(region)=0, не путая с итоговым NULL.
-- Сортировка держит блоки вместе: сперва блок 1 (по категории и каналу), затем
-- блок 2 (по региону), затем итог.
SELECT
    CASE
        WHEN GROUPING(category, channel) = 0 THEN 'Категория×Канал'
        WHEN GROUPING(region)            = 0 THEN 'Регион'
        ELSE 'ИТОГО'
    END                                       AS секция,
    category, channel,
    CASE WHEN region IS NULL AND GROUPING(region) = 0 THEN '(не указан)'
         ELSE region END                      AS регион,
    SUM(amount) AS revenue
FROM sales
GROUP BY GROUPING SETS ((category, channel), (region), ())
ORDER BY
    GROUPING(category, channel), category, channel,
    GROUPING(region), region NULLS FIRST;
