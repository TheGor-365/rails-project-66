# GitHub Quality — Design System v0.1

Status: implementation foundation / draft. **Not approved for production.**

## Approved direction

- Main visual language: **A Graphite / Glacier**, restrained technical dark theme.
- From **B Porcelain / Cobalt**: spacious readable information hierarchy and an accessible future light theme.
- From **C Deep Slate / Mint**: semantic mint used selectively for successful execution, not as a competing primary accent.
- Editorial motto: **Clear signal. Less noise.** A working developer tool, not a dashboard demo.

## Truthful data

All metrics, commit IDs, durations, statuses and actions on real Rails pages must derive from persisted check data. Do not add dummy activity tabs, fabricated scores or inert links merely because a prototype contains them.

## Page model

| Screen | Purpose | Unique components |
| --- | --- | --- |
| Home guest | Explain product; lead to GitHub sign-in | Hero, real feature summary |
| Home signed-in | Clear first action | Repository entry, recent activity only when supported |
| Repositories index | Find connected repositories | Compact index, last-check status |
| Add repository | Search and add a GitHub repo | Existing accessible Stimulus search |
| Repository detail | See context and check history | Timeline/list of real checks, Run check |
| Check report | Diagnose lint results quickly | Summary, file index, offense detail, GitHub source links |

## Source-of-truth layers

- `design/_tokens.scss` — all semantic CSS variables, dark and light palettes.
- `design/_foundation.scss` — typography, global focus treatment, page width.
- `design/_shell.scss` — shared header/footer and mobile navigation.
- `design/_components.scss` — reusable primitives. Do not redefine on a page.
- `design/_motion.scss` — opt-in motion and reduced-motion support.
- `pages/_*.scss` — forthcoming screen-specific composition only.
- `app/views/shared/ui/_*.html.slim` — semantic view partials.
- Stimulus only for real user interaction (filtering, theme toggle), not decorative animation.

## Layout and motion

- One content maximum of 1380px, side gutters 16–44px via CSS variable.
- Desktop 12-column responsive mindset; reduce layouts to one column on narrow screens.
- File paths must wrap, all flex/grid children need min-width: 0.
- 8/12/16px corner radii; a single 4/8/16/24/32px spacing rhythm.
- 180ms for hover, optional 240ms for section reveal, transform and opacity only.
- No animation of large page surfaces by default; respect reduced-motion.
- Semantic states: success=lint pass, warning=lint findings, danger=execution error. Never call a successful job an error merely because code violations exist.
- Accessible minimum: keyboard focus, readable contrast, real buttons/links, no sideways overflow at 360px.

## Release gates

1. App shell + design tokens render across guest/auth states.
2. Port the check report to the same primitives; ensure existing local uncommitted report is preserved.
3. Finish home, repository index/detail and add flow.
4. Test mobile 360/390/430, tablet 768, desktop 1280/1440, dark and light themes, EN/RU, keyboard.
5. Review Hexlet provenance/permission before removing existing footer attribution. Current template attribution is deliberately retained.
6. CI (Rails tests, RuboCop, Brakeman); local screenshots; **only then** merge/deploy.

Note: CSS font stacks are system fallbacks; external web fonts are NOT fetched by this foundation. Pick licensed self-hosted fonts later, if needed.
