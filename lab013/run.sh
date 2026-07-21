#!/usr/bin/env bash
# Прогон lab013: поднять БД, накатить схему, выполнить все запросы.
source "$(dirname "$0")/../.lib/common.sh"

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
run_lab "$LAB_DIR"
