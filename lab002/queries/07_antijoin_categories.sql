-- Задача 7. Категории, в которых нет ни одного товара (анти-соединение по справочнику).
SET search_path TO lab002;

SELECT
    cat.id,
    cat.name
FROM categories AS cat
LEFT JOIN products AS p  ON p.category_id = cat.id
WHERE p.id IS NULL
ORDER BY cat.id;
