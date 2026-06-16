unit uMfClassicKeysLvData;

interface

uses
  Vcl.ComCtrls,
  uClasses, uTypes;

type
  { TMfClassicKeysLvData }

  TMfClassicKeysLvData = class(TVirtualListViewData)
  public type
    TViewItem = record
      m_sIdx        : string;
      m_sKey        : string;
      m_pKI         : PMcKeyInfo;
    end;
    PViewItem = ^TViewItem;

  protected
    m_aCache        : TArray<TViewItem>;
    m_nCacheStart   : Integer;
    m_rTempViewItem : TViewItem;

  public
    m_pKeys         : TMfClassicKeyList;
    m_rNewKey       : TMcKeyInfo;

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
  System.Math, System.SysUtils;

{ TMfClassicKeysLvData }

constructor TMfClassicKeysLvData.Create;
begin
  inherited Create;
	m_nCacheStart	:= -1;
end;

procedure TMfClassicKeysLvData.DataHint(AStartIndex, AEndIndex: Integer);
begin
  if (m_aCache <> nil) and (AStartIndex >= m_nCacheStart) and
      (AEndIndex < (m_nCacheStart + Length(m_aCache))) then
    Exit;

	m_nCacheStart := AStartIndex;
  SetLength(m_aCache, AEndIndex - AStartIndex + 1);
  UpdateCache;
end;

function TMfClassicKeysLvData.GetCount: Integer;
begin
  Assert(m_pKeys <> nil);

  Result := (m_pKeys.Count + 1);
end;

procedure TMfClassicKeysLvData.GetData(AItem: TListItem);
var
  pItem: PViewItem;
begin
  pItem := RetrieveItem(AItem.Index);
  AItem.Caption := pItem.m_sIdx;
  Assert(AItem.SubItems.Count = 0);
  AItem.SubItems.Add(pItem.m_sKey);
  AItem.SubItems.Add(pItem.m_pKI.m_sComment);
end;

procedure TMfClassicKeysLvData.GetInfo(Idx: Integer; var VInfo: TViewItem);
var
  pKI: PMcKeyInfo;
begin
  if Idx = m_pKeys.Count then
    pKI := @m_rNewKey
  else
    pKI := @m_pKeys.List[Idx];
  VInfo.m_sIdx := IntToStr(1 + Idx);
  VInfo.m_sKey := '0x' + IntToHex(pKI.m_nKey, 12);
  VInfo.m_pKI := pKI;
end;

function TMfClassicKeysLvData.RetrieveItem(AIndex: Integer): PViewItem;
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

procedure TMfClassicKeysLvData.UpdateAllView;
begin
  UpdateCache;
  inherited;
end;

procedure TMfClassicKeysLvData.UpdateCache;
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
