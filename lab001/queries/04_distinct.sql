-- Задача 4. Список уникальных городов, из которых есть клиенты (по алфавиту).
SET search_path TO lab001;

SELECT DISTINCT city
FROM customers
ORDER BY city;
