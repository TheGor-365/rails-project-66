# GitHub Quality

[![CI](https://github.com/TheGor-365/rails-project-66/actions/workflows/ci.yml/badge.svg)](https://github.com/TheGor-365/rails-project-66/actions/workflows/ci.yml)
[![Hexlet check](https://github.com/TheGor-365/rails-project-66/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/TheGor-365/rails-project-66/actions/workflows/hexlet-check.yml)

**GitHub Quality** — приложение для проверки качества Ruby- и JavaScript-репозиториев GitHub с сохранением истории, поиском замечаний и переходом к исходному коду.

> **Происхождение:** личный/учебный проект на основе задания Hexlet, существенно доработанный для портфолио. Не коммерческий заказ. Авторская атрибуция Hexlet сохранена.

[Работающее приложение](https://rails-project-66-production-9982.up.railway.app/) · [Код](https://github.com/TheGor-365/rails-project-66) · [UI-релиз #22](https://github.com/TheGor-365/rails-project-66/pull/22) · [README-релиз #23](https://github.com/TheGor-365/rails-project-66/pull/23)

![GitHub Quality — брендированный preview](https://rails-project-66-production-9982.up.railway.app/og-image.png)

## Сценарий использования

1. Войти с помощью GitHub OAuth.
2. Найти и добавить свой поддерживаемый репозиторий Ruby или JavaScript.
3. Запустить проверку либо обработать подписанное событие GitHub push.
4. Фоновая задача выполняет анализ RuboCop / ESLint.
5. Открыть историю проверок и отчёт с реальными findings: файл, правило, сообщение, строка/колонка; выполнить поиск и перейти по ссылке на GitHub.

Результат **Issues found** означает замечания линтера, а не сбой веб-сайта. Числа и статусы формируются из результатов фактического анализа.

## Реализовано

| Компонент | Возможности |
|---|---|
| Доступ | OAuth GitHub через OmniAuth, сессии, политика доступа Pundit |
| Репозитории | Список, GitHub-селектор с поиском, создание записи, карточка |
| Анализ | RuboCop / ESLint, сериализованный результат, commit SHA, история проверок |
| Фоновые задания | Active Job + Solid Queue 1.7 в PostgreSQL; рабочий процесс Puma |
| Webhook | HMAC SHA-256 signature, фильтр push, skip deleted branch, deduplication delivery ID |
| Отчёт | Файлы, замечания, поиск, раскрытие/сворачивание, GitHub blob/line URL |
| UX | Graphite / Glacier dark design, Slim/Sass/Bootstrap/Turbo/Stimulus, desktop/mobile |
| Локализация | RU/EN через Rails I18n и session; локализованные даты |
| Site chrome | Единый SVG/favicon/ICO/PNG, Apple/Android icons, OG/Twitter preview, статические 404/422/500 и 406 |
| QA | Minitest, RuboCop, Brakeman, Hexlet/GitHub Actions |

### Архитектура

```text
GitHub OAuth ──> Web controllers / Pundit ──> PostgreSQL
                         │
Manual run ───────────────┼──> Active Job / Solid Queue
Signed push webhook ─────┘                │
                                         ▼
                                  CodeChecker
                                   │       │
                                RuboCop  ESLint
                                   └──┬────┘
                                 Stored report
                                         │
                           Rails + Slim + Stimulus UI
```

Файлы входа: `app/controllers/web/auth_controller.rb`, `app/controllers/web/repositories_controller.rb`, `app/controllers/web/repositories/checks_controller.rb`. Проверки: `app/controllers/api/checks_controller.rb`, `app/jobs/run_repository_check_job.rb`, `app/services/checks/run_service.rb`, `app/services/code_checker.rb`, `app/models/concerns/repository/check_output_parsing.rb`.

## Стек

| Слой | Технологии |
|---|---|
| Сервер | Ruby 3.2.2 (`.ruby-version`), Rails 7.2 |
| Данные и задачи | PostgreSQL, Solid Queue 1.7 |
| UI | Slim, Sass, Bootstrap 5, Turbo, Stimulus |
| Интеграции | GitHub OAuth / API / signed webhooks, Octokit |
| QA | Minitest, RuboCop, Brakeman, GitHub Actions |
| Hosting | Railway (Rails и отдельный Postgres) |

## Локальный запуск

Нужны Git, Ruby 3.2.2, Bundler, Node/Yarn, PostgreSQL. GitHub OAuth/webhook требуют **собственной** настройки с секретами только в окружении.

```bash
git clone https://github.com/TheGor-365/rails-project-66.git
cd rails-project-66
ruby -v
bundle install
yarn install
bin/rails db:prepare
bin/dev
```

`bin/dev` запускает Puma, esbuild и Sass watcher. Приложение: `http://localhost:3000`. Изменения `DATABASE_URL`, GitHub OAuth keys, `GITHUB_WEBHOOK_SECRET` и других секретов нельзя сохранять в Git/Drive. Прочитайте `config/puma.rb`, `Procfile.dev` и Rails конфигурацию перед развёртыванием.

```bash
RAILS_ENV=test bin/rails test
bundle exec rubocop
bundle exec brakeman -q
git diff --check
```

## Release / QA

- 30.10.2026 PR [#22](https://github.com/TheGor-365/rails-project-66/pull/22) объединён в `main`: Graphite / Glacier, I18n RU/EN, favicon и системные страницы (`6f7ad60`).
- Документационный PR [#23](https://github.com/TheGor-365/rails-project-66/pull/23) объединён (`942ed4e`), CI успешен; Railway сообщил `SUCCESS`, Rails и PostgreSQL `Online`.
- `GET /up` — healthcheck. Страницы ошибок самодостаточны, не требуют Rails asset pipeline.
- Подтверждён публичный production home и статическая 404. Авторизованные сценарии требуют браузерной проверки под владельцем GitHub.

## Ограничения, безопасность, происхождение

- Учебный/личный кейс. Нет доказательств платных клиентов, SLA или нагрузочных испытаний.
- Текущий `CodeChecker` использует shallow `git clone` и анализирует HEAD; необходимо отдельно доказать точный checkout commit, переданного в webhook `after`, прежде чем заявлять полную привязку к webhook SHA.
- Выполнение линтеров на недоверенном исходном коде требует оценки sandbox/лимитов/ресурсов; не заявлять security certification.
- Ротация ранее раскрытого PostgreSQL-пароля отложена владельцем; риск остаётся открытым. Отдельно проверить CSRF/origin policy, секреты, публичные документы и права на исходный код.
- `404.html`, `422.html`, `500.html` выдаются стандартным Rails exceptions middleware; `406-unsupported-browser.html` при Rails `allow_browser` в production.
- Атрибуция Hexlet намеренно сохранена; не удалять без проверки лицензии и происхождения.

## Презентация

[Google Drive: 02_GITHUB_QUALITY](https://drive.google.com/drive/folders/1fN44w5XB0XCNxRlkbnV2gJs80NeTutZS) — кейсы RU/EN, verified production screenshots, storyboard, экспортные материалы. Редакционные изображения не следует выдавать за реальные скриншоты интерфейса.

## English overview

GitHub Quality is a personal / educational Rails 7.2 app for inspecting Ruby and JavaScript repositories via GitHub OAuth and signed push webhooks. It runs background checks with Solid Queue/PostgreSQL, saves lint results and presents searchable file-level findings with GitHub source links. Responsive Graphite / Glacier UI supports RU and EN. No claims of commercial customers, SLAs or security certification. Hexlet educational attribution is retained.
