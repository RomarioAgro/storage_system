unit uUtils;

interface

uses
  WinApi.Windows,
  System.Types,
  Vcl.StdCtrls,
{$IF CompilerVersion >= 29.0} // For Delphi XE8 and up
  System.JSON,
{$ENDIF}
  Data.DBXJSON, // для JSON
  IL.Readers, uTypes;

type
{$IF CompilerVersion >= 29.0} // For Delphi XE8 and up
  TJSONObject = System.JSON.TJSONObject;
  TJSONArray = System.JSON.TJSONArray;
  TJSONPair = System.JSON.TJSONPair;
  TJsonValue = System.JSON.TJsonValue;
  TJsonNumber = System.JSON.TJsonNumber;
{$ELSE}
  TJSONObject = Data.DBXJSON.TJSONObject;
  TJSONArray = Data.DBXJSON.TJSONArray;
  TJsonValue = Data.DBXJSON.TJsonValue;
  TJsonNumber = Data.DBXJSON.TJsonNumber;
{$ENDIF}

  TJSONObjectHlpr = class helper for TJSONObject
    function AddPair(const Str: string; Val: Boolean): TJSONObject; overload;
    function AddPair(const Str: string; Val: Integer): TJSONObject; overload;
    function AddPair(const Str: string; Val: Cardinal): TJSONObject; overload;
    function AddPair(const Str: string; const Val: Int64): TJSONObject; overload;
    function AddPair(const Str: string; const Val: UInt64): TJSONObject; overload;
    function AddPair(const Str: string; const Val: Double): TJSONObject; overload;
    function AddPair(const Str, AVal: string; AEscape: Boolean): TJSONObject; overload;
    class function EscapeStr(const Str: string): string; static;
  end;

{$IF CompilerVersion <= 26.0} // For Delphi XE5 and down
  TJSONArrayHlpr = class helper for TJSONArray
    function Count: Integer;
    function GetValue(Idx: Integer): TJSONValue; inline;
    property Items[Idx: Integer]: TJSONValue read GetValue;
    function Add(const Element: string; AEscape: Boolean): TJSONArray; overload;
  end;

  TJSONValueHlpr = class helper for TJSONValue
    function TryGetString(var Value: string): Boolean;
    function TryGetInteger(var Value: Integer): Boolean;
    function TryGetCardinal(var Value: Cardinal): Boolean;
    function TryGetInt64(var Value: Int64): Boolean;
    function TryGetUInt64(var Value: UInt64): Boolean;
    function TryGetBoolean(var Value: Boolean): Boolean;
    function TryGetObject(var Value: TJSONObject): Boolean;
    function TryGetArray(var Value: TJSONArray): Boolean;
  end;
{$ENDIF}

// Преобразует значение байта в текст ячейки TStringGrid
function ByteToCellStr(AByte: Byte; AFormat: TCellFormat): string;
// Преобразует текст ячейки TStringGrid в значение байта
function CellStrToByte(const AStr: string; AFormat: TCellFormat): Byte;

// Рисует кнопку-флажок
procedure DrawCheckbox(DC: HDC; R: TRect; State: TCheckBoxState;
    Enabled: Boolean = True; Pressed: Boolean = False; Hot: Boolean = False);

// Извлекает следующее поле из данных CSV файла
function NextCsvField(var P: PChar; var VLastCol: Boolean; ASeparator: Char): string;
// Добавляет поле к строке CSV
procedure AddCsvField(var VRow: string; const ACol, ASep: string);

// Преобразует ключ Mifare Plus в строку
function MfPlusKeyToStr4(const AKey: TMfPlusKey): string;
// Преобразует строку в ключ Mifare Plus
function TryStr4ToMfPlusKey(const AStr: string; out VKey: TMfPlusKey): Boolean;
// Извлекает следующую подстроку в строке, разделённой символом ACh
function TextToChar(const AText: string; ACh: Char; var VPos: Integer): string;

implementation

uses
  System.SysUtils, System.StrUtils, System.Math,
  Vcl.Themes;


{ TJSONObjectHlpr }

function TJSONObjectHlpr.AddPair(const Str: string; Val: Boolean): TJSONObject;
begin
  if Val then
    Result := AddPair(Str, TJSONTrue.Create())
  else
    Result := AddPair(Str, TJSONFalse.Create());
end;

function TJSONObjectHlpr.AddPair(const Str: string; Val: Integer): TJSONObject;
begin
  Result := AddPair(Str, TJSONNumber.Create(Val));
end;

function TJSONObjectHlpr.AddPair(const Str: string; Val: Cardinal): TJSONObject;
begin
  Result := AddPair(Str, TJSONNumber.Create(Int64(Val)));
end;

function TJSONObjectHlpr.AddPair(const Str: string; const Val: Int64): TJSONObject;
begin
  Result := AddPair(Str, TJSONNumber.Create(Val));
end;

function TJSONObjectHlpr.AddPair(const Str: string; const Val: UInt64): TJSONObject;
begin
  Result := AddPair(Str, TJSONNumber.Create(Int64(Val)));
end;

function TJSONObjectHlpr.AddPair(const Str: string; const Val: Double): TJSONObject;
begin
  Result := AddPair(Str, TJSONNumber.Create(Val));
end;

function TJSONObjectHlpr.AddPair(const Str, AVal: string; AEscape: Boolean): TJSONObject;
begin
  if AEscape then
    Result := AddPair(Str, EscapeStr(AVal))
  else
    Result := AddPair(Str, AVal);
end;

class function TJSONObjectHlpr.EscapeStr(const Str: string): string;
var
  I: Integer;
begin
  Result := string.Empty;
  for I := 1 to Length(Str) do
  begin
    case Str[I] of
      '\': Result := Result + '\\';
      #9: Result := Result + '\t';
      #13: Result := Result + '\r';
      #10: Result := Result + '\n';
      else Result := Result + Str[I];
    end;
  end;
end;

{$IF CompilerVersion <= 26.0} // For Delphi XE5 and down
function TJSONArrayHlpr.Count: Integer;
begin
  Result := inherited Size;
end;

function TJSONArrayHlpr.GetValue(Idx: Integer): TJSONValue;
begin
  Result := inherited Get(Idx);
end;

function TJSONArrayHlpr.Add(const Element: string; AEscape: Boolean): TJSONArray;
begin
  if AEscape then
    AddElement(TJSONString.Create(TJSONObject.EscapeStr(Element)))
  else
    AddElement(TJSONString.Create(Element));
  Result := Self;
end;

function TJSONValueHlpr.TryGetString(var Value: string): Boolean;
begin
  Result := (Self <> nil);
  if Result then
    Value := Self.Value;
end;

function TJSONValueHlpr.TryGetInteger(var Value: Integer): Boolean;
begin
  Result := (Self <> nil) and (Self is TJsonNumber);
  if Result then
    Value := TJsonNumber(Self).AsInt;
end;

function TJSONValueHlpr.TryGetCardinal(var Value: Cardinal): Boolean;
begin
  Result := (Self <> nil) and (Self is TJsonNumber);
  if Result then
    Value := Cardinal(TJsonNumber(Self).AsInt64);
end;

function TJSONValueHlpr.TryGetInt64(var Value: Int64): Boolean;
begin
  Result := (Self <> nil) and (Self is TJsonNumber);
  if Result then
    Value := TJsonNumber(Self).AsInt64;
end;

function TJSONValueHlpr.TryGetUInt64(var Value: UInt64): Boolean;
begin
  Result := (Self <> nil) and (Self is TJsonNumber);
  if Result then
    Value := UInt64(TJsonNumber(Self).AsInt64);
end;

function TJSONValueHlpr.TryGetBoolean(var Value: Boolean): Boolean;
begin
  if Self is TJSONTrue then
    Value := True
  else if Self is TJSONFalse then
    Value := False
  else
    Exit(False);
  Result := True;
end;

function TJSONValueHlpr.TryGetObject(var Value: TJSONObject): Boolean;
begin
  Result := (Self <> nil) and (Self is TJSONObject);
  if Result then
    Value := TJSONObject(Self);
end;

function TJSONValueHlpr.TryGetArray(var Value: TJSONArray): Boolean;
begin
  Result := (Self <> nil) and (Self is TJSONArray);
  if Result then
    Value := TJSONArray(Self);
end;
{$ENDIF}

function ByteToCellStr(AByte: Byte; AFormat: TCellFormat): string;
var
  I: Integer;
begin
  case AFormat of
    cfBin:
    begin
      Result := '00000000';
      for I := Length(Result) downto 1 do
      begin
        if (AByte and 1) <> 0 then
          Result[I] := '1';
        AByte := AByte shr 1;
      end;
    end;

    cfDec: Result := format('%.3d', [AByte]);

    cfHex: Result := IntToHex(AByte, 2);

    else
    begin
      Assert(False);
      Result := string.Empty;
    end;
  end;
end;

function CellStrToByte(const AStr: string; AFormat: TCellFormat): Byte;
var
  I: Integer;
  nMask: Cardinal;
begin
  case AFormat of
    cfBin:
    begin
      Result := 0;
      nMask := 1;
      for I := Length(AStr) downto 1 do
      begin
        if AStr[I] = '1' then
          Inc(Result, nMask);
        nMask := nMask shl 1;
      end;
    end;

    cfDec: Result := StrToInt(AStr);

    cfHex: Result := StrToInt('$' + AStr);

    else
    begin
      Assert(False);
      Result := 0;
    end;
  end;
end;

procedure DrawCheckbox(DC: HDC; R: TRect; State: TCheckBoxState;
    Enabled: Boolean {= True}; Pressed: Boolean {= False}; Hot: Boolean {= False});
var
  Styles: TCustomStyleServices;
  Details: TThemedElementDetails;
  nFlags: Cardinal;
  nButtonSt: TThemedButton;
begin
  Styles := StyleServices;
  if Styles.Enabled then
  begin
    case State of
      cbUnchecked:
        if not Enabled then
          nButtonSt := tbCheckBoxUncheckedDisabled
        else if Pressed then
          nButtonSt := tbCheckBoxUncheckedPressed
        else if Hot then
          nButtonSt := tbCheckBoxUncheckedHot
        else
          nButtonSt := tbCheckBoxUncheckedNormal;

      cbChecked:
        if not Enabled then
          nButtonSt := tbCheckBoxCheckedDisabled
        else if Pressed then
          nButtonSt := tbCheckBoxCheckedPressed
        else if Hot then
          nButtonSt := tbCheckBoxCheckedHot
        else
          nButtonSt := tbCheckBoxCheckedNormal;

      else
        if not Enabled then
          nButtonSt := tbCheckBoxMixedDisabled
        else if Pressed then
          nButtonSt := tbCheckBoxMixedPressed
        else if Hot then
          nButtonSt := tbCheckBoxMixedHot
        else
          nButtonSt := tbCheckBoxMixedNormal;
    end;

    Details := Styles.GetElementDetails(nButtonSt);
    // Рисуем флажок
    Styles.DrawElement(DC, Details, R)
  end
  else
  begin
    case State of
      cbUnchecked:
        nFlags := DFCS_BUTTONCHECK;

      cbChecked:
        nFlags := DFCS_BUTTONCHECK or DFCS_CHECKED;

      else
        nFlags := DFCS_BUTTON3STATE or DFCS_CHECKED;
    end;
    if not Enabled then
      nFlags := nFlags or DFCS_INACTIVE
    else if Pressed then
      nFlags := nFlags or DFCS_PUSHED
    else if Hot then
      nFlags := nFlags or DFCS_HOT;
    // Рисуем флажок
    DrawFrameControl(DC, R, DFC_BUTTON, nFlags);
  end;
end;

function NextCsvField(var P: PChar; var VLastCol: Boolean; ASeparator: Char): string;
var
  fQ: Boolean;
  pp: PChar;
begin
  Assert(P <> nil);

  VLastCol := False;
  pp := p;
  fQ := (pp^ = '"');

  if fQ then       // """a""b""c";        // """;";    // "";
  begin            // ftf tf tf t         // ftf t        ft
    Inc(pp);
    while p^ <> #0 do
    begin
      if p^ = '"' then
        fQ := not fQ
      else if p^ =  ASeparator then
      begin
        if fQ then
        begin
          if (p - pp) > 1 then
            (p-1)^ := #0;
          p^ := #0;
          Inc(p);
          break;
        end;
      end;
      Inc(p);
    end;
  end
  else
  begin   // a"b"c
    repeat
      if p^ = ASeparator then
      begin
        p^ := #0;
        Inc(p);
        break;
      end;
      if p^ = #13 then
      begin
        p^ := #0;
        Inc(p);
        if p^ = #10 then
          Inc(p);
        VLastCol := True;
        break;
      end;
      Inc(p);
    until p^ = #0;
  end;
  if p^ = #0 then
  begin
    p := nil;
    VLastCol := True;
  end;
  Result := StrPas(pp);
end;

procedure AddCsvField(var VRow: string; const ACol, ASep: string);
begin
  if (Pos('"', ACol) <> 0) or (Pos(ASep, ACol) <> 0) or (Pos(#13, ACol) <> 0) then
    VRow := VRow + '"' + ReplaceStr(ACol, '"', '""') + '"' + ASep
  else
    VRow := VRow + ACol + ASep;
end;

function MfPlusKeyToStr4(const AKey: TMfPlusKey): string;
begin
  Result := IntToHex(PCardinal(@AKey.a[12])^, 8) + ' ' +
    IntToHex(PCardinal(@AKey.a[8])^, 8) + ' ' +
    IntToHex(PCardinal(@AKey.a[4])^, 8) + ' ' +
    IntToHex(PCardinal(@AKey.a[0])^, 8);
end;

function TryStr4ToMfPlusKey(const AStr: string; out VKey: TMfPlusKey): Boolean;
var
  nPos, nPos2, c: Integer;
  N: Int64;
begin
  Result := False;
  FillChar(VKey.a, SizeOf(VKey.a), 0);

  nPos := Length(AStr) + 1;
  nPos2 := nPos;
  c := 0;        // A1A2A3A4 B1B2B3B4 C1C2C3C4 D1D2D3D4
  repeat         // 12345678901234567890123456789012345
    Dec(nPos, 8);
    if not TryStrToInt64('$' + Copy(AStr, min(nPos, 1), nPos2 - nPos), N) then
      Exit;
    PCardinal(@VKey.a[c])^ := N;
    Inc(c, 4);
    if c = 16 then
      break;
    if (nPos > 1) and (AStr[nPos - 1] = ' ') then
      Dec(nPos);
    nPos2 := nPos;
  until nPos <= 0;
  Result := True;
end;

function TextToChar(const AText: string; ACh: Char; var VPos: Integer): string;
var
  nNextPos: Integer;
begin
  nNextPos := PosEx(ACh, AText, VPos);
  if nNextPos = 0 then
    Result := Copy(AText, VPos, Length(AText) - VPos + 1)
  else
  begin
    Result := Copy(AText, VPos, nNextPos - VPos);
    Inc(nNextPos);
    if nNextPos > Length(AText) then
      nNextPos := 0;
  end;
  VPos := nNextPos;
end;

end.
