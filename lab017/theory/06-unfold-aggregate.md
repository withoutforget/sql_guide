# 06 — Разворачивание JSON в строки и обратная агрегация

[← изменение jsonb](05-modify.md) · [оглавление](../README.md)

---

Кульминация темы — **мост между JSON и реляционным миром** в обе стороны:

- **разворачивание** (JSON → строки/таблица): «взорвать» массив или объект в
  строки, чтобы дальше работать обычным SQL — фильтровать, группировать,
  джойнить;
- **агрегация** (строки → JSON): собрать результат обратно в JSON-массив/объект,
  например для API-ответа.

Все разворачивающие функции — **set-returning** (возвращают набор строк), поэтому
ставятся во **`FROM`**, обычно через **`LATERAL`**, чтобы разворачивать документ
из каждой строки таблицы. Механику `LATERAL` и SRF мы разобрали в
[lab006](../../lab006/) — здесь применяем к JSON.

## Разворачивание массива

### `jsonb_array_elements(arr)` — элементы массива в строки

По строке на каждый элемент JSON-массива; значение — `jsonb`.

```sql
SELECT o.id, it
FROM orders o,
     LATERAL jsonb_array_elements(o.items) AS it
WHERE o.id = 1;
```
```
 id |                          it
----+------------------------------------------------------
  1 | {"qty": 1, "price": 24990, "product": "Смартфон Nova 5"}
  1 | {"qty": 2, "price": 5990, "product": "Наушники TWS Pro"}
```

Дальше `it` — обычное значение: достаём поля через `->>`, приводим к числам,
группируем. Классика — **сумма заказа**:

```sql
SELECT o.id, SUM((it ->> 'qty')::int * (it ->> 'price')::numeric) AS total
FROM orders o, LATERAL jsonb_array_elements(o.items) AS it
GROUP BY o.id ORDER BY o.id;
```
```
 id | total
----+-------
  1 | 36970
  2 | 74990
  ...
```

- **`jsonb_array_elements_text(arr)`** — то же, но элементы сразу `text` (удобно
  для массива строк/чисел, когда не нужен JSON).

### `jsonb_to_recordset` — массив объектов сразу в типизированную таблицу

Если массив — это **список объектов одинаковой формы**, `jsonb_to_recordset`
разворачивает его в строки и **раскладывает поля по колонкам с типами**, которые
вы объявляете в `AS (...)`. Не нужно доставать каждое поле через `->>` и приводить
вручную — числа сразу числа:

```sql
SELECT o.id, x.product, x.qty, x.price, x.qty * x.price AS subtotal
FROM orders o,
     LATERAL jsonb_to_recordset(o.items) AS x(product text, qty int, price numeric)
WHERE o.id = 3
ORDER BY x.product;
```
```
 id |       product        | qty | price | subtotal
----+----------------------+-----+-------+----------
  3 | Книга «SQL за месяц» |   3 |   890 |     2670
  3 | Мышь беспроводная    |   2 |  1490 |     2980
  3 | Наушники TWS Pro     |   1 |  5990 |     5990
```

- Объявлять надо **только нужные** поля; лишние ключи документа игнорируются, а
  объявленное, но отсутствующее поле даст `NULL`.
- Родня: **`jsonb_to_record(doc)`** — то же для **одного** объекта (не массива);
  **`json_populate_record(base, doc)`** / **`json_populate_recordset`** —
  заполняют строку(и) по образцу существующего типа/таблицы.

Когда что: `jsonb_array_elements` — когда структура элементов **разная** или
нужен сам `jsonb`; `jsonb_to_recordset` — когда элементы **однородные** и удобнее
сразу типизированные колонки.

## Разворачивание объекта

### `jsonb_each(doc)` / `jsonb_each_text(doc)` — пары ключ-значение в строки

По строке на каждую пару верхнего уровня; колонки `key` и `value` (`value` —
`jsonb` у `jsonb_each`, `text` у `jsonb_each_text`). Превращает документ с
**произвольным** набором ключей в узкую таблицу «ключ-значение» (вид EAV):

```sql
SELECT p.name, kv.key AS attribute, kv.value
FROM products p, LATERAL jsonb_each_text(p.attributes) AS kv
WHERE p.id = 2
ORDER BY kv.key;
```
```
        name        | attribute | value
--------------------+-----------+-------
 Ноутбук AirBook 14 | brand     | Apple
 Ноутбук AirBook 14 | ram       | 16
 Ноутбук AirBook 14 | screen    | 14.0
 Ноутбук AirBook 14 | ssd       | 512
```

Разворачивает **только верхний уровень**: вложенные объекты/массивы (`colors`,
`genres`) вернутся как одно JSON-значение, не рекурсивно.

### `jsonb_object_keys(doc)` — только ключи

По строке на каждый ключ верхнего уровня (значения не нужны):

```sql
SELECT jsonb_object_keys(attributes) AS key
FROM products WHERE id = 1 ORDER BY key;
-- brand, colors, ram, screen
```

### `jsonb_array_length(arr)` — длина массива

Не разворачивает, а считает элементы (скалярная функция):

```sql
SELECT id, jsonb_array_length(items) AS positions FROM orders ORDER BY id;
```

## Обратная агрегация: строки → JSON

Собрать результат **из многих строк** обратно в JSON — «json-родня» `array_agg`
из [lab009](../../lab009/theory/02-collections-and-boolean.md).

### `jsonb_agg(expr ORDER BY …)` — строки в JSON-массив

```sql
SELECT category,
       jsonb_agg(jsonb_build_object('name', name, 'price', price)
                 ORDER BY price DESC, id) AS products_json
FROM products
GROUP BY category ORDER BY category;
```
```
 books | [{"name": "Книга «Чистый код»", "price": 1290.00}, ...]
 electronics | [{"name": "Ноутбук AirBook 14", "price": 74990.00}, ...]
```

### `jsonb_object_agg(key, value ORDER BY …)` — строки в JSON-объект

```sql
SELECT jsonb_object_agg(name, price ORDER BY name) AS price_list
FROM products WHERE category = 'books';
-- {"Роман «Дюна»": 990.00, "Книга «SQL за месяц»": 890.00, "Книга «Чистый код»": 1290.00}
```

### Детерминизм: `ORDER BY` внутри — обязателен!

> **Правило воспроизводимости.** Порядок элементов, которые собирает `jsonb_agg`,
> **не определён** без `ORDER BY` **внутри** агрегата — от запуска к запуску он
> может «плавать». Всегда пишите `jsonb_agg(x ORDER BY …)` (то же, что для
> `array_agg` в lab009). Для `jsonb_object_agg` ключи в результирующем объекте
> `jsonb` всё равно отсортируются по своим правилам, но `ORDER BY` внутри задаёт,
> **чьё значение победит** при дубликате ключа — тоже пишите его.
>
> При разворачивании (`jsonb_array_elements`, `jsonb_each`, `jsonb_object_keys`)
> порядок строк на выходе тоже не гарантирован — если он важен, добавляйте
> `ORDER BY` во **внешнем** запросе (по ключу, по индексу через `WITH ORDINALITY`
> из [lab006](../../lab006/), по вычисленному полю).

## Кульминация: собрать вложенный API-ответ (задача 14)

Реальная задача backend-разработчика — отдать по каждому заказу документ
`{order_id, customer, total, items:[…]}`, где `items` пересобран с вычисленным
`subtotal`, а `total` — сумма позиций. Здесь сходятся все приёмы лабы:
разворачивание в `LATERAL`, приведения, `jsonb_build_object` и `jsonb_agg` с
`ORDER BY`:

```sql
SELECT jsonb_pretty(jsonb_build_object(
           'order_id', o.id,
           'customer', o.customer,
           'total',    agg.total,
           'items',    agg.items
       )) AS response
FROM orders o
CROSS JOIN LATERAL (
    SELECT SUM((it->>'qty')::int * (it->>'price')::numeric) AS total,
           jsonb_agg(
               jsonb_build_object(
                   'product',  it->>'product',
                   'qty',      (it->>'qty')::int,
                   'subtotal', (it->>'qty')::int * (it->>'price')::numeric)
               ORDER BY (it->>'qty')::int * (it->>'price')::numeric DESC
           ) AS items
    FROM jsonb_array_elements(o.items) AS it
) AS agg
WHERE o.id = 1;
```
```
 {
     "items": [
         {"qty": 1, "product": "Смартфон Nova 5", "subtotal": 24990},
         {"qty": 2, "product": "Наушники TWS Pro", "subtotal": 11980}
     ],
     "total": 36970,
     "customer": "Анна",
     "order_id": 1
 }
```

Логика: внутренний `LATERAL`-подзапрос разворачивает позиции заказа, считает
`total` и одновременно собирает их обратно в чистый JSON-массив `items` (с
детерминирующим `ORDER BY`); внешний `jsonb_build_object` заворачивает всё в
финальный документ. `jsonb_pretty` даёт стабильный человекочитаемый вид.

## Утилиты (для полноты)

- **`jsonb_pretty(doc)`** — красивый отступированный вывод (детерминирован).
- **`jsonb_typeof(doc)`** — тип значения (файл [01](01-json-vs-jsonb.md)).
- **`jsonb_array_length`**, **`jsonb_strip_nulls`** — см. выше и файл 05.

## Итог файла

- Разворачивание (set-returning, в `FROM`/`LATERAL`): `jsonb_array_elements`(`_text`)
  — массив в строки; `jsonb_to_recordset` — массив объектов в типизированную
  таблицу; `jsonb_each`(`_text`) — пары объекта; `jsonb_object_keys` — ключи;
  `jsonb_array_length` — длина.
- Агрегация: `jsonb_agg` (массив) и `jsonb_object_agg` (объект) — «json-родня»
  `array_agg`; **`ORDER BY` внутри обязателен** для детерминизма.
- Связка «развернуть → посчитать → собрать обратно» строит вложенные API-ответы
  из реляционных данных.

## Документация

- Функции обработки JSON (`jsonb_array_elements`, `jsonb_to_recordset`,
  `jsonb_each`, `jsonb_object_keys`, `jsonb_pretty`) (рус.):
  <https://postgrespro.ru/docs/postgresql/16/functions-json>
- JSON-агрегаты `jsonb_agg`/`jsonb_object_agg` (рус.):
  <https://postgrespro.ru/docs/postgresql/16/functions-aggregate>

---

[← изменение jsonb](05-modify.md) · [оглавление](../README.md)
