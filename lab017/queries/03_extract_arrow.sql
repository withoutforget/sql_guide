-- Задача 3. Извлечь атрибуты через -> и ->>, привести текст к числу для сравнения.
SET search_path TO lab017;

-- -> отдаёт JSON (jsonb), ->> отдаёт TEXT. Цепочкой спускаемся вглубь:
-- attributes -> 'colors' -> 0  — первый элемент массива как JSON,
-- attributes -> 'colors' ->> 0 — он же текстом. Отсутствующий ключ → SQL NULL.
SELECT
    name,
    attributes ->> 'brand'        AS brand,        -- текст
    attributes -> 'colors'        AS colors_json,  -- весь массив (jsonb) или NULL
    attributes -> 'colors' ->> 0  AS first_color   -- первый цвет текстом
FROM products
WHERE category = 'electronics'
ORDER BY id;

-- Чтобы фильтровать/считать по числу ВНУТРИ JSON, ->> приводим к числу.
-- Здесь: товары с ОЗУ больше 8 ГБ. Сравнивать надо ЧИСЛА, а не текст:
-- как текст '16' < '8' (посимвольно "1" < "8") — сравнение было бы неверным.
-- У товаров без ключа ram (attributes ->> 'ram') = NULL → в фильтр не попадают.
SELECT
    name,
    (attributes ->> 'ram')::int AS ram_gb,
    price
FROM products
WHERE (attributes ->> 'ram')::int > 8
ORDER BY ram_gb DESC, id;
