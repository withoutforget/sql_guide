# 06 — `GROUP BY` и `HAVING`: агрегаты по группам

[← агрегаты](05-aggregates.md) · [оглавление](../README.md)

---

## `GROUP BY` — разбить строки на группы

`GROUP BY` собирает строки с одинаковыми значениями указанных колонок в **одну
группу**, и агрегатные функции считаются **отдельно для каждой группы**.

```sql
SELECT
    category,
    COUNT(*)             AS products_count,
    ROUND(AVG(price), 2) AS avg_price
FROM products
GROUP BY category;
```

Результат: по одной строке на каждую категорию, а `COUNT`/`AVG` — внутри неё.

### Мысленная модель

1. `FROM`/`WHERE` дают набор строк.
2. `GROUP BY category` раскладывает их по «корзинам» — своя корзина на каждое
   значение `category`.
3. Каждый агрегат в `SELECT` считается внутри корзины.
4. На выходе — одна строка на корзину.

## Золотое правило `GROUP BY`

**Каждая колонка в `SELECT` должна быть либо в `GROUP BY`, либо под
агрегатом.** Иначе — ошибка.

```sql
-- ❌ ОШИБКА: name не в GROUP BY и не под агрегатом
SELECT category, name, COUNT(*)
FROM products
GROUP BY category;
-- column "products.name" must appear in the GROUP BY clause or be used in an aggregate function
```

Почему: в группе «electronics» несколько разных `name` — какое из них показать в
одной строке результата? СУБД не угадывает и требует определённости: либо
сгруппируй и по `name` тоже, либо примени агрегат (`MAX(name)`, `COUNT(name)`).

## Группировка по нескольким колонкам

Группа определяется **комбинацией** значений:

```sql
SELECT category, in_stock > 0 AS available, COUNT(*)
FROM products
GROUP BY category, in_stock > 0;
-- отдельный счётчик для каждой пары (категория, есть ли в наличии)
```

Группировать можно по колонке, по выражению, по номеру колонки в `SELECT`
(`GROUP BY 1`) или по алиасу (в PostgreSQL).

## `GROUP BY` и `NULL`

Все строки с `NULL` в группирующей колонке попадают в **одну** группу (в отличие
от сравнения, где `NULL = NULL` не истинно, здесь они считаются «одинаковыми»
для группировки).

## `HAVING` — фильтр по группам

`WHERE` не может фильтровать по агрегату (он выполняется до группировки). Для
условия на **результат агрегата** есть `HAVING` — он применяется **после**
`GROUP BY`.

```sql
SELECT category, COUNT(*) AS products_count
FROM products
GROUP BY category
HAVING COUNT(*) > 2;         -- оставить только группы, где больше 2 товаров
```

### `WHERE` vs `HAVING` — ключевое различие

| | `WHERE` | `HAVING` |
|--|---------|----------|
| Когда | до группировки | после группировки |
| Над чем | над отдельными строками | над группами |
| Агрегаты | ❌ нельзя | ✅ можно |

Часто в запросе есть **оба**, и это правильно — фильтруй строки как можно раньше
(в `WHERE`), а по агрегатам — в `HAVING`:

```sql
SELECT category, ROUND(AVG(price), 2) AS avg_price
FROM products
WHERE in_stock > 0            -- 1) сначала выкинули товары не в наличии
GROUP BY category
HAVING AVG(price) > 2000      -- 2) потом оставили дорогие в среднем категории
ORDER BY avg_price DESC;      -- 3) и отсортировали
```

**Производительность:** `WHERE` уменьшает объём данных *до* группировки, поэтому
условие, которое можно записать в `WHERE`, туда и пишите — не тащите его в
`HAVING`. В `HAVING` — только то, что без агрегата не выразить.

## Полный порядок исполнения (собираем всё вместе)

```
FROM       — взять таблицу
  ↓
WHERE      — отфильтровать строки
  ↓
GROUP BY   — разбить на группы
  ↓
HAVING     — отфильтровать группы
  ↓
SELECT     — вычислить колонки и агрегаты
  ↓
DISTINCT   — убрать дубликаты
  ↓
ORDER BY   — отсортировать
  ↓
LIMIT      — обрезать
```

Держа эту схему в голове, легко объяснить почти любую ошибку «column must appear
in GROUP BY» или «aggregate not allowed in WHERE».

## Что дальше

- `GROUP BY` с несколькими уровнями итогов — `GROUPING SETS`, `ROLLUP`, `CUBE`
  (продвинутая аналитика, в следующих лабах).
- Когда нужно и агрегат, и детальные строки одновременно — это уже **оконные
  функции** (`OVER (PARTITION BY ...)`), им посвящена отдельная лаба. Оконные
  функции не схлопывают строки, в отличие от `GROUP BY`.

## Документация

- `GROUP BY` и `HAVING` (рус.):
  <https://postgrespro.ru/docs/postgresql/16/queries-table-expressions#QUERIES-GROUP>
- `GROUPING SETS`, `ROLLUP`, `CUBE` (рус.):
  <https://postgrespro.ru/docs/postgresql/16/queries-table-expressions#QUERIES-GROUPING-SETS>

---

[← агрегаты](05-aggregates.md) · [оглавление](../README.md)
