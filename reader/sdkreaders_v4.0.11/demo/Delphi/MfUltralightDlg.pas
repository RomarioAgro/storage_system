unit MfUltralightDlg;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Grids,
  IL.Readers, uConst, uTypes;

type
  TfmMfUltralightDlg = class(TForm)
    gridBytes: TStringGrid;
    rgDataFormat: TRadioGroup;
    panLegend: TPanel;
    shLegSN: TShape;
    labLegSN: TLabel;
    shLegConfig: TShape;
    labLegConfig: TLabel;
    shLegData: TShape;
    labLegData: TLabel;
    shLegDataRO: TShape;
    labLegDataRO: TLabel;
    labLegConfigRO: TLabel;
    shLegConfigRO: TShape;
    btnWrite: TButton;
    btnRead: TButton;
    procedure FormShow(Sender: TObject);
    procedure btnReadClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure gridBytesFixedCellClick(Sender: TObject; ACol, ARow: Integer);
    procedure gridBytesSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure gridBytesDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure gridBytesKeyPress(Sender: TObject; var Key: Char);
    procedure rgDataFormatClick(Sender: TObject);
    procedure gridBytesKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure gridBytesDblClick(Sender: TObject);
    procedure gridBytesClick(Sender: TObject);
    procedure btnWriteClick(Sender: TObject);
  private
    { Private declarations }
    m_nCol          : Integer;
    m_nRow          : Integer;
    m_fEditMode     : Boolean;
    m_nCellCharIdx  : Integer;

    // Вкл/выкл режим редактирования ячеек
    procedure EnableEditMode(AEnable: Boolean = True);
    // Перемещает фокус на следующую ячейку, доступную для редактирования
    function NextEditCell: Boolean;
    // Перемещает фокус на предыдущую ячейку, доступную для редактирования
    function PrevEditCell: Boolean;
    function RowToPageIdx(ARow: Integer): Integer; inline;
    function PageIdxToRow(APageIdx: Integer): Integer; inline;
    function ColToByteIdx(ACol: Integer): Integer; inline;
    function ByteIdxToCol(AByteIdx: Integer): Integer; inline;
    function GetCellFormat(ACol, ARow: Integer): TCellFormat;
    procedure UpdateGrid;
    procedure UpdateGridCell(ACol, ARow: Integer);
    function CanCheckPage(APageIdx: Integer): Boolean;
    function IsReadOnlyPage(APageIdx: Integer): Boolean;
    function IsReadOnlyByte(APageIdx, AByteIdx: Integer): Boolean;
    function IsPageChecked(APageIdx: Integer): Boolean;
    procedure SetPageChecked(APageIdx: Integer; AChecked: Boolean = True;
      ARedraw: Boolean = True);
    function IsValidByteValue(APageIdx, AByteIdx: Integer; AValue: Byte): Boolean;
  public
    { Public declarations }
    m_iReader       : IILReader;
    m_aOldPages     : array[0..15, 0..3] of Byte; // Исходные данные карты (16 страниц по 4 байта)
    m_aNewPages     : array[0..15, 0..3] of Byte; // Изменённые данные карты

    // Читает данные из карты
    procedure ReadCardData;
    // Пишет данные в карту
    procedure WriteCardData;
  end;

var
  fmMfUltralightDlg: TfmMfUltralightDlg;

implementation

{$R *.dfm}

uses
  System.UITypes, System.Character,
  IL.RUtils, uAppSettings, uUtils, uAppHelp;


procedure TfmMfUltralightDlg.btnReadClick(Sender: TObject);
begin
  ReadCardData;
end;

procedure TfmMfUltralightDlg.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  HelpContext := HIDD_MFULTRALIGHT;
  m_nCol := -1;
  m_nRow := -1;
  for I := gridBytes.FixedCols to gridBytes.ColCount - 1 do
    gridBytes.Cells[I, 0] := IntToStr(I - 1);
  for I := gridBytes.FixedRows to gridBytes.RowCount - 1 do
    gridBytes.Cells[0, I] := IntToStr(RowToPageIdx(I));
  gridBytes.ColWidths[0] := 60;
  gridBytes.Cells[0, 0] := SPageByte;
end;

procedure TfmMfUltralightDlg.FormShow(Sender: TObject);
var
  rCI: TCardInfo;
begin
  m_iReader.GetCardInfo(rCI);
  if rCI.nType <> cMifareUltralight then
    Close;
  Caption := format(' %s %s', [
        kCardTypeNames[rCI.nType],
        ILRCardUIDToStr(rCI.nType, rCI.rUID)]);
  rgDataFormat.ItemIndex := Integer(g_AppSet.m_nMulDataFormat);
  ReadCardData;
end;

function TfmMfUltralightDlg.GetCellFormat(ACol, ARow: Integer): TCellFormat;
var
  nPageIdx: Integer;
begin
  nPageIdx := RowToPageIdx(ARow);
  if nPageIdx < 2 then
    Result := cfHex
  else if nPageIdx = 2 then
  begin
    if ACol > 2 then
      Result := cfBin
    else
      Result := cfHex;
  end
  else if nPageIdx = 3 then
    Result := cfBin
  else
    Result := g_AppSet.m_nMulDataFormat;
end;

procedure TfmMfUltralightDlg.gridBytesClick(Sender: TObject);
var
  oGrid: TStringGrid;
  pt: TPoint;
  nCol, nRow, dx, nCharIdx: Integer;
  rc: TRect;
  S: string;
  pCanva: TCanvas;
begin
  oGrid := (Sender as TStringGrid);
  pt := oGrid.ScreenToClient(Mouse.CursorPos);
  oGrid.MouseToCell(pt.X, pt.Y, nCol, nRow);
  if (nCol <> -1) and (nRow <> -1) then
  begin
    rc := oGrid.CellRect(nCol, nRow);
    S := oGrid.Cells[nCol, nRow];
    pCanva := oGrid.Canvas;
    pCanva.Font := oGrid.Font;
    dx := pCanva.TextWidth(S) + 2;
    rc.Left := (rc.Left + rc.Right - dx) div 2;
    rc.Right := rc.Left + dx;
    // Рассчитываем позицию каретки для моноширинного шрифта
    nCharIdx := 1 + ((pt.X - rc.Left) * Length(S)) div rc.Width;
    if nCharIdx < 1 then
      nCharIdx := 1
    else if nCharIdx > Length(S) then
      nCharIdx := Length(S);
    if m_nCellCharIdx <> nCharIdx then
    begin
      m_nCellCharIdx := nCharIdx;
      oGrid.Invalidate;
    end;
  end;
end;

procedure TfmMfUltralightDlg.gridBytesDblClick(Sender: TObject);
begin
  EnableEditMode;
end;

procedure TfmMfUltralightDlg.gridBytesDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  oGrid: TStringGrid;
  pCanva: TCanvas;
  rc: TRect;
  I, nPageIdx, nByteIdx, cx, cy, x, y, a, b, k: Integer;
  S: string;
  nCheckState: TCheckBoxState;
  nFlags, nChanges: Cardinal;
begin
  oGrid := (Sender as TStringGrid);
  pCanva := oGrid.Canvas;

  pCanva.Font := oGrid.Font;
  if gdFocused in State then
    pCanva.Pen.Color := clBlack
  else
    pCanva.Pen.Color := clDkGray;
  SetBkMode(Handle, TRANSPARENT);

  nPageIdx := RowToPageIdx(ARow);
  nByteIdx := ColToByteIdx(ACol);

  if (ACol < oGrid.FixedCols) or (ARow < oGrid.FixedRows) then
  begin
    pCanva.Brush.Color := oGrid.FixedColor;
    pCanva.FillRect(Rect);
    S := oGrid.Cells[ACol, ARow];
    if (ACol = 0) and (ARow >= oGrid.FixedRows) then
    begin
      if nPageIdx >= 2 then
      begin
        rc := Rect;
        rc.Top := rc.Top + ((rc.Height - 16) div 2);
        Inc(rc.Left, 4);
        rc.Right := rc.Left + 16;
        rc.Bottom := rc.Top + 16;

        if IsPageChecked(nPageIdx) then
          nCheckState := TCheckBoxState.cbChecked
        else
          nCheckState := TCheckBoxState.cbUnchecked;
        DrawCheckbox(pCanva.Handle, rc, nCheckState, CanCheckPage(nPageIdx));
      end;
      rc := Rect;
      rc.Left := rc.Left + 18;
    end
    else
      rc := Rect;
    pCanva.TextRect(rc, S, [tfSingleLine, tfCenter, tfVerticalCenter]);
  end
  else
  begin
    pCanva.Brush.Color := oGrid.Color;
    case nPageIdx of
      0:
        if nByteIdx <> 3 then
          pCanva.Brush.Color := shLegSN.Brush.Color;

      1:
        pCanva.Brush.Color := shLegSN.Brush.Color;

      2:
        if nByteIdx >= 2 then
        begin
          if IsReadOnlyByte(nPageIdx, nByteIdx) then
            pCanva.Brush.Color := shLegConfigRO.Brush.Color
          else
            pCanva.Brush.Color := shLegConfig.Brush.Color;
        end;

      3:
        if IsReadOnlyPage(nPageIdx) then
          pCanva.Brush.Color := shLegConfigRO.Brush.Color
        else
            pCanva.Brush.Color := shLegConfig.Brush.Color;

      else
        if IsReadOnlyPage(nPageIdx) then
          pCanva.Brush.Color := shLegDataRO.Brush.Color
        else
          pCanva.Brush.Color := shLegData.Brush.Color;
    end;

    // Если ячейка текущая,
    if (ACol = m_nCol) and (ARow = m_nRow) then
    begin
      // рисуем рамку
      pCanva.Pen.Width := 2;
      pCanva.Rectangle(Rect);
    end
    else
      pCanva.FillRect(Rect);

    S := oGrid.Cells[ACol, ARow];
    cx := pCanva.TextWidth(S) + 2;
    cy := pCanva.TextHeight(S) + 2;

    x := (Rect.Left + Rect.Right - cx) div 2;
    y := (Rect.Top + Rect.Bottom - cy) div 2;
    pCanva.TextOut(x, y, S);

    // Если данные в ячейке изменены
    if m_aNewPages[nPageIdx, nByteIdx] <> m_aOldPages[nPageIdx, nByteIdx] then
    begin
      a := m_aOldPages[nPageIdx, nByteIdx];
      b := m_aNewPages[nPageIdx, nByteIdx];
      nChanges := a xor b;
      pCanva.Font.Color := clRed;
      // рисуем краснымм измененные символы
      case GetCellFormat(ACol, ARow) of
        cfBin: // bin
        begin
          nFlags := 1;
          k := -1;
          for I := Length(S) downto 1 do
          begin
            if k = -1 then
            begin
              if (nChanges and nFlags) <> 0 then
                k := I;
            end
            else if (nChanges and nFlags) = 0 then
            begin
              pCanva.TextOut(x + pCanva.TextWidth(Copy(S, 1, I)), y,
                Copy(S, I + 1, k - I));
              k := -1;
            end;
            nFlags := nFlags shl 1;
          end;
          if k <> -1 then
            pCanva.TextOut(x, y, Copy(S, 1, k));
        end;

        cfDec: // dec
        begin
          k := -1;
          for I := Length(s) downto 1 do
          begin
            if k = -1 then
            begin
              if (a mod 10) <> (b mod 10) then
                k := I;
            end
            else if (a mod 10) = (b mod 10) then
            begin
              pCanva.TextOut(x + pCanva.TextWidth(Copy(S, 1, I)), y,
                Copy(S, I + 1, k - I));
              k := -1;
            end;
            a := a div 10;
            b := b div 10;
          end;
          if k <> -1 then
            pCanva.TextOut(x, y, Copy(S, 1, k));
        end;

        else // hex
        begin
          nFlags := $F;
          k := -1;
          for I := Length(S) downto 1 do
          begin
            if k = -1 then
            begin
              if (nChanges and nFlags) <> 0 then
                k := I;
            end
            else if (nChanges and nFlags) = 0 then
            begin
              pCanva.TextOut(x + pCanva.TextWidth(Copy(S, 1, I)), y,
                Copy(S, I + 1, k - I));
              k := -1;
            end;
            nFlags := nFlags shl 4;
          end;
          if k <> -1 then
            pCanva.TextOut(x, y, Copy(S, 1, k));
        end;
      end;
    end;

    // Если (включен режим редактирования) и (ячейка текущая),
    if m_fEditMode and (ACol = m_nCol) and (ARow = m_nRow) and
      (m_nCellCharIdx <> 0) then
    begin
      // рисуем линию под символов редактируемой ячейки
      a := pCanva.TextWidth(Copy(S, 1, m_nCellCharIdx - 1));
      b := pCanva.TextWidth(Copy(S, m_nCellCharIdx, 1));
      rc.Left := (x + a);
      rc.Right := (rc.Left + b);
      rc.Top := (y + cy);
      rc.Bottom := rc.Top;
      pCanva.MoveTo(rc.Left, rc.Top);
      pCanva.LineTo(rc.Right, rc.Bottom);
    end;
  end;
end;

procedure TfmMfUltralightDlg.gridBytesFixedCellClick(Sender: TObject; ACol,
  ARow: Integer);
var
  oGrid: TStringGrid;
  pt: TPoint;
  nCol, nRow, nPageIdx: Integer;
begin
  oGrid := (Sender as TStringGrid);
  GetCursorPos(pt);
  pt := oGrid.ScreenToClient(pt);
  oGrid.MouseToCell(pt.X, pt.Y, nCol, nRow);
  nPageIdx := RowToPageIdx(nRow);
  if (nPageIdx <> -1) and CanCheckPage(nPageIdx) then
    SetPageChecked(nPageIdx, not IsPageChecked(nPageIdx));
end;

procedure TfmMfUltralightDlg.gridBytesKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  oGrid: TStringGrid;
  nPageIdx, nByteIdx: Integer;
  nFormat: TCellFormat;
  sNewValue, sOldValue: string;
begin
  oGrid := (Sender as TStringGrid);
  case Key of
    VK_ESCAPE: // Клавиша ESC
      EnableEditMode(False);

    VK_RETURN: // Клавиша Enter
    begin
      nPageIdx := RowToPageIdx(m_nRow);
      nByteIdx := ColToByteIdx(m_nCol);
      if not IsReadOnlyByte(nPageIdx, nByteIdx) then
        EnableEditMode;
    end;

    VK_LEFT: // Клавиша Left Arrow (стрелка влево)
      if m_fEditMode then
      begin
        Key := 0;
        if m_nCellCharIdx > 1 then
        begin
          Dec(m_nCellCharIdx);
          gridBytes.Invalidate;
        end
        else
          PrevEditCell;
      end;

    VK_RIGHT: // Клавиша Right Arrow (стрелка вправо)
      if m_fEditMode then
      begin
        Key := 0;
        if m_nCellCharIdx < Length(gridBytes.Cells[m_nCol, m_nRow]) then
        begin
          Inc(m_nCellCharIdx);
          gridBytes.Invalidate;
        end
        else
          NextEditCell;
      end;

    VK_BACK: // Клавиша Backspace
      if m_fEditMode then
      begin
        Key := 0;
        // Переходим к предыдущему символу
        if m_nCellCharIdx > 1 then
        begin
          Dec(m_nCellCharIdx);
          gridBytes.Invalidate;
        end
        else
          PrevEditCell;
        nPageIdx := RowToPageIdx(m_nRow);
        nByteIdx := ColToByteIdx(m_nCol);
        if not IsReadOnlyByte(nPageIdx, nByteIdx) then
        begin
          nFormat := GetCellFormat(m_nCol, m_nRow);
          sNewValue := oGrid.Cells[m_nCol, m_nRow];
          sOldValue := ByteToCellStr(m_aOldPages[nPageIdx, nByteIdx], nFormat);
          sNewValue[m_nCellCharIdx] := sOldValue[m_nCellCharIdx];
          m_aNewPages[nPageIdx, nByteIdx] := CellStrToByte(sNewValue, nFormat);
          oGrid.Cells[m_nCol, m_nRow] := sNewValue;
        end;
      end;
  end;
end;

procedure TfmMfUltralightDlg.gridBytesKeyPress(Sender: TObject; var Key: Char);
var
  oGrid: TStringGrid;
  nPageIdx, nByteIdx: Integer;
  S: string;
  nValue: Byte;
begin
  oGrid := (Sender as TStringGrid);
  if not Key.IsControl then
  begin
    nPageIdx := RowToPageIdx(m_nRow);
    nByteIdx := ColToByteIdx(m_nCol);
    if IsReadOnlyByte(nPageIdx, nByteIdx) then
      Exit;
    S := oGrid.Cells[m_nCol, m_nRow];
    case GetCellFormat(m_nCol, m_nRow) of
      cfBin:
      begin
        case Key of
          '0','1':
          begin
            if not m_fEditMode then
              m_nCellCharIdx := 1;
            Assert(m_nCellCharIdx <= Length(s));
            S[m_nCellCharIdx] := Key;
            nValue := CellStrToByte(S, cfBin);
            if not IsValidByteValue(nPageIdx, nByteIdx, nValue) then
              Exit;
            m_aNewPages[nPageIdx, nByteIdx] := nValue;
            oGrid.Cells[m_nCol, m_nRow] := S;
            Inc(m_nCellCharIdx);
            m_fEditMode := True;
            oGrid.Invalidate;
          end;
        end;
        if m_fEditMode and (m_nCellCharIdx > 8) and (not NextEditCell) then
          m_nCellCharIdx := 1;
      end;

      cfDec:
      begin
        case Key of
          '0'..'9':
          begin
            if not m_fEditMode then
              m_nCellCharIdx := 1;
            Assert(m_nCellCharIdx <= Length(S));
            S[m_nCellCharIdx] := UpCase(Key);
            nValue := CellStrToByte(S, cfDec);
            if not IsValidByteValue(nPageIdx, nByteIdx, nValue) then
              Exit;
            m_aNewPages[nPageIdx, nByteIdx] := nValue;
            oGrid.Cells[m_nCol, m_nRow] := S;
            Inc(m_nCellCharIdx);
            m_fEditMode := True;
            oGrid.Invalidate;
          end;
        end;
        if m_fEditMode and (m_nCellCharIdx > 3) and (not NextEditCell) then
          m_nCellCharIdx := 1;
      end;

      cfHex:
      begin
        case Key of
          '0'..'9','a'..'f','A'..'F':
          begin
            if not m_fEditMode then
              m_nCellCharIdx := 1;
            Assert(m_nCellCharIdx <= Length(S));
            S[m_nCellCharIdx] := UpCase(Key);
            nValue := CellStrToByte(S, cfHex);
            if not IsValidByteValue(nPageIdx, nByteIdx, nValue) then
              Exit;
            m_aNewPages[nPageIdx, nByteIdx] := nValue;
            oGrid.Cells[m_nCol, m_nRow] := S;
            Inc(m_nCellCharIdx);
            m_fEditMode := True;
            oGrid.Invalidate;
          end;
        end;
        if m_fEditMode and (m_nCellCharIdx > 2) and (not NextEditCell) then
          m_nCellCharIdx := 1;
      end;
    end;
  end;
end;

procedure TfmMfUltralightDlg.gridBytesSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  if CanSelect and ((m_nCol <> ACol) or (m_nRow <> ARow)) then
  begin
    m_nCol := ACol;
    m_nRow := ARow;
    case GetCellFormat(m_nCol, m_nRow) of
      cfDec: if m_nCellCharIdx > 3 then m_nCellCharIdx := 3;
      cfHex: if m_nCellCharIdx > 2 then m_nCellCharIdx := 2;
    end;
    gridBytes.Invalidate;
  end
end;

function TfmMfUltralightDlg.IsReadOnlyByte(APageIdx, AByteIdx: Integer): Boolean;
var
  nLock: Cardinal;
begin
  nLock := PWord(@m_aOldPages[2, 2])^;
  case APageIdx of
    0,1: // Serial Number
      Result := True;

    2: // Lock0, Lock1
    begin
      case AByteIdx of
        2: Result := (nLock and 7) = 7; // Lock0
        3: Result := ((nLock and 6) = 6) // Lock1
        else Result := True;
      end;
    end;

    3: // OTP
      Result := ((nLock and 8) <> 0); // OTP

    else
      Result := GetBit(nLock, APageIdx); // Data
  end;
end;

function TfmMfUltralightDlg.CanCheckPage(APageIdx: Integer): Boolean;
var
  nLock: Word;
begin
  nLock := PWord(@m_aOldPages[2, 2])^;
  case APageIdx of
    2: // Internal / Lock
      Result := (nLock and 7) <> 7;

    3: // OTP
      Result := not GetBit(nLock, 0);

    4..9: // Data
      Result := not GetBit(nLock, 1);

    10..15: // Data
      Result := not GetBit(nLock, 2);

    else
      Result := False;
  end;
end;

function TfmMfUltralightDlg.IsPageChecked(APageIdx: Integer): Boolean;
var
  nLock: Word;
begin
  nLock := PWord(@m_aNewPages[2, 2])^;
  if APageIdx < 2 then
    Result := True
  else if APageIdx = 2 then
    Result := (nLock and 7) = 7
  else
    Result := GetBit(nLock, APageIdx);
end;

function TfmMfUltralightDlg.IsReadOnlyPage(APageIdx: Integer): Boolean;
var
  nLock: Word;
begin
  nLock := PWord(@m_aOldPages[2, 2])^;
  case APageIdx of
    2: // Internal / Lock
      Result := (nLock and 7) = 7;

    3: // OTP
      Result := GetBit(nLock, 3);

    4..15: // Data
      Result := GetBit(nLock, APageIdx);

    else
      Result := True;
  end;
end;

function TfmMfUltralightDlg.IsValidByteValue(APageIdx, AByteIdx: Integer;
  AValue: Byte): Boolean;
var
  nOldValue, nChanges: Byte;
begin
  nOldValue := m_aOldPages[APageIdx, AByteIdx];
  case APageIdx of
    0, 1: // Serial Number
      if nOldValue <> AValue then
        Exit(False);

    2: // Internal / Lock
      case AByteIdx of
        0, 1:
          if nOldValue <> AValue then
            Exit(False);

        2: // Lock0
        begin
          // если какой-либо бит в Lock-байте был установлен в 1, то он больше
          //  не может быть сброшен
          if (nOldValue and AValue) <> nOldValue then
            Exit(False);
          nChanges := (nOldValue xor AValue);
          // Если (установлен бит BL OPT) и (бит L OTP изменен),
          if GetBit(nOldValue, 0) and ((nChanges and 8) <> 0) then
            Exit(False);
            // Если (установлен бит BL 9-4) и (биты 4..7 изменены)
          if GetBit(nOldValue, 1) and ((nChanges and $F0) <> 0) then
            Exit(False);
        end;

        3: // Lock1
        begin
          // если какой-либо бит в Lock-байте был установлен в 1, то он больше
          //  не может быть сброшен
          if (nOldValue and AValue) <> nOldValue then
            Exit(False);
          nChanges := (nOldValue xor AValue);
            // Если (установлен бит BL 9-4) и (биты 0..1 изменены)
          if GetBit(m_aOldPages[2, 2], 1) and ((nChanges and 3) <> 0) then
            Exit(False);
           // Если (установлен бит BL 15-10) и (биты 2..7 изменены)
          if GetBit(m_aOldPages[2, 2], 2) and ((nChanges and $FC) <> 0) then
            Exit(False);
        end;
      end;

    3: // OTP
    begin
      // Если (OTP область заблокирована) и (значение изменилось),
      if GetBit(m_aOldPages[2, 2], 3) and (nOldValue <> AValue) then
        Exit(False);
      // При установке 1 в каком-либо бите из области OTP, его становится
      //  невозможно сбросить в ноль
      if (nOldValue and AValue) <> nOldValue then
        Exit(False);
    end;

    else // Data
      // Если (страница заблокирована) и (значение изменилось),
      if GetBit(PWord(@m_aNewPages[2, 2])^, APageIdx) and (nOldValue <> AValue) then
        Exit(False);
  end;
  Result := True;
end;

function TfmMfUltralightDlg.NextEditCell: Boolean;
var
  I, nPageIdx, nByteIdx: Integer;
begin
  nPageIdx := RowToPageIdx(m_nRow);
  nByteIdx := ColToByteIdx(m_nCol);
  // Цикл по всем байтам
  for I := 0 to SizeOf(m_aOldPages) - 1 do
  begin
    if nByteIdx < High(m_aOldPages[nPageIdx]) then
      Inc(nByteIdx)
    else
    begin
      if nPageIdx > 0 then
        Dec(nPageIdx)
      else
        nPageIdx := High(m_aOldPages);
      nByteIdx := 0;
    end;
    if not IsReadOnlyByte(nPageIdx, nByteIdx) then
    begin
      gridBytes.Col := ByteIdxToCol(nByteIdx);
      gridBytes.Row := PageIdxToRow(nPageIdx);
      m_nCellCharIdx := 1;
      gridBytes.Invalidate;
      Exit(True);
    end;
  end;
  Result := False;
end;

procedure TfmMfUltralightDlg.ReadCardData;
begin
  try
    m_iReader.ReadMfUlralight(0, PCardinal(@m_aOldPages), Length(m_aOldPages));
  finally
    Move(m_aOldPages, m_aNewPages, SizeOf(m_aNewPages));
    UpdateGrid;
  end;
end;

procedure TfmMfUltralightDlg.rgDataFormatClick(Sender: TObject);
var
  nIdx: Integer;
begin
  nIdx := rgDataFormat.ItemIndex;
  if (nIdx <> -1) and (g_AppSet.m_nMulDataFormat <> TCellFormat(nIdx)) then
  begin
    g_AppSet.SetMulDataFormat(TCellFormat(nIdx));
    m_nCellCharIdx := 1;
    UpdateGrid;
  end;
end;

function TfmMfUltralightDlg.RowToPageIdx(ARow: Integer): Integer;
begin
  Result := (gridBytes.RowCount - 1 - ARow);
end;

function TfmMfUltralightDlg.PageIdxToRow(APageIdx: Integer): Integer;
begin
  Result := (gridBytes.RowCount - 1 - APageIdx);
end;

function TfmMfUltralightDlg.PrevEditCell: Boolean;
var
  I, nPageIdx, nByteIdx: Integer;
begin
  nPageIdx := RowToPageIdx(m_nRow);
  nByteIdx := ColToByteIdx(m_nCol);
  // Цикл по всем байтам
  for I := 0 to SizeOf(m_aOldPages) - 1 do
  begin
    if nByteIdx > 0 then
      Dec(nByteIdx)
    else
    begin
      nPageIdx := (nPageIdx + 1) mod Length(m_aOldPages);
      nByteIdx := 3;
    end;
    if not IsReadOnlyByte(nPageIdx, nByteIdx) then
    begin
      gridBytes.Col := ByteIdxToCol(nByteIdx);
      gridBytes.Row := PageIdxToRow(nPageIdx);
      case GetCellFormat(m_nCol, m_nRow) of
        cfBin: m_nCellCharIdx := 8;
        cfDec: m_nCellCharIdx := 3;
        else m_nCellCharIdx := 2;
      end;
      gridBytes.Invalidate;
      Exit(True);
    end;
  end;
  Result := False;
end;

function TfmMfUltralightDlg.ColToByteIdx(ACol: Integer): Integer;
begin
  Result := (ACol - gridBytes.FixedCols);
end;

procedure TfmMfUltralightDlg.EnableEditMode(AEnable: Boolean);
begin
  if m_fEditMode = AEnable then
    Exit;
  m_fEditMode := AEnable;
  if AEnable then
    m_nCellCharIdx := 1;
  gridBytes.Invalidate;
end;

procedure TfmMfUltralightDlg.btnWriteClick(Sender: TObject);
begin
  WriteCardData;
end;

function TfmMfUltralightDlg.ByteIdxToCol(AByteIdx: Integer): Integer;
begin
  Result := (gridBytes.FixedCols + AByteIdx);
end;

procedure TfmMfUltralightDlg.SetPageChecked(APageIdx: Integer; AChecked,
  ARedraw: Boolean);
begin
  if APageIdx = 2 then
  begin
    if AChecked then
      m_aNewPages[2, 2] := m_aNewPages[2, 2] or 7
    else
      m_aNewPages[2, 2] := (m_aNewPages[2, 2] and not 7) or (m_aOldPages[2, 2] and 7);
  end
  else if APageIdx > 2 then
    SetBit(PCardinal(@m_aNewPages[2, 2])^, APageIdx, AChecked);
  UpdateGridCell(ByteIdxToCol(2), PageIdxToRow(2));
  UpdateGridCell(ByteIdxToCol(3), PageIdxToRow(2));
  if ARedraw then
    gridBytes.Invalidate;
end;

procedure TfmMfUltralightDlg.UpdateGrid;
var
  nPageIdx, nByteIdx, nCol, nRow: Integer;
  nByte: Byte;
begin
  for nPageIdx := 0 to High(m_aNewPages) do
  begin
    nCol := gridBytes.FixedCols;
    nRow := PageIdxToRow(nPageIdx);
    for nByteIdx := 0 to High(m_aNewPages[nPageIdx]) do
    begin
      nByte := m_aNewPages[nPageIdx, nByteIdx];
      gridBytes.Cells[nCol, nRow] := ByteToCellStr(nByte, GetCellFormat(nCol, nRow));
      Inc(nCol);
    end;
  end;
  gridBytes.Invalidate;
end;

procedure TfmMfUltralightDlg.UpdateGridCell(ACol, ARow: Integer);
var
  nByte: Integer;
begin
  nByte := m_aNewPages[RowToPageIdx(ARow), ColToByteIdx(ACol)];
  gridBytes.Cells[ACol, ARow] := ByteToCellStr(nByte, GetCellFormat(ACol, ARow));
end;

procedure TfmMfUltralightDlg.WriteCardData;
var
  I: Integer;
begin
  try
    for I := 0 to High(m_aNewPages) do
    begin
      if CompareMem(@m_aNewPages[I], @m_aOldPages[I], 4) then
        continue;
      m_iReader.WriteMfUlralight(I, PCardinal(@m_aNewPages[I]), 1);
      Move(m_aNewPages[I], m_aOldPages[I], 4);
    end;
  finally
    gridBytes.Invalidate;
  end;
end;

end.
