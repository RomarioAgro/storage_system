unit TemicDlg;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Grids, Vcl.Mask, Vcl.Samples.Spin, Vcl.ComCtrls,
  IL.Readers, uTypes, uConst;

type
  TfmTemicDlg = class(TForm)
    gridBytes: TStringGrid;
    rgDataFormat: TRadioGroup;
    panLegend: TPanel;
    shLegSn: TShape;
    labLegSn: TLabel;
    shLegPassw: TShape;
    labLegPassw: TLabel;
    shLegData: TShape;
    labLegData: TLabel;
    shLegConfig: TShape;
    labLegConfig: TLabel;
    grPassword: TGroupBox;
    chkPassword: TCheckBox;
    cbPassword: TComboBox;
    btnPswList: TButton;
    btnWrite: TButton;
    btnRead: TButton;
    grConfig: TGroupBox;
    labMode: TLabel;
    cbMode: TComboBox;
    labDataRate: TLabel;
    cbDataBitRate: TComboBox;
    labModulation: TLabel;
    cbModulation: TComboBox;
    labPSK_CF: TLabel;
    cbPSK_CF: TComboBox;
    labMaxBlock: TLabel;
    cbMaxBlock: TComboBox;
    chkAOR: TCheckBox;
    chkOTP: TCheckBox;
    chkST_seq_ter: TCheckBox;
    chkSST_seq_sm: TCheckBox;
    chkFastWrite: TCheckBox;
    chkInverseData: TCheckBox;
    chkPOR_delay: TCheckBox;
    grEmulation: TGroupBox;
    chkTestMode: TCheckBox;
    labEmulated: TLabel;
    grEmuNew: TGroupBox;
    pcCreateCard: TPageControl;
    TabSheet1: TTabSheet;
    labEmNumber: TLabel;
    labEmGroup: TLabel;
    labEmFacility: TLabel;
    edtEmNumber: TSpinEdit;
    edtEmGroup: TSpinEdit;
    edtEmFacility: TMaskEdit;
    TabSheet2: TTabSheet;
    labHidWiegand: TLabel;
    labHidFacility: TLabel;
    labHidNumber: TLabel;
    edtHidWiegand: TSpinEdit;
    rgHidFormat: TRadioGroup;
    edtHidNumber: TSpinEdit;
    edtHidFacility2: TSpinEdit;
    edtHidFacility: TMaskEdit;
    rgCardType: TRadioGroup;
    btnEmuGet: TButton;
    btnEmuApply: TButton;
    edtEmulated: TEdit;
    procedure FormShow(Sender: TObject);
    procedure rgDataFormatClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnWriteClick(Sender: TObject);
    procedure btnReadClick(Sender: TObject);
    procedure gridBytesSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure gridBytesFixedCellClick(Sender: TObject; ACol, ARow: Integer);
    procedure gridBytesKeyPress(Sender: TObject; var Key: Char);
    procedure gridBytesDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure btnPswListClick(Sender: TObject);
    procedure chkPasswordClick(Sender: TObject);
    procedure gridBytesKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure gridBytesDblClick(Sender: TObject);
    procedure gridBytesClick(Sender: TObject);
    procedure cbModeChange(Sender: TObject);
    procedure cbDataBitRateChange(Sender: TObject);
    procedure cbModulationChange(Sender: TObject);
    procedure cbPSK_CFChange(Sender: TObject);
    procedure cbMaxBlockChange(Sender: TObject);
    procedure chkTestModeClick(Sender: TObject);
    procedure chkAORClick(Sender: TObject);
    procedure chkST_seq_terClick(Sender: TObject);
    procedure chkSST_seq_smClick(Sender: TObject);
    procedure chkPOR_delayClick(Sender: TObject);
    procedure chkOTPClick(Sender: TObject);
    procedure chkFastWriteClick(Sender: TObject);
    procedure chkInverseDataClick(Sender: TObject);
    procedure btnEmuGetClick(Sender: TObject);
    procedure rgCardTypeClick(Sender: TObject);
    procedure rgHidFormatClick(Sender: TObject);
    procedure edtHidWiegandChange(Sender: TObject);
    procedure edtEmFacilityChange(Sender: TObject);
    procedure edtEmGroupChange(Sender: TObject);
    procedure edtEmNumberChange(Sender: TObject);
    procedure edtHidFacility2Change(Sender: TObject);
    procedure edtHidFacilityChange(Sender: TObject);
    procedure edtHidNumberChange(Sender: TObject);
    procedure btnEmuApplyClick(Sender: TObject);
    procedure cbPasswordSelect(Sender: TObject);
  private
    { Private declarations }
    m_rTemicUId     : TCardUID;
    m_nCol          : Integer;
    m_nRow          : Integer;
    m_fEditMode     : Boolean;
    m_nCellCharIdx  : Integer;
    m_nEmuCardType  : TCardType;
    m_rEmMarineUId  : TCardUId;
    m_rHidUId       : TCardUId;
    m_nHidWiegand   : Integer;

    procedure UpdateGrid;
    procedure UpdateGridCell(ACol, ARow: Integer);
    procedure UpdateGridRow(ARow: Integer);
    function GetCellFormat(ACol, ARow: Integer): TCellFormat;
    // Вкл/выкл режим редактирования ячеек
    procedure EnableEditMode(AEnable: Boolean = True);
    // Перемещает фокус на следующую ячейку, доступную для редактирования
    function NextEditCell: Boolean;
    // Перемещает фокус на предыдущую ячейку, доступную для редактирования
    function PrevEditCell: Boolean;
    function RowToBlockIdx(ARow: Integer): Integer; inline;
    function BlockIdxToRow(ABlockIdx: Integer): Integer; inline;
    function ColToByteIdx(ACol: Integer): Integer; inline;
    function ByteIdxToCol(AByteIdx: Integer): Integer; inline;
    function IsBlockChecked(ABlockIdx: Integer): Boolean; inline;
    procedure SetBlockChecked(ABlockIdx: Integer; AChecked: Boolean = True;
      ARedraw: Boolean = True);
    function IsReadOnlyByte(ABlockIdx, AByteIdx: Integer): Boolean; inline;
    function IsValidByteValue(ABlockIdx, AByteIdx: Integer; AValue: Byte): Boolean;
    procedure SetByte(ABlockIdx, AByteIdx: Integer; AValue: Byte;
      AUpdateGrid: Boolean = True);
    procedure UpdatePasswordCombobox;
    procedure UpdatePasswordGroupCtrlState;
    procedure UpdateConfigGroupData(ASave: Boolean);
    procedure UpdateEmulatedLabel;
    procedure UpdateEmMarine;
    procedure UpdateHID;
    procedure SetSpinEditValue(AEdit: TSpinEdit; Value: Integer);
    procedure SetMaskEditValue(AEdit: TMaskEdit; Const Value: String);
  public
    { Public declarations }
    m_iReader       : IILReader;
    m_aOldBlocks    : array[0..9, 0..3] of Byte;  // Исходные данные карты (10 страниц по 4 байта)
    m_aNewBlocks    : array[0..9, 0..3] of Byte;  // Изменённые данные карты
    m_nLocks        : Cardinal; // Биты блокируемых блоков
    m_nCurrPassword : Int64;
    m_fPasswListChange: Boolean; // True, список паролей изменился

    // Читает данные из карты
    procedure ReadCardData;
    // Пишет данные в карту
    procedure WriteCardData;
    // Открывает окно для редактирования списка паролей
    function DoEditPasswords: Boolean;
  end;

var
  fmTemicDlg: TfmTemicDlg;

implementation

{$R *.dfm}

uses
  System.UITypes, System.Character, System.StrUtils, System.Math,
  IL.RUtils, uAppSettings, uUtils, uAppHelp,
  TemicPasswordsDlg, ProgressDlg;

const
  ke5550BitRates: array[0..7] of Cardinal = (
    8, 16, 32, 40, 50, 64, 100, 128
  );

function Finde5550BitRateCode(ABitRate: Cardinal): Integer;
begin
  for Result := 0 to High(ke5550BitRates) do
    if ke5550BitRates[Result] = ABitRate then
      Exit;
  Result := -1;
end;

function TfmTemicDlg.BlockIdxToRow(ABlockIdx: Integer): Integer;
begin
  Result := (gridBytes.RowCount - 1 - ABlockIdx);
end;

procedure TfmTemicDlg.btnEmuApplyClick(Sender: TObject);
begin
  case rgCardType.ItemIndex of
    0: // Em-Marine
    begin
      m_iReader.EncodeTemicEmMarine(m_rEmMarineUId, PCardinal(@m_aNewBlocks[0]), 3);
      UpdateGrid;
      UpdateConfigGroupData(False);
    end;

    1: // HID
    begin
      m_iReader.EncodeTemicHID(m_rHidUId, PCardinal(@m_aNewBlocks[0]), 4, m_nHidWiegand);
      UpdateGrid;
      UpdateConfigGroupData(False);
    end;
  end;
end;

procedure TfmTemicDlg.btnEmuGetClick(Sender: TObject);
var
  rUId: TCardUId;
  nWiegand: Integer;
  fConfigOk: Boolean;
  nCardType: TCardType;
begin
  rUId.Clear;
  m_iReader.DecodeTemicEmMarine(PCardinal(@m_aNewBlocks[0]), 3, rUId, fConfigOk);
  if rUId.IsEmpty then
  begin
    m_iReader.DecodeTemicHID(PCardinal(@m_aNewBlocks[0]), 4, rUId, nWiegand, fConfigOk);
    nCardType := cHID;
  end
  else
    nCardType := cEmMarine;
  if rUId.IsEmpty then
    MessageDlg(SNoEmulatedCard, mtWarning, [mbOk], 0)
  else
  begin
    m_nEmuCardType := nCardType;
    if nCardType = cEmMarine then
    begin
      m_rEmMarineUId := rUId;
      UpdateEmMarine;
      rgCardType.ItemIndex := 0;
      pcCreateCard.ActivePageIndex := 0;
    end
    else
    begin
      m_rHidUId := rUId;
      m_nHidWiegand := nWiegand;
      UpdateHID;
      rgCardType.ItemIndex := 1;
      pcCreateCard.ActivePageIndex := 1;
    end;
  end;
end;

procedure TfmTemicDlg.btnPswListClick(Sender: TObject);
begin
  DoEditPasswords;
end;

procedure TfmTemicDlg.btnReadClick(Sender: TObject);
begin
  ReadCardData;
end;

procedure TfmTemicDlg.btnWriteClick(Sender: TObject);
begin
  WriteCardData;
end;

function TfmTemicDlg.ByteIdxToCol(AByteIdx: Integer): Integer;
begin
  Result := (gridBytes.FixedCols + AByteIdx);
end;

procedure TfmTemicDlg.cbDataBitRateChange(Sender: TObject);
var
  nConfig, nMasterKey, nBitRate: Cardinal;
  nIdx: Integer;
  fXMode: Boolean;
begin
  if sscanf(cbDataBitRate.Text, 'RF/%d', [@nBitRate]) <> 1 then
    Exit;
  nConfig := PCardinal(@m_aNewBlocks[0])^;
  nMasterKey := (nConfig shr 4) and $f;
  fXMode := GetBit(nConfig, 9) and (nMasterKey in [6, 9]);
  if fXMode then
    nConfig := (nConfig and not $FC00) or (((nBitRate - 2) div 2) shl 10)
  else
  begin
    nIdx := Finde5550BitRateCode(nBitRate);
    if nIdx = -1 then
      Exit;
    nConfig := (nConfig and not $1C00) or (Cardinal(nIdx) shl 10);
  end;
  if PCardinal(@m_aNewBlocks[0])^ <> nConfig then
  begin
    PCardinal(@m_aNewBlocks[0])^ := nConfig;
    UpdateGridCell(ByteIdxToCol(1), BlockIdxToRow(0));
  end;
end;

procedure TfmTemicDlg.cbMaxBlockChange(Sender: TObject);
var
  nConfig: Cardinal;
  nIdx: Integer;
begin
  nIdx := cbMaxBlock.ItemIndex;
  if nIdx <> -1 then
    Exit;
  nConfig := PCardinal(@m_aNewBlocks[0])^;
  nConfig := (nConfig and not $E0000000) or (Cardinal(nIdx) shl 29);
  if PCardinal(@m_aNewBlocks[0])^ <> nConfig then
  begin
    PCardinal(@m_aNewBlocks[0])^ := nConfig;
    UpdateGridCell(ByteIdxToCol(3), BlockIdxToRow(0));
  end;
end;

procedure TfmTemicDlg.cbModeChange(Sender: TObject);
begin
  UpdateConfigGroupData(True);
  UpdateGridRow(BlockIdxToRow(0));
end;

procedure TfmTemicDlg.cbModulationChange(Sender: TObject);
var
  nConfig, nModulation: Cardinal;
  nIdx: Integer;
begin
  nIdx := cbModulation.ItemIndex;
  if nIdx = -1 then
    Exit;
  nConfig := PCardinal(@m_aNewBlocks[0])^;
  case nIdx of
    0..8: nModulation := nIdx;
    9: nModulation := $10;
    10: nModulation := $18;
    else begin Assert(False); nModulation := 0 end;
  end;
  nConfig := (nConfig and not $F00100) or ((nModulation and $F) shl 20) or
    ((nModulation shr 4) shl 8);
  if PCardinal(@m_aNewBlocks[0])^ <> nConfig then
  begin
    PCardinal(@m_aNewBlocks[0])^ := nConfig;
    UpdateGridRow(BlockIdxToRow(0));
  end;
end;

procedure TfmTemicDlg.cbPasswordSelect(Sender: TObject);
var
  nIdx: Integer;
  nNewPassword: Cardinal;
  pPassword: PCardinal;
begin
  nIdx := cbPassword.ItemIndex;
  if (nIdx = -1) or (not chkPassword.Checked) then
    Exit;
  nNewPassword := g_AppSet.m_oTmcPasswords[nIdx].m_nPassword;
  pPassword := PCardinal(@m_aNewBlocks[7, 0]);
  if pPassword^ <> nNewPassword then
  begin
    pPassword^ := nNewPassword;
    UpdateGridRow(BlockIdxToRow(7));
  end;
end;

procedure TfmTemicDlg.cbPSK_CFChange(Sender: TObject);
var
  nConfig: Cardinal;
  nIdx: Integer;
begin
  nIdx := cbPSK_CF.ItemIndex;
  if nIdx = -1 then
    Exit;
  nConfig := PCardinal(@m_aNewBlocks[0])^;
  nConfig := (nConfig and not $C0000) or (Cardinal(nIdx) shl 18);
  if PCardinal(@m_aNewBlocks[0])^ <> nConfig then
  begin
    PCardinal(@m_aNewBlocks[0])^ := nConfig;
    UpdateGridCell(ByteIdxToCol(2), BlockIdxToRow(0));
  end;
end;

procedure TfmTemicDlg.chkAORClick(Sender: TObject);
var
  nConfig: Cardinal;
begin
  nConfig := PCardinal(@m_aNewBlocks[0])^;
  SetBit(nConfig, 17, chkAOR.Checked);
  if PCardinal(@m_aNewBlocks[0])^ <> nConfig then
  begin
    PCardinal(@m_aNewBlocks[0])^ := nConfig;
    UpdateGridCell(ByteIdxToCol(2), BlockIdxToRow(0));
  end;
end;

procedure TfmTemicDlg.chkFastWriteClick(Sender: TObject);
var
  nConfig, nMasterKey: Cardinal;
  fXMode: Boolean;
begin
  nConfig := PCardinal(@m_aNewBlocks[0])^;
  nMasterKey := (nConfig shr 4) and $f;
  fXMode := GetBit(nConfig, 9) and (nMasterKey in [6, 9]);
  SetBit(nConfig, 26, fXMode and chkFastWrite.Checked);
  if PCardinal(@m_aNewBlocks[0])^ <> nConfig then
  begin
    PCardinal(@m_aNewBlocks[0])^ := nConfig;
    UpdateGridCell(ByteIdxToCol(2), BlockIdxToRow(0));
  end;
end;

procedure TfmTemicDlg.chkInverseDataClick(Sender: TObject);
var
  nConfig, nMasterKey: Cardinal;
  fXMode: Boolean;
begin
  nConfig := PCardinal(@m_aNewBlocks[0])^;
  nMasterKey := (nConfig shr 4) and $f;
  fXMode := GetBit(nConfig, 9) and (nMasterKey in [6, 9]);
  SetBit(nConfig, 25, fXMode and chkInverseData.Checked);
  if PCardinal(@m_aNewBlocks[0])^ <> nConfig then
  begin
    PCardinal(@m_aNewBlocks[0])^ := nConfig;
    UpdateGridCell(ByteIdxToCol(2), BlockIdxToRow(0));
  end;
end;

procedure TfmTemicDlg.chkOTPClick(Sender: TObject);
var
  nConfig, nMasterKey: Cardinal;
  fXMode: Boolean;
begin
  nConfig := PCardinal(@m_aNewBlocks[0])^;
  nMasterKey := (nConfig shr 4) and $f;
  fXMode := GetBit(nConfig, 9) and (nMasterKey in [6, 9]);
  SetBit(nConfig, 16, fXMode and chkOTP.Checked);
  if PCardinal(@m_aNewBlocks[0])^ <> nConfig then
  begin
    PCardinal(@m_aNewBlocks[0])^ := nConfig;
    UpdateGridCell(ByteIdxToCol(2), BlockIdxToRow(0));
  end;
end;

procedure TfmTemicDlg.chkPasswordClick(Sender: TObject);
var
  fSetPassword: Boolean;
  nByte: Byte;
  nIdx: Integer;
  rPassword: TTemicPassword;
begin
  fSetPassword := chkPassword.Checked;
  nByte := m_aNewBlocks[0, 3];
  if fSetPassword = ((nByte and $10) <> 0) then
    Exit; // Нет изменений

  if fSetPassword then
//    nByte := nByte or $10
  else
    nByte := nByte and not $10;
  SetByte(0, 3, nByte);
  if fSetPassword then
  begin
    rPassword.m_nPassword := PCardinal(@m_aNewBlocks[7])^;
    nIdx := g_AppSet.m_oTmcPasswords.IndexOfPassword(rPassword.m_nPassword);
    if nIdx = -1 then
    begin
      rPassword.m_sComment := kCardTypeNames[cTemic] + ' ' +
        ILRCardUIDToStr(cTemic, m_rTemicUId);
      nIdx := g_AppSet.m_oTmcPasswords.Add(rPassword);
      m_fPasswListChange := True;
      UpdatePasswordCombobox;
    end;
    cbPassword.ItemIndex := nIdx;
  end;
  UpdateGridRow(BlockIdxToRow(7));
  UpdatePasswordGroupCtrlState;
end;

procedure TfmTemicDlg.chkPOR_delayClick(Sender: TObject);
var
  nConfig: Cardinal;
begin
  nConfig := PCardinal(@m_aNewBlocks[0])^;
  SetBit(nConfig, 17, chkPOR_delay.Checked);
  if PCardinal(@m_aNewBlocks[0])^ <> nConfig then
  begin
    PCardinal(@m_aNewBlocks[0])^ := nConfig;
    UpdateGridCell(ByteIdxToCol(0), BlockIdxToRow(0));
  end;
end;

procedure TfmTemicDlg.chkSST_seq_smClick(Sender: TObject);
var
  nConfig: Cardinal;
begin
  nConfig := PCardinal(@m_aNewBlocks[0])^;
  SetBit(nConfig, 27, chkSST_seq_sm.Checked);
  if PCardinal(@m_aNewBlocks[0])^ <> nConfig then
  begin
    PCardinal(@m_aNewBlocks[0])^ := nConfig;
    UpdateGridCell(ByteIdxToCol(0), BlockIdxToRow(0));
  end;
end;

procedure TfmTemicDlg.chkST_seq_terClick(Sender: TObject);
var
  nConfig: Cardinal;
begin
  nConfig := PCardinal(@m_aNewBlocks[0])^;
  SetBit(nConfig, 27, chkST_seq_ter.Checked);
  if PCardinal(@m_aNewBlocks[0])^ <> nConfig then
  begin
    PCardinal(@m_aNewBlocks[0])^ := nConfig;
    UpdateGridCell(ByteIdxToCol(0), BlockIdxToRow(0));
  end;
end;

procedure TfmTemicDlg.chkTestModeClick(Sender: TObject);
var
  nConfig, nMasterKey: Cardinal;
  fXMode: Boolean;
begin
  nConfig := PCardinal(@m_aNewBlocks[0])^;
  nMasterKey := (nConfig shr 4) and $f;
  fXMode := GetBit(nConfig, 9) and (nMasterKey in [6, 9]);
  if fXMode then
  begin
    if chkTestMode.Checked then
      nConfig := (nConfig and not $F) or 9
    else
      nConfig := (nConfig and not $F) or 6;
  end
  else
  begin
    if chkTestMode.Checked then
      nConfig := (nConfig and not $F) or 6
    else
      nConfig := (nConfig and not $F) or 9;
  end;
  if PCardinal(@m_aNewBlocks[0])^ <> nConfig then
  begin
    PCardinal(@m_aNewBlocks[0])^ := nConfig;
    UpdateGridCell(ByteIdxToCol(0), BlockIdxToRow(0));
  end;
end;

function TfmTemicDlg.ColToByteIdx(ACol: Integer): Integer;
begin
  Result := (ACol - gridBytes.FixedCols);
end;

function TfmTemicDlg.DoEditPasswords: Boolean;
var
  oDlg: TfmTemicPasswordsDlg;
  nPasswordIdx: Integer;
  nNewPassword: Cardinal;
  pPassword: PCardinal;
begin
  oDlg := TfmTemicPasswordsDlg.Create(Self);
  try
    oDlg.PopupParent := Self;
    if oDlg.ShowModal <> mrOk then
      Exit(False);
    nPasswordIdx := oDlg.m_nPasswordIdx;
  finally
    oDlg.Free;
  end;
  if chkPassword.Checked and (nPasswordIdx <> -1) and
    (nPasswordIdx < g_AppSet.m_oTmcPasswords.Count) then
  begin
    nNewPassword := g_AppSet.m_oTmcPasswords[nPasswordIdx].m_nPassword;
    pPassword := PCardinal(@m_aNewBlocks[7, 0]);
    if pPassword^ <> nNewPassword then
    begin
      pPassword^ := nNewPassword;
      UpdateGridRow(BlockIdxToRow(7));
    end;
  end;
  UpdatePasswordCombobox;
  Result := True;
end;

procedure TfmTemicDlg.edtEmFacilityChange(Sender: TObject);
var
  N: Integer;
begin
  if not TryStrToInt('$' + edtEmFacility.Text, N) then
    Exit;
  m_rEmMarineUId.nLength := 5;
  PWord(@m_rEmMarineUId.aBytes[3])^ := Word(N);
end;

procedure TfmTemicDlg.edtEmGroupChange(Sender: TObject);
var
  N: Integer;
begin
  if not TryStrToInt(edtEmGroup.Text, N) then
    Exit;
  m_rEmMarineUId.nLength := 5;
  m_rEmMarineUId.aBytes[2] := N;
end;

procedure TfmTemicDlg.edtEmNumberChange(Sender: TObject);
var
  N: Integer;
begin
  if not TryStrToInt(edtEmNumber.Text, N) then
    Exit;
  m_rEmMarineUId.nLength := 5;
  PWord(@m_rEmMarineUId.aBytes[0])^ := Word(N);
end;

procedure TfmTemicDlg.edtHidFacility2Change(Sender: TObject);
var
  N, nMask, k: Int64;
begin
  if not TryStrToInt64(edtHidFacility2.Text, N) then
    exit;
  nMask := $8000000000000000;
  k := 63;
  repeat
    if (N and nMask) <> 0 then
      break;
    nMask := nMask shr 1;
    Dec(k);
  until nMask = 0;
  k := k div 8 + 1;
  m_rHidUId.nLength := max(m_rHidUId.nLength, 2 + k);
  Move(N, m_rHidUId.aBytes[2], k);
  UpdateHid;
end;

procedure TfmTemicDlg.edtHidFacilityChange(Sender: TObject);
var
  S: string;
  I, n, nVal: Integer;
begin
  S := edtHidFacility.Text;
  m_rHidUId.nLength := min(2 + (Length(S) div 2), Length(m_rHidUId.aBytes));
  n := Length(S) - 1;
  for I := 2 to m_rHidUId.nLength - 1 do
  begin
    if not TryStrToInt('$' + S[n] + S[n + 1], nVal) then
      Exit;
    m_rHidUId.aBytes[I] := nVal;
    Dec(n, 2);
  end;
  UpdateHid;
end;

procedure TfmTemicDlg.edtHidNumberChange(Sender: TObject);
var
  N: Integer;
begin
  N := edtHidNumber.Value;
  m_rHidUId.nLength := max(m_rHidUId.nLength, 2);
  PWord(@m_rHidUId.aBytes[0])^ := N;
end;

procedure TfmTemicDlg.edtHidWiegandChange(Sender: TObject);
begin
  m_nHidWiegand := edtHidWiegand.Value;
  UpdateHid;
end;

procedure TfmTemicDlg.EnableEditMode(AEnable: Boolean);
begin
  if m_fEditMode = AEnable then
    Exit;
  m_fEditMode := AEnable;
  if AEnable then
    m_nCellCharIdx := 1;
  gridBytes.Invalidate;
end;

procedure TfmTemicDlg.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  HelpContext := HIDD_TEMIC;
  m_nCol := -1;
  m_nRow := -1;
  m_nCellCharIdx := -1;
  m_nCurrPassword := -1;
  m_nHidWiegand := 26;

  for I := gridBytes.FixedCols to gridBytes.ColCount - 1 do
    gridBytes.Cells[I, 0] := IntToStr(I - 1);
  for I := gridBytes.FixedRows to gridBytes.FixedRows + 1 do
    gridBytes.Cells[0, I] := format('1-%d', [gridBytes.FixedRows + 2 - i]);
  for I := gridBytes.FixedRows + 2 to gridBytes.RowCount - 1 do
    gridBytes.Cells[0, I] := format('0-%d', [gridBytes.FixedRows + 9 - i]);
  gridBytes.ColWidths[0] := 130;
  gridBytes.Cells[0, 0] := StrLockPgBlockByte;

  chkSST_seq_sm.Left := chkST_seq_ter.Left;

  for I := 0 to pcCreateCard.PageCount - 1 do
    pcCreateCard.Pages[I].TabVisible := False;
  pcCreateCard.ActivePageIndex := 0;
  rgCardType.ItemIndex := 0;
  edtHidFacility.Left := edtHidFacility2.Left;
end;

procedure TfmTemicDlg.FormShow(Sender: TObject);
var
  rCI: TCardInfo;
begin
  m_iReader.GetCardInfo(rCI);
  if rCI.nType <> cTemic then
    Close;
  m_rTemicUId := rCI.rUID;
  Caption := format(' %s %s', [
        kCardTypeNames[rCI.nType],
        ILRCardUIDToStr(rCI.nType, rCI.rUID)]);
  rgDataFormat.ItemIndex := Integer(g_AppSet.m_nTmcDataFormat);
  rgHidFormat.ItemIndex := Integer(g_AppSet.m_nHidFormat);
  UpdatePasswordCombobox;
  UpdatePasswordGroupCtrlState;
  ReadCardData;
end;

function TfmTemicDlg.GetCellFormat(ACol, ARow: Integer): TCellFormat;
begin
  if ARow < 3 then
    Result := cfHex
  else
    Result := g_AppSet.m_nTmcDataFormat;
end;

procedure TfmTemicDlg.gridBytesClick(Sender: TObject);
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
    rc.Left := ((rc.Left + rc.Right - dx) div 2);
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

procedure TfmTemicDlg.gridBytesDblClick(Sender: TObject);
begin
  EnableEditMode;
end;

procedure TfmTemicDlg.gridBytesDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  oGrid: TStringGrid;
  pCanva: TCanvas;
  rc: TRect;
  I, nBlockIdx, nByteIdx, cx, cy, x, y, a, b, k: Integer;
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

  nBlockIdx := RowToBlockIdx(ARow);
  nByteIdx := ColToByteIdx(ACol);

  if (ACol < oGrid.FixedCols) or (ARow < oGrid.FixedRows) then
  begin
    pCanva.Brush.Color := oGrid.FixedColor;
    pCanva.FillRect(Rect);
    S := oGrid.Cells[ACol, ARow];
    if (ACol = 0) and (ARow >= oGrid.FixedRows) then
    begin
      if ARow >= 3 then
      begin
        rc := Rect;
        rc.Top := rc.Top + ((rc.Height - 16) div 2);
        Inc(rc.Left, 4);
        rc.Right := rc.Left + 16;
        rc.Bottom := rc.Top + 16;

        if IsBlockChecked(nBlockIdx) then
          nCheckState := TCheckBoxState.cbChecked
        else
          nCheckState := TCheckBoxState.cbUnchecked;
        DrawCheckbox(pCanva.Handle, rc, nCheckState);
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
    if nBlockIdx > 7 then
      pCanva.Brush.Color := shLegSN.Brush.Color
    else if (nBlockIdx = 7) and ((m_aNewBlocks[0, 3] and $10) <> 0) then
      pCanva.Brush.Color := shLegPassw.Brush.Color
    else if nBlockIdx > 0 then
      pCanva.Brush.Color := shLegData.Brush.Color
    else
      pCanva.Brush.Color := shLegConfig.Brush.Color;

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
    if (m_aNewBlocks[nBlockIdx, nByteIdx] <> m_aOldBlocks[nBlockIdx, nByteIdx]) then
    begin
      a := m_aOldBlocks[nBlockIdx, nByteIdx];
      b := m_aNewBlocks[nBlockIdx, nByteIdx];
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
              if (a and nFlags) <> (b and nFlags) then
                k := I;
            end
            else if (a and nFlags) = (b and nFlags) then
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
      (m_nCellCharIdx > 0) then
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

procedure TfmTemicDlg.gridBytesFixedCellClick(Sender: TObject; ACol,
  ARow: Integer);
var
  oGrid: TStringGrid;
  nBlockIdx: Integer;
begin
  oGrid := (Sender as TStringGrid);
  if (ACol = 0) and (ARow >= (oGrid.FixedRows + 2)) then
  begin
    nBlockIdx := RowToBlockIdx(ARow);
    if nBlockIdx <> -1 then
      SetBlockChecked(nBlockIdx, not IsBlockChecked(nBlockIdx));
  end;
end;

procedure TfmTemicDlg.gridBytesKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  oGrid: TStringGrid;
  nBlockIdx, nByteIdx: Integer;
  nFormat: TCellFormat;
  sNewValue, sOldValue: string;
begin
  oGrid := (Sender as TStringGrid);
  case Key of
    VK_ESCAPE: // Клавиша ESC
      EnableEditMode(False);

    VK_RETURN: // Клавиша Enter
    begin
      nBlockIdx := RowToBlockIdx(m_nRow);
      nByteIdx := ColToByteIdx(m_nCol);
      if not IsReadOnlyByte(nBlockIdx, nByteIdx) then
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
        nBlockIdx := RowToBlockIdx(m_nRow);
        nByteIdx := ColToByteIdx(m_nCol);
        if not IsReadOnlyByte(nBlockIdx, nByteIdx) then
        begin
          nFormat := GetCellFormat(m_nCol, m_nRow);
          sNewValue := oGrid.Cells[m_nCol, m_nRow];
          sOldValue := ByteToCellStr(m_aOldBlocks[nBlockIdx, nByteIdx], nFormat);
          sNewValue[m_nCellCharIdx] := sOldValue[m_nCellCharIdx];
          SetByte(nBlockIdx, nByteIdx, CellStrToByte(sNewValue, nFormat), False);
          oGrid.Cells[m_nCol, m_nRow] := sNewValue;
        end;
      end;
  end;
end;

procedure TfmTemicDlg.gridBytesKeyPress(Sender: TObject; var Key: Char);
var
  oGrid: TStringGrid;
  nBlockIdx, nByteIdx: Integer;
  S: string;
  nValue: Byte;
begin
  oGrid := (Sender as TStringGrid);
  if not Key.IsControl then
  begin
    nBlockIdx := RowToBlockIdx(m_nRow);
    nByteIdx := ColToByteIdx(m_nCol);
    if IsReadOnlyByte(nBlockIdx, nByteIdx) then
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
            ASSERT(m_nCellCharIdx <= Length(s));
            S[m_nCellCharIdx] := Key;
            nValue := CellStrToByte(S, cfBin);
            if not IsValidByteValue(nBlockIdx, nByteIdx, nValue) then
              Exit;
            oGrid.Cells[m_nCol, m_nRow] := S;
            Inc(m_nCellCharIdx);
            m_fEditMode := True;
            SetByte(nBlockIdx, nByteIdx, nValue, False);
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
            ASSERT(m_nCellCharIdx <= Length(S));
            S[m_nCellCharIdx] := UpCase(Key);
            nValue := CellStrToByte(S, cfDec);
            if not IsValidByteValue(nBlockIdx, nByteIdx, nValue) then
              Exit;
            oGrid.Cells[m_nCol, m_nRow] := S;
            Inc(m_nCellCharIdx);
            m_fEditMode := True;
            SetByte(nBlockIdx, nByteIdx, nValue, False);
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
            if not IsValidByteValue(nBlockIdx, nByteIdx, nValue) then
              Exit;
            oGrid.Cells[m_nCol, m_nRow] := S;
            Inc(m_nCellCharIdx);
            m_fEditMode := True;
            SetByte(nBlockIdx, nByteIdx, nValue, False);
          end;
        end;
        if m_fEditMode and (m_nCellCharIdx > 2) and (not NextEditCell) then
          m_nCellCharIdx := 1;
      end;
    end;
  end;
end;

procedure TfmTemicDlg.gridBytesSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  CanSelect := (ARow >= (gridBytes.FixedRows + 2));
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

function TfmTemicDlg.IsBlockChecked(ABlockIdx: Integer): Boolean;
begin
  Result := GetBit(m_nLocks, ABlockIdx);
end;

function TfmTemicDlg.IsReadOnlyByte(ABlockIdx, AByteIdx: Integer): Boolean;
begin
  Result := (ABlockIdx > 7) or
    ((ABlockIdx = 7) and ((m_aNewBlocks[0, 3] and $10) <> 0));
end;

function TfmTemicDlg.IsValidByteValue(ABlockIdx, AByteIdx: Integer;
  AValue: Byte): Boolean;
begin
  Result := (ABlockIdx < 8) or (m_aOldBlocks[ABlockIdx, AByteIdx] = AValue);
end;

function TfmTemicDlg.NextEditCell: Boolean;
var
  I, nBlockIdx, nByteIdx: Integer;
begin
  nBlockIdx := RowToBlockIdx(m_nRow);
  nByteIdx := ColToByteIdx(m_nCol);
  // Цикл по всем байтам
  for I := 0 to SizeOf(m_aOldBlocks) - 1 do
  begin
    if nByteIdx < High(m_aOldBlocks[nBlockIdx]) then
      Inc(nByteIdx)
    else
    begin
      if nBlockIdx > 0 then
        Dec(nBlockIdx)
      else
        nBlockIdx := High(m_aOldBlocks);
      nByteIdx := 0;
    end;
    if not IsReadOnlyByte(nBlockIdx, nByteIdx) then
    begin
      gridBytes.Col := ByteIdxToCol(nByteIdx);
      gridBytes.Row := BlockIdxToRow(nBlockIdx);
      m_nCellCharIdx := 1;
      gridBytes.Invalidate;
      Exit(True);
    end;
  end;
  Result := False;
end;

function TfmTemicDlg.PrevEditCell: Boolean;
var
  I, nBlockIdx, nByteIdx: Integer;
begin
  nBlockIdx := RowToBlockIdx(m_nRow);
  nByteIdx := ColToByteIdx(m_nCol);
  // Цикл по всем байтам
  for I := 0 to SizeOf(m_aOldBlocks) - 1 do
  begin
    if nByteIdx > 0 then
      Dec(nByteIdx)
    else
    begin
      nBlockIdx := (nBlockIdx + 1) mod Length(m_aOldBlocks);
      nByteIdx := 3;
    end;
    if not IsReadOnlyByte(nBlockIdx, nByteIdx) then
    begin
      gridBytes.Col := ByteIdxToCol(nByteIdx);
      gridBytes.Row := BlockIdxToRow(nBlockIdx);
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

procedure TfmTemicDlg.ReadCardData;
begin
  try
    m_iReader.LoadTemicPassword(m_nCurrPassword);
    m_iReader.ReadTemic(0, PCardinal(@m_aOldBlocks[0]), Length(m_aOldBlocks));
  finally
    Move(m_aOldBlocks, m_aNewBlocks, SizeOf(m_aNewBlocks));
    UpdateGrid;
    chkPassword.Checked := GetBit(m_aNewBlocks[0, 3], 4);
    UpdatePasswordCombobox;
    UpdatePasswordGroupCtrlState;
    UpdateConfigGroupData(False);
    UpdateEmulatedLabel;
  end;
end;

procedure TfmTemicDlg.rgCardTypeClick(Sender: TObject);
begin
  pcCreateCard.ActivePageIndex := rgCardType.ItemIndex;
end;

procedure TfmTemicDlg.rgDataFormatClick(Sender: TObject);
var
  nIdx: Integer;
begin
  nIdx := rgDataFormat.ItemIndex;
  if g_AppSet.m_nTmcDataFormat <> TCellFormat(nIdx) then
  begin
    g_AppSet.SetTemicDataFormat(TCellFormat(nIdx));
    UpdateGrid;
  end;
end;

procedure TfmTemicDlg.rgHidFormatClick(Sender: TObject);
var
  nIdx: Integer;
begin
  nIdx := rgHidFormat.ItemIndex;
  if g_AppSet.m_nHidFormat <> THidFormat(nIdx) then
  begin
    g_AppSet.SetHidFormat(THidFormat(nIdx));
    UpdateHID();
  end;
end;

function TfmTemicDlg.RowToBlockIdx(ARow: Integer): Integer;
begin
  Result := (gridBytes.RowCount - 1 - ARow);
end;

procedure TfmTemicDlg.SetBlockChecked(ABlockIdx: Integer; AChecked,
  ARedraw: Boolean);
begin
  SetBit(m_nLocks, ABlockIdx, AChecked);
  if ARedraw then
    gridBytes.Invalidate;
end;

procedure TfmTemicDlg.SetByte(ABlockIdx, AByteIdx: Integer; AValue: Byte;
  AUpdateGrid: Boolean {= True});
begin
  if m_aNewBlocks[ABlockIdx, AByteIdx] = AValue then
    Exit;

  m_aNewBlocks[ABlockIdx, AByteIdx] := AValue;
  if AUpdateGrid then
    UpdateGridCell(ByteIdxToCol(AByteIdx), BlockIdxToRow(ABlockIdx));
  if ABlockIdx = 0 then
  begin
    if AByteIdx = 3 then
    begin
      chkPassword.Checked := GetBit(m_aNewBlocks[0, 3], 4);
      UpdatePasswordGroupCtrlState;
    end;
    UpdateConfigGroupData(False);
  end;
end;

procedure TfmTemicDlg.SetMaskEditValue(AEdit: TMaskEdit; const Value: String);
var
  nStart, nLength: Integer;
begin
  nStart := AEdit.SelStart;
  nLength := AEdit.SelLength;
  try
    AEdit.Text := Value;
  finally
    AEdit.SelStart := nStart;
    AEdit.SelLength := nLength;
  end;
end;

procedure TfmTemicDlg.SetSpinEditValue(AEdit: TSpinEdit; Value: Integer);
var
  nStart, nLength: Integer;
begin
  nStart := AEdit.SelStart;
  nLength := AEdit.SelLength;
  try
    AEdit.Value := Value;
  finally
    AEdit.SelStart := nStart;
    AEdit.SelLength := nLength;
  end;
end;

procedure TfmTemicDlg.UpdateConfigGroupData(ASave: Boolean);
var
  nConfig, nMasterKey, nBitRate, nModulation: Cardinal;
  fXMode: Boolean;
  nIdx: Integer;
begin
  nConfig := PCardinal(@m_aNewBlocks[0])^;
  nMasterKey := (nConfig shr 4) and $f;
  fXMode := GetBit(nConfig, 9) and (nMasterKey in [6, 9]);
  if ASave then
  begin
    nIdx := cbMode.ItemIndex;
    case nIdx of
      0:
      begin
        SetBit(nConfig, 9, False);
        if chkTestMode.Checked then
          nConfig := (nConfig and not $F) or 6
        else
          nConfig := (nConfig and not $F) or 9;
        fXMode := False;
      end;

      1:
      begin
        SetBit(nConfig, 9, True);
        if chkTestMode.Checked then
          nConfig := (nConfig and not $F) or 9
        else
          nConfig := (nConfig and not $F) or 6;
        fXMode := True;
      end;
    end;

    if sscanf(cbDataBitRate.Text, 'RF/%d', [@nBitRate]) = 1 then
    begin
      if fXMode then
        nConfig := (nConfig and not $FC00) or (((nBitRate - 2) div 2) shl 10)
      else
      begin
        nIdx := Finde5550BitRateCode(nBitRate);
        if nIdx <> -1 then
          nConfig := (nConfig and not $1C00) or (Cardinal(nIdx) shl 10);
      end;
    end;
    nIdx := cbModulation.ItemIndex;
    if nIdx <> -1 then
    begin
      case nIdx of
        0..8: nModulation := nIdx;
        9: nModulation := $10;
        10: nModulation := $18;
        else begin Assert(False); nModulation := 0 end;
      end;
      nConfig := (nConfig and not $F00100) or ((nModulation and $F) shl 20) or
        ((nModulation shr 4) shl 8);
    end;
    nIdx := cbPSK_CF.ItemIndex;
    if nIdx <> -1 then
      nConfig := (nConfig and not $C0000) or (Cardinal(nIdx) shl 18);
    nIdx := cbMaxBlock.ItemIndex;
    if nIdx <> -1 then
      nConfig := (nConfig and not $E0000000) or (Cardinal(nIdx) shl 29);
    SetBit(nConfig, 17, chkAOR.Checked);
    SetBit(nConfig, 16, fXMode and chkOTP.Checked);
    if fXMode then
      SetBit(nConfig, 27, chkSST_seq_sm.Checked)
    else
      SetBit(nConfig, 27, chkST_seq_ter.Checked);
    SetBit(nConfig, 26, fXMode and chkFastWrite.Checked);
    SetBit(nConfig, 25, fXMode and chkInverseData.Checked);
    SetBit(nConfig, 17, chkPOR_delay.Checked);
  end
  else
  begin
    if fXMode then
    begin
      cbMode.ItemIndex := 1;
      chkTestMode.Checked := (nMasterKey = 9);
    end
    else
    begin
      cbMode.ItemIndex := 0;
      chkTestMode.Checked := (nMasterKey = 6);
    end;
    if fXMode then
      nBitRate := ((nConfig shr 10) and $3F) * 2 + 2
    else
      nBitRate := ke5550BitRates[(nConfig shr 10) and 7];
    cbDataBitRate.Text := format('RF/%d', [nBitRate]);
    nModulation := ((nConfig shr 20) and $F) or (((nConfig shr 8) and 1) shl 4);
    case nModulation of
      0..8: nIdx := nModulation;
      $10: nIdx := 9;
      $18: nIdx := 10;
      else nIdx := -1;
    end;
    cbModulation.ItemIndex := nIdx;
    cbPSK_CF.ItemIndex := (nConfig shr 18) and 3;
    cbMaxBlock.ItemIndex := (nConfig shr 29) and 7;
    chkAOR.Checked := GetBit(nConfig, 17);
    chkST_seq_ter.Checked := GetBit(nConfig, 27);
    chkST_seq_ter.Visible := not fXMode;
    chkSST_seq_sm.Checked := GetBit(nConfig, 27);
    chkSST_seq_sm.Visible := fXMode;
    chkOTP.Checked := GetBit(nConfig, 16);
    chkOTP.Visible := fXMode;
    chkFastWrite.Checked := GetBit(nConfig, 26);
    chkFastWrite.Visible := fXMode;
    chkInverseData.Checked := GetBit(nConfig, 25);
    chkInverseData.Visible := fXMode;
    chkPOR_delay.Checked := GetBit(nConfig, 24);
  end;
end;

procedure TfmTemicDlg.UpdateEmMarine;
begin
  SetMaskEditValue(edtEmFacility, IntToHex(PWord(@m_rEmMarineUId.aBytes[3])^, 4));
  SetSpinEditValue(edtEmGroup, m_rEmMarineUId.aBytes[2]);
  SetSpinEditValue(edtEmNumber, PWord(@m_rEmMarineUId.aBytes[0])^);
end;

procedure TfmTemicDlg.UpdateEmulatedLabel;
var
  rUId: TCardUId;
  nWiegand: Integer;
  fConfigOk: Boolean;
  nCardType: TCardType;
begin
  rUId.Clear;
  m_iReader.DecodeTemicEmMarine(PCardinal(@m_aNewBlocks[0]), 3, rUId, fConfigOk);
  if rUId.IsEmpty then
  begin
    m_iReader.DecodeTemicHID(PCardinal(@m_aNewBlocks[0]), 4, rUId, nWiegand, fConfigOk);
    nCardType := cHID;
  end
  else
    nCardType := cEmMarine;
  if not rUId.IsEmpty then
  begin
    if nCardType = cHID then
      edtEmulated.Text := format('%s[W%d] %s', [
        kCardTypeNames[nCardType], nWiegand,
        ILRCardUIDToStr(nCardType, rUId)])
    else
      edtEmulated.Text := format('%s %s', [
        kCardTypeNames[nCardType],
        ILRCardUIDToStr(nCardType, rUId)]);
  end;
end;

procedure TfmTemicDlg.UpdateGrid;
var
  nBlockIdx, nByteIdx, nCol, nRow: Integer;
  nByte: Byte;
begin
  for nBlockIdx := 0 to High(m_aNewBlocks) do
  begin
    nCol := gridBytes.FixedCols;
    nRow := BlockIdxToRow(nBlockIdx);
    for nByteIdx := 0 to High(m_aNewBlocks[nBlockIdx]) do
    begin
      nByte := m_aNewBlocks[nBlockIdx, nByteIdx];
      gridBytes.Cells[nCol, nRow] := ByteToCellStr(nByte, GetCellFormat(nCol, nRow));
      Inc(nCol);
    end;
  end;
  gridBytes.Invalidate;
end;

procedure TfmTemicDlg.UpdateGridCell(ACol, ARow: Integer);
var
  nByte: Integer;
begin
  nByte := m_aNewBlocks[RowToBlockIdx(ARow), ColToByteIdx(ACol)];
  gridBytes.Cells[ACol, ARow] := ByteToCellStr(nByte, GetCellFormat(ACol, ARow));
end;

procedure TfmTemicDlg.UpdateGridRow(ARow: Integer);
var
  nBlockIdx, nByteIdx, nCol: Integer;
  nByte: Byte;
begin
  nBlockIdx := RowToBlockIdx(ARow);
  nCol := gridBytes.FixedCols;
  for nByteIdx := 0 to High(m_aNewBlocks[nBlockIdx]) do
  begin
    nByte := m_aNewBlocks[nBlockIdx, nByteIdx];
    gridBytes.Cells[nCol, ARow] := ByteToCellStr(nByte, GetCellFormat(nCol, ARow));
    Inc(nCol);
  end;
end;

procedure TfmTemicDlg.UpdateHID;
var
  I, nFSize, nFCount, nFacility: Integer;
  S: string;
begin
  edtHidWiegand.Value := m_nHidWiegand;
  nFSize := m_nHidWiegand - 2 - 16;
  nFCount := nFSize div 8;
  if (nFSize mod 8) <> 0 then
    Inc(nFCount);
  if nFSize > 0 then
  begin
    case g_AppSet.m_nHidFormat of
      hfDec:
      begin
        edtHidFacility2.MaxValue := (1 shl nFSize);
        nFacility := 0;
        Move(m_rHidUId.aBytes[2], nFacility, nFCount);
        edtHidFacility2.Value := nFacility;
        edtHidFacility.Visible := False;
        edtHidFacility2.Visible := True;
      end;

      hfHex:
      begin
        S := DupeString('AA', nFCount);
//        Delete(s, Length(s), 1);
        edtHidFacility.EditMask := s + ';1;_';
        S := '';
        for I := nFCount - 1 downto 0 do
          S := S + format('%.2X', [m_rHidUId.aBytes[2 + I]]);
//        Delete(S, Length(S), 1);
        SetMaskEditValue(edtHidFacility, s);
        edtHidFacility2.Visible := False;
        edtHidFacility.Visible := True;
      end;

      else Assert(False);
    end;
  end
  else
  begin
    edtHidFacility.Visible := False;
    edtHidFacility2.Visible := False;
  end;
  edtHidNumber.Value := PWord(@m_rHidUId.aBytes[0])^;
end;

procedure TfmTemicDlg.UpdatePasswordCombobox;
var
  oCB: TComboBox;
  I: Integer;
begin
  oCB := cbPassword;
  oCB.Items.BeginUpdate;
  try
    oCB.Items.Clear;
    for I := 0 to g_AppSet.m_oTmcPasswords.Count - 1 do
    begin
      case g_AppSet.m_nTmcPasswFormat of
        tpfDec: oCB.Items.Add(IntToStr(g_AppSet.m_oTmcPasswords[I].m_nPassword));
        tpfHex: oCB.Items.Add(IntToHex(g_AppSet.m_oTmcPasswords[I].m_nPassword, 8));
        else Assert(False);
      end;
    end;
    oCB.ItemIndex := g_AppSet.m_oTmcPasswords.IndexOfPassword(PCardinal(@m_aNewBlocks[7])^);
  finally
    oCB.Items.EndUpdate;
  end;
end;

procedure TfmTemicDlg.UpdatePasswordGroupCtrlState;
var
  f: Boolean;
begin
  f := chkPassword.Checked;
  cbPassword.Enabled := f;
  btnPswList.Enabled := f;
end;

procedure TfmTemicDlg.WriteCardData;
begin
  ExecuteWithProgress(SWritingBlocks, procedure(ADlg: TfmProgressDlg)
  var
    I, nCurrent, nTotal: Integer;
    nStartTick, nSpan: Cardinal;
    fSetPassword: Boolean;
  begin
    nCurrent := 0;
    nTotal := 8;
    nStartTick := GetTickCount;
    m_iReader.LoadTemicPassword(m_nCurrPassword);
    // Сначала пишем данные User Data
    for I := 1 to 6 do
    begin
      if not CompareMem(@m_aNewBlocks[I], @m_aOldBlocks[I], 4) then
      begin
        m_iReader.WriteTemic(I, PCardinal(@m_aNewBlocks[I]), 1,
          GetBit(m_nLocks, I));
        Move(m_aNewBlocks[I], m_aOldBlocks[I], 4);
      end;
      Inc(nCurrent);
      ADlg.SetProgress(nCurrent, nTotal);
      Application.ProcessMessages();
      if ADlg.m_fCancelled then
      begin
        ADlg.labDescription.Caption := SCancelled;
        Exit;
      end;
    end;

    // Пишем пароль
    if not CompareMem(@m_aNewBlocks[7], @m_aOldBlocks[7], 4) then
    begin
      m_iReader.WriteTemic(7, PCardinal(@m_aNewBlocks[7]), 1,
        GetBit(m_nLocks, 7));
      if m_nCurrPassword <> -1 then
        m_nCurrPassword := PCardinal(@m_aNewBlocks[7])^;
      Move(m_aNewBlocks[7], m_aOldBlocks[7], 4);
      m_iReader.LoadTemicPassword(m_nCurrPassword);
    end;
    Inc(nCurrent);
    ADlg.SetProgress(nCurrent, nTotal);
    Application.ProcessMessages();
    if ADlg.m_fCancelled then
    begin
      ADlg.labDescription.Caption := SCancelled;
      Exit;
    end;

    // Пишем конфигурацию
    if not CompareMem(@m_aNewBlocks[0], @m_aOldBlocks[0], 4) then
    begin
      m_iReader.WriteTemic(0, PCardinal(@m_aNewBlocks[0]), 1,
        GetBit(m_nLocks, 0));
      Move(m_aNewBlocks[0], m_aOldBlocks[0], 4);
      fSetPassword := ((m_aNewBlocks[0, 3] and $10) <> 0);
      if fSetPassword <> (m_nCurrPassword <> -1) then
      begin
        if fSetPassword then
          m_nCurrPassword := PCardinal(@m_aNewBlocks[7])^
        else
          m_nCurrPassword := -1;
        m_iReader.LoadTemicPassword(m_nCurrPassword);
      end;
    end;
    Inc(nCurrent);
    ADlg.SetProgress(nCurrent, nTotal);

    nSpan := GetTickSpan(nStartTick, GetTickCount);
    ADlg.labDescription.Caption := format(SWriteBlocksCompleted_F, [nSpan / 1000.0]);
  end, Self);

  gridBytes.Invalidate;
end;

end.
