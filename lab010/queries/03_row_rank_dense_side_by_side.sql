-- Задача 3. ROW_NUMBER vs RANK vs DENSE_RANK бок о бок: в чём разница на НИЧЬИХ.
SET search_path TO lab010;

-- Три ранжирующие функции почти одинаковы, пока нет равных значений. Разница видна
-- ТОЛЬКО на ничьих. В данных заложены две: Электроника (Планшет = Наушники = 30000)
-- и Дом (Робот-пылесос = Кофеварка = 24000). Смотрим все три ранга рядом:
--   row_number — уникальный номер 1..n (равным строкам — РАЗНЫЕ номера);
--   rank       — с пропусками: равные делят ранг, следующий "перепрыгивает" (…2,2,4);
--   dense_rank — плотный, без пропусков (…2,2,3).
-- ВАЖНО про детерминизм: доводчик ", p.id" стои́т ТОЛЬКО у row_number — чтобы его
-- уникальная нумерация была стабильной. У rank/dense_rank доводчика НЕТ намеренно:
-- добавь его — строки перестанут быть равными, и ничья ИСЧЕЗНЕТ (стало бы 1,2,3,4).
-- В Книгах и Игрушках ничьих нет — там все три функции совпадают (это и подтверждает,
-- что различаются они исключительно на равных значениях).
SELECT
    c.name                                                              AS категория,
    p.name                                                              AS товар,
    p.revenue                                                           AS выручка,
    row_number() OVER (PARTITION BY c.name ORDER BY p.revenue DESC, p.id) AS row_number,
    rank()       OVER (PARTITION BY c.name ORDER BY p.revenue DESC)       AS rank,
    dense_rank() OVER (PARTITION BY c.name ORDER BY p.revenue DESC)       AS dense_rank
FROM products  AS p
JOIN categories AS c ON c.id = p.category_id
ORDER BY c.name, p.revenue DESC, p.id;
