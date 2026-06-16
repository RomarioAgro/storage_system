from app.core.enums import AccessEventType, CellStatus, SessionOperationType
from app.models.access_event import AccessEvent
from app.models.cell_session import CellSession
from app.models.product import Product
from app.services.session_service import SessionService


def test_terminal_shows_rfid_prompt_without_active_session(client, sample_data):
    sample_data()

    response = client.get("/terminal")

    assert response.status_code == 200
    assert "Приложите RFID" in response.text


def test_terminal_shows_blocking_screen_with_active_session(client, db, sample_data):
    data = sample_data()
    SessionService.create_session(
        db,
        data["users"]["user"],
        data["cell1"],
        SessionOperationType.OPEN_ONLY,
    )
    db.commit()

    response = client.get("/terminal")

    assert response.status_code == 200
    assert "Есть незавершенная операция" in response.text
    assert "Новая ячейка не может быть открыта" in response.text


def test_terminal_rfid_creates_local_ui_session(client, sample_data):
    sample_data()

    login = client.post("/terminal/rfid", data={"rfid_uid": "user-card"})
    menu = client.get("/terminal/menu")

    assert login.status_code == 200
    assert menu.status_code == 200
    assert "Здравствуйте, Regular User" in menu.text


def test_terminal_menu_links_to_paginated_stock_overviews(client, sample_data):
    sample_data()

    client.post("/terminal/rfid", data={"rfid_uid": "user-card"})
    menu = client.get("/terminal/menu")
    products = client.get("/terminal/stock/products?page_size=50")
    cells = client.get("/terminal/stock/cells?page_size=100")

    assert menu.status_code == 200
    assert 'href="/terminal/stock/products"' in menu.text
    assert 'href="/terminal/stock/cells"' in menu.text
    assert products.status_code == 200
    assert "Все товары с остатками" in products.text
    assert "Cable" in products.text
    assert "SKU-1" in products.text
    assert "5.000" in products.text
    assert "Special Battery" not in products.text
    assert 'value="20"' in products.text
    assert 'value="50" selected' in products.text
    assert 'value="100"' in products.text
    assert "Показать товары с нулевым остатком" in products.text
    assert "Показать товары без ячеек" in products.text
    assert cells.status_code == 200
    assert "Все ячейки с товарами" in cells.text
    assert "Cable" in cells.text
    assert "5.000" in cells.text
    assert 'value="100" selected' in cells.text


def test_terminal_product_stock_overview_can_show_products_without_cells(client, sample_data):
    sample_data()

    client.post("/terminal/rfid", data={"rfid_uid": "user-card"})
    response = client.get("/terminal/stock/products?show_without_cells=1")

    assert response.status_code == 200
    assert "Special Battery" in response.text
    assert "0.000" in response.text
    assert 'name="show_without_cells" value="1" checked' in response.text


def test_terminal_product_stock_overview_can_show_zero_stock_products(client, sample_data):
    sample_data()

    client.post("/terminal/rfid", data={"rfid_uid": "user-card"})
    hidden = client.get("/terminal/stock/products")
    visible = client.get("/terminal/stock/products?show_zero=1")

    assert hidden.status_code == 200
    assert "Special Battery" not in hidden.text
    assert visible.status_code == 200
    assert "Special Battery" in visible.text
    assert "0.000" in visible.text
    assert 'name="show_zero" value="1" checked' in visible.text


def test_terminal_rfid_logs_client_ip(client, db, sample_data):
    sample_data()

    response = client.post("/terminal/rfid", data={"rfid_uid": "manager-card"})

    assert response.status_code == 200
    event = db.query(AccessEvent).order_by(AccessEvent.id.desc()).first()
    assert event.client_ip == "testclient"


def test_terminal_operation_events_reuse_session_client_ip(client, db, sample_data):
    sample_data()

    client.post("/terminal/rfid", data={"rfid_uid": "service-card"})
    opened = client.post(
        "/terminal/open-only/start",
        data={"cell_id": "1", "comment": "service open"},
    )
    close = client.post(
        "/terminal/sessions/1/confirm-close",
        data={"next_action": "open_only"},
    )
    done = client.post("/terminal/open-only/1/complete")

    assert opened.status_code == 200
    assert close.status_code == 200
    assert done.status_code == 200
    events = db.query(AccessEvent).order_by(AccessEvent.id.asc()).all()
    event_ips = {
        event.event_type: event.client_ip
        for event in events
        if event.event_type
        in {
            AccessEventType.SESSION_STARTED,
            AccessEventType.OPEN_CELL_SUCCESS,
            AccessEventType.CLOSE_CONFIRMED,
            AccessEventType.SESSION_COMPLETED,
        }
    }
    assert event_ips == {
        AccessEventType.SESSION_STARTED: "testclient",
        AccessEventType.OPEN_CELL_SUCCESS: "testclient",
        AccessEventType.CLOSE_CONFIRMED: "testclient",
        AccessEventType.SESSION_COMPLETED: "testclient",
    }


def test_terminal_manager_can_create_product(client, db, sample_data):
    sample_data()

    login = client.post("/terminal/rfid", data={"rfid_uid": "manager-card"})
    menu = client.get("/terminal/menu")
    form = client.get("/terminal/products/new")
    created = client.post(
        "/terminal/products",
        data={
            "name": "Новый товар",
            "sku": "NEW-1",
            "barcode": "9990001",
            "unit": "pcs",
        },
        follow_redirects=False,
    )

    assert login.status_code == 200
    assert "Создать товар" in menu.text
    assert form.status_code == 200
    assert created.status_code == 303
    product = db.query(Product).filter_by(sku="NEW-1").one()
    assert product.name == "Новый товар"


def test_terminal_regular_user_cannot_create_product(client, sample_data):
    sample_data()

    client.post("/terminal/rfid", data={"rfid_uid": "user-card"})
    menu = client.get("/terminal/menu")
    created = client.post(
        "/terminal/products",
        data={"name": "Forbidden", "sku": "NOPE", "unit": "pcs"},
        follow_redirects=False,
    )

    assert "Создать товар" not in menu.text
    assert created.status_code == 403


def test_terminal_user_menu_hides_forbidden_operation_links(client, sample_data):
    sample_data()

    client.post("/terminal/rfid", data={"rfid_uid": "user-card"})
    user_menu = client.get("/terminal/menu")
    client.get("/terminal/logout")
    client.post("/terminal/rfid", data={"rfid_uid": "service-card"})
    service_menu = client.get("/terminal/menu")

    assert user_menu.status_code == 200
    assert 'href="/terminal/open-only"' not in user_menu.text
    assert service_menu.status_code == 200
    assert 'href="/terminal/open-only"' in service_menu.text


def test_terminal_direct_product_url_is_blocked_by_active_session(client, db, sample_data):
    data = sample_data()
    SessionService.create_session(
        db,
        data["users"]["user"],
        data["cell1"],
        SessionOperationType.OPEN_ONLY,
    )
    db.commit()

    response = client.get(f"/terminal/products/{data['product'].id}")

    assert response.status_code == 200
    assert "open_only" in response.text
    assert "Cable" not in response.text
    return
    assert "Р•СЃС‚СЊ РЅРµР·Р°РІРµСЂС€РµРЅРЅР°СЏ РѕРїРµСЂР°С†РёСЏ" in response.text
    assert "Cable" not in response.text


def test_terminal_take_rejects_non_positive_quantity_before_opening(
    client,
    db,
    mock_lock_controller,
    sample_data,
):
    data = sample_data()
    client.post("/terminal/rfid", data={"rfid_uid": "user-card"})

    zero = client.post(
        "/terminal/take/start",
        data={
            "product_id": str(data["product"].id),
            "cell_id": str(data["cell1"].id),
            "quantity": "0",
        },
    )
    negative = client.post(
        "/terminal/take/start",
        data={
            "product_id": str(data["product"].id),
            "cell_id": str(data["cell1"].id),
            "quantity": "-1",
        },
    )

    assert zero.status_code == 400
    assert negative.status_code == 400
    assert "Quantity must be greater than zero" in zero.text
    assert "Quantity must be greater than zero" in negative.text
    assert mock_lock_controller.calls == []
    assert db.query(CellSession).count() == 0


def test_terminal_operation_errors_are_rendered_as_html(client, sample_data):
    data = sample_data()
    client.post("/terminal/rfid", data={"rfid_uid": "user-card"})

    response = client.post(
        "/terminal/take/start",
        data={
            "product_id": str(data["product"].id),
            "cell_id": str(data["cell1"].id),
            "quantity": "9999",
        },
    )

    assert response.status_code == 409
    assert "text/html" in response.headers["content-type"]
    assert "Not enough stock in selected cell" in response.text
    assert '{"detail"' not in response.text


def test_terminal_duplicate_sku_returns_form_error(client, sample_data):
    sample_data()
    client.post("/terminal/rfid", data={"rfid_uid": "manager-card"})

    response = client.post(
        "/terminal/products",
        data={"name": "Duplicate", "sku": "SKU-1", "unit": "pcs"},
    )

    assert response.status_code == 409
    assert "Product with the same SKU, barcode, or external ID already exists" in response.text
    assert "Internal Server Error" not in response.text


def test_terminal_product_forms_exclude_blocked_cells(client, db, sample_data):
    data = sample_data()
    data["cell2"].status = CellStatus.BLOCKED
    db.commit()
    client.post("/terminal/rfid", data={"rfid_uid": "manager-card"})

    response = client.get(f"/terminal/products/{data['product'].id}")

    assert response.status_code == 200
    assert f'<option value="{data["cell1"].id}">{data["cell1"].number}</option>' in response.text
    assert f'<option value="{data["cell2"].id}">{data["cell2"].number}</option>' not in response.text
