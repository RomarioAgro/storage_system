program Temic;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  WinApi.Windows,
  System.SysUtils,
  IL.Readers, IL.RUtils;

const
  kPassword: Int64 = -1;  // Пароль для доступа к Temic, =-1 нет пароля

procedure DoReadTemic(AReader: IILReader);
const
  kBitRates: array[0..7] of Integer = (
    8, 16, 32, 40, 50, 64, 100, 128
  );
  kPskCf: array[0..3] of string = (
    'RF/2', 'RF/4', 'RF/8', 'Reserved'
  );
var
  nStartTick, nSpan, nBlockData, nConfig: Cardinal;
  aBlocks: array[0..9] of Cardinal;
  aBlockBytes: array[0..3] of Byte absolute nBlockData;
  I, nModulation, nMaxBlock, nDataBitRate, nRead, nWiegand: Integer;
  fXMode, fConfigOk: Boolean;
  s: string;
  rUID: TCardUID;
begin
  try
    Write('Чтение данных карты... ');
    nStartTick := GetTickCount();
    AReader.LoadTemicPassword(kPassword);
    AReader.ReadTemic(0, @aBlocks, Length(aBlocks), -1, @nRead);
    nSpan := GetTickSpan(nStartTick, GetTickCount());
    Writeln(format('прочитано %d блоков за %d мс', [nRead, nSpan]));

    nConfig := 0;
    nDataBitRate := 0;
    nModulation := 0;
    nMaxBlock := 0;
    for I := 0 to High(aBlocks) do
    begin
      nBlockData := aBlocks[I];
      Write(format('%.2d. %.2X %.2X %.2X %.2X ', [
          I, aBlockBytes[0], aBlockBytes[1], aBlockBytes[2], aBlockBytes[3]]));
      case I of
        0: // Configuration data
        begin
          WriteLn('Конфигурация');
          nConfig := nBlockData;
          fXMode := GetBit(nConfig, 9);
          if fXMode then
            Writeln(#9'Режим: X-Mode')
          else
            Writeln(#9'Режим: e5550 Compatibility Mode');
          Writeln(format(#9'Master Key: %d', [(nConfig shr 4) and $f]));
          if fXMode then
            nDataBitRate := ((nConfig shr 10) and $3F) * 2 + 2
          else
            nDataBitRate := kBitRates[(nConfig shr 10) and 7];
          Writeln(format(#9'Data Bit Rate: RF/%d', [nDataBitRate]));
          s := '';
          nModulation := ((nConfig shr 20) and $F) or (((nConfig shr 8) and 1) shl 4);
          case nModulation of
            0: s := 'Direct';         // 0 0 0 0 0
            1: s := 'PSK1';           // 0 0 0 0 1
            2: s := 'PSK2';           // 0 0 0 1 0
            3: s := 'PSK3';           // 0 0 0 1 1
            4: s := 'FSK1';           // 0 0 1 0 0
            5: s := 'FSK2';           // 0 0 1 0 1
            6: s := 'FSK1a';          // 0 0 1 1 0
            7: s := 'FSK2a';          // 0 0 1 1 1
            8: s := 'Manchester';     // 0 1 0 0 0
            $10: s := 'Biphase(''50)';// 1 0 0 0 0
            $18: s := 'Biphase(''57)';// 1 1 0 0 0
          end;
          Writeln(format(#9'Modulation: %s', [s]));

          Writeln(format(#9'PSK-CF: %s', [
            kPskCf[(nConfig shr 18) and 3]]));
          Writeln(format(#9'AOR: %s', [BoolToStr(GetBit(nConfig, 17), True)]));
          if fXMode then
            Writeln(format(#9'OTP: %s', [BoolToStr(GetBit(nConfig, 16), True)]));
          nMaxBlock := (nConfig shr 29) and 7;
          Writeln(format(#9'MAX-BLOCK: %d', [nMaxBlock]));
          Writeln(format(#9'Password: %s', [BoolToStr(GetBit(nConfig, 28), True)]));
          if fXMode then
          begin
            Writeln(format(#9'SST-Sequence Start Marker: %s', [
              BoolToStr(GetBit(nConfig, 27), True)]));
            Writeln(format(#9'Fastwrite: %s', [
              BoolToStr(GetBit(nConfig, 26), True)]));
            Writeln(format(#9'Inverse Data: %s', [
              BoolToStr(GetBit(nConfig, 25), True)]));
          end
          else
            Writeln(format(#9'ST-Sequence Terminator: %s', [
              BoolToStr(GetBit(nConfig, 27), True)]));
          Writeln(format(#9'POR delay: %s', [
            BoolToStr(GetBit(nConfig, 24), True)]));
        end;

        7: // User data or password
        begin
          if GetBit(nConfig, 28) then
            WriteLn('Пароль')
          else
            WriteLn('Данные пользователя');
        end;

        8: // Traceability data
        begin
          WriteLn('Данные производителя');
          WriteLn(format(#9'ACL: 0x%.2X', [aBlockBytes[0]]));
          WriteLn(format(#9'MFC: 0x%.2X', [aBlockBytes[1]]));
          WriteLn(format(#9'ICR: 0x%.2X', [aBlockBytes[2]]));
          WriteLn(format(#9'MSN LotID: %d', [aBlockBytes[3]]));
        end;

        9: // Traceability data
        begin
          WriteLn('Данные производителя');
          WriteLn(format(#9'LotID: %d', [nBlockData and $FFF]));
          WriteLn(format(#9'wafer #: 0x%X', [(nBlockData shr 12) and $3F]));
          WriteLn(format(#9'die on wafer #: 0x%X', [(nBlockData shr 18) and $3FFF]));
        end;

        else
          WriteLn('Данные пользователя');
      end;
    end;
    rUID.Clear();
    if (nDataBitRate = 64) and (nModulation = 8) and (nMaxBlock = 2) then
    begin
      AReader.DecodeTemicEmMarine(@aBlocks, 3, rUID, fConfigOk);
      if not rUID.IsEmpty then
         WriteLn('Эмулирует Em-Marine ' + ILRCardUIDToStr(cEmMarine, rUID));
    end
    else if (nDataBitRate = 50) and (nModulation = 5) and (nMaxBlock = 3) then
    begin
      AReader.DecodeTemicHID(@aBlocks, 4, rUID, nWiegand, fConfigOk);
      if not rUID.IsEmpty then
         WriteLn(format('Эмулирует HID (W%d) %s', [
          nWiegand, ILRCardUIDToStr(cHID, rUID)]));
    end;
    Writeln('-----');
  except
    on e: Exception do
      Writeln(e.Message);
  end;
end;

procedure DoWriteTemic(AReader: IILReader);
var
  S: string;
  I, nBlockN, nWritten: Integer;
  a: array[0..3] of Integer;
  nStartTick, nSpan, nBlockData: Cardinal;
  aBlockBytes: array[0..3] of Byte absolute nBlockData;
begin
  try
    // Запрашиваем номер блока Temic и значения байтов блока Temic
    Writeln('Введите номер блока и байты 0 1 2 3 (16-ричное):');
    ReadLn(S);
    if Sscanf(S, '%x %x %x %x %x', [
        @nBlockN, @a[0], @a[1], @a[2], @a[3]]) <> 5 then
    begin
      Writeln('Неправильный ввод');
      Exit;
    end;
    for I := 0 to High(aBlockBytes) do
      aBlockBytes[I] := a[I];

    Write('Запись... ');
    nStartTick := GetTickCount();
    AReader.LoadTemicPassword(kPassword);
    AReader.WriteTemic(nBlockN, @nBlockData, 1, False, -1, @nWritten);
    nSpan := GetTickSpan(nStartTick, GetTickCount());
    Writeln(format('записано %d блок за %d мс', [nWritten, nSpan]));
  except
    on e: Exception do
      Writeln(e.Message);
  end;
end;

procedure DoWriteEmMarine(AReader: IILReader);
var
  s: String;
  nFacility, nSeries, nNumber, nWritten: Integer;
  rUID: TCardUID;
  aBlocks: array[0..2] of Cardinal;
  nStartTick, nSpan: Cardinal;
begin
  try
    // Запрашиваем номер Em-Marine: 1) код производителя (шестнадцатиричное число),
    //  2) номер серии  (десятичное), 3) номер (десятичное)
    WriteLn('Введите номер Em-Marine: код производителя (16-ричное), серия (10-тичное), номер (10-тичное):');
    ReadLn(s);
    if sscanf(s, '%x %d %d', [@nFacility, @nSeries, @nNumber]) <> 3 then
    begin
      Writeln('Неправильный ввод');
      Exit;
    end;

    // Подготавливаем данные для записи
    rUID.Clear();
    PWord(@rUID.aBytes[0])^ := nNumber;
    rUID.aBytes[2] := nSeries;
    PWord(@rUID.aBytes[3])^ := nFacility;
    rUID.nLength := 5;
    AReader.EncodeTemicEmMarine(rUID, @aBlocks, Length(aBlocks));

    // Пишем номер Em-Marine в Temic
    Write('Запись... ');
    nStartTick := GetTickCount();
    AReader.LoadTemicPassword(kPassword);
    AReader.WriteTemic(0, @aBlocks, Length(aBlocks), False, -1, @nWritten);
    nSpan := GetTickSpan(nStartTick, GetTickCount());
    Writeln(format('записано %d блока за %d мс', [nWritten, nSpan]));
  except
    on e: Exception do
      Writeln(e.Message);
  end;
end;

procedure DoWriteHID(AReader: IILReader);
var
  s: String;
  nWiegand, nFacility, nNumber, nWritten: Integer;
  rUID: TCardUID;
  aBlocks: array[0..3] of Cardinal;
  nStartTick, nSpan, nFSize, nFCount: Cardinal;
begin
  try
    // Запрашиваем номер HID: 1) номер кодировки Wiegand (десятичное число),
    //  2) код производителя (шестнадцатиричное), 3) номер (десятичное)
    WriteLn('Введите номер HID: виганд (10-тичное), код прозводителя (16-ричное), номер (10-тичное):');
    ReadLn(s);
    if (sscanf(s, '%d %x %d', [@nWiegand, @nFacility, @nNumber]) <> 3) or
        (nWiegand < 10) or (nWiegand > 37) then
    begin
      Writeln('Неправильный ввод');
      Exit;
    end;

    // Подготавливаем данные для записи
    rUID.Clear();
    nFSize := (nWiegand - 2 - 16);
    nFCount := nFSize div 8;
    if (nFSize mod 8) <> 0 then
      Inc(nFCount);
    PWord(@rUID.aBytes[0])^ := nNumber;
    if nFCount > 0 then
      Move(nFacility, rUID.aBytes[2], nFCount);
    rUID.nLength := (2 + nFCount);
    AReader.EncodeTemicHID(rUID, @aBlocks, Length(aBlocks), nWiegand);

    // Пишем номер HID в Temic
    Write('Запись... ');
    nStartTick := GetTickCount();
    AReader.LoadTemicPassword(kPassword);
    AReader.WriteTemic(0, @aBlocks, Length(aBlocks), False, -1, @nWritten);
    nSpan := GetTickSpan(nStartTick, GetTickCount());
    Writeln(format('записано %d блока за %d мс', [nWritten, nSpan]));
  except
    on e: Exception do
      Writeln(e.Message);
  end;
end;

procedure DoInitTemic(AReader: IILReader);
var
  nStartTick, nSpan, nBlockData: Cardinal;
  nWritten: Integer;
begin
  try
    // Подготавливаем данные для записи - стандартная конфигурация
    nBlockData := $40801400;

    // Пишем данные в Temic
    Write('Запись... ');
    nStartTick := GetTickCount();
    AReader.LoadTemicPassword(kPassword);
    AReader.WriteTemic(0, @nBlockData, 1, False, -1, @nWritten);
    nSpan := GetTickSpan(nStartTick, GetTickCount());
    Writeln(format('записано %d блок за %d мс', [nWritten, nSpan]));
  except
    on e: Exception do
      Writeln(e.Message);
  end;
end;

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
      fCanRW := (rwcTemic in rRI.CanRWCardTypes());
      if fCanRW then
        iReader.EnableAutoScanTemic(True);

      repeat
        Write('Поиск карты Temic... ');
        iReader.Scan();
        iReader.GetCardInfo(rCI);
        fCardFound := (rCI.nType = cTemic);
        // Если карта Temic найдена,
        if fCardFound then
          Writeln(format('%s %s', [
            kCardTypeNames[rCI.nType],
            ILRCardUIDToStr(rCI.nType, rCI.rUID)]))
        else // карта Temic не найдена
          Writeln('не найдена');

        Writeln('-----');
        Writeln('Введите номер команды:');
        Writeln('1 - Искать снова');
        if fCanRW then
        begin
          if fCardFound then
          begin
            Writeln('2 - Прочитать данные из карты');
            Writeln('3 - Записать данные на карту...');
            Writeln('4 - Записать Em-Marine...');
            Writeln('5 - Записать HID...');
          end
          else
            Writeln('2 - Инициализировать карту Temic');
        end;
        Writeln('0 - Выйти из программы');
        Readln(s);
        Writeln;
        case StrToIntDef(s, -1) of
          0: Exit;
          1: ;
          2:
            if fCanRW then
              if fCardFound then DoReadTemic(iReader) else DoInitTemic(iReader);
          3: if fCardFound and fCanRW then DoWriteTemic(iReader);
          4: if fCardFound and fCanRW then DoWriteEmMarine(iReader);
          5: if fCardFound and fCanRW then DoWriteHID(iReader);
          else
            Writeln('Неправильный ввод');
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
