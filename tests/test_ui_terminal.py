from app.core.enums import SessionOperationType
from app.models.access_event import AccessEvent
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


def test_terminal_rfid_logs_client_ip(client, db, sample_data):
    sample_data()

    response = client.post("/terminal/rfid", data={"rfid_uid": "manager-card"})

    assert response.status_code == 200
    event = db.query(AccessEvent).order_by(AccessEvent.id.desc()).first()
    assert event.client_ip == "testclient"


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
