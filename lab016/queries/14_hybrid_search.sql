-- Задача 14. 🔥 Гибридный поиск «как в магазине»: FTS по описанию (ранг) + триграммы по названию (сходство), общий скор.
SET search_path TO lab016;

-- Реалистичный поиск комбинирует два сигнала:
--   • FTS по ОПИСАНИЮ — смысловая релевантность с учётом словоформ (ts_rank);
--   • триграммы по НАЗВАНИЮ — попадание слова в заголовок, устойчивое к опечаткам
--     (word_similarity; для «игори» вместо «игры» сходство всё равно ~0.33).
-- Товар попадает в выдачу, если сработал ЛЮБОЙ сигнал (FULL: LEFT JOIN + OR);
-- итоговый score = 10·ts_rank + word_similarity. На запрос «игры» видно, что
-- совпадение в названии поднимает «игровой ноутбук» и «игровую мышь» выше товаров,
-- где «игры» лишь в описании. Тай-брейкер по id — у товаров 6 и 8 score равны.
WITH q(raw) AS (
    VALUES ('игры'::text)
),
fts AS (   -- смысловая релевантность описания
    SELECT p.id,
           ts_rank(to_tsvector('russian', p.description),
                   plainto_tsquery('russian', (SELECT raw FROM q))) AS rank
    FROM products p
    WHERE to_tsvector('russian', p.description) @@ plainto_tsquery('russian', (SELECT raw FROM q))
),
trg AS (   -- сходство названия (порог 0.3), терпит опечатки
    SELECT p.id,
           word_similarity((SELECT raw FROM q), p.name) AS name_sim
    FROM products p
    WHERE word_similarity((SELECT raw FROM q), p.name) >= 0.3
)
SELECT
    p.id,
    p.name,
    round(COALESCE(f.rank, 0)::numeric, 4)      AS fts_rank,
    round(COALESCE(t.name_sim, 0)::numeric, 3)  AS name_sim,
    round((COALESCE(f.rank, 0) * 10 + COALESCE(t.name_sim, 0))::numeric, 4) AS score
FROM products p
LEFT JOIN fts f ON f.id = p.id
LEFT JOIN trg t ON t.id = p.id
WHERE f.id IS NOT NULL OR t.id IS NOT NULL
ORDER BY score DESC, p.id;
