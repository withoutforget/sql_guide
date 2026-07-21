-- Задача 5. «Сырой» импорт: числа лежат текстом — приводим их к number.
SET search_path TO lab013;

-- price_text и qty_text — text. Приведение ::numeric / ::int:
--   • пробелы по краям обрезаются автоматически (' 590 '::numeric = 590);
--   • дробь '12.5' приводится к numeric, но ::int упал бы — поэтому цену берём
--     как numeric, а количество (целые строки) как int.
-- Приводим ТОЛЬКО валидные строки: фильтр WHERE is_valid отсекает «мусор»
-- ('бесплатно', '', 'нет') ДО вычисления приведений, поэтому запрос не падает.
SELECT
    id,
    source_name,
    price_text,
    qty_text,
    price_text::numeric                       AS price,       -- text → numeric
    qty_text::int                             AS qty,         -- text → integer
    price_text::numeric * qty_text::int       AS line_total   -- сумма позиции
FROM raw_import
WHERE is_valid
ORDER BY id;
