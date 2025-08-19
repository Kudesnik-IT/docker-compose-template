# Makefile — Управление Docker Compose проектом
#
# Использует:
#   --env-file .env                 -> общие переменные
#   --env-file docker/.env/environments/*.env -> окружение (dev, prod, ...)
#
# Переменные для приложений передаются через `env_file` в compose-файлах

.PHONY: up down dev prod test logs build clean help

# ===================================
# Основные команды
# ===================================

# Запуск базовой конфигурации (без override)
# Использует только .env (например, для локального запуска без dev/prod различий)
up:
	docker compose \
		--env-file .env \
		-f compose.yaml \
		up -d

# Остановка всех сервисов
down:
	docker compose \
		--env-file .env \
		-f compose.yaml \
		down

# Пересборка и запуск (без override)
up-rebuild:
	docker compose \
		--env-file .env \
		-f compose.yaml \
		up -d --build --force-recreate

# ===================================
# Режимы окружения
# ===================================

# Запуск в режиме разработки
# Подключает .env + .env.dev
dev:
	docker compose \
		--env-file .env \
		--env-file docker/.env/environments/.env.dev \
		-f compose.yaml \
		-f docker/compose.dev.yaml \
		up -d --build

# Запуск в продакшене
# Подключает .env + .env.prod
prod:
	docker compose \
		--env-file .env \
		--env-file docker/.env/environments/.env.prod \
		-f compose.yaml \
		-f docker/compose.prod.yaml \
		up -d --build

# Запуск тестов
# Использует compose.test.yaml
test:
	docker compose \
		--env-file .env \
		--env-file docker/.env/environments/.env.test \
		-f compose.yaml \
		-f tests/compose.test.yaml \
		up --abort-on-container-exit

# ===================================
# Дополнительные команды
# ===================================

# Только сборка (без запуска)
build:
	docker compose \
		--env-file .env \
		-f compose.yaml \
		build

# Сборка с пересозданием (для dev)
build-dev:
	docker compose \
		--env-file .env \
		--env-file docker/.env/environments/.env.dev \
		-f compose.yaml \
		-f docker/compose.dev.yaml \
		build --no-cache

# Просмотр логов
logs:
	docker compose \
		--env-file .env \
		-f compose.yaml \
		logs -f

# Логи в режиме разработки (с учётом override)
logs-dev:
	docker compose \
		--env-file .env \
		--env-file docker/.env/environments/.env.dev \
		-f compose.yaml \
		-f docker/compose.dev.yaml \
		logs -f

# Просмотр состояния
ps:
	docker compose \
		--env-file .env \
		-f compose.yaml \
		ps

# Очистка: остановка + удаление контейнеров, сетей
clean:
	docker compose \
		--env-file .env \
		-f compose.yaml \
		down --volumes --remove-orphans

# Полная очистка: + удаление образов
clean-all: clean
	docker compose \
		--env-file .env \
		-f compose.yaml \
		down --volumes --rmi all --remove-orphans

# ===================================
# Справка
# ===================================

help:
	@echo ""
	@echo "=== Управление проектом ==="
	@echo "  make up           — Запуск базовой конфигурации"
	@echo "  make down         — Остановка"
	@echo "  make up-rebuild   — Пересборка и запуск"
	@echo ""
	@echo "  make dev          — Запуск в режиме разработки"
	@echo "  make prod         — Запуск в продакшене"
	@echo "  make test         — Запуск тестов"
	@echo ""
	@echo "  make build        — Сборка образов"
	@echo "  make build-dev    — Сборка с кэшем (dev)"
	@echo ""
	@echo "  make logs         — Логи"
	@echo "  make logs-dev     — Логи (с override)"
	@echo "  make ps           — Состояние сервисов"
	@echo ""
	@echo "  make clean        — Очистка (контейнеры, сети)"
	@echo "  make clean-all    — Очистка + удаление образов"
	@echo ""
	@echo "  make help         — Показать эту справку"
	@echo ""
