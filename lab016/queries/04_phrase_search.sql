-- Задача 4. Фразовый поиск: слова именно рядом и в нужном порядке (phraseto_tsquery / оператор <->).
SET search_path TO lab016;

-- phraseto_tsquery('russian','игровой ноутбук') → 'игров <-> ноутбук': леммы должны
-- идти ПОДРЯД в этом порядке. Это строже, чем plainto (там просто И без порядка):
-- «мощный ноутбук для игр» под фразу не подойдёт, а «игровой ноутбук» — да.
SELECT phraseto_tsquery('russian', 'игровой ноутбук') AS phrase_query;

-- Товары, где в описании стоит именно фраза «игровой ноутбук»:
SELECT id, name, description
FROM products
WHERE to_tsvector('russian', description) @@ phraseto_tsquery('russian', 'игровой ноутбук')
ORDER BY id;

-- Отзывы с той же фразой (оператор <-> можно писать и вручную в to_tsquery):
SELECT id, author, body
FROM reviews
WHERE to_tsvector('russian', body) @@ to_tsquery('russian', 'игровой <-> ноутбук')
ORDER BY id;
