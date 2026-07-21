# 04 — Выражения, `CASE` и полезные функции

[← сортировка](03-order-distinct-limit.md) · [оглавление](../README.md) · [дальше: агрегаты →](05-aggregates.md)

---

## Вычисляемые колонки

В `SELECT` можно писать не только имена колонок, но и любые выражения. Они
вычисляются для каждой строки.

```sql
SELECT
    name,
    price,
    in_stock,
    price * in_stock         AS stock_value,     -- умножение
    price * 1.20             AS price_with_vat,   -- +20%
    price / 100              AS price_in_hundreds
FROM products;
```

### Арифметика и типы

Операторы: `+ - * /` и `%` (остаток). Важный нюанс — **целочисленное деление**:

```sql
SELECT 7 / 2;        -- 3   (оба операнда целые → целочисленное деление!)
SELECT 7.0 / 2;      -- 3.5 (один операнд дробный → дробное деление)
SELECT 7 / 2.0;      -- 3.5
SELECT 7 % 2;        -- 1   (остаток)
```

Если делите целые, а нужен дробный результат — приведите тип:

```sql
SELECT price / 3;                 -- price числовой (NUMERIC) → ок, дробное
SELECT quantity::numeric / 2;     -- явное приведение int → numeric
SELECT CAST(quantity AS numeric) / 2;   -- то же самое, стандартный синтаксис
```

`::тип` — короткий синтаксис приведения в PostgreSQL; `CAST(x AS тип)` —
стандартный ANSI-эквивалент.

## Работа со строками

Несколько функций, которые понадобятся сразу:

| Функция / оператор        | Что делает                          | Пример → результат            |
|---------------------------|-------------------------------------|-------------------------------|
| `a \|\| b`                | конкатенация строк                  | `'abc' \|\| '!'` → `abc!`     |
| `length(s)`               | длина в символах                    | `length('код')` → `3`         |
| `upper(s)` / `lower(s)`   | регистр                             | `upper('abc')` → `ABC`        |
| `trim(s)`                 | убрать пробелы по краям             | `trim('  x ')` → `x`          |
| `substring(s FROM a FOR n)` | подстрока                         | `substring('abcd' FROM 2 FOR 2)` → `bc` |
| `replace(s, from, to)`    | замена подстроки                    | `replace('a-b','-','+')` → `a+b` |
| `concat(a, b, ...)`       | конкатенация (игнорирует `NULL`)    | `concat('a', NULL, 'b')` → `ab` |

```sql
SELECT name || ' (' || category || ')' AS label
FROM products;
-- «Наушники TWS Pro (electronics)»
```

⚠️ Оператор `||` c `NULL` даёт `NULL` целиком. `concat()` в этом смысле
безопаснее — пропускает `NULL`.

## Работа с `NULL`: `COALESCE`, `NULLIF`

- **`COALESCE(a, b, c, ...)`** — возвращает первый аргумент, который не `NULL`.
  Классика для «значения по умолчанию»:

  ```sql
  SELECT COALESCE(discount, 0) AS discount FROM products;   -- NULL → 0
  ```

- **`NULLIF(a, b)`** — возвращает `NULL`, если `a = b`, иначе `a`. Удобно, чтобы
  избежать деления на ноль:

  ```sql
  SELECT total / NULLIF(count, 0);   -- если count=0 → делим на NULL → результат NULL, а не ошибка
  ```

## `CASE` — условная логика в запросе

`CASE` — это `if/else` внутри SQL-выражения. Возвращает значение в зависимости
от условий. Есть две формы.

### Поисковая форма (searched) — гибкая

Каждая ветка — своё логическое условие. Проверяются сверху вниз, срабатывает
первая истинная:

```sql
SELECT
    name,
    in_stock,
    CASE
        WHEN in_stock = 0   THEN 'нет в наличии'
        WHEN in_stock < 10  THEN 'мало'
        ELSE                     'достаточно'
    END AS stock_status
FROM products;
```

- Ветки проверяются **по порядку** — важно от частного к общему.
- `ELSE` необязателен; если его нет и ни одно условие не сработало — результат
  `NULL`.
- Все ветки `THEN`/`ELSE` должны возвращать **совместимый тип**.

### Простая форма (simple) — сравнение с одним значением

Короче, когда сравниваем одно выражение с набором значений:

```sql
SELECT
    name,
    CASE category
        WHEN 'electronics' THEN 'Электроника'
        WHEN 'books'       THEN 'Книги'
        ELSE                    'Прочее'
    END AS category_ru
FROM products;
```

Простая форма сравнивает через `=`, поэтому **не умеет** проверять `NULL` (см.
трёхзначную логику в [файле 02](02-where.md)) и диапазоны — для этого нужна
поисковая форма.

### `CASE` где угодно

`CASE` — это выражение, поэтому его можно ставить не только в `SELECT`, но и в
`WHERE`, `ORDER BY`, внутри агрегатов:

```sql
-- условная сортировка: сначала «нет в наличии», потом остальное
ORDER BY CASE WHEN in_stock = 0 THEN 0 ELSE 1 END, price DESC

-- условный подсчёт (частый приём — «pivot» через агрегат):
SELECT
    COUNT(*) FILTER (WHERE in_stock = 0)              AS out_of_stock,
    SUM(CASE WHEN price > 10000 THEN 1 ELSE 0 END)    AS expensive_count
FROM products;
```

`FILTER (WHERE ...)` — современный и читаемый способ условной агрегации в
PostgreSQL (подробнее в [файле 05](05-aggregates.md)).

## Документация

- Условные выражения `CASE`, `COALESCE`, `NULLIF` (рус.):
  <https://postgrespro.ru/docs/postgresql/16/functions-conditional>
- Строковые функции и операторы (рус.):
  <https://postgrespro.ru/docs/postgresql/16/functions-string>
- Математические функции (рус.):
  <https://postgrespro.ru/docs/postgresql/16/functions-math>
- Приведение типов `CAST` (рус.):
  <https://postgrespro.ru/docs/postgresql/16/sql-expressions>

---

[← сортировка](03-order-distinct-limit.md) · [оглавление](../README.md) · [дальше: агрегаты →](05-aggregates.md)
