"""stock items positive quantity

Revision ID: 0007_stock_items_positive_quantity
Revises: 0006_access_event_client_ip
Create Date: 2026-06-11
"""

from alembic import op

revision = "0007_stock_items_positive_quantity"
down_revision = "0006_access_event_client_ip"
branch_labels = None
depends_on = None


def upgrade() -> None:
    """Remove empty stock rows and require positive stock item quantities."""
    op.execute("DELETE FROM stock_items WHERE quantity <= 0")
    with op.batch_alter_table("stock_items") as batch_op:
        batch_op.create_check_constraint(
            "ck_stock_items_quantity_positive",
            "quantity > 0",
        )


def downgrade() -> None:
    """Allow zero stock item quantities again."""
    with op.batch_alter_table("stock_items") as batch_op:
        batch_op.drop_constraint("ck_stock_items_quantity_positive", type_="check")
