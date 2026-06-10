from collections.abc import Generator
from decimal import Decimal

import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker
from sqlalchemy.pool import StaticPool
from fastapi.testclient import TestClient

from app.api.deps import get_lock_controller
from app.core.database import get_db
from app.core.enums import CellStatus, ControllerType, RoleCode
from app.hardware.mock_lock_controller import MockLockController
import app.models  # noqa: F401
from app.main import app as fastapi_app
from app.models import Cell, Controller, Product, Role, StockItem, User
from app.models.base import Base


@pytest.fixture()
def engine():
    engine = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    Base.metadata.create_all(engine)
    try:
        yield engine
    finally:
        Base.metadata.drop_all(engine)
        engine.dispose()


@pytest.fixture()
def db(engine) -> Generator[Session, None, None]:
    SessionTesting = sessionmaker(bind=engine, autoflush=False, autocommit=False, future=True)
    session = SessionTesting()
    try:
        yield session
    finally:
        session.close()


@pytest.fixture()
def mock_lock_controller() -> MockLockController:
    return MockLockController()


@pytest.fixture()
def client(db: Session, mock_lock_controller: MockLockController) -> Generator[TestClient, None, None]:
    def override_get_db():
        yield db

    fastapi_app.dependency_overrides[get_db] = override_get_db
    fastapi_app.dependency_overrides[get_lock_controller] = lambda: mock_lock_controller
    try:
        yield TestClient(fastapi_app)
    finally:
        fastapi_app.dependency_overrides.clear()


@pytest.fixture()
def sample_data(db: Session):
    def create(quantity: Decimal = Decimal("5.000")) -> dict[str, object]:
        roles = {}
        for code in RoleCode:
            role = Role(code=code, name=code.value.title())
            db.add(role)
            db.flush()
            roles[code] = role

        users = {
            "admin": User(name="Admin", rfid_uid="admin-card", role_id=roles[RoleCode.ADMIN].id),
            "manager": User(
                name="Manager", rfid_uid="manager-card", role_id=roles[RoleCode.MANAGER].id
            ),
            "user": User(name="User", rfid_uid="user-card", role_id=roles[RoleCode.USER].id),
            "service": User(
                name="Service", rfid_uid="service-card", role_id=roles[RoleCode.SERVICE].id
            ),
        }
        db.add_all(users.values())
        controller = Controller(name="Mock", controller_type=ControllerType.MOCK, address=1)
        db.add(controller)
        db.flush()
        cell1 = Cell(
            number=1,
            status=CellStatus.ACTIVE,
            controller_id=controller.id,
            controller_address=1,
            relay_channel=1,
        )
        cell2 = Cell(
            number=2,
            status=CellStatus.ACTIVE,
            controller_id=controller.id,
            controller_address=1,
            relay_channel=2,
        )
        product = Product(name="Cable", sku="SKU-1", barcode="BAR-1", unit="pcs")
        name_only_product = Product(name="Special Battery", sku="BAT-1", barcode="BAR-2", unit="pcs")
        db.add_all([cell1, cell2, product, name_only_product])
        db.flush()
        stock = StockItem(product_id=product.id, cell_id=cell1.id, quantity=quantity)
        db.add(stock)
        db.commit()
        return {
            "roles": roles,
            "users": users,
            "controller": controller,
            "cell1": cell1,
            "cell2": cell2,
            "product": product,
            "name_only_product": name_only_product,
            "stock": stock,
        }

    return create
