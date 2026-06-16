unit MfSecurityLevelDlg;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask,
  Vcl.ImgList,
  IL.Readers, Vcl.Menus;

const
  UM_ILREADER_NOTIFY = (WM_USER + 1);
type
  TfmMfSecurityLevelDlg = class(TForm)
    grSwitchSL1: TGroupBox;
    labMasterKey: TLabel;
    edtMasterKey: TMaskEdit;
    labConfigKey: TLabel;
    edtConfigKey: TMaskEdit;
    labL2SwitchKey: TLabel;
    edtL2SwitchKey: TMaskEdit;
    labL3SwitchKey: TLabel;
    edtL3SwitchKey: TMaskEdit;
    btnSwitchToSL1: TButton;
    grSwitchSL3: TGroupBox;
    labSL3SwitchKey2: TLabel;
    edtAuthL3SwitchKey: TMaskEdit;
    btnSwitchToSL3: TButton;
    btnMasterKey: TButton;
    btnMasterKeys: TButton;
    btnConfigKeys: TButton;
    btnConfigKey: TButton;
    btnSL2SwitchKeys: TButton;
    btnSL2SwitchKey: TButton;
    btnSL3SwitchKeys: TButton;
    btnSL3SwitchKey: TButton;
    btnAuthL3SwitchKeys: TButton;
    btnAuthL3SwitchKey: TButton;
    ImageList1: TImageList;
    menuKeys: TPopupMenu;
    grCurrentCard: TGroupBox;
    labCurrentCard: TLabel;
    btnCSRefresh: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnMasterKeysClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnCSRefreshClick(Sender: TObject);
    procedure btnMasterKeyClick(Sender: TObject);
    procedure btnConfigKeyClick(Sender: TObject);
    procedure btnSL2SwitchKeyClick(Sender: TObject);
    procedure btnSL3SwitchKeyClick(Sender: TObject);
    procedure btnAuthL3SwitchKeyClick(Sender: TObject);
    procedure btnConfigKeysClick(Sender: TObject);
    procedure btnSL2SwitchKeysClick(Sender: TObject);
    procedure btnSL3SwitchKeysClick(Sender: TObject);
    procedure btnAuthL3SwitchKeysClick(Sender: TObject);
    procedure btnSwitchToSL1Click(Sender: TObject);
    procedure btnSwitchToSL3Click(Sender: TObject);
  public type
    // Вид списка ключей
    TKeyKind = (
      kkMasterKey,
      kkConfigKey,
      kkL2SwitchKey,
      kkL3SwitchKey,
      kkAuthL3SwitchKey
    );
  private
    { Private declarations }
    procedure UmILReader_Notify(var Msg: TMessage); message UM_ILREADER_NOTIFY;

    procedure miKeyXClick(Sender: TObject);

  public
    { Public declarations }
    m_iReader       : IILReader;  // Интерфейс считывателя
    m_rMasterKey    : TMfPlusKey;
    m_rConfigKey    : TMfPlusKey;
    m_rL2SwitchKey  : TMfPlusKey;
    m_rL3SwitchKey  : TMfPlusKey;
    m_rAuthL3SwitchKey: TMfPlusKey;
    m_rCardInfo     : TCardInfo;

    procedure UpdateCurrentCard;
    // Открывает окно "Ключи Mifare Plus"
    function OpenMfPlusKeysDlg(AKeyKind: TKeyKind): Boolean;
    procedure UpdateCtrlData(ASave: Boolean);
    procedure UpdateCtrlState;
    // Показывает меню со списком ключей
    procedure ShowKeysMenu(AKeyKind: TKeyKind; X, Y: Integer;
      AKeyIdx: Integer);
    procedure DoSwitchToSL1;
    procedure DoSwitchToSL3;
  end;

var
  fmMfSecurityLevelDlg: TfmMfSecurityLevelDlg;

implementation

{$R *.dfm}

uses
  System.UITypes,
  IL.RUtils,
  MfPlusKeysDlg, uConst, uUtils, uAppSettings;

procedure ReaderNotifyCallback(AMsg: TReaderMsg; AMsgData, AUserData: Pointer); stdcall;
begin
  PostMessage(TfmMfSecurityLevelDlg(AUserData).Handle, UM_ILREADER_NOTIFY, 0, 0);
end;

procedure TfmMfSecurityLevelDlg.btnMasterKeyClick(Sender: TObject);
var
  pt: TPoint;
  nAuthKeyIdx: Integer;
begin
  if edtMasterKey.Modified then
  begin
    TryStrToMfPlusKey(edtMasterKey.Text, m_rMasterKey);
    edtMasterKey.Modified := False;
  end;
  nAuthKeyIdx := g_AppSet.m_oMpKeys.IndexOfKey(m_rMasterKey);

  pt := edtMasterKey.BoundsRect.TopLeft;
  Inc(pt.Y, edtMasterKey.Height);
  pt := edtMasterKey.Parent.ClientToScreen(pt);
  ShowKeysMenu(TKeyKind.kkMasterKey, pt.X, pt.Y, nAuthKeyIdx);
end;

procedure TfmMfSecurityLevelDlg.btnMasterKeysClick(Sender: TObject);
begin
  OpenMfPlusKeysDlg(TKeyKind.kkMasterKey);
end;

procedure TfmMfSecurityLevelDlg.btnSL2SwitchKeyClick(Sender: TObject);
var
  pt: TPoint;
  nAuthKeyIdx: Integer;
begin
  if edtL2SwitchKey.Modified then
  begin
    TryStrToMfPlusKey(edtL2SwitchKey.Text, m_rL2SwitchKey);
    edtL2SwitchKey.Modified := False;
  end;
  nAuthKeyIdx := g_AppSet.m_oMpKeys.IndexOfKey(m_rL2SwitchKey);

  pt := edtL2SwitchKey.BoundsRect.TopLeft;
  Inc(pt.Y, edtL2SwitchKey.Height);
  pt := edtL2SwitchKey.Parent.ClientToScreen(pt);
  ShowKeysMenu(TKeyKind.kkL2SwitchKey, pt.X, pt.Y, nAuthKeyIdx);
end;

procedure TfmMfSecurityLevelDlg.btnSL2SwitchKeysClick(Sender: TObject);
begin
  OpenMfPlusKeysDlg(TKeyKind.kkL2SwitchKey);
end;

procedure TfmMfSecurityLevelDlg.btnSL3SwitchKeyClick(Sender: TObject);
var
  pt: TPoint;
  nAuthKeyIdx: Integer;
begin
  if edtL3SwitchKey.Modified then
  begin
    TryStrToMfPlusKey(edtL3SwitchKey.Text, m_rL3SwitchKey);
    edtL3SwitchKey.Modified := False;
  end;
  nAuthKeyIdx := g_AppSet.m_oMpKeys.IndexOfKey(m_rL3SwitchKey);

  pt := edtL3SwitchKey.BoundsRect.TopLeft;
  Inc(pt.Y, edtL3SwitchKey.Height);
  pt := edtL3SwitchKey.Parent.ClientToScreen(pt);
  ShowKeysMenu(TKeyKind.kkL3SwitchKey, pt.X, pt.Y, nAuthKeyIdx);
end;

procedure TfmMfSecurityLevelDlg.btnSL3SwitchKeysClick(Sender: TObject);
begin
  OpenMfPlusKeysDlg(TKeyKind.kkL3SwitchKey);
end;

procedure TfmMfSecurityLevelDlg.btnSwitchToSL1Click(Sender: TObject);
begin
  DoSwitchToSL1;
end;

procedure TfmMfSecurityLevelDlg.btnSwitchToSL3Click(Sender: TObject);
begin
  DoSwitchToSL3;
end;

procedure TfmMfSecurityLevelDlg.DoSwitchToSL1;
var
  nSak: Byte;
  nAtq: Word;
  rUid: TCardUid;
  aAts: array[0..31] of Byte;
  nSize: Cardinal;
begin
  UpdateCtrlData(True);
  m_iReader.EnableAutoScan(False, True);
  try
    m_iReader.MfPowerOff;
    Sleep(500);
    if not m_iReader.MfRAS(True, nSak, nAtq, rUid) then
    begin
      MessageDlg(SNoCard, mtError, [mbOk], 0);
      Exit;
    end;
    m_iReader.MfRATS(@aAts, SizeOf(aAts), nSize);

    m_iReader.MfWritePerso($9000, m_rMasterKey);
    m_iReader.MfWritePerso($9001, m_rConfigKey);
    if (m_rCardInfo.nMpType = mptX) or (m_rCardInfo.nMpType = mptUnknown) then
    begin
      try
        m_iReader.MfWritePerso($9002, m_rL2SwitchKey);
      except
        // Наверное карта не поддерживает этот ключ
      end;
    end;
    m_iReader.MfWritePerso($9003, m_rL3SwitchKey);
    m_iReader.MfCommitPerso;
  finally
    m_iReader.EnableAutoScan(True, False);
  end;
end;

procedure TfmMfSecurityLevelDlg.DoSwitchToSL3;
var
  nSak: Byte;
  nAtq: Word;
  rUid: TCardUid;
  aAts: array[0..31] of Byte;
  nSize: Cardinal;
begin
  UpdateCtrlData(True);
  m_iReader.EnableAutoScan(False);
  try
    m_iReader.MfPowerOff;
    Sleep(500);
    m_iReader.MfRAS(True, nSak, nAtq, rUid);
    if rUid.IsEmpty then
    begin
      MessageDlg(SNoCard, mtError, [mbOk], 0);
      Exit;
    end;
    m_iReader.MfRATS(@aAts, SizeOf(aAts), nSize);

    m_iReader.LoadMfPlusAuthKey(m_rAuthL3SwitchKey);
    m_iReader.AuthMfCard($9003, False);
  finally
    m_iReader.EnableAutoScan(True, False);
  end;
end;

procedure TfmMfSecurityLevelDlg.btnCSRefreshClick(Sender: TObject);
begin
  m_iReader.Scan(True);
end;

procedure TfmMfSecurityLevelDlg.btnAuthL3SwitchKeyClick(Sender: TObject);
var
  pt: TPoint;
  nAuthKeyIdx: Integer;
begin
  if edtAuthL3SwitchKey.Modified then
  begin
    TryStrToMfPlusKey(edtAuthL3SwitchKey.Text, m_rAuthL3SwitchKey);
    edtAuthL3SwitchKey.Modified := False;
  end;
  nAuthKeyIdx := g_AppSet.m_oMpKeys.IndexOfKey(m_rAuthL3SwitchKey);

  pt := edtAuthL3SwitchKey.BoundsRect.TopLeft;
  Inc(pt.Y, edtAuthL3SwitchKey.Height);
  pt := edtAuthL3SwitchKey.Parent.ClientToScreen(pt);
  ShowKeysMenu(TKeyKind.kkAuthL3SwitchKey, pt.X, pt.Y, nAuthKeyIdx);
end;

procedure TfmMfSecurityLevelDlg.btnAuthL3SwitchKeysClick(Sender: TObject);
begin
  OpenMfPlusKeysDlg(TKeyKind.kkAuthL3SwitchKey);
end;

procedure TfmMfSecurityLevelDlg.btnConfigKeyClick(Sender: TObject);
var
  pt: TPoint;
  nAuthKeyIdx: Integer;
begin
  if edtConfigKey.Modified then
  begin
    TryStrToMfPlusKey(edtConfigKey.Text, m_rConfigKey);
    edtConfigKey.Modified := False;
  end;
  nAuthKeyIdx := g_AppSet.m_oMpKeys.IndexOfKey(m_rConfigKey);

  pt := edtConfigKey.BoundsRect.TopLeft;
  Inc(pt.Y, edtConfigKey.Height);
  pt := edtConfigKey.Parent.ClientToScreen(pt);
  ShowKeysMenu(TKeyKind.kkConfigKey, pt.X, pt.Y, nAuthKeyIdx);
end;

procedure TfmMfSecurityLevelDlg.btnConfigKeysClick(Sender: TObject);
begin
  OpenMfPlusKeysDlg(TKeyKind.kkConfigKey);
end;

procedure TfmMfSecurityLevelDlg.FormCreate(Sender: TObject);
begin
  ImageList1.ResourceLoad(rtBitmap, 'rBtnDown', clWhite);
  m_rMasterKey := kDefaultMfPlusKey;
  m_rConfigKey := kDefaultMfPlusKey;
  m_rL2SwitchKey := kDefaultMfPlusKey;
  m_rL3SwitchKey := kDefaultMfPlusKey;
  m_rAuthL3SwitchKey := kDefaultMfPlusKey;
end;

procedure TfmMfSecurityLevelDlg.FormShow(Sender: TObject);
begin
  UpdateCtrlData(False);
  m_iReader.SetNotifyCallback(ReaderNotifyCallback, Self);
  UpdateCurrentCard;
end;

procedure TfmMfSecurityLevelDlg.miKeyXClick(Sender: TObject);
var
  nKeyKind: TKeyKind;
  mi: TMenuItem;
  nIdx: Integer;
  rKey: TMfPlusKey;
begin
  mi := (Sender as TMenuItem);
  nKeyKind := TKeyKind(mi.Owner.Tag);
  nIdx := mi.Tag;
  rKey := g_AppSet.m_oMpKeys[nIdx].m_rKey;
  case nKeyKind of
    kkMasterKey:
    begin
      m_rMasterKey := rKey;
      edtMasterKey.Text := MfPlusKeyToStr(m_rMasterKey);
    end;

    kkConfigKey:
    begin
      m_rConfigKey := rKey;
      edtConfigKey.Text := MfPlusKeyToStr(m_rConfigKey);
    end;

    kkL2SwitchKey:
    begin
      m_rL2SwitchKey := rKey;
      edtL2SwitchKey.Text := MfPlusKeyToStr(m_rL2SwitchKey);
    end;

    kkL3SwitchKey:
    begin
      m_rL3SwitchKey := rKey;
      edtL3SwitchKey.Text := MfPlusKeyToStr(m_rL3SwitchKey);
    end;

    kkAuthL3SwitchKey:
    begin
      m_rAuthL3SwitchKey := rKey;
      edtAuthL3SwitchKey.Text := MfPlusKeyToStr(m_rAuthL3SwitchKey);
    end;
  end;
end;

function TfmMfSecurityLevelDlg.OpenMfPlusKeysDlg(AKeyKind: TKeyKind): Boolean;
var
  oDlg: TfmMfPlusKeysDlg;
  pKey: PMfPlusKey;
  edt: TMaskEdit;
begin
  case AKeyKind of
    kkMasterKey:
    begin
      pKey := @m_rMasterKey;
      edt := edtMasterKey;
    end;

    kkConfigKey:
    begin
      pKey := @m_rConfigKey;
      edt := edtConfigKey;
    end;

    kkL2SwitchKey:
    begin
      pKey := @m_rL2SwitchKey;
      edt := edtL2SwitchKey;
    end;

    kkL3SwitchKey:
    begin
      pKey := @m_rL3SwitchKey;
      edt := edtL3SwitchKey;
    end;

    kkAuthL3SwitchKey:
    begin
      pKey := @m_rAuthL3SwitchKey;
      edt := edtAuthL3SwitchKey;
    end;

    else
    begin
      Assert(False);
      pKey := nil;
      edt := nil;
    end;
  end;

  if edt.Modified then
  begin
    TryStrToMfPlusKey(edt.Text, pKey^);
    edt.Modified := False;
  end;

  oDlg := TfmMfPlusKeysDlg.Create(Self);
  try
    oDlg.PopupParent := Self;
    oDlg.m_nKeyIdx := g_AppSet.m_oMpKeys.IndexOfKey(pKey^);
    Result := (oDlg.ShowModal = mrOk);
    if (oDlg.m_nKeyIdx <> -1) and
      (oDlg.m_nKeyIdx < g_AppSet.m_oMpKeys.Count) and
      (pKey^ <> g_AppSet.m_oMpKeys[oDlg.m_nKeyIdx].m_rKey) then
    begin
      pKey^ := g_AppSet.m_oMpKeys[oDlg.m_nKeyIdx].m_rKey;
      edt.Text := MfPlusKeyToStr(pKey^);
    end;
  finally
    oDlg.Free;
  end;
end;

procedure TfmMfSecurityLevelDlg.ShowKeysMenu(AKeyKind: TKeyKind; X, Y,
  AKeyIdx: Integer);
var
  I: Integer;
  mi: TMenuItem;
begin
  menuKeys.Items.Clear;
  for I := 0 to g_AppSet.m_oMpKeys.Count - 1 do
  begin
    mi := TMenuItem.Create(menuKeys);
    mi.Caption := format('%2d - 0x%s', [
        1 + I, MfPlusKeyToStr4(g_AppSet.m_oMpKeys[I].m_rKey)]);
    mi.Tag := I;
    mi.RadioItem := True;
    mi.Checked := (I = AKeyIdx);
    mi.OnClick := miKeyXClick;
    menuKeys.Items.Add(mi);
  end;
  menuKeys.Tag := NativeInt(AKeyKind);
  menuKeys.Popup(X, Y);
end;

procedure TfmMfSecurityLevelDlg.UmILReader_Notify(var Msg: TMessage);
var
  nMsg: TReaderMsg;
  pMsgData: Pointer;
begin
  while m_iReader.GetMessage(nMsg, pMsgData) do
  begin
    case nMsg of
      rmCardFound,
      rmCardLost:
        UpdateCurrentCard;
    end;
  end;
end;

procedure TfmMfSecurityLevelDlg.UpdateCurrentCard;
var
  S: string;
begin
  m_iReader.GetCardInfo(m_rCardInfo);
  if m_rCardInfo.rUID.IsEmpty then
    labCurrentCard.Caption := SNoCard
  else
  begin
    S := format(' %s %s', [
          kCardTypeNames[m_rCardInfo.nType],
          ILRCardUIDToStr(m_rCardInfo.nType, m_rCardInfo.rUID)]);
    if m_rCardInfo.nMpType <> TMfPlusType.mptUnknown then
      S := S + ' ' + kMpTypeNames[m_rCardInfo.nMpType];
    if m_rCardInfo.nSL <> TMfPlusSL.mpslUnknown then
      S := S + format(' SL%d', [Integer(m_rCardInfo.nSL)]);
    labCurrentCard.Caption := S;
  end;
  UpdateCtrlState;
end;

procedure TfmMfSecurityLevelDlg.UpdateCtrlData(ASave: Boolean);
begin
  if ASave then
  begin
    TryStrToMfPlusKey(edtMasterKey.Text, m_rConfigKey);
    TryStrToMfPlusKey(edtConfigKey.Text, m_rConfigKey);
    TryStrToMfPlusKey(edtL2SwitchKey.Text, m_rL2SwitchKey);
    TryStrToMfPlusKey(edtL3SwitchKey.Text, m_rL3SwitchKey);
    TryStrToMfPlusKey(edtAuthL3SwitchKey.Text, m_rAuthL3SwitchKey);
  end
  else
  begin
    edtMasterKey.Text := MfPlusKeyToStr(m_rMasterKey);
    edtConfigKey.Text := MfPlusKeyToStr(m_rConfigKey);
    edtL2SwitchKey.Text := MfPlusKeyToStr(m_rL2SwitchKey);
    edtL3SwitchKey.Text := MfPlusKeyToStr(m_rL3SwitchKey);
    edtAuthL3SwitchKey.Text := MfPlusKeyToStr(m_rAuthL3SwitchKey);
  end;
end;

procedure TfmMfSecurityLevelDlg.UpdateCtrlState;
var
  f: Boolean;
begin
  f := (not m_rCardInfo.rUID.IsEmpty) and m_rCardInfo.IsMfPlus and
    (m_rCardInfo.nSL = mpslSL0);
  grSwitchSL1.Enabled := f;
  btnSwitchToSL1.Enabled := f;
  if f then
  begin
//    f := (m_rCardInfo.nMpType = mptX);
    labL2SwitchKey.Visible := f;
    edtL2SwitchKey.Visible := f;
    btnSL2SwitchKey.Visible := f;
    btnSL2SwitchKeys.Visible := f;
  end;
  f := (not m_rCardInfo.rUID.IsEmpty) and m_rCardInfo.IsMfPlus and
    (m_rCardInfo.nSL in [mpslSL1, mpslSL2]);
  grSwitchSL3.Enabled := f;
  btnSwitchToSL3.Enabled := f;
end;

end.
