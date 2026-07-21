-- Задача 10. Нормализовать телефон из любого формата к единому виду +7XXXXXXXXXX.
SET search_path TO lab015;

-- Шаг 1: regexp_replace(phone, '\D', '', 'g') оставляет только цифры (\D = «не цифра»).
-- Шаг 2: берём последние 10 значащих цифр (right(..., 10)) — так одинаково
--        обрабатываются номера, начинающиеся на +7…, 8… или 7…, — и дописываем '+7'.
-- У клиента без телефона (NULL) весь результат корректно остаётся NULL.
SELECT
    id,
    phone,
    regexp_replace(phone, '\D', '', 'g')                         AS digits,
    '+7' || right(regexp_replace(phone, '\D', '', 'g'), 10)      AS normalized
FROM clients
ORDER BY id;
