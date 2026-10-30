# GitHub Quality — Site finishing QA

**Status:** Draft, not released. Work against PR #22's Graphite / Glacier branch.

## Static chrome
- Native dark SVG brand icon replaces original red square.
- Binary asset overlay supplied separately: `public/favicon.ico`, `public/icon.png`, `public/apple-touch-icon.png`, `public/icon-192.png`, `public/icon-512.png`, `public/og-image.png`. **Do not deploy until all six exist.**
- Main layout includes favicon, touch icon, webmanifest, Open Graph and Twitter large preview.
- `robots.txt` excludes private application paths; access control remains the responsibility of Rails authorization.
- Static error pages 404, 422, 500 and 406 carry their own inline dark styling (not the Rails asset pipeline) and generic messages with RU/EN text. Do not include private stack traces.

## Manual release checks
1. Run full Rails tests and RuboCop/Brakeman. Verify SVG and binary asset paths return 200 with correct MIME types.
2. Test homepage guest and signed-in, repository index and report, RU/EN switcher, 390px/768px/1440px, keyboard focus, reduced-motion.
3. Test 404 and 406 and their HTTP status; note in Rails development default error handling may show developer exception pages rather than static pages.
4. Verify real Open Graph preview only after the production deploy (guest accessible image). Beware external preview caches.
5. Recheck GitHub OAuth, POST webhook and Solid Queue worker after deploy; healthcheck `/up`.
6. Confirm deployment rollback/backup and secret rotation plan, especially the previously disclosed PostgreSQL password.
7. Only then capture *production* presentation screenshots and record exact deployment SHA, locale, viewport and UTC time.

## Pending non-code tasks
- Do not remove Hexlet attribution without provenance / licensing review.
- Confirm public support/privacy contact and publication-ready privacy/terms content if the service will onboard external users. Do not invent a policy.
- No claim of offline/PWA capability: webmanifest has `display: browser`, there is no service worker.
