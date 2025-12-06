# Github Quality

### Hexlet tests and linter status:
[![Actions Status](https://github.com/TheGor-365/rails-project-66/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/TheGor-365/rails-project-66/actions)

Сервис для автоматического анализа качества репозиториев на GitHub.  
Проект позволяет запускать проверки, получать отчёты и следить за историей проверок — аналог codeclimate.  

## Деплой

Задеплоено на Render: **https://<YOUR-RENDER-APP>.onrender.com/**  

## Локальный запуск

```bash
git clone https://github.com/<YOUR_GITHUB_USERNAME>/<YOUR_REPO>.git
cd <YOUR_REPO>
bundle install
rails db:create db:migrate
rails server
