# Script to switch postgresql server from slave to master / Скрипт переключения сервера postgresql с подчиненного в главный
![Screenshot](https://github.com/zaycevmain/promote_to_primary/blob/main/screen.png)

## Назначение / Purpose

(RU) Этот скрипт предназначен для "повышения" резервного сервера PostgreSQL (standby/replica) до основного (primary/master). Он автоматизирует процесс, необходимый для того, чтобы реплика перестала получать обновления от старого мастера и сама стала доступна для записи.

(EN) This script is designed to "promote" a PostgreSQL standby/replica server to a primary/master role. It automates the process required for a replica to stop following a former master server and become writable itself.

---

## Как использовать / How to Use

1.  **Скопируйте скрипт на сервер / Copy the script to the server**  
    (RU) Поместите файл `promote_to_primary.sh` на резервный (standby) сервер, который вы хотите сделать основным.
    (EN) Place the `promote_to_primary.sh` file on the standby server you wish to promote.

2.  **Дайте права на выполнение / Grant execute permissions**  
    ```bash
    chmod +x promote_to_primary.sh
    ```

3.  **Запустите скрипт / Run the script**  
    (RU) Запускать скрипт нужно от имени пользователя с правами `sudo`.  
    (EN) The script must be run by a user with `sudo` privileges.  
    ```bash
    sudo ./promote_to_primary.sh [PG_PORT]
    ```
    -   `[PG_PORT]` - (Опционально / Optional) Порт, на котором работает PostgreSQL. Если не указан, используется значение по умолчанию `5432`. / The port PostgreSQL is running on. If not specified, the default value `5432` is used.

---

## Что делает скрипт / What the Script Does

1.  **Определение пути к данным PostgreSQL / Determines PostgreSQL data path**  
    (RU) Скрипт автоматически находит каталог данных работающего кластера PostgreSQL.  
    (EN) The script automatically finds the data directory of the running PostgreSQL cluster.

2.  **Остановка сервиса PostgreSQL / Stops the PostgreSQL service**  
    (RU) Корректно останавливает сервис `postgresql`.  
    (EN) Gracefully stops the `postgresql` service.

3.  **Удаление файлов репликации / Deletes replication files**  
    (RU) Находит и удаляет файлы `standby.signal` (для PostgreSQL 12+) или `recovery.conf` (для старых версий) в каталоге данных PostgreSQL. Удаление этих файлов является ключевым шагом для "повышения" сервера.  
    (EN) Finds and deletes the `standby.signal` file (for PostgreSQL 12+) or the `recovery.conf` file (for older versions) within the PostgreSQL data directory. Deleting these files is the key step to promoting the server.

4.  **Запуск сервиса PostgreSQL / Starts the PostgreSQL service**  
    (RU) Запускает сервис `postgresql` снова. Теперь сервер запустится в режиме `primary`.  
    (EN) Starts the `postgresql` service again. The server will now start in primary mode.

5.  **Проверка статуса / Verifies the status**  
    (RU) После запуска скрипт подключается к серверу и выполняет команду `SELECT pg_is_in_recovery();`, чтобы убедиться, что сервер больше не находится в режиме восстановления (ожидаемый результат: `f` или `false`).  
    (EN) After starting, the script connects to the server and executes `SELECT pg_is_in_recovery();` to verify that the server is no longer in recovery mode (expected result: `f` or `false`).

6.  **Логирование / Logging**  
    (RU) Все действия и их результаты записываются в файл `promote_to_primary.log` в той же директории, где находится скрипт.  
    (EN) All actions and their results are logged to the `promote_to_primary.log` file in the same directory as the script. 
