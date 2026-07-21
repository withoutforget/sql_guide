-- Задача 13. Массив объектов → таблица с типизированными колонками (to_recordset).
SET search_path TO lab017;

-- jsonb_to_recordset(arr) разворачивает JSON-массив ОБЪЕКТОВ в набор строк, но,
-- в отличие от jsonb_array_elements, сразу раскладывает поля по ТИПИЗИРОВАННЫМ
-- колонкам — их надо объявить в AS (...). Дальше это обычная таблица: числа уже
-- числа, можно считать qty * price без ручных приведений через ->>.
-- Set-returning → в FROM/LATERAL (lab006).
SELECT
    o.id,
    o.customer,
    x.product,
    x.qty,
    x.price,
    x.qty * x.price AS subtotal
FROM orders o,
     LATERAL jsonb_to_recordset(o.items) AS x(product text, qty int, price numeric)
ORDER BY o.id, subtotal DESC, x.product;
