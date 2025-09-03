# Makefile — Управление Docker Compose проектом
#
# Использует:
#   --env-file .env                 -> общие переменные
#   --env-file docker/.env/environments/*.env -> окружение (dev, prod, ...)
#
# Переменные для приложений передаются через `env_file` в compose-файлах

# ===================================
# Цвета для вывода
# ===================================
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[1;34m
MAGENTA := \033[1;35m   # Пурпурный для лучшей видимости
CYAN := \033[1;36m
NC := \033[0m # No Color

# ===================================
# Основные цели
# ===================================
.PHONY: default help

# По умолчанию показываем помощь
default: help

# ===================================
# Проверки
# ===================================
.PHONY: check-env check-env-dev check-env-prod

check-env:
	@test -f .env || (echo "$(RED)❌ Файл .env не найден!$(NC)" && exit 1)
	@echo "$(GREEN)✅ Основной .env файл найден$(NC)"

check-env-dev:
	@test -f docker/.env/environments/.env.dev || (echo "$(RED)❌ Файл .env.dev не найден!$(NC)" && exit 1)
	@echo "$(GREEN)✅ .env.dev файл найден$(NC)"

check-env-prod:
	@test -f docker/.env/environments/.env.prod || (echo "$(RED)❌ Файл .env.prod не найден!$(NC)" && exit 1)
	@echo "$(GREEN)✅ .env.prod файл найден$(NC)"

# ===================================
# Основные команды
# ===================================
.PHONY: up down stop restart build clean

# Запуск базовой конфигурации (без override)
up: check-env
	@echo "$(BLUE)🚀 Запуск базовой конфигурации...$(NC)"
	docker compose \
		--env-file .env \
		-f compose.yaml \
		up -d
	@echo "$(GREEN)✅ Базовая конфигурация запущена$(NC)"

# Остановка всех сервисов
down: check-env
	@echo "$(YELLOW)🛑 Остановка всех сервисов...$(NC)"
	docker compose \
		--env-file .env \
		-f compose.yaml \
		down
	@echo "$(GREEN)✅ Все сервисы остановлены$(NC)"

# Остановка без удаления контейнеров
stop: check-env
	@echo "$(YELLOW)⏸️ Остановка сервисов (без удаления)...$(NC)"
	docker compose \
		--env-file .env \
		-f compose.yaml \
		stop
	@echo "$(GREEN)✅ Сервисы остановлены$(NC)"

# Перезапуск сервисов
restart: down up
	@echo "$(GREEN)✅ Сервисы перезапущены$(NC)"

# Пересборка и запуск (без override)
up-rebuild: check-env
	@echo "$(BLUE)🔄 Пересборка и запуск...$(NC)"
	docker compose \
		--env-file .env \
		-f compose.yaml \
		up -d --build --force-recreate
	@echo "$(GREEN)✅ Пересборка и запуск завершены$(NC)"

# Пересборка конкретного сервиса (остановка, удаление, пересборка, запуск)
rebuild-service: check-env
ifndef SERVICE
	@echo "$(RED)❌ Не указан сервис. Используйте: make rebuild-service SERVICE=имя_сервиса$(NC)"
	exit 1
endif
	@echo "$(BLUE)🔄 Пересборка сервиса $(SERVICE)...$(NC)"
	
	@echo "$(YELLOW)🛑 Остановка сервиса $(SERVICE)...$(NC)"
	docker compose \
		--env-file .env \
		-f compose.yaml \
		stop $(SERVICE)
	
	@echo "$(YELLOW)🗑️ Удаление контейнера для сервиса $(SERVICE)...$(NC)"
	docker compose \
		--env-file .env \
		-f compose.yaml \
		rm -f $(SERVICE)
	
	@echo "$(BLUE)🏗️ Пересборка образа для сервиса $(SERVICE)...$(NC)"
	docker compose \
		--env-file .env \
		-f compose.yaml \
		build $(SERVICE)
	
	@echo "$(GREEN)🚀 Запуск сервиса $(SERVICE)...$(NC)"
	docker compose \
		--env-file .env \
		-f compose.yaml \
		up -d $(SERVICE)
	
	@echo "$(GREEN)✅ Сервис $(SERVICE) пересобран и запущен$(NC)"

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
# Режимы окружения
# ===================================
.PHONY: dev prod test

# Запуск в режиме разработки
dev: check-env check-env-dev
	@echo "$(BLUE)💻 Запуск в режиме разработки...$(NC)"
	docker compose \
		--env-file .env \
		--env-file docker/.env/environments/.env.dev \
		-f compose.yaml \
		-f docker/compose.dev.yaml \
		up -d --build
	@echo "$(GREEN)✅ Режим разработки запущен$(NC)"

# Запуск в продакшене
prod: check-env check-env-prod
	@echo "$(BLUE)🚀 Запуск в продакшене...$(NC)"
	docker compose \
		--env-file .env \
		--env-file docker/.env/environments/.env.prod \
		-f compose.yaml \
		-f docker/compose.prod.yaml \
		up -d --build
	@echo "$(GREEN)✅ Продакшен запущен$(NC)"

# Запуск тестов
test: check-env
	@echo "$(BLUE)🧪 Запуск тестов...$(NC)"
	docker compose \
		--env-file .env \
		--env-file docker/.env/environments/.env.test \
		-f compose.yaml \
		-f tests/compose.test.yaml \
		up --abort-on-container-exit
	@echo "$(GREEN)✅ Тесты завершены$(NC)"

# ===================================
# Сборка
# ===================================
.PHONY: build build-dev build-service pull

# Только сборка (без запуска)
build: check-env
	@echo "$(BLUE)🏗️ Сборка образов...$(NC)"
	docker compose \
		--env-file .env \
		-f compose.yaml \
		build
	@echo "$(GREEN)✅ Сборка завершена$(NC)"

# Сборка с пересозданием (для dev)
build-dev: check-env check-env-dev
	@echo "$(BLUE)🏗️ Сборка с очисткой кэша (dev)...$(NC)"
	docker compose \
		--env-file .env \
		--env-file docker/.env/environments/.env.dev \
		-f compose.yaml \
		-f docker/compose.dev.yaml \
		build --no-cache
	@echo "$(GREEN)✅ Сборка с очисткой кэша завершена$(NC)"

# Сборка конкретного сервиса
build-service: check-env
	@echo "$(BLUE)🏗️ Сборка сервиса $(SERVICE)...$(NC)"
	docker compose \
		--env-file .env \
		-f compose.yaml \
		build $(SERVICE)
	@echo "$(GREEN)✅ Сборка сервиса $(SERVICE) завершена$(NC)"

# Обновление образов из registry
pull: check-env
	@echo "$(BLUE)📥 Обновление образов...$(NC)"
	docker compose \
		--env-file .env \
		-f compose.yaml \
		pull
	@echo "$(GREEN)✅ Образы обновлены$(NC)"

# ===================================
# Логи и мониторинг
# ===================================
.PHONY: logs logs-dev logs-service ps stats validate

# Просмотр логов
logs: check-env
	@echo "$(BLUE)📋 Просмотр логов...$(NC)"
	docker compose \
		--env-file .env \
		-f compose.yaml \
		logs -f

# Логи в режиме разработки (с учётом override)
logs-dev: check-env check-env-dev
	@echo "$(BLUE)📋 Просмотр логов (dev)...$(NC)"
	docker compose \
		--env-file .env \
		--env-file docker/.env/environments/.env.dev \
		-f compose.yaml \
		-f docker/compose.dev.yaml \
		logs -f

# Логи конкретного сервиса
logs-service: check-env
	@echo "$(BLUE)📋 Просмотр логов сервиса $(SERVICE)...$(NC)"
	docker compose \
		--env-file .env \
		-f compose.yaml \
		logs -f $(SERVICE)

# Просмотр состояния
ps: check-env
	@echo "$(BLUE)📊 Состояние сервисов:$(NC)"
	docker compose \
		--env-file .env \
		-f compose.yaml \
		ps

# Мониторинг ресурсов
stats:
	@echo "$(BLUE)📊 Мониторинг ресурсов контейнеров:$(NC)"
	docker stats

# Проверка конфигурации
validate: check-env
	@echo "$(BLUE)✅ Проверка конфигурации...$(NC)"
	docker compose \
		--env-file .env \
		-f compose.yaml \
		config > /dev/null && echo "$(GREEN)Конфигурация корректна$(NC)" || echo "$(RED)Ошибка в конфигурации!$(NC)"

# ===================================
# Дополнительные команды
# ===================================
.PHONY: exec shell backup restore

# Вход в контейнер
exec: check-env
	@echo "$(BLUE)🐚 Вход в контейнер $(SERVICE)...$(NC)"
	docker compose \
		--env-file .env \
		-f compose.yaml \
		exec $(SERVICE) sh

# Алиас для exec
shell: exec

# Бэкап данных
backup:
	@echo "$(BLUE)💾 Создание бэкапа...$(NC)"
	@test -f ./scripts/backup.sh && ./scripts/backup.sh || echo "$(YELLOW)Скрипт backup.sh не найден$(NC)"

# Восстановление данных
restore:
	@echo "$(BLUE)🔄 Восстановление из бэкапа...$(NC)"
	@test -f ./scripts/restore.sh && ./scripts/restore.sh || echo "$(YELLOW)Скрипт restore.sh не найден$(NC)"

# ===================================
# Очистка
# ===================================
.PHONY: clean clean-all prune prune-all prune-images prune-volumes disk-usage

# Очистка: остановка + удаление контейнеров, сетей
clean: check-env
	@echo "$(YELLOW)🧹 Очистка контейнеров и сетей...$(NC)"
	docker compose \
		--env-file .env \
		-f compose.yaml \
		down --volumes --remove-orphans
	@echo "$(GREEN)✅ Очистка завершена$(NC)"

# Полная очистка: + удаление образов
clean-all: clean
	@echo "$(RED)🚨 Полная очистка (включая образы)...$(NC)"
	docker compose \
		--env-file .env \
		-f compose.yaml \
		down --volumes --rmi all --remove-orphans
	@echo "$(GREEN)✅ Полная очистка завершена$(NC)"

# Удаление висячих образов и неиспользуемых данных
prune:
	@echo "$(YELLOW)🧹 Очистка висячих образов и неиспользуемых данных...$(NC)"
	docker image prune -f
	docker container prune -f
	docker network prune -f
	docker builder prune -f
	@echo "$(GREEN)✅ Базовая очистка завершена$(NC)"

# Полная очистка: все неиспользуемые данные
prune-all:
	@echo "$(RED)🚨 Полная очистка Docker (осторожно!)...$(NC)"
	docker system prune -af --volumes
	@echo "$(GREEN)✅ Полная очистка завершена$(NC)"

# Удаление только неиспользуемых образов
prune-images:
	@echo "$(YELLOW)🧹 Удаление неиспользуемых образов...$(NC)"
	docker image prune -af
	@echo "$(GREEN)✅ Неиспользуемые образы удалены$(NC)"

# Удаление неиспользуемых volumes
prune-volumes:
	@echo "$(YELLOW)🧹 Удаление неиспользуемых volumes...$(NC)"
	docker volume prune -f
	@echo "$(GREEN)✅ Неиспользуемые volumes удалены$(NC)"

# Анализ использования диска Docker
disk-usage:
	@echo "$(BLUE)📊 Использование диска Docker:$(NC)"
	docker system df -v

# ===================================
# Справка
# ===================================
help:
	@echo ""
	@echo "$(CYAN)=== Управление проектом ===$(NC)"
	@echo "  make up           — Запуск базовой конфигурации"
	@echo "  make down         — Остановка всех сервисов"
	@echo "  make stop         — Остановка без удаления контейнеров"
	@echo "  make restart      — Перезапуск сервисов"
	@echo "  make up-rebuild   — Пересборка и запуск"
	@echo "  make rebuild-service SERVICE=name — Пересборка указанного сервиса"
	@echo ""
	@echo "$(CYAN)=== Режимы окружения ===$(NC)"
	@echo "  make dev          — Запуск в режиме разработки"
	@echo "  make prod         — Запуск в продакшене"
	@echo "  make test         — Запуск тестов"
	@echo ""
	@echo "$(CYAN)=== Сборка ===$(NC)"
	@echo "  make build        — Сборка образов"
	@echo "  make build-dev    — Сборка с очисткой кэша (dev)"
	@echo "  make build-service SERVICE=name — Сборка конкретного сервиса"
	@echo "  make pull         — Обновление образов из registry"
	@echo ""
	@echo "$(CYAN)=== Логи и мониторинг ===$(NC)"
	@echo "  make logs         — Просмотр всех логов"
	@echo "  make logs-dev     — Просмотр логов (dev)"
	@echo "  make logs-service SERVICE=name — Логи конкретного сервиса"
	@echo "  make ps           — Состояние сервисов"
	@echo "  make stats        — Мониторинг ресурсов"
	@echo "  make validate     — Проверка конфигурации"
	@echo ""
	@echo "$(CYAN)=== Дополнительные команды ===$(NC)"
	@echo "  make exec SERVICE=name — Вход в контейнер"
	@echo "  make shell SERVICE=name — Алиас для exec"
	@echo "  make backup       — Создание бэкапа"
	@echo "  make restore      — Восстановление из бэкапа"
	@echo ""
	@echo "$(CYAN)=== Очистка ===$(NC)"
	@echo "  make clean        — Очистка (контейнеры, сети)"
	@echo "  make clean-all    — Очистка + удаление образов"
	@echo "  make prune        — Удаление висячих образов и данных"
	@echo "  make prune-all    — Полная очистка Docker (осторожно!)"
	@echo "  make prune-images — Удаление неиспользуемых образов"
	@echo "  make prune-volumes— Удаление неиспользуемых volumes"
	@echo "  make disk-usage   — Анализ использования диска"	
	@echo ""
	@echo "$(CYAN)=== Справка ===$(NC)"
	@echo "  make help         — Показать эту справку"
	@echo "  make              — Алиас для make help"
	@echo ""
