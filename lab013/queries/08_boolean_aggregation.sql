-- Задача 8. Булев тип в агрегатах: FILTER, sum(flag::int), bool_and / bool_or.
SET search_path TO lab013;

-- Три способа посчитать «сколько товаров в наличии» и два флага по группе.
-- count(*) FILTER (WHERE flag) и sum(flag::int) дают ОДНО И ТО ЖЕ число —
-- потому что true::int = 1, false::int = 0. bool_and/bool_or (из lab009) отвечают
-- на вопросы «все?» и «хоть один?»:
--   bool_and(in_stock) — все ли товары категории в наличии;
--   bool_or(in_stock)  — есть ли хоть один в наличии.
SELECT
    category,
    count(*)                              AS total,
    count(*) FILTER (WHERE in_stock)      AS in_stock_filter,   -- через FILTER
    sum(in_stock::int)                    AS in_stock_sum,      -- через bool→int
    bool_and(in_stock)                    AS all_in_stock,      -- все в наличии?
    bool_or(in_stock)                     AS any_in_stock       -- хоть один?
FROM products
GROUP BY category
ORDER BY category;
