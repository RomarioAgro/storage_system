unit uAppSettings;

interface

uses
  System.Types,
  IL.Readers, uTypes, uConst, uClasses;

type
  { TAppSettings - настройки программы }

  TAppSettings = class
  public
    m_fModified     : Boolean; // True, настройки изменены, но не сохранены в файл

    m_nLanguageId   : Cardinal;   // Id языка интерфейса
    m_fDebugLog     : Boolean;    // True, писать лог отладки
    m_nDLogLevel    : TLogLevel;  // Уровень лога отладки
    // Настройки поиска считывателей
    m_nReaderTypes  : TReaderTypes; // Типы считывателей для поиска
    m_fShowUnidentified: Boolean; // True, показывать неопознанные конвертеры
    // Настройки поиска карт
    m_fTmcAutoScan  : Boolean;  // True, автоматически сканировать карты Temic
    m_nTmcScanParam : Integer;  // Параметры сканирования Temic
    m_fTmcPswEnabled: Boolean;  // True, использоваться пароль Temic
    m_nTmcPassword  : Cardinal; // Пароль Temic
    // Настройки Temic
    m_nTmcDataFormat: TCellFormat;  // Формат данных в окне "Temic"
    m_oTmcPasswords : TTemicPasswordList; // Список паролей Temic
    m_nTmcPasswFormat: TTmcPasswFormat; // Формат пароля Temic
    m_nHidFormat    : THidFormat; // Формат номера HID в окне "Temic"
    // Настройки Mifare Ultralight
    m_nMulDataFormat: TCellFormat;  // Формат данных в окне "Mifare Ultralight"
    // Настройки Mifare Classic
    m_nMcDataFormat : TCellFormat;  // Формат данных в окне "Mifare Classic"
    m_fMcKeyB       : Boolean;      // True, авторизация по ключу B
    m_fMcAuthByRdKeys: Boolean;     // True, авторизация по ключам считывателя
    m_nMcAuthKey    : TMfClassicKey;// Ключ аутентификации Mifare Classic
    m_oMcKeys       : TMfClassicKeyList; // Список ключей аутентификации Mifare Classic
    // Настройки Mifare Plus
    m_nMpDataFormat : TCellFormat;  // Формат данных в окне "Mifare Plus"
    m_fMpKeyB       : Boolean;      // True, авторизация по ключу B
    m_fMpAuthByRdKeys: Boolean;     // True, авторизация по ключам считывателя
    m_fMpOpenText   : Boolean;    // True, открытая передача, иначе - зашифрованная
    m_rMpAuthKey    : TMfPlusKey; // Ключ аутентификации Mifare Plus
    m_oMpKeys       : TMfPlusKeyList; // Список ключей аутентификации Mifare Plus

    m_aWinSizes     : array[TSizeWinKind] of TSize; // Размеры окон

  public
    constructor Create;
    destructor Destroy; override;

    procedure Load;
    procedure Save;
    procedure SaveTemicPasswords;
    procedure SaveMfClassicKeys;
    procedure SaveMfPlusKeys;

    procedure SetLanguage(Value: Cardinal);
    procedure SetDebugLog(Value: Boolean);
    procedure SetDebugLogLevel(Value: TLogLevel);
    procedure SetReaderTypes(Value: TReaderTypes);
    procedure ShowUnidentified(Value: Boolean);
    procedure SetTmcAutoScan(Value: Boolean);
    procedure SetTmcScanParam(Value: Integer);
    procedure SetTmcPswEnabled(Value: Boolean);
    procedure SetTmcPassword(Value: Cardinal);
    procedure SetTemicDataFormat(Value: TCellFormat);
    procedure SetTemicPasswordFormat(Value: TTmcPasswFormat);
    procedure SetHidFormat(Value: THidFormat);
    procedure SetMulDataFormat(Value: TCellFormat);
    procedure SetMcDataFormat(Value: TCellFormat);
    procedure SetMcKeyB(Value: Boolean);
    procedure SetMcAuthByRdKeys(Value: Boolean);
    procedure SetMcAuthKey(const Value: TMfClassicKey);
    procedure SetMpDataFormat(Value: TCellFormat);
    procedure SetMpKeyB(Value: Boolean);
    procedure SetMpAuthByRdKeys(Value: Boolean);
    procedure SetMpOpenText(Value: Boolean);
    procedure SetMpAuthKey(const Value: TMfPlusKey);
    procedure SetWinSize(AWinKind: TSizeWinKind; const ASize: TSize);
  end;

var
  g_AppSet: TAppSettings {= nil};

implementation

uses
  System.SysUtils, System.IniFiles, System.Rtti,
  IL.RUtils, uUtils;

const
  kMainSect = 'Main';
  kLanguage = 'Language';
  kDebugLogSect = 'DebugLog';
  kEnabled = 'Enabled';
  kLogLevel = 'LogLevel';
  kSearchSect = 'Search';
  kReaderTypes = 'ReaderTypes';
  kShowUnidentified = 'ShowUnidentified';
  kReaderSect = 'Reader';
  kTemicSect = 'Temic';
  kAutoScan = 'AutoScan';
  kScanParam = 'ScanParam';
  kPasswordEnabled = 'PasswordEnabled';
  kPassword = 'Password';
  kDataFormat = 'DataFormat';
  kPasswordFormat = 'PasswordFormat';
  kHidFormat = 'HidFormat';
  kMfUltralightSect = 'MfUltralight';
  kMfClassicSect = 'MfClassic';
  kKeyB = 'KeyB';
  kAuthByRdKeys = 'AuthByRdKeys';
  kOpenText = 'OpenText';
  kAuthKey = 'AuthKey';
  kWinSizeSect = 'WinSize';
  kMfPlusSect = 'MfPlus';

{ TAppSettings }

constructor TAppSettings.Create;
begin
  inherited;
  m_nReaderTypes := [rtILUsb, rtCcid];
  m_fShowUnidentified := True;
  m_nDLogLevel := TLogLevel.llDebug;
  m_fTmcAutoScan := False;
  m_nTmcScanParam := -1;
  m_nTmcDataFormat := cfHex;
  m_oTmcPasswords := TTemicPasswordList.Create;
  m_nTmcPasswFormat := tpfHex;
  m_nMulDataFormat := cfHex;
  m_nMcDataFormat := cfHex;
  m_nMpDataFormat := cfHex;
  m_fMpOpenText := True;
  m_nMcAuthKey := kDefaultMfClassicKey;
  m_rMpAuthKey := kDefaultMfPlusKey;
  m_oMcKeys := TMfClassicKeyList.Create;
  m_oMpKeys := TMfPlusKeyList.Create;
end;

destructor TAppSettings.Destroy;
begin
  m_oMpKeys.Free;
  m_oMcKeys.Free;
  m_oTmcPasswords.Free;
  inherited;
end;

procedure TAppSettings.Load;
var
  sPath: string;
  oIni: TMemIniFile;
  N: Integer;
  N2: Int64;
  nSizeWin: TSizeWinKind;
  rSize: TSize;
begin
  // Загружаем основные настройки
  sPath := ChangeFileExt(ParamStr(0), '.ini');
  if FileExists(sPath) then
  begin
    oIni := TMemIniFile.Create(sPath);
    try
      m_nLanguageId := Cardinal(oIni.ReadInteger(kMainSect, kLanguage,
        Integer(m_nLanguageId)));
      m_fDebugLog := oIni.ReadBool(kDebugLogSect, kEnabled, m_fDebugLog);
      N := oIni.ReadInteger(kDebugLogSect, kLogLevel, -1);
      if (N > Integer(llDisabled)) and (N <= Integer(High(TLogLevel))) then
        m_nDLogLevel := TLogLevel(N);
      N := oIni.ReadInteger(kSearchSect, kReaderTypes, -1);
      if N >= 0 then
        m_nReaderTypes := FlagsToReaderTypes(Cardinal(N));
      m_fShowUnidentified := oIni.ReadBool(kSearchSect, kShowUnidentified, m_fShowUnidentified);
      // Загружаем параметры Temic
      m_fTmcAutoScan := oIni.ReadBool(kTemicSect, kAutoScan, m_fTmcAutoScan);
      m_nTmcScanParam := oIni.ReadInteger(kTemicSect, kScanParam, m_nTmcScanParam);
      m_fTmcPswEnabled := oIni.ReadBool(kTemicSect, kPasswordEnabled, m_fTmcPswEnabled);
      if TryStrToInt64(oIni.ReadString(kTemicSect, kPassword, string.Empty), N2) and
        (N2 >= 0) and (N2 <= $ffffffff) then
        m_nTmcPassword := N2;
      N := oIni.ReadInteger(kTemicSect, kDataFormat, -1);
      if (N >= Integer(Low(TCellFormat))) and (N <= Integer(High(TCellFormat))) then
        m_nTmcDataFormat := TCellFormat(N);
      N := oIni.ReadInteger(kTemicSect, kPasswordFormat, -1);
      if (N >= Integer(Low(TTmcPasswFormat))) and (N <= Integer(High(TTmcPasswFormat))) then
        m_nTmcPasswFormat := TTmcPasswFormat(N);
      N := oIni.ReadInteger(kTemicSect, kHidFormat, -1);
      if (N >= Integer(Low(THidFormat))) and (N <= Integer(High(THidFormat))) then
        m_nHidFormat := THidFormat(N);
      // Загружаем параметры Mifare Ultralight
      N := oIni.ReadInteger(kMfUltralightSect, kDataFormat, -1);
      if (N >= Integer(Low(TCellFormat))) and (N <= Integer(High(TCellFormat))) then
        m_nMulDataFormat := TCellFormat(N);
      // Загружаем параметры Mifare Classic
      N := oIni.ReadInteger(kMfClassicSect, kDataFormat, -1);
      if (N >= Integer(Low(TCellFormat))) and (N <= Integer(High(TCellFormat))) then
        m_nMcDataFormat := TCellFormat(N);
      m_fMcKeyB := oIni.ReadBool(kMfClassicSect, kKeyB, m_fMCKeyB);
      m_fMcAuthByRdKeys := oIni.ReadBool(kMfClassicSect, kAuthByRdKeys, m_fMcAuthByRdKeys);
      TryStrToMfClassicKey(oIni.ReadString(kMfClassicSect, kAuthKey, string.Empty), m_nMcAuthKey);
      // Загружаем параметры Mifare Plus
      N := oIni.ReadInteger(kMfPlusSect, kDataFormat, -1);
      if (N >= Integer(Low(TCellFormat))) and (N <= Integer(High(TCellFormat))) then
        m_nMpDataFormat := TCellFormat(N);
      m_fMpKeyB := oIni.ReadBool(kMfPlusSect, kKeyB, m_fMCKeyB);
      m_fMpAuthByRdKeys := oIni.ReadBool(kMfPlusSect, kAuthByRdKeys, m_fMpAuthByRdKeys);
      m_fMpOpenText := oIni.ReadBool(kMfPlusSect, kOpenText, m_fMpOpenText);
      TryStrToMfPlusKey(oIni.ReadString(kMfPlusSect, kAuthKey, string.Empty), m_rMpAuthKey);

      for nSizeWin := Low(TSizeWinKind) to High(TSizeWinKind) do
      begin
        if sscanf(
          oIni.ReadString(kWinSizeSect, TRttiEnumerationType.GetName(nSizeWin), string.Empty),
          '[%d,%d]', [@rSize.cx, @rSize.cy]) = 2 then
          m_aWinSizes[nSizeWin] := rSize;
      end;
    finally
      oIni.Free;
    end;
  end;
  // Загружаем список паролей Temic
  sPath := IncludeTrailingPathDelimiter(ExtractFileDir(ParamStr(0))) +
    kTemicPasswordsFilename;
  if FileExists(sPath) then
    m_oTmcPasswords.LoadFromFile(sPath);
  // Загружаем список ключей Mifare Classic
  sPath := IncludeTrailingPathDelimiter(ExtractFileDir(ParamStr(0))) +
    kMfClassicKeysFilename;
  if FileExists(sPath) then
    m_oMcKeys.LoadFromFile(sPath);
  // Загружаем список ключей Mifare Plus
  sPath := IncludeTrailingPathDelimiter(ExtractFileDir(ParamStr(0))) +
    kMfPlusKeysFilename;
  if FileExists(sPath) then
    m_oMpKeys.LoadFromFile(sPath);

  m_fModified := False;
end;

procedure TAppSettings.Save;
var
  sPath: string;
  oIni: TMemIniFile;
  nSizeWin: TSizeWinKind;
begin
  sPath := ChangeFileExt(ParamStr(0), '.ini');
  oIni := TMemIniFile.Create(sPath);
  try
    oIni.WriteInteger(kMainSect, kLanguage, Integer(m_nLanguageId));
    oIni.WriteBool(kDebugLogSect, kEnabled, m_fDebugLog);
    oIni.WriteInteger(kDebugLogSect, kLogLevel, Integer(m_nDLogLevel));
    oIni.WriteInteger(kSearchSect, kReaderTypes,
      ReaderTypesToFlags(m_nReaderTypes));
    oIni.WriteBool(kSearchSect, kShowUnidentified, m_fShowUnidentified);
    // Сохраняем параметры Temic
    oIni.WriteBool(kTemicSect, kAutoScan, m_fTmcAutoScan);
    oIni.WriteInteger(kTemicSect, kScanParam, m_nTmcScanParam);
    oIni.WriteBool(kTemicSect, kPasswordEnabled, m_fTmcPswEnabled);
    oIni.WriteString(kTemicSect, kPassword, IntToStr(m_nTmcPassword));
    oIni.WriteInteger(kTemicSect, kDataFormat, Integer(m_nTmcDataFormat));
    oIni.WriteInteger(kTemicSect, kPasswordFormat, Integer(m_nTmcPasswFormat));
    oIni.WriteInteger(kTemicSect, kHidFormat, Integer(m_nHidFormat));
    // Сохраняем параметры Mifare Ultralight
    oIni.WriteInteger(kMfUltralightSect, kDataFormat, Integer(m_nMulDataFormat));
    // Сохраняем параметры Mifare Classic
    oIni.WriteInteger(kMfClassicSect, kDataFormat, Integer(m_nMcDataFormat));
    oIni.WriteBool(kMfClassicSect, kKeyB, m_fMcKeyB);
    oIni.WriteBool(kMfClassicSect, kAuthByRdKeys, m_fMcAuthByRdKeys);
    oIni.WriteString(kMfClassicSect, kAuthKey, MfClassicKeyToStr(m_nMcAuthKey));
    // Сохраняем параметры Mifare Plus
    oIni.WriteInteger(kMfPlusSect, kDataFormat, Integer(m_nMpDataFormat));
    oIni.WriteBool(kMfPlusSect, kKeyB, m_fMpKeyB);
    oIni.WriteBool(kMfPlusSect, kAuthByRdKeys, m_fMpAuthByRdKeys);
    oIni.WriteBool(kMfPlusSect, kOpenText, m_fMpOpenText);
    oIni.WriteString(kMfPlusSect, kAuthKey, MfPlusKeyToStr(m_rMpAuthKey));

    for nSizeWin := Low(TSizeWinKind) to High(TSizeWinKind) do
      oIni.WriteString(kWinSizeSect, TRttiEnumerationType.GetName(nSizeWin),
        format('[%d,%d]', [m_aWinSizes[nSizeWin].cx, m_aWinSizes[nSizeWin].cy]));
    oIni.UpdateFile;
  finally
    oIni.Free;
  end;
  m_fModified := False;
end;

procedure TAppSettings.SaveMfClassicKeys;
var
  sPath: string;
begin
  sPath := IncludeTrailingPathDelimiter(ExtractFileDir(ParamStr(0))) +
    kMfClassicKeysFilename;
  m_oMcKeys.SaveToFile(sPath);
end;

procedure TAppSettings.SaveMfPlusKeys;
var
  sPath: string;
begin
  sPath := IncludeTrailingPathDelimiter(ExtractFileDir(ParamStr(0))) +
    kMfPlusKeysFilename;
  m_oMpKeys.SaveToFile(sPath);
end;

procedure TAppSettings.SaveTemicPasswords;
var
  sPath: string;
begin
  sPath := IncludeTrailingPathDelimiter(ExtractFileDir(ParamStr(0))) +
    kTemicPasswordsFilename;
  m_oTmcPasswords.SaveToFile(sPath);
end;

procedure TAppSettings.SetReaderTypes(Value: TReaderTypes);
begin
  if m_nReaderTypes = Value then
    Exit;
  m_nReaderTypes := Value;
  m_fModified := True;
end;

procedure TAppSettings.SetTmcAutoScan(Value: Boolean);
begin
  if m_fTmcAutoScan = Value then
    Exit;
  m_fTmcAutoScan := Value;
  m_fModified := True;
end;

procedure TAppSettings.SetTmcPassword(Value: Cardinal);
begin
  if m_nTmcPassword = Value then
    Exit;
  m_nTmcPassword := Value;
  m_fModified := True;
end;

procedure TAppSettings.SetTmcPswEnabled(Value: Boolean);
begin
  if m_fTmcPswEnabled = Value then
    Exit;
  m_fTmcPswEnabled := Value;
  m_fModified := True;
end;

procedure TAppSettings.SetTmcScanParam(Value: Integer);
begin
  if m_nTmcScanParam = Value then
    Exit;
  m_nTmcScanParam := Value;
  m_fModified := True;
end;

procedure TAppSettings.SetTemicDataFormat(Value: TCellFormat);
begin
  if m_nTmcDataFormat = Value then
    Exit;
  m_nTmcDataFormat := Value;
  m_fModified := True;
end;

procedure TAppSettings.SetTemicPasswordFormat(Value: TTmcPasswFormat);
begin
  if m_nTmcPasswFormat = Value then
    Exit;
  m_nTmcPasswFormat := Value;
  m_fModified := True;
end;

procedure TAppSettings.SetWinSize(AWinKind: TSizeWinKind; const ASize: TSize);
begin
  if m_aWinSizes[AWinKind] = ASize then
    Exit;
  m_aWinSizes[AWinKind] := ASize;
  m_fModified := True;
end;

procedure TAppSettings.ShowUnidentified(Value: Boolean);
begin
  if m_fShowUnidentified = Value then
    Exit;
  m_fShowUnidentified := Value;
  m_fModified := True;
end;

procedure TAppSettings.SetDebugLog(Value: Boolean);
begin
  if m_fDebugLog = Value then
    Exit;
  m_fDebugLog := Value;
  m_fModified := True;
end;

procedure TAppSettings.SetDebugLogLevel(Value: TLogLevel);
begin
  if m_nDLogLevel = Value then
    Exit;
  m_nDLogLevel := Value;
  m_fModified := True;
end;

procedure TAppSettings.SetHidFormat(Value: THidFormat);
begin
  if m_nHidFormat = Value then
    Exit;
  m_nHidFormat := Value;
  m_fModified := True;
end;

procedure TAppSettings.SetLanguage(Value: Cardinal);
begin
  if m_nLanguageId = Value then
    Exit;
  m_nLanguageId := Value;
  m_fModified := True;
end;

procedure TAppSettings.SetMcAuthByRdKeys(Value: Boolean);
begin
  if m_fMcAuthByRdKeys = Value then
    Exit;
  m_fMcAuthByRdKeys := Value;
  m_fModified := True;
end;

procedure TAppSettings.SetMcAuthKey(const Value: TMfClassicKey);
begin
  if m_nMcAuthKey = Value then
    Exit;
  m_nMcAuthKey := Value;
  m_fModified := True;
end;

procedure TAppSettings.SetMcDataFormat(Value: TCellFormat);
begin
  if m_nMcDataFormat = Value then
    Exit;
  m_nMcDataFormat := Value;
  m_fModified := True;
end;

procedure TAppSettings.SetMcKeyB(Value: Boolean);
begin
  if m_fMcKeyB = Value then
    Exit;
  m_fMcKeyB := Value;
  m_fModified := True;
end;

procedure TAppSettings.SetMpAuthByRdKeys(Value: Boolean);
begin
  if m_fMpAuthByRdKeys = Value then
    Exit;
  m_fMpAuthByRdKeys := Value;
  m_fModified := True;
end;

procedure TAppSettings.SetMpAuthKey(const Value: TMfPlusKey);
begin
  if m_rMpAuthKey = Value then
    Exit;
  m_rMpAuthKey := Value;
  m_fModified := True;
end;

procedure TAppSettings.SetMpDataFormat(Value: TCellFormat);
begin
  if m_nMpDataFormat = Value then
    Exit;
  m_nMpDataFormat := Value;
  m_fModified := True;
end;

procedure TAppSettings.SetMpKeyB(Value: Boolean);
begin
  if m_fMpKeyB = Value then
    Exit;
  m_fMpKeyB := Value;
  m_fModified := True;
end;

procedure TAppSettings.SetMpOpenText(Value: Boolean);
begin
  if m_fMpOpenText = Value then
    Exit;
  m_fMpOpenText := Value;
  m_fModified := True;
end;

procedure TAppSettings.SetMulDataFormat(Value: TCellFormat);
begin
  if m_nMulDataFormat = Value then
    Exit;
  m_nMulDataFormat := Value;
  m_fModified := True;
end;

end.
