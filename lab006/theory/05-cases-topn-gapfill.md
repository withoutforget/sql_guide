# 05 — Фирменные кейсы: top-N на группу и календарь с gap-filling

[← LATERAL](04-lateral.md) · [оглавление](../README.md) · [дальше: подводные камни и выбор инструмента →](06-pitfalls-choosing.md)

---

Два приёма, ради которых чаще всего и достают инструменты этой лабы. Первый —
**top-N строк в каждой группе** — почти всё держится на `LATERAL`. Второй —
**gap-filling** («заполнение пропусков») — на `generate_series` в связке с
`LEFT JOIN`. Оба разберём медленно и с результатами.

## Кейс 1: top-N строк на группу (`LEFT JOIN LATERAL ... LIMIT N`)

Задача-архетип: «для каждого клиента — **три** его самых дорогих заказа», «для
каждой категории — **два** самых дорогих товара», «по каждому автору — **пять**
последних статей». Общая форма: **в каждой группе взять несколько верхних строк по
некоторому порядку.**

Почему это трудно «обычными» средствами:

- `GROUP BY` сворачивает группу в **одну** строку (агрегат) — а нам нужно
  **несколько строк** группы целиком.
- Коррелированный скалярный подзапрос (lab004) вернёт **одно** значение — годится
  для «топ-1 по одному полю», но не для «топ-3 строк со всеми колонками».
- `MAX`/`MIN` дают только самую-самую строку, и то по одному полю.

`LATERAL` решает это прямо: слева — группы (клиенты), справа — маленький запрос,
который для **текущей** группы сортирует её строки и берёт `LIMIT N`.

```sql
-- три самых дорогих заказа каждого клиента (задача 9)
SELECT c.name AS customer, top.product, top.revenue
FROM customers AS c
LEFT JOIN LATERAL (
    SELECT pr.name AS product, pr.price * o.quantity AS revenue
    FROM orders AS o
    JOIN products AS pr ON pr.id = o.product_id
    WHERE o.customer_id = c.id       -- корреляция: заказы ИМЕННО этого клиента
    ORDER BY revenue DESC            -- порядок «топовости» внутри группы
    LIMIT 3                          -- сколько верхних строк оставить
) AS top ON true
ORDER BY c.name, top.revenue DESC NULLS LAST;
```
```
 customer |       product        | revenue
----------+----------------------+----------
 Анна     | Смартфон Nova 5      | 24990.00
 Анна     | Наушники TWS Pro     |  5990.00
 Анна     | Книга "Алгоритмы"    |  2490.00     ← у Анны 5 заказов, показаны 3 верхних
 Борис    | Смартфон Nova 5      | 24990.00
 Борис    | Книга "SQL за месяц" |   890.00     ← у Бориса заказов 2 — показаны оба
 ...
 Жанна    |                      |              ← заказов нет: LEFT JOIN LATERAL сохранил её
(16 rows)
```

Разбор трёх «ручек», которыми настраивают приём:

- **`WHERE ... = c.id`** — корреляция: связывает правый набор с текущей группой.
  Без неё top-N считался бы по всей таблице, а не по группе.
- **`ORDER BY`** — определяет, что значит «верхние» (по цене, по дате, по
  рейтингу). Меняете сортировку — меняется смысл «топа».
- **`LIMIT N`** — сколько строк на группу. `LIMIT 1` — «топ-1» (задачи 7–8),
  `LIMIT 3` — «топ-3» (задача 9). Групп с меньшим числом строк это не ломает:
  вернётся столько, сколько есть.

**`CROSS` или `LEFT`?** Если у группы может **не быть** строк (клиент без заказов —
Жанна) и её нельзя терять — `LEFT JOIN LATERAL ... ON true`. Если пустых групп не
бывает или они не нужны — `CROSS JOIN LATERAL` (так сделано для топ-2 товаров на
категорию в задаче 10: пустых категорий нет).

> **Ничьи.** `ORDER BY revenue DESC LIMIT 3` при равных значениях на границе (два
> заказа с одинаковой суммой на 3-м месте) выберет из них произвольные, чтобы
> добрать ровно 3. Детерминированно разрешить ничью помогает **дополнительный
> ключ сортировки** (`ORDER BY revenue DESC, o.id`). А «плотные» варианты рангов
> с честной обработкой ничьих (`RANK`, `DENSE_RANK`) появятся в оконных функциях
> (lab010) — там же top-N часто пишут короче. Но `LATERAL`-форма ценна тем, что
> понятна «по шагам» и работает уже сейчас.

### top-N + агрегация (хардкор, задача 13)

Сильная сторона `LATERAL`-варианта: его результат — обычные строки, к которым
дальше применимо **всё**. Взяв top-3 на клиента, можно тут же их **просуммировать**
и сравнить с полной выручкой клиента — «какую долю дают три крупнейших заказа»:

```sql
WITH
    customer_total AS (      -- полная выручка клиента
        SELECT o.customer_id, SUM(p.price * o.quantity) AS total_revenue
        FROM orders AS o JOIN products AS p ON p.id = o.product_id
        GROUP BY o.customer_id
    ),
    top3 AS (                -- сумма трёх крупнейших заказов клиента
        SELECT c.id AS customer_id, SUM(t.revenue) AS top3_revenue
        FROM customers AS c
        JOIN LATERAL (
            SELECT p.price * o.quantity AS revenue
            FROM orders AS o JOIN products AS p ON p.id = o.product_id
            WHERE o.customer_id = c.id
            ORDER BY revenue DESC
            LIMIT 3
        ) AS t ON true
        GROUP BY c.id
    )
SELECT c.name,
       ROUND(100.0 * t3.top3_revenue / ct.total_revenue, 1) AS top3_share_pct
FROM top3 AS t3
JOIN customer_total AS ct ON ct.customer_id = t3.customer_id
JOIN customers      AS c  ON c.id = t3.customer_id
ORDER BY top3_share_pct;
```

У кого заказов не больше трёх — доля `100%` (топ-3 = все заказы); у Анны, Дарьи,
Егора — меньше. Это связка **LATERAL + CTE (lab005) + агрегаты (lab001)**: сначала
top-N на группу, затем свёртка — то, ради чего приёмы и собираются вместе.

## Кейс 2: gap-filling — календарь без дыр (`generate_series` + `LEFT JOIN`)

Проблема: отчёт «выручка по дням» на «сырой» группировке показывает **только те
дни, где были заказы**. Дни без продаж просто отсутствуют — и график/таблица врут,
будто этих дней не существовало.

Лечение в три шага:

1. **`generate_series`** строит **сплошной ряд** нужных периодов (все дни/месяцы) —
   каркас без пропусков ([файл 01](01-srf-generate-series.md)).
2. **`LEFT JOIN`** приклеивает к каркасу фактические заказы. Ключевой момент:
   каркас — **слева**, поэтому периоды без заказов **сохраняются** (как «сироты»
   из lab002).
3. **`COUNT(o.id)` / `COALESCE(SUM(...), 0)`** дают на пустых периодах честные
   нули (агрегаты игнорируют `NULL`, а `COALESCE` заменяет пустую сумму на `0` —
   всё это из lab001–lab002).

```sql
-- заказы и выручка по каждому дню первой декады июня, включая пустые дни (задача 11)
SELECT cal.day::date AS day,
       COUNT(o.id)                            AS orders_count,
       COALESCE(SUM(p.price * o.quantity), 0) AS revenue
FROM generate_series(date '2024-06-01', date '2024-06-10', interval '1 day') AS cal(day)
LEFT JOIN orders   AS o ON o.ordered_at = cal.day::date
LEFT JOIN products AS p ON p.id = o.product_id
GROUP BY cal.day
ORDER BY cal.day;
```
```
    day     | orders_count | revenue
------------+--------------+----------
 2024-06-01 |            2 | 30980.00
 2024-06-02 |            2 | 86970.00
 2024-06-03 |            3 | 12770.00
 2024-06-04 |            0 |        0     ← пустой день сохранён нулём
 2024-06-05 |            3 | 18260.00
 2024-06-06 |            0 |        0
 2024-06-07 |            0 |        0
 2024-06-08 |            2 |  9680.00
 2024-06-09 |            0 |        0
 2024-06-10 |            2 |  5760.00
(10 rows)
```

Без каркаса в результате было бы **6 строк** (только дни с заказами); с ним — все
**10**, и провалы видны как нули. Ровно то, что нужно для честного временного ряда.

### По месяцам — тот же приём, другой шаг

Поменяв шаг на `interval '1 month'` и условие на диапазон `[начало, начало+1
месяц)`, получаем помесячный отчёт. Заказы у нас только в июне и июле, поэтому
август и сентябрь дают нули (задача 12):

```sql
SELECT to_char(m.month, 'YYYY-MM') AS month,
       COALESCE(SUM(p.price * o.quantity), 0) AS revenue
FROM generate_series(date '2024-06-01', date '2024-09-01', interval '1 month') AS m(month)
LEFT JOIN orders   AS o ON o.ordered_at >= m.month
                       AND o.ordered_at <  m.month + interval '1 month'
LEFT JOIN products AS p ON p.id = o.product_id
GROUP BY m.month
ORDER BY m.month;
-- 2024-06 → 164420; 2024-07 → 33950; 2024-08 → 0; 2024-09 → 0
```

Условие про попадание в месяц стоит **в `ON`** (диапазон), а не в `WHERE` — иначе
сработала бы ловушка `ON` vs `WHERE` из lab002 и месяцы без заказов пропали бы.

### Двумерный каркас: день × категория (хардкор, задача 14)

Каркас можно строить **по двум измерениям сразу**: сплошной ряд дней `CROSS JOIN`
со справочником категорий даёт полную решётку «дата × категория» без единой дыры, а
`LEFT JOIN` подтягивает в клетки факты:

```sql
SELECT cal.day::date AS day, cat.name AS category,
       COALESCE(SUM(p.price * o.quantity), 0) AS revenue
FROM generate_series(date '2024-06-01', date '2024-06-05', interval '1 day') AS cal(day)
CROSS JOIN categories AS cat                         -- каркас: 5 дней × 5 категорий = 25 клеток
LEFT JOIN products AS p ON p.category_id = cat.id
LEFT JOIN orders   AS o ON o.product_id = p.id
                       AND o.ordered_at = cal.day::date
GROUP BY cal.day, cat.id, cat.name
ORDER BY cal.day, cat.name;
```

В результате — все 25 клеток: видно, что 4 июня пусто во всех категориях, а
«Спорт» и «Игрушки» пусты всю пятидневку — и всё это **нулями**, а не отсутствующими
строками. Это тот же приём «сетка через `CROSS JOIN`, факты через `LEFT JOIN`,
дыры через `COALESCE`», что и матрица «категория × месяц» из
[lab002](../../lab002/theory/05-cross-self-join.md) — только ряд дат теперь
порождает `generate_series`.

> **Куда это ведёт.** Полноценные временные ряды (интервалы, `date_trunc`,
> недельные/квартальные сетки, скользящие окна) — это lab014; накопительные итоги
> и «предыдущий период» удобнее считать оконными функциями (lab010). Здесь мы
> заложили фундамент: **сплошной каркас через `generate_series` + `LEFT JOIN` +
> `COALESCE`.**

## Итог файла

- **top-N на группу** = `LATERAL`-подзапрос с `WHERE = группа`, `ORDER BY` и
  `LIMIT N`. `LEFT JOIN LATERAL ... ON true`, если пустые группы терять нельзя.
  Результат — обычные строки, поэтому его можно дальше агрегировать (задача 13).
- **gap-filling** = `generate_series` (каркас периодов) + `LEFT JOIN` (факты) +
  `COUNT`/`COALESCE(SUM,0)` (нули в пустых периодах). Каркас — слева; условие про
  период — в `ON`.
- Двумерный каркас — `generate_series CROSS JOIN справочник`, дальше так же.

## Документация

- `LATERAL` и табличные функции (рус.):
  <https://postgrespro.ru/docs/postgresql/16/queries-table-expressions#QUERIES-LATERAL>
- `generate_series`, функции даты/времени (рус.):
  <https://postgrespro.ru/docs/postgresql/16/functions-datetime>

---

[← LATERAL](04-lateral.md) · [оглавление](../README.md) · [дальше: подводные камни и выбор инструмента →](06-pitfalls-choosing.md)
