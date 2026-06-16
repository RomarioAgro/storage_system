program MfPlus;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  WinApi.Windows,
  System.SysUtils, System.StrUtils, System.Types, System.IniFiles,
  System.Classes,
  IL.Readers, IL.RUtils;

var
  g_AuthKey: TMfPlusKey;        // Ключ аутентификации Mifare
  g_fAuthKeyB: Boolean = False; // True, авторизовать по ключу B, иначе - A
  g_fOpenText: Boolean = True;  // True, открытая передача, иначе - зашифрованная
  g_nRdKeys: Cardinal = 0; // Биты ключей аутентификации считывателя
  g_aSavedRdKeys: array[Boolean, 0..15] of TMfPlusKey; // Сохранённые ключи считывателя
  g_aSavedRdKeyValid: array[Boolean] of Word;

const
  kKeyTypeChars: array[Boolean] of string = ('A', 'B');

{$REGION 'Функции загрузки/сохранения настроек'}
procedure LoadSettings();
var
  oIni: TIniFile;
  rKey: TMfPlusKey;
  f: Boolean;
  oStrs: TStringList;
  I, nKeyIdx: Integer;
begin
  oIni := TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini'));
  try
    if HexToBin(PWideChar(oIni.ReadString('Main', 'AuthKey', '')), rKey.a,
        Length(rKey.a)) = Length(rKey.a) then
      g_AuthKey := rKey;
    g_fAuthKeyB := oIni.ReadBool('Main', 'KeyB', g_fAuthKeyB);
    g_nRdKeys := Cardinal(oIni.ReadInteger('Main', 'RdKeys', Integer(g_nRdKeys)));

    oStrs := TStringList.Create();
    try
      for f := Low(g_aSavedRdKeys) to High(g_aSavedRdKeys) do
      begin
        if f then
          oIni.ReadSectionValues('RdBKeys', oStrs)
        else
          oIni.ReadSectionValues('RdAKeys', oStrs);
        for I := 0 to oStrs.Count - 1 do
        begin
          if (not TryStrToInt(oStrs.Names[I], nKeyIdx)) or
              (nKeyIdx < 0) or (nKeyIdx > High(g_aSavedRdKeys[f])) then
            continue;
          if HexToBin(PWideChar(oStrs.ValueFromIndex[I]), rKey.a,
              Length(rKey.a)) = Length(rKey.a) then
          begin
            g_aSavedRdKeys[f, nKeyIdx] := rKey;
            g_aSavedRdKeyValid[f] := g_aSavedRdKeyValid[f] or (1 shl nKeyIdx);
          end;
        end;
      end;
    finally
      oStrs.Free();
    end;
  finally
    oIni.Free();
  end;
end;
procedure SaveRdKey(AKeyIdx: Integer; AKeyB: Boolean; const AKey: TMfPlusKey);
var
  oIni: TIniFile;
  S: string;
begin
  oIni := TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini'));
  try
    SetLength(s, Length(AKey.a) * 2);
    BinToHex(PAnsiChar(@AKey.a), PChar(s), Length(AKey.a));
    if AKeyB then
      oIni.WriteString('RdBKeys', IntToStr(AKeyIdx), s)
    else
      oIni.WriteString('RdAKeys', IntToStr(AKeyIdx), s);
  finally
    oIni.Free();
  end;
end;
procedure SaveKeyType();
var
  oIni: TIniFile;
begin
  oIni := TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini'));
  try
    oIni.WriteBool('Main', 'KeyB', g_fAuthKeyB);
  finally
    oIni.Free();
  end;
end;
procedure SaveAuthKey();
var
  oIni: TIniFile;
  S: string;
begin
  oIni := TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini'));
  try
    SetLength(s, Length(g_AuthKey.a) * 2);
    BinToHex(PAnsiChar(@g_AuthKey.a), PChar(s), Length(g_AuthKey.a));
    oIni.WriteString('Main', 'AuthKey', S);
  finally
    oIni.Free();
  end;
end;
procedure SaveRdKeys();
var
  oIni: TIniFile;
begin
  oIni := TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini'));
  try
    oIni.WriteInteger('Main', 'RdKeys', Integer(g_nRdKeys));
  finally
    oIni.Free();
  end;
end;
{$ENDREGION} // Функции загрузки/сохранения настроек

procedure DoReadPlusSL3(AReader: IILReader);
const
  kOpenText: array[Boolean] of string = ( 'Зашифрованная передача', 'Открытая передача' );
var
  rCI: TCardInfo;
  I, nBlockMax, nRead, nSectN, nSBlockN, nSTrailer, nAreaN: Integer;
  oBlocks: array of TMfBlockData;
  pBData: PMfBlockData;
  nStartTick, nSpan, nAccessBits, nC1, nC2, nC3, nAreaAccess: Cardinal;
  nEn: Byte;
begin
  try
    AReader.GetCardInfo(rCI);
    nBlockMax := rCI.GetNumberOfMfBlocks();
    SetLength(oBlocks, nBlockMax);
    Write('Чтение данных карты... ');
    nStartTick := GetTickCount();
    if g_nRdKeys <> 0 then
    begin
      I := AReader.AuthMfCardByRdKeys(0, g_fAuthKeyB, g_nRdKeys);
      if I = -1 then
      begin
        Writeln('Нет подходящего ключа аутентификации');
        Exit;
      end;
    end
    else
    begin
      AReader.LoadMfPlusAuthKey(g_AuthKey);
      if not AReader.AuthMfCard(0, g_fAuthKeyB) then
      begin
        Writeln('Ключ аутентификации не подошёл');
        Exit;
      end;
    end;
    AReader.ReadMfPlus(0, @oBlocks[0], Length(oBlocks), g_fOpenText, @nRead);
    nSpan := GetTickSpan(nStartTick, GetTickCount());
    Writeln(format('прочитано %d блоков за %d мс', [nRead, nSpan]));

    nSectN := 0;
    nSBlockN := 0;
    nSTrailer := 0;
    nC1 := 0; nC2 := 0; nC3 := 0;
    nEn := 0;
    for I := 0 to nRead - 1 do
    begin
      if nSBlockN = 0 then
      begin
        if I < 128 then
          nSTrailer := 3
        else
          nSTrailer := 15;
        pBData := @oBlocks[I + nSTrailer - nSBlockN];
        nAccessBits := 0;
        Move(pBData.a[6], nAccessBits, 3);
        nC1 := (nAccessBits shr 12) and $F;
        nC2 := (nAccessBits shr 16) and $F;
        nC3 := (nAccessBits shr 20) and $F;
        nEn := pBData.a[5];
      end;

      pBData := @oBlocks[I];
      // Выводим байты блока
      Writeln(format('%.2d (%.2d). %.2X %.2X %.2X %.2X %.2X %.2X %.2X %.2X %.2X %.2X %.2X %.2X %.2X %.2X %.2X %.2X', [
          I, nSectN,
          pBData.a[0], pBData.a[1], pBData.a[2], pBData.a[3],
          pBData.a[4], pBData.a[5], pBData.a[6], pBData.a[7],
          pBData.a[8], pBData.a[9], pBData.a[10], pBData.a[11],
          pBData.a[12], pBData.a[13], pBData.a[14], pBData.a[15]]));

      nAreaN := nSBlockN div (nSTrailer div 3);
      nAreaAccess := ((nC1 shr nAreaN) and 1) or
        (((nC2 shr nAreaN) and 1) shl 1) or
				(((nC3 shr nAreaN) and 1) shl 2);

      if nSBlockN = nSTrailer then
      begin
        // Выводим параметры доступа прицепа
        Write(format('  Прицеп. Доступ (En=%X) (%d, %d, %d): ', [
          nEn and $F,
          (nAreaAccess and 1),
          (nAreaAccess shr 1) and 1,
          (nAreaAccess shr 2) and 1]));
        case nAreaAccess of
          0: // 0 0 0
          begin
            Assert(not g_fAuthKeyB);
            Writeln('Ключ A [-w]; Биты доступа [r-]; Ключ B [rw]');
          end;

          2: // 0 1 0
          begin
            Assert(not g_fAuthKeyB);
            Writeln('Ключ A [--]; Биты доступа [r-]; Ключ B [r-]');
          end;

          1: // 1 0 0
          begin
            if g_fAuthKeyB then
              Writeln('Ключ A [-w]; Биты доступа [r-]; Ключ B [-w]')
            else
              Writeln('Ключ A [--]; Биты доступа [r-]; Ключ B [--]');
          end;

          3: // 1 1 0
            Writeln('Ключ A [--]; Биты доступа [r-]; Ключ B [--]');

          4: // 0 0 1
          begin
            Assert(not g_fAuthKeyB);
            Writeln('Ключ A [-w]; Биты доступа [rw]; Ключ B [rw]; транспортная');
          end;

          6: // 0 1 1
          begin
            if g_fAuthKeyB then
              Writeln('Ключ A [-w]; Биты доступа [rw]; Ключ B [-w]')
            else
              Writeln('Ключ A [--]; Биты доступа [r-]; Ключ B [--]');
          end;

          5: // 1 0 1
          begin
            if g_fAuthKeyB then
              Writeln('Ключ A [--]; Биты доступа [rw]; Ключ B [-w]')
            else
              Writeln('Ключ A [--]; Биты доступа [r-]; Ключ B [--]');
          end;

          7: // 1 1 1
            Writeln('Ключ A [--]; Биты доступа [r-]; Ключ B [--]');
        end;
        Inc(nSectN);
        nSBlockN := 0;
      end
      else
      begin
        // Выводим параметры доступа блока данных
        Write(format('  Данные. Доступ (%d, %d, %d): ', [
          (nAreaAccess and 1),
          (nAreaAccess shr 1) and 1,
          (nAreaAccess shr 2) and 1]));
        case nAreaAccess of
          0: // 0 0 0
            Writeln('rwidtr; транспортная');

          2: // 0 1 0
            Writeln('r-----');

          1: // 1 0 0
            if g_fAuthKeyB then
              Writeln('rw----')
            else
              Writeln('r-----');

          3: // 1 1 0
            if g_fAuthKeyB then
              Writeln('rwidtr; блок-значение')
            else
              Writeln('r--dtr; блок-значение');

          4: // 0 0 1
            Writeln('r--dtr; блок-значение');

          6: // 0 1 1
            if g_fAuthKeyB then
              Writeln('rw----')
            else
              Writeln('------');

          5:// 1 0 1
            if g_fAuthKeyB then
              Writeln('r-----')
            else
              Writeln('------');

          7: // 1 1 1
            Writeln('------');
        end;
        Inc(nSBlockN);
      end;
      Writeln(format(#9'%s', [kOpenText[GetBit(nEn, nAreaN)]]));
    end;
    Writeln('-----');
  except
    on e: Exception do
      Writeln(e.Message);
  end;
end;

procedure DoWritePlusSL3(AReader: IILReader);
var
  S: string;
  I, nSectN, nSBlockN, nBlockN, nWritten: Integer;
  rBlockData: TMfBlockData;
  a: array[0..15] of Integer;
  fTrailer: Boolean;
  nAccessBits, nC1, nC2, nC3, nT1, nT2, nT3, nStartTick, nSpan: Cardinal;
  nEn: Byte;
begin
  try
    // Запрашиваем номер сектора и номер блока Mifare
    Writeln('Введите номер сектора и номер блока:');
    ReadLn(S);
    if Sscanf(S, '%d, %d', [@nSectN, @nSBlockN]) <> 2 then
    begin
      Writeln('Неправильный ввод');
      Exit;
    end;
    // Запрашиваем значения байтов блока Mifare
    Writeln('Введите байты 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 (16-ричные):');
    if Sscanf(S, '%x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x', [
        @a[0], @a[1], @a[2], @a[3], @a[4], @a[5], @a[6], @a[7],
        @a[8], @a[9], @a[10], @a[11], @a[12], @a[13], @a[14], @a[15]]) <> 16 then
    begin
      Writeln('Неправильный ввод');
      Exit;
    end;
    for I := 0 to High(rBlockData.a) do
      rBlockData.a[I] := Byte(a[I]);

    if nSectN < 32 then
    begin
      nBlockN := (nSectN * 4) + nSBlockN;
      fTrailer := (nSBlockN = 3);
    end
    else
    begin
      nBlockN := 128 + ((nSectN - 32) * 16) + nSBlockN;
      fTrailer := (nSBlockN = 15);
    end;
    // Если это блок-прицеп,
    if fTrailer then
    begin
      // Проверяем корректность битов доступа
      nAccessBits := 0;
      Move(rBlockData.a[6], nAccessBits, 3);
      nC1 := (nAccessBits shr 12) and $F;
      nC2 := (nAccessBits shr 16) and $F;
      nC3 := (nAccessBits shr 20) and $F;
      nT1 := (nAccessBits and $F);
      nT2 := (nAccessBits shr 4) and $F;
      nT3 := (nAccessBits shr 8) and $F;
      if ((nC1 xor nT1) <> $F) or ((nC2 xor nT2) <> $F) or ((nC3 xor nT3) <> $F) then
      begin
        Writeln('Некорректное значение битов доступа. Запись отменена');
        Exit;
      end;
      // Проверяем корректность битов доступа En
      nEn := rBlockData.a[5];
      if ((nEn and $F) xor (nEn shr 4)) <> $F then
      begin
        Writeln('Некорректное значение битов доступа En. Запись отменена');
        Exit;
      end;
    end;

    Write('Запись... ');
    nStartTick := GetTickCount();
    if g_nRdKeys <> 0 then
    begin
      I := AReader.AuthMfCardByRdKeys(nBlockN, g_fAuthKeyB, g_nRdKeys);
      if I = -1 then
      begin
        Writeln('Нет подходящего ключа аутентификации');
        Exit;
      end;
    end
    else
    begin
      AReader.LoadMfPlusAuthKey(g_AuthKey);
      if not AReader.AuthMfCard(nBlockN, g_fAuthKeyB) then
      begin
        Writeln('Ключ аутентификации не подошёл');
        Exit;
      end;
    end;
    AReader.WriteMfPlus(nBlockN, @rBlockData, 1, g_fOpenText, @nWritten);
    nSpan := GetTickSpan(nStartTick, GetTickCount());
    Writeln(format('записано %d блок за %d мс', [nWritten, nSpan]));
  except
    on e: Exception do
      Writeln(e.Message);
  end;
end;

procedure DoWriteAuthKeyToReader(AReader: IILReader);
var
  S: string;
  a: TStringDynArray;
  nKeyIdx, nWritten: Integer;
  N: Int64;
  rAuthKey: TMfPlusKey;
  nStartTick, nSpan: Cardinal;
  fOk: Boolean;
begin
  try
    Writeln('Введите номер ключа (10-тичное) и значение ключа (16-ричное):');
    ReadLn(S);
    a := SplitString(S, ' ,;');
    fOk := (Length(a) = 2) and
        TryStrToInt(a[0], nKeyIdx) and (nKeyIdx >= 0) and (nKeyIdx < 16);
    if fOk then
    begin
      a[1] := ReplaceStr(a[1], ' ', '');
      fOk := (Length(a[1]) >= 32) and TryStrToInt64(a[1].Substring(0, 16), N);
      if fOk then
      begin
        PUInt64(@rAuthKey.a[0])^ := UInt64(N);
        fOk := TryStrToInt64(a[1].Substring(16, 16), N);
        if fOk then
          PUInt64(@rAuthKey.a[8])^ := UInt64(N);
      end;
    end;
    if not fOk then
    begin
      Writeln('Неправильный ввод');
      Exit;
    end;

    Write('Запись... ');
    nStartTick := GetTickCount();
    AReader.WriteMfPlusAuthKeyToReader(nKeyIdx, g_fAuthKeyB, @rAuthKey, 1, @nWritten);
    nSpan := GetTickSpan(nStartTick, GetTickCount());
    Writeln(format('записано %d ключей за %d мс', [nWritten, nSpan]));

    // Сохраняем ключ в файл настроек
    SaveRdKey(nKeyIdx, g_fAuthKeyB, rAuthKey);
  except
    on e: Exception do
      Writeln(e.Message);
  end;
end;

{$REGION 'Функции просмотра/изменения настроек'}
procedure DoSwitchAuthKeyType();
var
  S: string;
begin
  // Запрашиваем тип ключа: A или B
  Writeln('Введите тип ключа A или B:');
  ReadLn(S);
  S := S.ToUpper;
  if S = 'A' then
    g_fAuthKeyB := False
  else if S = 'B' then
    g_fAuthKeyB := True
  else
  begin
    Writeln('Неправильный ввод');
    Exit;
  end;
  // Сохраняем тип ключа в файл настроек
  SaveKeyType();
end;

procedure DoEnterAuthKey();
var
  S: string;
  N: Int64;
  fOk: Boolean;
  rAuthKey: TMfPlusKey;
begin
  Writeln('Введите ключ аутентификации (16-ричное):');
  ReadLn(S);
    S := ReplaceStr(S, ' ', '');
  fOk := (Length(S) >= 32) and TryStrToInt64(S.Substring(0, 16), N);
  if fOk then
  begin
    PUInt64(@rAuthKey.a[0])^ := UInt64(N);
    fOk := TryStrToInt64(S.Substring(16, 16), N);
    if fOk then
      PUInt64(@rAuthKey.a[8])^ := UInt64(N);
  end;

  if not fOk then
  begin
    Writeln('Неправильный ввод');
    Exit;
  end;
  g_AuthKey := rAuthKey;
  // Сохраняем ключ в файл настроек
  SaveAuthKey();
end;

procedure DoSelectRdAuthKeys();
var
  S: string;
  N: Int64;
  a: TStringDynArray;
  I: Integer;
  nRdKeys: Cardinal;
begin
  Writeln('Введите номера ключей аутентификации (0..15) или "=" + битовую маску (16-ричное):');
  ReadLn(S);
  if S = '' then
    Exit;
  if S[1] = '=' then
  begin
    if (not TryStrToInt64('$' + S.Substring(1), N)) or (N > $ffffffff) then
    begin
      Writeln('Неправильный ввод');
      Exit;
    end;
    g_nRdKeys := Cardinal(N);
  end
  else
  begin
    nRdKeys := 0;
    a := SplitString(S, ' ,;');
    for I := 0 to High(a) do
      if TryStrToInt64(a[I], N) and (N >= 0) and (N < 16) then
        nRdKeys := nRdKeys or (1 shl N)
      else
        Exit;
    g_nRdKeys := nRdKeys;
  end;
  // Сохраняем биты ключей в файл настроек
  SaveRdKeys();
end;

procedure ShowSavedReaderKeys();
var
  f: Boolean;
  I: Integer;
begin
  for f := Low(g_aSavedRdKeys) to High(g_aSavedRdKeys) do
  begin
    Writeln(format('Сохранённые ключи %s:', [kKeyTypeChars[f]]));
    for I := Low(g_aSavedRdKeys[f]) to High(g_aSavedRdKeys[f]) do
      if ((g_aSavedRdKeyValid[f] shr I) and 1) <> 0 then
        Writeln(format('%2d: %s', [I, MfPlusKeyToStr(g_aSavedRdKeys[f, I])]))
      else
        Writeln(format('%2d: -', [I]));
    Writeln;
  end;
end;
{$ENDREGION} // Функции просмотра/изменения настроек

var
  iDll: IILR;
  iSearch: IILRSearch;
  iReader: IILReader;
  rRI: TReaderInfo;
  rCI: TCardInfo;
  s: string;
  fCanRW, fCardFound: Boolean;
begin
  try
    // Переключаем консоль на кодовую страницу CP1251 (Windows-1251).
    SetConsoleOutputCP(1251);

    // Загружаем DLL
    ILRCheck(LoadILR());
    try
      // Получаем главный интерфейс SDK
      ILRCheck(ILR_GetInterface(iDll));

      // Ищем считыватель
      Write('Поиск считывателя... ');
      iSearch := iDll.GetSearch();
      iSearch.Scan();
      if iSearch.GetReaderCount = 0 then
      begin
        Writeln('не найден');
        Exit;
      end;
      // Получаем информацию о считывателе
      iSearch.GetReaderInfo(0, rRI);
      WriteLn(format('%s: %s', [
          StrPas(rRI.szPortName),
          kRdModelNames[rRI.nModel]]));
      iSearch := nil;

      // Получаем интерфейс считывателя
      iReader := iDll.GetReader(rRI.nPortType, rRI.szPortName);
      iDll := nil;
      // Отключаем авто поиск карт
      iReader.EnableAutoScan(False, False);
      // Подключаемся к считывателю
      Write('Подключение к считывателю... ');
      iReader.Connect();
      Writeln('успешно');
      iReader.GetReaderInfo(rRI);
      fCanRW := (rwcMfPlus in rRI.CanRWCardTypes());

      repeat
        Write('Поиск карты Plus SL3... ');
        iReader.Scan(False);
        iReader.GetCardInfo(rCI);
        fCardFound := rCI.IsMfPlusSL3Mode;
        // Если карта Mifare Plus SL3 найдена,
        if fCardFound then
          Writeln(format('%s %s', [
            kCardTypeNames[rCI.nType],
            ILRCardUIDToStr(rCI.nType, rCI.rUID)]))
        else // Mifare Plus SL3 не найдена
          Writeln('не найдена');

        Writeln('-----');
        Writeln('Введите номер команды:');
        Writeln('1 - Искать снова');
        if fCardFound and fCanRW then
        begin
          Writeln('2 - Прочитать данные из карты');
          Writeln('3 - Записать данные на карту...');
        end;
        Writeln('4 - Записать ключ аутентификации в считыватель...');
        Writeln(format('5 - Переключить тип ключа A или B [%s]...', [
            kKeyTypeChars[g_fAuthKeyB]]));
        Writeln(format('6 - Ввести ключ аутентификации [0x%s]...', [
            MfPlusKeyToStr(g_AuthKey)]));
        Writeln(format('7 - Выбрать ключи аутентификации считывателя [0x%X]...', [
            g_nRdKeys]));
        Writeln('8 - Показать сохранённые ключи считывателя');
        Writeln('0 - Выйти из программы');
        Readln(s);
        Writeln;
        case StrToIntDef(s, -1) of
          0: Exit;
          1: ;
          2: if fCardFound and fCanRW then DoReadPlusSL3(iReader);
          3: if fCardFound and fCanRW then DoWritePlusSL3(iReader);
          4: DoWriteAuthKeyToReader(iReader);
          5: DoSwitchAuthKeyType();
          6: DoEnterAuthKey();
          7: DoSelectRdAuthKeys();
          8: ShowSavedReaderKeys();
          else Writeln('Неправильный ввод');
        end;
      until False;
    finally
      iReader := nil;
      iSearch := nil;
      iDll := nil;
      // Выгружаем DLL
      UnloadILR();
    end;
//    Readln;
    { TODO -oUser -cConsole Main : Insert code here }
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
