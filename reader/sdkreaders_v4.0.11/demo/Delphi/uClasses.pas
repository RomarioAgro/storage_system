unit uClasses;

interface

uses
  System.Generics.Collections, System.Classes,
  Vcl.ComCtrls,
  IL.Readers, uTypes, uConst;

type
  TLangInfoList = TList<TLangInfo>;

  { TVirtualListViewData }

  TVirtualListViewData = class
  protected
    FOnUpdateAllView: TNotifyEvent;
  public
    // Возвращает количество элементов
    function GetCount: Integer; virtual; abstract;
    // Возвращает данные для указанного элемента
    procedure GetData(AItem: TListItem); virtual; abstract;
    // Кэширует список элементов в указанном диапазоне
    procedure DataHint(AStartIndex, AEndIndex: Integer); virtual; abstract;
    // Обновляет все TListView
    procedure UpdateAllView; virtual;
  public
    property OnUpdateAllView: TNotifyEvent read FOnUpdateAllView
                                            write FOnUpdateAllView;
  end;

  { TReaderInfoList - Список инфо о считывателях }

  TReaderInfoList = class(TList<TReaderInfo>)
    function IndexOfPort(const APortName: string): Integer;
  end;

  { TTemicPasswordList - Список инфо о паролях Temic }

  TTemicPasswordList = class(TList<TTemicPassword>)
    procedure Assign(Source: TTemicPasswordList);
    // Загружает список паролей из файла
    procedure LoadFromFile(const APath: string);
    // Сохраняет список паролей в файл
    procedure SaveToFile(const APath: string);
    // Ищет позицию пароля в списке
    function IndexOfPassword(APassword: Cardinal): Integer;
  end;

  { TMfClassicKeyList - Список инфо о ключах Mifare Classic }

  TMfClassicKeyList = class(TList<TMcKeyInfo>)
    procedure Assign(Source: TMfClassicKeyList);
    // Загружает список ключей из файла
    procedure LoadFromFile(const APath: string);
    // Сохраняет список ключей в файл
    procedure SaveToFile(const APath: string);
    // Ищет позицию ключа в списке
    function IndexOfKey(const AKey: TMfClassicKey): Integer;
  end;

  { TMfPlusKeyList - Список инфо о ключах Mifare Plus }

  TMfPlusKeyList = class(TList<TMpKeyInfo>)
    procedure Assign(Source: TMfPlusKeyList);
    // Загружает список ключей из файла
    procedure LoadFromFile(const APath: string);
    // Сохраняет список ключей в файл
    procedure SaveToFile(const APath: string);
    // Ищет позицию ключа в списке
    function IndexOfKey(const AKey: TMfPlusKey): Integer;
  end;

implementation

uses
  System.SysUtils,
  IL.RUtils, uUtils;

{ TVirtualListViewData }

procedure TVirtualListViewData.UpdateAllView;
begin
  if Assigned(FOnUpdateAllView) then
    FOnUpdateAllView(Self);
end;

{ TReaderInfoList }

function TReaderInfoList.IndexOfPort(const APortName: string): Integer;
begin
  for Result := 0 to Count - 1 do
    if SameText(Items[Result].szPortName, APortName) then
      Exit;
  Result := -1;
end;

{ TTemicPasswordList }

procedure TTemicPasswordList.Assign(Source: TTemicPasswordList);
begin
  Clear;
  AddRange(Source);
end;

function TTemicPasswordList.IndexOfPassword(APassword: Cardinal): Integer;
begin
  for Result := 0 to Count - 1 do
    if Items[Result].m_nPassword = APassword then
      Exit;
  Result := -1;
end;

procedure TTemicPasswordList.LoadFromFile(const APath: string);
const
  kSeparator = ';';
var
  oSS: TStringStream;
  S, sValue: string;
  psz: PChar;
  fLastCol, fPasswordOk: Boolean;
  rPassword: TTemicPassword;
  N: Int64;
  nFieldIdx: Integer;
begin
  Clear;
  oSS := TStringStream.Create;
  try
    oSS.LoadFromFile(APath);
    S := oSS.DataString;
  finally
    oSS.Free;
  end;
  psz := PChar(S);
  nFieldIdx := 0;
  fPasswordOk := False;
  repeat
    sValue := NextCsvField(psz, fLastCol, kSeparator);
    case nFieldIdx of
      0:
      begin
        fPasswordOk := TryStrToInt64(sValue, N) and (N >= 0) and  (N <= $ffffffff);
        if fPasswordOk then
          rPassword.m_nPassword := Cardinal(N);
      end;
      1:
        rPassword.m_sComment := sValue;
    end;
    if fLastCol then
    begin
      nFieldIdx := 0;
      if fPasswordOk then
        Add(rPassword);
      rPassword.m_nPassword := 0;
      rPassword.m_sComment := string.Empty;
    end
    else
      Inc(nFieldIdx);
  until psz = nil;
end;

procedure TTemicPasswordList.SaveToFile(const APath: string);
const
  kSeparator = ';';
var
  oSS: TStringStream;
  I: Integer;
  S: string;
  pPassword: PTemicPassword;
begin
  oSS := TStringStream.Create;
  try
    S := string.Empty;
    AddCsvField(S, SPassword, kSeparator);
    AddCsvField(S, SComment, kSeparator);
    oSS.WriteString(S + #13#10);
    for I := 0 to Count - 1 do
    begin
      pPassword := @List[I];
      S := string.Empty;
      AddCsvField(S, IntToStr(pPassword.m_nPassword), kSeparator);
      AddCsvField(S, pPassword.m_sComment, kSeparator);
      oSS.WriteString(S + #13#10);
    end;
    oSS.SaveToFile(APath);
  finally
    oSS.Free;
  end;
end;

{ TMfClassicKeyList }

procedure TMfClassicKeyList.Assign(Source: TMfClassicKeyList);
begin
  Clear;
  AddRange(Source);
end;

function TMfClassicKeyList.IndexOfKey(const AKey: TMfClassicKey): Integer;
begin
  for Result := 0 to Count - 1 do
    if Items[Result].m_nKey = AKey then
      Exit;
  Result := -1;
end;

procedure TMfClassicKeyList.LoadFromFile(const APath: string);
const
  kSeparator = ';';
var
  oSS: TStringStream;
  S, sValue: string;
  psz: PChar;
  fLastCol, fKeyOk: Boolean;
  rKI: TMcKeyInfo;
  nFieldIdx: Integer;
begin
  Clear;
  oSS := TStringStream.Create;
  try
    oSS.LoadFromFile(APath);
    S := oSS.DataString;
  finally
    oSS.Free;
  end;
  psz := PChar(S);
  nFieldIdx := 0;
  fKeyOk := False;
  repeat
    sValue := NextCsvField(psz, fLastCol, kSeparator);
    case nFieldIdx of
      0:
        fKeyOk := IL.RUtils.TryStrToMfClassicKey(sValue, rKI.m_nKey);

      1:
        rKI.m_sComment := sValue;
    end;
    if fLastCol then
    begin
      nFieldIdx := 0;
      if fKeyOk then
        Add(rKI);
      rKI.m_nKey := 0;
      rKI.m_sComment := string.Empty;
    end
    else
      Inc(nFieldIdx);
  until psz = nil;
end;

procedure TMfClassicKeyList.SaveToFile(const APath: string);
const
  kSeparator = ';';
var
  oSS: TStringStream;
  I: Integer;
  S: string;
  pKI: PMcKeyInfo;
begin
  oSS := TStringStream.Create;
  try
    S := string.Empty;
    AddCsvField(S, SKey, kSeparator);
    AddCsvField(S, SComment, kSeparator);
    oSS.WriteString(S + #13#10);
    for I := 0 to Count - 1 do
    begin
      pKI := @List[I];
      S := string.Empty;
      AddCsvField(S, IL.RUtils.MfClassicKeyToStr(pKI.m_nKey), kSeparator);
      AddCsvField(S, pKI.m_sComment, kSeparator);
      oSS.WriteString(S + #13#10);
    end;
    oSS.SaveToFile(APath);
  finally
    oSS.Free;
  end;
end;

{ TMfPlusKeyList }

procedure TMfPlusKeyList.Assign(Source: TMfPlusKeyList);
begin
  Clear;
  AddRange(Source);
end;

function TMfPlusKeyList.IndexOfKey(const AKey: TMfPlusKey): Integer;
begin
  for Result := 0 to Count - 1 do
    if Items[Result].m_rKey = AKey then
      Exit;
  Result := -1;
end;

procedure TMfPlusKeyList.LoadFromFile(const APath: string);
const
  kSeparator = ';';
var
  oSS: TStringStream;
  S, sValue: string;
  psz: PChar;
  fLastCol, fKeyOk: Boolean;
  rKI: TMpKeyInfo;
  nFieldIdx: Integer;
begin
  Clear;
  oSS := TStringStream.Create;
  try
    oSS.LoadFromFile(APath);
    S := oSS.DataString;
  finally
    oSS.Free;
  end;
  psz := PChar(S);
  nFieldIdx := 0;
  fKeyOk := False;
  repeat
    sValue := NextCsvField(psz, fLastCol, kSeparator);
    case nFieldIdx of
      0:
        fKeyOk := IL.RUtils.TryStrToMfPlusKey(sValue, rKI.m_rKey);

      1:
        rKI.m_sComment := sValue;
    end;
    if fLastCol then
    begin
      nFieldIdx := 0;
      if fKeyOk then
        Add(rKI);
      FillChar(rKI.m_rKey, SizeOf(rKI.m_rKey), 0);
      rKI.m_sComment := string.Empty;
    end
    else
      Inc(nFieldIdx);
  until psz = nil;
end;

procedure TMfPlusKeyList.SaveToFile(const APath: string);
const
  kSeparator = ';';
var
  oSS: TStringStream;
  I: Integer;
  S: string;
  pKI: PMpKeyInfo;
begin
  oSS := TStringStream.Create;
  try
    S := string.Empty;
    AddCsvField(S, SKey, kSeparator);
    AddCsvField(S, SComment, kSeparator);
    oSS.WriteString(S + #13#10);
    for I := 0 to Count - 1 do
    begin
      pKI := @List[I];
      S := string.Empty;
      AddCsvField(S, IL.RUtils.MfPlusKeyToStr(pKI.m_rKey), kSeparator);
      AddCsvField(S, pKI.m_sComment, kSeparator);
      oSS.WriteString(S + #13#10);
    end;
    oSS.SaveToFile(APath);
  finally
    oSS.Free;
  end;
end;

end.
