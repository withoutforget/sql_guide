-- Задача 8. Разузлование Велосипеда: все компоненты по уровням с количеством по пути.
SET search_path TO lab007;

-- «Разузлование состава изделия» (BOM explosion): спускаемся от изделия к его узлам,
-- от узлов — к деталям, на любую глубину. bom — это граф «сборка → компонент»
-- (без циклов, DAG), обход тот же, что у дерева.
--   ЯКОРЬ     — прямые компоненты Велосипеда (assembly_id = 1), уровень 1,
--               qty_total = qty (столько на 1 велосипед);
--   РЕКУРСИЯ  — заходим внутрь каждого компонента, который сам является сборкой
--               (b.assembly_id = e.component_id), и УМНОЖАЕМ количество по пути:
--               e.qty_total * b.qty. Именно умножение даёт «сколько этой детали на
--               одно изделие с учётом вложенности»: 2 колеса × 36 спиц = 72 спицы.
-- Здесь показываем КАЖДОЕ вхождение отдельно (Болт появляется трижды — через Раму,
-- Руль и Колесо, с разными количествами). Суммирование по детали — в задаче 9.
-- Ответ (уровень 2): Спица 72, Болт 4/2/2 (три вхождения), Обод/Покрышка/Камера 2.
WITH RECURSIVE explosion AS (
    -- якорь: прямые компоненты изделия
    SELECT b.component_id,
           b.qty AS qty_total,
           1 AS level
    FROM bom b
    WHERE b.assembly_id = 1
    UNION ALL
    -- рекурсия: спускаемся в под-сборки, умножая количество по уровням
    SELECT b.component_id,
           e.qty_total * b.qty,
           e.level + 1
    FROM explosion e
    JOIN bom b ON b.assembly_id = e.component_id
)
SELECT e.level,
       p.name AS component,
       e.qty_total
FROM explosion e
JOIN parts p ON p.id = e.component_id
ORDER BY e.level, p.name, e.qty_total;
