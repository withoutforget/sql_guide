-- Задача 10. GREATEST / LEAST выбирают из НЕСКОЛЬКИХ выражений и ИГНОРИРУЮТ NULL.
SET search_path TO lab013;

-- GREATEST/LEAST — это НЕ агрегаты: они берут максимум/минимум среди аргументов
-- в ОДНОЙ строке. Их сюрприз — они пропускают NULL (в отличие от обычной
-- арифметики, где NULL заражает всё). Поэтому least(revenue_rub, discount_rub)
-- на строке без скидки (discount_rub IS NULL) возвращает revenue_rub, а не NULL.
-- Практика: «пол» и «потолок» значения — greatest(x, нижняя_граница),
-- least(x, верхняя_граница).
SELECT
    id,
    customer,
    revenue_rub,
    discount_rub,
    least(revenue_rub, discount_rub)                     AS min_ignores_null, -- NULL пропущен
    greatest(revenue_rub, discount_rub)                  AS max_ignores_null,
    greatest(revenue_rub - coalesce(discount_rub, 0), 1000) AS to_pay_floor_1000 -- не ниже 1000 ₽
FROM orders
ORDER BY id;
