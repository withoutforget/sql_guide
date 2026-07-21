#!/usr/bin/env bash
# Общие функции для run.sh всех лаб.
# Подключается из лабы так:
#   source "$(dirname "$0")/../.lib/common.sh"

set -euo pipefail

# ── Параметры подключения (совпадают с docker-compose.yml) ──────────────────
PG_CONTAINER="sql_guide_pg"
PG_USER="sql"
PG_DB="sql_guide"
COMPOSE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Цвета (если терминал их поддерживает)
if [ -t 1 ]; then
  BOLD="\033[1m"; DIM="\033[2m"; CYAN="\033[36m"; GREEN="\033[32m"; RESET="\033[0m"
else
  BOLD=""; DIM=""; CYAN=""; GREEN=""; RESET=""
fi

# psql внутри контейнера. Аргументы пробрасываются как есть.
psql_exec() {
  docker compose -f "$COMPOSE_DIR/docker-compose.yml" exec -T postgres \
    psql -U "$PG_USER" -d "$PG_DB" "$@"
}

# Поднять БД и дождаться готовности.
ensure_db() {
  echo -e "${DIM}» Проверяю PostgreSQL...${RESET}"
  docker compose -f "$COMPOSE_DIR/docker-compose.yml" up -d >/dev/null

  local tries=0
  until docker compose -f "$COMPOSE_DIR/docker-compose.yml" exec -T postgres \
        pg_isready -U "$PG_USER" -d "$PG_DB" >/dev/null 2>&1; do
    tries=$((tries + 1))
    if [ "$tries" -gt 30 ]; then
      echo "PostgreSQL не поднялся за отведённое время." >&2
      exit 1
    fi
    sleep 1
  done
  echo -e "${GREEN}✓ PostgreSQL готов${RESET}"
}

# Накатить схему из init.sql (в тихом режиме).
load_schema() {
  local dir="$1"
  echo -e "${DIM}» Накатываю схему (init.sql)...${RESET}"
  psql_exec -q -v ON_ERROR_STOP=1 < "$dir/init.sql"
  echo -e "${GREEN}✓ Схема и данные загружены${RESET}"
}

# Выполнить все запросы из queries/*.sql по порядку, печатая заголовок каждого.
# Заголовок берётся из первой строки файла вида: -- <текст задачи>
run_queries() {
  local dir="$1"
  local f title
  for f in "$dir"/queries/*.sql; do
    [ -e "$f" ] || continue
    title="$(head -n1 "$f" | sed 's/^--[[:space:]]*//')"
    echo
    echo -e "${BOLD}${CYAN}━━ $(basename "$f") ━━${RESET}"
    echo -e "${BOLD}$title${RESET}"
    echo
    psql_exec -q -v ON_ERROR_STOP=1 < "$f"
  done
}

# Полный прогон лабы: БД + схема + запросы.
run_lab() {
  local dir="$1"
  ensure_db
  load_schema "$dir"
  run_queries "$dir"
  echo
  echo -e "${GREEN}${BOLD}✓ Лаба прогнана целиком${RESET}"
}
