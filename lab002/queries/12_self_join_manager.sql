-- Задача 12. Каждый сотрудник и имя его руководителя; директора тоже показать (self-join, LEFT).
SET search_path TO lab002;

-- employees соединяется сама с собой: e — «сотрудник», m — «руководитель».
-- LEFT JOIN нужен, чтобы сохранить директора (manager_id = NULL): у него пары
-- нет, но строку оставляем, а руководителя помечаем текстом.
SELECT
    e.name                                AS employee,
    e.position,
    COALESCE(m.name, '— (высшее звено)')  AS manager
FROM employees AS e
LEFT JOIN employees AS m  ON m.id = e.manager_id
ORDER BY e.id;
