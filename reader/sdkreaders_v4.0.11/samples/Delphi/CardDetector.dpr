program CardDetector;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  WinApi.Windows,
  System.SysUtils,
  IL.Readers, IL.RUtils;


procedure ReaderNotify(AMsg: TReaderMsg; AMsgData, AUserData: Pointer); stdcall;
var
  pCI: PCardInfo;
begin
  case AMsg of
    rmCardFound,  // Карта поднесена
    rmCardLost:   // Карта удалена
    begin
      pCI := PCardInfo(AMsgData);

      if AMsg = rmCardFound then
        Write('{!} Найдена карта')
      else
        Write('{!} Потеряна карта');

      Write(format(' %s %s', [
        kCardTypeNames[pCI.nType],
        ILRCardUIDToStr(pCI.nType, pCI.rUID)
      ]));
      if pCI.nMpType <> TMfPlusType.mptUnknown then
        Write(' ' + kMpTypeNames[pCI.nMpType]);
      if pCI.nSL <> TMfPlusSL.mpslUnknown then
        Write(format(' SL%d', [Integer(pCI.nSL)]));
      Writeln;
    end;
  end;
end;

var
  iDll: IILR;
  iSearch: IILRSearch;
  iReader: IILReader;
  rRI: TReaderInfo;
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
      // Подключаемся к считывателю
      Write('Подключение к считывателю... ');
      iReader.Connect();
      Writeln('успешно');
      // Устанавливаем функцию для получения уведомлений об поднесении/удалении карты
      iReader.SetNotifyCallback(ReaderNotify, nil);
      Writeln('Ожидание поднесения карты...');
      Readln;
    finally
      iReader := nil;
      iSearch := nil;
      iDll := nil;
      // Выгружаем DLL
      UnloadILR();
    end;

    { TODO -oUser -cConsole Main : Insert code here }
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
