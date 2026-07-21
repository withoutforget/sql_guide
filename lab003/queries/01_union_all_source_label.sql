-- Задача 1. Слить оба списка контактов в один поток, пометив источник ('online'/'offline').
SET search_path TO lab003;

-- UNION ALL складывает строки двух запросов «друг под друга», НИЧЕГО не удаляя.
-- Литеральная колонка source отмечает, из какого списка пришла строка (частый
-- приём: добавить в каждый SELECT свою константу-метку). Схемы совпадают: обе
-- ветки дают (email, source) в одном порядке. Итог — все 10 строк (5 + 5).
SELECT email, 'online'  AS source FROM online_customers
UNION ALL
SELECT email, 'offline' AS source FROM offline_customers
ORDER BY email, source;
