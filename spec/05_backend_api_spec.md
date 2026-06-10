# 05. Backend API

## Общие требования

- Backend: FastAPI.
- Все операции, меняющие состояние, должны быть транзакционными.
- Проверка прав выполняется в backend.
- UI не должен быть единственным уровнем защиты.
- Hardware layer вызывается только после успешных проверок.
- Ошибки оборудования пишутся в журнал.

## Базовые группы API

- `/api/auth` — RFID-авторизация;
- `/api/products` — товары;
- `/api/cells` — ячейки;
- `/api/operations` — операции с товарами;
- `/api/sessions` — сессии открытия;
- `/api/admin` — администрирование;
- `/api/hardware` — оборудование, диагностика.

## POST `/api/auth/rfid`

Авторизация по RFID.

Request:

```json
{
  "rfid_uid": "admin-card"
}
```

Success response:

```json
{
  "user_id": 1,
  "name": "Администратор",
  "role": "admin"
}
```

Error response:

```json
{
  "error": "unknown_rfid",
  "message": "Ключ не найден"
}
```

Побочные эффекты:

- `login_success` при успехе;
- `unknown_rfid` при неизвестном ключе;
- `access_denied` при заблокированном пользователе.

## GET `/api/products?query=...`

Поиск товаров.

Порядок поиска:

1. точное совпадение `barcode`;
2. точное совпадение `sku`;
3. поиск по `name`.

Response:

```json
[
  {
    "id": 1,
    "name": "Кабель HDMI 2м",
    "sku": "HDMI-2M",
    "barcode": "460000000001",
    "unit": "шт",
    "total_quantity": "12.000"
  }
]
```

## POST `/api/products`

Создать товар.

Request:

```json
{
  "name": "Кабель HDMI 2м",
  "sku": "HDMI-2M",
  "barcode": "460000000001",
  "unit": "шт",
  "external_id": null
}
```

Права:

- `admin`;
- `manager`.

## GET `/api/products/{product_id}/stock`

Вернуть общий остаток и ячейки, где лежит товар.

Response:

```json
{
  "product_id": 1,
  "name": "Кабель HDMI 2м",
  "total_quantity": "12.000",
  "cells": [
    {
      "cell_id": 2,
      "cell_number": "2",
      "quantity": "5.000"
    },
    {
      "cell_id": 5,
      "cell_number": "5",
      "quantity": "7.000"
    }
  ]
}
```

## GET `/api/products/{product_id}/history`

История движения товара.

Response:

```json
[
  {
    "created_at": "2026-06-10T10:00:00Z",
    "movement_type": "fill",
    "quantity": "5.000",
    "quantity_before": "0.000",
    "quantity_after": "5.000",
    "cell_id": 2,
    "cell_number": "2",
    "user_name": "Иван"
  }
]
```

## GET `/api/cells`

Список ячеек.

Response:

```json
[
  {
    "id": 1,
    "number": "1",
    "status": "active",
    "controller_id": 1,
    "relay_channel": 1,
    "has_close_sensor": false
  }
]
```

## GET `/api/cells/{cell_id}/contents`

Содержимое ячейки.

Response:

```json
{
  "cell_id": 2,
  "cell_number": "2",
  "items": [
    {
      "product_id": 1,
      "name": "Кабель HDMI 2м",
      "sku": "HDMI-2M",
      "quantity": "5.000",
      "unit": "шт"
    }
  ]
}
```

## POST `/api/operations/fill/start`

Начать пополнение.

Request:

```json
{
  "user_id": 1,
  "product_id": 1,
  "cell_id": 2,
  "quantity": "5.000"
}
```

Backend должен:

1. Проверить пользователя.
2. Проверить права.
3. Проверить товар.
4. Проверить ячейку.
5. Проверить количество `> 0`.
6. Проверить отсутствие активной сессии.
7. Создать `cell_session`.
8. Вызвать `LockController.open_cell`.
9. Перевести сессию в `opened` или `waiting_close`.
10. Записать события.

Response:

```json
{
  "session_id": 100,
  "status": "waiting_close",
  "cell_id": 2,
  "cell_number": "2"
}
```

## POST `/api/operations/take/start`

Начать выдачу.

Request:

```json
{
  "user_id": 1,
  "product_id": 1,
  "cell_id": 2,
  "quantity": "3.000"
}
```

Дополнительная проверка:

- остаток в выбранной ячейке должен быть достаточным.

Если остатка недостаточно:

```json
{
  "error": "not_enough_stock",
  "message": "Недостаточно товара в ячейке"
}
```

## POST `/api/operations/open-only/start`

Открытие ячейки без изменения остатка.

Request:

```json
{
  "user_id": 1,
  "cell_id": 2,
  "comment": "Проверка замка"
}
```

## POST `/api/sessions/{session_id}/confirm-close`

Ручное подтверждение закрытия.

Request:

```json
{
  "user_id": 1
}
```

Response:

```json
{
  "session_id": 100,
  "status": "close_confirmed"
}
```

Правило:

- В MVP это ручная кнопка.
- В будущем метод может проверять датчик закрытия перед переводом статуса.

## POST `/api/operations/fill/{session_id}/confirm`

Подтвердить пополнение и изменить остаток.

Request:

```json
{
  "user_id": 1,
  "comment": "Положил новую поставку"
}
```

Правила:

- session должна быть `close_confirmed`.
- operation_type должна быть `fill`.
- остаток увеличивается только здесь.

## POST `/api/operations/take/{session_id}/confirm`

Подтвердить выдачу и изменить остаток.

Request:

```json
{
  "user_id": 1,
  "comment": "Взял для ремонта"
}
```

Правила:

- session должна быть `close_confirmed`.
- operation_type должна быть `take`.
- остаток уменьшается только здесь.

## POST `/api/sessions/{session_id}/cancel`

Отменить операцию.

Request:

```json
{
  "user_id": 1,
  "reason": "Пользователь передумал"
}
```

Правила:

- Остатки не меняются.
- Сессия переводится в `cancelled`.
- Событие пишется в журнал.

## GET `/api/sessions/active`

Вернуть активную сессию, если есть.

Response:

```json
{
  "has_active_session": true,
  "session": {
    "id": 100,
    "cell_id": 2,
    "cell_number": "2",
    "user_id": 1,
    "user_name": "Иван",
    "operation_type": "take",
    "status": "waiting_close",
    "opened_at": "2026-06-10T10:00:00Z"
  }
}
```

## Ошибки API

Рекомендуемые коды ошибок:

| Код | Значение |
|---|---|
| `unknown_rfid` | RFID не найден |
| `access_denied` | Нет прав |
| `inactive_user` | Пользователь заблокирован |
| `cell_not_active` | Ячейка недоступна |
| `active_session_exists` | Уже есть активная сессия |
| `not_enough_stock` | Недостаточно остатка |
| `invalid_session_status` | Некорректный статус сессии |
| `hardware_error` | Ошибка оборудования |
| `validation_error` | Ошибка входных данных |

## Сервисный слой

Минимальные сервисы:

- `AuthService`;
- `PermissionService`;
- `ProductService`;
- `CellService`;
- `StockService`;
- `SessionService`;
- `OperationService`;
- `AccessLogService`;
- `HardwareService`.

Backend-роуты должны быть тонкими. Основная логика должна быть в сервисах.
