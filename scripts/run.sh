#!/bin/bash

echo "Запуск приложения..."
go run main.go &

echo "Ожидаем, пока сервер будет готов..."
for i in {1..5}; do
  if curl -s http://localhost:8080 &> /dev/null; then
    echo "Сервер успешно запущен и готов к работе."
    exit 0
  fi
  echo "Попытка $i: ждем сервер..."
  sleep 5
done

echo "Ошибка: сервер не запустился вовремя."
exit 1