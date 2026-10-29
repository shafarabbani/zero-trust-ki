#!/usr/bin/env bash
# Util demo: menampilkan 20 keputusan terakhir dari tabel audit_logs (kebutuhan 4.4).
# Mode lokal (tanpa Docker): pakai MySQL Laragon; override path lewat env MYSQL_BIN bila perlu.
set -euo pipefail
cd "$(dirname "$0")/.."
set -a; source .env; set +a
MYSQL_BIN=${MYSQL_BIN:-/c/laragon/bin/mysql/mysql-8.0.30-winx64/bin/mysql.exe}
"$MYSQL_BIN" -u root -h 127.0.0.1 nilai_db -e \
  "SELECT created_at, subject_type, subject_id, role, method, endpoint, device_id, decision, reason FROM audit_logs ORDER BY id DESC LIMIT 20;"
