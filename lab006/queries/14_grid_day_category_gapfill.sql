-- Задача 14. 🔥 Матрица «день × категория» с выручкой за первую пятидневку июня, включая пустые клетки (0).
SET search_path TO lab006;

-- Изюм: полная решётка «дата × категория» БЕЗ единой дыры, собранная только из
-- пройденного. Три приёма вместе:
--   1) generate_series строит сплошной ряд дней (нет пропусков по времени);
--   2) CROSS JOIN с categories достраивает каждую дату КАЖДОЙ категорией
--      (нет пропусков по категориям) — полный каркас 5 дней × 5 категорий = 25 клеток;
--   3) LEFT JOIN к товарам и заказам подтягивает факты в клетку, а
--      COALESCE(SUM(...), 0) ставит 0 там, где продаж не было.
-- Условие «заказ в этот день» стоит в ON последнего LEFT JOIN (o.ordered_at =
-- cal.day) — как в ловушке ON vs WHERE из lab002: перенеси его в WHERE, и пустые
-- клетки исчезнут, каркас развалится. Каждый заказ ложится ровно в одну клетку
-- (свой день и категорию своего товара), поэтому задвоения (fan-out) нет.
-- Итог: видно, что 04 июня пусто во всех категориях, а «Спорт» и «Игрушки» пусты
-- всю пятидневку — и всё это честными нулями, а не отсутствующими строками.
SELECT cal.day::date                             AS day,
       cat.name                                  AS category,
       COALESCE(SUM(p.price * o.quantity), 0)    AS revenue
FROM generate_series(date '2024-06-01', date '2024-06-05', interval '1 day') AS cal(day)
CROSS JOIN categories AS cat
LEFT JOIN products AS p ON p.category_id = cat.id
LEFT JOIN orders   AS o ON o.product_id = p.id
                       AND o.ordered_at = cal.day::date
GROUP BY cal.day, cat.id, cat.name
ORDER BY cal.day, cat.name;
