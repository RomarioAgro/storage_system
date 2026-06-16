unit IL.Readers;

interface

// (rom) this is the switch to change between static and dynamic linking.
// (rom) it is enabled by default here.
// (rom) To disable simply change the '$' to a '.'.
//{$DEFINE ILREADERS_LINKONREQUEST}

{$IF CompilerVersion >= 17.0}
  {$DEFINE HAS_INLINE}
{$IFEND}

uses
  WinApi.Windows, WinApi.Ole2;

const
  ILR_Dll_Name = 'ILReaders.dll';
  ILR_SDK_Version = $0B0004; // v4.0.11

{$REGION 'Коды ошибок'}
const
  // Неправильная версия Sdk Readers
  ILR_E_WRONG_SDK_VERSION     = HResult($80040200);
  // Размер буфера слишком мал
  ILR_E_BUFFER_TOO_SMALL      = HResult($80040202);
  // Недостаточно ресурсов для завершения операции
  ILR_E_OUT_OF_RESOURCES      = HResult($80040203);
  // Блокирующий вызов функции из обработчика не разрешен
  ILR_E_BLOCKING_CALL_NOT_ALLOWED = HResult($80040204);
  // Ошибка функции Smart Cards
  ILR_E_SCARD_ERROR           = HResult($80040205);
  // Неправильное имя порта
  ILR_E_INVALID_PORTNAME      = HResult($80040307);
  // Порт не существует
  ILR_E_PORT_NOT_EXIST        = HResult($80040308);
  // Порт занят (уже используется)
  ILR_E_PORT_BUSY             = HResult($80040309);
  // Попытка подключения была отклонена
  ILR_E_CONNECT_REFUSED       = HResult($80040403);
  // Ошибка открытия порта
  ILR_E_PORT_OPEN_FAILED      = HResult($80040404);
  // Ошибка настройки порта
  ILR_E_PORT_CONFIGURE_FAILED = HResult($80040405);
  // Ошибка передачи данных через порт
  ILR_E_PORT_TRANSPORT_ERROR  = HResult($80040406);
  // Связь с устройством была потеряна
  ILR_E_PORT_NO_CONNECTION    = HResult($80040407);
  // Тайм-аут запроса к считывателю
  ILR_E_REQUEST_TIMEOUT       = HResult($80040409);
  // Не распознан ответ считывателя
  ILR_E_BAD_RESPONSE          = HResult($8004040A);
  // Ошибка считывателя
  ILR_E_READER_ERROR          = HResult($8004040B);

  // Нет карты
  ILR_E_NO_CARD               = HResult($8004040C);
  // Страница карты заблокирована
  ILR_E_CARD_PAGE_LOCK        = HResult($8004040D);
  // Не удалось записать на Temic
  ILR_E_WRITE_T57             = HResult($8004040E);
  // Ошибка авторизации карты
  ILR_E_CARD_AUTHORIZE        = HResult($8004040F);
  // Ошибка блока-значения Mifare
  ILR_E_MIFARE_VALUE          = HResult($80040410);
  // Неправильный адрес Mifare
  ILR_E_MIFARE_ADDRESS        = HResult($80040411);
  // Карта отказала от выполнения команды
  ILR_E_CARD_NACK             = HResult($80040412);
{$ENDREGION} // Коды ошибок

{$ALIGN 1}
{$MINENUMSIZE 4}
type
{$REGION 'Основные типы'}
  // Модель считывателя
  TReaderModel = (
    rmUnknownModel,   // Не известно
    rmZ2RDALL,        // Z-2 (мод. RD_ALL) / Z-2 USB
    rmZ2USBMF,        // Z-2 (мод. MF) / Z-2 USB MF
    rmZ2MFI,          // Z-2 (мод. MF-I)
    rmZ2EHR,          // Z-2 (мод. E HTZ RF) / Z-2 EHR
    rmZ2Base,         // Z-1 (мод. N Z) / Z-2 Base
    rmRF1996,         // Z-2 (мод. E HT Hotel) / Z-2 RF-1996
    rmMatrix3RdAll,   // Matrix-III (мод. RD_All)
    rmMatrix3Net,     // Matrix-III (мод. MF K Net) / Matrix-III Net
    rmCPZ2MF,         // CP-Z 2MF
    rmMatrix5,        // Matrix-V (мод. E S RF) / Matrix-V
    rmZ2MfCcid,       // Z-2 (мод. MF CCID)
    rmMatrix6         // Matrix-VI (мод. NFC K Net)
  );

  // Тип порта считывателя
  TPortType = (
    ptUnknownPort,    // Не известно
    ptComPort,        // Имя последовательного порта (например COM3)
    ptCCID,           // CCID (Smart Cards)
    ptServer,         // Адрес конвертера в режиме "Сервер" (например 10.0.0.2:1000)
    ptClient          // Адрес конвертера в режиме "Клиент" (например 123@25000)
  );
  // Имя порта считывателя
  TPortName = array[0..31] of WideChar;

  // Тип карты
  TCardType = (
    cUnknownCard,         // Не известно
    cEmMarine,            // Em-Marine
    cHID,                 // HID
    cICode,               // iCode
    cCod433,              // Cod433
    cCod433Fix,           // Cod433 Fix
    cCame433,             // Радиобрелок CAME
    cDallas,              // Dallas
    cTemic,               // Temic (T5557)

    cMifareUltralight,    // Mifare Ultralight
    cMifareUltralightC,   // Mifare Ultralight C
    cMifareMini,          // Mifare Classic Mini
    cMifare1K,            // Mifare Classic 1K
    cMifare2K,            // Mifare Classic 2K
    cMifare4K,            // Mifare Classic 4K
    cMifarePlus,          // Mifare Plus
    cMifarePlus1K,        // Mifare Plus 1K
    cMifarePlus2K,        // Mifare Plus 2K
    cMifarePlus4K,        // Mifare Plus 4K
    cSMXMifare1K,         // Smart MX with Mifare 1K
    cSMXMifare4K,         // Smart MX with Mifare 4K
    cMifareDesfire,       // Mifare DESFire
    cMifareProX           // Mifare ProX
  );
  TCardTypes = set of TCardType;

  // Типы карт, данные которых умеет читать/писать считыватель
  TRWCardType = (
    rwcMfUltralight,  // Mifare Ultralight
    rwcMfClassic,     // Mifare Classic
    rwcMfPlus,        // Mifare Plus
    rwcTemic          // Temic
  );
  TRWCardTypes = set of TRWCardType;

  // Информация о считывателе
  TReaderInfo = packed record
    nPortType       : TPortType;    // Тип порта
    szPortName      : TPortName;    // Имя порта
    nModel          : TReaderModel; // Модель считывателя
    nSn             : Integer;      // Серийный номер считывателя
    nFwVersion      : Cardinal;     // Версия прошивки считывателя
    nFwBuildDate    : Int64;        // Дата и время сборки прошивки
    nError          : HResult;      // Код ошибки, если не удалось получить инфо считывателя

    // Возвращает биты типов карт, UID которых умеет читать считыватель
    function GetIdCardTypes(): TCardTypes;
    // Возвращает типы карт, данные которых умеет читать/писать считыватель
    function CanRWCardTypes(): TRWCardTypes;
  end;
  PReaderInfo = ^TReaderInfo;

  // Уровень лога
  TLogLevel = (
    llDisabled,       // Лог выключен
    llAssert,			    // Неожиданные ошибки, которых быть не должно
    llError,          // Ошибки
    llWarning,			  // Предупреждения. Показывает возможные проблемы, которые не являются ошибками
    llInfo,           // Уведомления. Показывает полезную информацию, в основном успехи
    llDebug,          // Отладочные сообщения. Показвает шаги программы, получаемые и отправляемые данные
    llVerbose         // Подробные отладочные сообщения. Показывает каждую мелочь
  );
{$ENDREGION} // Основные типы

{$REGION 'Поиск считывателей'}
  // Тип считывателей
  TReaderType = (
    rtILUsb,  // USB считыватели Ironlogic
    rtTPUsb,  // USB считыватели сторонних производителей
    rtCcid,   // Считыватели SmartCards
    rtServer, // IP конвертеры в режиме "Сервер" (поиск по UDP)
    rtClient  // IP конвертеры в режиме "Клиент" (прослушка TCP)
  );
  TReaderTypes = set of TReaderType;

  TFilterPortProc = function(APortType: TPortType; APortName: PWideChar;
    AUserData: Pointer): LongBool; stdcall;

  // Сообщение поиска считывателей (IILRSearch)
  TSearchMsg = (
    smAsyncCmdFinish, // Завершилась асинхронная команда, созданная IILRSearchAsync
    smReaderFound,    // Считыватель найден, параметр PReaderInfo
    smReaderLost,     // Считыватель потерян, параметр PReaderInfo
    smListChanged     // Список считывателей изменён
  );

	// Тип функции для получения уведомлений от IILRSearch
  TSearchNotifyProc = procedure(AMsg: TSearchMsg;
    AMsgData, AUserData: Pointer); stdcall;
{$ENDREGION} // Поиск считывателей

{$REGION 'Подключение к считывателю'}
  // Сообщение считывателя (IILReader)
  TReaderMsg = (
    rmAsyncCmdFinish,     // Завершилась асинхронная команда, созданная IILReaderAsync
    rmConnectionChanged,  // Изменилось состояние подключения к считывателю
    rmCardFound,          // Карта найдена, параметр PCardInfo
    rmCardLost            // Карта потеряна, параметр PCardInfo
  );

	// Тип функции для получения уведомлений от IILReader
  TReaderNotifyProc = procedure(AMsg: TReaderMsg; AMsgData, AUserData: Pointer); stdcall;

  // Состояние подключения считывателя
  TConnectionStatus = (
    csDisconnected,       // Отключён
    csConnected,          // Подключён
    csConnecting          // Подключение
  );

  // ID карты
  TCardUID = packed record
    nLength         : ShortInt; // Длина номера в байтах
    aBytes          : array[0..14] of Byte; // Байты номера

    procedure Clear();
    function IsEmpty(): Boolean;
    procedure Assign(const AData; ASize: Cardinal);
    function Compare(const rUID: TCardUID): Integer;

    // Оператор соответствия
    class operator Equal(const a, b: TCardUID): Boolean;
    // Оператор несоответствия
    class operator NotEqual(const a, b: TCardUID): Boolean;
    // a > b ?
    class operator GreaterThan(const a, b: TCardUID): Boolean;
    // a >= b ?
    class operator GreaterThanOrEqual(const a, b: TCardUID): Boolean;
    // a < b ?
    class operator LessThan(const a, b: TCardUID): Boolean;
    // a <= b ?
    class operator LessThanOrEqual(const a, b: TCardUID): Boolean;
  end;
  PCardUID = ^TCardUID;

{$MINENUMSIZE 1}
  // Уровнь безопасности Mifare Plus
  TMfPlusSL = (
    mpslUnknown = -1, // Не известно
    mpslSL0,          // Уровень 0 (не инициализирована)
    mpslSL1,          // Уровень 1 (эмуляция Mifare Classic)
    mpslSL2,          // Уровень 2
    mpslSL3           // Уровень 3
  );

  // Тип Mifare Plus
  TMfPlusType = (
    mptUnknown,   // Не известно
    mptS,         // Mifare Plus S
    mptX,         // Mifare Plus X
    mptSE,        // MIFARE Plus SE
    mptEV1,       // MIFARE Plus EV1
    mptEV2        // MIFARE Plus EV2
  );

  // Информация о карте
  TCardInfo = packed record
    nType           : TCardType;  // Тип карты
    rUID            : TCardUID;   // Номер карты
    nMemSize        : Cardinal;   // Размер памяти
    nSL             : TMfPlusSL;  // Уровнь безопасности Mifare Plus
    nMpType         : TMfPlusType;// Тип Mifare Plus
    nType2          : TCardType;  // Тип карты
    rUID2           : TCardUID;   // Номер карты

    procedure Clear();
    // Возвращает True если карта Mifare Classic
    function IsMfClassic(): Boolean;
    // Возвращает True если карта Mifare Plus
    function IsMfPlus(): Boolean;
    // Возвращает True если карта Mifare Classic или Mifare Plus SL1
    function IsMfClassicMode(): Boolean;
    // Возвращает True если карта Mifare Plus SL3
    function IsMfPlusSL3Mode(): Boolean;
    // Возвращает количество блоков карты Mifare Classic/Plus
    function GetNumberOfMfBlocks(): Integer;
  end;
  PCardInfo = ^TCardInfo;

  // Ключ аутентификации Mifare Classic
  TMfClassicKey = Int64;
  PMfClassicKey = ^TMfClassicKey;

  // Ключ аутентификации Mifare Plus
  TMfPlusKey = packed record
    a               : array[0..15] of Byte;

    // Оператор соответствия
    class operator Equal(const a, b: TMfPlusKey): Boolean;
    // Оператор несоответствия
    class operator NotEqual(const a, b: TMfPlusKey): Boolean;
  end;
  PMfPlusKey = ^TMfPlusKey;

  // Данные блока Mifare Classic/Plus
  TMfBlockData = packed record
    a               : array[0..15] of Byte;

    // Оператор соответствия
    class operator Equal(const a, b: TMfBlockData): Boolean;
    // Оператор несоответствия
    class operator NotEqual(const a, b: TMfBlockData): Boolean;
  end;
  PMfBlockData = ^TMfBlockData;
{$ENDREGION} // Подключение к считывателю

{$REGION 'Интерфейсы'}
  IILRSearch = interface
    ['{6EAE522E-11FB-42AF-972A-726938CB68DB}']
    // Устанавливает функцию обратного вызова для уведомления о событиях дескриптора
    procedure SetNotifyCallback(ACallback: TSearchNotifyProc; AUserData: Pointer); safecall;
    // Вкл/выкл очередь сообщений (для синхронизации)
    procedure EnableMsgQueue(AEnable: LongBool = True); safecall;
    // Извлекает следующее сообщение из очереди
    function GetMessage(out VMsg: TSearchMsg; out VMsgData: Pointer): LongBool; safecall;
    // Устанавливает типы считывателей, которые нужно искать
    procedure SetReaderTypes(ATypes: Cardinal); safecall;
    // Возвращает типы считывателей, которые нужно искать
    function GetReaderTypes(): Cardinal; safecall;
    // Устанавливает период опроса IP конвертеров по UDP в миллисекундах
    procedure SetUdpScanPeriod(AMs: Cardinal); safecall;
    // Возвращает период опроса IP конвертеров по UDP в миллисекундах
    function GetUdpScanPeriod(): Cardinal; safecall;
    // Устанавливает тайм-аут запроса по UDP
    procedure SetUdpRequestTimeout(AMs: Cardinal); safecall;
    // Возвращает тайм-аут запроса по UDP в миллисекундах
    function GetUdpRequestTimeout(): Cardinal; safecall;
    // Устанавливает количество попыток запроса по UDP (поиск IP конвертеров)
    procedure SetUdpRequestAttempts(AAttempts: Integer); safecall;
    // Возвращает количество попыток запроса по UDP
    function GetUdpRequestAttempts(): Integer; safecall;
    // Устанавливает IP адреса конвертеров для опроса по UDP, которые не
    // находятся автоматически
    // pszAddress список адресов, разделённых символом ';'
    procedure SetUdpCvtAddresses(AAddresses: PWideChar); safecall;
    // Возвращает IP адреса конвертеров для опроса по UDP
    procedure GetUdpCvtAddresses(out Addresses: TBStr); safecall;
    // Устанавливает список TCP-портов для прослушки конвертеров к режиме "Клиент"
    procedure SetListenTcpPorts(APorts: PWord; ACount: Integer); safecall;
    // Возвращает список TCP-портов для прослушки конвертеров к режиме "Клиент"
    function GetListenTcpPorts(VBuf: PWord; ACount: Integer): Integer; safecall;
    // Устанавливает период между попытками открыть TCP порт для прослушки Клиентов
    procedure SetOpenListenerPeriod(AMs: Cardinal); safecall;
    // Ищет считыватели
    procedure Scan(AReset: LongBool = False); safecall;
    // Возвращает количество найденных считывателей
    function GetReaderCount(): Integer; safecall;
    // Возвращает инфо о найденном считывателе
    procedure GetReaderInfo(AIdx: Integer; out VInfo: TReaderInfo); safecall;
    // Вкл/выкл режим авто поиска считывателей
    procedure EnableAutoScan(AEnable: LongBool = True; AWait: LongBool = True); safecall;
    // Возвращает True если авто поиск включен
    function GetAutoScanEnabled(): LongBool; safecall;
    // Открывает порт
    function OpenPort(APortType: TPortType; APortName: PWideChar;
      out VInfo: TReaderInfo): THandle; safecall;
    // Закрывает порт
    procedure ClosePort(APortType: TPortType; APortName: PWideChar;
      APort: THandle); safecall;
  end;

  IILReader = interface
    ['{C435D1AB-A1AC-455D-A1D9-0C53F5F21417}']
    // Устанавливает функцию обратного вызова для уведомления о событиях дескриптора
    procedure SetNotifyCallback(ACallback: TReaderNotifyProc; AUserData: Pointer); safecall;
    // Вкл/выкл очередь сообщений (для синхронизации)
    procedure EnableMsgQueue(AEnable: LongBool = True); safecall;
    // Извлекает следующее сообщение из очереди
    function GetMessage(out VMsg: TReaderMsg; out VMsgData: Pointer): LongBool; safecall;
    // Устанавливает модель для подключения
    procedure SetModelToConnect(AModel: TReaderModel); safecall;
    // Возвращает модель для подключения
    function GetModelToConnect(): TReaderModel; safecall;
    // Подключается к считывателю
    procedure Connect(AReconnect: LongBool = False); safecall;
    // Отключается от считывателя
    procedure Disconnect(); safecall;
    // Возвращает состояние подключения к считывателю
    function GetConnectionStatus(): TConnectionStatus; safecall;
    // Возвращает информацию о считывателе
    procedure GetReaderInfo(out VInfo: TReaderInfo); safecall;
    // Ищет карты
    //	fPowerOff =True, выключает RF поле после сканирования
    procedure Scan(AReset: LongBool = False; APowerOff: LongBool = True); safecall;
    // Возвращает информацию о карте в поле считывателя
    procedure GetCardInfo(out VInfo: TCardInfo); safecall;
    // Вкл/выкл автоматическое сканирование карт
    //	fWait =True ждать завершение команды
    procedure EnableAutoScan(AEnable: LongBool = True; AWait: LongBool = True); safecall;
    // Возвращает True если авто сканирование включено
    function GetAutoScanEnabled(): LongBool; safecall;
    // Устанавливает типы карт, при обнаружении которых нужно автоматически
    //  приостановить сканирование карт. Для возобновления сканирования
    //  используйте EnableAutoScan()
    //  ATypes флаги типов карт, см. константы RWCTF_...
    procedure SetHoldCardTypes(ATypes: Cardinal); safecall;
    // Возвращает типы карт, при обнаружении которых автоматически
    // приостанавливается сканирование
    function GetHoldCardTypes(): Cardinal; safecall;

{$REGION 'Mifare Ultralight'}
    // Читает данные карты Mifare Ultralight
    procedure ReadMfUlralight(APageIdx: Integer; VBuf: PCardinal; APageCount: Integer;
        VRead: PInteger = nil); safecall;
    // Пишет данные карты Mifare Ultralight
    procedure WriteMfUlralight(APageIdx: Integer; const AData: PCardinal;
        APageCount: Integer; VWritten: PInteger = nil); safecall;
{$ENDREGION} // Mifare Ultralight

{$REGION 'Mifare Classic/Plus'}
    // Загружает ключ для авторизации сектора Mifare Classic / Plus SL1
    procedure LoadMfAuthKey(const AKey: TMfClassicKey); safecall;
    // Загружает ключ для авторизации сектора Mifare Plus SL3
    procedure LoadMfPlusAuthKey(const [Ref] AKey: TMfPlusKey); safecall;
    // Авторизует сектор карты Mifare Classic / Plus, используя ключ,
    // загруженный функцией LoadMfAuthKey / LoadMfPlusAuthKey
    function AuthMfCard(AAddress: Cardinal; AKeyB: LongBool): LongBool; safecall;
    // Авторизует сектор карты Mifare Classic / Plus, используя ключи считывателя
    // Возвращает позицию найденного ключа в списке считывателя, =-1 не найден
    function AuthMfCardByRdKeys(AAddress: Cardinal; AKeyB: LongBool;
        ARdKeys: Cardinal = $FFFF): Integer; safecall;
    // Читает данные карты Mifare Classic или Mifare Plus SL1
    procedure ReadMfClassic(ABlockIdx: Integer; VBuf: PMfBlockData;
        ABlockCount: Integer; VRead: PInteger = nil); safecall;
    // Пишет данные карты Mifare Classic или Mifare Plus SL1
    procedure WriteMfClassic(ABlockIdx: Integer; const AData: PMfBlockData;
        ABlockCount: Integer; VWritten: PInteger = nil); safecall;
    // Читает данные карты Mifare Plus SL3
    procedure ReadMfPlus(AAddress: Cardinal; VBuf: PMfBlockData;
        ABlockCount: Integer; AOpenText: LongBool = True;
        VRead: PInteger = nil); safecall;
    // Пишет данные карты Mifare Plus SL3
    procedure WriteMfPlus(AAddress: Cardinal; const AData: PMfBlockData;
        ABlockCount: Integer; AOpenText: LongBool = True;
        VWritten: PInteger = nil); safecall;
    // Увеличивает содержимое блока-значения карты Mifare и сохраняет результат
    //  во временном регистре данных
    procedure MfIncrement(ABlockIdx: Integer; Value: Cardinal); safecall;
    // Уменьшает содержимое блока-значения карты Mifare и сохраняет результат
    //  во временном регистре данных
    procedure MfDecrement(ABlockIdx: Integer; Value: Cardinal); safecall;
    // Записывает содержимое во временном регистре данных в блок-значение
    procedure MfTransfer(ABlockIdx: Integer); safecall;
    // Перемещает содержимое блока в регист данных Mifare
    procedure MfRestore(ABlockIdx: Integer); safecall;
    // Выключает RF поле считывателя
    procedure MfPowerOff; safecall;
    // R+A+S(Request+Anticollision+Select)
    function MfRAS(AWakeUp: LongBool;
      out VSAK: Byte; out VATQ: Word; out VUID: TCardUID): LongBool; safecall;
    // R+R(Request+Reselect(по известному номеру))
    function MfRR(AWakeUp: LongBool; const [Ref] AUID: TCardUID): LongBool; safecall;
    // Halt
    procedure MfHalt(); safecall;
    // Переходит на ISO 14443-4
    procedure MfRATS(VAtsBuf: PByte; ABufSize: Cardinal;
      out VRequiredSize: Cardinal); safecall;
    // Записывает ключи AES и всех блоков
    procedure MfWritePerso(AAddress: Cardinal; const [Ref] AKey: TMfPlusKey); safecall;
    // Переключает Mifare Plus в SL1 или SL3(если SL1 нет)
    procedure MfCommitPerso(); safecall;
    // Записывает ключи аутентификации Mifare Classic в память считывателя
    procedure WriteMfAuthKeyToReader(AIdx: Integer; AKeyB: LongBool;
        const AKeys: PMfClassicKey; ACount: Integer;
        VWritten: PInteger = nil); safecall;
    // Записывает ключи аутентификации Mifare Plus в память считывателя
    procedure WriteMfPlusAuthKeyToReader(AIdx: Integer; AKeyB: LongBool;
        const AKeys: PMfPlusKey; ACount: Integer;
        VWritten: PInteger = nil); safecall;
{$ENDREGION} // Mifare Classic/Plus

{$REGION 'Temic'}
    // Загружает пароль Temic в память объекта считывателя
    procedure LoadTemicPassword(const APassword: Int64); safecall;
    // Ищет карту Temic в поле считывателя
    procedure ScanTemic(AScanParam: Integer = -1); safecall;
    // Вкл/выкл сканирование карт Temic (для Z-2 Rd-All и Z-2 EHR)
    procedure EnableAutoScanTemic(AEnable: LongBool); safecall;
    // Возвращает True если авто сканирование Temic включено
    function GetAutoScanTemicEnabled(): LongBool; safecall;
    // Читает данные карты Temic
    procedure ReadTemic(ABlockIdx: Integer; VBuf: PCardinal;
        ABlockCount: Integer; AScanParam: Integer = -1;
        VRead: PInteger = nil); safecall;
    // Пишет данные карты Temic
    procedure WriteTemic(ABlockIdx: Integer; const AData: PCardinal;
        ABlockCount: Integer; ALock: LongBool = False;
        AScanParam: Integer = -1; VWritten: PInteger = nil); safecall;
    // Сброс TRES
    procedure ResetTemic(); safecall;
    // Шифрует данные для эмуляции Em-Marine, для записи в блоки 0..1
    procedure EncodeTemicEmMarine(const AUID: TCardUID; VBuf3: PCardinal;
        ABlockCount: Integer); safecall;
    // Дешифрует номер Em-Marine из данных блоков 0..1 карты Temic
    procedure DecodeTemicEmMarine(const AData3: PCardinal; ABlockCount: Integer;
        out VUID: TCardUID; out VConfigOk: Boolean); safecall;
    // Шифрует данные для эмуляции HID, для записи в блоки 0..3
    procedure EncodeTemicHID(const AUID: TCardUID; VBuf4: PCardinal;
        ABlockCount: Integer; AWiegand: Integer); safecall;
    // Дешифрует номер HID из данных блоков 0..3 карты Temic
    procedure DecodeTemicHID(const AData4: PCardinal; ABlockCount: Integer;
        out VUID: TCardUID; out VWiegand: Integer; out VConfigOk: Boolean); safecall;
{$ENDREGION} // Temic
  end;

  IILR = interface
    ['{B5FDDC67-9CAE-49F1-84D0-0594D2D3B003}']
    // Устанавливает функцию обратного вызова для исключения портов
    procedure SetFilterPortCallback(ACallback: TFilterPortProc; AUserData: Pointer); safecall;
    // Устанавливает путь к файлу лога отладки
    procedure SetLogPath(APath: LPCWSTR); safecall;
    // Возвращает путь к файлу лога отладки
    procedure GetLogPath(out VPath: TBStr); safecall;
    // Устанавливает уровень лога отладки
    procedure SetLogLevel(ALevel: TLogLevel); safecall;
    // Возвращает уровень лога отладки
    function GetLogLevel(): TLogLevel; safecall;
    // Очищает лог отладки
    function ClearLog(): HResult; stdcall;
    // Устанавливает количество стоповых бит для COM-порта
    procedure SetStopBits(AStopBits: Byte); safecall;
    // Возвращает количество стоповых бит для COM-порта
    function GetStopBits(): Byte; safecall;
    // Устанавливает тайм-аут запроса
    procedure SetRequestTimeout(AMs: Cardinal); safecall;
    // Возвращает тайм-аут запроса
    function GetRequestTimeout(): Cardinal; safecall;
    // Устанавливает количество попыток запроса
    procedure SetRequestAttempts(AAttempts: Integer); safecall;
    // Возвращает количество попыток запроса
    function GetRequestAttempts(): Integer; safecall;

    // Возвращает интерфейс поиска считывателей
    function GetSearch(): IILRSearch; safecall;
    // Возвращает интерфейс подключения к считывателю
    function GetReader(APortType: TPortType; APortName: LPCWSTR): IILReader; safecall;
  end;
{$ENDREGION} // Интерфейсы

{$REGION 'Интерфейсы для асинхронного режима'}
  IILRAsyncCommand = interface
    ['{D82E158B-7B9D-46AC-B3F8-0D1D97422FF4}']
    // Отменяет команду. Устанавливает статус E_ABORT
    procedure Cancel(); safecall;
    // Возвращает состояние команды
    //	Возвращает =E_PENDING команда ещё выполняется, иначе - завершена
    function GetStatus(): HResult; safecall;
    // Возвращает состояние прогресса выполнения команды
    procedure GetProgress(out VCurrent, VTotal: Integer); safecall;
  end;

  IILRSearchAsync = interface
    ['{C61BA823-D1AC-459E-B483-5A5F6CFAA446}']
    // Запускает асинхронную команду поиска считывателей
    function Begin_Scan(AReset: LongBool): IILRAsyncCommand; safecall;
    // Запускает асинхронную команду вкл/выкл режим авто поиска считывателей
    function Begin_EnableAutoScan(AEnable: LongBool): IILRAsyncCommand; safecall;
    // Запускает асинхронную команду открытия порта
    function Begin_OpenPort(APortType: TPortType; APortName: PWideChar
      ): IILRAsyncCommand; safecall;
    procedure End_OpenPort(ACmd: IILRAsyncCommand; out VPort: THandle;
      out VInfo: TReaderInfo); safecall;
    // Запускает асинхронную команду закрытия порта
    function Begin_ClosePort(APortType: TPortType; APortName: PWideChar;
      APort: THandle): IILRAsyncCommand; safecall;
  end;

  IILReaderAsync = interface
    ['{83938709-8E3B-4581-82EE-C5163DA2FAF8}']
    // Запускает асинхронную команду подключения к считывателю
    function Begin_Connect(AReconnect: LongBool = False): IILRAsyncCommand; safecall;
    // Запускает асинхронную команду отключения от считывателя
    function Begin_Disconnect(): IILRAsyncCommand; safecall;
    // Запускает асинхронную команду поиска карты
    //	fPowerOff =True, выключает RF поле после сканирования
    function Begin_Scan(AReset: LongBool = False; APowerOff: LongBool = True): IILRAsyncCommand; safecall;
    // Запускает асинхронную команду вкл/выкл автоматического сканирования карт
    function Begin_EnableAutoScan(AEnable: LongBool): IILRAsyncCommand; safecall;

    // Запускает асинхронную команду чтения данных из карты Mifare Ultralight
    function Begin_ReadMfUlralight(APageIdx, APageCount: Integer): IILRAsyncCommand; safecall;
    // Возвращает результат чтения данных из карты Mifare Ultralight
    procedure End_ReadMfUlralight(ACmd: IILRAsyncCommand; VBuf: PCardinal;
      ABufSize: Integer; out VRead: Integer); safecall;
    // Запускает асинхронную команду записи данных в карту Mifare Ultralight
    function Begin_WriteMfUlralight(APageIdx: Integer; const AData: PCardinal;
      APageCount: Integer): IILRAsyncCommand; safecall;
    // Возвращает результат записи данных в карту Mifare Ultralight
    //	VWritten количество прочитанных страниц
    procedure End_WriteMfUlralight(ACmd: IILRAsyncCommand;
      out VWritten: Integer); safecall;

    // Запускает асинхронную команду авторизации сектора карты Mifare Classic / Plus
    // используя ключ, загруженный функцией LoadMfAuthKey / LoadMfPlusAuthKey
    //	AAddress номер блока или адрес Mifare Plus,
    //	AKeyB =True по ключу B, иначе A,
    function Begin_AuthMfCard(AAddress: Cardinal; AKeyB: LongBool): IILRAsyncCommand; safecall;
    // Возвращает результат авторизации сектора карты
    //	VAuthOk =True, авторизация прошла успешно
    procedure End_AuthMfCard(ACmd: IILRAsyncCommand; out VAuthOk: LongBool); safecall;
    // Запускает асинхронную команду авторизации сектора карты
    //  Mifare Classic / Plus используя ключи в памяти считывателя
    //	AAddress номер блока или адрес Mifare Plus,
    //	AKeyB =True по ключу B, иначе A
    function Begin_AuthMfCardByRdKeys(AAddress: Cardinal; AKeyB: LongBool;
        ARdKeys: Cardinal = $ffff): IILRAsyncCommand; safecall;
    // Возвращает результат авторизации сектора карты
    //	VKeyIdx позиция найденного ключа в памяти считывателя, =-1 ключ не найден
    procedure End_AuthMfCardByRdKeys(ACmd: IILRAsyncCommand; out VKeyIdx: Integer); safecall;

    // Запускает асинхронную команду чтения данных из карты Mifare Classic или Mifare Plus SL1
    function Begin_ReadMfClassic(ABlockIdx, ABlockCount: Integer): IILRAsyncCommand; safecall;
    // Возвращает результат чтения данных из карты Mifare Classic или Mifare Plus SL1
    //	VRead количество прочитанных блоков
    procedure End_ReadMfClassic(ACmd: IILRAsyncCommand; VBuf: PMfBlockData;
        ABufSize: Integer; out VRead: Integer); safecall;
    // Запускает асинхронную команду записи данных в карту Mifare Classic или Mifare Plus SL1
    function Begin_WriteMfClassic(ABlockIdx: Integer; const AData: PMfBlockData;
        ABlockCount: Integer): IILRAsyncCommand; safecall;
    // Возвращает результат записи данных в карту Mifare Classic или Mifare Plus SL1
    //	VWritten количество записанных блоков
    procedure End_WriteMfClassic(ACmd: IILRAsyncCommand; out VWritten: Integer); safecall;
    // Запускает асинхронную команду чтения данных из карты Mifare Plus SL3
    //	ABlockCount количество блоков, которые нужно прочитать
    function Begin_ReadMfPlus(AAddress: Cardinal; ABlockCount: Integer;
        AOpenText: LongBool): IILRAsyncCommand; safecall;
    // Возвращает результат чтения данных из карты Mifare Plus SL3
    //	VRead количество прочитанных блоков
    procedure End_ReadMfPlus(ACmd: IILRAsyncCommand; VBuf: PMfBlockData;
        ABufSize: Integer; out VRead: Integer); safecall;
    // Запускает асинхронную команду записи данных в карту Mifare Plus SL3
    function Begin_WriteMfPlus(AAddress: Cardinal;
        const AData: PMfBlockData; ABlockCount: Integer; AOpenText: LongBool
        ): IILRAsyncCommand; safecall;
    // Возвращает результат записи данных в карту Mifare Plus SL3
    //	VWritten количество записанных блоков
    procedure End_WriteMfPlus(ACmd: IILRAsyncCommand; out VWritten: Integer); safecall;
    // Увеличивает содержимое блока-значения карты Mifare и сохраняет результат
    // во временном	регистре данных
    function Begin_MfIncrement(ABlockIdx: Integer; AValue: Cardinal): IILRAsyncCommand; safecall;
    // Уменьшает содержимое блока-значения карты Mifare и сохраняет результат
    //  во временном регистре данных
    function Begin_MfDecrement(ABlockIdx: Integer; AValue: Cardinal): IILRAsyncCommand; safecall;
    // Записывает содержимое во временном регистре данных в блок-значение
    function Begin_MfTransfer(ABlockIdx: Integer): IILRAsyncCommand; safecall;
    // Перемещает содержимое блока в регист данных Mifare
    function Begin_MfRestore(ABlockIdx: Integer): IILRAsyncCommand; safecall;
    // Запускает асинхронную команду записи ключей аутентификации Mifare Classic
    //  в память считывателя
    function Begin_WriteMfAuthKeyToReader(AIdx: Integer; AKeyB: LongBool;
        const AKeys: PMfClassicKey; ACount: Integer): IILRAsyncCommand; safecall;
    // Возвращает результат записи ключей аутентификации Mifare Classic в память считывателя
    //	VWritten количество записанных ключей
    procedure End_WriteMfAuthKeyToReader(ACmd: IILRAsyncCommand; out VWritten: Integer); safecall;
    // Запускает асинхронную команду записи ключей аутентификации Mifare Plus в память считывателя
    function Begin_WriteMfPlusAuthKeyToReader(AIdx: Integer; AKeyB: LongBool;
        const AKeys: PMfPlusKey; ACount: Integer): IILRAsyncCommand; safecall;
    // Возвращает результат записи ключей аутентификации Mifare Plus в память считывателя
    //	VWritten количество записанных ключей
    procedure End_WriteMfPlusAuthKeyToReader(ACmd: IILRAsyncCommand;
        out VWritten: Integer); safecall;

    // Запускает асинхронную команду поиска карты Temic в поле считывателя
    function Begin_ScanTemic(AScanParam: Integer = -1): IILRAsyncCommand; safecall;
    // Запускает асинхронную команду чтения данных из карты Temic
    function Begin_ReadTemic(ABlockIdx, ABlockCount: Integer;
        AScanParam: Integer = -1): IILRAsyncCommand; safecall;
    // Возвращает результат чтения данных из карты Temic
    //	VRead количество прочитанных блоков
    procedure End_ReadTemic(ACmd: IILRAsyncCommand; VBuf: PCardinal;
        ABufSize: Integer; out VRead: Integer); safecall;
    // Запускает асинхронную команду записи данных в карту Temic
    function Begin_WriteTemic(ABlockIdx: Integer; const AData: PCardinal;
        ABlockCount: Integer; ALock: LongBool = False;
        AScanParam: Integer = -1): IILRAsyncCommand; safecall;
    // Возвращает результат записи данных в карту Temic
    //	VWritten количество записанных блоков
    procedure End_WriteTemic(ACmd: IILRAsyncCommand; out VWritten: Integer); safecall;
    // Запускает асинхронную команду сброса TRES
    function Begin_ResetTemic(): IILRAsyncCommand; safecall;
  end;

{$ENDREGION} // Интерфейсы для асинхронного режима

{$REGION 'Константы'}
const
  // Флаги типов считывателей
  RT_F_ILUSB  = $00000001; // USB считыватели Ironlogic
  RT_F_TPUSB  = $00000002; // USB считыватели сторонних производителей
  RT_F_CCID   = $00000004; // Считыватели SmartCards
  RT_F_SERVER = $00000008; // IP конвертеры в режиме "Сервер" (поиск по UDP)
  RT_F_CLIENT = $00000010; // IP конвертеры в режиме "Клиент" (прослушка TCP)
  // Флаги типов карт (для авто приостановки сканирования при обнаружении карты)
  RWCT_F_MFULTRALIGHT = $00000001; // Mifare Ultralight
  RWCT_F_MFCLASSIC    = $00000002; // Mifare Classic
  RWCT_F_MFPPLUS      = $00000004; // Mifare Plus
  RWCT_F_TEMIC        = $00000008; // Temic

  // Ключ Mifare Classic по умолчанию
  kDefaultMfClassicKey: TMfClassicKey = $ffffffffffff;
  // Ключ Mifare Plus по умолчанию
  kDefaultMfPlusKey: TMfPlusKey = (a:(
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff));
{$ENDREGION} // Константы

{$MINENUMSIZE 1}
{$ALIGN ON}

{$IFNDEF ILREADERS_LINKONREQUEST}
// Возвращает версию библиотеки ILReaders.dll
function ILR_GetVersion(): Cardinal; stdcall;
// Возвращает описание ошибки по её коду. Для освобождения памяти используйте SysFreeString(pText)
function ILR_GetErrorText(AErrorCode: HResult; out VText: TBStr): HResult; stdcall;
// Инициализирует библиотеку. Эта функция не потокобезопасная
function ILR_GetInterface(out VObj: IILR;
    AVersionRequested: Cardinal = ILR_SDK_VERSION): HResult; stdcall;

{$ELSE}
type
  TILR_GetVersion = function(): Cardinal; stdcall;
  TILR_GetErrorText = function(AErrorCode: HResult; out VText: TBStr): HResult; stdcall;
  TILR_GetInterface = function(out VObj: IILR;
    AVersionRequested: Cardinal = ILR_SDK_VERSION): HResult; stdcall;
var
  ILR_GetVersion: TILR_GetVersion;
  ILR_GetErrorText: TILR_GetErrorText;
  ILR_GetInterface: TILR_GetInterface;
{$ENDIF !ILREADERS_LINKONREQUEST}


function IsILRLoaded(): Boolean;
function LoadILR(): HResult;
procedure UnloadILR();

// Преобразовывает типы считывателей в флаги RTF_
function ReaderTypesToFlags(ATypes: TReaderTypes): Cardinal;
// Преобразовывает флаги RTF_ в типы считывателей
function FlagsToReaderTypes(AFlags: Cardinal): TReaderTypes;
// Преобразовывает типы ключей в флаги RWCTF_
function RwCardTypesToFlags(ATypes: TRwCardTypes): Cardinal;

implementation

uses
  System.SysUtils, System.Math;


{ TReaderInfo }

function TReaderInfo.GetIdCardTypes(): TCardTypes;
begin
  case nModel of
    rmZ2RDALL:
    begin
      Result := [cEmMarine, cHID, cMifareUltraLight, cMifare1K, cMifare4K,
        cMifareDesfire, cMifareProX];
      if nFwVersion >= 106 then
        Result := Result + [cTemic];
    end;

    rmZ2USBMF,
    rmZ2MFI,
    rmMatrix3Net,
    rmCPZ2MF,
    rmZ2MfCcid,
    rmMatrix6:
      Result := [cMifareMini, cMifareUltraLight, cMifare1K, cMifare2K,
        cMifare4K, cMifarePlus, cMifarePlus1K, cMifarePlus2K, cMifarePlus4K,
        cMifareDesfire, cMifareProX];

    rmZ2EHR:
      Result := [cEmMarine, cHID, cMifareUltraLight, cMifare1K, cMifare4K,
        cMifareDesfire, cMifareProX, cTemic, cDallas, cCod433, cCod433Fix];

    rmRF1996:
      Result := [cEmMarine, cTemic];

    rmMatrix3RdAll:
      Result := [cEmMarine, cHID, cMifareUltraLight, cMifare1K, cMifare4K,
        cMifareDesfire, cMifareProX];

    rmMatrix5:
      Result := [cEmMarine, cCame433, cCod433, cCod433Fix];

    else
      Result := [];
  end;
end;

function TReaderInfo.CanRWCardTypes(): TRwCardTypes;
begin
  Result := [];
  case nModel of
    rmZ2RDALL:
    begin
      Result := Result + [rwcMfUltralight];
      if nFwVersion >= 106 then
        Result := Result + [rwcTemic];
    end;

    rmMatrix3RdAll:
      Result := Result + [rwcMfUltralight];

    rmZ2EHR:
      Result := Result + [rwcTemic];

    rmZ2USBMF,
    rmMatrix3Net,
    rmCPZ2MF,
    rmZ2MfCcid:
      Result := Result + [rwcMfUltralight, rwcMfClassic];

    rmZ2MFI,
    rmMatrix6:
      Result := Result + [rwcMfUltralight, rwcMfClassic, rwcMfPlus];
  end;
end;

{ TCardUID }

procedure TCardUID.Clear();
begin
  FillChar(Self, SizeOf(Self), 0);
end;

function TCardUID.IsEmpty(): Boolean;
begin
  Result := (nLength = 0);
end;

procedure TCardUID.Assign(const AData; ASize: Cardinal);
begin
  nLength := min(ASize, SizeOf(aBytes));
  if nLength <> 0 then
    Move(AData, aBytes, nLength);
end;

function TCardUID.Compare(const rUID: TCardUID): Integer;
var
  I: Integer;
begin
  Result := Integer(nLength) - rUID.nLength;
  if Result = 0 then
    for I := 0 to Integer(nLength) - 1 do
    begin
      Result := Integer(aBytes[I]) - rUID.aBytes[I];
      if Result <> 0 then
        Exit;
    end;
end;

class operator TCardUID.Equal(const a, b: TCardUID): Boolean;
begin
  Result := (a.nLength = b.nLength) and CompareMem(@a.aBytes, @b.aBytes, a.nLength);
end;

class operator TCardUID.NotEqual(const a, b: TCardUID): Boolean;
begin
  Result := not (a = b);
end;

class operator TCardUID.GreaterThan(const a, b: TCardUID): Boolean;
begin
  Result := a.Compare(b) > 0;
end;

class operator TCardUID.GreaterThanOrEqual(const a, b: TCardUID): Boolean;
begin
  Result := a.Compare(b) >= 0;
end;

class operator TCardUID.LessThan(const a, b: TCardUID): Boolean;
begin
  Result := a.Compare(b) < 0;
end;

class operator TCardUID.LessThanOrEqual(const a, b: TCardUID): Boolean;
begin
  Result := a.Compare(b) <= 0;
end;

{ TCardInfo }

procedure TCardInfo.Clear();
begin
  nType := TCardType.cUnknownCard;
  rUID.Clear();
  nSL := TMfPlusSL.mpslUnknown;
  nMpType := TMfPlusType.mptUnknown;
  nType2 := TCardType.cUnknownCard;
  rUID2.Clear();
end;

function TCardInfo.IsMfClassic(): Boolean;
begin
  Result := (nType >= cMifareMini) and (nType <= cMifare4K);
end;

function TCardInfo.IsMfPlus(): Boolean;
begin
  Result := (nType >= cMifarePlus) and (nType <= cSMXMifare4K);
end;

function TCardInfo.IsMfClassicMode(): Boolean;
begin
  Result := IsMfClassic() or (IsMfPlus() and (nSL = mpslSL1));
end;

function TCardInfo.IsMfPlusSL3Mode(): Boolean;
begin
  Result := IsMfPlus() and (nSL = mpslSL3);
end;

function TCardInfo.GetNumberOfMfBlocks(): Integer;
begin
  Result := nMemSize div 16;
end;

{ TMfPlusKey }

class operator TMfPlusKey.Equal(const a, b: TMfPlusKey): Boolean;
begin
  Result := CompareMem(@a.a, @b.a, Length(a.a));
end;

class operator TMfPlusKey.NotEqual(const a, b: TMfPlusKey): Boolean;
begin
  Result := not CompareMem(@a.a, @b.a, Length(a.a));
end;

{ TMfBlockData }

class operator TMfBlockData.Equal(const a, b: TMfBlockData): Boolean;
begin
  Result := CompareMem(@a.a, @b.a, Length(a.a));
end;

class operator TMfBlockData.NotEqual(const a, b: TMfBlockData): Boolean;
begin
  Result := not CompareMem(@a.a, @b.a, Length(a.a));
end;


{$IFDEF ILREADERS_LINKONREQUEST}
var
  g_hLib: THandle = 0;
  g_nLoadCount: Integer = 0;

function IsILRLoaded(): Boolean;
begin
  Result := g_hLib <> 0;
end;

function LoadILR(): HResult;
  function GetModuleSymbolEx(ASymbolName: LPCSTR; var VAccu: HResult): Pointer;
  begin
    Result := GetProcAddress(g_hLib, ASymbolName);
    if Result = nil then VAccu := E_NOINTERFACE;
  end;
begin
  Result := S_OK;
  if g_nLoadCount > 0 then
  begin
    Inc(g_nLoadCount);
    Exit;
  end;

  g_hLib := LoadLibrary(PChar(ILR_DLLNAME));
  if g_hLib = 0 then
    Exit(HResultFromWin32(GetLastError()));

  @ILR_GetVersion := GetModuleSymbolEx('ILR_GetVersion', Result);
  @ILR_GetErrorText := GetModuleSymbolEx('ILR_GetErrorText', Result);
  @ILR_GetInterface := GetModuleSymbolEx('ILR_GetInterface', Result);
  if Succeeded(Result) then
  begin
    Inc(g_nLoadCount);
  end
  else
    Result := ILR_E_WRONG_SDK_VERSION;

  if Failed(Result) then
    UnloadILR();
end;

procedure UnloadILR();
begin
  if g_nLoadCount = 0 then
    Exit;
  Dec(g_nLoadCount);
  FreeLibrary(g_hLib);
  ILR_GetVersion := nil;
  ILR_GetErrorText := nil;
  ILR_GetInterface := nil;
end;

{$ELSE}

function IsILRLoaded(): Boolean;
begin
  Result := True;
end;

function LoadILR(): HResult;
begin
  Result := S_OK;
end;

procedure UnloadILR();
begin
end;

function ILR_GetVersion(): Cardinal;
        external ILR_Dll_Name name 'ILR_GetVersion';
function ILR_GetErrorText(AErrorCode: HResult; out VText: TBStr): HResult;
        external ILR_Dll_Name name 'ILR_GetErrorText';
function ILR_GetInterface(out VObj: IILR;
    AVersionRequested: Cardinal {= ILR_SDK_VERSION}): HResult; stdcall;
        external ILR_Dll_Name name 'ILR_GetInterface';

{$ENDIF ILREADERS_LINKONREQUEST}

function ReaderTypesToFlags(ATypes: TReaderTypes): Cardinal;
begin
  Result := 0;
  if rtILUsb in ATypes then
    Result := Result or RT_F_ILUSB;
  if rtTPUsb in ATypes then
    Result := Result or RT_F_TPUSB;
  if rtCcid in ATypes then
    Result := Result or RT_F_CCID;
  if rtServer in ATypes then
    Result := Result or RT_F_SERVER;
  if rtClient in ATypes then
    Result := Result or RT_F_CLIENT;
end;

function FlagsToReaderTypes(AFlags: Cardinal): TReaderTypes;
begin
  Result := [];
  if (AFlags and RT_F_ILUSB) <> 0 then
    Include(Result, rtILUsb);
  if (AFlags and RT_F_TPUSB) <> 0 then
    Include(Result, rtTPUsb);
  if (AFlags and RT_F_CCID) <> 0 then
    Include(Result, rtCcid);
  if (AFlags and RT_F_SERVER) <> 0 then
    Include(Result, rtServer);
  if (AFlags and RT_F_CLIENT) <> 0 then
    Include(Result, rtClient);
end;

function RwCardTypesToFlags(ATypes: TRwCardTypes): Cardinal;
begin
  Result := 0;
  if rwcMfUltralight in ATypes then
    Result := Result or RWCT_F_MFULTRALIGHT;
  if rwcMfClassic in ATypes then
    Result := Result or RWCT_F_MFCLASSIC;
  if rwcMfPlus in ATypes then
    Result := Result or RWCT_F_MFPPLUS;
  if rwcTemic in ATypes then
    Result := Result or RWCT_F_TEMIC;
end;


end.
