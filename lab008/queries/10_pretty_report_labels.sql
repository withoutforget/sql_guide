-- Задача 10. Красивый отчёт по иерархии с подписями «итого по категории» и «ИТОГО».
SET search_path TO lab008;

-- Оформляем ROLLUP-отчёт для человека: вместо NULL — понятные подписи через
-- CASE + GROUPING() (теория 05). Строка общего итога (GROUPING(category)=1) →
-- «ИТОГО»; строки подытога категории (GROUPING(subcategory)=1 при
-- GROUPING(category)=0) → «· итого по категории» с отступом; в строке общего
-- итога подкатегорию оставляем пустой, чтобы подпись не задвоилась.
-- Сортируем по ИСХОДНЫМ колонкам и GROUPING(), а НЕ по подписям-CASE (иначе
-- 'ИТОГО' встал бы по алфавиту и структура развалилась).
SELECT
    CASE WHEN GROUPING(category) = 1 THEN 'ИТОГО'
         ELSE category END          AS категория,
    CASE WHEN GROUPING(subcategory) = 1 AND GROUPING(category) = 0
              THEN '  · итого по категории'
         WHEN GROUPING(subcategory) = 1 THEN ''
         ELSE subcategory END       AS подкатегория,
    SUM(amount) AS revenue
FROM sales
GROUP BY ROLLUP (category, subcategory)
ORDER BY category NULLS LAST, GROUPING(subcategory), subcategory;
