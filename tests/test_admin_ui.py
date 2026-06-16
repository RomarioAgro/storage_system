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
from app.models.cell import Cell
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
    assert 'href="/admin/logs?view=movements"' in response.text
    assert 'href="/admin/logs?view=access"' in response.text
    assert 'href="/admin/logs?view=sessions"' in response.text
    assert "<h2>История движений</h2>" in response.text
    assert "<h2>Журнал доступа</h2>" not in response.text
    assert "<h2>Сессии открытия</h2>" not in response.text
    assert "Europe/Moscow" in response.text

    access_response = client.get("/admin/logs?view=access")
    sessions_response = client.get("/admin/logs?view=sessions")

    assert access_response.status_code == 200
    assert "<h2>Журнал доступа</h2>" in access_response.text
    assert "<h2>История движений</h2>" not in access_response.text
    assert sessions_response.status_code == 200
    assert "<h2>Сессии открытия</h2>" in sessions_response.text
    assert "<h2>Журнал доступа</h2>" not in sessions_response.text


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
    assert ">Товары<" in response.text
    assert ">Группы<" in response.text
    assert "Special Battery" not in response.text


def test_admin_product_and_category_views_filter_lists(client, db, sample_data):
    data = sample_data()
    category = ProductCategory(name="Кабели", sort_order=10)
    db.add(category)
    data["product"].category_id = category.id
    db.commit()

    product_response = client.get("/admin/products?view=products&sku=BAT-1&page_size=10&sort=sku&direction=desc")

    assert product_response.status_code == 200
    assert "Special Battery" in product_response.text
    assert "Cable" not in product_response.text
    assert "<th>Редактирование</th>" not in product_response.text
    assert 'href="#edit-product-' in product_response.text
    assert "Редактировать товар" in product_response.text
    assert "/toggle-active" in product_response.text
    assert '<option value="10" selected>10</option>' in product_response.text

    category_response = client.get("/admin/products?view=categories&category_name=Каб&category_page_size=20")

    assert category_response.status_code == 200
    assert "Кабели" in category_response.text
    assert "<th>Редактирование</th>" not in category_response.text
    assert 'href="#edit-category-' in category_response.text
    assert "Редактировать группу" in category_response.text
    assert "Отменить" in category_response.text
    assert '<option value="20" selected>20</option>' in category_response.text


def test_admin_product_page_opens_create_forms_by_button_view(client, sample_data):
    sample_data()

    product_response = client.get("/admin/products?view=create_product")
    category_response = client.get("/admin/products?view=create_category")

    assert product_response.status_code == 200
    assert 'action="/admin/products"' in product_response.text
    assert "External ID" in product_response.text
    assert category_response.status_code == 200
    assert 'action="/admin/categories"' in category_response.text
    assert "Порядок" in category_response.text


def test_admin_cells_page_renders_cell_forms(client, sample_data):
    sample_data()

    response = client.get("/admin/cells")

    assert response.status_code == 200
    assert "Создать ячейку" in response.text
    assert "Блокировать" in response.text
    assert "Сохранить" in response.text
    assert "<th>Редактирование</th>" not in response.text
    assert 'class="number-field"' in response.text
    assert '<option value="10" selected>10</option>' in response.text
    assert "relay_channel" in response.text


def test_admin_cells_page_paginates_cells(client, db, sample_data):
    data = sample_data()
    for number in range(3, 15):
        db.add(
            Cell(
                number=number,
                status=CellStatus.ACTIVE,
                controller_id=data["controller"].id,
                controller_address=1,
                relay_channel=number,
            )
        )
    db.commit()

    response = client.get("/admin/cells?page_size=10")

    assert response.status_code == 200
    assert "Страница 1 из 2" in response.text
    assert "Вперед" in response.text


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

    response = client.get("/admin/logs?view=access")

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

    response = client.get("/admin/logs?view=movements")

    assert response.status_code == 200
    assert "2026-06-10 13:00:00 +03:00" in response.text
    assert "Cable" in response.text

    sessions_response = client.get("/admin/logs?view=sessions")

    assert sessions_response.status_code == 200
    assert "2026-06-10 13:00:00 +03:00" in sessions_response.text


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
    assert response.headers["location"] == "/admin/logs?view=sessions"


def test_admin_logs_page_shows_active_session_controls(client, db, sample_data):
    data = sample_data()
    session = CellSession(
        user_id=data["users"]["service"].id,
        cell_id=data["cell1"].id,
        operation_type=SessionOperationType.OPEN_ONLY,
        status=SessionStatus.OPENED,
    )
    db.add(session)
    db.commit()

    response = client.get("/admin/logs")

    assert response.status_code == 200
    assert 'id="active-session"' in response.text
    assert f'action="/admin/sessions/{session.id}/emergency-cancel"' in response.text
    assert "open_only" in response.text


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
    assert created.headers["location"] == "/admin/products?view=categories"
    category = db.query(ProductCategory).filter_by(name="Картриджи").one()
    assert category.is_active is True

    toggled = client.post(f"/admin/categories/{category.id}/toggle-active", follow_redirects=False)
    assert toggled.status_code == 303
    db.refresh(category)
    assert category.is_active is False


def test_admin_can_update_product_fields_and_category(client, db, sample_data):
    data = sample_data()
    product = data["product"]
    category = ProductCategory(name="Кабели", sort_order=10)
    db.add(category)
    db.commit()

    response = client.post(
        f"/admin/products/{product.id}",
        data={
            "name": "Updated cable",
            "sku": "SKU-UPDATED",
            "barcode": "BAR-UPDATED",
            "unit": "box",
            "external_id": "EXT-UPDATED",
            "category_id": str(category.id),
            "is_active": "on",
        },
        follow_redirects=False,
    )

    assert response.status_code == 303
    assert response.headers["location"] == "/admin/products?view=products"
    db.refresh(product)
    assert product.name == "Updated cable"
    assert product.sku == "SKU-UPDATED"
    assert product.barcode == "BAR-UPDATED"
    assert product.unit == "box"
    assert product.external_id == "EXT-UPDATED"
    assert product.category_id == category.id
    assert product.is_active is True

    response = client.post(f"/admin/products/{product.id}/toggle-active", follow_redirects=False)
    assert response.status_code == 303
    assert response.headers["location"] == "/admin/products?view=products"
    db.refresh(product)
    assert product.is_active is False


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
    assert response.headers["location"] == "/admin/cells"
    db.refresh(cell)
    assert cell.number == 101
    assert cell.controller_address == 7
    assert cell.relay_channel == 9
    assert cell.comment == "updated"

    response = client.post(f"/admin/cells/{cell.id}/toggle-block", follow_redirects=False)
    assert response.status_code == 303
    assert response.headers["location"] == "/admin/cells"
    db.refresh(cell)
    assert cell.status == CellStatus.BLOCKED
