-- Задача 13. 🔥 Пары сотрудников-коллег (с общим непосредственным руководителем).
SET search_path TO lab002;

-- Изюм: соединяем employees саму с собой по НЕ-ключевой колонке manager_id
-- (у коллег общий начальник). Два приёма против мусора:
--   * e1.id < e2.id  — убирает и «сам с собой», и дубли-зеркала (пара A–B и B–A);
--   * третий JOIN к employees (m) достаёт имя общего руководителя.
SELECT
    e1.name  AS colleague_1,
    e2.name  AS colleague_2,
    m.name   AS manager
FROM employees AS e1
JOIN employees AS e2  ON e2.manager_id = e1.manager_id
                     AND e1.id < e2.id
JOIN employees AS m   ON m.id = e1.manager_id
ORDER BY m.name, e1.name;
