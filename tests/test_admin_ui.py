from datetime import UTC, datetime

from app.core.enums import (
    AccessEventType,
    CellStatus,
    EventResult,
    MovementType,
    SessionOperationType,
    SessionStatus,
    RoleCode,
)
from app.models.access_event import AccessEvent
from app.models.cell_session import CellSession
from app.models.product_category import ProductCategory
from app.models.stock_item import StockItem
from app.models.stock_movement import StockMovement


def test_admin_can_update_and_block_user(client, db, sample_data):
    data = sample_data()
    user = data["users"]["user"]
    manager_role = data["roles"][RoleCode.MANAGER]

    response = client.post(
        f"/admin/users/{user.id}",
        data={
            "last_name": "Updated",
            "first_name": "User",
            "middle_name": "Middle",
            "department": "Updated department",
            "rfid_uid": "updated-card",
            "role_id": str(manager_role.id),
            "is_active": "on",
        },
        follow_redirects=False,
    )
    assert response.status_code == 303
    assert response.headers["location"] == "/admin/users#users"
    db.refresh(user)
    assert user.last_name == "Updated"
    assert user.first_name == "User"
    assert user.middle_name == "Middle"
    assert user.department == "Updated department"
    assert user.rfid_uid == "updated-card"
    assert user.role_id == manager_role.id

    response = client.post(f"/admin/users/{user.id}/toggle-active", follow_redirects=False)
    assert response.status_code == 303
    db.refresh(user)
    assert user.is_active is False


def test_admin_panel_renders_crud_forms(client, sample_data):
    sample_data()

    response = client.get("/admin")

    assert response.status_code == 200
    assert "Открыть пользователей" in response.text
    assert 'href="/admin/users"' in response.text
    assert "Открыть товары и группы" in response.text
    assert 'href="/admin/products"' in response.text
    assert "Открыть ячейки" in response.text
    assert 'href="/admin/cells"' in response.text
    assert "Открыть журналы и сессии" in response.text
    assert 'href="/admin/logs"' in response.text
    assert "Открыть остатки" in response.text
    assert 'href="/admin/stock"' in response.text
    assert "Открыть оборудование" in response.text
    assert 'href="/admin/hardware"' in response.text


def test_admin_logs_page_renders_operational_sections(client, sample_data):
    sample_data()

    response = client.get("/admin/logs")

    assert response.status_code == 200
    assert "История движений" in response.text
    assert "Журнал доступа" in response.text
    assert "Сессии открытия" in response.text
    assert "Europe/Moscow" in response.text


def test_admin_stock_page_renders_stock_form_and_rows(client, sample_data):
    sample_data()

    response = client.get("/admin/stock")

    assert response.status_code == 200
    assert "Остатки" in response.text
    assert "Добавить строку остатка" in response.text
    assert "Special Battery" in response.text


def test_admin_hardware_page_renders_controllers(client, sample_data):
    sample_data()

    response = client.get("/admin/hardware")

    assert response.status_code == 200
    assert "Оборудование" in response.text
    assert "Mock" in response.text
    assert "mock" in response.text


def test_admin_users_page_renders_user_forms(client, sample_data):
    sample_data()

    response = client.get("/admin/users")

    assert response.status_code == 200
    assert "Создать пользователя" in response.text
    assert "Фамилия" in response.text
    assert "Отдел" in response.text
    assert "Блокировать" in response.text
    assert "user-card" in response.text


def test_admin_products_page_renders_product_and_category_forms(client, sample_data):
    sample_data()

    response = client.get("/admin/products")

    assert response.status_code == 200
    assert "Создать товар" in response.text
    assert "Создать группу" in response.text
    assert "Special Battery" in response.text


def test_admin_cells_page_renders_cell_forms(client, sample_data):
    sample_data()

    response = client.get("/admin/cells")

    assert response.status_code == 200
    assert "Создать ячейку" in response.text
    assert "Блокировать" in response.text
    assert "relay_channel" in response.text


def test_admin_access_log_displays_local_time(client, db, sample_data):
    data = sample_data()
    db.add(
        AccessEvent(
            created_at=datetime(2026, 6, 10, 10, 0, 0, tzinfo=UTC),
            user_id=data["users"]["user"].id,
            event_type=AccessEventType.LOGIN_SUCCESS,
            result=EventResult.OK,
            client_ip="192.168.0.25",
            details="timezone check",
        )
    )
    db.commit()

    response = client.get("/admin/logs")

    assert response.status_code == 200
    assert "Europe/Moscow" in response.text
    assert "2026-06-10 13:00:00 +03:00" in response.text
    assert "Regular User" in response.text
    assert "192.168.0.25" in response.text


def test_admin_movements_and_sessions_display_local_time(client, db, sample_data):
    data = sample_data()
    db.add(
        CellSession(
            user_id=data["users"]["user"].id,
            cell_id=data["cell1"].id,
            operation_type=SessionOperationType.OPEN_ONLY,
            status=SessionStatus.COMPLETED,
            created_at=datetime(2026, 6, 10, 10, 0, 0, tzinfo=UTC),
        )
    )
    db.add(
        StockMovement(
            created_at=datetime(2026, 6, 10, 10, 0, 0, tzinfo=UTC),
            user_id=data["users"]["user"].id,
            product_id=data["product"].id,
            cell_id=data["cell1"].id,
            movement_type=MovementType.FILL,
            quantity="1.000",
            quantity_before="0.000",
            quantity_after="1.000",
        )
    )
    db.commit()

    response = client.get("/admin/logs")

    assert response.status_code == 200
    assert response.text.count("2026-06-10 13:00:00 +03:00") >= 2
    assert "Cable" in response.text


def test_admin_emergency_cancel_redirects_to_logs_page(client, db, sample_data):
    data = sample_data()
    session = CellSession(
        user_id=data["users"]["user"].id,
        cell_id=data["cell1"].id,
        operation_type=SessionOperationType.OPEN_ONLY,
        status=SessionStatus.OPENED,
    )
    db.add(session)
    db.commit()

    response = client.post(
        f"/admin/sessions/{session.id}/emergency-cancel",
        data={"reason": "manual admin stop"},
        follow_redirects=False,
    )

    assert response.status_code == 303
    assert response.headers["location"] == "/admin/logs#sessions"


def test_admin_can_create_stock_item_from_stock_page(client, db, sample_data):
    data = sample_data()

    response = client.post(
        "/admin/stock",
        data={
            "product_id": str(data["product"].id),
            "cell_id": str(data["cell2"].id),
            "quantity": "7.000",
        },
        follow_redirects=False,
    )

    assert response.status_code == 303
    assert response.headers["location"] == "/admin/stock#stock"
    stock_item = db.query(StockItem).filter_by(product_id=data["product"].id, cell_id=data["cell2"].id).one()
    assert str(stock_item.quantity) == "7.000"


def test_admin_zero_stock_quantity_removes_stock_item_row(client, db, sample_data):
    data = sample_data()

    response = client.post(
        "/admin/stock",
        data={
            "product_id": str(data["product"].id),
            "cell_id": str(data["cell1"].id),
            "quantity": "0.000",
        },
        follow_redirects=False,
    )

    assert response.status_code == 303
    assert (
        db.query(StockItem)
        .filter_by(product_id=data["product"].id, cell_id=data["cell1"].id)
        .count()
        == 0
    )


def test_admin_cannot_create_second_positive_product_in_cell(client, db, sample_data):
    data = sample_data()

    response = client.post(
        "/admin/stock",
        data={
            "product_id": str(data["name_only_product"].id),
            "cell_id": str(data["cell1"].id),
            "quantity": "7.000",
        },
        follow_redirects=False,
    )

    assert response.status_code == 409
    assert "already contains another product" in response.text
    assert (
        db.query(StockItem)
        .filter_by(product_id=data["name_only_product"].id, cell_id=data["cell1"].id)
        .count()
        == 0
    )


def test_admin_can_create_and_disable_product_category(client, db, sample_data):
    sample_data()

    created = client.post(
        "/admin/categories",
        data={"name": "Картриджи", "sort_order": "5", "is_active": "on"},
        follow_redirects=False,
    )

    assert created.status_code == 303
    assert created.headers["location"] == "/admin/products#categories"
    category = db.query(ProductCategory).filter_by(name="Картриджи").one()
    assert category.is_active is True

    toggled = client.post(f"/admin/categories/{category.id}/toggle-active", follow_redirects=False)
    assert toggled.status_code == 303
    db.refresh(category)
    assert category.is_active is False


def test_admin_can_update_and_block_cell(client, db, sample_data):
    data = sample_data()
    cell = data["cell1"]

    response = client.post(
        f"/admin/cells/{cell.id}",
        data={
            "number": "101",
            "status": "active",
            "controller_id": str(data["controller"].id),
            "controller_address": "7",
            "relay_channel": "9",
            "comment": "updated",
        },
        follow_redirects=False,
    )
    assert response.status_code == 303
    assert response.headers["location"] == "/admin/cells#cells"
    db.refresh(cell)
    assert cell.number == 101
    assert cell.controller_address == 7
    assert cell.relay_channel == 9
    assert cell.comment == "updated"

    response = client.post(f"/admin/cells/{cell.id}/toggle-block", follow_redirects=False)
    assert response.status_code == 303
    assert response.headers["location"] == "/admin/cells#cells"
    db.refresh(cell)
    assert cell.status == CellStatus.BLOCKED
