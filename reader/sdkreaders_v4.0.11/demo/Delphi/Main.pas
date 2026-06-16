unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.Actions,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Menus, Vcl.ActnList,
  IL.Readers, IL.RUtils, uConst, uTypes, uClasses, uReaderLVData, uAppSettings;

const
  UM_ILRSEARCH_NOTIFY = (WM_USER + 1);

type
  TfmMain = class(TForm)
    ListView1: TListView;
    Panel1: TPanel;
    StatusBar1: TStatusBar;
    btnRescan: TButton;
    btnOpen: TButton;
    PopupMenu1: TPopupMenu;
    miReaderTypes: TMenuItem;
    miILUsbReaders: TMenuItem;
    miTPUsbReaders: TMenuItem;
    miCcidReaders: TMenuItem;
    N1: TMenuItem;
    miWriteDebugLog: TMenuItem;
    Debugloglevel1: TMenuItem;
    miDLogLevelAssert: TMenuItem;
    miDLogLevelError: TMenuItem;
    miDLogLevelWarning: TMenuItem;
    miDLogLevelInfo: TMenuItem;
    miDLogLevelVerbose: TMenuItem;
    miDLogLevelDebug: TMenuItem;
    edtPort: TEdit;
    cbConnectModel: TComboBox;
    ActionList1: TActionList;
    actOpen: TAction;
    miLanguage: TMenuItem;
    miEnglish: TMenuItem;
    miShowUnidentified: TMenuItem;
    miServerReaders: TMenuItem;
    miClientReaders: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ListView1Data(Sender: TObject; Item: TListItem);
    procedure ListView1DataHint(Sender: TObject; StartIndex, EndIndex: Integer);
    procedure btnRescanClick(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure miILUsbReadersClick(Sender: TObject);
    procedure miTPUsbReadersClick(Sender: TObject);
    procedure miCcidReadersClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListView1DblClick(Sender: TObject);
    procedure ListView1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure miWriteDebugLogClick(Sender: TObject);
    procedure miDLogLevelAssertClick(Sender: TObject);
    procedure miDLogLevelErrorClick(Sender: TObject);
    procedure miDLogLevelWarningClick(Sender: TObject);
    procedure miDLogLevelInfoClick(Sender: TObject);
    procedure miDLogLevelVerboseClick(Sender: TObject);
    procedure miDLogLevelDebugClick(Sender: TObject);
    procedure ListView1SelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure actOpenExecute(Sender: TObject);
    procedure actOpenUpdate(Sender: TObject);
    procedure miLanguageClick(Sender: TObject);
    procedure miShowUnidentifiedClick(Sender: TObject);
    procedure miEnglishClick(Sender: TObject);
    procedure miServerReadersClick(Sender: TObject);
    procedure miClientReadersClick(Sender: TObject);
  private
    { Private declarations }
    procedure UmILRSearch_Notify(var Msg: TMessage); message UM_ILRSEARCH_NOTIFY;
    procedure LVDUpdateAllView(Sender: TObject);
    procedure miLangXClick(Sender: TObject);

    procedure UpdateLanguages;
    function Restart: Boolean;

  public
    { Public declarations }
    m_oLanguages    : TLangInfoList;
    m_iILR          : IILR;
    m_iSearch       : IILRSearch;
    m_oReaders      : TReaderInfoList;
    m_oLVD          : TReaderLVData;

    procedure UpdateListView;
    procedure DoToggleReaderType(AType: TReaderType);
    function DoOpen: Boolean;
    function OpenTemicReader(AReader: IILReader): Boolean;
    function OpenMifareReader(AReader: IILReader): Boolean;
    function OpenReader(AReader: IILReader): Boolean;
    procedure UpdateDebugLog;
  end;

var
  fmMain: TfmMain;
  g_nActiveLang: Cardinal {= 0};

procedure AppInit();

implementation

uses
  System.Generics.Defaults,
  reinit, uAppHelp, ReaderDlg, TmcReaderDlg, MfReaderDlg, AsyncProgressDlg;

{$R *.dfm}

procedure SearchNotifyCallback(AMsg: TSearchMsg;
  AMsgData: Pointer; AUserData: Pointer); stdcall;
begin
  PostMessage(TfmMain(AUserData).Handle, UM_ILRSEARCH_NOTIFY, 0, 0);
end;

procedure TfmMain.actOpenExecute(Sender: TObject);
begin
  DoOpen;
end;

procedure TfmMain.actOpenUpdate(Sender: TObject);
begin
  actOpen.Enabled := (edtPort.GetTextLen > 0);
end;

procedure TfmMain.btnRescanClick(Sender: TObject);
var
  nStartTick, nSpan: Cardinal;
  iAsync: IILRSearchAsync;
  iCmd: IILRAsyncCommand;
  oDlg: TfmAsyncProgressDlg;
begin
  StatusBar1.SimpleText := SSearching;
  Application.ProcessMessages;
  nStartTick := GetTickCount;
  try
//    m_iSearch.Scan(True);
    iAsync := m_iSearch as IILRSearchAsync;
    iCmd := iAsync.Begin_Scan(True);
    oDlg := TfmAsyncProgressDlg.Create(Self);
    try
      oDlg.PopupParent := Self;

      oDlg.FOnCancel := procedure(ADlg: TfmAsyncProgressDlg)
      begin
        iCmd.Cancel;
        ADlg.Close;
      end;
      oDlg.FOnGetProgress := procedure(ADlg: TfmAsyncProgressDlg)
      begin
        if iCmd.GetStatus <> E_PENDING then
        begin
          ADlg.Close;
          Exit;
        end;
      end;
      oDlg.SetProgress(0, 0);
      oDlg.ShowModal;
    finally
      oDlg.Free;
    end;
    UpdateListView;
  finally
    nSpan := GetTickSpan(nStartTick, GetTickCount);
    StatusBar1.SimpleText := format(SSearchComplite_F, [nSpan / 1000.0]);
  end;
end;

function TfmMain.DoOpen: Boolean;
var
  sPortName: string;
  nIdx: Integer;
  pRI: PReaderInfo;
  rRI: TReaderInfo;
  iReader: IILReader;
  nPortType: TPortType;
  nModel: TReaderModel;
begin
  sPortName := edtPort.Text;
  if sPortName.IsEmpty then
    Exit(False);

  nModel := TReaderModel(cbConnectModel.ItemIndex);
  nIdx := m_oReaders.IndexOfPort(sPortName);
  if nIdx <> -1 then
  begin
    pRI := @m_oReaders.List[nIdx];
    if nModel = rmUnknownModel then
      nModel := pRI.nModel;
    iReader := m_iILR.GetReader(pRI.nPortType, pRI.szPortName);
    iReader.SetModelToConnect(nModel);
  end
  else
  begin
    if sscanf(sPortName, 'COM%d', [@nIdx]) = 1 then
      nPortType := TPortType.ptComPort
    else
      nPortType := TPortType.ptServer;
    iReader := m_iILR.GetReader(nPortType, PWideChar(sPortName));
    iReader.SetModelToConnect(nModel);
    iReader.Connect;
    iReader.GetReaderInfo(rRI);
    if rRI.nModel <> rmUnknownModel then
      nModel := rRI.nModel;
  end;

  case nModel of
    rmZ2RDALL,
    rmZ2EHR:
      Result := OpenTemicReader(iReader);

    rmZ2UsbMf,
    rmZ2MFI,
    rmMatrix3Net,
    rmCpZ2Mf,
    rmZ2MfCcid,
    rmMatrix6:
      Result := OpenMifareReader(iReader);

    else
      Result := OpenReader(iReader);
  end;
end;

procedure TfmMain.DoToggleReaderType(AType: TReaderType);
var
  nTypes: TReaderTypes;
begin
  nTypes := g_AppSet.m_nReaderTypes;
  if AType in g_AppSet.m_nReaderTypes then
    Exclude(nTypes, AType)
  else
    Include(nTypes, AType);
  g_AppSet.SetReaderTypes(nTypes);
  m_iSearch.SetReaderTypes(ReaderTypesToFlags(nTypes));
end;

procedure TfmMain.FormClose(Sender: TObject; var Action: TCloseAction);
var
  rWP: TWindowPlacement;
  rSize: TSize;
begin
  FillChar(rWP, SizeOf(rWP), 0);
  rWP.length := SizeOf(rWP);
  GetWindowPlacement(Self.Handle, rWP);
  rSize := rWP.rcNormalPosition.Size;
  if g_AppSet.m_aWinSizes[swMainWnd] <> rSize then
    g_AppSet.SetWinSize(swMainWnd, rSize);

  if g_AppSet.m_fModified then
    g_AppSet.Save;
end;

procedure TfmMain.FormCreate(Sender: TObject);
const
  kListenTcp: array[0..0] of Word = (25000);
var
  cb: TCombobox;
  nModel: TReaderModel;
  rSize: TSize;
begin
  HelpContext := HIDD_MAIN;
  Application.HelpFile := ExtractFileDir(ParamStr(0)) + '\Help\ILReaders_RUS.chm';

  m_oLanguages := TLangInfoList.Create;
  UpdateLanguages;

  m_oReaders := TReaderInfoList.Create;
  m_oLVD := TReaderLVData.Create;
  m_oLVD.m_pReaders := m_oReaders;
  m_oLVD.OnUpdateAllView := LVDUpdateAllView;

  cb := cbConnectModel;
  cb.Items.BeginUpdate;
  try
    cb.Items.Clear;
    cb.Items.Add(SAuto);
    for nModel := rmZ2RDALL to High(kRdModelNames) do
      cb.Items.Add(kRdModelNames[nModel]);
    cb.ItemIndex := 0;
  finally
    cb.Items.EndUpdate;
  end;

  Assert(g_AppSet <> nil);
  rSize := g_AppSet.m_aWinSizes[swMainWnd];
  if (rSize.cx <> 0) and (rSize.cy <> 0) then
  begin
    Width := rSize.cx;
    Height := rSize.cy;
  end;

  ILRCheck(LoadILR);
  ILRCheck(ILR_GetInterface(m_iILR));

  UpdateDebugLog;

  m_iSearch := m_iILR.GetSearch;
  m_iSearch.EnableMsgQueue;
  m_iSearch.SetNotifyCallback(SearchNotifyCallback, Self);

  m_iSearch.SetReaderTypes(ReaderTypesToFlags(g_AppSet.m_nReaderTypes));
  m_iSearch.SetListenTcpPorts(@kListenTcp, Length(kListenTcp));
  m_iSearch.EnableAutoScan(True, False);
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  m_iSearch := nil;
  m_iILR := nil;
  if IsILRLoaded then
    UnloadILR;

  m_oLVD.Free;
  m_oReaders.Free;
  m_oLanguages.Free;
  FreeAndNil(g_AppSet);
end;

procedure TfmMain.FormShow(Sender: TObject);
begin
  UpdateListView;
end;

procedure TfmMain.ListView1Data(Sender: TObject; Item: TListItem);
begin
  m_oLVD.GetData(Item);
end;

procedure TfmMain.ListView1DataHint(Sender: TObject; StartIndex,
  EndIndex: Integer);
begin
  m_oLVD.DataHint(StartIndex, EndIndex);
end;

procedure TfmMain.ListView1DblClick(Sender: TObject);
begin
  DoOpen;
end;

procedure TfmMain.ListView1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_RETURN) and (Shift = []) then
    DoOpen;
end;

procedure TfmMain.ListView1SelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var
  pRI: PReaderInfo;
begin
  if Selected then
  begin
    pRI := @m_oReaders.List[Item.Index];
    edtPort.Text := pRI.szPortName;
    cbConnectModel.ItemIndex := Integer(pRI.nModel);
    btnOpen.Enabled := True;
  end
  else
  begin
    edtPort.Text := string.Empty;
    cbConnectModel.ItemIndex := 0;
    btnOpen.Enabled := False;
  end;
end;

procedure TfmMain.miCcidReadersClick(Sender: TObject);
begin
  DoToggleReaderType(rtCcid);
end;

procedure TfmMain.miClientReadersClick(Sender: TObject);
begin
  DoToggleReaderType(rtClient);
end;

procedure TfmMain.miDLogLevelAssertClick(Sender: TObject);
begin
  g_AppSet.SetDebugLogLevel(TLogLevel.llAssert);
  UpdateDebugLog;
end;

procedure TfmMain.miDLogLevelDebugClick(Sender: TObject);
begin
  g_AppSet.SetDebugLogLevel(TLogLevel.llDebug);
  UpdateDebugLog;
end;

procedure TfmMain.miDLogLevelErrorClick(Sender: TObject);
begin
  g_AppSet.SetDebugLogLevel(TLogLevel.llError);
  UpdateDebugLog;
end;

procedure TfmMain.miDLogLevelInfoClick(Sender: TObject);
begin
  g_AppSet.SetDebugLogLevel(TLogLevel.llInfo);
  UpdateDebugLog;
end;

procedure TfmMain.miDLogLevelVerboseClick(Sender: TObject);
begin
  g_AppSet.SetDebugLogLevel(TLogLevel.llVerbose);
  UpdateDebugLog;
end;

procedure TfmMain.miDLogLevelWarningClick(Sender: TObject);
begin
  g_AppSet.SetDebugLogLevel(TLogLevel.llWarning);
  UpdateDebugLog;
end;

procedure TfmMain.miEnglishClick(Sender: TObject);
begin
  g_AppSet.SetLanguage(0);
  Restart();
end;

procedure TfmMain.miILUsbReadersClick(Sender: TObject);
begin
  DoToggleReaderType(rtILUsb);
end;

procedure TfmMain.miServerReadersClick(Sender: TObject);
begin
  DoToggleReaderType(rtServer);
end;

procedure TfmMain.miLanguageClick(Sender: TObject);
var
  I: Integer;
  mi: TMenuItem;
  pLI: TLangInfo;
begin
  for I := miLanguage.Count - 1 downto 1 do
    miLanguage.Delete(I);
  miLanguage[0].Checked := (g_nActiveLang = 0);
  for I := 0 to m_oLanguages.Count - 1 do
  begin
    pLI := m_oLanguages[i];
    mi := TMenuItem.Create(Self);
    mi.Caption := pLI.m_sName;
    mi.Tag := (1 + i);
    mi.RadioItem := True;
    mi.Checked := (g_nActiveLang = pLI.m_nLocale);
    mi.OnClick := miLangXClick;
    miLanguage.Add(mi);
  end;
end;

procedure TfmMain.miLangXClick(Sender: TObject);
var
  nIdx: Integer;
  nLanguage: Cardinal;
begin
  nIdx := ((Sender as TMenuItem).Tag - 1);
  if nIdx = -1 then
    nLanguage := 0
  else
  begin
    ASSERT((nIdx >= 0) and (nIdx < m_oLanguages.Count));
    nLanguage := m_oLanguages[nIdx].m_nLocale;
  end;
  g_AppSet.SetLanguage(nLanguage);
  Restart();
end;

procedure TfmMain.miShowUnidentifiedClick(Sender: TObject);
begin
  g_AppSet.ShowUnidentified(not g_AppSet.m_fShowUnidentified);
  UpdateListView;
end;

procedure TfmMain.miTPUsbReadersClick(Sender: TObject);
begin
  DoToggleReaderType(rtTPUsb);
end;

procedure TfmMain.miWriteDebugLogClick(Sender: TObject);
begin
  g_AppSet.SetDebugLog(not g_AppSet.m_fDebugLog);
  UpdateDebugLog;
end;

function TfmMain.OpenMifareReader(AReader: IILReader): Boolean;
var
  oDlg: TfmMfReaderDlg;
begin
  oDlg := TfmMfReaderDlg.Create(Self);
  try
    oDlg.PopupParent := Self;
    oDlg.m_iReader := AReader;

    Result := (oDlg.ShowModal = mrOk);
  finally
    oDlg.Free;
  end;
end;

function TfmMain.OpenReader(AReader: IILReader): Boolean;
var
  oDlg: TfmReaderDlg;
begin
  oDlg := TfmReaderDlg.Create(Self);
  try
    oDlg.PopupParent := Self;
    oDlg.m_iReader := AReader;

    Result := (oDlg.ShowModal = mrOk);
  finally
    oDlg.Free;
  end;
end;

function TfmMain.OpenTemicReader(AReader: IILReader): Boolean;
var
  oDlg: TfmTmcReaderDlg;
begin
  oDlg := TfmTmcReaderDlg.Create(Self);
  try
    oDlg.PopupParent := Self;
    oDlg.m_iReader := AReader;

    Result := (oDlg.ShowModal = mrOk);
  finally
    oDlg.Free;
  end;
end;

procedure TfmMain.PopupMenu1Popup(Sender: TObject);
begin
  miILUsbReaders.Checked := (rtILUsb in g_AppSet.m_nReaderTypes);
  miTPUsbReaders.Checked := (rtTPUsb in g_AppSet.m_nReaderTypes);
  miCcidReaders.Checked := (rtCcid in g_AppSet.m_nReaderTypes);
  miServerReaders.Checked := (rtServer in g_AppSet.m_nReaderTypes);
  miClientReaders.Checked := (rtClient in g_AppSet.m_nReaderTypes);
  miShowUnidentified.Checked := g_AppSet.m_fShowUnidentified;

  miDLogLevelAssert.Checked := (g_AppSet.m_nDLogLevel = llAssert);
  miDLogLevelError.Checked := (g_AppSet.m_nDLogLevel = llError);
  miDLogLevelWarning.Checked := (g_AppSet.m_nDLogLevel = llWarning);
  miDLogLevelInfo.Checked := (g_AppSet.m_nDLogLevel = llInfo);
  miDLogLevelDebug.Checked := (g_AppSet.m_nDLogLevel = llDebug);
  miDLogLevelVerbose.Checked := (g_AppSet.m_nDLogLevel = llVerbose);
  miWriteDebugLog.Checked := g_AppSet.m_fDebugLog;
end;

function TfmMain.Restart: Boolean;
var
  si: TStartupInfo;
  pi: TProcessInformation;
  sCmdLine: String;
begin
  fmMain.Close();
  Application.ProcessMessages();
  if not Application.Terminated then
    Exit(False);
  FillChar(si, SizeOf(si), 0);
  si.cb := SizeOf(si);
  FillChar(pi, SizeOf(pi), 0);
  sCmdLine := GetCommandLine();
  Result := CreateProcess(nil, PChar(sCmdLine), nil, nil, False, 0, nil, nil, si, pi);
  if Result then
  begin
    CloseHandle(pi.hProcess);
    CloseHandle(pi.hThread);
  end;
end;

procedure TfmMain.UmILRSearch_Notify(var Msg: TMessage);
var
  nMsg: TSearchMsg;
  nMsgData: Pointer;
  pRI: PReaderInfo;
  S: string;
begin
  while m_iSearch.GetMessage(nMsg, nMsgData) do
  begin
    case nMsg of
      smReaderFound:
      begin
        pRI := PReaderInfo(nMsgData);
        S := format(SReaderFound_SSS, [
          TimeToStr(Now),
          StrPas(pRI.szPortName),
          kRdModelNames[pRI.nModel]]);
        if pRI.nSn <> -1 then
          S := S + ' ' + format(SSn_D, [pRI.nSn]);
        StatusBar1.SimpleText := S;
        UpdateListView;
      end;

      smReaderLost:
      begin
        pRI := PReaderInfo(nMsgData);
        S := format(SReaderLost_SSS, [
          TimeToStr(Now),
          StrPas(pRI.szPortName),
          kRdModelNames[pRI.nModel]]);
        if pRI.nSn <> -1 then
          S := S + ' ' + format(SSn_D, [pRI.nSn]);
        StatusBar1.SimpleText := S;
        UpdateListView;
      end;

//      smListChanged:
//        UpdateListView;
    end;
  end;
end;

procedure TfmMain.UpdateDebugLog;
var
  sPath: string;
  nLevel: TLogLevel;
begin
  if g_AppSet.m_fDebugLog then
    nLevel := g_AppSet.m_nDLogLevel
  else
    nLevel := llDisabled;
  if m_iILR.GetLogLevel() <> nLevel then
  begin
    if m_iILR.GetLogLevel() = llDisabled then
    begin
      sPath := ChangeFileExt(ParamStr(0), '.log');
      m_iILR.SetLogPath(PWideChar(sPath));
      m_iILR.ClearLog;
    end;
    m_iILR.SetLogLevel(nLevel);
  end;
end;

procedure TfmMain.UpdateLanguages;
var
  sr: TSearchRec;
  I: Integer;
  rLI: TLangInfo;
begin
  m_oLanguages.Clear;
  // Ищем файлы
  if FindFirst(ChangeFileExt(ParamStr(0), '*'), faAnyFile, sr) = 0 then
  begin
    try
      repeat
        if (sr.Attr and faDirectory) <> 0 then
          continue;

        rLI.m_sExt := UpperCase(Copy(sr.Name, LastDelimiter('.', sr.Name) + 1, MaxInt));
        for I := 0 to System.SysUtils.Languages.Count - 1 do
          if System.SysUtils.Languages.Ext[I] = rLI.m_sExt then
          begin
            rLI.m_nLocale := System.SysUtils.Languages.LocaleID[I];
            rLI.m_sName := System.SysUtils.Languages.Name[I];
            m_oLanguages.Add(rLI);
            break;
          end;
      until FindNext(sr) <> 0;
    finally
      FindClose(sr);
    end;
  end;
  if m_oLanguages.Count > 1 then
    // Сортируем список языков
    m_oLanguages.Sort(TComparer<TLangInfo>.Construct(
      function(const Left, Right: TLangInfo): Integer
      begin
        Result := CompareStr(Left.m_sName, Right.m_sName);
      end
    ));
end;

procedure TfmMain.UpdateListView;
var
  I, nCount: Integer;
  rRI: TReaderInfo;
begin
  nCount := m_iSearch.GetReaderCount;
  m_oReaders.Capacity := nCount;
  m_oReaders.Clear;
  for I := 0 to nCount - 1 do
  begin
    m_iSearch.GetReaderInfo(I, rRI);
    if (rRI.nModel <> rmUnknownModel) or g_AppSet.m_fShowUnidentified then
      m_oReaders.Add(rRI);
  end;
  m_oLVD.UpdateAllView;
end;

procedure TfmMain.LVDUpdateAllView(Sender: TObject);
begin
  ListView1.Items.Count := m_oLVD.GetCount;
  ListView1.Invalidate;
end;

procedure AppInit();
begin
  Assert(g_AppSet = nil);
  g_AppSet := TAppSettings.Create;
  g_AppSet.Load;
  if g_AppSet.m_nLanguageId <> 0 then
  begin
    if LoadNewResourceModule(g_AppSet.m_nLanguageId) <> 0 then
      g_nActiveLang := g_AppSet.m_nLanguageId;
  end;
end;

end.
