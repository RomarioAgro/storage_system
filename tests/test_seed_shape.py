from app.core.enums import RoleCode
from app.models.role import Role


def test_role_model_accepts_role_code(db):
    role = Role(code=RoleCode.ADMIN, name="Administrator")
    db.add(role)
    db.commit()
    assert role.id is not None
