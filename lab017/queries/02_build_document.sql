-- Задача 2. Собрать JSON-документ из колонок таблицы (build_object / to_jsonb).
SET search_path TO lab017;

-- jsonb_build_object('k1', v1, 'k2', v2, ...) собирает объект из пар
-- «ключ-значение». Это ТИПОБЕЗОПАСНО: числа остаются числами, вложенный jsonb
-- (attributes) вкладывается как поддокумент — в отличие от ручной склейки строк,
-- где легко получить битый JSON. Значения могут быть любых типов и колонок.
SELECT
    id,
    jsonb_build_object(
        'sku',        'P-' || id,
        'title',      name,
        'price_rub',  price,
        'attrs',      attributes            -- вложенный jsonb становится поддеревом
    ) AS document
FROM products
WHERE category = 'books'
ORDER BY id;

-- to_jsonb(anyelement) превращает ЛЮБОЕ значение в jsonb «как есть». Для строки
-- таблицы (p) получается объект, где ключи — имена колонок. Быстрый способ
-- «сериализовать всю запись».
SELECT to_jsonb(p) AS row_document
FROM products p
WHERE id = 4;
