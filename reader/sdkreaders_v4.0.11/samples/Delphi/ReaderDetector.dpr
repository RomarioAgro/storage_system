program ReaderDetector;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  WinApi.Windows,
  System.SysUtils,
  IL.Readers, IL.RUtils;

procedure SearchNotify(AMsg: TSearchMsg; AMsgData, AUserData: Pointer); stdcall;
var
  pRI: PReaderInfo;
begin
  case AMsg of
    smReaderFound,  // Считыватель найден
    smReaderLost:   // Считыватель потерян
    begin
      pRI := PReaderInfo(AMsgData);
      if AMsg = smReaderFound then
        Write('{!} Найден считыватель')
      else
        Write('{!} Потерян считыватель');

      Write(format(' (%s): %s', [
          StrPas(pRI.szPortName),
          kRdModelNames[pRI.nModel]]));

      if pRI.nSn <> -1 then
        Write(format(' с/н:%d', [pRI.nSn]));

      if pRI.nFwVersion <> 0 then
        Write(format(' прошивка:%s', [ILRVersionToStr(pRI.nFwVersion)]));

      if pRI.nFwBuildDate <> 0 then
        Write(format(' сборка %s', [ILRTimeToStr(pRI.nFwBuildDate)]));
      WriteLn;
    end;

    smListChanged:  // Список считывателей изменился
    begin
      Writeln('{!} Список считыватель изменился')
    end;
  end;
end;

var
  iDll: IILR;
  iSearch: IILRSearch;
begin
  try
    // Переключаем консоль на кодовую страницу CP1251 (Windows-1251).
    SetConsoleOutputCP(1251);

    // Загружаем DLL
    ILRCheck(LoadILR());
    try
      // Получаем главный интерфейс SDK
      ILRCheck(ILR_GetInterface(iDll));
      // Получает интерфейс поиска считывателей
      iSearch := iDll.GetSearch();
      iDll := nil;
      // Выбираем типы считывателей для поиска
      iSearch.SetReaderTypes(RT_F_ILUSB or RT_F_TPUSB or RT_F_CCID);
      // // Устанавливаем функцию для получения сообщений о подключении/отключении считывателей
      iSearch.SetNotifyCallback(SearchNotify, nil);
      // Включаем авто поиск считывателей
      iSearch.EnableAutoScan();

      Readln;
      iSearch := nil;
    finally
      // Выгружаем DLL
      UnloadILR();
    end;

    { TODO -oUser -cConsole Main : Insert code here }
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
