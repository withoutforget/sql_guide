-- Задача 7. Подсветка совпадений: ts_headline вырезает фрагмент отзыва и выделяет найденные слова.
SET search_path TO lab016;

-- ts_headline(конфиг, текст, запрос, опции) возвращает КУСОК исходного текста
-- (не леммы!) с обёрнутыми совпадениями. Опции:
--   StartSel/StopSel — чем оборачивать совпадение (здесь « и »);
--   MaxWords/MinWords — размер фрагмента;
--   MaxFragments      — сколько отдельных кусков склеить (0 = один непрерывный).
-- Подсвечиваются все словоформы запроса «ноутбук игры»: ноутбук, ноутбуки, игры, игр.
SELECT
    r.id,
    r.author,
    ts_headline(
        'russian',
        r.body,
        plainto_tsquery('russian', 'ноутбук игры'),
        'StartSel=«, StopSel=», MaxWords=12, MinWords=4, MaxFragments=2, FragmentDelimiter= … '
    ) AS snippet
FROM reviews r
WHERE to_tsvector('russian', r.body) @@ plainto_tsquery('russian', 'ноутбук игры')
ORDER BY r.id;
