unit MfReaderMpKeysDlg;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Mask, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls,
  IL.Readers, uMfReaderSettings, uTypes;

type
  TfmMfReaderMpKeysDlg = class(TForm)
    ListView1: TListView;
    rgKeyType: TRadioGroup;
    btnCancel: TButton;
    btnOk: TButton;
    panProperties: TPanel;
    laKey: TLabel;
    labComment: TLabel;
    edtComment: TEdit;
    edtKey: TMaskEdit;
    btnWriteAll: TButton;
    procedure btnWriteAllClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure edtKeyKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure ListView1SelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure ListView1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ListView1ItemChecked(Sender: TObject; Item: TListItem);
    procedure rgKeyTypeClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListView1CustomDrawSubItem(Sender: TCustomListView;
      Item: TListItem; SubItem: Integer; State: TCustomDrawState;
      var DefaultDraw: Boolean);
  private
    { Private declarations }
    m_fModified     : Boolean;
    m_sValidChars   : string;

    // Список ключей аутентификации Mifare Plus
    m_aMpRdKeys     : array[Boolean, 0..15] of TMpKeyInfo;
    m_aMpValidRdKeys: array[Boolean] of Cardinal;
    m_aMpCheckRdKeys: array[Boolean] of Cardinal;
    m_aChangedKeys  : array[Boolean] of Cardinal;

    procedure CMChildKey(var Msg: TCMChildKey); message CM_CHILDKEY;

    procedure UpdateListView;
    procedure UpdateListViewRow(ARow: Integer);
    function SaveProperties: Boolean;
    procedure UpdateProperties;
    procedure DoDelete;

  public
    { Public declarations }
    m_iReader       : IILReader;
    m_pSettings     : TMfReaderSettings;
    m_fKeyB         : Boolean;
    m_fCheckboxes   : Boolean; // True, разрешить выбор ключей
    m_nKeyIdx       : Integer;

    procedure DoWriteAll;
    procedure DoWriteChanged;
  end;

var
  fmMfReaderMpKeysDlg: TfmMfReaderMpKeysDlg;

implementation

{$R *.dfm}

uses
  System.Character,
  IL.RUtils, uUtils, uConst, uAppSettings,
  ProgressDlg;


procedure TfmMfReaderMpKeysDlg.btnOkClick(Sender: TObject);
var
  f: Boolean;
  I: Integer;
begin
  if m_nKeyIdx <> -1 then
    SaveProperties;

  DoWriteChanged;

  if m_fModified then
  begin
    for f := False to True do
    begin
      if m_pSettings.m_aMpValidRdKeys[f] <> m_aMpValidRdKeys[f] then
      begin
        m_pSettings.m_aMpValidRdKeys[f] := m_aMpValidRdKeys[f];
        m_pSettings.m_fModified := True;
      end;
      if m_pSettings.m_aMpCheckRdKeys[f] <> m_aMpCheckRdKeys[f] then
      begin
        m_pSettings.m_aMpCheckRdKeys[f] := m_aMpCheckRdKeys[f];
        m_pSettings.m_fModified := True;
      end;
      for I := 0 to High(m_aMpRdKeys[f]) do
        if (m_pSettings.m_aMpRdKeys[f, I].m_rKey <> m_aMpRdKeys[f, I].m_rKey) or
          (m_pSettings.m_aMpRdKeys[f, I].m_sComment <> m_aMpRdKeys[f, I].m_sComment) then
        begin
          m_pSettings.m_aMpRdKeys[f, I] := m_aMpRdKeys[f, I];
          m_pSettings.m_fModified := True;
        end;
    end;
    m_fModified := False;
    if m_pSettings.m_fModified then
      m_pSettings.Save;
  end;
end;

procedure TfmMfReaderMpKeysDlg.btnWriteAllClick(Sender: TObject);
begin
  DoWriteAll;
end;

procedure TfmMfReaderMpKeysDlg.CMChildKey(var Msg: TCMChildKey);
begin
  inherited;
  if Msg.CharCode in [VK_RETURN, VK_ESCAPE] then
  begin
    if (Msg.Sender = edtKey) or (Msg.Sender = edtComment) then
    begin
      Msg.Result := 1;
      if Msg.CharCode = VK_RETURN then
        SaveProperties
      else
        UpdateProperties;
    end;
  end;
end;

procedure TfmMfReaderMpKeysDlg.DoDelete;
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
    if GetBit(m_aMpValidRdKeys[m_fKeyB], oLI.Index) then
    begin
      SetBit(m_aMpValidRdKeys[m_fKeyB], oLI.Index, False);
      m_fModified := True;
    end;
  until False;
  UpdateListView;
  UpdateProperties;
end;

procedure TfmMfReaderMpKeysDlg.DoWriteAll;
begin
  ExecuteWithProgress(SWritingAuthKeys, procedure(ADlg: TfmProgressDlg)
  var
    f: Boolean;
    I, nCurrent, nTotal: Integer;
  begin
    nCurrent := 0;
    nTotal := Length(m_aMpRdKeys[f]) * 2;
    for f := False to True do
    begin
      for I := 0 to High(m_aMpRdKeys[f]) do
      begin
        if GetBit(m_aMpValidRdKeys[f], I) then
        begin
          m_iReader.WriteMfPlusAuthKeyToReader(I, f, @m_aMpRdKeys[f, I].m_rKey, 1);
          SetBit(m_aChangedKeys[f], I, False);
          ADlg.SetProgress(nCurrent, nTotal);
          Application.ProcessMessages();
          if ADlg.m_fCancelled then
            break;
        end;
        Inc(nCurrent);
      end;
    end;
  end, Self);
end;

procedure TfmMfReaderMpKeysDlg.DoWriteChanged;
begin
  ExecuteWithProgress(SWritingAuthKeys, procedure(ADlg: TfmProgressDlg)
  var
    f: Boolean;
    I, nCurrent, nTotal: Integer;
  begin
    nCurrent := 0;
    nTotal := Length(m_aMpRdKeys[f]) * 2;
    for f := False to True do
    begin
      for I := 0 to High(m_aMpRdKeys[f]) do
      begin
        if GetBit(m_aMpValidRdKeys[f], I) and GetBit(m_aChangedKeys[f], I) then
        begin
          m_iReader.WriteMfAuthKeyToReader(I, f, @m_aMpRdKeys[f, I].m_rKey, 1);
          SetBit(m_aChangedKeys[f], I, False);
          ADlg.SetProgress(nCurrent, nTotal);
          Application.ProcessMessages();
          if ADlg.m_fCancelled then
            break;
        end;
        Inc(nCurrent);
      end;
    end;
  end, Self);
end;

procedure TfmMfReaderMpKeysDlg.edtKeyKeyPress(Sender: TObject; var Key: Char);
begin
  if (not Key.IsControl) and (m_sValidChars <> '') and
    (m_sValidChars.IndexOf(Key) = -1) then
  begin
    Key := #0;
    Exit;
  end;
end;

procedure TfmMfReaderMpKeysDlg.FormClose(Sender: TObject;
  var Action: TCloseAction);
var
  rWP: TWindowPlacement;
  rSize: TSize;
begin
  FillChar(rWP, SizeOf(rWP), 0);
  rWP.length := SizeOf(rWP);
  GetWindowPlacement(Self.Handle, rWP);
  rSize := rWP.rcNormalPosition.Size;
  if g_AppSet.m_aWinSizes[swMfReaderMpKeysDlg] <> rSize then
    g_AppSet.SetWinSize(swMfReaderMpKeysDlg, rSize);
end;

procedure TfmMfReaderMpKeysDlg.FormCreate(Sender: TObject);
var
  rSize: TSize;
begin
  m_sValidChars := '0123456789abcdefABCDEF';

  rSize := g_AppSet.m_aWinSizes[swMfReaderMpKeysDlg];
  if (rSize.cx <> 0) and (rSize.cy <> 0) then
  begin
    Width := rSize.cx;
    Height := rSize.cy;
  end;
end;

procedure TfmMfReaderMpKeysDlg.FormShow(Sender: TObject);
var
  f: Boolean;
  I: Integer;
begin
  Assert(m_pSettings <> nil);

  for f := False to True do
  begin
    m_aMpValidRdKeys[f] := m_pSettings.m_aMpValidRdKeys[f];
    m_aMpCheckRdKeys[f] := m_pSettings.m_aMpCheckRdKeys[f];
    for I := 0 to High(m_aMpRdKeys[f]) do
      m_aMpRdKeys[f, I] := m_pSettings.m_aMpRdKeys[f, I];
  end;
  m_fModified := False;
  ListView1.Checkboxes := m_fCheckboxes;
  if m_fKeyB then
    rgKeyType.ItemIndex := 1
  else
    rgKeyType.ItemIndex := 0;
  UpdateListView;
  UpdateProperties;
end;

procedure TfmMfReaderMpKeysDlg.ListView1CustomDrawSubItem(
  Sender: TCustomListView; Item: TListItem; SubItem: Integer;
  State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  if SubItem = 1 then
    Sender.Canvas.Font.Name := 'Courier New';
end;

procedure TfmMfReaderMpKeysDlg.ListView1ItemChecked(Sender: TObject;
  Item: TListItem);
begin
  if GetBit(m_aMpCheckRdKeys[m_fKeyB], Item.Index) <> Item.Checked then
  begin
    SetBit(m_aMpCheckRdKeys[m_fKeyB], Item.Index, Item.Checked);
    m_fModified := True;
  end;
end;

procedure TfmMfReaderMpKeysDlg.ListView1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_DELETE) and (Shift = []) then
    DoDelete;
end;

procedure TfmMfReaderMpKeysDlg.ListView1SelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  if Selected then
  begin
    if m_nKeyIdx <> -1 then
      SaveProperties;
    UpdateProperties;
  end;
end;

procedure TfmMfReaderMpKeysDlg.rgKeyTypeClick(Sender: TObject);
begin
  if m_nKeyIdx <> -1 then
    SaveProperties;
  m_fKeyB := (rgKeyType.ItemIndex = 1);
  UpdateListView;
  UpdateProperties;
end;

function TfmMfReaderMpKeysDlg.SaveProperties: Boolean;
var
  rKey: TMfPlusKey;
  fKeyOk: Boolean;
  pKI: PMpKeyInfo;
  S: string;
begin
  if m_nKeyIdx = -1 then
    Exit(False);

  fKeyOk := TryStrToMfPlusKey(edtKey.Text, rKey);

  pKI := @m_aMpRdKeys[m_fKeyB, m_nKeyIdx];
  if fKeyOk and (pKI.m_rKey <> rKey) then
  begin
    pKI.m_rKey := rKey;
    SetBit(m_aMpValidRdKeys[m_fKeyB], m_nKeyIdx);
    SetBit(m_aChangedKeys[m_fKeyB], m_nKeyIdx);
    m_fModified := True;
  end;
  S := edtComment.Text;
  if pKI.m_sComment <> S then
  begin
    pKI.m_sComment := S;
    m_fModified := True;
  end;
  UpdateListViewRow(m_nKeyIdx);
  Result := fKeyOk;
end;

procedure TfmMfReaderMpKeysDlg.UpdateListView;
var
  lv: TListView;
  I: Integer;
  pLI: TListItem;
  pKI: PMpKeyInfo;
begin
  lv := ListView1;
  lv.Items.BeginUpdate;
  try
    for I := 0 to lv.Items.Count - 1 do
    begin
      pLI := lv.Items[I];
      pKI := @m_aMpRdKeys[m_fKeyB, I];
      pLI.SubItems.Clear;
      if GetBit(m_aMpValidRdKeys[m_fKeyB], I) then
      begin
        pLI.SubItems.Add('0x' + MfPlusKeyToStr4(pKI.m_rKey));
        pLI.SubItems.Add(pKI.m_sComment);
      end;
      if m_fCheckboxes then
        pLI.Checked := GetBit(m_aMpCheckRdKeys[m_fKeyB], I);
    end;
  finally
    lv.Items.EndUpdate;
  end;
end;

procedure TfmMfReaderMpKeysDlg.UpdateListViewRow(ARow: Integer);
var
  lv: TListView;
  pLI: TListItem;
  pKI: PMpKeyInfo;
begin
  lv := ListView1;
  lv.Items.BeginUpdate;
  try
    pLI := lv.Items[ARow];
    pKI := @m_aMpRdKeys[m_fKeyB, ARow];
    pLI.SubItems.Clear;
    if GetBit(m_aMpValidRdKeys[m_fKeyB], ARow) then
    begin
      pLI.SubItems.Add('0x' + MfPlusKeyToStr4(pKI.m_rKey));
      pLI.SubItems.Add(pKI.m_sComment);
    end;
    if m_fCheckboxes then
      pLI.Checked := GetBit(m_aMpCheckRdKeys[m_fKeyB], ARow);
  finally
    lv.Items.EndUpdate;
  end;
end;

procedure TfmMfReaderMpKeysDlg.UpdateProperties;
var
  pKI: PMpKeyInfo;
begin
  m_nKeyIdx := ListView1.ItemIndex;
  if m_nKeyIdx <> -1 then
  begin
    pKI := @m_aMpRdKeys[m_fKeyB, m_nKeyIdx];
    edtKey.Text := MfPlusKeyToStr(pKI.m_rKey);
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
