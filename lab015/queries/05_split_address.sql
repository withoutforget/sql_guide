-- Задача 5. Разобрать адрес «город, улица, дом» на отдельные части (split_part).
SET search_path TO lab015;

-- Все адреса записаны через разделитель ', ' (запятая + пробел), поэтому
-- split_part с этим разделителем аккуратно достаёт нужную часть по номеру.
SELECT
    id,
    address,
    split_part(address, ', ', 1) AS city,
    split_part(address, ', ', 2) AS street,
    split_part(address, ', ', 3) AS house
FROM clients
ORDER BY id;
