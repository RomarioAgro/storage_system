from app.core.enums import CellStatus, ControllerType, RoleCode, SessionOperationType
from app.models.cell import Cell
from app.models.controller import Controller
from app.models.role import Role
from app.models.user import User
from app.services.errors import ActiveSessionExistsError
from app.services.session_service import SessionService


def test_session_service_blocks_second_active_session(db):
    role = Role(code=RoleCode.USER, name="User")
    db.add(role)
    db.flush()
    user = User(last_name="User", first_name="One", rfid_uid="u-card", role_id=role.id)
    controller = Controller(name="Mock", controller_type=ControllerType.MOCK, address=1)
    db.add_all([user, controller])
    db.flush()
    cell1 = Cell(number=1, status=CellStatus.ACTIVE, controller_id=controller.id, relay_channel=1)
    cell2 = Cell(number=2, status=CellStatus.ACTIVE, controller_id=controller.id, relay_channel=2)
    db.add_all([cell1, cell2])
    db.flush()

    SessionService.create_session(db, user, cell1, SessionOperationType.OPEN_ONLY)

    try:
        SessionService.create_session(db, user, cell2, SessionOperationType.OPEN_ONLY)
    except ActiveSessionExistsError:
        pass
    else:
        raise AssertionError("Expected ActiveSessionExistsError")
