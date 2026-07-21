-- Задача 12. 🔥 Клиенты, зарегистрированные РОВНО в одном канале (симметрическая разность).
SET search_path TO lab003;

-- «Ровно в одном из двух» = «в онлайне, но не в офлайне» ПЛЮС «в офлайне, но не в
-- онлайне». На языке множеств это симметрическая разность:
--     (online EXCEPT offline)  UNION  (offline EXCEPT online).
-- Скобки нужны: UNION и EXCEPT имеют ОДИН приоритет и считаются слева направо,
-- поэтому без скобок «A EXCEPT B UNION C EXCEPT D» превратилось бы в
-- «((A EXCEPT B) UNION C) EXCEPT D» — совсем не то. Скобки задают: сначала обе
-- разности по отдельности, потом их объединение.
-- Клиенты обоих каналов (Анна, Глеб) сюда НЕ попадают — они в пересечении.
-- Итог: Борис, Вера, Дарья (только онлайн) + Егор, Жанна (только офлайн).
-- Ремарка про дедуп: две ветки-разности заведомо НЕ пересекаются и уже
-- продедуплены самим EXCEPT, поэтому UNION здесь дубликатов не найдёт — UNION ALL
-- дал бы тот же результат дешевле. UNION оставлен как каноничная запись A\B ∪ B\A.
(
    SELECT email, name, city FROM online_customers
    EXCEPT
    SELECT email, name, city FROM offline_customers
)
UNION
(
    SELECT email, name, city FROM offline_customers
    EXCEPT
    SELECT email, name, city FROM online_customers
)
ORDER BY email;
