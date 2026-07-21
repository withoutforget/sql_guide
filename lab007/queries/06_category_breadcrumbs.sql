-- Задача 6. Полный путь («хлебные крошки») и уровень каждой категории.
SET search_path TO lab007;

-- Дерево категорий, но здесь копим путь не массивом id, а СТРОКОЙ имён — привычные
-- «хлебные крошки» вида «Электроника / Компьютеры / Ноутбуки». Механика та же:
--   ЯКОРЬ     — корневые категории (parent_id IS NULL), breadcrumb = имя, уровень 1;
--   РЕКУРСИЯ  — спускаемся к подкатегориям, дописывая ' / ' и имя ребёнка к пути
--               родителя (p.breadcrumb || ' / ' || c.name), level = level + 1.
-- Сортировка по breadcrumb выстраивает категории в естественном древовидном
-- порядке (каждая ветвь идёт целиком). level показывает глубину вложенности.
-- Ответ (фрагмент): «Электроника / Компьютеры / Комплектующие / Видеокарты» — 4-й
-- уровень; корневые «Дом и сад», «Электроника» — 1-й.
WITH RECURSIVE cats AS (
    SELECT id, name, 1 AS level, name::text AS breadcrumb
    FROM categories
    WHERE parent_id IS NULL
    UNION ALL
    SELECT c.id, c.name,
           p.level + 1,
           p.breadcrumb || ' / ' || c.name
    FROM cats p
    JOIN categories c ON c.parent_id = p.id
)
SELECT level, breadcrumb
FROM cats
ORDER BY breadcrumb;
