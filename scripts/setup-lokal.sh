#!/usr/bin/env bash
# Setup sekali untuk jalan TANPA Docker (MySQL pakai Laragon yang sudah dinyalakan).
# Pakai: bash scripts/setup-lokal.sh   — lalu jalankan `npm start` di tiap folder app.
# Anggapan: Laragon terpasang di C:\laragon dan user root MySQL tanpa password (default Laragon).
set -euo pipefail
cd "$(dirname "$0")/.."
MYSQL_BIN=${MYSQL_BIN:-/c/laragon/bin/mysql/mysql-8.0.30-winx64/bin/mysql.exe}
set -a; source .env; set +a

echo "[1/4] pastikan database nilai_db ada"
"$MYSQL_BIN" -u root -h 127.0.0.1 -e "CREATE DATABASE IF NOT EXISTS nilai_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

echo "[2/4] install dependency tiap folder"
for app in gateway service-nilai service-transkrip database; do
  (cd "$app" && npm install --no-audit --no-fund >/dev/null)
done

echo "[3/4] salin schema Prisma ke tiap app + generate client (mengulang kerja Dockerfile)"
for app in gateway service-nilai service-transkrip; do
  mkdir -p "$app/prisma"
  cp database/prisma/schema.prisma "$app/prisma/schema.prisma"
  (cd "$app" && npx prisma generate >/dev/null)
done

echo "[4/4] migrasi tabel lalu seed data contoh"
(cd database && npx prisma migrate deploy >/dev/null)
(cd database && node --env-file=../.env prisma/seed.js)

echo
echo "Selesai. Buka 3 terminal, jalankan satu per satu:"
echo "  cd gateway           && npm start"
echo "  cd service-nilai     && npm start"
echo "  cd service-transkrip && npm start"
echo "Lalu tes: curl http://localhost:3000/health"
