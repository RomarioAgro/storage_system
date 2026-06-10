from app.core.enums import RoleCode
from app.models.user import User
from app.services.errors import PermissionDeniedError


class PermissionService:
    ROLE_ACTIONS = {
        RoleCode.ADMIN: {
            "manage_users",
            "manage_roles",
            "manage_products",
            "manage_cells",
            "view_stock",
            "view_history",
            "fill",
            "take",
            "inventory",
            "open_only",
            "service_open",
            "emergency_finish_session",
        },
        RoleCode.MANAGER: {
            "manage_products",
            "view_stock",
            "view_history",
            "fill",
            "take",
            "inventory",
            "open_only",
        },
        RoleCode.USER: {"view_stock", "fill", "take"},
        RoleCode.SERVICE: {"service_open", "open_only"},
    }

    @classmethod
    def require(cls, user: User, action: str) -> None:
        role_code = user.role.code
        allowed = cls.ROLE_ACTIONS.get(role_code, set())
        if action not in allowed:
            raise PermissionDeniedError(f"Role {role_code} cannot perform action {action}")
