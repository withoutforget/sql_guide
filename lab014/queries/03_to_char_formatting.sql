-- Задача 3. Красиво отформатировать момент заказа несколькими шаблонами to_char.
SET search_path TO lab014;
SET TIME ZONE 'UTC';   -- детерминизм: форматируем момент в UTC

-- to_char(значение, шаблон) → text. Показываем разные шаблоны на одном столбце:
--   'DD.MM.YYYY'          — русская дата
--   'YYYY-MM-DD HH24:MI'  — ISO дата-время до минут
--   'YYYY-MM'             — КЛЮЧ месяца (удобно как строковый идентификатор периода)
--   'FMDD.FMMM.YYYY'      — FM убирает ведущие нули (5.3.2024 вместо 05.03.2024)
--   'Q "кв." YYYY'        — квартал + свой текст в двойных кавычках
-- Названия месяцев/дней (Month/Day) НЕ используем — они зависят от локали lc_time
-- и «поплыли» бы на другой машине (см. theory/05). Числовые шаблоны детерминированы.
SELECT
    id,
    to_char(created_at, 'DD.MM.YYYY')          AS дата,
    to_char(created_at, 'YYYY-MM-DD HH24:MI')  AS дата_время,
    to_char(created_at, 'YYYY-MM')             AS ключ_месяца,
    to_char(created_at, 'FMDD.FMMM.YYYY')      AS без_нулей,
    to_char(created_at, 'Q "кв." YYYY')        AS квартал
FROM orders
ORDER BY created_at;
