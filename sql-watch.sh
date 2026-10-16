#!/bin/bash
# Runs inside the "sqlserver-watch" container (see docker-compose.yml).
# Every time you save a .sql file in scripts/, it deletes the database, creates it empty
# and runs scripts/*.sql inside it (in name order). The last run's output goes to scripts-run.log.
set -u
shopt -s nullglob

DB="${DB_NAME:-section_b}"
SCRIPTS=/work/scripts
LOG=/work/scripts-run.log
SQLCMD=(/opt/mssql-tools18/bin/sqlcmd -S sqlserver -U sa -P "$MSSQL_SA_PASSWORD" -C -b)

# Changes whenever a script is edited, added, renamed or removed
fingerprint() {
  local files=("$SCRIPTS"/*.sql)
  { printf '%s\n' "${files[@]}"; cat "${files[@]}" /dev/null; } | sha256sum | cut -d' ' -f1
}

# Fingerprint stored in the database by the last successful run (empty if none)
applied_fingerprint() {
  "${SQLCMD[@]}" -h -1 -W -Q "SET NOCOUNT ON;
    IF DB_ID('$DB') IS NOT NULL
      SELECT CAST(value AS varchar(64)) FROM [$DB].sys.extended_properties
      WHERE class = 0 AND name = 'scripts_fingerprint'" 2>/dev/null | tr -d '[:space:]'
}

run_scripts() {
  local fp=$1 files=("$SCRIPTS"/*.sql)
  if (( ${#files[@]} == 0 )); then
    echo "No .sql file in scripts/"
    return 1
  fi

  # Start from an empty database. ROLLBACK IMMEDIATE disconnects SSMS/apps using it.
  "${SQLCMD[@]}" -Q "
    IF DB_ID('$DB') IS NOT NULL BEGIN
      ALTER DATABASE [$DB] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
      DROP DATABASE [$DB];
    END
    CREATE DATABASE [$DB];" || return 1
  # Without this, ids jump by ~1000 (e.g. 3 -> 1002) after every server restart
  "${SQLCMD[@]}" -d "$DB" -Q "ALTER DATABASE SCOPED CONFIGURATION SET IDENTITY_CACHE = OFF" || return 1

  for f in "${files[@]}"; do
    echo "--- ${f##*/}"
    "${SQLCMD[@]}" -d "$DB" -W -s '|' -i "$f" || return 1
  done

  # Remember what was applied, so a restart doesn't rebuild (and wipe) an up-to-date database
  "${SQLCMD[@]}" -d "$DB" -Q "EXEC sys.sp_addextendedproperty N'scripts_fingerprint', N'$fp'" || return 1
}

rebuild() {
  {
    echo "=== $(date '+%Y-%m-%d %H:%M:%S')  rebuilding [$DB] from scripts/"
    if run_scripts "$1"; then
      echo "=== OK: [$DB] is ready"
    else
      echo "=== FAILED: fix the error above and save again"
    fi
  } 2>&1 | tee "$LOG"
}

echo "Waiting for SQL Server..."
until "${SQLCMD[@]}" -Q "SELECT 1" -o /dev/null 2>/dev/null; do sleep 2; done

last=$(fingerprint)
if [ "$last" != "$(applied_fingerprint)" ]; then
  rebuild "$last"
else
  echo "[$DB] already matches scripts/"
fi
echo "Watching scripts/ for changes..."

while sleep 1; do
  [ "$(fingerprint)" = "$last" ] && continue
  sleep 1 # let the editor finish writing the file
  last=$(fingerprint)
  rebuild "$last"
done
