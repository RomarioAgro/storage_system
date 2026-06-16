unit ReaderDlg;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  IL.Readers, uConst;

const
  UM_ILREADER_NOTIFY = (WM_USER + 1);
type
  TfmReaderDlg = class(TForm)
    grConnectionStatus: TGroupBox;
    labConnectionStatus: TLabel;
    btnConnect: TButton;
    btnDisconnect: TButton;
    grCurrentCard: TGroupBox;
    btnRefresh: TButton;
    edtCurrentCard: TEdit;
    procedure FormShow(Sender: TObject);
    procedure btnConnectClick(Sender: TObject);
    procedure btnDisconnectClick(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }

    procedure UmILReader_Notify(var Msg: TMessage); message UM_ILREADER_NOTIFY;

  public
    { Public declarations }
    m_iReader       : IILReader;
    m_rCardInfo     : TCardInfo;

    procedure UpdateReaderInfo;
    procedure UpdateConnectionStatus;
    procedure UpdateCurrentCard;
  end;

var
  fmReaderDlg: TfmReaderDlg;


implementation

{$R *.dfm}

uses
  IL.RUtils, uAppHelp;


procedure ReaderNotifyCallback(AMsg: TReaderMsg; AMsgData, AUserData: Pointer); stdcall;
begin
  PostMessage(TfmReaderDlg(AUserData).Handle, UM_ILREADER_NOTIFY, 0, 0);
end;

procedure TfmReaderDlg.btnConnectClick(Sender: TObject);
begin
  m_iReader.Connect;
end;

procedure TfmReaderDlg.btnRefreshClick(Sender: TObject);
begin
  m_iReader.Scan(True);
end;

procedure TfmReaderDlg.btnDisconnectClick(Sender: TObject);
begin
  m_iReader.Disconnect;
end;

procedure TfmReaderDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  m_iReader.SetNotifyCallback(nil, nil);
  m_iReader.Disconnect;
end;

procedure TfmReaderDlg.FormCreate(Sender: TObject);
begin
  HelpContext := HIDD_READER;
end;

procedure TfmReaderDlg.FormShow(Sender: TObject);
begin
  m_iReader.EnableMsgQueue;
  m_iReader.SetNotifyCallback(ReaderNotifyCallback, Self);

  if m_iReader.GetConnectionStatus <> csConnected then
    m_iReader.Connect;
  UpdateReaderInfo;
  UpdateConnectionStatus;
  UpdateCurrentCard;
end;

procedure TfmReaderDlg.UmILReader_Notify(var Msg: TMessage);
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

procedure TfmReaderDlg.UpdateConnectionStatus;
var
  nStatus: TConnectionStatus;
begin
  nStatus := m_iReader.GetConnectionStatus;
  labConnectionStatus.Caption := LoadResString(kConnectionStatusNames[nStatus]);
end;

procedure TfmReaderDlg.UpdateCurrentCard;
var
  S: string;
begin
  m_iReader.GetCardInfo(m_rCardInfo);
  if m_rCardInfo.rUID.IsEmpty then
  begin
    edtCurrentCard.Text := SNoCard;
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
  end;
end;

procedure TfmReaderDlg.UpdateReaderInfo;
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
end;

end.
