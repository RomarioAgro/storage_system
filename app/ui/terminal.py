from decimal import Decimal

from fastapi import APIRouter, Depends, Request
from fastapi.responses import HTMLResponse, RedirectResponse, Response
from sqlalchemy import func, select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session, joinedload, selectinload

from app.api.deps import get_lock_controller
from app.core.client_ip import client_ip_from_request
from app.core.database import get_db
from app.core.enums import CellStatus
from app.hardware.lock_controller import LockController
from app.models.cell import Cell
from app.models.product import Product
from app.models.product_category import ProductCategory
from app.models.stock_item import StockItem
from app.models.user import User
from app.services.auth_service import AuthService
from app.services.errors import AppError
from app.services.operation_service import OperationService
from app.services.permission_service import PermissionService
from app.services.session_service import SessionService
from app.ui.templates import templates

router = APIRouter(prefix="/terminal", tags=["terminal-ui"], include_in_schema=False)

PAGE_SIZE_OPTIONS = (20, 50, 100)


def _active_context(db: Session) -> dict[str, object] | None:
    """Build template context for an unfinished active session.

    Args:
        db: SQLAlchemy session.

    Returns:
        Context dictionary when an active session exists, otherwise None.
    """
    session = SessionService.get_active_session(db)
    if session is None:
        return None
    return {"active_session": session}


def _render_blocker(request: Request, db: Session) -> HTMLResponse | None:
    """Render active-session blocking screen when needed.

    Args:
        request: Current HTTP request.
        db: SQLAlchemy session.

    Returns:
        HTML response if the UI must be blocked, otherwise None.
    """
    context = _active_context(db)
    if context is None:
        return None
    return templates.TemplateResponse(request, "terminal/active_session.html", context)


def _get_user(db: Session, user_id: int) -> User:
    """Load an active UI user by id.

    Args:
        db: SQLAlchemy session.
        user_id: User identifier from the current MVP UI form.

    Returns:
        Active user with role loaded.

    Raises:
        AppError: If the user is not active or not found.
    """
    return OperationService._get_user(db, user_id)


def _current_user(request: Request, db: Session) -> User:
    """Return the terminal user stored in the local UI session.

    Args:
        request: Current HTTP request.
        db: SQLAlchemy session.

    Returns:
        Active user with role loaded.

    Raises:
        AppError: If there is no authenticated terminal UI session.
    """
    user_id = request.session.get("terminal_user_id")
    if user_id is None:
        raise AppError("Terminal UI session is not authenticated")
    return _get_user(db, int(user_id))


def _require_user(request: Request, db: Session) -> User | RedirectResponse:
    """Return current terminal user or redirect to RFID prompt."""
    try:
        return _current_user(request, db)
    except AppError:
        return RedirectResponse(url="/terminal", status_code=303)


def _access_client_ip(request: Request) -> str | None:
    """Return the IP address associated with the terminal UI session."""
    return request.session.get("terminal_client_ip") or client_ip_from_request(request)


def _product_stock(db: Session, product_id: int) -> tuple[Decimal, list[StockItem]]:
    """Return total stock and per-cell rows for a product."""
    total = db.scalar(
        select(func.coalesce(func.sum(StockItem.quantity), Decimal("0.000"))).where(
            StockItem.product_id == product_id
        )
    )
    rows = db.scalars(
        select(StockItem)
        .options(joinedload(StockItem.cell), joinedload(StockItem.product))
        .where(StockItem.product_id == product_id, StockItem.quantity > 0)
        .order_by(StockItem.cell_id.asc())
    ).all()
    return total or Decimal("0.000"), list(rows)


def _can_manage_products(user: User) -> bool:
    """Return whether a user can create or edit products.

    Args:
        user: Authenticated terminal user.

    Returns:
        True when the user's role includes product management permission.
    """
    try:
        PermissionService.require(user, "manage_products")
    except AppError:
        return False
    return True


def _can_perform(user: User, action: str) -> bool:
    try:
        PermissionService.require(user, action)
    except AppError:
        return False
    return True


def _terminal_user_context(user: User) -> dict[str, object]:
    return {
        "user": user,
        "can_manage_products": _can_perform(user, "manage_products"),
        "can_fill": _can_perform(user, "fill"),
        "can_take": _can_perform(user, "take"),
        "can_inventory": _can_perform(user, "inventory"),
        "can_open_only": _can_perform(user, "open_only"),
    }


def _active_cells(db: Session) -> list[Cell]:
    return list(
        db.scalars(
            select(Cell)
            .where(Cell.status == CellStatus.ACTIVE)
            .order_by(Cell.number.asc())
        ).all()
    )


def _terminal_error(request: Request, message: str, status_code: int = 400) -> HTMLResponse:
    return templates.TemplateResponse(
        request,
        "terminal/error.html",
        {"error": message},
        status_code=status_code,
    )


def _pagination(page: int, page_size: int, total: int) -> dict[str, int | list[int]]:
    """Build bounded pagination metadata for terminal list screens.

    Args:
        page: Requested 1-based page number.
        page_size: Requested number of rows per page.
        total: Total number of rows available for the list.

    Returns:
        Dictionary with normalized page, page size, total rows, total pages and
        available page-size options.
    """
    normalized_size = page_size if page_size in PAGE_SIZE_OPTIONS else PAGE_SIZE_OPTIONS[0]
    total_pages = max((total + normalized_size - 1) // normalized_size, 1)
    normalized_page = min(max(page, 1), total_pages)
    return {
        "page": normalized_page,
        "page_size": normalized_size,
        "total": total,
        "total_pages": total_pages,
        "page_size_options": list(PAGE_SIZE_OPTIONS),
    }


def _stock_page_query(db: Session, page: int, page_size: int, order_by: str) -> dict[str, object]:
    """Return paginated positive stock rows for terminal stock overview screens.

    Args:
        db: SQLAlchemy session.
        page: Requested page number.
        page_size: Requested rows per page.
        order_by: Sort mode: ``product`` or ``cell``.

    Returns:
        Template context with stock rows and pagination metadata.
    """
    total = db.scalar(select(func.count()).select_from(StockItem).where(StockItem.quantity > 0)) or 0
    pagination = _pagination(page, page_size, total)
    sort_columns = (
        (Product.name.asc(), Cell.number.asc())
        if order_by == "product"
        else (Cell.number.asc(), Product.name.asc())
    )
    rows = db.scalars(
        select(StockItem)
        .join(StockItem.product)
        .join(StockItem.cell)
        .options(joinedload(StockItem.product), joinedload(StockItem.cell))
        .where(StockItem.quantity > 0)
        .order_by(*sort_columns)
        .offset((int(pagination["page"]) - 1) * int(pagination["page_size"]))
        .limit(int(pagination["page_size"]))
    ).all()
    return {"rows": rows, "pagination": pagination}


def _product_stock_page_query(
    db: Session,
    page: int,
    page_size: int,
    show_zero: bool = False,
    show_without_cells: bool = False,
) -> dict[str, object]:
    """Return paginated product-first stock rows for terminal overview.

    Args:
        db: SQLAlchemy session.
        page: Requested page number.
        page_size: Requested rows per page.
        show_zero: Include stock rows with zero quantity.
        show_without_cells: Include products that have no stock rows.

    Returns:
        Template context with product rows, filters and pagination metadata.
    """
    products = db.scalars(
        select(Product)
        .options(selectinload(Product.stock_items).joinedload(StockItem.cell))
        .where(Product.is_active.is_(True))
        .order_by(Product.name.asc())
    ).all()
    rows = []
    for product in products:
        stock_items = sorted(
            product.stock_items,
            key=lambda stock_item: stock_item.cell.number if stock_item.cell else 0,
        )
        visible_items = [
            stock_item for stock_item in stock_items if stock_item.quantity > 0 or show_zero
        ]
        for stock_item in visible_items:
            rows.append(
                {
                    "product": product,
                    "cell": stock_item.cell,
                    "quantity": stock_item.quantity,
                }
            )
        if (show_zero or show_without_cells) and not visible_items:
            rows.append({"product": product, "cell": None, "quantity": Decimal("0.000")})

    pagination = _pagination(page, page_size, len(rows))
    start = (int(pagination["page"]) - 1) * int(pagination["page_size"])
    end = start + int(pagination["page_size"])
    return {
        "rows": rows[start:end],
        "pagination": pagination,
        "show_zero": show_zero,
        "show_without_cells": show_without_cells,
    }


@router.get("", response_class=HTMLResponse)
def terminal_home(request: Request, db: Session = Depends(get_db)) -> HTMLResponse:
    """Show RFID prompt or active-session blocking screen."""
    blocker = _render_blocker(request, db)
    if blocker:
        return blocker
    return templates.TemplateResponse(request, "terminal/rfid.html")


@router.post("/rfid", response_class=HTMLResponse)
async def terminal_rfid(request: Request, db: Session = Depends(get_db)) -> HTMLResponse:
    """Authenticate RFID card and show the terminal menu."""
    form = await request.form()
    rfid_uid = str(form.get("rfid_uid", "")).strip()
    blocker = _render_blocker(request, db)
    if blocker:
        return blocker
    try:
        client_ip = client_ip_from_request(request)
        user = AuthService.authenticate_rfid(
            db,
            rfid_uid,
            client_ip=client_ip,
        )
    except AppError:
        return templates.TemplateResponse(
            request,
            "terminal/rfid.html",
            {"error": "Ключ не найден или заблокирован"},
            status_code=403,
        )
    request.session["terminal_user_id"] = user.id
    request.session["terminal_client_ip"] = client_ip
    return templates.TemplateResponse(
        request,
        "terminal/menu.html",
        _terminal_user_context(user),
    )


@router.get("/menu", response_class=HTMLResponse)
def terminal_menu(request: Request, db: Session = Depends(get_db)) -> Response:
    """Show the terminal main menu for an authenticated MVP user."""
    blocker = _render_blocker(request, db)
    if blocker:
        return blocker
    user = _require_user(request, db)
    if isinstance(user, RedirectResponse):
        return user
    return templates.TemplateResponse(
        request,
        "terminal/menu.html",
        _terminal_user_context(user),
    )


@router.get("/products/new", response_class=HTMLResponse)
def new_product_form(request: Request, db: Session = Depends(get_db)) -> Response:
    """Show product creation form for managers and admins."""
    blocker = _render_blocker(request, db)
    if blocker:
        return blocker
    user = _require_user(request, db)
    if isinstance(user, RedirectResponse):
        return user
    try:
        PermissionService.require(user, "manage_products")
    except AppError as exc:
        return _terminal_error(request, str(exc), exc.status_code)
    categories = db.scalars(
        select(ProductCategory)
        .where(ProductCategory.is_active.is_(True))
        .order_by(
            ProductCategory.parent_id.asc().nullsfirst(),
            ProductCategory.sort_order.asc(),
            ProductCategory.name.asc(),
        )
    ).all()
    return templates.TemplateResponse(
        request,
        "terminal/new_product.html",
        {"user": user, "categories": categories},
    )


@router.post("/products", response_class=HTMLResponse)
async def create_product(request: Request, db: Session = Depends(get_db)) -> Response:
    """Create a product from terminal UI when the role allows it."""
    blocker = _render_blocker(request, db)
    if blocker:
        return blocker
    try:
        user = _current_user(request, db)
        PermissionService.require(user, "manage_products")
    except AppError as exc:
        return _terminal_error(request, str(exc), exc.status_code)
    form = await request.form()
    category_id = int(form["category_id"]) if form.get("category_id") else None
    if category_id is not None and db.get(ProductCategory, category_id) is None:
        from app.services.errors import NotFoundError

        raise NotFoundError("Product category not found")
    product = Product(
        name=str(form["name"]).strip(),
        sku=str(form.get("sku") or "").strip() or None,
        barcode=str(form.get("barcode") or "").strip() or None,
        unit=str(form.get("unit") or "pcs").strip() or "pcs",
        external_id=str(form.get("external_id") or "").strip() or None,
        category_id=category_id,
    )
    db.add(product)
    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        categories = db.scalars(
            select(ProductCategory)
            .where(ProductCategory.is_active.is_(True))
            .order_by(
                ProductCategory.parent_id.asc().nullsfirst(),
                ProductCategory.sort_order.asc(),
                ProductCategory.name.asc(),
            )
        ).all()
        return templates.TemplateResponse(
            request,
            "terminal/new_product.html",
            {
                "user": user,
                "categories": categories,
                "error": "Product with the same SKU, barcode, or external ID already exists",
            },
            status_code=409,
        )
    db.refresh(product)
    return RedirectResponse(url=f"/terminal/products/{product.id}", status_code=303)


@router.get("/search", response_class=HTMLResponse)
def search_products(
    request: Request,
    query: str = "",
    db: Session = Depends(get_db),
) -> Response:
    """Search products from terminal UI."""
    blocker = _render_blocker(request, db)
    if blocker:
        return blocker
    user = _require_user(request, db)
    if isinstance(user, RedirectResponse):
        return user
    products: list[Product] = []
    q = query.strip()
    if q:
        statement = select(Product).where(Product.is_active.is_(True))
        products = list(db.scalars(statement.where(Product.barcode == q)).all())
        if not products:
            products = list(db.scalars(statement.where(Product.sku == q)).all())
        if not products:
            products = list(
                db.scalars(statement.where(Product.name.ilike(f"%{q}%")).order_by(Product.name.asc())).all()
            )
    return templates.TemplateResponse(
        request,
        "terminal/search.html",
        {"user": user, "query": query, "products": products},
    )


@router.get("/products/{product_id}", response_class=HTMLResponse)
def product_card(
    request: Request,
    product_id: int,
    db: Session = Depends(get_db),
) -> Response:
    """Show product card with stock and operation forms."""
    blocker = _render_blocker(request, db)
    if blocker:
        return blocker
    user = _require_user(request, db)
    if isinstance(user, RedirectResponse):
        return user
    product = db.get(Product, product_id)
    cells = _active_cells(db)
    total, stock_rows = _product_stock(db, product_id)
    active_stock_rows = [row for row in stock_rows if row.cell and row.cell.status == CellStatus.ACTIVE]
    return templates.TemplateResponse(
        request,
        "terminal/product.html",
        {
            "user": user,
            "product": product,
            "cells": cells,
            "stock_rows": stock_rows,
            "active_stock_rows": active_stock_rows,
            "total": total,
            "can_fill": _can_perform(user, "fill"),
            "can_take": _can_perform(user, "take"),
            "can_inventory": _can_perform(user, "inventory"),
        },
    )


@router.post("/fill/start", response_class=HTMLResponse)
async def start_fill(
    request: Request,
    db: Session = Depends(get_db),
    lock_controller: LockController = Depends(get_lock_controller),
) -> HTMLResponse:
    """Start a fill operation from terminal UI."""
    blocker = _render_blocker(request, db)
    if blocker:
        return blocker
    form = await request.form()
    user = _current_user(request, db)
    try:
        session = OperationService.start_fill(
            db=db,
            lock_controller=lock_controller,
            user_id=user.id,
            product_id=int(form["product_id"]),
            cell_id=int(form["cell_id"]),
            quantity=Decimal(str(form["quantity"])),
            comment=str(form.get("comment") or ""),
            client_ip=_access_client_ip(request),
        )
    except AppError as exc:
        return _terminal_error(request, str(exc), exc.status_code)
    return templates.TemplateResponse(
        request,
        "terminal/opened.html",
        {"session": session, "next_action": "fill"},
    )


@router.post("/take/start", response_class=HTMLResponse)
async def start_take(
    request: Request,
    db: Session = Depends(get_db),
    lock_controller: LockController = Depends(get_lock_controller),
) -> HTMLResponse:
    """Start a take operation from terminal UI."""
    blocker = _render_blocker(request, db)
    if blocker:
        return blocker
    form = await request.form()
    user = _current_user(request, db)
    try:
        session = OperationService.start_take(
            db=db,
            lock_controller=lock_controller,
            user_id=user.id,
            product_id=int(form["product_id"]),
            cell_id=int(form["cell_id"]),
            quantity=Decimal(str(form["quantity"])),
            comment=str(form.get("comment") or ""),
            client_ip=_access_client_ip(request),
        )
    except AppError as exc:
        return _terminal_error(request, str(exc), exc.status_code)
    return templates.TemplateResponse(
        request,
        "terminal/opened.html",
        {"session": session, "next_action": "take"},
    )


@router.post("/inventory/start", response_class=HTMLResponse)
async def start_inventory(
    request: Request,
    db: Session = Depends(get_db),
    lock_controller: LockController = Depends(get_lock_controller),
) -> HTMLResponse:
    """Start an inventory operation from terminal UI."""
    blocker = _render_blocker(request, db)
    if blocker:
        return blocker
    form = await request.form()
    user = _current_user(request, db)
    try:
        session = OperationService.start_inventory(
            db=db,
            lock_controller=lock_controller,
            user_id=user.id,
            product_id=int(form["product_id"]),
            cell_id=int(form["cell_id"]),
            actual_quantity=Decimal(str(form["actual_quantity"])),
            comment=str(form.get("comment") or ""),
            client_ip=_access_client_ip(request),
        )
    except AppError as exc:
        return _terminal_error(request, str(exc), exc.status_code)
    return templates.TemplateResponse(
        request,
        "terminal/opened.html",
        {"session": session, "next_action": "inventory"},
    )


@router.get("/cell-contents", response_class=HTMLResponse)
def cell_contents_form(
    request: Request,
    cell_id: int | None = None,
    db: Session = Depends(get_db),
) -> Response:
    """Show cell contents lookup screen."""
    blocker = _render_blocker(request, db)
    if blocker:
        return blocker
    user = _require_user(request, db)
    if isinstance(user, RedirectResponse):
        return user
    cells = db.scalars(select(Cell).order_by(Cell.number.asc())).all()
    rows = []
    selected_cell = None
    if cell_id:
        selected_cell = db.get(Cell, cell_id)
        rows = db.scalars(
            select(StockItem)
            .options(joinedload(StockItem.product))
            .where(StockItem.cell_id == cell_id, StockItem.quantity > 0)
            .order_by(StockItem.product_id.asc())
        ).all()
    return templates.TemplateResponse(
        request,
        "terminal/cell_contents.html",
        {
            "user": user,
            "cells": cells,
            "selected_cell": selected_cell,
            "rows": rows,
        },
    )


@router.get("/stock/products", response_class=HTMLResponse)
def stock_by_products(
    request: Request,
    page: int = 1,
    page_size: int = PAGE_SIZE_OPTIONS[0],
    show_zero: bool = False,
    show_without_cells: bool = False,
    db: Session = Depends(get_db),
) -> Response:
    """Show all positive stock rows grouped visually by product."""
    user = _require_user(request, db)
    if isinstance(user, RedirectResponse):
        return user
    context = _product_stock_page_query(
        db,
        page=page,
        page_size=page_size,
        show_zero=show_zero,
        show_without_cells=show_without_cells,
    )
    context["user"] = user
    return templates.TemplateResponse(request, "terminal/stock_by_products.html", context)


@router.get("/stock/cells", response_class=HTMLResponse)
def stock_by_cells(
    request: Request,
    page: int = 1,
    page_size: int = PAGE_SIZE_OPTIONS[0],
    db: Session = Depends(get_db),
) -> Response:
    """Show all positive stock rows grouped visually by cell."""
    user = _require_user(request, db)
    if isinstance(user, RedirectResponse):
        return user
    context = _stock_page_query(db, page=page, page_size=page_size, order_by="cell")
    context["user"] = user
    return templates.TemplateResponse(request, "terminal/stock_by_cells.html", context)


@router.get("/open-only", response_class=HTMLResponse)
def open_only_form(request: Request, db: Session = Depends(get_db)) -> Response:
    """Show service opening form."""
    blocker = _render_blocker(request, db)
    if blocker:
        return blocker
    user = _require_user(request, db)
    if isinstance(user, RedirectResponse):
        return user
    try:
        PermissionService.require(user, "open_only")
    except AppError as exc:
        return _terminal_error(request, str(exc), exc.status_code)
    cells = _active_cells(db)
    return templates.TemplateResponse(
        request,
        "terminal/open_only.html",
        {"user": user, "cells": cells},
    )


@router.post("/open-only/start", response_class=HTMLResponse)
async def start_open_only(
    request: Request,
    db: Session = Depends(get_db),
    lock_controller: LockController = Depends(get_lock_controller),
) -> HTMLResponse:
    """Start open-only operation from terminal UI."""
    blocker = _render_blocker(request, db)
    if blocker:
        return blocker
    form = await request.form()
    user = _current_user(request, db)
    try:
        session = OperationService.start_open_only(
            db=db,
            lock_controller=lock_controller,
            user_id=user.id,
            cell_id=int(form["cell_id"]),
            comment=str(form.get("comment") or ""),
            client_ip=_access_client_ip(request),
        )
    except AppError as exc:
        return _terminal_error(request, str(exc), exc.status_code)
    return templates.TemplateResponse(
        request,
        "terminal/opened.html",
        {"session": session, "next_action": "open_only"},
    )


@router.post("/sessions/{session_id}/confirm-close", response_class=HTMLResponse)
async def confirm_close(request: Request, session_id: int, db: Session = Depends(get_db)) -> HTMLResponse:
    """Confirm that the physical cell was closed."""
    form = await request.form()
    next_action = str(form.get("next_action") or "")
    session = SessionService.confirm_close(
        db,
        session_id=session_id,
        client_ip=_access_client_ip(request),
    )
    return templates.TemplateResponse(
        request,
        "terminal/confirm_operation.html",
        {"session": session, "next_action": next_action},
    )


@router.post("/fill/{session_id}/confirm", response_class=HTMLResponse)
async def confirm_fill(request: Request, session_id: int, db: Session = Depends(get_db)) -> HTMLResponse:
    """Confirm fill operation and apply stock change."""
    form = await request.form()
    session = OperationService.confirm_fill(
        db,
        session_id=session_id,
        comment=str(form.get("comment") or ""),
        client_ip=_access_client_ip(request),
    )
    return templates.TemplateResponse(request, "terminal/done.html", {"session": session})


@router.post("/take/{session_id}/confirm", response_class=HTMLResponse)
async def confirm_take(request: Request, session_id: int, db: Session = Depends(get_db)) -> HTMLResponse:
    """Confirm take operation and apply stock change."""
    form = await request.form()
    session = OperationService.confirm_take(
        db,
        session_id=session_id,
        comment=str(form.get("comment") or ""),
        client_ip=_access_client_ip(request),
    )
    return templates.TemplateResponse(request, "terminal/done.html", {"session": session})


@router.post("/inventory/{session_id}/confirm", response_class=HTMLResponse)
async def confirm_inventory(request: Request, session_id: int, db: Session = Depends(get_db)) -> HTMLResponse:
    """Confirm inventory operation and apply stock count."""
    form = await request.form()
    session = OperationService.confirm_inventory(
        db,
        session_id=session_id,
        comment=str(form.get("comment") or ""),
        client_ip=_access_client_ip(request),
    )
    return templates.TemplateResponse(request, "terminal/done.html", {"session": session})


@router.post("/open-only/{session_id}/complete", response_class=HTMLResponse)
def complete_open_only(request: Request, session_id: int, db: Session = Depends(get_db)) -> HTMLResponse:
    """Complete open-only session after close confirmation."""
    session = OperationService.complete_open_only(
        db,
        session_id=session_id,
        client_ip=_access_client_ip(request),
    )
    return templates.TemplateResponse(request, "terminal/done.html", {"session": session})


@router.post("/sessions/{session_id}/cancel", response_class=HTMLResponse)
async def cancel_session(request: Request, session_id: int, db: Session = Depends(get_db)) -> HTMLResponse:
    """Cancel active session without changing stock."""
    form = await request.form()
    session = SessionService.cancel(
        db,
        session_id=session_id,
        reason=str(form.get("reason") or "UI cancel"),
        client_ip=_access_client_ip(request),
    )
    return templates.TemplateResponse(request, "terminal/done.html", {"session": session})


@router.get("/logout", response_class=HTMLResponse)
def logout(request: Request) -> RedirectResponse:
    """Return to RFID prompt."""
    request.session.clear()
    return RedirectResponse(url="/terminal", status_code=303)
