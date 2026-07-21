-- Задача 10. Категории выше средней выручки, с долей в общей выручке (явный MATERIALIZED).
SET search_path TO lab005;

-- category_revenue здесь нужен ТРИЖДЫ: как строки (FROM), для общей суммы
-- (SELECT SUM ...) и для среднего (SELECT AVG ...). Пишем AS MATERIALIZED, чтобы
-- ЯВНО сказать: "сверни заказы по категориям ОДИН раз в промежуточный результат,
-- дальше работай с готовой табличкой". Слово ставится между AS и скобкой.
-- MATERIALIZED — оптимизационная подсказка (барьер), на РЕЗУЛЬТАТ не влияет:
-- строки те же, что были бы и без него. По умолчанию PostgreSQL 12+ и так
-- материализует CTE, использованный больше одного раза, — здесь мы фиксируем это
-- намерение в коде. Выше среднего (27464 ₽): Электроника (60.75%) и Дом (25.45%).
WITH category_revenue AS MATERIALIZED (
    SELECT p.category_id,
           SUM(p.price * o.quantity) AS revenue
    FROM orders   AS o
    JOIN products AS p ON p.id = o.product_id
    GROUP BY p.category_id
)
SELECT cat.name,
       cr.revenue,
       ROUND(cr.revenue * 100.0 / (SELECT SUM(revenue) FROM category_revenue), 2) AS pct_of_total
FROM category_revenue AS cr
JOIN categories AS cat ON cat.id = cr.category_id
WHERE cr.revenue > (SELECT AVG(revenue) FROM category_revenue)
ORDER BY cr.revenue DESC;
