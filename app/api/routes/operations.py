from fastapi import APIRouter, Depends, Request
from sqlalchemy.orm import Session

from app.api.deps import get_lock_controller
from app.core.client_ip import client_ip_from_request
from app.core.database import get_db
from app.hardware.lock_controller import LockController
from app.schemas.operation import (
    ConfirmOperationRequest,
    FillStartRequest,
    InventoryStartRequest,
    InventorySetRequest,
    OpenOnlyStartRequest,
    TakeStartRequest,
)
from app.schemas.session import SessionResponse
from app.services.errors import InvalidSessionStateError
from app.services.operation_service import OperationService

router = APIRouter()


@router.post("/fill/start", response_model=SessionResponse)
def start_fill(
    request: Request,
    payload: FillStartRequest,
    db: Session = Depends(get_db),
    lock_controller: LockController = Depends(get_lock_controller),
):
    return OperationService.start_fill(
        db=db,
        lock_controller=lock_controller,
        user_id=payload.user_id,
        product_id=payload.product_id,
        cell_id=payload.cell_id,
        quantity=payload.quantity,
        comment=payload.comment,
        client_ip=client_ip_from_request(request),
    )


@router.post("/fill/{session_id}/confirm", response_model=SessionResponse)
def confirm_fill(
    request: Request,
    session_id: int,
    payload: ConfirmOperationRequest,
    db: Session = Depends(get_db),
):
    return OperationService.confirm_fill(
        db,
        session_id=session_id,
        comment=payload.comment,
        client_ip=client_ip_from_request(request),
    )


@router.post("/take/start", response_model=SessionResponse)
def start_take(
    request: Request,
    payload: TakeStartRequest,
    db: Session = Depends(get_db),
    lock_controller: LockController = Depends(get_lock_controller),
):
    return OperationService.start_take(
        db=db,
        lock_controller=lock_controller,
        user_id=payload.user_id,
        product_id=payload.product_id,
        cell_id=payload.cell_id,
        quantity=payload.quantity,
        comment=payload.comment,
        client_ip=client_ip_from_request(request),
    )


@router.post("/take/{session_id}/confirm", response_model=SessionResponse)
def confirm_take(
    request: Request,
    session_id: int,
    payload: ConfirmOperationRequest,
    db: Session = Depends(get_db),
):
    return OperationService.confirm_take(
        db,
        session_id=session_id,
        comment=payload.comment,
        client_ip=client_ip_from_request(request),
    )


@router.post("/open-only/start", response_model=SessionResponse)
def start_open_only(
    request: Request,
    payload: OpenOnlyStartRequest,
    db: Session = Depends(get_db),
    lock_controller: LockController = Depends(get_lock_controller),
):
    return OperationService.start_open_only(
        db=db,
        lock_controller=lock_controller,
        user_id=payload.user_id,
        cell_id=payload.cell_id,
        comment=payload.comment,
        client_ip=client_ip_from_request(request),
    )


@router.post("/open-only/{session_id}/complete", response_model=SessionResponse)
def complete_open_only(request: Request, session_id: int, db: Session = Depends(get_db)):
    return OperationService.complete_open_only(
        db,
        session_id=session_id,
        client_ip=client_ip_from_request(request),
    )


@router.post("/inventory/set")
def inventory_set(payload: InventorySetRequest, db: Session = Depends(get_db)):
    raise InvalidSessionStateError(
        "Direct inventory stock changes are disabled. Use /api/operations/inventory/start, "
        "/api/sessions/{session_id}/confirm-close, and /api/operations/inventory/{session_id}/confirm."
    )


@router.post("/inventory/start", response_model=SessionResponse)
def start_inventory(
    request: Request,
    payload: InventoryStartRequest,
    db: Session = Depends(get_db),
    lock_controller: LockController = Depends(get_lock_controller),
):
    return OperationService.start_inventory(
        db=db,
        lock_controller=lock_controller,
        user_id=payload.user_id,
        product_id=payload.product_id,
        cell_id=payload.cell_id,
        actual_quantity=payload.actual_quantity,
        comment=payload.comment,
        client_ip=client_ip_from_request(request),
    )


@router.post("/inventory/{session_id}/confirm", response_model=SessionResponse)
def confirm_inventory(
    request: Request,
    session_id: int,
    payload: ConfirmOperationRequest,
    db: Session = Depends(get_db),
):
    return OperationService.confirm_inventory(
        db,
        session_id=session_id,
        comment=payload.comment,
        client_ip=client_ip_from_request(request),
    )
