-- Задача 6. Цена со скидкой 10% и итог с НДС 20% через LATERAL (расчёт с переиспользованием).
SET search_path TO lab006;

-- Знакомимся с LATERAL на простом расчёте. Обычный элемент FROM независим и НЕ
-- видит колонок соседей. LATERAL это разрешает: подзапрос СПРАВА может ссылаться
-- на колонки таблиц СЛЕВА. Здесь первый LATERAL считает цену со скидкой из p.price
-- (ссылка на левую таблицу — это и есть «корреляция», как в коррелированных
-- подзапросах lab004), а ВТОРОЙ LATERAL переиспользует уже посчитанное d.discounted.
-- Так промежуточное значение вычисляется один раз и используется дальше — чего
-- нельзя сделать, повторно сославшись на псевдоним колонки в обычном SELECT.
-- Каждый подзапрос возвращает по одной строке, поэтому CROSS JOIN LATERAL просто
-- добавляет вычисленные колонки к строке товара.
SELECT p.name,
       p.price,
       d.discounted,
       calc.final_price
FROM products AS p
CROSS JOIN LATERAL (
    SELECT ROUND(p.price * 0.90, 2) AS discounted          -- ссылка на левую p.price
) AS d
CROSS JOIN LATERAL (
    SELECT ROUND(d.discounted * 1.20, 2) AS final_price     -- переиспользуем d.discounted
) AS calc
ORDER BY p.price DESC
LIMIT 6;
