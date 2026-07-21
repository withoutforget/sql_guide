-- Задача 12. 🔥 Для каждой категории — клиент, принёсший ей наибольшую выручку.
SET search_path TO lab005;

-- Изюм: многошаговая аналитика "топ-1 в каждой группе", которую без CTE писать
-- больно. Раскладываем на понятные шаги (цепочка):
--   ШАГ 1 (cat_customer_rev) — выручка в разрезе (категория, клиент);
--   ШАГ 2 (category_max)     — максимальная такая выручка В КАЖДОЙ категории
--                              (свёртка шага 1 — агрегат от агрегата);
--   ФИНАЛ — соединяем шаг 1 с шагом 2 по (категория, эта максимальная сумма):
--           остаётся клиент-рекордсмен категории (приём "(k, MAX) join" из lab004).
-- Никаких новых конструкций — только CTE + JOIN + агрегаты. Оконные функции
-- (которые сделали бы это ещё короче) — позже, в lab010; здесь их НЕ используем.
-- Прим.: при НИЧЬЕЙ на максимуме (два клиента с одинаковой топ-выручкой в
-- категории) join вернёт обоих — две строки на категорию. На данных лабы ничьих
-- нет; чистое разрешение ничьих (ровно один рекордсмен) даст ROW_NUMBER() из lab010.
-- Ответ: Электроника -> Егор, Дом -> Борис, Книги -> Анна, Игрушки -> Егор,
-- Спорт -> Дарья (топ-клиент у категорий разный).
WITH
    cat_customer_rev AS (
        SELECT p.category_id,
               o.customer_id,
               SUM(p.price * o.quantity) AS revenue
        FROM orders   AS o
        JOIN products AS p ON p.id = o.product_id
        GROUP BY p.category_id, o.customer_id
    ),
    category_max AS (
        SELECT category_id,
               MAX(revenue) AS max_revenue
        FROM cat_customer_rev
        GROUP BY category_id
    )
SELECT cat.name  AS category,
       c.name    AS top_customer,
       ccr.revenue
FROM cat_customer_rev AS ccr
JOIN category_max AS cm
     ON cm.category_id = ccr.category_id
    AND ccr.revenue    = cm.max_revenue      -- оставить только рекордсмена категории
JOIN categories AS cat ON cat.id = ccr.category_id
JOIN customers  AS c   ON c.id   = ccr.customer_id
ORDER BY ccr.revenue DESC;
