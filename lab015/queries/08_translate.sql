-- Задача 8. Транслитерация фамилии (translate), чистка телефона (translate) и позиция '@' (strpos).
SET search_path TO lab015;

-- translate работает ПОСИМВОЛЬНО:
--   • для логина — заменяем каждую кириллическую букву на латинскую по позиции
--     (мягкий знак 'ь' в наборе есть, а пары в правом наборе нет → он удаляется);
--   • для телефона — перечисляем символы-мусор ('+', '(', ')', '-', пробел) и
--     удаляем их (правый набор пустой). Отличие от regexp_replace(x,'\D','') в том,
--     что translate убирает ТОЛЬКО перечисленные символы, а не «всё кроме цифр».
-- strpos находит позицию подстроки ('@'), 0 — если её нет.
WITH c AS (
    SELECT id, email,
           split_part(initcap(regexp_replace(btrim(raw_name), '\s+', ' ', 'g')), ' ', 1) AS surname,
           phone
    FROM clients
)
SELECT
    surname,
    translate(lower(surname),
              'авдезиклмнопрстуць',   -- 'ь' в конце — без пары → удаляется
              'avdeziklmnoprstuc')  AS login,
    phone,
    translate(phone, '+()- ', '')   AS phone_cleaned,  -- убрать перечисленные символы
    email,
    strpos(email, '@')              AS at_pos          -- позиция '@' (0 — если нет)
FROM c
ORDER BY id;
