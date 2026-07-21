-- Задача 6. varchar(n): приведение ::varchar(n) молча УСЕКАЕТ (в отличие от вставки).
SET search_path TO lab013;

-- Ключевой нюанс: приведение (cast) к varchar(n) обрезает строку до n символов
-- БЕЗ ошибки, тогда как попытка ВСТАВИТЬ слишком длинную строку в колонку
-- varchar(n) даёт ошибку «value too long». Здесь показываем именно cast-усечение:
-- sku из 7 символов ужимаем до varchar(5), длинные названия — до varchar(12).
SELECT
    sku,
    sku::varchar(5)                 AS sku_5,        -- 'EL-1001' → 'EL-10'
    name,
    name::varchar(12)               AS name_12,      -- усечение до 12 символов
    length(name)                    AS name_len,     -- исходная длина
    length(name::varchar(12))       AS name_12_len   -- <= 12
FROM products
ORDER BY id;
