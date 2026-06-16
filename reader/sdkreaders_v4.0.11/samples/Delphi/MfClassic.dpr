program MfClassic;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  WinApi.Windows,
  System.SysUtils, System.StrUtils, System.Types, System.IniFiles,
  System.Classes,
  IL.Readers, IL.RUtils;

var
  // Настройки:
  g_AuthKey: TMfClassicKey = $ffffffffffff; // Ключ аутентификации Mifare
  g_fAuthKeyB: Boolean = False;      // True, авторизовать по ключу B, иначе - A
  g_nRdKeys: Cardinal = 0; // Биты ключей аутентификации считывателя
  g_aSavedRdKeys: array[Boolean, 0..15] of TMfClassicKey; // Сохранённые ключи считывателя

const
  kKeyTypeChars: array[Boolean] of string = ('A', 'B');

{$REGION 'Функции загрузки/сохранения настроек'}
procedure LoadSettings();
var
  oIni: TIniFile;
  N: Int64;
  f: Boolean;
  oStrs: TStringList;
  I, nKeyIdx: Integer;
begin
  oIni := TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini'));
  try
    if TryStrToInt64('$' + oIni.ReadString('Main', 'AuthKey', ''), N) then
      g_AuthKey := TMfClassicKey(N);
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
          if TryStrToInt64('$' + oStrs.ValueFromIndex[I], N) then
            g_aSavedRdKeys[f, nKeyIdx] := TMfClassicKey(N);
        end;
      end;
    finally
      oStrs.Free();
    end;
  finally
    oIni.Free();
  end;
end;
procedure SaveRdKey(AKeyIdx: Integer; AKeyB: Boolean; const AKey: TMfClassicKey);
var
  oIni: TIniFile;
begin
  oIni := TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini'));
  try
    if AKeyB then
      oIni.WriteString('RdBKeys', IntToStr(AKeyIdx), IntToHex(AKey, 12))
    else
      oIni.WriteString('RdAKeys', IntToStr(AKeyIdx), IntToHex(AKey, 12));
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
begin
  oIni := TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini'));
  try
    oIni.WriteString('Main', 'AuthKey', IntToHex(g_AuthKey, 12));
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

procedure DoReadClassic(AReader: IILReader);
var
  rCI: TCardInfo;
  I, nBlockMax, nRead, nSectN, nSBlockN, nSTrailer, nAreaN: Integer;
  oBlocks: array of TMfBlockData;
  pBData: PMfBlockData;
  nStartTick, nSpan, nAccessBits, nAreaAccess: Cardinal;
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
      AReader.LoadMfAuthKey(g_AuthKey);
      if not AReader.AuthMfCard(0, g_fAuthKeyB) then
      begin
        Writeln('Ключ аутентификации не подошёл');
        Exit;
      end;
    end;
    AReader.ReadMfClassic(0, @oBlocks[0], Length(oBlocks), @nRead);
    nSpan := GetTickSpan(nStartTick, GetTickCount());
    Writeln(format('прочитано %d блоков за %d мс', [nRead, nSpan]));

    nSectN := 0;
    nSBlockN := 0;
    nSTrailer := 0;
    nAccessBits := 0;
    for I := 0 to nRead - 1 do
    begin
      if nSBlockN = 0 then
      begin
        if I < 128 then
          nSTrailer := 3
        else
          nSTrailer := 15;
        nAccessBits := GetMfAccessBits(oBlocks[I + nSTrailer]);
      end;

      pBData := @oBlocks[I];
      // Выводим байты блока
      Writeln(format('%.2d (%.2d). %.2X %.2X %.2X %.2X %.2X %.2X %.2X %.2X %.2X %.2X %.2X %.2X %.2X %.2X %.2X %.2X', [
          I, nSectN,
          pBData.a[0], pBData.a[1], pBData.a[2], pBData.a[3],
          pBData.a[4], pBData.a[5], pBData.a[6], pBData.a[7],
          pBData.a[8], pBData.a[9], pBData.a[10], pBData.a[11],
          pBData.a[12], pBData.a[13], pBData.a[14], pBData.a[15]]));

      nAreaN := (nSBlockN * 3) div nSTrailer;
      nAreaAccess := GetMfAreaAccess(nAccessBits, nAreaN);

      if nSBlockN = nSTrailer then
      begin
        // Выводим параметры доступа прицепа
        Write(format('  Прицеп. Доступ (%d, %d, %d): ', [
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
    end;
    Writeln('-----');
  except
    on e: Exception do
      Writeln(e.Message);
  end;
end;

procedure DoWriteClassic(AReader: IILReader);
var
  S: string;
  I, nSectN, nSBlockN, nBlockN, nWritten: Integer;
  rBlockData: TMfBlockData;
  a: array[0..15] of Integer;
  fTrailer: Boolean;
  nAccessBits, nStartTick, nSpan: Cardinal;
  nKey: UInt64;
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
      rBlockData.a[I] := a[I];

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
     if ((nAccessBits and $FFF) xor (nAccessBits shr 12)) <> $FFF then
      begin
        Writeln('Некорректное значение битов доступа. Запись отменена');
        Exit;
      end;
      // Выводим ключ A
      nKey := 0;
      Move(rBlockData.a, nKey, 6);
      Writeln(format('Ключ A: 0x%s', [MfClassicKeyToStr(nKey)]));
      // Выводим ключ B
      nKey := 0;
      Move(rBlockData.a[10], nKey, 6);
      Writeln(format('Ключ B: 0x%s', [MfClassicKeyToStr(nKey)]));
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
      AReader.LoadMfAuthKey(g_AuthKey);
      if not AReader.AuthMfCard(nBlockN, g_fAuthKeyB) then
      begin
        Writeln('Ключ аутентификации не подошёл');
        Exit;
      end;
    end;
    AReader.WriteMfClassic(nBlockN, @rBlockData, 1, @nWritten);
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
  nAuthKey: TMfClassicKey;
  nStartTick, nSpan: Cardinal;
begin
  try
    Writeln('Введите номер ключа (10-тичное) и значение ключа (16-тичное):');
    ReadLn(S);
    a := SplitString(S, ' ,;');
    if (Length(a) <> 2) or
        (not TryStrToInt(a[0], nKeyIdx)) or (nKeyIdx < 0) or (nKeyIdx > 15) or
        (not TryStrToInt64(a[1], N)) or (N < 0) or (N > $ffffffffffff) then
    begin
      Writeln('Неправильный ввод');
      Exit;
    end;
    nAuthKey := TMfClassicKey(N);

    Write('Запись... ');
    nStartTick := GetTickCount();
    AReader.WriteMfAuthKeyToReader(nKeyIdx, g_fAuthKeyB, @nAuthKey, 1, @nWritten);
    nSpan := GetTickSpan(nStartTick, GetTickCount());
    Writeln(format('записано %d ключей за %d мс', [nWritten, nSpan]));

    // Сохраняем ключ в файл настроек
    SaveRdKey(nKeyIdx, g_fAuthKeyB, nAuthKey);
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
begin
  Writeln('Введите ключ аутентификации (16-ричное):');
  ReadLn(S);
  if (not TryStrToInt64('$' + S, N)) or (N < 0) or (N > $ffffffffffff) then
  begin
    Writeln('Неправильный ввод');
    Exit;
  end;
  g_AuthKey := TMfClassicKey(N);
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
      if g_aSavedRdKeys[f, I] <> TMfClassicKey(-1) then
        Writeln(format('%2d: %.12X', [I, g_aSavedRdKeys[f, I]]))
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
  fCanRW, fCardFound, f: Boolean;
  I: Integer;
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
      fCanRW := (rwcMfClassic in rRI.CanRWCardTypes);
      // Инициализируем список сохранённых ключей считывателя
      for f := Low(g_aSavedRdKeys) to High(g_aSavedRdKeys) do
        for I := 0 to High(g_aSavedRdKeys[f]) do
          g_aSavedRdKeys[f, I] := TMfClassicKey(-1);
      // Загружаем настройки из файла
      LoadSettings();

      repeat
        Write('Поиск карты Mifare Classic... ');
        iReader.Scan(False);
        iReader.GetCardInfo(rCI);
        fCardFound := rCI.IsMfClassicMode();
        // Если карта Mifare Classic найдена,
        if fCardFound then
        begin
          Writeln(format('%s %s', [
            kCardTypeNames[rCI.nType],
            ILRCardUIDToStr(rCI.nType, rCI.rUID)]));
        end
        else // Mifare Classic не найдена
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
            MfClassicKeyToStr(g_AuthKey)]));
        Writeln(format('7 - Выбрать ключи аутентификации считывателя [0x%X]...', [
            g_nRdKeys]));
        Writeln('8 - Показать сохранённые ключи считывателя');
        Writeln('0 - Выйти из программы');
        Readln(s);
        Writeln;
        case StrToIntDef(s, -1) of
          0: Exit;
          1: ;
          2: if fCardFound and fCanRW then DoReadClassic(iReader);
          3: if fCardFound and fCanRW then DoWriteClassic(iReader);
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
