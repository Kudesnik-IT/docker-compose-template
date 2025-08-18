# apps/sample/Dockerfile
# Минимальный сервис-шаблон: запускает HTTP-сервер на порту 8000
# Можно использовать как основу для нового сервиса

FROM alpine:latest

# Метаданные
LABEL maintainer="dev-team"
LABEL service="sample-service"
LABEL description="Minimal template service. Rename and customize for your needs."

# Установка Python (для простого HTTP-сервера)
RUN apk add --no-cache python3

# Создание простого HTML-файла (вместо src/)
RUN mkdir -p /app && \
    echo "<h1>Sample Service is Running!</h1><p>Port: 8000</p><p>Env: ${APP_ENV:-development}</p>" > /app/index.html

# Рабочая директория
WORKDIR /app

# Переменная окружения (можно переопределить в docker-compose)
ENV APP_ENV=development

# Команда: запуск простого HTTP-сервера на порту 8000
EXPOSE 8000

CMD python3 -m http.server 8000
