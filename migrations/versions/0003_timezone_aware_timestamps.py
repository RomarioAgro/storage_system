"""timezone-aware timestamps

Revision ID: 0003_timezone_aware_timestamps
Revises: 0002_product_categories
Create Date: 2026-06-10
"""

from alembic import op
import sqlalchemy as sa

revision = "0003_timezone_aware_timestamps"
down_revision = "0002_product_categories"
branch_labels = None
depends_on = None


TIMESTAMP_COLUMNS = {
    "roles": ["created_at", "updated_at"],
    "controllers": ["created_at"],
    "products": ["created_at", "updated_at"],
    "product_categories": ["created_at", "updated_at"],
    "users": ["created_at", "updated_at"],
    "cells": ["created_at", "updated_at"],
    "cell_sessions": [
        "opened_at",
        "close_confirmed_at",
        "completed_at",
        "cancelled_at",
        "created_at",
        "updated_at",
    ],
    "stock_items": ["created_at", "updated_at"],
    "stock_movements": ["created_at"],
    "access_events": ["created_at"],
}


def _alter_timestamp_columns(timezone: bool) -> None:
    bind = op.get_bind()
    if bind.dialect.name == "sqlite":
        return

    target_type = sa.DateTime(timezone=timezone)
    existing_type = sa.DateTime(timezone=not timezone)
    for table_name, column_names in TIMESTAMP_COLUMNS.items():
        for column_name in column_names:
            kwargs = {}
            if bind.dialect.name == "postgresql" and timezone:
                kwargs["postgresql_using"] = f"{column_name} AT TIME ZONE 'UTC'"
            op.alter_column(
                table_name,
                column_name,
                existing_type=existing_type,
                type_=target_type,
                existing_nullable=column_name
                in {"opened_at", "close_confirmed_at", "completed_at", "cancelled_at"},
                **kwargs,
            )


def upgrade() -> None:
    """Convert timestamp columns to timezone-aware storage where supported."""
    _alter_timestamp_columns(timezone=True)


def downgrade() -> None:
    """Convert timestamp columns back to naive storage where supported."""
    _alter_timestamp_columns(timezone=False)
