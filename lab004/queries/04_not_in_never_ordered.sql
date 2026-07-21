-- Задача 4. Товары, которые ни разу не заказывали (анти-соединение через NOT IN).
SET search_path TO lab004;

-- NOT IN оставляет id, которых НЕТ среди заказанных product_id. Здесь это
-- безопасно: orders.product_id объявлен NOT NULL, поэтому подзапрос гарантированно
-- не вернёт NULL и ловушка "NOT IN + NULL" не сработает (её показывает задача 5).
-- Тот же вопрос решался анти-джойном в lab002 и через EXCEPT в lab003 — сравните.
SELECT id, name
FROM products
WHERE id NOT IN (SELECT product_id FROM orders)
ORDER BY id;
