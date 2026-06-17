from app.core.enums import RoleCode
from app.models.user import User
from app.services.errors import PermissionDeniedError


class PermissionService:
    ACTION_LABELS = {
        "manage_users": "Управление пользователями",
        "manage_roles": "Управление ролями",
        "manage_products": "Управление товарами",
        "manage_cells": "Управление ячейками",
        "view_stock": "Просмотр остатков",
        "view_history": "Просмотр истории",
        "fill": "Пополнение",
        "take": "Выдача",
        "inventory": "Инвентаризация",
        "open_only": "Открытие без изменения остатка",
        "service_open": "Сервисное открытие",
        "emergency_finish_session": "Аварийное завершение сессии",
    }
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
    ALL_ACTIONS = tuple(ACTION_LABELS)

    @classmethod
    def allowed_actions(cls, role) -> set[str]:
        """Return permissions configured for a role."""
        if role.permissions is not None:
            return set(role.permissions)
        try:
            return cls.ROLE_ACTIONS.get(RoleCode(role.code), set())
        except ValueError:
            return set()

    @classmethod
    def require(cls, user: User, action: str) -> None:
        role_code = user.role.code
        allowed = cls.allowed_actions(user.role)
        if action not in allowed:
            raise PermissionDeniedError(f"Role {role_code} cannot perform action {action}")
