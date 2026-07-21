# 07 — Временные ряды: `generate_series`, gap-filling, окна, бизнес-календарь

[← арифметика и `age`](06-arithmetic.md) · [оглавление](../README.md)

---

Это кульминация темы. Аналитические вопросы про время почти всегда сводятся к
**временному ряду**: значение на каждый день/неделю/месяц. Главная трудность — не
посчитать сумму, а **не потерять периоды, в которых ничего не было**. Здесь
собираем воедино `generate_series` (из [lab006](../../lab006/)), оконные функции
(из [lab011](../../lab011/)) и датные функции этой лабы.

## Проблема «дыр» в ряду

Наивная группировка выкидывает пустые периоды:

```sql
SELECT date_trunc('day', created_at)::date AS day, count(*) AS orders
FROM orders
GROUP BY 1 ORDER BY 1;
```

В результат попадут **только те дни, где были заказы**. Дни без заказов просто
отсутствуют — в графике будет провал, «вчера/сегодня» посчитается неверно, а
скользящее среднее и running total собьются, потому что ряд неравномерный. Нужен
**сплошной** ряд — с нулями на пустых днях. Это называется **gap-filling**
(заполнение пропусков).

## Шаг 1: каркас календаря через `generate_series`

`generate_series` с шагом-интервалом порождает **все** точки ряда, включая пустые
(подробно — lab006):

```sql
SELECT d::date AS day
FROM generate_series(date '2024-06-01', date '2024-06-30', interval '1 day') AS g(d);
--   30 строк: 2024-06-01, 2024-06-02, …, 2024-06-30 — КАЖДЫЙ день
```

Границы включаются обе (`[start, stop]`). Шаг может быть любым интервалом:
`interval '1 day'`, `'1 week'`, `'1 month'`, `'15 minutes'`. `generate_series`
возвращает `timestamp`/`timestamptz` — при необходимости приводим `::date`.

## Шаг 2: `LEFT JOIN` фактов на каркас

Ключевой приём: календарь — **слева**, факты — справа через `LEFT JOIN`. Дни без
фактов сохраняются (это суть `LEFT JOIN`), а агрегаты на них дают честные нули:

```sql
SELECT cal.d::date                       AS day,
       count(o.id)                       AS orders_cnt,     -- 0 в пустой день
       coalesce(sum(o.amount), 0)        AS revenue         -- 0, а не NULL
FROM generate_series(date '2024-06-01', date '2024-06-30', interval '1 day') AS cal(d)
LEFT JOIN orders o
       ON o.created_at >= cal.d
      AND o.created_at <  cal.d + interval '1 day'   -- заказ попал в этот день?
GROUP BY cal.d
ORDER BY cal.d;
```

Разбор:

- `count(o.id)` считает **только не-NULL** `o.id` — в день без заказов `LEFT JOIN`
  подставил `NULL`, и счётчик даёт `0` (а не 1). Это важнее, чем кажется:
  `count(*)` посчитал бы саму строку календаря и вернул бы `1` в пустой день —
  **ошибка**. Считайте `count(колонки_из_правой_таблицы)`.
- `coalesce(sum(...), 0)` превращает `NULL`-сумму пустого дня в `0` (агрегат по
  пустому набору даёт `NULL`, см. lab001).
- Условие соединения — **полуоткрытый интервал** `>= d AND < d+1day` (файл 06):
  ловит любое время суток и работает для `timestamptz` без «магии» 23:59:59.

Теперь в результате **все** 30 дней июня, у пустых — нули. Это и есть gap-filling.

## Шаг 3: окна поверх сплошного ряда

Оконные функции ([lab011](../../lab011/)) на ряду **без дыр** работают правильно —
«предыдущий день» действительно предыдущий, running total накапливается через нули,
скользящее среднее считается по равным интервалам:

```sql
WITH daily AS (
    SELECT cal.d::date               AS day,
           coalesce(sum(o.amount),0) AS revenue
    FROM generate_series(date '2024-06-01', date '2024-06-30', interval '1 day') AS cal(d)
    LEFT JOIN orders o ON o.created_at >= cal.d
                      AND o.created_at <  cal.d + interval '1 day'
    GROUP BY cal.d
)
SELECT day,
       revenue,
       sum(revenue) OVER (ORDER BY day)                              AS running_total,
       round(avg(revenue) OVER (ORDER BY day
                                ROWS BETWEEN 6 PRECEDING
                                         AND CURRENT ROW), 0)         AS ma7,
       revenue - lag(revenue) OVER (ORDER BY day)                    AS vs_prev_day
FROM daily
ORDER BY day;
```

Почему сплошной ряд обязателен для окон: `lag(revenue) OVER (ORDER BY day)` берёт
**предыдущую строку ряда**. Если в ряду не хватает пустых дней, «предыдущей» окажется
не вчера, а последний непустой день — и «рост день-к-дню» соврёт. То же с рамкой
`ROWS BETWEEN 6 PRECEDING` — «6 строк назад» должно означать «6 дней назад», а это
верно только когда каждая строка = один день. **Сначала выравниваем ряд (gap-fill),
потом применяем окна.**

## То же для месяцев: непрерывный ряд и MoM

Пропущенный **месяц** так же обязан появиться нулём — иначе рост «месяц-к-месяцу»
(MoM) сравнит не те месяцы. Каркас — `generate_series` с шагом `'1 month'`:

```sql
WITH months AS (
    SELECT m::date AS month_start
    FROM generate_series(date '2024-06-01', date '2024-09-01', interval '1 month') AS g(m)
),
rev AS (
    SELECT ms.month_start,
           coalesce(sum(o.amount), 0) AS revenue
    FROM months ms
    LEFT JOIN orders o ON o.created_at >= ms.month_start
                      AND o.created_at <  ms.month_start + interval '1 month'
    GROUP BY ms.month_start
)
SELECT to_char(month_start, 'YYYY-MM')                       AS month,
       revenue,
       lag(revenue) OVER (ORDER BY month_start)              AS prev,
       round(100.0 * (revenue - lag(revenue) OVER (ORDER BY month_start))
             / nullif(lag(revenue) OVER (ORDER BY month_start), 0), 1) AS mom_pct
FROM rev
ORDER BY month_start;
```

Если в данных заказы есть в июне, июле и сентябре, а в **августе — нет**, то без
сплошного ряда `lag` в сентябре взял бы июль (август «съелся») и показал неверный
рост. На непрерывном ряду август появляется строкой `revenue = 0`, сентябрь
корректно сравнивается с ним, а `nullif(prev, 0)` спасает от деления на ноль, когда
предыдущий месяц был нулевым. Это задача 16 (🔥) — самый ценный вывод темы: **ряд
выравнивают до применения окон.**

## Бизнес-календарь

Частые календарные вычисления — на скалярных датных функциях, без справочников:

```sql
-- первый день месяца:
date_trunc('month', d)::date
-- последний день месяца:
(date_trunc('month', d) + interval '1 month' - interval '1 day')::date
-- число дней в месяце:
extract(day FROM (date_trunc('month', d) + interval '1 month' - interval '1 day'))
-- сколько дней осталось до конца месяца:
(date_trunc('month', d) + interval '1 month' - interval '1 day')::date - d
-- выходной ли день (суббота/воскресенье):
extract(isodow FROM d) IN (6, 7)
-- начало ISO-недели (понедельник):
date_trunc('week', d)::date
```

«Последний день месяца» строят как **начало следующего месяца минус один день** —
это автоматически учитывает 28/29/30/31 день и високосный год (`31.01`→`29.02` в
2024). В задаче 9 собираем эти вычисления, в задаче 15 (🔥) — «тепловую карту»
активности: сплошной календарь + день недели + пометка выходных + число заказов.

> **Рабочие дни без справочника праздников.** Отличить будни от выходных легко
> (`isodow IN (6,7)`). А вот учесть **праздники** (перенос выходных, нерабочие дни) —
> нельзя вычислить из календаря: нужна **таблица праздников** конкретной страны/года,
> и «рабочие дни» считаются как «будни минус праздники». Это уже вопрос модели
> данных, не датных функций.

## Сессии: склейка событий по времени (island-and-gap)

Ещё один типовой временной приём — **сгруппировать события в сессии**: соседние
события одного пользователя относятся к одной сессии, если между ними меньше порога
(скажем, 30 минут), иначе начинается новая. Решается ровно пройденным — `lag` по
времени + флаг новой сессии + кумулятивная сумма флага (это «острова и промежутки»
из lab011/lab012, но по времени):

```sql
WITH marked AS (
    SELECT customer_id, event_at,
           event_at - lag(event_at) OVER (PARTITION BY customer_id
                                          ORDER BY event_at) AS gap
    FROM events
),
flagged AS (
    SELECT customer_id, event_at,
           CASE WHEN gap IS NULL OR gap >= interval '30 min'
                THEN 1 ELSE 0 END AS is_new_session
    FROM marked
)
SELECT customer_id, event_at,
       sum(is_new_session) OVER (PARTITION BY customer_id
                                 ORDER BY event_at) AS session_no
FROM flagged
ORDER BY customer_id, event_at;
```

Как работает:

1. `gap` = разница с предыдущим событием того же клиента (`interval`); у первого
   события клиента `lag` даёт `NULL`.
2. `is_new_session` = 1, если это первое событие (`gap IS NULL`) **или** пауза
   `>= 30 мин`; иначе 0.
3. Кумулятивная сумма флагов `sum(...) OVER (... ORDER BY event_at)` — это и есть
   **номер сессии**: он увеличивается ровно там, где начинается новая сессия, и
   держится постоянным внутри одной. Порог сравниваем прямо с `interval '30 min'` —
   интервалы сравнимы между собой.

Дальше по `(customer_id, session_no)` можно группировать: длительность сессии,
число событий, была ли покупка и т. п.

## Бакетирование по 15 минут

Для равномерной сетки времени (не по дням, а по 15-минуткам) — `date_bin` из
[файла 04](04-extract-trunc-bin.md):

```sql
SELECT date_bin(interval '15 min', event_at, timestamptz '2024-06-15 00:00:00+00') AS bucket,
       count(*) AS events
FROM events
GROUP BY 1 ORDER BY 1;
```

Каждое событие сворачивается к левой границе своей 15-минутной корзины; группировка
по `bucket` даёт «профиль активности» по четвертям часа (задача 12).

## Итог темы

1. **Ось времени строим сами** — `generate_series` даёт сплошной каркас без дыр.
2. **Факты приклеиваем `LEFT JOIN`** — пустые периоды сохраняются, `count`/
   `coalesce(sum,0)` дают нули.
3. **Окна — поверх выровненного ряда** — running total, MA, LAG/MoM считаются верно
   только без дыр.
4. **Календарь — на скалярных функциях** — границы месяца, выходные, недели.
5. Порог/паузу выражаем **интервалом** и сравниваем напрямую (`gap >= interval '30
   min'`).

## Документация

- Функции, возвращающие множества: `generate_series` (рус.):
  <https://postgrespro.ru/docs/postgresql/16/functions-srf>
- Функции даты/времени (рус.):
  <https://postgrespro.ru/docs/postgresql/16/functions-datetime>
- Оконные функции (рус.):
  <https://postgrespro.ru/docs/postgresql/16/tutorial-window> — и подробно в [lab011](../../lab011/).

---

[← арифметика и `age`](06-arithmetic.md) · [оглавление](../README.md)
