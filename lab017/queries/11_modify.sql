-- Задача 11. Изменение jsonb в ВЫРАЖЕНИИ (саму таблицу не меняем — это lab019).
SET search_path TO lab017;

-- Все операции возвращают НОВЫЙ jsonb, исходные данные не трогают:
--   ||               — слить объекты (правый перекрывает левый; слияние
--                      ПОВЕРХНОСТНОЕ — вложенные объекты заменяются целиком!),
--   jsonb_set(t,path,val,create_if_missing) — заменить/создать по пути,
--   - 'key'          — удалить ключ верхнего уровня,
--   jsonb_strip_nulls — убрать ключи со значением JSON null.
SELECT
    name,
    attributes                                        AS before,
    attributes || '{"warranty":24,"color":"чёрный"}'  AS after_merge,  -- добавить/заменить
    jsonb_set(attributes, '{ram}', '4', true)         AS after_set,    -- создать ram, т.к. create_if_missing
    attributes - 'wireless'                           AS after_drop,   -- удалить ключ
    jsonb_strip_nulls(attributes)                     AS after_strip   -- убрать warranty: null
FROM products
WHERE id = 10                                          -- «Мышь»: есть warranty: null
;

-- #- '{path}' удаляет по ПУТИ, в том числе элемент массива по индексу.
-- Уберём первый цвет у смартфона (colors[0]):
SELECT
    name,
    attributes -> 'colors'                    AS colors_before,
    (attributes #- '{colors,0}') -> 'colors'  AS colors_after
FROM products
WHERE id = 1;
