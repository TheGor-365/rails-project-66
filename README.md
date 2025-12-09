# Github Quality

### Hexlet tests and linter status:
[![Hexlet Status](https://github.com/TheGor-365/rails-project-66/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/TheGor-365/rails-project-66/actions/workflows/hexlet-check.yml)
[![CI](https://github.com/TheGor-365/rails-project-66/actions/workflows/ci.yml/badge.svg)](https://github.com/TheGor-365/rails-project-66/actions/workflows/ci.yml)

Сервис для автоматического анализа качества репозиториев на GitHub.  
Пользователь авторизуется через GitHub, выбирает свои репозитории и запускает проверки кода — приложение клонирует репозиторий, прогоняет линтеры и сохраняет историю проверок.

Github Quality задуман как учебный pet-проект и упрощённый аналог CodeClimate: помогает следить за здоровьем кода, видеть количество нарушений стиля и быстро переходить к проблемным коммитам в GitHub.

## Основной функционал

- Авторизация через GitHub и привязка репозиториев пользователя;
- Запуск проверок репозиториев (Ruby и JavaScript);
- Анализ кода с помощью RuboCop и ESLint;
- Сохранение результатов проверки: статус, SHA коммита, количество нарушений, сырой вывод линтеров;
- История проверок для каждого репозитория;
- Переход к коммиту на GitHub по короткому SHA;
- Простое веб-UI на Bootstrap-классах (таблица проверок, страница детализации).

## Технологии

- Ruby on Rails 7.2
- PostgreSQL
- Интеграция с GitHub (OAuth + работа с репозиториями)
- Minitest (unit- и system-тесты)
- RuboCop / ESLint как основные инструменты анализа кода
- Brakeman для security-скана Rails-приложения
- GitHub Actions (CI: тесты, линтеры, security-проверки)

## Деплой

Задеплоено на Render: **[https://<YOUR-RENDER-APP>.onrender.com](https://<YOUR-RENDER-APP>.onrender.com)**  

(замени `<YOUR-RENDER-APP>` на реальное имя приложения после деплоя)

## Локальный запуск

```bash
git clone https://github.com/<YOUR_GITHUB_USERNAME>/<YOUR_REPO>.git
cd <YOUR_REPO>
bundle install
bin/rails db:create db:migrate
bin/rails server
