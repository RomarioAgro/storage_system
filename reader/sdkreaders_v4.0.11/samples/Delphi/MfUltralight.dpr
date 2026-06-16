program MfUltralight;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  WinApi.Windows,
  System.SysUtils,
  IL.Readers, IL.RUtils;


procedure DoReadUltralight(AReader: IILReader);
const
  kLocked: array[Boolean] of string = ('', 'Заблокировано');
var
  nStartTick, nSpan, N, nPageData: Cardinal;
  aBuf: array[0..15] of Cardinal;
  I, J, nRead: Integer;
  S: string;
begin
  try
    Write('Чтение данных карты... ');
    nStartTick := GetTickCount();
    AReader.ReadMfUlralight(0, @aBuf, Length(aBuf), @nRead);
    nSpan := GetTickSpan(nStartTick, GetTickCount());
    Writeln(format('прочитано %d страниц за %d мс', [nRead, nSpan]));

    Writeln;
    Writeln('Страница. Байты 0..3');
    for I := 0 to High(aBuf) do // цикл по страницам
    begin
      nPageData := aBuf[I];
      Write(format('%4d. %.2X %.2X %.2X %.2X', [
        I,
        nPageData and $ff,
        (nPageData shr 8) and $ff,
        (nPageData shr 16) and $ff,
        nPageData shr 24]));
      case I of
        0,1: // Serial Number
          Writeln(' Серийный номер');

        2: // Internal / Lock
        begin
          Writeln(' Внутреннее / Блокировка');
          N := (nPageData shr 16);
          Writeln(format('Lock0[%.2X] BOTP:%d, BL9-4:%d, BL15-10:%d, OTP:%d, L4:%d, L5:%d, L6:%d, L7:%d', [
            N and $ff,
            N and 1,
            (N shr 1) and 1,
            (N shr 2) and 1,
            (N shr 3) and 1,
            (N shr 4) and 1,
            (N shr 5) and 1,
            (N shr 6) and 1,
            (N shr 7) and 1]));

          Writeln(format('Lock1[%.2X] L8:%d, L9:%d, L10:%d, L11:%d, L12:%d, L13:%d, L14:%d, L15:%d', [
            (N shr 8),
            (N shr 8) and 1,
            (N shr 9) and 1,
            (N shr 10) and 1,
            (N shr 11) and 1,
            (N shr 12) and 1,
            (N shr 13) and 1,
            (N shr 14) and 1,
            (N shr 15) and 1]));
        end;

        3: // OTP
        begin
          S := '00000000 00000000 00000000 00000000';
          N := nPageData;
          for J := 1 to Length(S) do
          begin
            if S[J] = ' ' then
              continue;
            if (N and 1) <> 0 then
              S[J] := '1';
            N := N shr 1;
          end;
          Writeln(format(' OTP (%d) %s %s', [
            nPageData,
            S,
            kLocked[GetBit(aBuf[2] shr 16, 3)]]));
        end;

        else
        begin
          Writeln(format(' Данные (%d) %s', [
            nPageData,
            kLocked[GetBit(aBuf[2] shr 16, I)]]));
        end;
      end;
    end;
    Writeln('-----');
  except
    on e: Exception do
      Writeln(e.Message);
  end;
end;

procedure DoWriteUltralight(AReader: IILReader);
var
  S: string;
  I, nPageN, nWritten: Integer;
  a: array[0..3] of Integer;
  nStartTick, nSpan, nPageData: Cardinal;
  aBytes: array[0..3] of Byte absolute nPageData;
begin
  try
    Writeln('Введите номер страницы (10-тичное), байты 0 1 2 3 (16-ричные):');
    ReadLn(S);
    if Sscanf(S, '%d %x %x %x %x', [
      @nPageN, @a[0], @a[1], @a[2], @a[3]]) <> 5 then
    begin
       Writeln('Неправильный ввод');
       Exit;
    end;
    for I := 0 to High(aBytes) do
      aBytes[I] := a[I];

    Write('Запись... ');
    nStartTick := GetTickCount();
    AReader.WriteMfUlralight(nPageN, @nPageData, 1, @nWritten);
    nSpan := GetTickSpan(nStartTick, GetTickCount());
    Writeln(format('записана %d страница за %d мс', [nWritten, nSpan]));
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
      fCanRW := (rwcMfUltralight in rRI.CanRWCardTypes);

      repeat
        Write('Поиск карты Mifare Ultralight... ');
        iReader.Scan(False);
        iReader.GetCardInfo(rCI);
        fCardFound := (rCI.nType = TCardType.cMifareUltralight);
        // Если карта Mifare Ultralight найдена,
        if fCardFound then
          Writeln(format('%s %s', [
            kCardTypeNames[rCI.nType],
            ILRCardUIDToStr(rCI.nType, rCI.rUID)]))
        else // Mifare Ultralight не найдена
          Writeln('не найдена');

        Writeln('-----');
        Writeln('Введите номер команды:');
        Writeln('1 - Искать снова');
        if fCardFound and fCanRW then
        begin
          Writeln('2 - Прочитать данные из карты');
          Writeln('3 - Записать данные на карту...');
        end;
        Writeln('0 - Выйти из программы');
        Readln(s);
        Writeln;
        case StrToIntDef(s, -1) of
          0: Exit;
          1: ;
          2: if fCardFound and fCanRW then DoReadUltralight(iReader);
          3: if fCardFound and fCanRW then DoWriteUltralight(iReader);
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
