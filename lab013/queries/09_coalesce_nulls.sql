-- Задача 9. COALESCE: подставить осмысленное значение вместо NULL.
SET search_path TO lab013;

-- discount_rub бывает NULL — это «скидки не было», а не «скидка = 0». Но для
-- арифметики нам нужен ноль: без COALESCE выражение revenue_rub - discount_rub
-- на NULL-строках само стало бы NULL (любая операция с NULL → NULL) и «съело» бы
-- сумму. COALESCE(discount_rub, 0) заменяет NULL на 0. Второй пример COALESCE —
-- многоуровневый: показать «примечание», беря первый непустой источник.
SELECT
    id,
    customer,
    revenue_rub,
    discount_rub,
    coalesce(discount_rub, 0)                    AS discount_effective, -- NULL → 0
    revenue_rub - coalesce(discount_rub, 0)      AS net_revenue,        -- корректная разность
    coalesce(discount_rub::text, 'без скидки')   AS discount_label      -- NULL → текстовая метка
FROM orders
ORDER BY id;
