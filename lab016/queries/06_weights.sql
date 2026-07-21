-- Задача 6. Веса setweight: совпадение в НАЗВАНИИ (вес A) важнее, чем в ОПИСАНИИ (вес D).
SET search_path TO lab016;

-- В столбце search_tsv название помечено весом 'A', описание — 'D' (см. init.sql).
-- ts_rank принимает массив весов {D,C,B,A}; здесь {0.1,0.2,0.4,1.0} — стандартный.
-- Запрос «клавиатура»: у товара 8 слово есть и в названии (A), и в описании (D) →
-- ранг высокий; у товара 10 «клавиатура» лишь в описании (D) → ранг в разы ниже.
-- Так «заголовок важнее тела» выражается численно.
SELECT
    p.id,
    p.name,
    round(
        ts_rank('{0.1,0.2,0.4,1.0}', p.search_tsv, plainto_tsquery('russian', 'клавиатура'))::numeric,
        5
    ) AS weighted_rank
FROM products p
WHERE p.search_tsv @@ plainto_tsquery('russian', 'клавиатура')
ORDER BY weighted_rank DESC, p.id;
