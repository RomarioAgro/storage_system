unit uReaderLVData;

interface

uses
  Vcl.ComCtrls,
  IL.Readers, uClasses, uTypes;

type
  { TReaderVLVData }

  TReaderLVData = class(TVirtualListViewData)
  public type
    TViewItem = record
      m_sSn         : string;
      m_sFwVersion  : string;
      m_sFwBuild    : string;
      m_pRI         : PReaderInfo;
    end;
    PViewItem = ^TViewItem;

  protected
    m_aCache        : TArray<TViewItem>;
    m_nCacheStart   : Integer;
    m_rTempViewItem : TViewItem;

  public
    m_pReaders      : TReaderInfoList;

  protected
    procedure UpdateCache;
    procedure GetInfo(Idx: Integer; var VInfo: TViewItem);

  public
    constructor Create;

    function GetCount: Integer; override;
    procedure GetData(AItem: TListItem); override;
    procedure DataHint(AStartIndex, AEndIndex: Integer); override;
    procedure UpdateAllView; override;

    function RetrieveItem(AIndex: Integer): PViewItem;
  end;

implementation

uses
  System.Math, System.SysUtils,
  IL.RUtils;


{ TReaderLVData }

constructor TReaderLVData.Create;
begin
  inherited Create;
	m_nCacheStart	:= -1;
end;

procedure TReaderLVData.DataHint(AStartIndex, AEndIndex: Integer);
begin
  if (m_aCache <> nil) and (AStartIndex >= m_nCacheStart) and
      (AEndIndex < (m_nCacheStart + Length(m_aCache))) then
    Exit;

	m_nCacheStart := AStartIndex;
  SetLength(m_aCache, AEndIndex - AStartIndex + 1);
  UpdateCache;
end;

function TReaderLVData.GetCount: Integer;
begin
  Assert(m_pReaders <> nil);

  Result := m_pReaders.Count;
end;

procedure TReaderLVData.GetData(AItem: TListItem);
var
  pItem: PViewItem;
begin
  pItem := RetrieveItem(AItem.Index);
  AItem.Caption := StrPas(pItem.m_pRI.szPortName);
  Assert(AItem.SubItems.Count = 0);
  AItem.SubItems.Add(kRdModelNames[pItem.m_pRI.nModel]);
  AItem.SubItems.Add(pItem.m_sSn);
  AItem.SubItems.Add(pItem.m_sFwVersion);
  AItem.SubItems.Add(pItem.m_sFwBuild);
end;

procedure TReaderLVData.GetInfo(Idx: Integer; var VInfo: TViewItem);
var
  pRI: PReaderInfo;
begin
  pRI := @m_pReaders.List[Idx];
  if pRI.nSn <> -1 then
    VInfo.m_sSn := IntToStr(pRI.nSn)
  else
    VInfo.m_sSn := string.Empty;
  if pRI.nFwVersion <> 0 then
    VInfo.m_sFwVersion := ILRVersionToStr(pRI.nFwVersion)
  else
    VInfo.m_sFwVersion := string.Empty;
  if pRI.nFwBuildDate <> 0 then
    VInfo.m_sFwBuild := ILRTimeToStr(pRI.nFwBuildDate)
  else
    VInfo.m_sFwBuild := string.Empty;

  VInfo.m_pRI := pRI;
end;

function TReaderLVData.RetrieveItem(AIndex: Integer): PViewItem;
begin
	if (AIndex >= m_nCacheStart) and
      (AIndex < m_nCacheStart + Length(m_aCache)) then
  begin
    Result := @m_aCache[AIndex - m_nCacheStart];
  end
  else
  begin
    GetInfo(AIndex, m_rTempViewItem);
    Result := @m_rTempViewItem;
  end;
end;

procedure TReaderLVData.UpdateAllView;
begin
  UpdateCache;
  inherited;
end;

procedure TReaderLVData.UpdateCache;
var
  nCount, I: Integer;
begin
  if Length(m_aCache) = 0 then
    Exit;

  nCount := min(Length(m_aCache), GetCount - m_nCacheStart);
  for I := 0 to nCount - 1 do
    GetInfo(m_nCacheStart + I, m_aCache[I]);
end;

end.
