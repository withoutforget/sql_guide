-- Задача 3. Показать разницу UNION ALL и UNION на одних данных (сравнить число строк).
SET search_path TO lab003;

-- В файле ДВА запроса подряд. Смотрите на строку-«итог» под каждой выборкой,
-- которую печатает psql: "(N rows)". Данные одни и те же, разница только в
-- операторе:
--   * UNION ALL — оставляет всё как есть            → (10 rows);
--   * UNION     — убирает дубликаты по всей строке   → (7 rows).
-- Три «лишние» строки, которые убрал UNION: повтор Анны (в обоих списках),
-- повтор Глеба (в обоих, включая NULL-город) и второй Егор (дубль внутри офлайна).

-- 1) со всеми повторами:
SELECT email, name, city FROM online_customers
UNION ALL
SELECT email, name, city FROM offline_customers;

-- 2) с устранением повторов:
SELECT email, name, city FROM online_customers
UNION
SELECT email, name, city FROM offline_customers;
