unit TemicPasswordsDlg;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Mask,
  uConst, uTypes, uTmcPasswLVData, uClasses;

type
  TfmTemicPasswordsDlg = class(TForm)
    btnCancel: TButton;
    btnOk: TButton;
    ListView1: TListView;
    panProperties: TPanel;
    labPassword: TLabel;
    cbPasswFormat: TComboBox;
    labComment: TLabel;
    edtComment: TEdit;
    edtPassword: TMaskEdit;
    procedure btnOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cbPasswFormatSelect(Sender: TObject);
    procedure ListView1Data(Sender: TObject; Item: TListItem);
    procedure ListView1DataHint(Sender: TObject; StartIndex, EndIndex: Integer);
    procedure ListView1SelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure edtPasswordKeyPress(Sender: TObject; var Key: Char);
    procedure ListView1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    m_fModified     : Boolean;
    m_oLVD          : TTmcPasswLVData;
    m_sValidChars   : string;

    procedure CMChildKey(var Msg: TCMChildKey); message CM_CHILDKEY;
    procedure LVDUpdateAllView(Sender: TObject);

    procedure UpdateProperties;
    function SaveProperties: Boolean;
    procedure DoDelete;

  public
    { Public declarations }
    m_oTmcPasswords : TTemicPasswordList;
    m_nPasswordIdx  : Integer;
  end;

var
  fmTemicPasswordsDlg: TfmTemicPasswordsDlg;

implementation

{$R *.dfm}

uses
  System.Character,
  uUtils, uAppSettings;

procedure TfmTemicPasswordsDlg.btnOkClick(Sender: TObject);
var
  nIdx: Integer;
begin
  if (m_nPasswordIdx <> -1) and SaveProperties and
    (m_nPasswordIdx = m_oTmcPasswords.Count) and
    ((m_oLVD.m_rNewPassword.m_nPassword <> 0) or
    (not m_oLVD.m_rNewPassword.m_sComment.IsEmpty)) then
  begin
    nIdx := m_oTmcPasswords.Add(m_oLVD.m_rNewPassword);
    m_oLVD.m_rNewPassword.m_nPassword := 0;
    m_oLVD.m_rNewPassword.m_sComment := string.Empty;
    m_oLVD.UpdateAllView;
    ListView1.ItemIndex := nIdx;
    m_fModified := True;
  end;

  if m_fModified then
  begin
    g_AppSet.m_oTmcPasswords.Assign(m_oTmcPasswords);
    g_AppSet.SaveTemicPasswords;
    m_fModified := False;
  end;
end;

procedure TfmTemicPasswordsDlg.cbPasswFormatSelect(Sender: TObject);
begin
  SaveProperties;
  m_oLVD.m_nPasswFormat := TTmcPasswFormat(cbPasswFormat.ItemIndex);
  g_AppSet.SetTemicPasswordFormat(m_oLVD.m_nPasswFormat);
  m_oLVD.UpdateAllView;
  UpdateProperties;
end;

procedure TfmTemicPasswordsDlg.CMChildKey(var Msg: TCMChildKey);
var
  nIdx: Integer;
begin
  inherited;
  if Msg.CharCode in [VK_RETURN, VK_ESCAPE] then
  begin
    if (Msg.Sender = edtPassword) or (Msg.Sender = edtComment) then
    begin
      Msg.Result := 1;
      if Msg.CharCode = VK_RETURN then
      begin
        if SaveProperties and (m_nPasswordIdx = m_oTmcPasswords.Count) then
        begin
          nIdx := m_oTmcPasswords.Add(m_oLVD.m_rNewPassword);
          m_oLVD.m_rNewPassword.m_nPassword := 0;
          m_oLVD.m_rNewPassword.m_sComment := string.Empty;
          m_oLVD.UpdateAllView;
          ListView1.ItemIndex := nIdx;
          m_fModified := True;
        end;
      end
      else
        UpdateProperties;
    end;
  end;
end;

procedure TfmTemicPasswordsDlg.DoDelete;
var
  oLI: TListItem;
begin
  if ListView1.SelCount = 0 then
    Exit;
  oLI := nil;
  repeat
    oLI := ListView1.GetNextItem(oLI, sdAll, [isSelected]);
    if oLI = nil then
      break;
    if oLI.Index < m_oTmcPasswords.Count then
    begin
      m_oTmcPasswords.Delete(oLI.Index);
      m_fModified := True;
    end;
  until False;
  m_oLVD.UpdateAllView;
  UpdateProperties;
end;

procedure TfmTemicPasswordsDlg.edtPasswordKeyPress(Sender: TObject;
  var Key: Char);
begin
  if (not Key.IsControl) and (m_sValidChars <> '') and
    (m_sValidChars.IndexOf(Key) = -1) then
  begin
    Key := #0;
    Exit;
  end;
end;

procedure TfmTemicPasswordsDlg.FormClose(Sender: TObject;
  var Action: TCloseAction);
var
  rWP: TWindowPlacement;
  rSize: TSize;
begin
  FillChar(rWP, SizeOf(rWP), 0);
  rWP.length := SizeOf(rWP);
  GetWindowPlacement(Self.Handle, rWP);
  rSize := rWP.rcNormalPosition.Size;
  if g_AppSet.m_aWinSizes[swTemicPasswordsDlg] <> rSize then
    g_AppSet.SetWinSize(swTemicPasswordsDlg, rSize);
end;

procedure TfmTemicPasswordsDlg.FormCreate(Sender: TObject);
var
  rSize: TSize;
begin
  m_nPasswordIdx := -1;
  m_oTmcPasswords := TTemicPasswordList.Create;
  m_oTmcPasswords.Assign(g_AppSet.m_oTmcPasswords);
  m_oLVD := TTmcPasswLVData.Create;
  m_oLVD.m_pPasswords := m_oTmcPasswords;
  m_oLVD.m_nPasswFormat := g_AppSet.m_nTmcPasswFormat;
  m_oLVD.OnUpdateAllView := LVDUpdateAllView;
  cbPasswFormat.ItemIndex := Integer(g_AppSet.m_nTmcPasswFormat);

  rSize := g_AppSet.m_aWinSizes[swTemicPasswordsDlg];
  if (rSize.cx <> 0) and (rSize.cy <> 0) then
  begin
    Width := rSize.cx;
    Height := rSize.cy;
  end;
end;

procedure TfmTemicPasswordsDlg.FormDestroy(Sender: TObject);
begin
  m_oLVD.Free;
  m_oTmcPasswords.Free;
end;

procedure TfmTemicPasswordsDlg.FormShow(Sender: TObject);
var
  nIdx: Integer;
begin
  nIdx := m_nPasswordIdx;
  m_nPasswordIdx := -1;
  m_oLVD.UpdateAllView;
  if nIdx <> -1 then
    ListView1.ItemIndex := nIdx
  else
    UpdateProperties;
end;

procedure TfmTemicPasswordsDlg.ListView1Data(Sender: TObject; Item: TListItem);
begin
  m_oLVD.GetData(Item);
end;

procedure TfmTemicPasswordsDlg.ListView1DataHint(Sender: TObject; StartIndex,
  EndIndex: Integer);
begin
  m_oLVD.DataHint(StartIndex, EndIndex);
end;

procedure TfmTemicPasswordsDlg.ListView1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_DELETE) and (Shift = []) then
    DoDelete;
end;

procedure TfmTemicPasswordsDlg.ListView1SelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  if Selected then
  begin
    if m_nPasswordIdx <> -1 then
      SaveProperties;
    UpdateProperties;
  end;
end;

procedure TfmTemicPasswordsDlg.LVDUpdateAllView(Sender: TObject);
begin
  ListView1.Items.Count := m_oLVD.GetCount;
  ListView1.Invalidate;
end;

function TfmTemicPasswordsDlg.SaveProperties: Boolean;
var
  pPassword: PTemicPassword;
  fPasswordOk: Boolean;
  N: Int64;
  nPassword: Cardinal;
  S: string;
begin
  if m_nPasswordIdx = -1 then
    Exit(False);

  nPassword := 0;
  fPasswordOk := False;
  case m_oLVD.m_nPasswFormat of
    tpfDec:
    begin
      fPasswordOk := TryStrToInt64(edtPassword.Text, N) and
        (N >= 0) and (N <= $FFFFFFFF);
      if fPasswordOk then
        nPassword := N;
    end;

    tpfHex:
    begin
      fPasswordOk := TryStrToInt64('$' + edtPassword.Text, N) and
        (N >= 0) and (N <= $FFFFFFFF);
      if fPasswordOk then
        nPassword := N;
    end;

    else
      Assert(False);
  end;

  if m_nPasswordIdx = m_oTmcPasswords.Count then
  begin
    m_oLVD.m_rNewPassword.m_sComment := edtComment.Text;
    if fPasswordOk then
      m_oLVD.m_rNewPassword.m_nPassword := nPassword;
  end
  else
  begin
    pPassword := @m_oTmcPasswords.List[m_nPasswordIdx];
    if fPasswordOk and (pPassword.m_nPassword <> nPassword) then
    begin
      pPassword.m_nPassword := nPassword;
      m_fModified := True;
    end;
    S := edtComment.Text;
    if pPassword.m_sComment <> S then
    begin
      pPassword.m_sComment := S;
      m_fModified := True;
    end;
  end;
  m_oLVD.UpdateAllView;
  Result := fPasswordOk;
end;

procedure TfmTemicPasswordsDlg.UpdateProperties;
var
  pPassword: PTemicPassword;
begin
  m_nPasswordIdx := ListView1.ItemIndex;
  if m_nPasswordIdx <> -1 then
  begin
    if m_nPasswordIdx = m_oTmcPasswords.Count then
      pPassword := @m_oLVD.m_rNewPassword
    else
      pPassword := @m_oTmcPasswords.List[m_nPasswordIdx];
    case m_oLVD.m_nPasswFormat of
      tpfDec:
      begin
        edtPassword.EditMask := string.Empty;
        m_sValidChars := '0123456789';
        edtPassword.Text := IntToStr(pPassword.m_nPassword);
      end;
      tpfHex:
      begin
        edtPassword.EditMask := 'AAAAAAAA;1;_';
        m_sValidChars := '0123456789abcdefABCDEF';
        edtPassword.Text := IntToHex(pPassword.m_nPassword, 8);
      end;
    end;
    edtComment.Text := pPassword.m_sComment;
    edtPassword.Enabled := True;
    edtComment.Enabled := True;
  end
  else
  begin
    edtPassword.Text := string.Empty;
    edtPassword.Enabled := False;
    edtComment.Text := string.Empty;
    edtComment.Enabled := False;
  end;
end;

end.

