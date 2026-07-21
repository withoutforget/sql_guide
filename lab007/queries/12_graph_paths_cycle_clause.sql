-- Задача 12. Те же маршруты в Екатеринбург, но защита от циклов — штатным CYCLE (PG14+).
SET search_path TO lab007;

-- То же, что задача 11, но защиту «не заходить в уже посещённый узел» пишет за нас
-- СТАНДАРТНОЕ предложение CYCLE (стандарт SQL, в PostgreSQL с версии 14). Синтаксис:
--     ... ) CYCLE to_city SET is_cycle USING cyc_path
--   * to_city   — по какой колонке (колонкам) определять повтор узла;
--   * is_cycle  — новая булева колонка-флаг: TRUE, если этот узел УЖЕ встречался на
--                 пути (то есть шаг замкнул цикл); такую строку CYCLE выдаёт, но
--                 дальше НЕ разворачивает — этим и достигается конечность;
--   * cyc_path  — новая колонка, куда CYCLE сам складывает пройденный путь (массив).
-- Нам остаётся отфильтровать «замыкающие» строки условием NOT is_cycle. Это ровно
-- замена ручного WHERE NOT ... = ANY(path) из задачи 11 — короче и без риска забыть
-- защиту. Свой массив route мы ведём здесь только чтобы КРАСИВО НАПЕЧАТАТЬ маршрут
-- (внутренний cyc_path хранит путь как массив кортежей — для вывода неудобен).
-- Родственное предложение SEARCH BREADTH/DEPTH FIRST BY ... SET ... задаёт порядок
-- обхода (в ширину/в глубину) — см. теорию 04.
-- Ответ: те же два маршрута, что в задаче 11 (2530 и 2550 км).
WITH RECURSIVE paths AS (
    SELECT from_city,
           to_city,
           ARRAY[from_city, to_city] AS route,     -- свой путь — только для печати
           distance AS total_dist
    FROM routes
    WHERE from_city = 'Москва'
    UNION ALL
    SELECT p.from_city,
           r.to_city,
           p.route || r.to_city,
           p.total_dist + r.distance
    FROM paths p
    JOIN routes r ON r.from_city = p.to_city
    -- ручного условия против цикла НЕТ — его заменяет CYCLE ниже
) CYCLE to_city SET is_cycle USING cyc_path
SELECT array_to_string(route, ' → ') AS route,
       total_dist AS distance_km
FROM paths
WHERE to_city = 'Екатеринбург'
  AND NOT is_cycle                                 -- отбрасываем «замыкающие» строки
ORDER BY total_dist, route;
