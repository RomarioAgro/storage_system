# 13. Iteration 028: terminal UI fixes after manual Playwright test

## Scope

This addendum records fixes made after `reports/iteration_027_manual_playwright_test.md`.

## Requirements confirmed

- Terminal UI renders application errors as HTML pages, not raw JSON, for permission, stock, validation and duplicate product errors.
- Fill and take operation start forms reject non-positive quantities before a cell session is created or a lock is opened.
- Inventory start rejects negative actual quantities; zero is allowed to support recounting a cell to empty stock.
- Terminal menus and product operation forms show only actions allowed for the current role.
- Operation cell selectors include only active cells; blocked and maintenance cells are excluded from UI and still rejected by backend service checks.
- Product-card direct URLs respect the active-session blocker before showing any new operation forms.
- Admin logs show an active session and emergency-cancel control while an operation is unfinished.

## Tests added

- Regular user menu hides open-only action while service user can see it.
- Direct product URL is blocked by an active session.
- Take operation rejects `0` and negative quantities before opening the lock.
- Terminal operation errors are rendered as HTML.
- Duplicate SKU from terminal product creation returns a form error.
- Product operation forms exclude blocked cells.
- Admin logs show active-session emergency controls.
