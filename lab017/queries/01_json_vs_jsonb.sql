-- Задача 1. json vs jsonb: дедупликация ключей, порядок, пробелы, jsonb_typeof.
SET search_path TO lab017;

-- Один и тот же текст, приведённый к json и к jsonb, ведёт себя ПО-РАЗНОМУ:
--   • json  — хранит текст «как есть»: пробелы, порядок ключей и ДУБЛИ ключей;
--   • jsonb — разбирает в бинарное дерево: убирает лишние пробелы, сортирует
--     ключи и ДЕДУПЛИЦИРУЕТ их (при дубле остаётся последний: "a":3 победил).
SELECT
    '{"b": 1,   "a": 2, "a": 3}'::json  AS as_json,   -- как ввели
    '{"b": 1,   "a": 2, "a": 3}'::jsonb AS as_jsonb;  -- нормализовано → {"a":3,"b":1}

-- Внутри JSON бывает ровно 6 типов значений. jsonb_typeof показывает тип КОРНЯ.
-- Обратите внимание на 'null': это JSON null — значение внутри документа,
-- и это НЕ то же самое, что SQL NULL (отсутствие значения).
SELECT
    jsonb_typeof('{"x":1}')  AS t_object,
    jsonb_typeof('[1,2,3]')  AS t_array,
    jsonb_typeof('"текст"')  AS t_string,
    jsonb_typeof('42')       AS t_number,
    jsonb_typeof('true')     AS t_boolean,
    jsonb_typeof('null')     AS t_null;
