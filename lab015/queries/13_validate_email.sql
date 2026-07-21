-- Задача 13. Пометить каждый e-mail как валидный или невалидный простым regex-валидатором.
SET search_path TO lab015;

-- Шаблон: непустой локальный кусок, '@', домен, точка, зона из ≥2 букв — и всё это
-- ВСЯ строка (^…$). «Идеально» валидировать e-mail регуляркой нельзя, но отсеять
-- явный мусор ('bad-email@', 'no-at-sign.ru', '@nouser.ru', 'morozov@site') — легко.
-- COALESCE(... , false) страхует от NULL-адресов, чтобы вердикт всегда был определён.
SELECT
    email,
    is_valid,
    CASE WHEN is_valid THEN 'валидный' ELSE 'НЕвалидный' END AS verdict
FROM (
    SELECT id, email,
           COALESCE(email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$', false) AS is_valid
    FROM clients
) t
ORDER BY is_valid DESC, id;
