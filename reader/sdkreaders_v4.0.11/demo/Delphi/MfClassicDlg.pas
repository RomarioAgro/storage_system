unit MfClassicDlg;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.CheckLst, Vcl.Mask, Vcl.ComCtrls, Vcl.Grids, Vcl.ImgList,
  Vcl.Menus, Vcl.Samples.Spin, SpinEdit64,
  IL.Readers, uTypes, uConst, uMfReaderSettings;

type
  TfmMfClassicDlg = class(TForm)
    lbGroups: TListBox;
    gridBytes: TStringGrid;
    grAuthorization: TGroupBox;
    pcAuth: TPageControl;
    tabAuthKeyVal: TTabSheet;
    edtAuthKey: TMaskEdit;
    btnAuthKeys: TButton;
    btnAuthKey: TButton;
    tabAuthRdKeys: TTabSheet;
    btnRdKeys: TButton;
    rgAuthKeyMode: TRadioGroup;
    rgDataFormat: TRadioGroup;
    grTrailLegend: TGroupBox;
    shLegAccess: TShape;
    labLegAccess: TLabel;
    shLegAccessRO: TShape;
    labLegAccessRO: TLabel;
    shLegKeyWO: TShape;
    labLegKeyWO: TLabel;
    grDataLegend: TGroupBox;
    shLegSN: TShape;
    labLegSN: TLabel;
    shLegData: TShape;
    labLegData: TLabel;
    shLegDataRO: TShape;
    labLegDataRO: TLabel;
    shLegDataNRW: TShape;
    labLegDataNRW: TLabel;
    grSectorCfg: TGroupBox;
    labCfgSect: TLabel;
    grCfgTrailAcc: TGroupBox;
    pbCfgTrailAcc: TPaintBox;
    cbCfgTrailAcc: TComboBox;
    grCfgAuthKeys: TGroupBox;
    Label2: TLabel;
    Label4: TLabel;
    labCfgKeyBWarning: TLabel;
    edtCfgKeyA: TMaskEdit;
    btnCfgRdKeyA: TButton;
    edtCfgKeyB: TMaskEdit;
    btnCfgRdKeyB: TButton;
    btnCfgKeyA: TButton;
    btnCfgKeyB: TButton;
    grCfgDataAcc: TGroupBox;
    pbCfgDataAcc: TPaintBox;
    labCfgArea2: TLabel;
    labCfgArea1: TLabel;
    labCfgArea0: TLabel;
    cbCfgArea2: TComboBox;
    cbCfgArea1: TComboBox;
    cbCfgArea0: TComboBox;
    btnRead: TButton;
    btnWrite: TButton;
    labLegValue: TLabel;
    shLegValue: TShape;
    shLegKeyNRW: TShape;
    labLegKeyNRW: TLabel;
    labLegValueDO: TLabel;
    shLegValueDO: TShape;
    rgAuthKeySource: TRadioGroup;
    lbRdKeys: TCheckListBox;
    lbAuthRdKeys: TCheckListBox;
    btnAuthRdKeys: TButton;
    ImageList1: TImageList;
    menuKeys: TPopupMenu;
    menuRdKeys: TPopupMenu;
    menuGrid: TPopupMenu;
    miReadGroup: TMenuItem;
    N1: TMenuItem;
    miWriteGroup: TMenuItem;
    miReadAll: TMenuItem;
    miWriteAll: TMenuItem;
    miReadSector: TMenuItem;
    miWriteSector: TMenuItem;
    menuAuthRdKeys: TPopupMenu;
    miAuthRdKeysCheckAll: TMenuItem;
    miAuthRdKeysUncheckAll: TMenuItem;
    grValueBlock: TGroupBox;
    btnMfIncrement: TButton;
    btnMfDecrement: TButton;
    btnMfTransfer: TButton;
    btnMfRestore: TButton;
    edtMfValue: TSpinEdit64;
    procedure btnReadClick(Sender: TObject);
    procedure btnWriteClick(Sender: TObject);
    procedure gridBytesSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure gridBytesDblClick(Sender: TObject);
    procedure gridBytesClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure rgDataFormatClick(Sender: TObject);
    procedure gridBytesDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure FormShow(Sender: TObject);
    procedure lbGroupsClick(Sender: TObject);
    procedure gridBytesKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure gridBytesKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure rgAuthKeyModeClick(Sender: TObject);
    procedure btnAuthRdKeysClick(Sender: TObject);
    procedure lbRdKeysExit(Sender: TObject);
    procedure lbRdKeysKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lbRdKeysClickCheck(Sender: TObject);
    procedure lbAuthRdKeysClickCheck(Sender: TObject);
    procedure rgAuthKeySourceClick(Sender: TObject);
    procedure btnRdKeysClick(Sender: TObject);
    procedure btnAuthKeysClick(Sender: TObject);
    procedure pbCfgTrailAccPaint(Sender: TObject);
    procedure pbCfgDataAccPaint(Sender: TObject);
    procedure cbCfgTrailAccDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure cbCfgArea2DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure cbCfgArea1DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure cbCfgArea0DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure btnAuthKeyClick(Sender: TObject);
    procedure btnCfgKeyAClick(Sender: TObject);
    procedure btnCfgKeyBClick(Sender: TObject);
    procedure btnCfgRdKeyAClick(Sender: TObject);
    procedure btnCfgRdKeyBClick(Sender: TObject);
    procedure miReadGroupClick(Sender: TObject);
    procedure miWriteGroupClick(Sender: TObject);
    procedure miReadAllClick(Sender: TObject);
    procedure miWriteAllClick(Sender: TObject);
    procedure miReadSectorClick(Sender: TObject);
    procedure miWriteSectorClick(Sender: TObject);
    procedure cbCfgTrailAccSelect(Sender: TObject);
    procedure cbCfgArea2Select(Sender: TObject);
    procedure cbCfgArea1Select(Sender: TObject);
    procedure cbCfgArea0Select(Sender: TObject);
    procedure edtCfgKeyAChange(Sender: TObject);
    procedure edtCfgKeyBChange(Sender: TObject);
    procedure miAuthRdKeysCheckAllClick(Sender: TObject);
    procedure miAuthRdKeysUncheckAllClick(Sender: TObject);
    procedure btnMfIncrementClick(Sender: TObject);
    procedure btnMfDecrementClick(Sender: TObject);
    procedure btnMfTransferClick(Sender: TObject);
    procedure btnMfRestoreClick(Sender: TObject);
  public type
    // Вид списка ключей
    TKeyListKind = (
      klAuthKey,
      klKeyA,
      klKeyB
    );
    // Информация о секторе Mifare Classic
    TMfSectorInfo = record
      m_fAuthOk       : Boolean;  // True, авторизации прошла успешно
      // Параметры авторизации
      m_fKeyB         : Boolean;  // True, авторизован по ключу B, иначе - по ключу A
      m_nRdKeyIdx     : Integer;  // Номер ключа аутентификации в памяти считывателя
      m_nAuthKey      : TMfClassicKey; // Явный ключ аутентификации
      // Данные сектора
      m_fReadDataOk   : Boolean;  // True, чтение сектора выполнено (возможно с ошибками)
      m_nInitBlocks   : Cardinal; // Биты успешно прочитанных блоков сектора
      m_aKeyInit      : array[Boolean] of Boolean; // [KeyB] = True ключ известный
    end;
    PMfSectorInfo = ^TMfSectorInfo;

  private
    { Private declarations }
    m_rUId          : TCardUId; // Id карты
    m_aSectors      : TArray<TMfSectorInfo>; // Список инфо о секторах

    m_nFirstBlockIdx: Integer; // Номер первого отображаемого блока
    m_nBlockCount   : Integer; // Количество отображаемых блоков
    m_nCol          : Integer;
    m_nRow          : Integer;
    m_fEditMode     : Boolean;
    m_nCellCharIdx  : Integer;

    // Параметры авторизации
    m_fAuthKeyB     : Boolean; // True, авторизация по ключу B, иначе - по ключу A
    m_fAuthByRdKeys : Boolean; // True, авторизация по ключу из памяти считывателя, иначе - по явному ключу
    m_nAuthKey      : TMfClassicKey; // Ключ аутентификации
    m_aAuthRdKeys   : array[Boolean] of Cardinal;

    m_nSectorIdx    : Integer; // Номер текущего сектора для панели "Конфигурация сектора"

    procedure miKeyXClick(Sender: TObject);
    procedure miRdKeyXClick(Sender: TObject);

    // Вкл/выкл режим редактирования ячеек
    procedure EnableEditMode(AEnable: Boolean = True);
    function GetCellFormat(ACol, ARow: Integer): TCellFormat; inline;
    function ByteIdxToCol(AByteIdx: Integer): Integer;
    function ColToByteIdx(ACol: Integer): Integer;
    function BlockIdxToRow(ABlockIdx: Integer): Integer;
    function RowToBlockIdx(ARow: Integer): Integer;
    procedure UpdateGroupListBox;
    procedure UpdateGrid;
    procedure UpdateGridCell(ACol, ARow: Integer);
    procedure UpdateGridRow(ARow: Integer);
    procedure UpdateValueBlockGroup;
    procedure UpdateSectorConfigPanel;
    function IsReadOnlyByte(ABlockIdx, AByteIdx: Integer): Boolean;
    function IsValidByteValue(ABlockIdx, AByteIdx: Integer; AValue: Byte): Boolean;
    procedure SetByte(ABlockIdx, AByteIdx: Integer; AValue: Byte;
      AUpdateGrid: Boolean = True);
    // Перемещает фокус на следующую ячейку, доступную для редактирования
    function NextEditCell: Boolean;
    // Перемещает фокус на предыдущую ячейку, доступную для редактирования
    function PrevEditCell: Boolean;
    // Перемещает фокус на ячейку ниже, доступную для редактирования
    function DownEditCell: Boolean;
    // Перемещает фокус на ячейку выше, доступную для редактирования
    function UpEditCell: Boolean;
    procedure UpdateAuthPanelData(ASave: Boolean);
    procedure UpdateAuthRdKeysCheckListBox;
    procedure UpdateRdKeysListBox;
    procedure UpdateRdKeysListBoxChecks;
    procedure DrawCfgAreaComboBoxItem(ACb: TComboBox; AIdx: Integer;
      ARect: TRect);
    function KeyToStr(const AKey: TMfClassicKey): string;
    // Возвращает ключ аутентификации сектора
    function GetSectorKey(ASectorIdx: Integer; AKeyB: Boolean;
      out VKey: TMfClassicKey): Boolean;
    // Устанавливает ключ аутентификации сектора
    procedure SetSectorKey(ASectorIdx: Integer; AKeyB: Boolean;
      const AKey: TMfClassicKey);
    // Устанавливает биты доступа области (C1 C2 C3)
    procedure SetSectorAreaAccess(ASectorIdx, AAreaN: Integer; AAreaBits: Cardinal);
    // Показывает меню со списком ключей аутентификации
    procedure ShowKeysMenu(AListKind: TKeyListKind; X, Y: Integer;
      AKeyIdx: Integer);
    // Показывает меню со списком ключей считывателя
    procedure ShowRdKeysMenu(AListKind: TKeyListKind; X, Y: Integer;
      AKeyIdx: Integer);

  public
    { Public declarations }
    m_iReader       : IILReader;            // Интерфейс считывателя
    m_pSettings     : TMfReaderSettings;    // Настройки считывателя
    m_aOldBlocks    : TArray<TMfBlockData>; // Исходные данные карты (до 256 блоков по 16 байт)
    m_aNewBlocks    : TArray<TMfBlockData>; // Изменённые данные карты

    // Читает данные из карты
    procedure ReadCardData; overload;
    procedure ReadCardData(ASectorIdx, ASectorCount: Integer); overload;
    procedure ReadGroup;
    procedure ReadSector;
    // Пишет данные в карту
    procedure WriteCardData; overload;
    procedure WriteCardData(ASectorIdx, ASectorCount: Integer); overload;
    procedure WriteGroup;
    procedure WriteSector;
    procedure DoMfIncrement;
    procedure DoMfDecrement;
    procedure DoMfTransfer;
    procedure DoMfRestore;
    // Открывает окно "Ключи считывателя"
    procedure OpenMfReaderKeysDlg;
    // Открывает окно "Ключи Mifare Classic"
    function OpenMfClassicKeysDlg: Boolean;
  end;

var
  fmMfClassicDlg: TfmMfClassicDlg;

implementation

{$R *.dfm}

uses
  System.Math, System.Character, System.UITypes, System.Types,
  uAppSettings, uUtils, IL.RUtils, uAppHelp,
  MfReaderMcKeysDlg, MfClassicKeysDlg, ProgressDlg;

const
  // Количество столбцов в ComboBox "Доступ блока-прицепа"
  kTrailerAccessCols = 8;
  // Размеры столбцов в ComboBox "Доступ блока-прицепа"
  kTrailerAccessColWs: array[0..kTrailerAccessCols-1] of Integer = (
    32, 50, 50, 60, 60, 50, 50, 163
  );
  // Количество столбцов в ComboBox "Доступ области данных"
  kDataAccessCols = 6;
  // Размеры столбцов в ComboBox "Доступ области данных"
  kDataAccessColWs: array[0..kDataAccessCols-1] of Integer = (
    32, 50, 50, 80, 80, 223
  );
  // [позиция строки таблицы "Биты доступа"] = значения битов доступа
  kAccessBits: array[0..7] of Byte = (
    0 {0 0 0}, 2 {0 1 0}, 1 {1 0 0}, 3 {1 1 0}, 4 {0 0 1}, 6 {0 1 1},
    5 {1 0 1}, 7 {1 1 1}
  );
  // kAccessIdxs[значению битов доступа] = позиция строки таблицы "Биты доступа"
  kAccessIdxs: array[0..7] of ShortInt = (
    {0 0 0} 0, {1 0 0} 2, {0 1 0} 1, {1 1 0} 3, {0 0 1} 4, {1 0 1} 6, {0 1 1} 5,
    7 {1 1 1}
  );


function TfmMfClassicDlg.BlockIdxToRow(ABlockIdx: Integer): Integer;
begin
  Result := (gridBytes.RowCount - 1 - ABlockIdx + m_nFirstBlockIdx)
end;

procedure TfmMfClassicDlg.btnAuthKeyClick(Sender: TObject);
var
  pt: TPoint;
  nAuthKeyIdx: Integer;
begin
  if edtAuthKey.Modified then
  begin
    TryStrToMfClassicKey(edtAuthKey.Text, m_nAuthKey);
    edtAuthKey.Modified := False;
  end;
  nAuthKeyIdx := g_AppSet.m_oMcKeys.IndexOfKey(m_nAuthKey);

  pt := edtAuthKey.BoundsRect.TopLeft;
  Inc(pt.Y, edtAuthKey.Height);
  pt := edtAuthKey.Parent.ClientToScreen(pt);
  ShowKeysMenu(TKeyListKind.klAuthKey, pt.X, pt.Y, nAuthKeyIdx);
end;

procedure TfmMfClassicDlg.btnAuthKeysClick(Sender: TObject);
begin
  OpenMfClassicKeysDlg;
end;

procedure TfmMfClassicDlg.btnAuthRdKeysClick(Sender: TObject);
var
  pt: TPoint;
begin
  if lbRdKeys.Visible then
    lbRdKeys.Visible := False
  else
  begin
    UpdateRdKeysListBox;
    pt := lbAuthRdKeys.BoundsRect.TopLeft;
    Inc(pt.Y, lbAuthRdKeys.Height);
    pt := lbAuthRdKeys.Parent.ClientToScreen(pt);
    pt := lbRdKeys.Parent.ScreenToClient(pt);
    lbRdKeys.Left := pt.X;
    lbRdKeys.Top := pt.Y;
    lbRdKeys.Visible := True;
    lbRdKeys.SetFocus;
  end;
end;

procedure TfmMfClassicDlg.btnCfgKeyAClick(Sender: TObject);
var
  pt: TPoint;
  nKeyIdx: Integer;
  nKey: TMfClassicKey;
begin
  if GetSectorKey(m_nSectorIdx, False, nKey) then
    nKeyIdx := g_AppSet.m_oMcKeys.IndexOfKey(nKey)
  else
    nKeyIdx := -1;

  pt := edtCfgKeyA.BoundsRect.TopLeft;
  Inc(pt.Y, edtCfgKeyA.Height);
  pt := edtCfgKeyA.Parent.ClientToScreen(pt);
  ShowKeysMenu(TKeyListKind.klKeyA, pt.X, pt.Y, nKeyIdx);
end;

procedure TfmMfClassicDlg.btnCfgKeyBClick(Sender: TObject);
var
  pt: TPoint;
  nKeyIdx: Integer;
  nKey: TMfClassicKey;
begin
  if GetSectorKey(m_nSectorIdx, True, nKey) then
    nKeyIdx := g_AppSet.m_oMcKeys.IndexOfKey(nKey)
  else
    nKeyIdx := -1;

  pt := edtCfgKeyB.BoundsRect.TopLeft;
  Inc(pt.Y, edtCfgKeyB.Height);
  pt := edtCfgKeyB.Parent.ClientToScreen(pt);
  ShowKeysMenu(TKeyListKind.klKeyB, pt.X, pt.Y, nKeyIdx);
end;

procedure TfmMfClassicDlg.btnCfgRdKeyAClick(Sender: TObject);
var
  pt: TPoint;
  nKeyIdx: Integer;
  nKey: TMfClassicKey;
begin
  if GetSectorKey(m_nSectorIdx, False, nKey) then
    nKeyIdx := m_pSettings.FindClassicKey(False, nKey)
  else
    nKeyIdx := -1;

  pt := btnCfgRdKeyA.BoundsRect.TopLeft;
  Inc(pt.Y, btnCfgRdKeyA.Height);
  pt := btnCfgRdKeyA.Parent.ClientToScreen(pt);
  ShowRdKeysMenu(TKeyListKind.klKeyA, pt.X, pt.Y, nKeyIdx);
end;

procedure TfmMfClassicDlg.btnCfgRdKeyBClick(Sender: TObject);
var
  pt: TPoint;
  nKeyIdx: Integer;
  nKey: TMfClassicKey;
begin
  if GetSectorKey(m_nSectorIdx, True, nKey) then
    nKeyIdx := m_pSettings.FindClassicKey(True, nKey)
  else
    nKeyIdx := -1;

  pt := btnCfgRdKeyB.BoundsRect.TopLeft;
  Inc(pt.Y, btnCfgRdKeyB.Height);
  pt := btnCfgRdKeyB.Parent.ClientToScreen(pt);
  ShowRdKeysMenu(TKeyListKind.klKeyB, pt.X, pt.Y, nKeyIdx);
end;

procedure TfmMfClassicDlg.btnMfDecrementClick(Sender: TObject);
begin
  DoMfDecrement;
end;

procedure TfmMfClassicDlg.btnMfIncrementClick(Sender: TObject);
begin
  DoMfIncrement;
end;

procedure TfmMfClassicDlg.btnMfRestoreClick(Sender: TObject);
begin
  DoMfRestore;
end;

procedure TfmMfClassicDlg.btnMfTransferClick(Sender: TObject);
begin
  DoMfTransfer;
end;

procedure TfmMfClassicDlg.btnRdKeysClick(Sender: TObject);
begin
  OpenMfReaderKeysDlg;
end;

procedure TfmMfClassicDlg.btnReadClick(Sender: TObject);
begin
  ReadCardData;
end;

procedure TfmMfClassicDlg.btnWriteClick(Sender: TObject);
begin
  WriteCardData;
end;

function TfmMfClassicDlg.ByteIdxToCol(AByteIdx: Integer): Integer;
begin
  Result := gridBytes.FixedCols + AByteIdx;
end;

procedure TfmMfClassicDlg.cbCfgArea0DrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
  DrawCfgAreaComboBoxItem(Control as TComboBox, Index, Rect);
end;

procedure TfmMfClassicDlg.cbCfgArea0Select(Sender: TObject);
var
  nIdx: Integer;
begin
  nIdx := cbCfgArea0.ItemIndex;
  if nIdx <> -1 then
    SetSectorAreaAccess(m_nSectorIdx, 0, kAccessBits[nIdx]);
end;

procedure TfmMfClassicDlg.cbCfgArea1DrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
  DrawCfgAreaComboBoxItem(Control as TComboBox, Index, Rect);
end;

procedure TfmMfClassicDlg.cbCfgArea1Select(Sender: TObject);
var
  nIdx: Integer;
begin
  nIdx := cbCfgArea1.ItemIndex;
  if nIdx <> -1 then
    SetSectorAreaAccess(m_nSectorIdx, 1, kAccessBits[nIdx]);
end;

procedure TfmMfClassicDlg.cbCfgArea2DrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
  DrawCfgAreaComboBoxItem(Control as TComboBox, Index, Rect);
end;

procedure TfmMfClassicDlg.cbCfgArea2Select(Sender: TObject);
var
  nIdx: Integer;
begin
  nIdx := cbCfgArea2.ItemIndex;
  if nIdx <> -1 then
    SetSectorAreaAccess(m_nSectorIdx, 2, kAccessBits[nIdx]);
end;

procedure TfmMfClassicDlg.cbCfgTrailAccDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  cb: TComboBox;
  pCanva: TCanvas;
  sLine, S: String;
  I, nColX, nColWidth, nPos, X, Y: Integer;
  fLast: Boolean;
begin
  cb := Control as TComboBox;
  pCanva := cb.Canvas;
  pCanva.Brush.Color := cb.Color;
  pCanva.Font := cb.Font;
  if Index in [0,1,4] then
    pCanva.Brush.Color := $00EBEBEB;
  pCanva.FillRect(Rect);
  sLine := cb.Items[Index];
  nColX := 0;
  nPos := 1;
  for I := 0 to kTrailerAccessCols - 1 do
  begin
    nColWidth := kTrailerAccessColWs[i];
    fLast := I = (kTrailerAccessCols - 1);
    if nPos <> 0 then
    begin
      S := TextToChar(sLine, ';', nPos);
      if fLast then
        X := nColX + 4
      else
        X := nColX + (nColWidth - pCanva.TextWidth(S)) div 2;
      Y := (Rect.Bottom + Rect.Top - pCanva.TextHeight(S)) div 2;
      pCanva.TextOut(X, Y, S);
    end;
    Inc(nColX, nColWidth);
    if not fLast then
    begin
      pCanva.MoveTo(nColX, Rect.Top);
      pCanva.LineTo(nColX, Rect.Bottom);
    end;
  end;
end;

procedure TfmMfClassicDlg.cbCfgTrailAccSelect(Sender: TObject);
var
  nIdx: Integer;
begin
  nIdx := cbCfgTrailAcc.ItemIndex;
  if nIdx <> -1 then
    SetSectorAreaAccess(m_nSectorIdx, 3, kAccessBits[nIdx]);
end;

function TfmMfClassicDlg.ColToByteIdx(ACol: Integer): Integer;
begin
  Result := ACol - gridBytes.FixedCols;
end;

procedure TfmMfClassicDlg.DoMfDecrement;
var
  nBlockIdx, nSectorIdx: Integer;
  nValue: Cardinal;
  pSI: PMfSectorInfo;
  fOk: Boolean;
begin
  nBlockIdx := RowToBlockIdx(m_nRow);

  nSectorIdx := GetMfSectorByBlock(nBlockIdx);
  pSI := @m_aSectors[nSectorIdx];
  if pSI.m_nRdKeyIdx <> -1 then
    fOk := m_iReader.AuthMfCardByRdKeys(nBlockIdx, pSI.m_fKeyB,
      1 shl pSI.m_nRdKeyIdx) <> -1
  else
  begin
    m_iReader.LoadMfAuthKey(pSI.m_nAuthKey);
    fOk := m_iReader.AuthMfCard(nBlockIdx, pSI.m_fKeyB);
  end;
  if fOk then
  begin
    nValue := edtMfValue.Value;
    m_iReader.MfDecrement(nBlockIdx, nValue);
    m_iReader.ReadMfClassic(nBlockIdx, @m_aOldBlocks[nBlockIdx], 1);
    m_aNewBlocks[nBlockIdx] := m_aOldBlocks[nBlockIdx];
    UpdateGridRow(BlockIdxToRow(nBlockIdx));
  end
  else
    MessageDlg(format(SEAuthorizeSector_D, [nSectorIdx]), mtError, [mbOk], 0);
end;

procedure TfmMfClassicDlg.DoMfIncrement;
var
  nBlockIdx, nSectorIdx: Integer;
  nValue: Cardinal;
  pSI: PMfSectorInfo;
  fOk: Boolean;
begin
  nBlockIdx := RowToBlockIdx(m_nRow);

  nSectorIdx := GetMfSectorByBlock(nBlockIdx);
  pSI := @m_aSectors[nSectorIdx];
  if pSI.m_nRdKeyIdx <> -1 then
    fOk := m_iReader.AuthMfCardByRdKeys(nBlockIdx, pSI.m_fKeyB,
      1 shl pSI.m_nRdKeyIdx) <> -1
  else
  begin
    m_iReader.LoadMfAuthKey(pSI.m_nAuthKey);
    fOk := m_iReader.AuthMfCard(nBlockIdx, pSI.m_fKeyB);
  end;
  if fOk then
  begin
    nValue := edtMfValue.Value;
    m_iReader.MfIncrement(nBlockIdx, nValue);
    m_iReader.ReadMfClassic(nBlockIdx, @m_aOldBlocks[nBlockIdx], 1);
    m_aNewBlocks[nBlockIdx] := m_aOldBlocks[nBlockIdx];
    UpdateGridRow(BlockIdxToRow(nBlockIdx));
  end
  else
    MessageDlg(format(SEAuthorizeSector_D, [nSectorIdx]), mtError, [mbOk], 0);
end;

procedure TfmMfClassicDlg.DoMfRestore;
var
  nBlockIdx, nSectorIdx: Integer;
  pSI: PMfSectorInfo;
  fOk: Boolean;
begin
  nBlockIdx := RowToBlockIdx(m_nRow);

  nSectorIdx := GetMfSectorByBlock(nBlockIdx);
  pSI := @m_aSectors[nSectorIdx];
  if pSI.m_nRdKeyIdx <> -1 then
    fOk := m_iReader.AuthMfCardByRdKeys(nBlockIdx, pSI.m_fKeyB,
      1 shl pSI.m_nRdKeyIdx) <> -1
  else
  begin
    m_iReader.LoadMfAuthKey(pSI.m_nAuthKey);
    fOk := m_iReader.AuthMfCard(nBlockIdx, pSI.m_fKeyB);
  end;
  if fOk then
  begin
    m_iReader.MfRestore(nBlockIdx);
    m_iReader.ReadMfClassic(nBlockIdx, @m_aOldBlocks[nBlockIdx], 1);
    m_aNewBlocks[nBlockIdx] := m_aOldBlocks[nBlockIdx];
    UpdateGridRow(BlockIdxToRow(nBlockIdx));
  end
  else
    MessageDlg(format(SEAuthorizeSector_D, [nSectorIdx]), mtError, [mbOk], 0);
end;

procedure TfmMfClassicDlg.DoMfTransfer;
var
  nBlockIdx, nSectorIdx: Integer;
  pSI: PMfSectorInfo;
  fOk: Boolean;
begin
  nBlockIdx := RowToBlockIdx(m_nRow);

  nSectorIdx := GetMfSectorByBlock(nBlockIdx);
  pSI := @m_aSectors[nSectorIdx];
  if pSI.m_nRdKeyIdx <> -1 then
    fOk := m_iReader.AuthMfCardByRdKeys(nBlockIdx, pSI.m_fKeyB,
      1 shl pSI.m_nRdKeyIdx) <> -1
  else
  begin
    m_iReader.LoadMfAuthKey(pSI.m_nAuthKey);
    fOk := m_iReader.AuthMfCard(nBlockIdx, pSI.m_fKeyB);
  end;
  if fOk then
  begin
    m_iReader.MfTransfer(nBlockIdx);
    m_iReader.ReadMfClassic(nBlockIdx, @m_aOldBlocks[nBlockIdx], 1);
    m_aNewBlocks[nBlockIdx] := m_aOldBlocks[nBlockIdx];
    UpdateGridRow(BlockIdxToRow(nBlockIdx));
  end
  else
    MessageDlg(format(SEAuthorizeSector_D, [nSectorIdx]), mtError, [mbOk], 0);
end;

function TfmMfClassicDlg.DownEditCell: Boolean;
var
  oGrid: TStringGrid;
  I, nBlockIdx, nByteIdx, nRow: Integer;
begin
  oGrid := gridBytes;
  nByteIdx := ColToByteIdx(m_nCol);
  nRow := m_nRow;
  for I := 0 to oGrid.RowCount - oGrid.FixedRows - 1 do
  begin
    if nRow < (oGrid.RowCount - 1) then
      Inc(nRow)
    else
      nRow := oGrid.FixedRows;
    nBlockIdx := RowToBlockIdx(nRow);
    if not IsReadOnlyByte(nBlockIdx, nByteIdx) then
    begin
      oGrid.Col := m_nCol;
      oGrid.Row := nRow;
      case GetCellFormat(m_nCol, m_nRow) of
        cfBin: m_nCellCharIdx := 8;
        cfDec: m_nCellCharIdx := 3;
        else m_nCellCharIdx := 2;
      end;
      oGrid.Invalidate;
      Exit(True);
    end;
  end;
  Result := False;
end;

procedure TfmMfClassicDlg.DrawCfgAreaComboBoxItem(ACb: TComboBox; AIdx: Integer;
  ARect: TRect);
var
  pCanva: TCanvas;
  sLine, S: String;
  I, nColX, nColWidth, nPos, X, Y: Integer;
  fLast: Boolean;
begin
  pCanva := ACb.Canvas;
  pCanva.Brush.Color := ACb.Color;
  pCanva.Font := ACb.Font;
  pCanva.FillRect(ARect);
  sLine := ACb.Items[AIdx];
  nColX := 0;
  nPos := 1;
  for I := 0 to kDataAccessCols - 1 do
  begin
    nColWidth := kDataAccessColWs[I];
    fLast := (I = (kDataAccessCols - 1));
    S := TextToChar(sLine, ';', nPos);
    if fLast then
      X := nColX + 4
    else
      X := nColX + (nColWidth - pCanva.TextWidth(S)) div 2;
    Y := (ARect.Bottom + ARect.Top - pCanva.TextHeight(S)) div 2;
    pCanva.TextOut(X, Y, S);
    Inc(nColX, nColWidth);
    if not fLast then
    begin
      pCanva.MoveTo(nColX, ARect.Top);
      pCanva.LineTo(nColX, ARect.Bottom);
    end;
  end;
end;

procedure TfmMfClassicDlg.edtCfgKeyAChange(Sender: TObject);
var
  nKey: TMfClassicKey;
begin
  if TryStrToMfClassicKey(edtCfgKeyA.Text, nKey) then
    SetSectorKey(m_nSectorIdx, False, nKey)
end;

procedure TfmMfClassicDlg.edtCfgKeyBChange(Sender: TObject);
var
  nKey: TMfClassicKey;
begin
  if TryStrToMfClassicKey(edtCfgKeyB.Text, nKey) then
    SetSectorKey(m_nSectorIdx, True, nKey)
end;

procedure TfmMfClassicDlg.EnableEditMode(AEnable: Boolean);
begin
  if m_fEditMode = AEnable then
    Exit;
  m_fEditMode := AEnable;
  if AEnable then
    m_nCellCharIdx := 1;
  gridBytes.Invalidate;
end;

procedure TfmMfClassicDlg.FormClose(Sender: TObject; var Action: TCloseAction);
var
  rWP: TWindowPlacement;
  rSize: TSize;
  f: Boolean;
begin
  UpdateAuthPanelData(True);

  FillChar(rWP, SizeOf(rWP), 0);
  rWP.length := SizeOf(rWP);
  GetWindowPlacement(Self.Handle, rWP);
  rSize := rWP.rcNormalPosition.Size;
  if g_AppSet.m_aWinSizes[swMfClassicDlg] <> rSize then
    g_AppSet.SetWinSize(swMfClassicDlg, rSize);

  g_AppSet.SetMcKeyB(m_fAuthKeyB);
  g_AppSet.SetMcAuthByRdKeys(m_fAuthByRdKeys);
  g_AppSet.SetMcAuthKey(m_nAuthKey);

  for f := False to True do
  begin
    if m_pSettings.m_aMcCheckRdKeys[f] <> m_aAuthRdKeys[f] then
    begin
      m_pSettings.m_aMcCheckRdKeys[f] := m_aAuthRdKeys[f];
      m_pSettings.m_fModified := True;
    end;
  end;
  if m_pSettings.m_fModified then
    m_pSettings.Save;
end;

procedure TfmMfClassicDlg.FormCreate(Sender: TObject);
var
  I, nCol: Integer;
  rSize: TSize;
begin
  HelpContext := HIDD_MFCLASSIC;
  m_nSectorIdx := -1;

  for I := 0 to pcAuth.PageCount - 1 do
    pcAuth.Pages[I].TabVisible := False;

  nCol := ByteIdxToCol(0);
  for I := 0 to 15 do
  begin
    gridBytes.Cells[nCol, 0] := IntToStr(I);
    Inc(nCol);
  end;
  gridBytes.Cells[0, 0] := SColBlock;
  gridBytes.Cells[1, 0] := SColSBlock;
  gridBytes.ColWidths[0] := 26;
  gridBytes.ColWidths[1] := 52;

  ImageList1.ResourceLoad(rtBitmap, 'rBtnDown', clWhite);

  m_fAuthKeyB := g_AppSet.m_fMcKeyB;
  m_fAuthByRdKeys := g_AppSet.m_fMcAuthByRdKeys;
  m_nAuthKey := g_AppSet.m_nMcAuthKey;

  pcAuth.ActivePageIndex := rgAuthKeySource.ItemIndex;
  m_nCol := gridBytes.FixedCols;
  m_nRow := gridBytes.FixedRows;

  rSize := g_AppSet.m_aWinSizes[swMfClassicDlg];
  if (rSize.cx <> 0) and (rSize.cy <> 0) then
  begin
    Width := rSize.cx;
    Height := rSize.cy;
  end;
end;

procedure TfmMfClassicDlg.FormShow(Sender: TObject);
var
  rCI: TCardInfo;
  nMaxBlocks: Integer;
  f: Boolean;
begin
  m_iReader.GetCardInfo(rCI);
  if not rCI.IsMfClassicMode then
    Close;
  m_rUId := rCI.rUID;
  Caption := format(' %s %s', [
        kCardTypeNames[rCI.nType],
        ILRCardUIDToStr(rCI.nType, rCI.rUID)]);
  nMaxBlocks := rCI.GetNumberOfMfBlocks;
  SetLength(m_aOldBlocks, nMaxBlocks);
  SetLength(m_aNewBlocks, nMaxBlocks);
  SetLength(m_aSectors, GetMfSectorByBlock(nMaxBlocks));
  m_nFirstBlockIdx := 0;
  m_nBlockCount := 4;
  m_nSectorIdx := 0;
  for f := False to True do
    m_aAuthRdKeys[f] := m_pSettings.m_aMcCheckRdKeys[f];

  UpdateAuthPanelData(False);
  UpdateGroupListBox;
  UpdateGrid;
  UpdateValueBlockGroup;
  UpdateSectorConfigPanel;
  rgDataFormat.ItemIndex := Integer(g_AppSet.m_nMcDataFormat);

  ReadGroup;
 end;

function TfmMfClassicDlg.GetCellFormat(ACol, ARow: Integer): TCellFormat;
begin
  Result := g_AppSet.m_nMcDataFormat;
end;

function TfmMfClassicDlg.GetSectorKey(ASectorIdx: Integer; AKeyB: Boolean;
  out VKey: TMfClassicKey): Boolean;
var
  pSI: PMfSectorInfo;
  nBlockIdx, nSBlockCount, nTrailerIdx: Integer;
begin
  pSI := @m_aSectors[m_nSectorIdx];
  nBlockIdx := GetMfBlockBySector(m_nSectorIdx);
  nSBlockCount := GetMfSectorBlockCount(m_nSectorIdx);
  nTrailerIdx := (nBlockIdx + nSBlockCount - 1);
  VKey := 0;
  if AKeyB then
    Move(m_aNewBlocks[nTrailerIdx].a[10], VKey, 6)
  else
    Move(m_aNewBlocks[nTrailerIdx].a[0], VKey, 6);
  Result := pSI.m_fAuthOk and pSI.m_aKeyInit[AKeyB];
end;

procedure TfmMfClassicDlg.gridBytesClick(Sender: TObject);
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

procedure TfmMfClassicDlg.gridBytesDblClick(Sender: TObject);
begin
  EnableEditMode;
end;

procedure TfmMfClassicDlg.gridBytesDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  oGrid: TStringGrid;
  pCanva: TCanvas;
  nBlockIdx, nByteIdx, nSectorIdx, nSBlockIdx, nSBlockCount, nArea: Integer;
  I, x, y, cx, cy, a, b, k: Integer;
  nAccessBits, nAreaAccess, nFlags, nChanges: Cardinal;
  pSI: PMfSectorInfo;
  S: string;
  rc: TRect;
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
    pCanva.TextRect(Rect, S, [tfSingleLine, tfCenter, tfVerticalCenter]);
  end
  else
  begin
    pCanva.Brush.Color := oGrid.Color;
    GetMfBlockInfo(nBlockIdx, nSectorIdx, nSBlockIdx, nSBlockCount);
    pSI := @m_aSectors[nSectorIdx];

    // Если сектор авторизован,
    if pSI.m_fAuthOk then
    begin
      nArea := (nSBlockIdx * 3) div (nSBlockCount - 1);
      nAccessBits := GetMfAccessBits(m_aOldBlocks[nBlockIdx - nSBlockIdx + nSBlockCount - 1]);
      nAreaAccess := GetMfAreaAccess(nAccessBits, nArea);

      if nSBlockIdx = (nSBlockCount - 1) then // Если блок-прицеп
      begin
        if nByteIdx = 9 then
          pCanva.Brush.Color := shLegData.Brush.Color
        else
        begin
          case nAreaAccess of
            0: // 0 0 0
            begin
//              Assert(not pSI.m_fKeyB); // Ключ Б не может служить для авторизации

              if nByteIdx < 6 then
                pCanva.Brush.Color := shLegKeyWO.Brush.Color
              else if nByteIdx < 10 then
                pCanva.Brush.Color := shLegAccessRO.Brush.Color
              else
                pCanva.Brush.Color := shLegData.Brush.Color;
            end;

            2: // 0 1 0
            begin
//              Assert(not pSI.m_fKeyB); // Ключ Б не может служить для авторизации

              if nByteIdx < 6 then
                pCanva.Brush.Color := shLegKeyNRW.Brush.Color
              else if nByteIdx < 10 then
                pCanva.Brush.Color := shLegAccessRO.Brush.Color
              else
                pCanva.Brush.Color := shLegDataRO.Brush.Color;
            end;

            1: // 1 0 0
              if nByteIdx < 6 then
              begin
                if pSI.m_fKeyB then
                  pCanva.Brush.Color := shLegKeyWO.Brush.Color
                else
                  pCanva.Brush.Color := shLegKeyNRW.Brush.Color;
              end
              else if nByteIdx < 10 then
                pCanva.Brush.Color := shLegAccessRO.Brush.Color
              else if pSI.m_fKeyB then
                pCanva.Brush.Color := shLegKeyWO.Brush.Color
              else
                pCanva.Brush.Color := shLegKeyNRW.Brush.Color;

            3: // 1 1 0
              if nByteIdx < 6 then
                pCanva.Brush.Color := shLegKeyNRW.Brush.Color
              else if nByteIdx < 10 then
                pCanva.Brush.Color := shLegAccessRO.Brush.Color
              else
                pCanva.Brush.Color := shLegKeyNRW.Brush.Color;

            4: // 0 0 1
            begin
//              Assert(not pSI.m_fKeyB); // Ключ Б не может служить для авторизации

              if nByteIdx < 6 then
                pCanva.Brush.Color := shLegKeyWO.Brush.Color
              else if nByteIdx < 10 then
                pCanva.Brush.Color := shLegAccess.Brush.Color
              else
                pCanva.Brush.Color := shLegData.Brush.Color;
            end;

            6: // 0 1 1
              if nByteIdx < 6 then
              begin
                if pSI.m_fKeyB then
                  pCanva.Brush.Color := shLegKeyWO.Brush.Color
                else
                  pCanva.Brush.Color := shLegKeyNRW.Brush.Color;
              end
              else if nByteIdx < 10 then
              begin
                if pSI.m_fKeyB then
                  pCanva.Brush.Color := shLegAccess.Brush.Color
                else
                  pCanva.Brush.Color := shLegAccessRO.Brush.Color;
              end
              else if pSI.m_fKeyB then
                pCanva.Brush.Color := shLegKeyWO.Brush.Color
              else
                pCanva.Brush.Color := shLegKeyNRW.Brush.Color;

            5: // 1 0 1
              if nByteIdx < 6 then
                pCanva.Brush.Color := shLegKeyNRW.Brush.Color
              else if nByteIdx < 10 then
              begin
                if pSI.m_fKeyB then
                  pCanva.Brush.Color := shLegAccess.Brush.Color
                else
                  pCanva.Brush.Color := shLegAccessRO.Brush.Color;
              end
              else
                pCanva.Brush.Color := shLegKeyNRW.Brush.Color;

            7: // 1 1 1
              if nByteIdx < 6 then
                pCanva.Brush.Color := shLegKeyNRW.Brush.Color
              else if nByteIdx < 10 then
                pCanva.Brush.Color := shLegAccessRO.Brush.Color
              else
                pCanva.Brush.Color := shLegKeyNRW.Brush.Color;
          end;
        end;
      end
      else // иначе - блок данных
      begin
        case nAreaAccess of
          0: // 0 0 0
            pCanva.Brush.Color := shLegData.Brush.Color;
          2: // 0 1 0
            pCanva.Brush.Color := shLegDataRO.Brush.Color;
          1: // 1 0 0
            if pSI.m_fKeyB then
              pCanva.Brush.Color := shLegData.Brush.Color
            else
              pCanva.Brush.Color := shLegDataRO.Brush.Color;
          3: // 1 1 0
            if pSI.m_fKeyB then
              pCanva.Brush.Color := shLegValue.Brush.Color
            else
              pCanva.Brush.Color := shLegValueDO.Brush.Color;
          4: // 0 0 1
            pCanva.Brush.Color := shLegValueDO.Brush.Color;
          6: // 0 1 1
            if pSI.m_fKeyB then
              pCanva.Brush.Color := shLegData.Brush.Color
            else
              pCanva.Brush.Color := shLegDataNRW.Brush.Color;
          5: // 1 0 1
            if pSI.m_fKeyB then
              pCanva.Brush.Color := shLegDataRO.Brush.Color
            else
              pCanva.Brush.Color := shLegDataNRW.Brush.Color;
          7: // 1 1 1
            pCanva.Brush.Color := shLegDataNRW.Brush.Color;
        end;
      end;
    end;
    // Если первый блок,
    if nBlockIdx = 0 then
    begin
      if nByteIdx < m_rUId.nLength then
        pCanva.Brush.Color := shLegSN.Brush.Color  // С/н карты
      else
        pCanva.Brush.Color := shLegDataRO.Brush.Color;
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
    if m_aNewBlocks[nBlockIdx].a[nByteIdx] <> m_aOldBlocks[nBlockIdx].a[nByteIdx] then
    begin
      a := m_aOldBlocks[nBlockIdx].a[nByteIdx];
      b := m_aNewBlocks[nBlockIdx].a[nByteIdx];
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

    // Если (блок-прицеп) и (это не первая строка данных),
    if (nSBlockIdx = (nSBlockCount - 1)) and (ARow <> oGrid.FixedRows) then
    begin
      // Рисуем разделительную линию между секторами
//      pCanva.Pen.Color := clBlack;
      pCanva.Pen.Width := 2;
      pCanva.MoveTo(Rect.Left, Rect.Top);
      pCanva.LineTo(Rect.Right, Rect.Top);
    end;
  end;
end;

procedure TfmMfClassicDlg.gridBytesKeyDown(Sender: TObject; var Key: Word;
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

    VK_UP:
      if m_fEditMode then
      begin
        Key := 0;
        UpEditCell;
      end;

    VK_DOWN:
      if m_fEditMode then
      begin
        Key := 0;
        DownEditCell;
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
          sOldValue := ByteToCellStr(m_aOldBlocks[nBlockIdx].a[nByteIdx], nFormat);
          sNewValue[m_nCellCharIdx] := sOldValue[m_nCellCharIdx];
          SetByte(nBlockIdx, nByteIdx, CellStrToByte(sNewValue, nFormat), False);
          oGrid.Cells[m_nCol, m_nRow] := sNewValue;
        end;
      end;
  end;
end;

procedure TfmMfClassicDlg.gridBytesKeyPress(Sender: TObject; var Key: Char);
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

procedure TfmMfClassicDlg.gridBytesSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
var
  fRowChanged: Boolean;
begin
  if CanSelect and ((m_nCol <> ACol) or (m_nRow <> ARow)) then
  begin
    fRowChanged := (m_nRow <> ARow);
    m_nCol := ACol;
    m_nRow := ARow;
    case GetCellFormat(m_nCol, m_nRow) of
      cfDec: if m_nCellCharIdx > 3 then m_nCellCharIdx := 3;
      cfHex: if m_nCellCharIdx > 2 then m_nCellCharIdx := 2;
    end;
    gridBytes.Invalidate;
    if fRowChanged then
      UpdateValueBlockGroup;
  end;
end;

function TfmMfClassicDlg.IsReadOnlyByte(ABlockIdx, AByteIdx: Integer): Boolean;
var
  nSectorIdx, nSBlockIdx, nSBlockCount, nArea: Integer;
  nAccess: Cardinal;
  fKeyB: Boolean;
begin
  if ABlockIdx = 0 then
    Exit(True);
  GetMfBlockInfo(ABlockIdx, nSectorIdx, nSBlockIdx, nSBlockCount);
  nArea := (nSBlockIdx * 3) div (nSBlockCount - 1);
  nAccess := GetMfAreaAccess(
    GetMfAccessBits(m_aOldBlocks[ABlockIdx - nSBlockIdx + nSBlockCount - 1]), nArea);
  fKeyB := m_aSectors[nSectorIdx].m_fKeyB;
  Result := False;
  // Если блок-прицеп,
  if nSBlockIdx = (nSBlockCount - 1) then
  begin
    case nAccess of
      0: // 0 0 0
        Result := fKeyB or (AByteIdx in [6..9]);
      2: // 0 1 0
        Result := True;
      1: // 1 0 0
        Result := (not fKeyB) or (AByteIdx in [6..9]);
      3: // 1 1 0
        Result := True;
      4: // 0 0 1
        Result := fKeyB;
      6: // 0 1 1
        Result := (not fKeyB);
      5: // 1 0 1
        Result := (not fKeyB) or (not (AByteIdx in [6..9]));
      7: // 1 1 1
        Result := True;
    end;
  end
  else
  begin
    case nAccess of
      0: // 0 0 0
        Result := False;
      2, // 0 1 0
      5, // 1 0 1
      7: // 1 1 1
        Result := True;
      1, // 1 0 0
      6: // 0 1 1
        Result := (not fKeyB);
      3: // 1 1 0
        Result := (not fKeyB);
      4: // 0 0 1
        Result := True;
    end;
  end;
end;

function TfmMfClassicDlg.IsValidByteValue(ABlockIdx, AByteIdx: Integer;
  AValue: Byte): Boolean;
var
  nSectorIdx, nSBlockIdx, nSBlockCount: Integer;
begin
  if ABlockIdx = 0 then
    Result := (m_aOldBlocks[ABlockIdx].a[AByteIdx] = AValue)
  else
  begin
    GetMfBlockInfo(ABlockIdx, nSectorIdx, nSBlockIdx, nSBlockCount);
    // Если блок-прицеп,
    if (nSBlockIdx = (nSBlockCount - 1)) and (AByteIdx <> 9) then
      Exit(m_aOldBlocks[ABlockIdx].a[AByteIdx] = AValue);
    Result := True;
  end;
end;

function TfmMfClassicDlg.KeyToStr(const AKey: TMfClassicKey): string;
begin
  Result := IntToHex(AKey, 12);
end;

procedure TfmMfClassicDlg.lbAuthRdKeysClickCheck(Sender: TObject);
var
  lb: TCheckListBox;
  I: Integer;
  nRdKeys: Cardinal;
begin
  lb := Sender as TCheckListBox;
  nRdKeys := 0;
  for I := 0 to lb.Count - 1 do
    if lb.Checked[I] then
      SetBit(nRdKeys, I);

  if m_aAuthRdKeys[m_fAuthKeyB] <> nRdKeys then
    m_aAuthRdKeys[m_fAuthKeyB] := nRdKeys;
end;

procedure TfmMfClassicDlg.lbGroupsClick(Sender: TObject);
var
  I, nIdx, nCount, nBlockIdx, nBlockCount, nSectorIdx, N: Integer;
  fNeedRead: Boolean;
begin
  nIdx := lbGroups.ItemIndex;
  nCount := lbGroups.Count;

  if nIdx = (nCount - 1) then
  begin
    // All
    nBlockIdx := 0;
    nBlockCount := Length(m_aNewBlocks);
  end
  else
  begin
    if Length(m_aNewBlocks) > 128 then
    begin
      if nIdx = (nCount - 2) then
      begin
        // Large
        nBlockIdx := 128;
        nBlockCount := (Length(m_aNewBlocks) - nBlockIdx);
      end
      else if nIdx = (nCount - 3) then
      begin
        // Small
        nBlockIdx := 0;
        nBlockCount := min(Length(m_aNewBlocks), 128);
      end
      else
      begin
        nBlockIdx := GetMfBlockBySector(nIdx);
        nBlockCount := GetMfSectorBlockCount(nIdx);
      end;
    end
    else
    begin
      nBlockIdx := GetMfBlockBySector(nIdx);
      nBlockCount := GetMfSectorBlockCount(nIdx);
    end;
  end;

  if (m_nFirstBlockIdx <> nBlockIdx) or (m_nBlockCount <> nBlockCount) then
  begin
    m_nFirstBlockIdx := nBlockIdx;
    m_nBlockCount := nBlockCount;

    fNeedRead := False;
    nSectorIdx := GetMfSectorByBlock(nBlockIdx);
    N := GetMfSectorByBlock(nBlockIdx + nBlockCount) - nSectorIdx;
    for I := nSectorIdx to nSectorIdx + N - 1 do
      if not m_aSectors[I].m_fReadDataOk then
      begin
        fNeedRead := True;
        break;
      end;

    if fNeedRead then
      ReadCardData(nSectorIdx, N)
    else
      UpdateGrid;
    nSectorIdx := GetMfSectorByBlock(RowToBlockIdx(m_nRow));
    if m_nSectorIdx <> nSectorIdx then
    begin
      m_nSectorIdx := nSectorIdx;
      UpdateValueBlockGroup;
      UpdateSectorConfigPanel;
    end;
  end;
end;

procedure TfmMfClassicDlg.lbRdKeysClickCheck(Sender: TObject);
var
  lb: TCheckListBox;
  I: Integer;
  nRdKeys: Cardinal;
begin
  lb := Sender as TCheckListBox;
  nRdKeys := 0;
  for I := 0 to lb.Count - 1 do
    if lb.Checked[I] then
      SetBit(nRdKeys, I);

  if m_aAuthRdKeys[m_fAuthKeyB] <> nRdKeys then
  begin
    m_aAuthRdKeys[m_fAuthKeyB] := nRdKeys;
    UpdateAuthRdKeysCheckListBox;
  end;
end;

procedure TfmMfClassicDlg.lbRdKeysExit(Sender: TObject);
begin
  lbRdKeys.Visible := False;
end;

procedure TfmMfClassicDlg.lbRdKeysKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE,
    VK_RETURN:
      lbRdKeys.Visible := False;
  end;
end;

procedure TfmMfClassicDlg.miAuthRdKeysCheckAllClick(Sender: TObject);
var
  nRdKeys: Cardinal;
begin
  nRdKeys := $FFFF;
  if m_aAuthRdKeys[m_fAuthKeyB] <> nRdKeys then
  begin
    m_aAuthRdKeys[m_fAuthKeyB] := nRdKeys;
    UpdateAuthRdKeysCheckListBox;
    if lbRdKeys.Visible then
      UpdateRdKeysListBoxChecks;
  end;
end;

procedure TfmMfClassicDlg.miAuthRdKeysUncheckAllClick(Sender: TObject);
var
  nRdKeys: Cardinal;
begin
  nRdKeys := 0;
  if m_aAuthRdKeys[m_fAuthKeyB] <> nRdKeys then
  begin
    m_aAuthRdKeys[m_fAuthKeyB] := nRdKeys;
    UpdateAuthRdKeysCheckListBox;
    if lbRdKeys.Visible then
      UpdateRdKeysListBoxChecks;
  end;
end;

procedure TfmMfClassicDlg.miKeyXClick(Sender: TObject);
var
  nListKind: TKeyListKind;
  mi: TMenuItem;
  nIdx: Integer;
  nKey: TMfClassicKey;
begin
  mi := (Sender as TMenuItem);
  nListKind := TKeyListKind(mi.Owner.Tag);
  nIdx := mi.Tag;
  nKey := g_AppSet.m_oMcKeys[nIdx].m_nKey;
  case nListKind of
    klAuthKey:
    begin
      m_nAuthKey := nKey;
      edtAuthKey.Text := KeyToStr(m_nAuthKey);
    end;

    klKeyA:
      SetSectorKey(m_nSectorIdx, False, nKey);

    klKeyB:
      SetSectorKey(m_nSectorIdx, True, nKey);
  end;
end;

procedure TfmMfClassicDlg.miRdKeyXClick(Sender: TObject);
var
  nListKind: TKeyListKind;
  mi: TMenuItem;
  nIdx: Integer;
  fKeyB: Boolean;
  nKey: TMfClassicKey;
begin
  mi := (Sender as TMenuItem);
  nListKind := TKeyListKind(mi.Owner.Tag);
  nIdx := mi.Tag;
  fKeyB := (nListKind = TKeyListKind.klKeyB);
  nKey := m_pSettings.m_aMcRdKeys[fKeyB, nIdx].m_nKey;
  case nListKind of
    klKeyA:
      SetSectorKey(m_nSectorIdx, False, nKey);

    klKeyB:
      SetSectorKey(m_nSectorIdx, True, nKey);
  end;
end;

procedure TfmMfClassicDlg.miReadAllClick(Sender: TObject);
begin
  ReadCardData;
end;

procedure TfmMfClassicDlg.miReadGroupClick(Sender: TObject);
begin
  ReadGroup;
end;

procedure TfmMfClassicDlg.miReadSectorClick(Sender: TObject);
begin
  ReadSector;
end;

procedure TfmMfClassicDlg.miWriteAllClick(Sender: TObject);
begin
  WriteCardData;
end;

procedure TfmMfClassicDlg.miWriteGroupClick(Sender: TObject);
begin
  WriteGroup;
end;

procedure TfmMfClassicDlg.miWriteSectorClick(Sender: TObject);
begin
  WriteSector;
end;

function TfmMfClassicDlg.NextEditCell: Boolean;
var
  oGrid: TStringGrid;
  I, nCol, nRow, nBlockIdx, nByteIdx: Integer;
begin
  oGrid := gridBytes;
  nCol := m_nCol;
  nRow := m_nRow;
  // Цикл по всем ячейкам
  for I := 0 to (oGrid.RowCount - oGrid.FixedRows) * (oGrid.ColCount - oGrid.FixedCols) - 1 do
  begin
    if nCol < (oGrid.ColCount - 1) then
      Inc(nCol)
    else
    begin
      if nRow < (oGrid.RowCount - 1) then
        Inc(nRow)
      else
        nRow := oGrid.FixedRows;
      nCol := oGrid.FixedCols;
    end;
    nBlockIdx := RowToBlockIdx(nRow);
    nByteIdx := ColToByteIdx(nCol);
    if not IsReadOnlyByte(nBlockIdx, nByteIdx) then
    begin
      gridBytes.Col := nCol;
      gridBytes.Row := nRow;
      m_nCellCharIdx := 1;
      gridBytes.Invalidate;
      Exit(True);
    end;
  end;
  Result := False;
end;

function TfmMfClassicDlg.OpenMfClassicKeysDlg: Boolean;
var
  oDlg: TfmMfClassicKeysDlg;
begin
  UpdateAuthPanelData(True);
  oDlg := TfmMfClassicKeysDlg.Create(Self);
  try
    oDlg.PopupParent := Self;
    oDlg.m_nKeyIdx := g_AppSet.m_oMcKeys.IndexOfKey(m_nAuthKey);
    Result := (oDlg.ShowModal = mrOk);
    if (oDlg.m_nKeyIdx <> -1) and
      (oDlg.m_nKeyIdx < g_AppSet.m_oMcKeys.Count) and
      (m_nAuthKey <> g_AppSet.m_oMcKeys[oDlg.m_nKeyIdx].m_nKey) then
    begin
      m_nAuthKey := g_AppSet.m_oMcKeys[oDlg.m_nKeyIdx].m_nKey;
      UpdateAuthPanelData(False);
    end;
  finally
    oDlg.Free;
  end;
end;

procedure TfmMfClassicDlg.OpenMfReaderKeysDlg;
var
  oDlg: TfmMfReaderMcKeysDlg;
  f: Boolean;
begin
  for f := False to True do
  begin
    if m_pSettings.m_aMcCheckRdKeys[f] <> m_aAuthRdKeys[f] then
    begin
      m_pSettings.m_aMcCheckRdKeys[f] := m_aAuthRdKeys[f];
      m_pSettings.m_fModified := True;
    end;
  end;
  UpdateAuthPanelData(True);

  oDlg := TfmMfReaderMcKeysDlg.Create(Self);
  try
    oDlg.PopupParent := Self;
    oDlg.m_iReader := m_iReader;
    oDlg.m_pSettings := m_pSettings;
    oDlg.m_fKeyB := m_fAuthKeyB;
    oDlg.m_fCheckboxes := True;
    if oDlg.ShowModal <> mrOk then
      Exit;
    m_fAuthKeyB := oDlg.m_fKeyB;
    m_aAuthRdKeys[m_fAuthKeyB] := m_pSettings.m_aMcCheckRdKeys[m_fAuthKeyB];
  finally
    oDlg.Free;
  end;
  UpdateAuthPanelData(False);
end;

procedure TfmMfClassicDlg.pbCfgDataAccPaint(Sender: TObject);
var
  pb: TPaintBox;
  pCanva: TCanvas;
  I, nWidth, nHeight, nColX, nColWidth, nPos, N: Integer;
  rc: TRect;
  S, sCols: String;
  fLast: Boolean;
begin
  pb := (Sender as TPaintBox);
  pCanva := pb.Canvas;

  pCanva.Font := pb.Font;
  pCanva.Brush.Color := pb.Color;
  rc := pb.ClientRect;
  pCanva.Rectangle(rc);
  nWidth := (rc.Right - rc.Left);
  nHeight := (rc.Bottom - rc.Top);
  nColX := 0;
  sCols := SDataAccessCols;
  nPos := 1;
  S := string.Empty;
  for I := 0 to kDataAccessCols - 1 do
  begin
    nColWidth := kDataAccessColWs[i];
    fLast := (I = (kDataAccessCols - 1));
    if fLast then
      nColWidth := nWidth
    else
      Dec(nWidth, nColWidth);

    if nPos <> 0 then
      S := TextToChar(sCols, '|', nPos)
    else
      Assert(False);

    SetRect(rc, nColX, 0, nColX + nColWidth, nHeight);
    pCanva.TextRect(rc, S, [tfCalcRect, tfWordBreak]);
    N := (rc.Bottom - rc.Top);
    if rc.Bottom < nHeight then
    begin
      rc.Top := (nHeight - N) div 2;
      rc.Bottom := rc.Top + N;
    end;
    N := (rc.Right - rc.Left);
    if rc.Right < (nColX + nColWidth) then
    begin
      rc.Left := nColX + (nColWidth - N) div 2;
      rc.Right := rc.Left + N;
    end;
    pCanva.TextRect(rc, S, [tfWordBreak]);
    Inc(nColX, nColWidth);
    if not fLast then
    begin
      pCanva.MoveTo(nColX, 0);
      pCanva.LineTo(nColX, nHeight);
    end;
  end;
end;

procedure TfmMfClassicDlg.pbCfgTrailAccPaint(Sender: TObject);
var
  pb: TPaintBox;
  pCanva: TCanvas;
  I, nWidth, nHeight, nColX, nColWidth, nPos, N: Integer;
  rc: TRect;
  S, sCols: String;
  fLast: Boolean;
begin
  pb := (Sender as TPaintBox);
  pCanva := pb.Canvas;

  pCanva.Font := pb.Font;
  pCanva.Brush.Color := pb.Color;
  rc := pb.ClientRect;
  pCanva.Rectangle(rc);
  nWidth := rc.Width;
  nHeight := rc.Height;
  nColX := 0;
  sCols := STrailerAccessCols;
  nPos := 1;
  S := string.Empty;
  for I := 0 to kTrailerAccessCols - 1 do
  begin
    nColWidth := kTrailerAccessColWs[i];
    fLast := (i = (kTrailerAccessCols - 1));
    if fLast then
      nColWidth := nWidth
    else
      Dec(nWidth, nColWidth);
    if nPos <> 0 then
      S := TextToChar(sCols, '|', nPos)
    else
      Assert(False);
    SetRect(rc, nColX, 0, nColX + nColWidth, nHeight);
    pCanva.TextRect(rc, S, [tfCalcRect, tfWordBreak]);
    N := rc.Height;
    if rc.Bottom < nHeight then
    begin
      rc.Top := (nHeight - N) div 2;
      rc.Bottom := rc.Top + N;
    end;
    N := rc.Width;
    if rc.Right < (nColX + nColWidth) then
    begin
      rc.Left := nColX + (nColWidth - N) div 2;
      rc.Right := rc.Left + N;
    end;
    pCanva.TextRect(rc, S, [tfWordBreak]);
    Inc(nColX, nColWidth);
    if not fLast then
    begin
      pCanva.MoveTo(nColX, 0);
      pCanva.LineTo(nColX, nHeight);
    end;
  end;
end;

function TfmMfClassicDlg.PrevEditCell: Boolean;
var
  oGrid: TStringGrid;
  I, nCol, nRow, nBlockIdx, nByteIdx: Integer;
begin
  oGrid := gridBytes;
  nCol := m_nCol;
  nRow := m_nRow;
  // Цикл по всем ячейкам
  for I := 0 to (oGrid.RowCount - oGrid.FixedRows) * (oGrid.ColCount - oGrid.FixedCols) - 1 do
  begin
    if nCol > oGrid.FixedCols then
      Dec(nCol)
    else
    begin
      if nRow > oGrid.FixedRows then
        Dec(nRow)
      else
        nRow := (oGrid.RowCount - 1);
      nCol := (oGrid.ColCount - 1);
    end;
    nBlockIdx := RowToBlockIdx(nRow);
    nByteIdx := ColToByteIdx(nCol);
    if not IsReadOnlyByte(nBlockIdx, nByteIdx) then
    begin
      gridBytes.Col := nCol;
      gridBytes.Row := nRow;
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

procedure TfmMfClassicDlg.ReadCardData(ASectorIdx, ASectorCount: Integer);
begin
  UpdateAuthPanelData(True);

  ExecuteWithProgress(SReadingBlocks, procedure(ADlg: TfmProgressDlg)
  var
    I, J, nCurrent, nTotal, nBlockIdx, nSBlockCount, nTrailerIdx: Integer;
    nRead, c, nIdx: Integer;
    pSI: PMfSectorInfo;
    nStartTick, nSpan, nTrailerAccess: Cardinal;
  begin
    nCurrent := 0;
    nTotal := GetMfBlockBySector(ASectorIdx + ASectorCount) -
      GetMfBlockBySector(ASectorIdx);
    nStartTick := GetTickCount;
    // Цикл по секторам, которые нужно прочитать
    for I := ASectorIdx to ASectorIdx + ASectorCount - 1 do
    begin
      pSI := @m_aSectors[I];
      nSBlockCount := GetMfSectorBlockCount(I);

      // Если данные ещё не прочитаны,
      if not pSI.m_fReadDataOk then
      begin
        nBlockIdx := GetMfBlockBySector(I);

        pSI.m_aKeyInit[False] := False;
        pSI.m_aKeyInit[True] := False;
        pSI.m_fAuthOk := False;
        pSI.m_fKeyB := m_fAuthKeyB;
        if m_fAuthByRdKeys then
        begin
          if m_aAuthRdKeys[pSI.m_fKeyB] <> 0 then
          begin
            pSI.m_nRdKeyIdx := m_iReader.AuthMfCardByRdKeys(nBlockIdx,
              pSI.m_fKeyB, m_aAuthRdKeys[pSI.m_fKeyB]);
            pSI.m_fAuthOk := (pSI.m_nRdKeyIdx <> -1);
          end;
        end
        else
        begin
          pSI.m_nRdKeyIdx := -1;
          pSI.m_nAuthKey := m_nAuthKey;
          m_iReader.LoadMfAuthKey(pSI.m_nAuthKey);
          pSI.m_fAuthOk := m_iReader.AuthMfCard(nBlockIdx, pSI.m_fKeyB);
        end;

        // Если авторизация прошла успешно,
        if pSI.m_fAuthOk then
        begin
          pSI.m_nInitBlocks := 0;
          c := 0;
          repeat
            Application.ProcessMessages();
            if ADlg.m_fCancelled then
            begin
              ADlg.labDescription.Caption := SCancelled;
              Exit;
            end;
            nIdx := (nBlockIdx + c);
            try
              m_iReader.ReadMfClassic(nIdx,
                @m_aOldBlocks[nIdx], nSBlockCount - c, @nRead);
            except
              on e: Exception do
              begin
                ADlg.AddLog(format(SEReadBlock_DS, [
                  nBlockIdx + nRead, e.Message]));
                ADlg.SetErrorMode;
              end;
            end;
            if nRead > 0 then
            begin
              for J := c to c + nRead - 1 do
                SetBit(pSI.m_nInitBlocks, J);
              Move(m_aOldBlocks[nIdx], m_aNewBlocks[nIdx],
                SizeOf(TMfBlockData) * nRead);
            end;
            // Если удалось прочитать не все блоки,
            if nRead <> (nSBlockCount - c) then
              Inc(c); // Пропускаем следующий блок, который не удалось прочитать
            Inc(c, nRead);
          until c >= nSBlockCount;
          pSI.m_fReadDataOk := True;

          // Устанавливаем ключ в байты блока-прицепа
          // Если авторизация по ключу считывателя,
          nTrailerIdx := (nBlockIdx + nSBlockCount - 1);
          if pSI.m_nRdKeyIdx <> -1 then
            pSI.m_nAuthKey := m_pSettings.m_aMcRdKeys[pSI.m_fKeyB, pSI.m_nRdKeyIdx].m_nKey;
          if pSI.m_fKeyB then
            Move(pSI.m_nAuthKey, m_aOldBlocks[nTrailerIdx].a[10], 6)
          else
            Move(pSI.m_nAuthKey, m_aOldBlocks[nTrailerIdx].a[0], 6);
          m_aNewBlocks[nTrailerIdx] := m_aOldBlocks[nTrailerIdx];
          pSI.m_aKeyInit[pSI.m_fKeyB] := True;
          // Если авторизация по ключу А,
          if not pSI.m_fKeyB then
          begin
            nTrailerAccess := GetMfAreaAccess(
              GetMfAccessBits(m_aNewBlocks[nTrailerIdx]), 3);
            pSI.m_aKeyInit[True] := (nTrailerAccess in [
              0 {0 0 0}, 2 {0 1 0}, 4 {0 0 1}]); // Ключ Б может быть прочитан
          end;
        end
        else // иначе - не удалось авторизовать
        begin
          ADlg.AddLog(format(SEAuthorizeSector_D, [I]));
          ADlg.SetErrorMode;
        end;
      end;

      Inc(nCurrent, nSBlockCount);
      ADlg.SetProgress(nCurrent, nTotal);
      Application.ProcessMessages();
      if ADlg.m_fCancelled then
      begin
        ADlg.labDescription.Caption := SCancelled;
        Exit;
      end;
      Inc(nCurrent);
    end;
    nSpan := GetTickSpan(nStartTick, GetTickCount);
    ADlg.labDescription.Caption := format(SReadingBlocksCompleted_F, [nSpan / 1000.0]);
  end,
  Self);
  UpdateGrid;
  UpdateValueBlockGroup;
  UpdateSectorConfigPanel;
end;

procedure TfmMfClassicDlg.ReadGroup;
var
  I, nSectorIdx, nSectorCount: Integer;
begin
  // Перечитываем текущую группу секторов
  nSectorIdx := GetMfSectorByBlock(m_nFirstBlockIdx);
  nSectorCount := GetMfSectorByBlock(m_nFirstBlockIdx + m_nBlockCount) -
    nSectorIdx;
  for I := nSectorIdx to (nSectorIdx + nSectorCount - 1) do
    m_aSectors[I].m_fReadDataOk := False;
  ReadCardData(nSectorIdx, nSectorCount);
end;

procedure TfmMfClassicDlg.ReadSector;
var
  nSectorIdx: Integer;
begin
  // Перечитываем текущий сектор
  nSectorIdx := GetMfSectorByBlock(RowToBlockIdx(m_nRow));
  m_aSectors[nSectorIdx].m_fReadDataOk := False;
  ReadCardData(nSectorIdx, 1);
end;

procedure TfmMfClassicDlg.ReadCardData;
var
  I: Integer;
  pSI: PMfSectorInfo;
begin
  // Перечитываем все сектора
  for I := 0 to High(m_aSectors) do
  begin
    pSI := @m_aSectors[I];
    pSI.m_fAuthOk := False;
    pSI.m_fReadDataOk := False;
    pSI.m_nInitBlocks := 0;
  end;
  ReadCardData(0, Length(m_aSectors));
end;

procedure TfmMfClassicDlg.rgAuthKeyModeClick(Sender: TObject);
begin
  m_fAuthKeyB := (rgAuthKeyMode.ItemIndex = 1);
end;

procedure TfmMfClassicDlg.rgAuthKeySourceClick(Sender: TObject);
var
  fKeyB: Boolean;
begin
  fKeyB := (rgAuthKeySource.ItemIndex = 1);
  if m_fAuthByRdKeys <> fKeyB then
  begin
    m_fAuthByRdKeys := fKeyB;
    pcAuth.ActivePageIndex := rgAuthKeySource.ItemIndex;
  end;
end;

procedure TfmMfClassicDlg.rgDataFormatClick(Sender: TObject);
var
  nIdx: Integer;
begin
  nIdx := rgDataFormat.ItemIndex;
  if g_AppSet.m_nMcDataFormat <> TCellFormat(nIdx) then
  begin
    g_AppSet.SetMcDataFormat(TCellFormat(nIdx));
    m_nCellCharIdx := 1;
    UpdateGrid;
  end;
end;

function TfmMfClassicDlg.RowToBlockIdx(ARow: Integer): Integer;
begin
  Result := (m_nFirstBlockIdx + gridBytes.RowCount - 1 - ARow)
end;

procedure TfmMfClassicDlg.SetByte(ABlockIdx, AByteIdx: Integer; AValue: Byte;
  AUpdateGrid: Boolean);
var
  nSectorIdx, nSBlockIdx, nSBlockCount, nRow: Integer;
begin
  m_aNewBlocks[ABlockIdx].a[AByteIdx] := AValue;
  nRow := BlockIdxToRow(ABlockIdx);
  if AUpdateGrid then
    UpdateGridCell(ByteIdxToCol(AByteIdx), nRow);
  GetMfBlockInfo(ABlockIdx, nSectorIdx, nSBlockIdx, nSBlockCount);
  // Если это блок-прицеп,
  if (m_nSectorIdx = nSectorIdx) and (nSBlockIdx = (nSBlockCount - 1)) then
    UpdateSectorConfigPanel;
  if nRow = m_nRow then
    UpdateValueBlockGroup;
end;

procedure TfmMfClassicDlg.SetSectorAreaAccess(ASectorIdx, AAreaN: Integer;
  AAreaBits: Cardinal);
var
  nBlockIdx, nSBlockCount, nTrailerIdx, nRow: Integer;
  nAccessBits: Cardinal;
begin
  nBlockIdx := GetMfBlockBySector(ASectorIdx);
  nSBlockCount := GetMfSectorBlockCount(ASectorIdx);
  nTrailerIdx := (nBlockIdx + nSBlockCount - 1);
  nAccessBits := GetMfAccessBits(m_aNewBlocks[nTrailerIdx]);
  if GetMfAreaAccess(nAccessBits, AAreaN) = AAreaBits then
    Exit;
  SetMfAreaAccess(nAccessBits, AAreaN, AAreaBits);
  SetMfAccessBits(m_aNewBlocks[nTrailerIdx], nAccessBits);
  nRow := BlockIdxToRow(nTrailerIdx);
  UpdateGridRow(nRow);
  case AAreaN of
    0: cbCfgArea0.ItemIndex := kAccessIdxs[AAreaBits];
    1: cbCfgArea1.ItemIndex := kAccessIdxs[AAreaBits];
    2: cbCfgArea2.ItemIndex := kAccessIdxs[AAreaBits];
    3: cbCfgTrailAcc.ItemIndex := kAccessIdxs[AAreaBits];
  end;
end;

procedure TfmMfClassicDlg.SetSectorKey(ASectorIdx: Integer; AKeyB: Boolean;
  const AKey: TMfClassicKey);
var
  pSI: PMfSectorInfo;
  nBlockIdx, nSBlockCount, nTrailerIdx, nRow: Integer;
begin
  pSI := @m_aSectors[m_nSectorIdx];
  nBlockIdx := GetMfBlockBySector(ASectorIdx);
  nSBlockCount := GetMfSectorBlockCount(ASectorIdx);
  nTrailerIdx := (nBlockIdx + nSBlockCount - 1);
  if AKeyB then
  begin
    Move(AKey, m_aNewBlocks[nTrailerIdx].a[10], 6);
    edtCfgKeyB.Text := MfClassicKeyToStr(AKey);
  end
  else
  begin
    Move(AKey, m_aNewBlocks[nTrailerIdx].a[0], 6);
    edtCfgKeyA.Text := MfClassicKeyToStr(AKey);
  end;
  pSI.m_aKeyInit[AKeyB] := True;
  nRow := BlockIdxToRow(nTrailerIdx);
  if (nRow >= gridBytes.FixedRows) and (nRow < gridBytes.RowCount) then
    UpdateGridRow(nRow);
end;

procedure TfmMfClassicDlg.ShowKeysMenu(AListKind: TKeyListKind; X, Y: Integer;
  AKeyIdx: Integer);
var
  I: Integer;
  mi: TMenuItem;
begin
  menuKeys.Items.Clear;
  for I := 0 to g_AppSet.m_oMcKeys.Count - 1 do
  begin
    mi := TMenuItem.Create(menuKeys);
    mi.Caption := format('%2d - 0x%s', [
        1 + I, MfClassicKeyToStr(g_AppSet.m_oMcKeys[I].m_nKey)]);
    mi.Tag := I;
    mi.RadioItem := True;
    mi.Checked := (I = AKeyIdx);
    mi.OnClick := miKeyXClick;
    menuKeys.Items.Add(mi);
  end;
  menuKeys.Tag := NativeInt(AListKind);
  menuKeys.Popup(X, Y);
end;

procedure TfmMfClassicDlg.ShowRdKeysMenu(AListKind: TKeyListKind; X, Y,
  AKeyIdx: Integer);
var
  fKeyB, fValid: Boolean;
  I: Integer;
  mi: TMenuItem;
begin
  fKeyB := (AListKind = TKeyListKind.klKeyB);
  menuRdKeys.Items.Clear;
  for I := 0 to High(m_pSettings.m_aMcRdKeys[fKeyB]) do
  begin
    mi := TMenuItem.Create(menuRdKeys);
    fValid := GetBit(m_pSettings.m_aMcValidRdKeys[fKeyB], I);
    if fValid then
      mi.Caption := format('%2d - 0x%s', [
          1 + I, MfClassicKeyToStr(m_pSettings.m_aMcRdKeys[fKeyB, I].m_nKey)])
    else
      mi.Caption := format('%2d - ', [1 + I]);
    mi.Tag := I;
    mi.RadioItem := True;
    mi.Checked := (I = AKeyIdx);
    mi.Enabled := fValid;
    mi.OnClick := miRdKeyXClick;
    menuRdKeys.Items.Add(mi);
  end;
  menuRdKeys.Tag := NativeInt(AListKind);
  menuRdKeys.Popup(X, Y);
end;

procedure TfmMfClassicDlg.UpdateAuthPanelData(ASave: Boolean);
begin
  if ASave then
  begin
    m_fAuthKeyB := (rgAuthKeyMode.ItemIndex = 1);
    m_fAuthByRdKeys := (pcAuth.ActivePageIndex = 1);
    TryStrToMfClassicKey(edtAuthKey.Text, m_nAuthKey);
  end
  else
  begin
    if m_fAuthKeyB then
      rgAuthKeyMode.ItemIndex := 1
    else
      rgAuthKeyMode.ItemIndex := 0;
    edtAuthKey.Text := MfClassicKeyToStr(m_nAuthKey);
    if m_fAuthByRdKeys then
    begin
      rgAuthKeySource.ItemIndex := 1;
      pcAuth.ActivePageIndex := 1;
    end
    else
    begin
      rgAuthKeySource.ItemIndex := 0;
      pcAuth.ActivePageIndex := 0;
    end;
    UpdateAuthRdKeysCheckListBox;
  end;
end;

procedure TfmMfClassicDlg.UpdateAuthRdKeysCheckListBox;
var
  lb: TCheckListBox;
  I: Integer;
begin
  lb := lbAuthRdKeys;
  lb.Items.BeginUpdate();
  try
    for I := 0 to High(m_pSettings.m_aMcRdKeys[m_fAuthKeyB]) do
      lb.Checked[I] := GetBit(m_aAuthRdKeys[m_fAuthKeyB], I);
  finally
    lb.Items.EndUpdate();
  end;
end;

procedure TfmMfClassicDlg.UpdateRdKeysListBox;
var
  lb: TCheckListBox;
  I: Integer;
begin
  lb := lbRdKeys;
  lb.Items.BeginUpdate();
  try
    lb.Clear();
    for I := 0 to High(m_pSettings.m_aMcRdKeys[m_fAuthKeyB]) do
    begin
      if GetBit(m_pSettings.m_aMcValidRdKeys[m_fAuthKeyB], I) then
        lb.Items.Add(format('%2d - 0x%.12X', [
          I,
          m_pSettings.m_aMcRdKeys[m_fAuthKeyB, I].m_nKey]))
      else
        lb.Items.Add(format('%2d', [I]));
      lb.Checked[I] := GetBit(m_aAuthRdKeys[m_fAuthKeyB], I);
    end;
  finally
    lb.Items.EndUpdate();
  end;
end;

procedure TfmMfClassicDlg.UpdateRdKeysListBoxChecks;
var
  lb: TCheckListBox;
  I: Integer;
begin
  lb := lbRdKeys;
  lb.Items.BeginUpdate();
  try
    for I := 0 to lb.Count - 1 do
      lb.Checked[I] := GetBit(m_aAuthRdKeys[m_fAuthKeyB], I);
  finally
    lb.Items.EndUpdate();
  end;
end;

procedure TfmMfClassicDlg.UpdateGrid;
var
  oGrid: TStringGrid;
  nBlockIdx, nByteIdx, nCol, nRow: Integer;
  nSectorIdx, nSBlockIdx, nSBlockCount: Integer;
  nByte: Byte;
begin
  oGrid := gridBytes;

  oGrid.RowCount := (oGrid.FixedRows + m_nBlockCount);

  for nRow := oGrid.FixedRows to oGrid.RowCount - 1 do
  begin
    nBlockIdx := RowToBlockIdx(nRow);

    GetMfBlockInfo(nBlockIdx, nSectorIdx, nSBlockIdx, nSBlockCount);
    oGrid.Cells[0, nRow] := IntToStr(nBlockIdx);
    oGrid.Cells[1, nRow] := format('%d.%d', [nSectorIdx, nSBlockIdx]);

    nByteIdx := 0;
    for nCol := oGrid.FixedCols to oGrid.ColCount - 1 do
    begin
      nByte := m_aNewBlocks[nBlockIdx].a[nByteIdx];
      oGrid.Cells[nCol, nRow] := ByteToCellStr(nByte, GetCellFormat(nCol, nRow));
      Inc(nByteIdx);
    end;
  end;
  oGrid.Invalidate;
end;

procedure TfmMfClassicDlg.UpdateGridCell(ACol, ARow: Integer);
var
  nByte: Integer;
begin
  nByte := m_aNewBlocks[RowToBlockIdx(ARow)].a[ColToByteIdx(ACol)];
  gridBytes.Cells[ACol, ARow] := ByteToCellStr(nByte, GetCellFormat(ACol, ARow));
end;

procedure TfmMfClassicDlg.UpdateGridRow(ARow: Integer);
var
  oGrid: TStringGrid;
  nBlockIdx, nByteIdx, nCol: Integer;
  nByte: Byte;
begin
  oGrid := gridBytes;
  nBlockIdx := RowToBlockIdx(ARow);
  nByteIdx := 0;
  for nCol := oGrid.FixedCols to oGrid.ColCount - 1 do
  begin
    nByte := m_aNewBlocks[nBlockIdx].a[nByteIdx];
    oGrid.Cells[nCol, ARow] := ByteToCellStr(nByte, GetCellFormat(nCol, ARow));
    Inc(nByteIdx);
  end;
  oGrid.Invalidate;
end;

procedure TfmMfClassicDlg.UpdateGroupListBox;
var
  lb: TListBox;
  I, nSectorIdx, nSBlockCount, n: Integer;
begin
  lb := lbGroups;
  lb.Items.BeginUpdate();
  try
    lb.Clear();
    for I := 0 to High(m_aSectors) do
      lb.Items.Add(format(SSector_D, [I]));
    lb.Items.Add(SAll);
    if Length(m_aSectors) > 32 then
    begin
      lb.Items.Add(SSmallUnder32);
      lb.Items.Add(SBigFrom32);
    end;

    if m_nBlockCount = Length(m_aOldBlocks) then
      lb.ItemIndex := (lb.Count - 1) // All
    else
    begin
      GetMfBlockInfo(m_nFirstBlockIdx, nSectorIdx, n, nSBlockCount);
      if m_nBlockCount = nSBlockCount then
        lb.ItemIndex := nSectorIdx
      else if m_nFirstBlockIdx < 128 then
        lb.ItemIndex := (lb.Count - 3) // Small
      else
        lb.ItemIndex := (lb.Count - 2); // Large
    end;
  finally
    lb.Items.EndUpdate();
  end;
end;

procedure TfmMfClassicDlg.UpdateSectorConfigPanel;
var
  nBlockIdx, nSBlockIdx, nSBlockCount: Integer;
  pSI: PMfSectorInfo;
  pTrailerData: PMfBlockData;
  nAuthKey: TMfClassicKey;
  nAccessBits, nAreaAccess: Cardinal;
begin
  nBlockIdx := RowToBlockIdx(m_nRow);
  GetMfBlockInfo(nBlockIdx, m_nSectorIdx, nSBlockIdx, nSBlockCount);
  labCfgSect.Caption := format(SSector_D, [m_nSectorIdx]);
  pSI := @m_aSectors[m_nSectorIdx];
  if nBlockIdx < 128 then
  begin
    labCfgArea0.Caption := SBlock0;
    labCfgArea1.Caption := SBlock1;
    labCfgArea2.Caption := SBlock2;
  end
  else
  begin
    labCfgArea0.Caption := SBlock0_4;
    labCfgArea1.Caption := SBlock5_9;
    labCfgArea2.Caption := SBlock10_14;
  end;

  pTrailerData := @m_aNewBlocks[nBlockIdx - nSBlockIdx + nSBlockCount - 1];
  edtCfgKeyA.Enabled := pSI.m_fAuthOk;
  edtCfgKeyB.Enabled := pSI.m_fAuthOk;

  if pSI.m_aKeyInit[False] then
  begin
    nAuthKey := 0;
    Move(pTrailerData.a[0], nAuthKey, 6);
    edtCfgKeyA.Text := MfClassicKeyToStr(nAuthKey);
  end
  else
    edtCfgKeyA.Clear;

  if pSI.m_aKeyInit[True] then
  begin
    nAuthKey := 0;
    Move(pTrailerData.a[10], nAuthKey, 6);
    edtCfgKeyB.Text := MfClassicKeyToStr(nAuthKey);
  end
  else
    edtCfgKeyB.Clear;

  nAccessBits := GetMfAccessBits(pTrailerData^);
  nAreaAccess := GetMfAreaAccess(nAccessBits, 3);
  labCfgKeyBWarning.Visible := (nAreaAccess in [
    0 {0 0 0}, 2 {0 1 0}, 4 {0 0 1}]); // Ключ Б может быть прочитан
  cbCfgTrailAcc.ItemIndex := kAccessIdxs[nAreaAccess];

  nAreaAccess := GetMfAreaAccess(nAccessBits, 2);
  cbCfgArea2.ItemIndex := kAccessIdxs[nAreaAccess];
  nAreaAccess := GetMfAreaAccess(nAccessBits, 1);
  cbCfgArea1.ItemIndex := kAccessIdxs[nAreaAccess];
  nAreaAccess := GetMfAreaAccess(nAccessBits, 0);
  cbCfgArea0.ItemIndex := kAccessIdxs[nAreaAccess];
end;

procedure TfmMfClassicDlg.UpdateValueBlockGroup;
var
  nBlockIdx, nAreaIdx, nSBlockIdx, nSBlockCount: Integer;
  pTrailerData: PMfBlockData;
  fShowGroup: Boolean;
  nAccessBits, nAreaAccess: Cardinal;
begin
  nBlockIdx := RowToBlockIdx(m_nRow);
  nAreaIdx := GetMfAreaByBlockIdx(nBlockIdx);
  GetMfBlockInfo(nBlockIdx, m_nSectorIdx, nSBlockIdx, nSBlockCount);

  grValueBlock.Caption := format(SValueBlock_D, [nBlockIdx]);

  pTrailerData := @m_aNewBlocks[nBlockIdx - nSBlockIdx + nSBlockCount - 1];
  nAccessBits := GetMfAccessBits(pTrailerData^);
  nAreaAccess := GetMfAreaAccess(nAccessBits, nAreaIdx);
  fShowGroup := (nAreaIdx <> 3) and (nAreaAccess in [3{1 1 0}, 4 {0 0 1}]);
  if fShowGroup then
    btnMfIncrement.Enabled := (nAreaAccess = 3{1 1 0}) and
        m_aSectors[m_nSectorIdx].m_fKeyB;

  if grValueBlock.Visible <> fShowGroup then
  begin
    if fShowGroup then
      gridBytes.Height := gridBytes.Height - grValueBlock.Height
    else
      gridBytes.Height := gridBytes.Height + grValueBlock.Height;
    grValueBlock.Visible := fShowGroup;
  end;
end;

function TfmMfClassicDlg.UpEditCell: Boolean;
var
  oGrid: TStringGrid;
  I, nBlockIdx, nByteIdx, nRow: Integer;
begin
  oGrid := gridBytes;
  nByteIdx := ColToByteIdx(m_nCol);
  nRow := m_nRow;
  for I := 0 to oGrid.RowCount - oGrid.FixedRows - 1 do
  begin
    if nRow > oGrid.FixedRows then
      Dec(nRow)
    else
      nRow := (oGrid.RowCount - 1);
    nBlockIdx := RowToBlockIdx(nRow);
    if not IsReadOnlyByte(nBlockIdx, nByteIdx) then
    begin
      oGrid.Col := m_nCol;
      oGrid.Row := nRow;
      case GetCellFormat(m_nCol, m_nRow) of
        cfBin: m_nCellCharIdx := 8;
        cfDec: m_nCellCharIdx := 3;
        else m_nCellCharIdx := 2;
      end;
      oGrid.Invalidate;
      Exit(True);
    end;
  end;
  Result := False;
end;

procedure TfmMfClassicDlg.WriteCardData(ASectorIdx, ASectorCount: Integer);
begin
  UpdateAuthPanelData(True);

  ExecuteWithProgress(SWritingBlocks, procedure(ADlg: TfmProgressDlg)
  var
    I, J, nCurrent, nTotal, nBlockIdx, nSBlockCount, nIdx: Integer;
    pSI: PMfSectorInfo;
    nStartTick, nSpan, nChanged: Cardinal;
    fOk: Boolean;
  begin
    nCurrent := 0;
    nTotal := GetMfBlockBySector(ASectorIdx + ASectorCount) -
      GetMfBlockBySector(ASectorIdx);
    nStartTick := GetTickCount;
    // Цикл по секторам, которые нужно записать
    for I := ASectorIdx to ASectorIdx + ASectorCount - 1 do
    begin
      pSI := @m_aSectors[I];
      nBlockIdx := GetMfBlockBySector(I);
      nSBlockCount := GetMfSectorBlockCount(I);
      nChanged := 0;
      for J := 0 to nSBlockCount - 1 do
      begin
        if GetBit(pSI.m_nInitBlocks, J) and
          (m_aOldBlocks[nBlockIdx + J] <> m_aNewBlocks[nBlockIdx + J]) then
        begin
          SetBit(nChanged, J);
        end;
      end;
      if nChanged <> 0 then
      begin
        Assert(pSI.m_fAuthOk);

        if pSI.m_nRdKeyIdx <> -1 then
          fOk := m_iReader.AuthMfCardByRdKeys(nBlockIdx, pSI.m_fKeyB,
            1 shl pSI.m_nRdKeyIdx) <> -1
        else
        begin
          m_iReader.LoadMfAuthKey(pSI.m_nAuthKey);
          fOk := m_iReader.AuthMfCard(nBlockIdx, pSI.m_fKeyB);
        end;
        if fOk then
        begin
          for J := 0 to nSBlockCount - 2 do
          begin
            if GetBit(nChanged, J) then
            begin
              Application.ProcessMessages();
              if ADlg.m_fCancelled then
              begin
                ADlg.labDescription.Caption := SCancelled;
                Exit;
              end;
              nIdx := (nBlockIdx + J);
              try
                m_iReader.WriteMfClassic(nIdx, @m_aNewBlocks[nIdx], 1);
                m_aOldBlocks[nIdx] := m_aNewBlocks[nIdx];
              except
                on e: Exception do
                begin
                  ADlg.AddLog(format(SEWriteBlock_DS, [nIdx, e.Message]));
                  ADlg.SetErrorMode;
                end;
              end;
            end;
          end;
          // Если блок-прицеп изменён
          if GetBit(nChanged, nSBlockCount - 1) then
          begin
            // Если один из ключей аутентификации не введён,
            if not (pSI.m_aKeyInit[False] and pSI.m_aKeyInit[True]) then
            begin
              // Сообщаем о пропуске записи блока-прицепа
              ADlg.AddLog(format(SENoInitSectorKey_D, [I]));
              ADlg.m_fCloseAfter := False;
            end
            else
            begin
              Application.ProcessMessages();
              if ADlg.m_fCancelled then
              begin
                ADlg.labDescription.Caption := SCancelled;
                Exit;
              end;
              nIdx := (nBlockIdx + nSBlockCount - 1);
              try
                m_iReader.WriteMfClassic(nIdx, @m_aNewBlocks[nIdx], 1);
                m_aOldBlocks[nIdx] := m_aNewBlocks[nIdx];
              except
                on e: Exception do
                begin
                  ADlg.AddLog(format(SEWriteBlock_DS, [nIdx, e.Message]));
                  ADlg.SetErrorMode;
                end;
              end;
            end;
          end;
        end
        else
        begin
          ADlg.AddLog(format(SEAuthorizeSector_D, [I]));
          ADlg.SetErrorMode;
        end;
      end;

      Inc(nCurrent, nSBlockCount);
      ADlg.SetProgress(nCurrent, nTotal);
      Application.ProcessMessages();
      if ADlg.m_fCancelled then
      begin
        ADlg.labDescription.Caption := SCancelled;
        Exit;
      end;
      Inc(nCurrent);
    end;
    nSpan := GetTickSpan(nStartTick, GetTickCount);
    ADlg.labDescription.Caption := format(SWriteBlocksCompleted_F, [nSpan / 1000.0]);
  end,
  Self);
  UpdateGrid;
end;

procedure TfmMfClassicDlg.WriteGroup;
var
  nSectorIdx, nSectorCount: Integer;
begin
  // Пишем изменные блоки текущей группы секторов
  nSectorIdx := GetMfSectorByBlock(m_nFirstBlockIdx);
  nSectorCount := GetMfSectorByBlock(m_nFirstBlockIdx + m_nBlockCount) -
    nSectorIdx;
  WriteCardData(nSectorIdx, nSectorCount);
end;

procedure TfmMfClassicDlg.WriteSector;
var
  nSectorIdx: Integer;
begin
  // Пишем изменные блоки текущего сектора
  nSectorIdx := GetMfSectorByBlock(RowToBlockIdx(m_nRow));
  WriteCardData(nSectorIdx, 1);
end;

procedure TfmMfClassicDlg.WriteCardData;
begin
  WriteCardData(0, Length(m_aSectors));
end;

end.
