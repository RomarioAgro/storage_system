unit TmcReaderDlg;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  IL.Readers, uConst, uTypes;

const
  UM_ILREADER_NOTIFY = (WM_USER + 1);
type
  TfmTmcReaderDlg = class(TForm)
    grConnectionStatus: TGroupBox;
    labConnectionStatus: TLabel;
    btnConnect: TButton;
    btnDisconnect: TButton;
    grCurrentCard: TGroupBox;
    btnRefresh: TButton;
    btnOpen: TButton;
    GroupBox1: TGroupBox;
    labScanParam: TLabel;
    cbScanParam: TComboBox;
    grPassword: TGroupBox;
    chkPassword: TCheckBox;
    cbPassword: TComboBox;
    btnPswList: TButton;
    btnScanTemic: TButton;
    btnInitTemic: TButton;
    chkAutoScanTemic: TCheckBox;
    edtCurrentCard: TEdit;
    procedure FormShow(Sender: TObject);
    procedure btnConnectClick(Sender: TObject);
    procedure btnDisconnectClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnRefreshClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure btnScanTemicClick(Sender: TObject);
    procedure chkAutoScanTemicClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cbPasswordSelect(Sender: TObject);
    procedure chkPasswordClick(Sender: TObject);
    procedure cbScanParamSelect(Sender: TObject);
    procedure cbScanParamChange(Sender: TObject);
    procedure btnPswListClick(Sender: TObject);
    procedure btnInitTemicClick(Sender: TObject);
  private
    { Private declarations }

    procedure UmILReader_Notify(var Msg: TMessage); message UM_ILREADER_NOTIFY;

  public
    { Public declarations }
    m_iReader       : IILReader;
    m_rCardInfo     : TCardInfo;
    m_fTmcAutoScan  : Boolean;
    m_nTmcScanParam : Integer;
    m_fTmcPswEnabled: Boolean;
    m_nTmcPassword  : Cardinal;

    procedure OpenTemic;
    procedure OpenMfUltralight;

    procedure UpdateReaderInfo;
    procedure UpdateConnectionStatus;
    procedure UpdateCurrentCard;
    procedure UpdatePasswordCombobox;
    // Открывает окно для редактирования списка паролей
    function DoEditPasswords: Boolean;
  end;

var
  fmTmcReaderDlg: TfmTmcReaderDlg;

implementation

{$R *.dfm}

uses
  System.UITypes,
  IL.RUtils, uAppSettings, uAppHelp,
  TemicDlg, MfUltralightDlg, TemicPasswordsDlg;

procedure ReaderNotifyCallback(AMsg: TReaderMsg; AMsgData, AUserData: Pointer); stdcall;
begin
  PostMessage(TfmTmcReaderDlg(AUserData).Handle, UM_ILREADER_NOTIFY, 0, 0);
end;

procedure TfmTmcReaderDlg.btnConnectClick(Sender: TObject);
begin
  m_iReader.Connect;
end;

procedure TfmTmcReaderDlg.btnDisconnectClick(Sender: TObject);
begin
  m_iReader.Disconnect;
end;

procedure TfmTmcReaderDlg.btnInitTemicClick(Sender: TObject);
var
  nConfig: Cardinal;
  nScanParam: Integer;
begin
  if MessageDlg(SConfirm, mtConfirmation, [mbOk, mbCancel], 0) <> mrOk then
    Exit;
  nConfig := $40801400;
  if m_nTmcScanParam <> -1 then
    nScanParam := m_nTmcScanParam
  else
    nScanParam := 2;
  m_iReader.WriteTemic(0, @nConfig, 1, False, nScanParam);
end;

procedure TfmTmcReaderDlg.btnOpenClick(Sender: TObject);
begin
  case m_rCardInfo.nType of
    cTemic:
      OpenTemic;

    cMifareUltraLight:
      OpenMfUltralight;
  end;
end;

procedure TfmTmcReaderDlg.btnPswListClick(Sender: TObject);
begin
  DoEditPasswords;
end;

procedure TfmTmcReaderDlg.btnRefreshClick(Sender: TObject);
begin
  m_iReader.Scan(True);
end;

procedure TfmTmcReaderDlg.btnScanTemicClick(Sender: TObject);
begin
  m_iReader.ScanTemic(m_nTmcScanParam);
end;

procedure TfmTmcReaderDlg.cbPasswordSelect(Sender: TObject);
var
  nIdx: Integer;
begin
  nIdx := cbPassword.ItemIndex;
  if nIdx = -1 then
    Exit;
  m_nTmcPassword := g_AppSet.m_oTmcPasswords[nIdx].m_nPassword;
  if m_fTmcPswEnabled then
    m_iReader.LoadTemicPassword(m_nTmcPassword)
  else
    m_iReader.LoadTemicPassword(-1);
end;

procedure TfmTmcReaderDlg.cbScanParamChange(Sender: TObject);
var
  nType, nSpeed: Integer;
begin
  if (sscanf(cbScanParam.Text, '%d %d', [@nType, @nSpeed]) = 2) and
    (nType >= 0) and (nSpeed >= 0) then
    m_nTmcScanParam := MakeWord(nType, nSpeed);
end;

procedure TfmTmcReaderDlg.cbScanParamSelect(Sender: TObject);
var
  nIdx: Integer;
begin
  nIdx := cbScanParam.ItemIndex;
  case nIdx of
    0: m_nTmcScanParam := -1;
    1: m_nTmcScanParam := MakeWord(2, 0);
    2: m_nTmcScanParam := MakeWord(1, 1);
    3: m_nTmcScanParam := MakeWord(2, 1);
    4: m_nTmcScanParam := MakeWord(1, 0);
    5: m_nTmcScanParam := MakeWord(3, 0);
    6: m_nTmcScanParam := MakeWord(4, 0);
  end;
end;

procedure TfmTmcReaderDlg.chkAutoScanTemicClick(Sender: TObject);
begin
  m_fTmcAutoScan := chkAutoScanTemic.Checked;
  m_iReader.EnableAutoScanTemic(m_fTmcAutoScan);
end;

procedure TfmTmcReaderDlg.chkPasswordClick(Sender: TObject);
var
  fEnabled: Boolean;
begin
  fEnabled := chkPassword.Checked;
  if m_fTmcPswEnabled <> fEnabled then
  begin
    m_fTmcPswEnabled := fEnabled;
    if m_fTmcPswEnabled then
      m_iReader.LoadTemicPassword(m_nTmcPassword)
    else
      m_iReader.LoadTemicPassword(-1);
  end;
end;

function TfmTmcReaderDlg.DoEditPasswords: Boolean;
var
  oDlg: TfmTemicPasswordsDlg;
  nPasswordIdx: Integer;
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
  if (nPasswordIdx <> -1) and
    (nPasswordIdx < g_AppSet.m_oTmcPasswords.Count) then
    m_nTmcPassword := g_AppSet.m_oTmcPasswords[nPasswordIdx].m_nPassword;
  UpdatePasswordCombobox;
  Result := True;
end;

procedure TfmTmcReaderDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  m_iReader.SetNotifyCallback(nil, nil);
  m_iReader.Disconnect;

  g_AppSet.SetTmcAutoScan(m_fTmcAutoScan);
  g_AppSet.SetTmcScanParam(m_nTmcScanParam);
  g_AppSet.SetTmcPswEnabled(m_fTmcPswEnabled);
  g_AppSet.SetTmcPassword(m_nTmcPassword);
end;

procedure TfmTmcReaderDlg.FormCreate(Sender: TObject);
begin
  HelpContext := HIDD_READER;
  m_fTmcAutoScan := g_AppSet.m_fTmcAutoScan;
  m_nTmcScanParam := g_AppSet.m_nTmcScanParam;
  m_fTmcPswEnabled := g_AppSet.m_fTmcPswEnabled;
  m_nTmcPassword := g_AppSet.m_nTmcPassword;
end;

procedure TfmTmcReaderDlg.FormShow(Sender: TObject);
begin
  m_iReader.EnableMsgQueue;
  m_iReader.SetNotifyCallback(ReaderNotifyCallback, Self);
  m_iReader.EnableAutoScanTemic(m_fTmcAutoScan);
  chkAutoScanTemic.Checked := m_fTmcAutoScan;
  UpdatePasswordCombobox;
  chkPassword.Checked := m_fTmcPswEnabled;
  if m_fTmcPswEnabled then
    m_iReader.LoadTemicPassword(m_nTmcPassword)
  else
    m_iReader.LoadTemicPassword(-1);
  case m_nTmcScanParam of
    -1: cbScanParam.ItemIndex := 0;
    2: cbScanParam.ItemIndex := 1;
    $0101: cbScanParam.ItemIndex := 2;
    $0102: cbScanParam.ItemIndex := 3;
    1: cbScanParam.ItemIndex := 4;
    3: cbScanParam.ItemIndex := 5;
    4: cbScanParam.ItemIndex := 6;
    else
      cbScanParam.Text := format('%u %u', [
        LoByte(m_nTmcScanParam), HiByte(m_nTmcScanParam)]);
  end;

  if m_iReader.GetConnectionStatus <> csConnected then
    m_iReader.Connect;
  UpdateReaderInfo;
  UpdateConnectionStatus;
  UpdateCurrentCard;
end;

procedure TfmTmcReaderDlg.OpenMfUltralight;
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

procedure TfmTmcReaderDlg.OpenTemic;
var
  oDlg: TfmTemicDlg;
begin
  // Временно выключаем сканирование Temic
  m_iReader.EnableAutoScanTemic(False);
  oDlg := TfmTemicDlg.Create(Self);
  try
    oDlg.PopupParent := Self;
    oDlg.m_iReader := m_iReader;
    if m_fTmcPswEnabled then
      oDlg.m_nCurrPassword := m_nTmcPassword;
    oDlg.ShowModal;

    if oDlg.m_nCurrPassword <> -1 then
      m_nTmcPassword := oDlg.m_nCurrPassword;
    m_fTmcPswEnabled := (oDlg.m_nCurrPassword <> -1);
    if oDlg.m_fPasswListChange then
      UpdatePasswordCombobox
    else
      cbPassword.ItemIndex := g_AppSet.m_oTmcPasswords.IndexOfPassword(m_nTmcPassword);
    chkPassword.Checked := m_fTmcPswEnabled;
  finally
    oDlg.Free;
    m_iReader.EnableAutoScanTemic(m_fTmcAutoScan);
  end;
end;

procedure TfmTmcReaderDlg.UmILReader_Notify(var Msg: TMessage);
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

procedure TfmTmcReaderDlg.UpdateConnectionStatus;
var
  nStatus: TConnectionStatus;
begin
  nStatus := m_iReader.GetConnectionStatus;
  labConnectionStatus.Caption := LoadResString(kConnectionStatusNames[nStatus]);
end;

procedure TfmTmcReaderDlg.UpdateCurrentCard;
var
  S: string;
begin
  m_iReader.GetCardInfo(m_rCardInfo);
  if m_rCardInfo.rUID.IsEmpty then
  begin
    edtCurrentCard.Text := SNoCard;
    btnOpen.Enabled := False;
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
    btnOpen.Enabled := (m_rCardInfo.nType in [cTemic, cMifareUltralight]);
  end;
end;

procedure TfmTmcReaderDlg.UpdatePasswordCombobox;
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
    oCB.ItemIndex := g_AppSet.m_oTmcPasswords.IndexOfPassword(m_nTmcPassword);
  finally
    oCB.Items.EndUpdate;
  end;
end;

procedure TfmTmcReaderDlg.UpdateReaderInfo;
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
  chkAutoScanTemic.Visible := rRI.nModel in [rmZ2RDALL, rmZ2EHR];
end;

end.
