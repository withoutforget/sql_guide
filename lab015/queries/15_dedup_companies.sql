-- Задача 15. 🔥 Канонизация названий фирм и поиск дубликатов, «на глаз» разных, а по факту одинаковых.
SET search_path TO lab015;

-- Одна фирма записана по-разному: регистр, лишние пробелы, кавычки «», форма
-- собственности (ООО/ЗАО/АО). Приводим к канону цепочкой:
--   lower                          — регистр;
--   regexp_replace('[«»".]','','g')— выкинуть кавычки и точки;
--   regexp_replace('\s+',' ','g')  — схлопнуть пробелы;  btrim — обрезать края;
--   regexp_replace('^(ооо|...) ','')— срезать форму собственности в начале.
-- После этого «ООО Ромашка», «ооо  ромашка», «ООО «Ромашка»» и «Ромашка»
-- схлопываются в один канон 'ромашка' — их и ловит GROUP BY … HAVING count(*) > 1.
WITH canon AS (
    SELECT id, name,
           regexp_replace(
               btrim(regexp_replace(regexp_replace(lower(name), '[«»".]', '', 'g'),
                                    '\s+', ' ', 'g')),
               '^(ооо|оао|зао|ао|ип) ', '') AS canonical
    FROM companies
)
SELECT
    canonical,
    count(*)                             AS variants,
    string_agg(name, ' | ' ORDER BY id)  AS as_written
FROM canon
GROUP BY canonical
HAVING count(*) > 1
ORDER BY variants DESC, canonical;
