-- Задача 5. Клиенты, которые никого не приглашали: ловушка NOT IN + NULL и её обход.
SET search_path TO lab004;

-- В файле ТРИ запроса. Вопрос один: чьих id нет среди referrer_id (кто никого не
-- пригласил). Правильный ответ — пятеро: Глеб, Дарья, Егор, Жанна, Захар.

-- 1) ❌ СЛОМАНО. Подзапрос SELECT referrer_id возвращает в том числе NULL (у тех,
--    кто пришёл сам). Одного NULL достаточно, чтобы весь NOT IN перестал находить
--    строки: x NOT IN (..., NULL) = (... AND x <> NULL), а x <> NULL = UNKNOWN, и
--    вся конъюнкция никогда не станет TRUE. Результат — ПУСТО (0 строк).
SELECT id, name
FROM customers
WHERE id NOT IN (SELECT referrer_id FROM customers)
ORDER BY id;

-- 2) ✅ Обход №1 — убрать NULL прямо в подзапросе:
SELECT id, name
FROM customers
WHERE id NOT IN (SELECT referrer_id FROM customers WHERE referrer_id IS NOT NULL)
ORDER BY id;

-- 3) ✅ Обход №2 (рекомендуемый) — NOT EXISTS: он проверяет НАЛИЧИЕ строк, а не
--    сравнивает значения, поэтому NULL-безопасен (подробно — теория 03).
SELECT c.id, c.name
FROM customers AS c
WHERE NOT EXISTS (
    SELECT 1 FROM customers AS r WHERE r.referrer_id = c.id
)
ORDER BY c.id;
