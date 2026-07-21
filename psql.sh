#!/usr/bin/env bash
# Быстрый вход в интерактивный psql (REPL) внутри контейнера.
#
#   ./psql.sh              — открыть shell
#   ./psql.sh lab001       — открыть shell сразу в схеме lab001
#                            (search_path = lab001, public)
#
# Полезные команды внутри psql:
#   \dn            — список схем
#   \dt lab001.*   — таблицы схемы lab001
#   \d products    — структура таблицы
#   \x             — расширенный (вертикальный) вывод для широких строк
#   \timing on     — показывать время выполнения запросов
#   \e             — открыть последний запрос в редакторе
#   \q             — выйти
source "$(dirname "$0")/.lib/common.sh"

ensure_db

SCHEMA="${1:-}"
if [ -n "$SCHEMA" ]; then
  echo -e "${DIM}» search_path = ${SCHEMA}, public${RESET}"
  docker compose -f "$COMPOSE_DIR/docker-compose.yml" exec \
    -e PGOPTIONS="--search_path=${SCHEMA},public" \
    postgres psql -U "$PG_USER" -d "$PG_DB"
else
  docker compose -f "$COMPOSE_DIR/docker-compose.yml" exec \
    postgres psql -U "$PG_USER" -d "$PG_DB"
fi
