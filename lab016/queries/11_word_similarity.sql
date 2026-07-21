-- Задача 11. Нечёткое вхождение слова в длинный текст: word_similarity против обычной similarity.
SET search_path TO lab016;

-- similarity(a, ДЛИННЫЙ_ТЕКСТ) почти всегда близка к нулю: триграммы короткого
-- слова «тонут» среди всех триграмм документа. Чтобы понять, есть ли слово ВНУТРИ
-- текста, нужен word_similarity(слово, текст) — он ищет наиболее похожий НЕПРЕРЫВНЫЙ
-- участок и меряет сходство только с ним. Оператор `слово <% текст` истинен, когда
-- word_similarity ≥ pg_trgm.word_similarity_threshold (по умолчанию 0.6).
-- Ищем слово «ноутбук» в описаниях: whole_sim крошечная у всех, а word_sim=1.0 там,
-- где слово реально есть (товары 1–3), и мала у остальных.
SELECT
    p.id,
    p.name,
    round(similarity('ноутбук', p.description)::numeric, 3)      AS whole_sim,
    round(word_similarity('ноутбук', p.description)::numeric, 3) AS word_sim,
    ('ноутбук' <% p.description)                                 AS found_in_text
FROM products p
ORDER BY word_sim DESC, p.id;
