-- Задача 1. Сводная таблица: выручка по категориям (строки) × месяцам (столбцы).
SET search_path TO lab012;

-- PIVOT (long → wide): группируем по СТРОКЕ-измерению (категория), а каждый
-- СТОЛБЕЦ получаем условной агрегацией — своим агрегатом с FILTER (WHERE period=k).
-- Тонкость: если в паре (категория, месяц) заказов НЕТ, SUM по пустому множеству
-- вернёт NULL, а не 0 → оборачиваем в COALESCE(..., 0), чтобы «пусто» = 0 ₽.
-- Число и набор столбцов ФИКСИРОВАНЫ в тексте запроса (в чистом SQL иначе нельзя).
SELECT
    category                                            AS категория,
    COALESCE(SUM(amount) FILTER (WHERE period = 1), 0)  AS янв,
    COALESCE(SUM(amount) FILTER (WHERE period = 2), 0)  AS фев,
    COALESCE(SUM(amount) FILTER (WHERE period = 3), 0)  AS мар,
    COALESCE(SUM(amount) FILTER (WHERE period = 4), 0)  AS апр,
    COALESCE(SUM(amount) FILTER (WHERE period = 5), 0)  AS май,
    COALESCE(SUM(amount) FILTER (WHERE period = 6), 0)  AS июн,
    SUM(amount)                                         AS итого
FROM orders
GROUP BY category
ORDER BY итого DESC;
