-- Задача 5. Клиенты, которые есть только в онлайн-списке (и нет в офлайн-списке).
SET search_path TO lab003;

-- EXCEPT возвращает строки ПЕРВОГО запроса, которых НЕТ во втором (разность
-- множеств), и убирает дубликаты. EXCEPT несимметричен: online EXCEPT offline и
-- offline EXCEPT online — это разные ответы. Здесь берём «есть в онлайне, но нет
-- в офлайне» → Борис, Вера, Дарья.
SELECT email, name, city FROM online_customers
EXCEPT
SELECT email, name, city FROM offline_customers
ORDER BY email;
