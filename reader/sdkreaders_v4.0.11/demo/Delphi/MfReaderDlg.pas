unit MfReaderDlg;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  IL.Readers, uConst, uMfReaderSettings;

const
  UM_ILREADER_NOTIFY = (WM_USER + 1);
type
  TfmMfReaderDlg = class(TForm)
    grConnectionStatus: TGroupBox;
    labConnectionStatus: TLabel;
    btnConnect: TButton;
    btnDisconnect: TButton;
    grCurrentCard: TGroupBox;
    btnRefresh: TButton;
    btnOpen: TButton;
    btnClassicKeys: TButton;
    btnPlusKeys: TButton;
    btnChangeSL: TButton;
    edtCurrentCard: TEdit;
    procedure btnConnectClick(Sender: TObject);
    procedure btnDisconnectClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure btnClassicKeysClick(Sender: TObject);
    procedure btnPlusKeysClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure btnChangeSLClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    m_fCanRWMfClassic: Boolean; // True считыватель поддерживает чтение/запись карт Mifare Classic
    m_fCanRWMfPlus  : Boolean; // True считыватель поддерживает чтение/запись карт Mifare Plus SL3

    procedure UmILReader_Notify(var Msg: TMessage); message UM_ILREADER_NOTIFY;

  public
    { Public declarations }
    m_iReader       : IILReader;
    m_rCardInfo     : TCardInfo;
    m_oMfRdSet      : TMfReaderSettings; // Настройки считывателя Mifare

    procedure UpdateReaderInfo;
    procedure UpdateConnectionStatus;
    procedure UpdateCurrentCard;

    procedure OpenMfUltralight;
    procedure OpenMfClassic;
    procedure OpenMfPlusSL3;
    procedure OpenMfReaderMcKeysDlg;
    procedure OpenMfReaderMpKeysDlg;
    procedure OpenMfSecurityLevelDlg;
  end;

var
  fmMfReaderDlg: TfmMfReaderDlg;

implementation

{$R *.dfm}

uses
  IL.RUtils, uAppSettings, uAppHelp,
  MfUltralightDlg, MfClassicDlg, MfPlusSL3Dlg, MfReaderMcKeysDlg,
  MfReaderMpKeysDlg, MfSecurityLevelDlg;


procedure ReaderNotifyCallback(AMsg: TReaderMsg; AMsgData, AUserData: Pointer); stdcall;
begin
  PostMessage(TfmMfReaderDlg(AUserData).Handle, UM_ILREADER_NOTIFY, 0, 0);
end;

procedure TfmMfReaderDlg.btnChangeSLClick(Sender: TObject);
begin
  OpenMfSecurityLevelDlg;
end;

procedure TfmMfReaderDlg.btnClassicKeysClick(Sender: TObject);
begin
  OpenMfReaderMcKeysDlg;
end;

procedure TfmMfReaderDlg.btnConnectClick(Sender: TObject);
begin
  m_iReader.Connect;
end;

procedure TfmMfReaderDlg.btnDisconnectClick(Sender: TObject);
begin
  m_iReader.Disconnect;
end;

procedure TfmMfReaderDlg.btnOpenClick(Sender: TObject);
begin
  case m_rCardInfo.nType of
    cMifareUltraLight:
      OpenMfUltralight;

    cMifareMini,
    cMifare1K,
    cMifare2K,
    cMifare4K:
      OpenMfClassic;

    cMifarePlus1K,
    cMifarePlus2K,
    cMifarePlus4K,
    cSMXMifare1K,
    cSMXMifare4K:
      if m_rCardInfo.IsMfClassicMode then
        OpenMfClassic
      else if m_rCardInfo.IsMfPlusSL3Mode then
        OpenMfPlusSL3;
  end;
end;

procedure TfmMfReaderDlg.btnPlusKeysClick(Sender: TObject);
begin
  OpenMfReaderMpKeysDlg;
end;

procedure TfmMfReaderDlg.btnRefreshClick(Sender: TObject);
begin
  m_iReader.Scan(True);
end;

procedure TfmMfReaderDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  m_iReader.SetNotifyCallback(nil, nil);
  m_iReader.Disconnect;

  if (m_oMfRdSet <> nil) and m_oMfRdSet.m_fModified then
    m_oMfRdSet.Save;
end;

procedure TfmMfReaderDlg.FormCreate(Sender: TObject);
begin
  HelpContext := HIDD_READER;
end;

procedure TfmMfReaderDlg.FormDestroy(Sender: TObject);
begin
  m_oMfRdSet.Free;
end;

procedure TfmMfReaderDlg.FormShow(Sender: TObject);
begin
  m_iReader.EnableMsgQueue;
  m_iReader.SetNotifyCallback(ReaderNotifyCallback, Self);

  if m_iReader.GetConnectionStatus <> csConnected then
    m_iReader.Connect;
  UpdateReaderInfo;
  UpdateConnectionStatus;
  UpdateCurrentCard;
end;

procedure TfmMfReaderDlg.OpenMfClassic;
var
  oDlg: TfmMfClassicDlg;
  fAutoScan: Boolean;
begin
  Assert(m_oMfRdSet <> nil);

  fAutoScan := m_iReader.GetAutoScanEnabled;
  oDlg := TfmMfClassicDlg.Create(Self);
  try
    if fAutoScan then
      // Временно выключаем сканирование Mifare
      m_iReader.EnableAutoScan(False, False);
    oDlg.PopupParent := Self;
    oDlg.m_iReader := m_iReader;
    oDlg.m_pSettings := m_oMfRdSet;
    oDlg.ShowModal;
  finally
    oDlg.Free;
    if fAutoScan then
      m_iReader.EnableAutoScan(True, False);
  end;
end;

procedure TfmMfReaderDlg.OpenMfPlusSL3;
var
  oDlg: TfmMfPlusSL3Dlg;
  fAutoScan: Boolean;
begin
  Assert(m_oMfRdSet <> nil);

  fAutoScan := m_iReader.GetAutoScanEnabled;
  oDlg := TfmMfPlusSL3Dlg.Create(Self);
  try
    if fAutoScan then
      // Временно выключаем сканирование Mifare
      m_iReader.EnableAutoScan(False, False);
    oDlg.PopupParent := Self;
    oDlg.m_iReader := m_iReader;
    oDlg.m_pSettings := m_oMfRdSet;
    oDlg.ShowModal;
  finally
    oDlg.Free;
    if fAutoScan then
      m_iReader.EnableAutoScan(True, False);
  end;
end;

procedure TfmMfReaderDlg.OpenMfReaderMcKeysDlg;
var
  oDlg: TfmMfReaderMcKeysDlg;
begin
  oDlg := TfmMfReaderMcKeysDlg.Create(Self);
  try
    oDlg.PopupParent := Self;
    oDlg.m_iReader := m_iReader;
    oDlg.m_pSettings := m_oMfRdSet;
    oDlg.ShowModal;
  finally
    oDlg.Free;
  end;
end;

procedure TfmMfReaderDlg.OpenMfReaderMpKeysDlg;
var
  oDlg: TfmMfReaderMpKeysDlg;
begin
  oDlg := TfmMfReaderMpKeysDlg.Create(Self);
  try
    oDlg.PopupParent := Self;
    oDlg.m_iReader := m_iReader;
    oDlg.m_pSettings := m_oMfRdSet;
    oDlg.ShowModal;
  finally
    oDlg.Free;
  end;
end;

procedure TfmMfReaderDlg.OpenMfSecurityLevelDlg;
var
  oDlg: TfmMfSecurityLevelDlg;
begin
  oDlg := TfmMfSecurityLevelDlg.Create(Self);
  try
    oDlg.PopupParent := Self;
    oDlg.m_iReader := m_iReader;
    oDlg.ShowModal;
  finally
    oDlg.Free;
    m_iReader.SetNotifyCallback(ReaderNotifyCallback, Self);
  end;
end;

procedure TfmMfReaderDlg.OpenMfUltralight;
var
  oDlg: TfmMfUltralightDlg;
  fAutoScan: Boolean;
begin
  fAutoScan := m_iReader.GetAutoScanEnabled;
  oDlg := TfmMfUltralightDlg.Create(Self);
  try
    if fAutoScan then
      // Временно выключаем сканирование Mifare
      m_iReader.EnableAutoScan(False, False);
    oDlg.PopupParent := Self;
    oDlg.m_iReader := m_iReader;
    oDlg.ShowModal;
  finally
    oDlg.Free;
    if fAutoScan then
      m_iReader.EnableAutoScan(True, False);
  end;
end;

procedure TfmMfReaderDlg.UmILReader_Notify(var Msg: TMessage);
var
  nMsg: TReaderMsg;
  pMsgData: Pointer;
begin
  while m_iReader.GetMessage(nMsg, pMsgData) do
  begin
    case nMsg of
      rmConnectionChanged:
      begin
        UpdateConnectionStatus;
        if m_iReader.GetConnectionStatus = csConnected then
          UpdateReaderInfo;
      end;

      rmCardFound,
      rmCardLost:
        UpdateCurrentCard;
    end;
  end;
end;

procedure TfmMfReaderDlg.UpdateConnectionStatus;
var
  nStatus: TConnectionStatus;
begin
  nStatus := m_iReader.GetConnectionStatus;
  labConnectionStatus.Caption := LoadResString(kConnectionStatusNames[nStatus]);
end;

procedure TfmMfReaderDlg.UpdateCurrentCard;
var
  S: string;
begin
  m_iReader.GetCardInfo(m_rCardInfo);
  if m_rCardInfo.rUID.IsEmpty then
  begin
    edtCurrentCard.Text := SNoCard;
    btnOpen.Enabled := False;
    btnChangeSL.Enabled := False;
  end
  else
  begin
    S := format(' %s %s', [
          kCardTypeNames[m_rCardInfo.nType],
          ILRCardUIDToStr(m_rCardInfo.nType, m_rCardInfo.rUID)]);
    if m_rCardInfo.nMpType <> TMfPlusType.mptUnknown then
      S := S + ' ' + kMpTypeNames[m_rCardInfo.nMpType];
    if m_rCardInfo.nSL <> TMfPlusSL.mpslUnknown then
      S := S + format(' SL%d', [Integer(m_rCardInfo.nSL)]);

    if not m_rCardInfo.rUID2.IsEmpty then
      S := S + format(' (%s %s)', [
          kCardTypeNames[m_rCardInfo.nType2],
          ILRCardUIDToStr(m_rCardInfo.nType2, m_rCardInfo.rUID2)]);

    edtCurrentCard.Text := S;
    btnOpen.Enabled := ((m_rCardInfo.nType = cMifareUltralight) or
      (m_rCardInfo.IsMfClassicMode and m_fCanRWMfClassic) or
      (m_rCardInfo.IsMfPlusSL3Mode and m_fCanRWMfPlus)) and (m_rCardInfo.nType <> cMifarePlus);
    btnChangeSL.Enabled := m_rCardInfo.IsMfPlus and
      (m_rCardInfo.nSL in [mpslSL0, mpslSL1, mpslSL2]) and m_fCanRWMfPlus;
  end;
end;

procedure TfmMfReaderDlg.UpdateReaderInfo;
var
  rRI: TReaderInfo;
  S: string;
begin
  m_iReader.GetReaderInfo(rRI);
  S := format(' (%s): %s', [
    StrPas(rRI.szPortName),
    kRdModelNames[rRI.nModel]]);
  if rRI.nSn <> -1 then
    S := S + ' ' + format(SSn_D, [rRI.nSn]);
  if rRI.nFwVersion <> 0 then
    S := S + ' ' + format(SFW_S, [ILRVersionToStr(rRI.nFwVersion)]);
  if rRI.nFwBuildDate <> 0 then
    S := S + ' '  + format(SBuild_S, [ILRTimeToStr(rRI.nFwBuildDate)]);
  Caption := S;

  m_fCanRWMfClassic := (rRI.nModel in [
    rmZ2USBMF, rmZ2MFI, rmMatrix3Net, rmCPZ2MF, rmMatrix6, rmZ2MfCcid]);
  m_fCanRWMfPlus := (rRI.nModel in [rmZ2MFI, rmMatrix6]);
  btnClassicKeys.Visible := m_fCanRWMfClassic;
  btnPlusKeys.Visible := m_fCanRWMfPlus;
  if (m_fCanRWMfClassic or m_fCanRWMfPlus) and
    (m_oMfRdSet = nil) then
  begin
    m_oMfRdSet := TMfReaderSettings.Create();
    m_oMfRdSet.m_nReaderSn := rRI.nSn;
    m_oMfRdSet.Load;
  end;
end;

end.
