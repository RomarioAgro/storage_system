from datetime import UTC, datetime

from app.core.enums import CellStatus, RoleCode
from app.core.enums import AccessEventType, EventResult
from app.models.access_event import AccessEvent
from app.models.product_category import ProductCategory


def test_admin_can_update_and_block_user(client, db, sample_data):
    data = sample_data()
    user = data["users"]["user"]
    manager_role = data["roles"][RoleCode.MANAGER]

    response = client.post(
        f"/admin/users/{user.id}",
        data={
            "name": "Updated User",
            "rfid_uid": "updated-card",
            "role_id": str(manager_role.id),
            "is_active": "on",
        },
        follow_redirects=False,
    )
    assert response.status_code == 303
    db.refresh(user)
    assert user.name == "Updated User"
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
    assert "Создать пользователя" in response.text
    assert "Блокировать" in response.text
    assert "Группы товаров" in response.text


def test_admin_access_log_displays_local_time(client, db, sample_data):
    sample_data()
    db.add(
        AccessEvent(
            created_at=datetime(2026, 6, 10, 10, 0, 0, tzinfo=UTC),
            event_type=AccessEventType.LOGIN_SUCCESS,
            result=EventResult.OK,
            details="timezone check",
        )
    )
    db.commit()

    response = client.get("/admin")

    assert response.status_code == 200
    assert "Europe/Moscow" in response.text
    assert "2026-06-10 13:00:00 +03:00" in response.text


def test_admin_can_create_and_disable_product_category(client, db, sample_data):
    sample_data()

    created = client.post(
        "/admin/categories",
        data={"name": "Картриджи", "sort_order": "5", "is_active": "on"},
        follow_redirects=False,
    )

    assert created.status_code == 303
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
    db.refresh(cell)
    assert cell.number == 101
    assert cell.controller_address == 7
    assert cell.relay_channel == 9
    assert cell.comment == "updated"

    response = client.post(f"/admin/cells/{cell.id}/toggle-block", follow_redirects=False)
    assert response.status_code == 303
    db.refresh(cell)
    assert cell.status == CellStatus.BLOCKED
