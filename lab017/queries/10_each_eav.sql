-- Задача 10. Развернуть attributes в пары «ключ-значение» (вид EAV).
SET search_path TO lab017;

-- jsonb_each_text(doc) — set-returning: по строке на каждую пару верхнего уровня,
-- колонки key/value (value уже приведён к TEXT). Это превращает документ с
-- ПРОИЗВОЛЬНЫМ набором ключей в узкую таблицу фактов «entity-attribute-value».
-- Set-returning → в FROM/LATERAL (lab006). Вложенные значения (colors, genres)
-- отдаются как JSON-текст: jsonb_each_text разворачивает только ВЕРХНИЙ уровень.
SELECT
    p.name,
    kv.key   AS attribute,
    kv.value AS value
FROM products p,
     LATERAL jsonb_each_text(p.attributes) AS kv
WHERE p.category = 'electronics'
ORDER BY p.id, kv.key;
