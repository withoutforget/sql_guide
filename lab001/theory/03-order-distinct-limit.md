# 03 — `ORDER BY`, `DISTINCT`, `LIMIT`: сортировка и отбор

[← WHERE](02-where.md) · [оглавление](../README.md) · [дальше: CASE и выражения →](04-case.md)

---

## `ORDER BY` — сортировка результата

Без `ORDER BY` порядок строк в SQL **не определён** — СУБД может вернуть их в
любом порядке (и он может меняться от запуска к запуску). Если порядок важен —
задавайте его явно.

```sql
SELECT name, price
FROM products
ORDER BY price;          -- по возрастанию (по умолчанию)
```

### `ASC` / `DESC` — направление

```sql
ORDER BY price ASC       -- по возрастанию (default, можно не писать)
ORDER BY price DESC      -- по убыванию
```

### Сортировка по нескольким колонкам

Сортирует по первой колонке, при равенстве — по второй, и т.д.:

```sql
ORDER BY category ASC, price DESC
-- сначала по категории (А→Я), внутри категории — по цене (дорогие сверху)
```

### По номеру колонки и по алиасу

```sql
ORDER BY 2 DESC                      -- по 2-й колонке в SELECT (хрупко, но кратко)
ORDER BY price * in_stock DESC       -- по выражению
ORDER BY stock_value DESC            -- по алиасу из SELECT (в ORDER BY можно!)
```

`ORDER BY` — единственная секция, где алиас из `SELECT` уже доступен, потому что
выполняется после него.

### `NULLS FIRST` / `NULLS LAST`

`NULL` при сортировке считается «больше всех». По умолчанию в PostgreSQL:
`ASC` → `NULLS LAST`, `DESC` → `NULLS FIRST`. Поведение можно задать явно:

```sql
ORDER BY discount DESC NULLS LAST
```

### Сортировка текста и регистр

Строки сравниваются по правилам сортировки (collation) базы/колонки. Это влияет
на регистр и порядок кириллицы/латиницы. Для явного контроля:
`ORDER BY name COLLATE "C"` (побайтово) или конкретная локаль.

## `DISTINCT` — уникальные строки

Убирает дубликаты из результата. Уникальность считается **по всем колонкам в
`SELECT`**, а не по одной.

```sql
SELECT DISTINCT city FROM customers;             -- уникальные города

SELECT DISTINCT city, registered FROM customers; -- уникальные ПАРЫ (город, дата)
```

- `DISTINCT` пишется **сразу после `SELECT`** и относится ко всей строке.
- Часто путают с `GROUP BY`: `SELECT DISTINCT city` эквивалентно
  `SELECT city ... GROUP BY city`. Разница в том, что `GROUP BY` позволяет ещё и
  считать агрегаты по группам, а `DISTINCT` — только убирает повторы.
- `NULL` считается одним значением: несколько `NULL` схлопнутся в один.

### `DISTINCT ON (...)` — расширение PostgreSQL

Возвращает первую строку для каждого значения указанных колонок (в порядке
`ORDER BY`). Удобно для «последней записи на каждого клиента»:

```sql
SELECT DISTINCT ON (customer_id) customer_id, ordered_at, product_id
FROM orders
ORDER BY customer_id, ordered_at DESC;   -- по одному, самому свежему заказу на клиента
```

Тонкость: список в `DISTINCT ON` должен идти в начале `ORDER BY`.

## `LIMIT` и `OFFSET` — сколько строк вернуть

```sql
SELECT name, price
FROM products
ORDER BY price DESC
LIMIT 3;             -- только первые 3 строки
```

- **`LIMIT` почти всегда идёт с `ORDER BY`** — иначе «первые N» это случайные N.
- `OFFSET n` пропускает первые `n` строк (для постраничного вывода):

```sql
ORDER BY price DESC
LIMIT 10 OFFSET 20;   -- строки 21–30 (третья «страница» по 10)
```

- Стандартный (ANSI) синтаксис того же — `FETCH FIRST n ROWS ONLY`; в PostgreSQL
  работают оба, но `LIMIT` короче и привычнее.

⚠️ **`OFFSET` дорогой на больших смещениях**: чтобы отдать строки 100001–100010,
СУБД всё равно проходит первые 100000. Для «бесконечной ленты» лучше
keyset-пагинация (`WHERE id > <последний_виденный>`), но это позже.

## Как эти секции сочетаются

Порядок исполнения: `... → SELECT → DISTINCT → ORDER BY → LIMIT`. То есть
сначала убираются дубликаты, потом сортировка, потом обрезка по `LIMIT`.

```sql
SELECT DISTINCT category
FROM products
ORDER BY category
LIMIT 2;
```

## Документация

- `SELECT`, секции `ORDER BY`, `LIMIT`, `DISTINCT` (рус.):
  <https://postgrespro.ru/docs/postgresql/16/sql-select>
- Сортировка строк и collation (рус.):
  <https://postgrespro.ru/docs/postgresql/16/collation>

---

[← WHERE](02-where.md) · [оглавление](../README.md) · [дальше: CASE и выражения →](04-case.md)
