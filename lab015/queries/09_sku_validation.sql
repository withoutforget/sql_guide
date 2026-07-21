-- Задача 9. Проверить формат артикула регуляркой: две заглавные буквы, дефис, четыре цифры.
SET search_path TO lab015;

-- Шаблон '^[A-Z]{2}-[0-9]{4}$' с якорями ^…$ требует, чтобы ВСЯ строка была
-- ровно такой. Поэтому 'ab-99' (строчные, 2 цифры) и 'Z-12' (одна буква) — битые.
SELECT
    sku,
    name,
    sku ~ '^[A-Z]{2}-[0-9]{4}$'                                  AS valid_format,
    CASE WHEN sku ~ '^[A-Z]{2}-[0-9]{4}$' THEN 'ок' ELSE 'битый' END AS status
FROM products
ORDER BY valid_format DESC, sku;
