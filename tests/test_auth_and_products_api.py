from app.core.enums import AccessEventType
from app.models.access_event import AccessEvent


def test_unknown_rfid_is_rejected_and_logged(client, db, sample_data):
    sample_data()

    response = client.post("/api/auth/rfid", json={"rfid_uid": "unknown"})

    assert response.status_code == 403
    event = db.query(AccessEvent).order_by(AccessEvent.id.desc()).first()
    assert event.event_type == AccessEventType.UNKNOWN_RFID
    assert event.client_ip == "testclient"


def test_known_active_rfid_authenticates_and_logs_event(client, db, sample_data):
    data = sample_data()

    response = client.post("/api/auth/rfid", json={"rfid_uid": "user-card"})

    assert response.status_code == 200
    assert response.json()["user_id"] == data["users"]["user"].id
    assert response.json()["name"] == "Regular User"
    event = db.query(AccessEvent).order_by(AccessEvent.id.desc()).first()
    assert event.event_type == AccessEventType.LOGIN_SUCCESS
    assert event.client_ip == "testclient"


def test_product_search_prefers_barcode_before_sku_and_name(client, db, sample_data):
    data = sample_data()

    barcode_response = client.get("/api/products", params={"query": "BAR-1"})
    sku_response = client.get("/api/products", params={"query": "SKU-1"})
    name_response = client.get("/api/products", params={"query": "Battery"})

    assert barcode_response.status_code == 200
    assert barcode_response.json()[0]["id"] == data["product"].id
    assert sku_response.status_code == 200
    assert sku_response.json()[0]["id"] == data["product"].id
    assert name_response.status_code == 200
    assert name_response.json()[0]["id"] == data["name_only_product"].id
