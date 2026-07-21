-- Задача 12. Мини-каталог: по категории — список «товар (цена)» от дорогих к дешёвым.
SET search_path TO lab009;

-- Комбинация коллекции с GROUP BY по категориям. string_agg склеивает не просто
-- имена, а выражение name || ' (' || цена || ')'. ORDER BY price DESC ВНУТРИ
-- агрегата упорядочивает список от дорогих к дешёвым — независимо от ORDER BY
-- всего запроса. Рядом — размах цен категории (min..max) для контекста.
SELECT
    category                                                    AS категория,
    count(*)                                                    AS товаров,
    min(price)                                                  AS дешевле_всех,
    max(price)                                                  AS дороже_всех,
    string_agg(name || ' (' || price::int || ' ₽)', ', '
               ORDER BY price DESC)                             AS каталог
FROM products
GROUP BY category
ORDER BY категория;
