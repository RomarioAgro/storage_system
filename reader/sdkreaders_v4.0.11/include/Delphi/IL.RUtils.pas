unit IL.RUtils;

interface

uses
  System.SysUtils, System.Win.ComObj,
  IL.Readers;

type
  EILRError = class(EOleException)
    constructor Create(const Message: string; ErrorCode: HRESULT;
      const Source, HelpFile: string; HelpContext: Integer);
  end;

const
  // Названия моделей считывателей
  kRdModelNames: array[TReaderModel] of string = (
    '',
    'Z-2 RD_ALL',
    'Z-2 USB MF',
    'Z-2 MF-I',
    'Z-2 EHR',
    'Z-2 Base',
    'RF-1996',
    'Matrix III Rd-All',
    'Matrix III Net',
    'CP-Z 2MF',
    'Matrix V',
    'Z-2 MF CCID',
    'Matrix-VI (NFC K Net)'
  );
  // Название типов карт
  kCardTypeNames: array[TCardType] of string = (
    '',
    'Em-Marine',
    'HID',
    'iCode',
    'Cod433',
    'Cod433 Fix',
    'CAME',
    'Dallas',
    'Temic',
    'Mifare UltraLight',
    'Mifare UltraLight C',
    'Mifare Mini',
    'Mifare Classic 1K',
    'Mifare Classic 2K',
    'Mifare Classic 4K',
    'Mifare Plus',
    'Mifare Plus 1K',
    'Mifare Plus 2K',
    'Mifare Plus 4K',
    'Smart MX with Mifare 1K',
    'Smart MX with Mifare 4K',
    'Mifare DESFire',
    'Mifare ProX'
  );
  // Название подтипов карт Mifare Plus
  kMpTypeNames: array[TMfPlusType] of string = (
    '',
    'S',
    'X',
    'SE',
    'EV1',
    'EV2'
  );

// Вызывает исключение EILRError если AStatus является ошибкой
procedure ILRCheck(AStatus: HResult);
// Возвращает текст ошибки
function ILRGetErrorText(AErrorCode: HResult): string;
// Преобразует время, возвращаемое SDK, в TDateTime
// Если время не известно, то возвращает 0
function ILRTimeToDateTime(AILRTime: Int64): TDateTime;
// Преобразует номер версии, возвращаемый SDK, в строку
function ILRVersionToStr(AVersion: Cardinal): string;
// Преобразует время, возвращаемое SDK, в строку
function ILRTimeToStr(AILRTime: Int64): string;
// Преобразует UID карты в строку
function ILRCardUIDToStr(AType: TCardType; const AUID: TCardUID): string;

// Возвращает номер сектора по номеру блока
function GetMfSectorByBlock(ABlock: Integer): Integer;
// Возвращает номер блока по номеру сектора
function GetMfBlockBySector(ASector: Integer): Integer;
// Возвращает количество блоков в секторе
function GetMfSectorBlockCount(ASector: Integer): Integer;
procedure GetMfBlockInfo(ABlock: Integer;
    out VSectror, VSBlock, VSBlockCount: Integer);
// Возвращает биты доступа Mifare
function GetMfAccessBits(const ATrailerData: TMfBlockData): Cardinal;
// Устанавливает биты доступа Mifare
procedure SetMfAccessBits(var VTrailerData: TMfBlockData; AAccessBits: Cardinal);
// Возвращает номер области сектора Mifare по номеру блока
function GetMfAreaByBlockIdx(ABlockIdx: Integer): Integer;
// Возвращает биты доступа для области сектора Mifare (3 бита)
function GetMfAreaAccess(AAccessBits: Cardinal; AArea: Integer): Cardinal;
// Устанавливает биты доступа для области сектора Mifare (3 бита)
procedure SetMfAreaAccess(var VAccessBits: Cardinal; AArea: Integer;
  AAreaBits: Cardinal);
// Преобразует ключ аутентификации Mifare Classic в строку
function MfClassicKeyToStr(const AKey: TMfClassicKey): string;
// Преобразует строку в ключ аутентификации Mifare Classic
function TryStrToMfClassicKey(const AStr: string; var VKey: TMfClassicKey): Boolean;
// Преобразует ключ аутентификации Mifare Plus в строку
function MfPlusKeyToStr(const AKey: TMfPlusKey): string;
// Преобразует строку в ключ аутентификации Mifare Plus
function TryStrToMfPlusKey(const AStr: string; var VKey: TMfPlusKey): Boolean;

function GetTickSpan(AOld, ANew: Cardinal): Cardinal;
function GetBit(AVal: Cardinal; AIdx: Integer): Boolean;
procedure SetBit(var VVal: Cardinal; AIdx: Integer; AOn: Boolean = True);
function Sscanf(const s: string; const fmt: string;
  const Args: array of Pointer): Integer;

implementation

uses
  WinApi.Windows, WinApi.ActiveX,
  System.DateUtils, System.Math, System.Character;

type
  OleSysErorClass = class of EOleSysError;
  OleExceptionClass = class of EOleException;

procedure CustomSafeCallError(ErrorCode: HResult; ErrorAddr: Pointer);
  // Строит исключение по коду и дополнительной информации
  function CreateExceptionFromCode(ACode: HRESULT): Exception;
  var
    ExceptionClass: ExceptClass;
    ErrorInfo: IErrorInfo;
    Source, Description, HelpFile: WideString;
    HelpContext: Longint;
  begin
    // Определяем класс:
    // а) системные ошибки
    if HResultFacility(ACode) = FACILITY_WIN32 then
      ExceptionClass := EOSError
    else
    // б) все прочие - общий класс
      ExceptionClass := EOleException;

    // Получаем дополнительную информацию
    if GetErrorInfo(0, ErrorInfo) = S_OK then
    begin
      ErrorInfo.GetSource(Source);
      ErrorInfo.GetDescription(Description);
      ErrorInfo.GetHelpFile(HelpFile);
      ErrorInfo.GetHelpContext(HelpContext);
    end
    else
    begin
      Source := '';
      Description := '';
      HelpFile := '';
      HelpContext := 0;
    end;

    // Создаём объект исключения с информацией
    if ExceptionClass.InheritsFrom(EOleException) then
      Result := OleExceptionClass(ExceptionClass).Create(Description, ACode, Source, HelpFile, HelpContext)
    else
    if ExceptionClass.InheritsFrom(EOleSysError) then
      Result := OleSysErorClass(ExceptionClass).Create(Description, ACode, HelpContext)
    else
    begin
      Result := ExceptionClass.Create(Description);
      if Result is EOSError then
        EOSError(Result).ErrorCode := HResultCode(ACode);
    end;
  end;
var
  E: Exception;
begin
  E := CreateExceptionFromCode(HRESULT(ErrorCode));
  raise E at ErrorAddr;
end;

constructor EILRError.Create(const Message: string; ErrorCode: HRESULT;
  const Source, HelpFile: string; HelpContext: Integer);
var
  S: string;
begin
  S := Message;
  if S = '' then
    S := ILRGetErrorText(ErrorCode);
  inherited Create(S, ErrorCode, Source, HelpFile, HelpContext);
end;

procedure ILRCheck(AStatus: HResult);
begin
  if Failed(AStatus) then
    raise EILRError.Create('', AStatus, '', '', 0);
end;

function ILRGetErrorText(AErrorCode: HResult): string;
var
  nFlags: Cardinal;
  nLen: Integer;
  pSource: Pointer;
  pBuffer: PChar;
begin
  nFlags := FORMAT_MESSAGE_ALLOCATE_BUFFER;
  if HResultFacility(AErrorCode) = FACILITY_ITF then
  begin
    pSource := Pointer(GetModuleHandle(PChar(ILR_DLL_NAME)));
    Inc(nFlags, FORMAT_MESSAGE_FROM_HMODULE);
  end
  else
  begin
    pSource := nil;
    Inc(nFlags, FORMAT_MESSAGE_FROM_SYSTEM);
  end;
  pBuffer := nil;
  try
    nLen := FormatMessage(nFlags, pSource, AErrorCode, 0, PChar(@pBuffer), 0, nil);
    SetString(Result, pBuffer, nLen);
  finally
    if pBuffer <> nil then
      LocalFree(HLOCAL(pBuffer));
  end;
end;

function ILRTimeToDateTime(AILRTime: Int64): TDateTime;
begin
  if AILRTime = 0 then
    Result := 0
  else
    Result := System.DateUtils.TTimeZone.Local.ToLocalTime(UnixToDateTime(AILRTime));
end;

function ILRVersionToStr(AVersion: Cardinal): string;
var
  A: array[0..3] of Byte absolute AVersion;
  I, nLen: Integer;
begin
  Result := string.Empty;
  if AVersion = 0 then
    Exit;
  if (AVersion and $ff) = $ff then
    Exit(UIntToStr(AVersion shr 8));

  nLen := Length(A);
  for I := (nLen - 1) downto 0 do
  begin
    if A[I] <> 0 then
      break;
    Dec(nLen);
  end;
  if nLen = 0 then
    Exit;
  Result := IntToStr(A[0]);
  for I := 1 to nLen - 1 do
    Result := Result + '.' + IntToStr(A[I]);
end;

function ILRTimeToStr(AILRTime: Int64): string;
begin
  if AILRTime = 0 then
    Result := ''
  else
    Result := DateTimeToStr(ILRTimeToDateTime(AILRTime));
end;

function ILRCardUIDToStr(AType: TCardType; const AUID: TCardUID): string;
var
  I: Integer;
  nFacility: Cardinal;
begin
  case AType of
    cEmMarine,
    cICode,
    cCod433,
    cCod433Fix,
    cCame433:
      Result := format('[%.2X%.2X] %.3u,%.5u', [
          AUID.aBytes[4], AUID.aBytes[3], AUID.aBytes[2], PWord(@AUID.aBytes)^]);

    cHID:
    begin
      nFacility := 0;
      I := min(AUID.nLength - 2, 4);
      if I > 0 then
        Move(AUID.aBytes[2], nFacility, I);
      Result := format('[%.*X] %.5d', [I * 2, nFacility, PWord(@AUID.aBytes)^]);
    end;

    else
    begin
      Result := '';
      for I := AUID.nLength - 1 downto 0 do
        Result := Result + IntToHex(AUID.aBytes[I], 2);
    end;
  end;
end;

function GetMfSectorByBlock(ABlock: Integer): Integer;
begin
  if ABlock < 128 then
    Result := (ABlock div 4)
  else
    Result := (32 + ((ABlock - 128) div 16));
end;

function GetMfBlockBySector(ASector: Integer): Integer;
begin
  if ASector < 32 then
    Result := (ASector * 4)
  else
    Result := (128 + ((ASector - 32) * 16));
end;

function GetMfSectorBlockCount(ASector: Integer): Integer;
begin
  if ASector < 32 then
    Result := 4
  else
    Result := 16;
end;

procedure GetMfBlockInfo(ABlock: Integer; out VSectror, VSBlock,
  VSBlockCount: Integer);
begin
  if ABlock < 128 then
  begin
    VSectror := (ABlock div 4);
    VSBlock := (ABlock mod 4);
    VSBlockCount := 4;
  end
  else
  begin
    VSectror := (32 + ((ABlock - 128) div 16));
    VSBlock := (ABlock mod 16);
    VSBlockCount := 16;
  end;
end;

function GetMfAccessBits(const ATrailerData: TMfBlockData): Cardinal;
begin
  Result := 0;
  Move(ATrailerData.a[6], Result, 3);
end;

procedure SetMfAccessBits(var VTrailerData: TMfBlockData; AAccessBits: Cardinal);
begin
  Move(AAccessBits, VTrailerData.a[6], 3);
end;

function GetMfAreaByBlockIdx(ABlockIdx: Integer): Integer;
begin
  if ABlockIdx < 128 then
//    Result := ((ABlockIdx mod 4) * 3) div 3
    Result := (ABlockIdx mod 4)
  else
//    Result := ((ABlockIdx mod 16) * 3) div 15;
    Result := (ABlockIdx mod 16) div 5;
end;

function GetMfAreaAccess(AAccessBits: Cardinal; AArea: Integer): Cardinal;
begin
  Result := ((AAccessBits shr (12 + AArea)) and 1) or
    (((AAccessBits shr (16 + AArea)) and 1) shl 1) or
    (((AAccessBits shr (20 + AArea)) and 1) shl 2);
end;

procedure SetMfAreaAccess(var VAccessBits: Cardinal; AArea: Integer;
  AAreaBits: Cardinal);
var
  f: Boolean;
begin
  f := (AAreaBits and 1) <> 0;
  SetBit(VAccessBits, 12 + AArea, f);
  SetBit(VAccessBits, AArea, not f);
  f := (AAreaBits and 2) <> 0;
  SetBit(VAccessBits, 16 + AArea, f);
  SetBit(VAccessBits, 4 + AArea, not f);
  f := (AAreaBits and 4) <> 0;
  SetBit(VAccessBits, 20 + AArea, f);
  SetBit(VAccessBits, 8 + AArea, not f);
end;

function MfClassicKeyToStr(const AKey: TMfClassicKey): string;
begin
  Result := IntToHex(AKey, 12);
end;

function TryStrToMfClassicKey(const AStr: string; var VKey: TMfClassicKey): Boolean;
var
  N: Int64;
begin
  Result := TryStrToInt64('$' + AStr, N) and (N >= 0) and (N <= $FFFFFFFFFFFF);
  if Result then
    VKey := N;
end;

function MfPlusKeyToStr(const AKey: TMfPlusKey): string;
begin
  Result := IntToHex(PUInt64(@AKey.a[8])^, 16) +
    IntToHex(PUInt64(@AKey.a[0])^, 16);
end;

function TryStrToMfPlusKey(const AStr: string; var VKey: TMfPlusKey): Boolean;
var
  N: UInt64;
  E: Integer;
begin
  Val('$' + Copy(AStr, max(Length(AStr) - 15, 1), 16), N, E);
  Result := E = 0;
  if Result then
  begin
    PUInt64(@VKey.a[0])^ := N;
    if Length(AStr) > 16 then
    begin
      Val('$' + Copy(AStr, 1, Length(AStr) - 16), N, E);
      Result := E = 0;
      if Result then
        PUInt64(@VKey.a[8])^ := N;
    end;
  end;
end;

function GetTickSpan(AOld, ANew: Cardinal): Cardinal;
begin
  {This is just in case the TickCount rolled back to zero}
  if ANew >= AOld then begin
    Result := ANew - AOld;
  end else begin
    Result := High(LongWord) - AOld + ANew;
  end;
end;

function GetBit(AVal: Cardinal; AIdx: Integer): Boolean;
begin
  Result := ((AVal shr AIdx) and 1) <> 0;
end;

procedure SetBit(var VVal: Cardinal; AIdx: Integer; AOn: Boolean {= True});
begin
  if AOn then
    VVal := VVal or (1 shl AIdx)
  else
    VVal := VVal and (not (1 shl AIdx));
end;

//{ Sscanf выполняет синтаксический разбор входной строки. Параметры...
//
//s - входная строка для разбора
//fmt - 'C' scanf-форматоподобная строка для управления разбором
//%c - преобразование в Char
//%d - преобразование в Long Integer
//%l - преобразование в Int64
//%f - преобразование в Extended Float
//%s - преобразование в строку (ограничено пробелами)
//другой символ - приращение позиции s на "другой символ"
//пробел - ничего не делает
//Pointers - массив указателей на присваиваемые переменные
//
//результат - количество действительно присвоенных переменных
//
//Например, ...
//Sscanf('Name. Bill   Time. 7:32.77   Age. 8',
//'. %s . %d:%f . %d', [@Name, @hrs, @min, @age]);
//
//возвратит ...
//Name = Bill  hrs = 7  min = 32.77  age = 8 }
//
function Sscanf(const s: string; const fmt: string;
  const Args: array of Pointer): Integer;
type
  TFmtType = (ftNone,
      ftChar, ftInteger, ftInt64, ftHex, ftExtended, ftString);
var
  I, n, m: integer;
  nFmt: TFmtType;
  s1: string;

  function GetChar(): Integer;
  begin
    if Length(s) >= n then
    begin
      s1 := s[n];
      Inc(n);
    end
    else
      s1 := string.Empty;
    Result := Length(s1);
  end;

  function GetInt: Integer;
  begin
    s1 := string.Empty;
    while (Length(s) > n) and (s[n] = ' ') do
      Inc(n);
    while (Length(s) >= n) and CharInSet(s[n], ['0'..'9', '+', '-']) do
    begin
      s1 := s1 + s[n];
      Inc(n);
    end;
    Result := Length(s1);
  end;
  function GetHex: Integer;
  begin
    s1 := string.Empty;
    while (Length(s) > n) and (s[n] = ' ') do
      inc(n);
    while (Length(s) >= n) and CharInSet(s[n], ['0'..'9','a'..'f','A'..'F']) do
    begin
      s1 := s1 + s[n];
      Inc(n);
    end;
    Result := Length(s1);
  end;

  function GetFloat: Integer;
  begin
    s1 := string.Empty;
    while (Length(s) > n) and (s[n] = ' ') do
      Inc(n);
    if (Length(s) >= n) and CharInSet(s[n], ['+', '-']) then
    begin
      s1 := s1 + s[n];
      Inc(n);
    end;

    while (Length(s) >= n) and CharInSet(s[n], ['0'..'9', FormatSettings.DecimalSeparator, 'e', 'E']) do
    begin
      s1 := s1 + s[n];
      Inc(n);
    end;
    Result := Length(s1);
  end;

  function GetString: Integer;
  begin
    s1 := string.Empty;
    while (Length(s) > n) and (s[n] = ' ') do
      Inc(n);
    if m <= Length(fmt) then
    begin
      while (Length(s) >= n) and (s[n] <> ' ') and (s[n] <> fmt[m]) do
      begin
        s1 := s1 + s[n];
        Inc(n);
      end;
    end
    else
    begin
      while (Length(s) >= n) and (s[n] <> ' ') do
      begin
        s1 := s1 + s[n];
        Inc(n);
      end;
    end;
    Result := Length(s1);
  end;

  function ScanStr(c: Char): Boolean;
  begin
    while (Length(s) > n) and (s[n] <> c) do
      inc(n);
    Result := (n <= Length(s));
    inc(n);
  end;

  function GetFmt: TFmtType;
  begin
    Result := ftNone;
    while (True) do
    begin
      while (Length(fmt) > m) and (fmt[m] = ' ') do
        inc(m);
      if (m >= Length(fmt)) then
        break;
      if (fmt[m] = '%') then
      begin
        inc(m);
        case fmt[m].ToLower() of
          'c': Result := ftChar;
          'd': Result := ftInteger;
          'l': Result := ftInt64;
          'x': Result := ftHex;
          'f': Result := ftExtended;
          's': Result := ftString;
          '%': break;
        end;
        inc(m);
        break;
      end;
      if (ScanStr(fmt[m]) = False) then
        break;
      inc(m);
    end;
  end;

begin
  n := 1;
  m := 1;
  Result := 0;
  for I := 0 to High(Args) do
  begin
    nFmt := GetFmt;
    case nFmt of
      ftChar:
      begin
        if GetChar() > 0 then
        begin
          PChar(Args[I])^ := s1[1];
          inc(Result);
        end
        else
          break;
      end;
      ftInteger,
      ftInt64:
        begin
          if GetInt > 0 then
          begin
            if nFmt = ftInteger then
              PInteger(Args[I])^ := StrToIntDef(s1, 0)
            else
              PInt64(Args[I])^ := StrToInt64Def(s1, 0);
            inc(Result);
          end
          else
            break;
        end;
      ftHex:
        begin
          if GetHex > 0 then
          begin
            PInteger(Args[I])^ := StrToIntDef('$' + s1, 0);
            inc(Result);
          end
          else
            break;
        end;
      ftExtended:
        begin
          if GetFloat > 0 then
          begin
            PExtended(Args[I])^ := StrToFloatDef(s1, 0);
            inc(Result);
          end
          else
            break;
        end;
      ftString:
        begin
          GetString();
          PString(Args[I])^ := s1;
          inc(Result);
        end;
    else
      break;
    end;
  end;
end;

// Установка и снятие обработчика
initialization
  SafeCallErrorProc := CustomSafeCallError;
finalization
  SafeCallErrorProc := nil;

end.
