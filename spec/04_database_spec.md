# 04. Спецификация базы данных

## Общие требования

- Боевая БД: PostgreSQL.
- Для ранней разработки допустим SQLite.
- ORM: SQLAlchemy 2.x.
- Миграции: Alembic.
- Все даты хранить как timezone-aware UTC timestamp. PostgreSQL должен использовать
  `TIMESTAMP WITH TIME ZONE`; SQLite в dev/test режиме должен возвращать
  timezone-aware UTC значения на уровне ORM даже при собственных ограничениях
  SQLite по типам дат.
- Для журнала доступа источником истины остается UTC timestamp в БД. Отображение
  пользователю, фильтры по датам и экспорты журнала доступа должны использовать
  локальный часовой пояс объекта: `UTC+03:00` (`Europe/Moscow`), если не задана
  другая конфигурация.
- Количество хранить как `Numeric`, не `float`.
- Все критичные изменения остатков выполнять в транзакции.

## Таблица `roles`

Роли пользователей.

Поля:

| Поле | Тип | Описание |
|---|---|---|
| `id` | integer / uuid | PK |
| `name` | string | `admin`, `manager`, `user`, `service` |
| `description` | string | Описание роли |
| `created_at` | datetime | Дата создания |
| `updated_at` | datetime | Дата обновления |

Ограничения:

- `UNIQUE(name)`.

## Таблица `users`

Пользователи.

Поля:

| Поле | Тип | Описание |
|---|---|---|
| `id` | integer / uuid | PK |
| `name` | string | Имя пользователя |
| `rfid_uid` | string | UID RFID-карты |
| `role_id` | FK | Роль |
| `is_active` | bool | Активен ли пользователь |
| `created_at` | datetime | Дата создания |
| `updated_at` | datetime | Дата обновления |

Ограничения:

- `UNIQUE(rfid_uid)`.
- Индекс по `rfid_uid`.

## Таблица `controllers`

Контроллеры замков.

Поля:

| Поле | Тип | Описание |
|---|---|---|
| `id` | integer / uuid | PK |
| `name` | string | Название контроллера |
| `controller_type` | string / enum | Тип контроллера |
| `address` | integer / string | Адрес контроллера |
| `port` | string | Порт, например `/dev/ttyUSB0` или `COM3` |
| `is_active` | bool | Активен ли контроллер |
| `comment` | text | Комментарий |
| `created_at` | datetime | Дата создания |

Типы `controller_type`:

- `mock`;
- `usb_relay`;
- `modbus_rtu`.

## Таблица `cells`

Физические ячейки хранения.

Поля:

| Поле | Тип | Описание |
|---|---|---|
| `id` | integer / uuid | PK |
| `number` | integer/string | Номер ячейки на шкафу |
| `status` | string / enum | Статус ячейки |
| `controller_id` | FK | Контроллер замка |
| `controller_address` | integer | Адрес контроллера |
| `relay_channel` | integer | Канал реле |
| `has_close_sensor` | bool | Есть ли датчик закрытия |
| `close_sensor_controller_address` | integer/null | Адрес контроллера датчика |
| `close_sensor_channel` | integer/null | Канал датчика |
| `comment` | text | Комментарий |
| `created_at` | datetime | Дата создания |
| `updated_at` | datetime | Дата обновления |

Статусы `status`:

- `active`;
- `blocked`;
- `maintenance`.

Ограничения:

- `UNIQUE(number)`.
- Для одного контроллера не должно быть двух активных ячеек на одном канале.

## Таблица `products`

Номенклатура товаров.

Поля:

| Поле | Тип | Описание |
|---|---|---|
| `id` | integer / uuid | PK |
| `name` | string | Название товара |
| `sku` | string/null | Артикул |
| `barcode` | string/null | Штрихкод |
| `unit` | string | Единица измерения |
| `external_id` | string/null | ID во внешней системе |
| `is_active` | bool | Активен ли товар |
| `created_at` | datetime | Дата создания |
| `updated_at` | datetime | Дата обновления |

Ограничения:

- `UNIQUE(sku)`, если `sku` не null.
- `UNIQUE(barcode)`, если `barcode` не null.
- Индекс по `name`.
- Индекс по `external_id`.

## Таблица `stock_items`

Остатки товаров по ячейкам.

Поля:

| Поле | Тип | Описание |
|---|---|---|
| `id` | integer / uuid | PK |
| `cell_id` | FK | Ячейка |
| `product_id` | FK | Товар |
| `quantity` | Numeric | Количество |
| `created_at` | datetime | Дата создания |
| `updated_at` | datetime | Дата обновления |

Ограничения:

```sql
UNIQUE(cell_id, product_id)
```

Проверки:

- `quantity >= 0`.

Эта таблица позволяет:

- хранить один товар в нескольких ячейках;
- хранить несколько товаров в одной ячейке.

## Таблица `stock_movements`

История движения товаров.

Поля:

| Поле | Тип | Описание |
|---|---|---|
| `id` | integer / uuid | PK |
| `created_at` | datetime | Дата события |
| `user_id` | FK | Пользователь |
| `product_id` | FK | Товар |
| `cell_id` | FK | Ячейка |
| `session_id` | FK/null | Сессия открытия |
| `movement_type` | string / enum | Тип движения |
| `quantity` | Numeric | Количество операции |
| `quantity_before` | Numeric | Остаток до операции |
| `quantity_after` | Numeric | Остаток после операции |
| `comment` | text | Комментарий |

Типы `movement_type`:

- `fill`;
- `take`;
- `move_in`;
- `move_out`;
- `adjust`;
- `inventory`.

## Таблица `access_events`

Технический журнал.

Поля:

| Поле | Тип | Описание |
|---|---|---|
| `id` | integer / uuid | PK |
| `created_at` | datetime | Дата события |
| `user_id` | FK/null | Пользователь, если известен |
| `rfid_uid` | string/null | RFID UID |
| `cell_id` | FK/null | Ячейка |
| `session_id` | FK/null | Сессия |
| `event_type` | string / enum | Тип события |
| `result` | string | Результат |
| `details` | json/text | Детали |

Правила времени:

- `created_at` хранится как timezone-aware UTC timestamp.
- В админ-панели и локальных отчетах событие отображается в локальном времени
  `UTC+03:00` (`Europe/Moscow`) с явным указанием смещения или подписью
  локального часового пояса.
- Фильтры журнала по дате и времени принимают локальное время `UTC+03:00` и
  преобразуются в UTC перед запросом к БД.

Типы `event_type`:

- `login_success`;
- `unknown_rfid`;
- `access_denied`;
- `open_cell_success`;
- `open_cell_failed`;
- `close_confirmed`;
- `session_started`;
- `session_completed`;
- `session_cancelled`;
- `session_timeout`;
- `relay_error`;
- `system_startup`.

## Таблица `cell_sessions`

Сессии открытия ячеек.

Поля:

| Поле | Тип | Описание |
|---|---|---|
| `id` | integer / uuid | PK |
| `user_id` | FK | Пользователь |
| `cell_id` | FK | Ячейка |
| `operation_type` | string / enum | Тип операции |
| `status` | string / enum | Статус сессии |
| `product_id` | FK/null | Товар, если применимо |
| `planned_quantity` | Numeric/null | Плановое количество |
| `opened_at` | datetime/null | Когда ячейка открыта |
| `close_confirmed_at` | datetime/null | Когда закрытие подтверждено |
| `completed_at` | datetime/null | Когда операция завершена |
| `cancelled_at` | datetime/null | Когда операция отменена |
| `cancel_reason` | text/null | Причина отмены |
| `comment` | text/null | Комментарий |
| `created_at` | datetime | Дата создания |
| `updated_at` | datetime | Дата обновления |

Типы `operation_type`:

- `fill`;
- `take`;
- `open_only`;
- `inventory`;
- `move_from`;
- `move_to`.

Статусы `status`:

- `created`;
- `opening`;
- `opened`;
- `waiting_close`;
- `close_confirmed`;
- `completed`;
- `cancelled`;
- `error`.

## Ограничение одной активной сессии

В PostgreSQL нужно создать partial unique index:

```sql
CREATE UNIQUE INDEX only_one_active_cell_session
ON cell_sessions ((true))
WHERE status IN (
    'created',
    'opening',
    'opened',
    'waiting_close',
    'close_confirmed'
);
```

Это запрещает две активные операции открытия одновременно.

## Транзакционная логика остатков

Пополнение:

```text
BEGIN
-> найти stock_item for update
-> quantity_before = текущее количество или 0
-> quantity_after = quantity_before + quantity
-> обновить stock_items
-> создать stock_movements
-> завершить cell_session
COMMIT
```

Выдача:

```text
BEGIN
-> найти stock_item for update
-> проверить quantity_before >= quantity
-> quantity_after = quantity_before - quantity
-> обновить stock_items
-> создать stock_movements
-> завершить cell_session
COMMIT
```

Отмена:

```text
BEGIN
-> перевести session в cancelled
-> записать access_event session_cancelled
-> остатки не менять
COMMIT
```
