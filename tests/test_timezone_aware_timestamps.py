from datetime import timedelta
from decimal import Decimal

from sqlalchemy import select
from sqlalchemy.orm import sessionmaker

from app.models.access_event import AccessEvent
from app.models.cell_session import CellSession
from app.models.stock_movement import StockMovement
from app.services.operation_service import OperationService
from app.services.session_service import SessionService


def _assert_utc_aware(value):
    assert value.tzinfo is not None
    assert value.utcoffset() == timedelta(0)


def _assert_utc_json(value: str):
    assert value.endswith("Z") or value.endswith("+00:00")


def test_model_timestamps_are_utc_aware_after_sqlite_roundtrip(engine, db, sample_data):
    data = sample_data()
    product_id = data["product"].id
    cell_id = data["cell1"].id

    _assert_utc_aware(data["product"].created_at)
    _assert_utc_aware(data["product"].updated_at)

    SessionTesting = sessionmaker(bind=engine, autoflush=False, autocommit=False, future=True)
    new_db = SessionTesting()
    try:
        product = new_db.get(type(data["product"]), product_id)
        stock = new_db.scalars(
            select(type(data["stock"])).where(
                type(data["stock"]).product_id == product_id,
                type(data["stock"]).cell_id == cell_id,
            )
        ).one()

        _assert_utc_aware(product.created_at)
        _assert_utc_aware(product.updated_at)
        _assert_utc_aware(stock.created_at)
        _assert_utc_aware(stock.updated_at)
    finally:
        new_db.close()


def test_session_movement_and_event_timestamps_are_utc_aware(
    engine,
    db,
    client,
    mock_lock_controller,
    sample_data,
):
    data = sample_data()

    session = OperationService.start_fill(
        db,
        mock_lock_controller,
        user_id=data["users"]["user"].id,
        product_id=data["product"].id,
        cell_id=data["cell1"].id,
        quantity=Decimal("2.000"),
    )
    _assert_utc_aware(session.created_at)
    _assert_utc_aware(session.updated_at)
    _assert_utc_aware(session.opened_at)

    active_response = client.get("/api/sessions/active")
    assert active_response.status_code == 200
    _assert_utc_json(active_response.json()["session"]["opened_at"])

    SessionService.confirm_close(db, session.id)
    OperationService.confirm_fill(db, session.id)

    SessionTesting = sessionmaker(bind=engine, autoflush=False, autocommit=False, future=True)
    new_db = SessionTesting()
    try:
        stored_session = new_db.get(CellSession, session.id)
        movement = new_db.scalars(select(StockMovement)).one()
        event = new_db.scalars(
            select(AccessEvent).order_by(AccessEvent.created_at.desc())
        ).first()

        _assert_utc_aware(stored_session.close_confirmed_at)
        _assert_utc_aware(stored_session.completed_at)
        _assert_utc_aware(movement.created_at)
        _assert_utc_aware(event.created_at)
    finally:
        new_db.close()

    history_response = client.get(f"/api/products/{data['product'].id}/history")
    assert history_response.status_code == 200
    _assert_utc_json(history_response.json()[0]["created_at"])
