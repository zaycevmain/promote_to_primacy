#!/bin/bash
set -e

# Скрипт для "повышения" резервного сервера PostgreSQL (standby) до основного (primary).
#
# Использование:
# ./promote_to_primary.sh [PG_PORT]
#
# [PG_PORT] - (опционально) порт PostgreSQL, по умолчанию 5432.

# --- Начало конфигурации ---
# Порт PostgreSQL. Использует первый аргумент командной строки или 5432 по умолчанию.
PG_PORT=${1:-5432}
# --- Конец конфигурации ---

LOG_FILE="promote_to_primary.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "=== Переводим сервер в режим PRIMARY ==="

# 1. Определить каталог данных до остановки сервера
PGDATA=$(sudo -u postgres psql -t -c "show data_directory;" | tr -d '[:space:]')
log "[ШАГ] Каталог данных: $PGDATA"

# 2. Остановить PostgreSQL
log "[ШАГ] Останавливаю PostgreSQL..."
sudo systemctl stop postgresql || sudo service postgresql stop

# 3. Подождать, пока сервер полностью остановится
sleep 2

# 4. Удалить/переименовать файлы репликации
for f in recovery.conf standby.signal recovery.signal; do
    if [ -f "$PGDATA/$f" ]; then
        log "[ШАГ] Удаляю $f"
        sudo rm -f "$PGDATA/$f"
    fi
done

# 5. Запустить PostgreSQL
log "[ШАГ] Запускаю PostgreSQL..."
sudo systemctl start postgresql || sudo service postgresql start

# 6. Проверить статус
sleep 2
IS_RECOVERY=$(sudo -u postgres psql -p "$PG_PORT" -c "SELECT pg_is_in_recovery();" -tA)
if [ "$IS_RECOVERY" = "f" ]; then
    log "[OK] Сервер успешно переведён в режим PRIMARY (master)."
else
    log "[ОШИБКА] Сервер всё ещё в режиме реплики! Проверьте логи PostgreSQL."
    exit 1
fi

log "=== Готово ===" 
