-- Задача 11. Один и тот же момент заказа — на настенных часах разных городов (AT TIME ZONE).
SET search_path TO lab014;
SET TIME ZONE 'UTC';   -- детерминизм: базовый вывод момента в UTC

-- created_at — это МОМЕНТ времени (timestamptz), одинаковый для всех на планете.
-- Как он выглядел на настенных часах конкретного города — показывает
-- «timestamptz AT TIME ZONE 'зона'» → timestamp без зоны (см. theory/01).
-- Зоны указаны ЯВНО, поэтому результат не зависит от пояса сессии — детерминирован.
-- Заказ 1 оформлен 2024-06-01 09:15 UTC: в Москве это 12:15 (+3), в Новосибирске
-- 16:15 (+7), в Нью-Йорке 05:15 (летом −4). Один момент — три «локальных» времени.
SELECT
    id,
    created_at                                    AS момент_utc,
    created_at AT TIME ZONE 'Europe/Moscow'       AS москва,
    created_at AT TIME ZONE 'Asia/Novosibirsk'    AS новосибирск,
    created_at AT TIME ZONE 'America/New_York'    AS нью_йорк
FROM orders
WHERE id IN (1, 6, 12)
ORDER BY id;
