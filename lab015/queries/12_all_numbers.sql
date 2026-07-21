-- Задача 12. Извлечь ВСЕ числа из свободного описания и собрать их по товару.
SET search_path TO lab015;

-- regexp_matches(..., 'g') — функция, возвращающая МНОЖЕСТВО (по строке на каждое
-- совпадение), поэтому её ставят во FROM (через LATERAL), а не в SELECT, иначе она
-- «размножит» строки запроса неявно. Шаблон '\d+(\.\d+)?' ловит и целые (128),
-- и дробные (6.1) числа как одно совпадение; (?:...) — группа без захвата.
-- WITH ORDINALITY нумерует совпадения → детерминированный порядок в string_agg.
SELECT
    p.id,
    p.name,
    p.note,
    count(*)                                   AS numbers_cnt,
    string_agg(m.arr[1], ', ' ORDER BY m.ord)  AS numbers
FROM products AS p,
     LATERAL regexp_matches(p.note, '\d+(?:\.\d+)?', 'g') WITH ORDINALITY AS m(arr, ord)
GROUP BY p.id, p.name, p.note
ORDER BY p.id;
