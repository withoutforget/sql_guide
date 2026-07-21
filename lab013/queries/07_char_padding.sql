-- Задача 7. char(n) дополняется пробелами — и это коварно при сравнении.
SET search_path TO lab013;

-- char(n) (он же character) ХРАНИТ ровно n символов, добивая справа пробелами.
-- length() и приведение к text эти хвостовые пробелы «прячут» (обрезают), а вот
-- octet_length() показывает реальную набивку. Главный подвох — сравнение:
-- у типа char хвостовые пробелы НЕ значимы, поэтому 'EL-1001' и 'EL-1001   '
-- как char РАВНЫ, а как text — РАЗНЫЕ. Отсюда баги, когда одна колонка char,
-- а другая text/varchar.
SELECT
    sku,
    octet_length(sku)                                   AS bytes_varchar,        -- 7 (без набивки)
    octet_length(sku::char(10))                         AS bytes_char10,         -- 10 (набито пробелами!)
    length(sku::char(10))                               AS len_char10,           -- 7 (length прячет хвост)
    (sku::char(10) = (sku || '   ')::char(10))          AS char_ignores_spaces,  -- true
    (sku = sku || '   ')                                AS text_keeps_spaces     -- false
FROM products
ORDER BY id;
