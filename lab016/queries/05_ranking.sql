-- Задача 5. Ранжирование отзывов по релевантности запросу «ноутбук»: ts_rank и ts_rank_cd, топ по рангу.
SET search_path TO lab016;

-- ts_rank(vector, query) оценивает релевантность документа запросу: чем чаще
-- встречается лемма и чем «весомее» её позиции, тем выше ранг. ts_rank_cd (cover
-- density) дополнительно учитывает БЛИЗОСТЬ найденных слов друг к другу.
-- Отзыв 1 упоминает «ноутбук» трижды → самый высокий ранг; отзыв 3 (про «игры»,
-- без «ноутбук») в выдачу не попадает вовсе. round(...) — только для читаемости.
-- Тай-брейкер по id обязателен: у отзывов 5 и 8 ранги равны.
SELECT
    r.id,
    r.author,
    round(ts_rank   (to_tsvector('russian', r.body), plainto_tsquery('russian', 'ноутбук'))::numeric, 4) AS rank,
    round(ts_rank_cd(to_tsvector('russian', r.body), plainto_tsquery('russian', 'ноутбук'))::numeric, 4) AS rank_cd
FROM reviews r
WHERE to_tsvector('russian', r.body) @@ plainto_tsquery('russian', 'ноутбук')
ORDER BY rank DESC, r.id;
