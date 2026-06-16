# Storage System MVP

Local RFID-based storage system for small office warehouses with addressable cells and electronic locks.

The MVP is intentionally simple and local-first:

- FastAPI backend
- SQLAlchemy 2.x models
- Alembic migrations
- PostgreSQL-ready data model
- SQLite-friendly development mode
- Mock lock controller for development without hardware
- Hardware abstraction for USB relay and Modbus relay implementations
- One active cell session at a time
- Stock accounting by product and cell
- Product movement history
- Access event journal
- Server-rendered terminal UI
- Minimal admin panel

## Main business rule

Only one cell may be opened at any time.

A new cell cannot be opened until the active operation is closed and confirmed or cancelled.

## Project layout

```text
app/
  api/              FastAPI routes and dependencies
  core/             settings, database, enums
  hardware/         lock controller abstraction and implementations
  models/           SQLAlchemy models
  schemas/          Pydantic request/response schemas
  services/         business logic
  main.py           FastAPI application
  seed.py           seed data
migrations/         Alembic setup and initial migration
tests/              starter tests
```

## Quick start with SQLite

```bash
python -m venv .venv
source .venv/bin/activate
pip install -e .[dev]
cp .env.example .env
python -m app.seed
uvicorn app.main:app --reload
```

Open:

```text
http://127.0.0.1:8000/terminal
http://127.0.0.1:8000/admin
http://127.0.0.1:8000/docs
```

Seed RFID cards:

```text
admin-card
manager-card
user-card
service-card
```

## Quick API smoke test

Authenticate:

```bash
curl -X POST http://127.0.0.1:8000/api/auth/rfid \
  -H 'Content-Type: application/json' \
  -d '{"rfid_uid":"admin-card"}'
```

Start fill operation:

```bash
curl -X POST http://127.0.0.1:8000/api/operations/fill/start \
  -H 'Content-Type: application/json' \
  -d '{"user_id":1,"product_id":1,"cell_id":1,"quantity":"5.000"}'
```

Confirm close:

```bash
curl -X POST http://127.0.0.1:8000/api/sessions/1/confirm-close
```

Confirm fill:

```bash
curl -X POST http://127.0.0.1:8000/api/operations/fill/1/confirm \
  -H 'Content-Type: application/json' \
  -d '{"comment":"initial stock"}'
```

## PostgreSQL mode

Use `docker-compose.yml` or your own PostgreSQL instance.

Example `.env`:

```text
DATABASE_URL=postgresql+psycopg://storage:storage@127.0.0.1:5432/storage_system
LOCK_CONTROLLER=mock
AUTO_CREATE_TABLES=false
```

Apply migration:

```bash
alembic upgrade head
python -m app.seed
```

## Hardware notes

Business logic must not talk to relays directly. All lock operations go through:

```python
LockController.open_cell(controller_address, relay_channel, pulse_seconds)
```

Implemented now:

- `MockLockController`

Prepared stubs:

- `UsbRelayController`
- `ModbusRelayController`

## Important MVP limitations

- No real relay protocol implementation yet.
- Manual close confirmation is used instead of close sensors.
- Basic role policy is hardcoded in `PermissionService`.
- Authentication endpoint returns user data only, not JWT.
- Terminal UI uses a local signed cookie session after RFID login.
- Inventory uses the same open, close-confirm, final-confirm lifecycle as other stock operations.
- Direct `/api/operations/inventory/set` stock mutation is disabled; use `/inventory/start`, `/api/sessions/{id}/confirm-close`, and `/inventory/{id}/confirm`.
- ORM timestamps are normalized to timezone-aware UTC values in SQLite dev/test mode and PostgreSQL-ready models.
- Python 3.12+ is the declared target. The project workspace includes a local `.python312` install and `.venv` created from Python 3.12.10.

## Next development steps

1. Replace the development `ui_session_secret` default with deployment configuration.
2. Implement selected relay protocol.
3. Add close sensors in hardware layer.
4. Add stronger transaction isolation and DB-level lock handling for production.
5. Add export and external integration endpoints.
