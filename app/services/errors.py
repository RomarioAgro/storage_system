class AppError(RuntimeError):
    status_code = 400


class NotFoundError(AppError):
    status_code = 404


class PermissionDeniedError(AppError):
    status_code = 403


class ActiveSessionExistsError(AppError):
    status_code = 409


class InvalidSessionStateError(AppError):
    status_code = 409


class InsufficientStockError(AppError):
    status_code = 409
