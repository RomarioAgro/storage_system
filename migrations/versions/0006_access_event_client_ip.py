"""access event client ip

Revision ID: 0006_access_event_client_ip
Revises: 0005_user_fio_department
Create Date: 2026-06-11
"""

from alembic import op
import sqlalchemy as sa

revision = "0006_access_event_client_ip"
down_revision = "0005_user_fio_department"
branch_labels = None
depends_on = None


def upgrade() -> None:
    """Add client IP address to access events."""
    with op.batch_alter_table("access_events") as batch_op:
        batch_op.add_column(sa.Column("client_ip", sa.String(length=64), nullable=True))
        batch_op.create_index("ix_access_events_client_ip", ["client_ip"])


def downgrade() -> None:
    """Drop client IP address from access events."""
    with op.batch_alter_table("access_events") as batch_op:
        batch_op.drop_index("ix_access_events_client_ip")
        batch_op.drop_column("client_ip")
