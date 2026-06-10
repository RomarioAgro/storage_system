from enum import Enum

from sqlalchemy import Enum as SAEnum


def enum_column(enum_cls: type[Enum]) -> SAEnum:
    return SAEnum(
        enum_cls,
        values_callable=lambda enum: [item.value for item in enum],
        native_enum=False,
        validate_strings=True,
    )
