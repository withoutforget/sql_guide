-- Задача 13. 🔥 Отчёт «регион × канал» с подытогами, долями и корректной обработкой настоящих NULL.
SET search_path TO lab008;

-- Собираем аналитический отчёт по региону и каналу через ROLLUP (region, channel):
-- детализация (регион × канал) + подытог по региону + общий итог. Три сложности
-- сразу, и все решаются пройденным:
--  1) region в данных БЫВАЕТ NULL («не указан»). В отчёте должны различаться ТРИ
--     вида строк с region = NULL: детали «не указан» (GROUPING(region)=0), подытог
--     по «не указан» (GROUPING(region)=0, GROUPING(channel)=1) и общий итог
--     (GROUPING(region)=1). Разводим их маской GROUPING; ветку GROUPING() в CASE
--     ставим ПЕРВОЙ — до проверки region IS NULL.
--  2) Доля от общего итога — БЕЗ оконных функций (нельзя, это lab010): общий SUM
--     берём скалярным подзапросом из lab004 — (SELECT SUM(amount) FROM sales).
--  3) Сортировка: подытог региона под его деталями, общий итог в самом низу —
--     через GROUPING() в ORDER BY.
-- Проверка долей: Москва 59% + СПб 34% + «не указан» 7% = 100%.
SELECT
    CASE WHEN GROUPING(region) = 1 THEN 'ВСЕ РЕГИОНЫ'
         WHEN region IS NULL       THEN '(регион не указан)'
         ELSE region END           AS регион,
    CASE WHEN GROUPING(channel) = 1 THEN 'все каналы'
         ELSE channel END          AS канал,
    SUM(amount) AS revenue,
    ROUND(100.0 * SUM(amount) / (SELECT SUM(amount) FROM sales), 1) AS доля_pct
FROM sales
GROUP BY ROLLUP (region, channel)
ORDER BY GROUPING(region), region NULLS FIRST, GROUPING(channel), channel;
