-- Задача 4. Достать вложенное значение по ПУТИ операторами #> и #>>.
SET search_path TO lab017;

-- #> и #>> идут по ПУТИ, заданному массивом текста '{a,b,c}': это короткая
-- запись цепочки ->. #> возвращает JSON, #>> — TEXT.
--   prefs #> '{address}'          — поддокумент address (jsonb),
--   prefs #>> '{address,city}'    — город текстом.
-- Если по пути ключа нет (у Глеба нет address) → SQL NULL (запрос не падает).
SELECT
    name,
    prefs #>  '{address}'               AS address_json,
    prefs #>> '{address,city}'          AS city,
    prefs #>> '{notifications,email}'   AS email_enabled  -- вложенный флаг текстом
FROM users
ORDER BY id;
