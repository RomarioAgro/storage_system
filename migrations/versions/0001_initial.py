"""initial schema

Revision ID: 0001_initial
Revises:
Create Date: 2026-06-10
"""
from alembic import op
import sqlalchemy as sa

revision = "0001_initial"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    role_code = sa.Enum("admin", "manager", "user", "service", name="rolecode", native_enum=False)
    controller_type = sa.Enum("mock", "usb_relay", "modbus_rtu", name="controllertype", native_enum=False)
    cell_status = sa.Enum("active", "blocked", "maintenance", name="cellstatus", native_enum=False)
    movement_type = sa.Enum(
        "fill", "take", "move_in", "move_out", "adjust", "inventory", name="movementtype", native_enum=False
    )
    access_event_type = sa.Enum(
        "login_success",
        "unknown_rfid",
        "access_denied",
        "open_cell_success",
        "open_cell_failed",
        "close_confirmed",
        "session_started",
        "session_completed",
        "session_cancelled",
        "session_timeout",
        "relay_error",
        "system_startup",
        name="accesseventtype",
        native_enum=False,
    )
    event_result = sa.Enum("ok", "denied", "error", name="eventresult", native_enum=False)
    session_operation_type = sa.Enum(
        "fill", "take", "open_only", "inventory", "move_from", "move_to", name="sessionoperationtype", native_enum=False
    )
    session_status = sa.Enum(
        "created", "opening", "opened", "waiting_close", "close_confirmed", "completed", "cancelled", "error",
        name="sessionstatus",
        native_enum=False,
    )

    op.create_table(
        "roles",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("code", role_code, nullable=False),
        sa.Column("name", sa.String(length=100), nullable=False),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.text("true")),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.Column("updated_at", sa.DateTime(), nullable=False),
        sa.UniqueConstraint("code"),
        sa.UniqueConstraint("name"),
    )
    op.create_index("ix_roles_code", "roles", ["code"])

    op.create_table(
        "controllers",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("name", sa.String(length=200), nullable=False),
        sa.Column("controller_type", controller_type, nullable=False),
        sa.Column("address", sa.Integer(), nullable=True),
        sa.Column("port", sa.String(length=100), nullable=True),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.text("true")),
        sa.Column("comment", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.UniqueConstraint("name"),
    )
    op.create_index("ix_controllers_controller_type", "controllers", ["controller_type"])

    op.create_table(
        "products",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("name", sa.String(length=300), nullable=False),
        sa.Column("sku", sa.String(length=100), nullable=True),
        sa.Column("barcode", sa.String(length=100), nullable=True),
        sa.Column("unit", sa.String(length=20), nullable=False),
        sa.Column("external_id", sa.String(length=100), nullable=True),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.text("true")),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.Column("updated_at", sa.DateTime(), nullable=False),
        sa.UniqueConstraint("sku"),
        sa.UniqueConstraint("barcode"),
        sa.UniqueConstraint("external_id"),
    )
    op.create_index("ix_products_name", "products", ["name"])
    op.create_index("ix_products_sku", "products", ["sku"])
    op.create_index("ix_products_barcode", "products", ["barcode"])
    op.create_index("ix_products_external_id", "products", ["external_id"])

    op.create_table(
        "users",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("name", sa.String(length=200), nullable=False),
        sa.Column("rfid_uid", sa.String(length=128), nullable=False),
        sa.Column("role_id", sa.Integer(), sa.ForeignKey("roles.id"), nullable=False),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.text("true")),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.Column("updated_at", sa.DateTime(), nullable=False),
        sa.UniqueConstraint("rfid_uid"),
    )
    op.create_index("ix_users_name", "users", ["name"])
    op.create_index("ix_users_rfid_uid", "users", ["rfid_uid"])
    op.create_index("ix_users_role_id", "users", ["role_id"])

    op.create_table(
        "cells",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("number", sa.Integer(), nullable=False),
        sa.Column("status", cell_status, nullable=False),
        sa.Column("controller_id", sa.Integer(), sa.ForeignKey("controllers.id"), nullable=True),
        sa.Column("controller_address", sa.Integer(), nullable=True),
        sa.Column("relay_channel", sa.Integer(), nullable=True),
        sa.Column("has_close_sensor", sa.Boolean(), nullable=False, server_default=sa.text("false")),
        sa.Column("close_sensor_controller_address", sa.Integer(), nullable=True),
        sa.Column("close_sensor_channel", sa.Integer(), nullable=True),
        sa.Column("comment", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.Column("updated_at", sa.DateTime(), nullable=False),
        sa.UniqueConstraint("number"),
    )
    op.create_index("ix_cells_number", "cells", ["number"])

    op.create_table(
        "cell_sessions",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("user_id", sa.Integer(), sa.ForeignKey("users.id"), nullable=False),
        sa.Column("cell_id", sa.Integer(), sa.ForeignKey("cells.id"), nullable=False),
        sa.Column("operation_type", session_operation_type, nullable=False),
        sa.Column("status", session_status, nullable=False),
        sa.Column("product_id", sa.Integer(), sa.ForeignKey("products.id"), nullable=True),
        sa.Column("planned_quantity", sa.Numeric(12, 3), nullable=True),
        sa.Column("opened_at", sa.DateTime(), nullable=True),
        sa.Column("close_confirmed_at", sa.DateTime(), nullable=True),
        sa.Column("completed_at", sa.DateTime(), nullable=True),
        sa.Column("cancelled_at", sa.DateTime(), nullable=True),
        sa.Column("cancel_reason", sa.Text(), nullable=True),
        sa.Column("comment", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.Column("updated_at", sa.DateTime(), nullable=False),
    )
    op.create_index("ix_cell_sessions_user_id", "cell_sessions", ["user_id"])
    op.create_index("ix_cell_sessions_cell_id", "cell_sessions", ["cell_id"])
    op.create_index("ix_cell_sessions_status", "cell_sessions", ["status"])
    op.create_index("ix_cell_sessions_product_id", "cell_sessions", ["product_id"])
    op.execute(
        "CREATE UNIQUE INDEX only_one_active_cell_session "
        "ON cell_sessions ((true)) "
        "WHERE status IN ('created','opening','opened','waiting_close','close_confirmed')"
    )

    op.create_table(
        "stock_items",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("cell_id", sa.Integer(), sa.ForeignKey("cells.id"), nullable=False),
        sa.Column("product_id", sa.Integer(), sa.ForeignKey("products.id"), nullable=False),
        sa.Column("quantity", sa.Numeric(12, 3), nullable=False),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.Column("updated_at", sa.DateTime(), nullable=False),
        sa.UniqueConstraint("cell_id", "product_id", name="uq_stock_cell_product"),
    )
    op.create_index("ix_stock_items_cell_id", "stock_items", ["cell_id"])
    op.create_index("ix_stock_items_product_id", "stock_items", ["product_id"])

    op.create_table(
        "stock_movements",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.Column("user_id", sa.Integer(), sa.ForeignKey("users.id"), nullable=True),
        sa.Column("product_id", sa.Integer(), sa.ForeignKey("products.id"), nullable=False),
        sa.Column("cell_id", sa.Integer(), sa.ForeignKey("cells.id"), nullable=False),
        sa.Column("session_id", sa.Integer(), sa.ForeignKey("cell_sessions.id"), nullable=True),
        sa.Column("movement_type", movement_type, nullable=False),
        sa.Column("quantity", sa.Numeric(12, 3), nullable=False),
        sa.Column("quantity_before", sa.Numeric(12, 3), nullable=False),
        sa.Column("quantity_after", sa.Numeric(12, 3), nullable=False),
        sa.Column("comment", sa.Text(), nullable=True),
    )
    op.create_index("ix_stock_movements_created_at", "stock_movements", ["created_at"])
    op.create_index("ix_stock_movements_user_id", "stock_movements", ["user_id"])
    op.create_index("ix_stock_movements_product_id", "stock_movements", ["product_id"])
    op.create_index("ix_stock_movements_cell_id", "stock_movements", ["cell_id"])
    op.create_index("ix_stock_movements_session_id", "stock_movements", ["session_id"])
    op.create_index("ix_stock_movements_movement_type", "stock_movements", ["movement_type"])

    op.create_table(
        "access_events",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.Column("user_id", sa.Integer(), sa.ForeignKey("users.id"), nullable=True),
        sa.Column("rfid_uid", sa.String(length=128), nullable=True),
        sa.Column("cell_id", sa.Integer(), sa.ForeignKey("cells.id"), nullable=True),
        sa.Column("session_id", sa.Integer(), sa.ForeignKey("cell_sessions.id"), nullable=True),
        sa.Column("event_type", access_event_type, nullable=False),
        sa.Column("result", event_result, nullable=False),
        sa.Column("details", sa.Text(), nullable=True),
    )
    op.create_index("ix_access_events_created_at", "access_events", ["created_at"])
    op.create_index("ix_access_events_user_id", "access_events", ["user_id"])
    op.create_index("ix_access_events_rfid_uid", "access_events", ["rfid_uid"])
    op.create_index("ix_access_events_cell_id", "access_events", ["cell_id"])
    op.create_index("ix_access_events_session_id", "access_events", ["session_id"])
    op.create_index("ix_access_events_event_type", "access_events", ["event_type"])
    op.create_index("ix_access_events_result", "access_events", ["result"])


def downgrade() -> None:
    op.drop_table("access_events")
    op.drop_table("stock_movements")
    op.drop_table("stock_items")
    op.drop_index("only_one_active_cell_session", table_name="cell_sessions")
    op.drop_table("cell_sessions")
    op.drop_table("cells")
    op.drop_table("users")
    op.drop_table("products")
    op.drop_table("controllers")
    op.drop_table("roles")
