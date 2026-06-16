unit uTmcPasswLVData;

interface

uses
  Vcl.ComCtrls,
  uClasses, uTypes;

type
  { TTmcPasswLVData }

  TTmcPasswLVData = class(TVirtualListViewData)
  public type
    TViewItem = record
      m_sIdx        : string;
      m_sPassword   : string;
      m_pPassword   : PTemicPassword;
    end;
    PViewItem = ^TViewItem;

  protected
    m_aCache        : TArray<TViewItem>;
    m_nCacheStart   : Integer;
    m_rTempViewItem : TViewItem;

  public
    m_pPasswords    : TTemicPasswordList;
    m_nPasswFormat  : TTmcPasswFormat;
    m_rNewPassword  : TTemicPassword;

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

{ TTmcPasswLVData }

constructor TTmcPasswLVData.Create;
begin
  inherited Create;
	m_nCacheStart	:= -1;
end;

procedure TTmcPasswLVData.DataHint(AStartIndex, AEndIndex: Integer);
begin
  if (m_aCache <> nil) and (AStartIndex >= m_nCacheStart) and
      (AEndIndex < (m_nCacheStart + Length(m_aCache))) then
    Exit;

	m_nCacheStart := AStartIndex;
  SetLength(m_aCache, AEndIndex - AStartIndex + 1);
  UpdateCache;
end;

function TTmcPasswLVData.GetCount: Integer;
begin
  Assert(m_pPasswords <> nil);

  Result := (m_pPasswords.Count + 1);
end;

procedure TTmcPasswLVData.GetData(AItem: TListItem);
var
  pItem: PViewItem;
begin
  pItem := RetrieveItem(AItem.Index);
  AItem.Caption := pItem.m_sIdx;
  Assert(AItem.SubItems.Count = 0);
  AItem.SubItems.Add(pItem.m_sPassword);
  AItem.SubItems.Add(pItem.m_pPassword.m_sComment);
end;

procedure TTmcPasswLVData.GetInfo(Idx: Integer; var VInfo: TViewItem);
var
  pPassword: PTemicPassword;
begin
  if Idx = m_pPasswords.Count then
    pPassword := @m_rNewPassword
  else
    pPassword := @m_pPasswords.List[Idx];
  VInfo.m_sIdx := IntToStr(1 + Idx);
  case m_nPasswFormat of
    tpfDec: VInfo.m_sPassword := IntToStr(pPassword.m_nPassword);
    tpfHex: VInfo.m_sPassword := IntToHex(pPassword.m_nPassword, 8);
    else Assert(False);
  end;
  VInfo.m_pPassword := pPassword;
end;

function TTmcPasswLVData.RetrieveItem(AIndex: Integer): PViewItem;
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

procedure TTmcPasswLVData.UpdateAllView;
begin
  UpdateCache;
  inherited;
end;

procedure TTmcPasswLVData.UpdateCache;
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
