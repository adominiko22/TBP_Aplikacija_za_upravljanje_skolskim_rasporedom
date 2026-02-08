#!/usr/bin/env bash
set -euo pipefail

# ==========================================================
# School Schedule – lokalno pokretanje projekta
# Automatizira:
#  - pripremu .env
#  - Python virtualno okruženje
#  - instalaciju Python ovisnosti
#  - kreiranje PostgreSQL korisnika i baze
#  - inicijalizaciju baze (schema + seed)
#  - pokretanje Flask aplikacije
#
# Testirano na Ubuntu Linux
# ==========================================================

# ---------- Konfiguracija baze ----------
DB_HOST="localhost"
DB_PORT="5432"
DB_NAME="school_db"
DB_USER="school_app"
DB_PASSWORD="school_app_pw"

RESET_SQL="sql/00_reset_all.sql"

# ---------- Provjere ----------
echo "==> Provjera preduvjeta"

command -v psql >/dev/null 2>&1 || { echo "ERROR: psql nije instaliran."; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo "ERROR: python3 nije instaliran."; exit 1; }

if [[ ! -f "requirements.txt" ]]; then
  echo "ERROR: requirements.txt nije pronađen. Pokreni skriptu iz root direktorija projekta."
  exit 1
fi

if [[ ! -f "$RESET_SQL" ]]; then
  echo "ERROR: Ne mogu pronaći $RESET_SQL."
  exit 1
fi

# ---------- .env ----------
echo "==> Priprema .env datoteke"

if [[ ! -f ".env" ]]; then
  cat > .env <<EOF
DATABASE_URL=postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}
ADMIN_PIN=1234
SECRET_KEY=dev-secret-change-me
EOF
  echo "Kreirana nova .env datoteka."
else
  echo ".env već postoji – preskačem."
fi

# ---------- Python virtual environment ----------
echo "==> Python virtualno okruženje"

if [[ ! -d ".venv" ]]; then
  python3 -m venv .venv
  echo "Virtualno okruženje .venv kreirano."
fi

# shellcheck disable=SC1091
source .venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# ---------- PostgreSQL: korisnik i baza ----------
echo "==> PostgreSQL inicijalizacija (potrebna sudo prava)"

sudo -u postgres psql -v ON_ERROR_STOP=1 <<SQL
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '${DB_USER}') THEN
    CREATE ROLE ${DB_USER} LOGIN PASSWORD '${DB_PASSWORD}';
  ELSE
    ALTER ROLE ${DB_USER} LOGIN PASSWORD '${DB_PASSWORD}';
  END IF;
END
\$\$;

DO \$\$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = '${DB_NAME}') THEN
    CREATE DATABASE ${DB_NAME} OWNER ${DB_USER};
  END IF;
END
\$\$;

GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME} TO ${DB_USER};
SQL

# ---------- Reset i seed baze ----------
echo "==> Reset i inicijalizacija baze podataka"

PGPASSWORD="${DB_PASSWORD}" psql \
  -h "${DB_HOST}" -p "${DB_PORT}" \
  -U "${DB_USER}" -d "${DB_NAME}" \
  -v ON_ERROR_STOP=1 \
  -f "${RESET_SQL}"

# ---------- Pokretanje Flask aplikacije ----------
echo "==> Pokretanje Flask aplikacije"
echo "Aplikacija će biti dostupna na: http://127.0.0.1:5000/"
echo "Admin sučelje: http://127.0.0.1:5000/admin"

python3 -m flask --app app.app run --debug
