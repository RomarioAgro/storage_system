from app.core.enums import AccessEventType, SessionOperationType
from app.models.access_event import AccessEvent
from app.models.product import Product
from app.models.stock_item import StockItem
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


def test_terminal_product_stock_overview_can_show_zero_stock_rows(client, db, sample_data):
    data = sample_data()
    db.add(
        StockItem(
            product_id=data["name_only_product"].id,
            cell_id=data["cell2"].id,
            quantity="0.000",
        )
    )
    db.commit()

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
