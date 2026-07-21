-- Задача 6. offline EXCEPT online: обычный и ALL — увидеть, как ALL сохраняет кратность.
SET search_path TO lab003;

-- Два запроса подряд — сравните число строк. Берём «есть в офлайне, но нет в
-- онлайне». В офлайн-списке Егор внесён ДВАЖДЫ, а в онлайне его нет вовсе.
--   * EXCEPT      — как обычно, убирает дубликаты  → Егор один раз, Жанна → (2 rows);
--   * EXCEPT ALL  — учитывает кратности: из «2 Егора в офлайне» вычитает «0 в
--                   онлайне» и оставляет 2 Егора    → (3 rows).
-- Правило кратности EXCEPT ALL: в результат строка попадает (число копий слева −
-- число копий справа) раз, но не меньше нуля.

-- 1) обычный EXCEPT (дедуп):
SELECT email, name FROM offline_customers
EXCEPT
SELECT email, name FROM online_customers;

-- 2) EXCEPT ALL (с сохранением кратности):
SELECT email, name FROM offline_customers
EXCEPT ALL
SELECT email, name FROM online_customers;
