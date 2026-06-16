unit uMfReaderSettings;

interface

uses
  IL.Readers,
  uTypes;

type
  { TMfReaderSettings - настройки считывателей Z-2 USB MF, Z-2 MFI, CP-Z2-MF,
    Matrix III Net }

  TMfReaderSettings = class
  public
    m_nReaderSn     : Integer;
    m_fModified     : Boolean;

    // Список ключей аутентификации Mifare Classic
    m_aMcRdKeys     : array[Boolean, 0..15] of TMCKeyInfo;
    m_aMcValidRdKeys: array[Boolean] of Cardinal;
    m_aMcCheckRdKeys: array[Boolean] of Cardinal;

    // Список ключей аутентификации Mifare Plus
    m_aMpRdKeys     : array[Boolean, 0..15] of TMpKeyInfo;
    m_aMpValidRdKeys: array[Boolean] of Cardinal;
    m_aMpCheckRdKeys: array[Boolean] of Cardinal;

  public
    procedure Load;
    procedure Save;

    // Ищет ключ в списке ключей Mifare Classic считывателя
    function FindClassicKey(AKeyB: Boolean; const AKey: TMfClassicKey): Integer;
    // Ищет ключ в списке ключей Mifare Plus считывателя
    function FindPlusKey(AKeyB: Boolean; const AKey: TMfPlusKey): Integer;
  end;

implementation

uses
  System.SysUtils, System.Classes, System.Math,
  IL.RUtils, uUtils;

const
  kMcKeyA = 'mcKeyA';
  kMcKeyB = 'mcKeyB';
  kValid = 'valid';
  kChecked = 'checked';
  kKeys = 'keys';
  kKey = 'key';
  kComment = 'comment';
  kMpKeyA = 'mpKeyA';
  kMpKeyB = 'mpKeyB';


{ TMfReaderSettings }

function TMfReaderSettings.FindClassicKey(AKeyB: Boolean;
  const AKey: TMfClassicKey): Integer;
begin
  for Result := 0 to High(m_aMcRdKeys[AKeyB]) do
    if GetBit(m_aMcValidRdKeys[AKeyB], Result) and
      (m_aMcRdKeys[AKeyB, Result].m_nKey = AKey) then
      Exit;
  Result := -1;
end;

function TMfReaderSettings.FindPlusKey(AKeyB: Boolean;
  const AKey: TMfPlusKey): Integer;
begin
  for Result := 0 to High(m_aMpRdKeys[AKeyB]) do
    if GetBit(m_aMpValidRdKeys[AKeyB], Result) and
      (m_aMpRdKeys[AKeyB, Result].m_rKey = AKey) then
      Exit;
  Result := -1;
end;

procedure TMfReaderSettings.Load;
var
  sPath, S: string;
  oStream: TFileStream;
  oBytes: TBytes;
  oJVal: TJSONValue;
  oJObj, oJObj2, oJObj3: TJSONObject;
  oJArr: TJSONArray;
  fKeyB, f: Boolean;
  I: Integer;
  pMCKI: PMcKeyInfo;
  pMPKI: PMpKeyInfo;
begin
  sPath := IncludeTrailingPathDelimiter(ExtractFileDir(ParamStr(0))) +
    format('Reader_%d.json', [m_nReaderSn]);
  if FileExists(sPath) then
  begin
    oStream := TFileStream.Create(sPath, fmOpenRead);
    try
      SetLength(oBytes, oStream.Size);
      oStream.ReadBuffer(Pointer(oBytes)^, oStream.Size);
    finally
      oStream.Free();
    end;
    oJVal := TJSONObject.ParseJSONValue(oBytes, 0);
    try
      if oJVal.TryGetObject(oJObj) then
      begin
        for fKeyB := False to True do
        begin
          if fKeyB then
            f := oJObj.GetValue(kMcKeyB).TryGetObject(oJObj2)
          else
            f := oJObj.GetValue(kMcKeyA).TryGetObject(oJObj2);
          if not f then
            continue;
          oJObj2.GetValue(kValid).TryGetCardinal(m_aMcValidRdKeys[fKeyB]);
          oJObj2.GetValue(kChecked).TryGetCardinal(m_aMcCheckRdKeys[fKeyB]);
          if oJObj2.GetValue(kKeys).TryGetArray(oJArr) then
          begin
            for I := 0 to min(High(m_aMcRdKeys[fKeyB]), oJArr.Count - 1) do
            begin
              pMcKI := @m_aMcRdKeys[fKeyB, I];
              if not oJArr.Get(I).TryGetObject(oJObj3) then
                continue;
              if oJObj3.GetValue(kKey).TryGetString(S) then
                TryStrToMfClassicKey(S, pMcKI.m_nKey);
              oJObj3.GetValue(kComment).TryGetString(pMcKI.m_sComment);
            end;
          end;
        end;

        for fKeyB := False to True do
        begin
          if fKeyB then
            f := oJObj.GetValue(kMpKeyB).TryGetObject(oJObj2)
          else
            f := oJObj.GetValue(kMpKeyA).TryGetObject(oJObj2);
          if not f then
            continue;
          oJObj2.GetValue(kValid).TryGetCardinal(m_aMpValidRdKeys[fKeyB]);
          oJObj2.GetValue(kChecked).TryGetCardinal(m_aMpCheckRdKeys[fKeyB]);
          if oJObj2.GetValue(kKeys).TryGetArray(oJArr) then
          begin
            for I := 0 to min(High(m_aMpRdKeys[fKeyB]), oJArr.Count - 1) do
            begin
              pMpKI := @m_aMpRdKeys[fKeyB, I];
              if not oJArr.Get(I).TryGetObject(oJObj3) then
                continue;
              if oJObj3.GetValue(kKey).TryGetString(S) then
                TryStrToMfPlusKey(S, pMpKI.m_rKey);
              oJObj3.GetValue(kComment).TryGetString(pMpKI.m_sComment);
            end;
          end;
        end;
      end;
    finally
      oJVal.Free;
    end;
  end;
  m_fModified := False;
end;

procedure TMfReaderSettings.Save;
var
  sPath: string;
  oFile: TStringStream;
  oJObj, oJObj2, oJObj3: TJSONObject;
  oJArr: TJSONArray;
  fKeyB: Boolean;
  I: Integer;
  pMcKI: PMcKeyInfo;
  pMpKI: PMpKeyInfo;
begin
  sPath := IncludeTrailingPathDelimiter(ExtractFileDir(ParamStr(0))) +
    format('Reader_%d.json', [m_nReaderSn]);
  oJObj := TJSONObject.Create;
  try
    // mcKeysA { valid: 0; checked: 0; keys: [] }
    // mcKeysB { valid: 0; checked: 0; keys: [] }
    // mpKeysA { valid: 0; checked: 0; keys: [] }
    // mpKeysB { valid: 0; checked: 0; keys: [] }

    for fKeyB := False to True do
    begin
      oJObj2 := TJSONObject.Create();
      oJObj2.AddPair(kValid, TJSONNumber.Create(m_aMcValidRdKeys[fKeyB]));
      oJObj2.AddPair(kChecked, TJSONNumber.Create(m_aMcCheckRdKeys[fKeyB]));
      oJArr := TJSONArray.Create();
      for I := 0 to High(m_aMcRdKeys[fKeyB]) do
      begin
        pMcKI := @m_aMcRdKeys[fKeyB, I];
        oJObj3 := TJSONObject.Create();
        oJObj3.AddPair(kKey, MfClassicKeyToStr(pMcKI.m_nKey));
        oJObj3.AddPair(kComment, pMcKI.m_sComment, True);
        oJArr.AddElement(oJObj3);
      end;
      oJObj2.AddPair(kKeys, oJArr);
      if fKeyB then
        oJObj.AddPair(kMCKeyB, oJObj2)
      else
        oJObj.AddPair(kMCKeyA, oJObj2);
    end;
    for fKeyB := False to True do
    begin
      oJObj2 := TJSONObject.Create();
      oJObj2.AddPair(kValid, TJSONNumber.Create(m_aMpValidRdKeys[fKeyB]));
      oJObj2.AddPair(kChecked, TJSONNumber.Create(m_aMpCheckRdKeys[fKeyB]));
      oJArr := TJSONArray.Create();
      for I := 0 to High(m_aMpRdKeys[fKeyB]) do
      begin
        pMpKI := @m_aMpRdKeys[fKeyB, I];
        oJObj3 := TJSONObject.Create();
        oJObj3.AddPair(kKey, MfPlusKeyToStr(pMpKI.m_rKey));
        oJObj3.AddPair(kComment, pMpKI.m_sComment, True);
        oJArr.AddElement(oJObj3);
      end;
      oJObj2.AddPair(kKeys, oJArr);
      if fKeyB then
        oJObj.AddPair(kMpKeyB, oJObj2)
      else
        oJObj.AddPair(kMpKeyA, oJObj2);
    end;
    oFile := TStringStream.Create(oJObj.ToString, TEncoding.UTF8);
    try
      oFile.SaveToFile(sPath);
    finally
      oFile.Free();
    end;
  finally
    oJObj.Free;
  end;
  m_fModified := False;
end;

end.
