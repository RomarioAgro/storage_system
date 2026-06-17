"""role permissions

Revision ID: 0008_role_permissions
Revises: 0007_stock_items_positive_quantity
Create Date: 2026-06-17
"""

from alembic import op
import sqlalchemy as sa

from app.services.permission_service import PermissionService

revision = "0008_role_permissions"
down_revision = "0007_stock_items_positive_quantity"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("roles", sa.Column("permissions", sa.JSON(), nullable=True))
    roles = sa.table(
        "roles",
        sa.column("code", sa.String()),
        sa.column("permissions", sa.JSON()),
    )
    connection = op.get_bind()
    for code, permissions in PermissionService.ROLE_ACTIONS.items():
        connection.execute(
            roles.update()
            .where(roles.c.code == code.value)
            .where(roles.c.permissions.is_(None))
            .values(permissions=sorted(permissions))
        )


def downgrade() -> None:
    op.drop_column("roles", "permissions")
