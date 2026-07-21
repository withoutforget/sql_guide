-- ============================================================================
-- lab017 — JSON / JSONB. Схема и тестовые данные.
-- Доменная область: интернет-магазин, где часть данных — полуструктурированные
-- документы: гибкие атрибуты товаров, позиции заказа массивом, настройки
-- пользователей, события/логи.
-- Скрипт идемпотентен: всё пересоздаётся с нуля.
-- ============================================================================

DROP SCHEMA IF EXISTS lab017 CASCADE;
CREATE SCHEMA lab017;
SET search_path TO lab017;

-- ── Товары с гибкими атрибутами ─────────────────────────────────────────────
-- attributes JSONB: НАБОР КЛЮЧЕЙ РАЗНЫЙ у разных категорий (разреженность!):
--   электроника → {brand, ram, screen, ...}, книга → {author, pages, genres:[...]}.
-- Специально заложено для задач:
--   • brand = 'Sony' у товаров 1, 3, 8 → фильтр по образцу @> '{"brand":"Sony"}'
--   • ключ ram есть у 1(8), 2(16), 7(12) → приведение (attributes->>'ram')::int,
--     фильтр ram > 8 отбирает товары 2 и 7 (16 и 12), а товар 1 (ram = 8) — нет
--   • ключ screen есть у 1,2,7,8 и ОТСУТСТВУЕТ у остальных → операторы ? / ?& / ?|
--   • у товара 10 (Мышь) есть ключ "warranty": null — это JSON null (не SQL NULL!):
--       attributes ? 'warranty'                → true (ключ ЕСТЬ)
--       attributes ->> 'warranty'              → NULL (значение — JSON null)
--       jsonb_typeof(attributes -> 'warranty') → 'null'
--     тогда как у остальных товаров ключа warranty НЕТ вовсе (missing) →
--     разница «JSON null» vs «ключа нет» + материал для jsonb_strip_nulls
--   • у книг есть вложенный МАССИВ genres:[...] → jsonpath / развёртка
CREATE TABLE products (
    id          INT PRIMARY KEY,
    name        TEXT          NOT NULL,
    category    TEXT          NOT NULL,   -- 'electronics', 'books'
    price       NUMERIC(10,2) NOT NULL,   -- цена за штуку, ₽
    attributes  JSONB         NOT NULL    -- гибкие атрибуты (разный набор ключей)
);

INSERT INTO products (id, name, category, price, attributes) VALUES
    (1,  'Смартфон Nova 5',       'electronics', 24990.00,
        '{"brand":"Sony","ram":8,"screen":6.1,"colors":["black","blue"]}'),
    (2,  'Ноутбук AirBook 14',    'electronics', 74990.00,
        '{"brand":"Apple","ram":16,"screen":14.0,"ssd":512}'),
    (3,  'Наушники TWS Pro',      'electronics', 5990.00,
        '{"brand":"Sony","wireless":true,"colors":["white"]}'),
    (4,  'Умная колонка Mini',    'electronics', 3490.00,
        '{"brand":"Yandex","voice":true}'),
    (5,  'Книга «SQL за месяц»',  'books',        890.00,
        '{"author":"Иванов","pages":320,"genres":["tech","education"]}'),
    (6,  'Книга «Чистый код»',    'books',       1290.00,
        '{"author":"Мартин","pages":464,"genres":["tech","classic"]}'),
    (7,  'Планшет Tab S',         'electronics', 32990.00,
        '{"brand":"Samsung","ram":12,"screen":11.0,"stylus":true}'),
    (8,  'Монитор 27"',           'electronics', 18990.00,
        '{"brand":"Sony","screen":27.0}'),
    (9,  'Роман «Дюна»',          'books',        990.00,
        '{"author":"Херберт","pages":688,"genres":["fantasy","classic"]}'),
    (10, 'Мышь беспроводная',     'electronics', 1490.00,
        '{"brand":"Logitech","wireless":true,"warranty":null}');

-- ── Заказы: позиции — МАССИВ ОБЪЕКТОВ в одном jsonb-поле ─────────────────────
-- items JSONB — массив [{product, qty, price}, ...]. Заложено для задач:
--   • развёртка jsonb_array_elements в LATERAL → сумма заказа SUM(qty*price)
--   • @> '[{"product":"Наушники TWS Pro"}]' — какие заказы содержат этот товар
--   • jsonpath $.items[*] ? (@.price > 10000) — дорогие позиции
--   • аналитика «топ товаров»: развернуть items ВСЕХ заказов и сгруппировать
-- Проверенные суммы (SUM qty*price):
--   заказ 1: 1*24990 + 2*5990          = 36970
--   заказ 2: 1*74990                   = 74990
--   заказ 3: 3*890 + 1*5990 + 2*1490   = 11640
--   заказ 4: 1*32990 + 1*24990         = 57980
--   заказ 5: 1*5990                    = 5990
CREATE TABLE orders (
    id        INT PRIMARY KEY,
    customer  TEXT  NOT NULL,
    items     JSONB NOT NULL    -- массив объектов {product, qty, price}
);

INSERT INTO orders (id, customer, items) VALUES
    (1, 'Анна',
        '[{"product":"Смартфон Nova 5","qty":1,"price":24990},
          {"product":"Наушники TWS Pro","qty":2,"price":5990}]'),
    (2, 'Борис',
        '[{"product":"Ноутбук AirBook 14","qty":1,"price":74990}]'),
    (3, 'Вера',
        '[{"product":"Книга «SQL за месяц»","qty":3,"price":890},
          {"product":"Наушники TWS Pro","qty":1,"price":5990},
          {"product":"Мышь беспроводная","qty":2,"price":1490}]'),
    (4, 'Глеб',
        '[{"product":"Планшет Tab S","qty":1,"price":32990},
          {"product":"Смартфон Nova 5","qty":1,"price":24990}]'),
    (5, 'Анна',
        '[{"product":"Наушники TWS Pro","qty":1,"price":5990}]');

-- ── Профили/настройки пользователей ─────────────────────────────────────────
-- prefs JSONB: ВЛОЖЕННЫЕ объекты (address), массивы (favorite_categories),
-- флаги (notifications). Заложено:
--   • путь {address,city} → операторы #> / #>> по пути-массиву
--   • у Глеба НЕТ ключа address (missing) → #>>'{address,city}' даст SQL NULL
--   • у Бориса "newsletter": null — JSON null (для strip_nulls / typeof)
--   • у Глеба favorite_categories — ПУСТОЙ массив [] (крайний случай)
CREATE TABLE users (
    id     INT PRIMARY KEY,
    name   TEXT  NOT NULL,
    prefs  JSONB NOT NULL
);

INSERT INTO users (id, name, prefs) VALUES
    (1, 'Анна',
        '{"address":{"city":"Москва","street":"Тверская","zip":"101000"},
          "favorite_categories":["electronics","books"],
          "notifications":{"email":true,"sms":false},
          "theme":"dark"}'),
    (2, 'Борис',
        '{"address":{"city":"Санкт-Петербург"},
          "favorite_categories":["electronics"],
          "notifications":{"email":true},
          "newsletter":null}'),
    (3, 'Вера',
        '{"address":{"city":"Казань","street":"Баумана"},
          "favorite_categories":["books","home"],
          "theme":"light"}'),
    (4, 'Глеб',
        '{"favorite_categories":[],
          "notifications":{"email":false,"sms":false}}');

-- ── События / логи ──────────────────────────────────────────────────────────
-- payload JSONB — разнородные документы (как строки лога API). Заложено:
--   • разные типы значений (для jsonb_typeof)
--   • вложенный объект meta (для jsonpath-предиката @? / @@)
CREATE TABLE events (
    id       INT PRIMARY KEY,
    payload  JSONB NOT NULL
);

INSERT INTO events (id, payload) VALUES
    (1, '{"event":"login","user":"Анна","ok":true}'),
    (2, '{"event":"purchase","user":"Борис","amount":74990,"items":1}'),
    (3, '{"event":"error","code":500,"path":"/api/orders","meta":{"retry":true,"attempts":3}}'),
    (4, '{"event":"error","code":404,"path":"/api/products","meta":{"retry":false,"attempts":1}}'),
    (5, '{"event":"logout","user":"Анна"}');
