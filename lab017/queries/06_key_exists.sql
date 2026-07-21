-- Задача 6. Проверить НАЛИЧИЕ ключей операторами ? / ?| / ?& (только jsonb).
SET search_path TO lab017;

-- ?  'k'          — есть ли ключ k (у объектов) / строковый элемент (у массивов);
-- ?| array[...]   — есть ли ХОТЯ БЫ ОДИН из перечисленных ключей;
-- ?& array[...]   — есть ли ВСЕ перечисленные ключи.
-- Важно: ? проверяет НАЛИЧИЕ КЛЮЧА, а не значения. У «Мыши» ключ warranty есть
-- (хоть значение и JSON null) → attributes ? 'warranty' = true.
SELECT
    name,
    attributes ? 'screen'                    AS has_screen,      -- есть характеристика экрана?
    attributes ?| array['ram','ssd']         AS has_ram_or_ssd,  -- любой из
    attributes ?& array['brand','screen']    AS has_brand_scr    -- оба сразу
FROM products
ORDER BY id;

-- Практика: отобрать только товары, у которых ЗАДАН экран (например, для
-- витрины «Экраны/Мониторы»).
SELECT name, (attributes ->> 'screen')::numeric AS screen_inch
FROM products
WHERE attributes ? 'screen'
ORDER BY screen_inch DESC, id;
