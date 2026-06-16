unit MfClassicKeysDlg;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Mask, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls,
  IL.Readers, uClasses, uTypes, uMfClassicKeysLvData;

type
  TfmMfClassicKeysDlg = class(TForm)
    btnCancel: TButton;
    btnOk: TButton;
    ListView1: TListView;
    panProperties: TPanel;
    laKey: TLabel;
    labComment: TLabel;
    edtComment: TEdit;
    edtKey: TMaskEdit;
    procedure btnOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure edtKeyKeyPress(Sender: TObject; var Key: Char);
    procedure ListView1Data(Sender: TObject; Item: TListItem);
    procedure ListView1DataHint(Sender: TObject; StartIndex, EndIndex: Integer);
    procedure ListView1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ListView1SelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListView1CustomDrawSubItem(Sender: TCustomListView;
      Item: TListItem; SubItem: Integer; State: TCustomDrawState;
      var DefaultDraw: Boolean);
  private
    { Private declarations }
    m_fModified     : Boolean;
    m_oLVD          : TMfClassicKeysLvData;
    m_sValidChars   : string;

    procedure CMChildKey(var Msg: TCMChildKey); message CM_CHILDKEY;
    procedure LVDUpdateAllView(Sender: TObject);

    procedure UpdateProperties;
    function SaveProperties: Boolean;
    procedure DoDelete;

  public
    { Public declarations }
    m_oKeys         : TMfClassicKeyList;
    m_nKeyIdx       : Integer;
  end;

var
  fmMfClassicKeysDlg: TfmMfClassicKeysDlg;

implementation

{$R *.dfm}

uses
  System.Character,
  uAppSettings, uConst;

{ TfmMfClassicKeysDlg }

procedure TfmMfClassicKeysDlg.btnOkClick(Sender: TObject);
var
  nIdx: Integer;
begin
  if (m_nKeyIdx <> -1) and SaveProperties and
    (m_nKeyIdx = m_oKeys.Count) and
    ((m_oLVD.m_rNewKey.m_nKey <> kDefaultMfClassicKey) or
    (not m_oLVD.m_rNewKey.m_sComment.IsEmpty)) then
  begin
    nIdx := m_oKeys.Add(m_oLVD.m_rNewKey);
    m_oLVD.m_rNewKey.m_nKey := kDefaultMfClassicKey;
    m_oLVD.m_rNewKey.m_sComment := string.Empty;
    m_oLVD.UpdateAllView;
    ListView1.ItemIndex := nIdx;
    m_fModified := True;
  end;

  if m_fModified then
  begin
    g_AppSet.m_oMcKeys.Assign(m_oKeys);
    g_AppSet.SaveMfClassicKeys;
    m_fModified := False;
  end;
end;

procedure TfmMfClassicKeysDlg.CMChildKey(var Msg: TCMChildKey);
var
  nIdx: Integer;
begin
  inherited;
  if Msg.CharCode in [VK_RETURN, VK_ESCAPE] then
  begin
    if (Msg.Sender = edtKey) or (Msg.Sender = edtComment) then
    begin
      Msg.Result := 1;
      if Msg.CharCode = VK_RETURN then
      begin
        if SaveProperties and (m_nKeyIdx = m_oKeys.Count) then
        begin
          nIdx := m_oKeys.Add(m_oLVD.m_rNewKey);
          m_oLVD.m_rNewKey.m_nKey := kDefaultMfClassicKey;
          m_oLVD.m_rNewKey.m_sComment := string.Empty;
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

procedure TfmMfClassicKeysDlg.DoDelete;
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
    if oLI.Index < m_oKeys.Count then
    begin
      m_oKeys.Delete(oLI.Index);
      m_fModified := True;
    end;
  until False;
  m_oLVD.UpdateAllView;
  UpdateProperties;
end;

procedure TfmMfClassicKeysDlg.edtKeyKeyPress(Sender: TObject; var Key: Char);
begin
  if (not Key.IsControl) and (m_sValidChars <> '') and
    (m_sValidChars.IndexOf(Key) = -1) then
  begin
    Key := #0;
    Exit;
  end;
end;

procedure TfmMfClassicKeysDlg.FormClose(Sender: TObject;
  var Action: TCloseAction);
var
  rWP: TWindowPlacement;
  rSize: TSize;
begin
  FillChar(rWP, SizeOf(rWP), 0);
  rWP.length := SizeOf(rWP);
  GetWindowPlacement(Self.Handle, rWP);
  rSize := rWP.rcNormalPosition.Size;
  if g_AppSet.m_aWinSizes[swMfClassicKeysDlg] <> rSize then
    g_AppSet.SetWinSize(swMfClassicKeysDlg, rSize);
end;

procedure TfmMfClassicKeysDlg.FormCreate(Sender: TObject);
var
  rSize: TSize;
begin
  m_nKeyIdx := -1;
  m_sValidChars := '0123456789abcdefABCDEF';
  m_oKeys := TMfClassicKeyList.Create;
  m_oKeys.Assign(g_AppSet.m_oMcKeys);
  m_oLVD := TMfClassicKeysLvData.Create;
  m_oLVD.m_pKeys := m_oKeys;
  m_oLVD.OnUpdateAllView := LVDUpdateAllView;
  m_oLVD.m_rNewKey.m_nKey := kDefaultMfClassicKey;

  rSize := g_AppSet.m_aWinSizes[swMfClassicKeysDlg];
  if (rSize.cx <> 0) and (rSize.cy <> 0) then
  begin
    Width := rSize.cx;
    Height := rSize.cy;
  end;
end;

procedure TfmMfClassicKeysDlg.FormDestroy(Sender: TObject);
begin
  m_oLVD.Free;
  m_oKeys.Free;
end;

procedure TfmMfClassicKeysDlg.FormShow(Sender: TObject);
var
  nIdx: Integer;
begin
  nIdx := m_nKeyIdx;
  m_nKeyIdx := -1;
  m_oLVD.UpdateAllView;
  if nIdx <> -1 then
    ListView1.ItemIndex := nIdx
  else
    UpdateProperties;
end;

procedure TfmMfClassicKeysDlg.ListView1CustomDrawSubItem(
  Sender: TCustomListView; Item: TListItem; SubItem: Integer;
  State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  if SubItem = 1 then
    Sender.Canvas.Font.Name := 'Courier New';
end;

procedure TfmMfClassicKeysDlg.ListView1Data(Sender: TObject; Item: TListItem);
begin
  m_oLVD.GetData(Item);
end;

procedure TfmMfClassicKeysDlg.ListView1DataHint(Sender: TObject; StartIndex,
  EndIndex: Integer);
begin
  m_oLVD.DataHint(StartIndex, EndIndex);
end;

procedure TfmMfClassicKeysDlg.ListView1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_DELETE) and (Shift = []) then
    DoDelete;
end;

procedure TfmMfClassicKeysDlg.ListView1SelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  if Selected then
  begin
    if m_nKeyIdx <> -1 then
      SaveProperties;
    UpdateProperties;
  end;
end;

procedure TfmMfClassicKeysDlg.LVDUpdateAllView(Sender: TObject);
begin
  ListView1.Items.Count := m_oLVD.GetCount;
  ListView1.Invalidate;
end;

function TfmMfClassicKeysDlg.SaveProperties: Boolean;
var
  nKey: TMfClassicKey;
  fKeyOk: Boolean;
  N: Int64;
  pKI: PMcKeyInfo;
  S: string;
begin
  if m_nKeyIdx = -1 then
    Exit(False);

  fKeyOk := TryStrToInt64('$' + edtKey.Text, N) and
        (N >= 0) and (N <= $FFFFFFFFFFFF);
  if fKeyOk then
    nKey := N
  else
    nKey := 0;

  if m_nKeyIdx = m_oKeys.Count then
  begin
    m_oLVD.m_rNewKey.m_sComment := edtComment.Text;
    if fKeyOk then
      m_oLVD.m_rNewKey.m_nKey := nKey;
  end
  else
  begin
    pKI := @m_oKeys.List[m_nKeyIdx];
    if fKeyOk and (pKI.m_nKey <> nKey) then
    begin
      pKI.m_nKey := nKey;
      m_fModified := True;
    end;
    S := edtComment.Text;
    if pKI.m_sComment <> S then
    begin
      pKI.m_sComment := S;
      m_fModified := True;
    end;
  end;
  m_oLVD.UpdateAllView;
  Result := fKeyOk;
end;

procedure TfmMfClassicKeysDlg.UpdateProperties;
var
  pKI: PMcKeyInfo;
begin
  m_nKeyIdx := ListView1.ItemIndex;
  if m_nKeyIdx <> -1 then
  begin
    if m_nKeyIdx = m_oKeys.Count then
      pKI := @m_oLVD.m_rNewKey
    else
      pKI := @m_oKeys.List[m_nKeyIdx];
    edtKey.Text := IntToHex(pKI.m_nKey, 12);
    edtComment.Text := pKI.m_sComment;
    edtKey.Enabled := True;
    edtComment.Enabled := True;
  end
  else
  begin
    edtKey.Text := string.Empty;
    edtKey.Enabled := False;
    edtComment.Text := string.Empty;
    edtComment.Enabled := False;
  end;
end;

end.
