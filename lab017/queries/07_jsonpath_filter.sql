-- Задача 7. JSONPath: фильтр вложенных массивов и предикаты по пути.
SET search_path TO lab017;

-- JSONPath — мини-язык путей: $ — корень, .key — ключ, [*] — все элементы
-- массива, ? (предикат) — фильтр (@ означает текущий элемент). jsonb_path_query
-- возвращает НАБОР совпадений (set-returning → ставим в FROM/LATERAL, см. lab006).
-- Здесь: развернуть только позиции дороже 10 000 ₽ по всем заказам.
SELECT
    o.id,
    o.customer,
    hit ->> 'product'          AS product,
    (hit ->> 'price')::numeric AS price
FROM orders o,
     LATERAL jsonb_path_query(o.items, '$[*] ? (@.price > 10000)') AS hit
ORDER BY price DESC, o.id;

-- Операторы @? (существует ли совпадение по пути) и @@ (истинен ли предикат)
-- удобны прямо в WHERE — без разворачивания. Найдём события-ошибки, которые
-- система будет ПОВТОРЯТЬ (вложенный meta.retry == true):
SELECT
    id,
    payload ->> 'path'          AS path,
    payload #> '{meta,attempts}' AS attempts
FROM events
WHERE payload @? '$.meta ? (@.retry == true)'
ORDER BY id;
