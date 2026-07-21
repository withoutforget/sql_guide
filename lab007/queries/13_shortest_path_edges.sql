-- Задача 13. Кратчайший по числу пересадок маршрут из Москвы в Новосибирск.
SET search_path TO lab007;

-- Финал: «кратчайший путь» по ЧИСЛУ РЁБЕР (пересадок), а не по километрам. Считаем
-- все простые маршруты до Новосибирска (защита от цикла — путь-массивом, как в
-- задаче 11), в hops ведём число рёбер, а затем оставляем только маршруты с
-- МИНИМАЛЬНЫМ hops. Минимум берём скалярным подзапросом по тому же CTE — обычный
-- CTE можно использовать в запросе несколько раз (lab005); тут paths читается и в
-- FROM, и внутри (SELECT MIN(hops) ...). Оконных функций (которые дали бы тот же
-- эффект через ранжирование) здесь не используем — они в lab010.
-- В Новосибирск ведёт единственный «хвост» ...→Уфа→Екатеринбург→Новосибирск (2 ребра),
-- а к Уфе — два маршрута (через Казань за 3 ребра и через Нижний Новгород за 4),
-- поэтому кратчайший по числу рёбер — ровно один, в 3 + 2 = 5 рёбер.
-- Ответ: Москва → Казань → Самара → Уфа → Екатеринбург → Новосибирск (5 рёбер).
WITH RECURSIVE paths AS (
    SELECT from_city,
           to_city,
           ARRAY[from_city, to_city] AS path,
           1 AS hops
    FROM routes
    WHERE from_city = 'Москва'
    UNION ALL
    SELECT p.from_city,
           r.to_city,
           p.path || r.to_city,
           p.hops + 1
    FROM paths p
    JOIN routes r ON r.from_city = p.to_city
    WHERE NOT r.to_city = ANY(p.path)            -- защита от цикла
)
SELECT array_to_string(path, ' → ') AS route,
       hops AS edges
FROM paths
WHERE to_city = 'Новосибирск'
  AND hops = (SELECT MIN(hops) FROM paths WHERE to_city = 'Новосибирск')
ORDER BY route;
