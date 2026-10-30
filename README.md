# GitHub Quality

[![CI](https://github.com/TheGor-365/rails-project-66/actions/workflows/ci.yml/badge.svg)](https://github.com/TheGor-365/rails-project-66/actions/workflows/ci.yml)
[![Hexlet tests](https://github.com/TheGor-365/rails-project-66/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/TheGor-365/rails-project-66/actions/workflows/hexlet-check.yml)

**Repository quality checks for Ruby and JavaScript projects connected to GitHub.**

> Personal and educational Ruby on Rails project. Extended, debugged and redesigned as a developer portfolio case; the original Hexlet educational attribution is retained.

**[Live demo](https://rails-project-66-production-9982.up.railway.app/)** · **[Source code](https://github.com/TheGor-365/rails-project-66)** · **[Redesign PR #22](https://github.com/TheGor-365/rails-project-66/pull/22)**

![GitHub Quality — Graphite / Glacier brand preview](https://rails-project-66-production-9982.up.railway.app/og-image.png)

## What it does

GitHub Quality turns raw linter results into a navigable per-file report:

- **GitHub OAuth** — sign in, select and search supported repositories.
- **Ruby and JavaScript checks** — run RuboCop and ESLint against a repository revision.
- **Signed GitHub push webhooks** — validate deliveries and handle duplicate events.
- **Background processing** — use Solid Queue backed by PostgreSQL, including persistent check history.
- **Actionable reports** — find affected files, search rule/message text, expand findings and follow links to exact GitHub source lines.
- **Responsive interface** — Graphite / Glacier dark UI, mobile navigation and **RU / EN** language switcher.
- **Site polish** — favicon, Open Graph metadata and branded 404/406/422/500 pages.

## Stack

| Layer | Technologies |
|---|---|
| Server | Ruby, Rails 7.2, Slim |
| Database / jobs | PostgreSQL, Solid Queue 1.7 |
| Frontend | Sass, Bootstrap, Hotwire Turbo, Stimulus |
| Integrations | GitHub OAuth / API / signed webhooks |
| Checks | RuboCop, ESLint |
| QA | Minitest, RuboCop, Brakeman, GitHub Actions |
| Hosting | Railway |

## Basic user flow

1. Sign in with GitHub.
2. Select an accessible Ruby or JavaScript repository.
3. Start a check, or receive a signed GitHub push event.
4. Open check history and inspect issues by file, rule and source line.

The application differentiates a completed check with lint findings from an execution error. Reports only show information returned by actual analysis; there are no fabricated scores or benchmarks.

## Local development

Prerequisites: compatible Ruby (check `.ruby-version`), Bundler, Node/Yarn and PostgreSQL.

```bash
git clone https://github.com/TheGor-365/rails-project-66.git
cd rails-project-66

bundle install
yarn install
bin/rails db:prepare
bin/dev
```

Testing:

```bash
RAILS_ENV=test bin/rails test
bin/rubocop
bin/brakeman --no-pager
```

GitHub OAuth and signed webhooks need your own configuration. Do **not** commit local credentials, `.env` files or real webhook secrets.

## Deployment and verification

The Graphite / Glacier redesign was merged in [PR #22](https://github.com/TheGor-365/rails-project-66/pull/22) on 30 October 2026, GitHub CI passed, and Railway reported a successful production deployment. The public demo may require GitHub login for personalized repository pages.

This is not a commercial client project or a claim of continuous uptime, security certification or paid customer traction.

## Origin and credits

This project started as an educational Hexlet Rails assignment, then underwent debugging, infrastructure work, accessibility/responsive UI redesign, localization, test coverage and deployment improvements. Preserve the original educational credit; verify third-party/source-code licensing before reusing this implementation in other products.
