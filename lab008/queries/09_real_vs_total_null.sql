-- Задача 9. Отличить «регион не указан» (настоящий NULL) от «Все регионы» (итоговый NULL).
SET search_path TO lab008;

-- Ключевая проблема расширенной группировки: в колонке region значение NULL
-- означает и «нет данных» (продажи 4 и 8, регион не указан), и «строка общего
-- итога». По самому значению их не отличить. Решает GROUPING(region): 1 — колонка
-- свёрнута (итог), 0 — настоящее значение (в т.ч. настоящий NULL из данных).
-- Смотри две нижние строки: у обеих region = NULL, но g_region разный — 0
-- (данные «не указан», 70 000) и 1 (общий итог, 1 000 000).
-- В CASE ветку GROUPING() ставим ПЕРВОЙ: иначе общий итог подпишется как
-- «Регион не указан» и отчёт соврёт.
SELECT
    GROUPING(region) AS g_region,
    CASE WHEN GROUPING(region) = 1 THEN 'ВСЕ РЕГИОНЫ'
         WHEN region IS NULL       THEN 'Регион не указан'
         ELSE region END           AS регион,
    SUM(amount) AS revenue
FROM sales
GROUP BY ROLLUP (region)
ORDER BY GROUPING(region), revenue DESC;
