-- Задача 11. Извлечь домен из e-mail тремя способами и увидеть разницу на битых адресах.
SET search_path TO lab015;

-- Три инструмента дают домен:
--   split_part(email,'@',2)      — берёт 2-ю часть; если '@' нет или после него
--                                  пусто, вернёт ПУСТУЮ строку '' (не NULL);
--   substring(email FROM '@(.+)$')— regex-группа; если совпадения нет → NULL;
--   (regexp_match(email,'@(.+)$'))[1] — то же через массив групп.
-- На битых адресах ('bad-email@', 'no-at-sign.ru') видно расхождение: split_part
-- отдаёт '', а regex-варианты — NULL. Запрос не падает ни на одном.
SELECT
    email,
    split_part(email, '@', 2)          AS via_split_part,
    substring(email FROM '@(.+)$')     AS via_substring,
    (regexp_match(email, '@(.+)$'))[1] AS via_regexp_match
FROM clients
ORDER BY id;
