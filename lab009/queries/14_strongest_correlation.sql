-- Задача 14. 🔥 В какой категории связь цены и спроса самая сильная?
SET search_path TO lab009;

-- Ищем категорию с максимальной ПО МОДУЛЮ корреляцией цены и продаж. Знак говорит
-- о направлении (у нас всюду обратная связь, кроме «Книг»), а сила — это |corr|.
-- Приём: обычный агрегат corr() по категориям + ORDER BY abs(corr(...)) DESC.
-- Никаких оконных функций — «победитель» оказывается первой строкой (LIMIT 1),
-- а полный рейтинг с ярлыком силы даёт контекст. Дополнительно тянем наклон
-- регрессии и R² — сильная |corr| означает и хорошее линейное приближение.
-- Ответ: сильнее всего связь в «Доме» (corr ≈ −0.93, R² ≈ 0.86) — почти прямая.
SELECT
    category                                          AS категория,
    count(*)                                          AS n,
    round(corr(units_sold, price)::numeric, 4)        AS corr,
    round(abs(corr(units_sold, price))::numeric, 4)   AS сила_abs,
    round(regr_slope(units_sold, price)::numeric, 6)  AS наклон,
    round(regr_r2(units_sold, price)::numeric, 4)     AS r2,
    CASE
        WHEN abs(corr(units_sold, price)) >= 0.8 THEN 'очень сильная'
        WHEN abs(corr(units_sold, price)) >= 0.5 THEN 'сильная'
        WHEN abs(corr(units_sold, price)) >= 0.3 THEN 'умеренная'
        ELSE 'слабая / нет'
    END                                               AS сила_связи
FROM products
GROUP BY category
ORDER BY сила_abs DESC NULLS LAST;
