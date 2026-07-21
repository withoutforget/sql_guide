-- Задача 15. 🔥 Дедуп брендов по нечёткому сходству: сгруппировать разные написания одного бренда (self-join по similarity).
SET search_path TO lab016;

-- Один бренд записан по-разному (регистр, пробелы, опечатки). Схлопываем их без
-- ручного словаря — по триграммному сходству. Приём:
--   self-join brands×brands по similarity ≥ 0.35 (порог с запасом ниже реального
--   минимума кластера 0.4, но выше «чужих» 0.18) → для каждого написания берём
--   МИНИМАЛЬНЫЙ id среди похожих как «канон» кластера. Затем группируем по канону.
-- «Сяоми» (иная транслитерация, сходство 0.18) и латиница отсеиваются в одиночки и
-- в дубликаты не попадают — это честная граница метода.
WITH canon AS (
    SELECT
        b.id,
        b.raw_name,
        MIN(o.id) AS canonical_id            -- канон = мин. id среди похожих (включая себя)
    FROM brands b
    JOIN brands o ON similarity(b.raw_name, o.raw_name) >= 0.35
    GROUP BY b.id, b.raw_name
)
SELECT
    canonical_id,
    count(*)                                    AS variants,
    string_agg(raw_name, ' | ' ORDER BY id)     AS spellings
FROM canon
GROUP BY canonical_id
HAVING count(*) > 1
ORDER BY variants DESC, canonical_id;
