-- Задача 3. Собрать «Фамилия И.О.» из ФИО и NULL-безопасную контактную строку.
SET search_path TO lab015;

-- Сначала чистим имя (как в задаче 2), затем разбираем split_part на части.
-- Инициалы строим только для существующих частей (у части клиентов нет отчества
-- или имени → split_part вернёт '' → CASE отдаёт NULL → concat его пропускает).
WITH cleaned AS (
    SELECT id, phone, email,
           initcap(regexp_replace(btrim(raw_name), '\s+', ' ', 'g')) AS full_name
    FROM clients
),
parts AS (
    SELECT id, phone, email, full_name,
           split_part(full_name, ' ', 1) AS surname,
           split_part(full_name, ' ', 2) AS first_name,
           split_part(full_name, ' ', 3) AS patronymic
    FROM cleaned
)
SELECT
    full_name,
    -- «Фамилия И.О.»: инициалы добавляются только если часть непустая
    btrim(surname || ' ' || concat(
        CASE WHEN first_name  <> '' THEN left(first_name, 1)  || '.' END,
        CASE WHEN patronymic <> '' THEN left(patronymic, 1) || '.' END
    ))                                        AS short_name,
    -- Подводный камень ||: если phone = NULL, вся склейка = NULL
    phone || ' / ' || email                   AS contact_unsafe,
    -- concat_ws NULL-безопасен: пропускает NULL и не оставляет лишний разделитель
    concat_ws(' / ', phone, email)            AS contact_safe
FROM parts
ORDER BY id;
