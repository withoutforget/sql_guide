-- Задача 1. Длина названий: символы (length) против байтов (octet_length) на кириллице и латинице.
SET search_path TO lab015;

-- На UTF-8 кириллическая буква = 2 байта, латинская = 1. Поэтому у названий с
-- кириллицей length (символы) и octet_length (байты) расходятся, у чисто
-- латинских ('iPhone 15') — совпадают.
SELECT
    name,
    length(name)                      AS chars,          -- сколько СИМВОЛОВ видит человек
    octet_length(name)                AS bytes,           -- сколько БАЙТОВ занимает в UTF-8
    octet_length(name) - length(name) AS cyrillic_bytes  -- «лишние» байты = число кириллических букв
FROM products
ORDER BY octet_length(name) DESC, id;
