-- Задача 2. Выручка и число заказов по месяцам (date_trunc), от старых к новым.
SET search_path TO lab014;
SET TIME ZONE 'UTC';   -- детерминизм: date_trunc над timestamptz читаем в UTC

-- date_trunc('month', created_at) обнуляет всё мельче месяца → все заказы одного
-- месяца получают одинаковый ключ (первое число месяца) и попадают в одну группу.
-- Группируем и СОРТИРУЕМ по этому ключу-дате (правильный хронологический порядок),
-- а не по отформатированной строке. Заказы есть в июне, июле и сентябре 2024;
-- август тут просто отсутствует (пустые месяцы «подтянем» в задаче 16).
SELECT
    date_trunc('month', created_at)::date AS месяц,
    count(*)                              AS заказов,
    sum(amount)                           AS выручка
FROM orders
GROUP BY date_trunc('month', created_at)
ORDER BY date_trunc('month', created_at);
