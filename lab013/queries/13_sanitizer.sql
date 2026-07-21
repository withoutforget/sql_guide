-- Задача 13. 🔥 Санитайзер импорта: привести валидные строки, битые НЕ уронить запрос.
SET search_path TO lab013;

-- Задача: пройти по ВСЕЙ «сырой» таблице (и валидные, и битые строки), привести
-- числа-как-текст к numeric/int, посчитать сумму позиции — и при этом НЕ упасть
-- на строках вроде 'бесплатно', '' или 'нет'.
-- Приём: приведение обёрнуто в CASE, который выполняет ::numeric ТОЛЬКО когда
-- is_valid = true. CASE гарантированно вычисляет лишь выбранную ветку, поэтому
-- на битых строках приведение просто не запускается — ошибки нет (регулярные
-- выражения для отсева мусора здесь не нужны; они — тема lab015).
-- Общий итог по валидным считаем оконной суммой (одно значение на все строки).
SELECT
    id,
    source_name,
    price_text,
    qty_text,
    CASE WHEN is_valid THEN price_text::numeric               END AS price,
    CASE WHEN is_valid THEN price_text::numeric * qty_text::int END AS line_total,
    CASE WHEN is_valid THEN 'принято' ELSE 'отброшено (не число)' END AS status,
    -- контрольный итог: сумма line_total по валидным строкам (одинаков во всех строках)
    sum(CASE WHEN is_valid THEN price_text::numeric * qty_text::int ELSE 0 END) OVER () AS grand_total_valid
FROM raw_import
ORDER BY is_valid DESC, id;
