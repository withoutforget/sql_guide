-- Задача 12. Доля дневной выручки от лучшего дня товара (max по партиции).
SET search_path TO lab011;

-- max(revenue) OVER (PARTITION BY товар) — выручка ЛУЧШЕГО дня товара, приписанная
-- каждой строке. Окно БЕЗ ORDER BY = вся партиция целиком (рамка не «до текущей строки»,
-- а весь раздел), поэтому максимум берётся по всему ряду. Делим день на пик — получаем,
-- на сколько процентов день дотянул до рекорда товара. У лучшего дня — 100%.
SELECT
    p.name                                                      AS товар,
    s.sale_date                                                 AS дата,
    s.revenue                                                   AS выручка,
    max(s.revenue) OVER (PARTITION BY s.product_id)             AS лучший_день,
    round(100.0 * s.revenue
          / max(s.revenue) OVER (PARTITION BY s.product_id), 1) AS доля_от_пика_проц
FROM sales AS s
JOIN products AS p ON p.id = s.product_id
ORDER BY p.name, s.sale_date;
