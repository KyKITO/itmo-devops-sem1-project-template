#!/bin/bash

set -e

echo "Подготовка базы данных..."

# Переменные окружения
DB_HOST="localhost"
DB_PORT=5432
DB_USER="validator"
DB_PASSWORD="val1dat0r"
DB_NAME="project-sem-1"

export DB_PASSWORD

# Проверка доступности базы данных
echo "Проверяем доступность базы данных..."
if ! psql -U "$DB_USER" -h "$DB_HOST" -p "$DB_PORT" -d "$DB_NAME" -c "\\q" &> /dev/null; then
  echo "База данных $DB_NAME недоступна. Проверяем настройки..."
  
  # Проверка подключения с пользователем postgres
  echo "Пробуем подключиться как postgres..."
  DB_USER="postgres"
  if ! psql -U "$DB_USER" -h "$DB_HOST" -p "$DB_PORT" -c "\\q" &> /dev/null; then
    echo "Ошибка: Не удалось подключиться к базе данных как postgres."
    exit 1
  fi

  # Создаём пользователя и базу данных
  echo "Создаём пользователя и базу данных..."
  psql -U "$DB_USER" -h "$DB_HOST" -p "$DB_PORT" <<-EOSQL
    DO \$\$ BEGIN
      IF NOT EXISTS (SELECT FROM pg_catalog.DB_USER WHERE usename = 'validator') THEN
        CREATE USER validator WITH PASSWORD 'val1dat0r';
      END IF;
    END \$\$;

    DO \$\$ BEGIN
      IF NOT EXISTS (SELECT FROM pg_database WHERE datname = '${DB_NAME}') THEN
        CREATE DATABASE ${DB_NAME} OWNER validator;
      END IF;
    END \$\$;

    GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME} TO validator;
EOSQL
else
  echo "База данных $DB_NAME доступна. Ничего не требуется."
fi

# Проверка/создание таблицы
echo "Проверяем таблицу prices..."
DB_USER="validator"
psql -U "$DB_USER" -h "$DB_HOST" -p "$DB_PORT" -d "$DB_NAME" <<-EOSQL
  CREATE TABLE IF NOT EXISTS prices (
    product_id SERIAL PRIMARY KEY,
    id INT NOT NULL,
    name TEXT NOT NULL,
    category TEXT NOT NULL,
    price NUMERIC(10, 2) NOT NULL,
    created_at DATE NOT NULL
  );
EOSQL

echo "Подготовка базы данных завершена успешно."