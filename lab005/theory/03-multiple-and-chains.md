# 03 — Несколько CTE, цепочки и переиспользование

[← CTE vs derived](02-cte-vs-derived.md) · [оглавление](../README.md) · [дальше: MATERIALIZED →](04-materialized.md)

---

Настоящая сила CTE раскрывается, когда их **несколько**. Тут CTE превращается из
«просто именованного подзапроса» в инструмент, которым сложный запрос собирают
как конструктор — шаг за шагом.

## Несколько CTE через запятую

В одной секции `WITH` можно объявить сколько угодно CTE — они перечисляются
**через запятую**. `WITH` при этом пишется **один раз**:

```sql
WITH
    cte1 AS ( ... ),      -- запятая между CTE
    cte2 AS ( ... ),      -- запятая
    cte3 AS ( ... )       -- перед главным запросом запятой НЕТ
SELECT ...                -- главный запрос
FROM ...;
```

Частая ошибка новичка — написать `WITH` перед каждым CTE или поставить запятую
перед `SELECT`. Правильно: **один `WITH`, запятые между CTE, никакой запятой
перед главным запросом**.

### Пример: несколько независимых «кубиков» в одну сводку

CTE не обязаны быть связаны друг с другом. Можно посчитать несколько независимых
показателей и собрать их в одну строку-сводку:

```sql
WITH
    revenue AS (
        SELECT SUM(p.price * o.quantity) AS grand_total
        FROM orders AS o JOIN products AS p ON p.id = o.product_id
    ),
    lines AS (
        SELECT COUNT(*) AS order_lines FROM orders
    ),
    buyers AS (
        SELECT COUNT(DISTINCT customer_id) AS active_customers FROM orders
    )
SELECT revenue.grand_total,
       lines.order_lines,
       buyers.active_customers
FROM revenue, lines, buyers;      -- каждый CTE — таблица 1×1, их перемножение даёт одну строку
```
```
 grand_total | order_lines | active_customers
-------------+-------------+------------------
   137320.00 |          22 |                8
(1 row)
```

Здесь три CTE вычисляют по одному числу каждый, а `FROM revenue, lines, buyers`
соединяет их (это `CROSS JOIN` из lab002; для таблиц 1×1 он просто ставит три
значения в одну строку). Каждый показатель считается **своим понятным шагом** —
это и есть декомпозиция.

## Цепочки: следующий CTE видит предыдущий

Ключевая возможность: CTE, объявленный **ниже**, может **ссылаться на объявленный
выше** — как на готовую таблицу. Так строятся **цепочки** шагов, где каждый
следующий работает с результатом предыдущего.

Разберём каноничную многошаговую аналитику: **«категории, чья выручка выше
средней выручки по категориям»**. Это естественно раскладывается на два шага:

1. посчитать выручку **по каждой категории**;
2. взять от неё **среднюю** и оставить категории выше этого среднего.

```sql
WITH
    category_revenue AS (                       -- ШАГ 1: выручка по категориям
        SELECT p.category_id,
               SUM(p.price * o.quantity) AS revenue
        FROM orders   AS o
        JOIN products AS p ON p.id = o.product_id
        GROUP BY p.category_id
    ),
    avg_revenue AS (                            -- ШАГ 2: среднее ПО РЕЗУЛЬТАТУ шага 1
        SELECT AVG(revenue) AS avg_rev
        FROM category_revenue                   -- ← ссылка на предыдущий CTE!
    )
SELECT cat.name,
       cr.revenue,
       ROUND((SELECT avg_rev FROM avg_revenue), 2) AS avg_rev
FROM category_revenue AS cr                     -- используем шаг 1
JOIN categories AS cat ON cat.id = cr.category_id
WHERE cr.revenue > (SELECT avg_rev FROM avg_revenue)   -- и шаг 2
ORDER BY cr.revenue DESC;
```
```
    name     | revenue  | avg_rev
-------------+----------+----------
 Электроника | 83420.00 | 27464.00
 Дом         | 34950.00 | 27464.00
(2 rows)
```

`avg_revenue` строится **на основе** `category_revenue` — считает среднее по его
колонке `revenue`. Главный запрос использует оба шага. Средняя выручка по пяти
категориям — 27464 ₽; выше неё только Электроника (83420) и Дом (34950). Каждый
шаг понятен по отдельности — попробуйте записать это одним вложенным подзапросом
и сравните читаемость.

> **Так делать «агрегат от агрегата» логичнее, чем в lab004.** Здесь среднее по
> категориям — это среднее **от** посуммовой выручки категорий, то есть снова
> двухуровневая агрегация. CTE-цепочка выражает её буквально «шаг за шагом».

### Порядок определения важен: ссылаться можно только «назад»

CTE видит только те CTE, что объявлены **выше него**. Сослаться на CTE,
определённый **ниже** («вперёд»), — **нельзя**:

```sql
-- ❌ ОШИБКА: a ссылается на b, а b объявлен НИЖЕ
WITH a AS (SELECT * FROM b),      -- b ещё «не существует» в этой точке
     b AS (SELECT 1 AS x)
SELECT * FROM a;
-- ERROR: relation "b" does not exist
```

Правило простое: **пишите шаги в том порядке, в котором они вычисляются** —
сначала базовые, потом те, что на них опираются. (Единственное исключение —
рекурсивные CTE, где `WITH RECURSIVE` разрешает ссылку на самого себя; это lab007
и здесь не рассматривается.)

## Область видимости — сводно

| Откуда ссылаемся | Видны ли CTE, объявленные ВЫШЕ? | Видны ли объявленные НИЖЕ? |
|------------------|:-------------------------------:|:--------------------------:|
| внутри другого CTE | ✅ да | ❌ нет («вперёд» нельзя) |
| в главном запросе (после `WITH`) | ✅ да (**все** объявленные) | — |
| вне этого запроса | ❌ нет (CTE не существует снаружи) | ❌ нет |

Итого: **все CTE, объявленные в секции `WITH`, доступны в главном запросе; внутри
CTE доступны только предшествующие; за пределами запроса — недоступны никакие**
(про это — [файл 01](01-what-is-cte.md)).

## Переиспользование одного CTE в нескольких местах

Один CTE можно использовать в главном запросе **несколько раз**. Это то, ради
чего CTE часто и берут (derived table так не умеет — [файл 02](02-cte-vs-derived.md)).
Два типичных приёма.

### Сравнение результата с его же агрегатом

Мы уже видели это в [файле 02](02-cte-vs-derived.md): CTE стоит в `FROM`, и он же
— в скалярном подзапросе, вычисляющем по нему среднее/сумму/максимум. Ещё пример
— **доля каждой категории в общей выручке**: `category_revenue` используется и как
источник строк, и внутри `(SELECT SUM(revenue) FROM category_revenue)`:

```sql
WITH category_revenue AS (
    SELECT p.category_id, SUM(p.price * o.quantity) AS revenue
    FROM orders AS o JOIN products AS p ON p.id = o.product_id
    GROUP BY p.category_id
)
SELECT cat.name,
       cr.revenue,
       ROUND(cr.revenue * 100.0 / (SELECT SUM(revenue) FROM category_revenue), 2) AS pct_of_total
FROM category_revenue AS cr
JOIN categories AS cat ON cat.id = cr.category_id
ORDER BY cr.revenue DESC;
```
```
    name     | revenue  | pct_of_total
-------------+----------+--------------
 Электроника | 83420.00 |        60.75
 Дом         | 34950.00 |        25.45
 Книги       |  9830.00 |         7.16
 Игрушки     |  6450.00 |         4.70
 Спорт       |  2670.00 |         1.94
(5 rows)
```

Каждой строке нужна **общая** сумма (одна на всех), и её даёт тот же `category_revenue`.

### Джойн промежуточного результата с самим собой (self-join)

CTE можно присоединить к самому себе — как self-join таблицы из lab002, только
соединяем не таблицу, а **вычисленный шаг**. Задача: «пары клиентов из одного
города, где первый потратил больше второго».

```sql
WITH customer_revenue AS (
    SELECT o.customer_id, SUM(p.price * o.quantity) AS total
    FROM orders AS o JOIN products AS p ON p.id = o.product_id
    GROUP BY o.customer_id
)
SELECT c1.city,
       big.name  AS spent_more, r1.total AS more_total,
       small.name AS spent_less, r2.total AS less_total
FROM customer_revenue AS r1                       -- первая «копия» шага
JOIN customer_revenue AS r2 ON TRUE               -- вторая «копия» того же шага
JOIN customers AS big   ON big.id   = r1.customer_id
JOIN customers AS small ON small.id = r2.customer_id
JOIN customers AS c1    ON c1.id    = r1.customer_id
WHERE big.city = small.city                       -- один город
  AND r1.total > r2.total                          -- первый потратил больше
ORDER BY c1.city, r1.total DESC;
```
```
  city  | spent_more | more_total | spent_less | less_total
--------+------------+------------+------------+------------
 Казань | Глеб       |    9480.00 | Захар      |    8480.00
 Москва | Егор       |   34640.00 | Анна       |   30550.00
 Москва | Егор       |   34640.00 | Вера       |   15660.00
 Москва | Анна       |   30550.00 | Вера       |   15660.00
(4 rows)
```

`customer_revenue` посчитан один раз, а в `FROM` он появился **дважды** (`r1` и
`r2`) — как две копии одной таблицы в self-join. Без CTE пришлось бы дважды
выписать весь агрегирующий подзапрос. (В [задаче 6](../queries/06_reuse_self_join.sql)
мы запишем это чуть аккуратнее, вынеся город в сам CTE.)

## Итог

- Несколько CTE перечисляются через запятую: **один `WITH`, запятые между CTE,
  никакой запятой перед главным запросом**.
- CTE можно строить **цепочкой**: следующий ссылается на предыдущий как на
  таблицу. Ссылаться можно только **назад** — «вперёд» нельзя (нерекурсивные CTE).
- В главном запросе доступны **все** объявленные CTE; внутри CTE — только
  предшествующие; снаружи запроса — никакие.
- Один CTE можно **переиспользовать** несколько раз: сравнить с его же агрегатом
  или сджойнить сам с собой. Это ключевое преимущество перед derived table.

## Документация

- Запросы `WITH`, несколько CTE и порядок вычисления — рус.:
  <https://postgrespro.ru/docs/postgresql/16/queries-with>
- Self-join и `CROSS JOIN` (напоминание из lab002) — рус.:
  <https://postgrespro.ru/docs/postgresql/16/queries-table-expressions#QUERIES-JOIN>

---

[← CTE vs derived](02-cte-vs-derived.md) · [оглавление](../README.md) · [дальше: MATERIALIZED →](04-materialized.md)
