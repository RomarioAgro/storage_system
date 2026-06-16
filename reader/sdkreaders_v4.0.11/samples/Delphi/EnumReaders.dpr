program EnumReaders;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  WinApi.Windows,
  System.SysUtils,
  IL.Readers, IL.RUtils;

var
  iDll: IILR;
  iSearch: IILRSearch;
  nCount, I: Integer;
  rRI: TReaderInfo;
begin
  try
    // Переключаем консоль на кодовую страницу CP1251 (Windows-1251).
    SetConsoleOutputCP(1251);

    // Загружаем DLL
    ILRCheck(LoadILR());

    // Получаем главный интерфейс SDK
    ILRCheck(ILR_GetInterface(iDll));
    // Получает интерфейс поиска считывателей
    iSearch := iDll.GetSearch();
    iDll := nil;    // Освобождаем интерфей главный интерфейс SDK
    // Выбираем типы считывателей для поиска
    iSearch.SetReaderTypes(RT_F_ILUSB or RT_F_CCID);
    // Ищем считыватели
    Write('Поиск считывателей... ');
    iSearch.Scan();
    // Перечисляем найденные считыватели
    nCount := iSearch.GetReaderCount();
    if nCount <> 0 then
    begin
      Writeln(format('найдено %d считывателей:', [nCount]));
      for I := 0 to nCount - 1 do
      begin
        iSearch.GetReaderInfo(I, rRI);
        Write(format('%d. %s: %s', [
            1 + I,
            StrPas(rRI.szPortName),
            kRdModelNames[rRI.nModel]]));
        if rRI.nSn <> -1 then
          Write(format(' с/н:%d', [rRI.nSn]));
        if rRI.nFwVersion <> 0 then
          Write(format(' прошивка:%s', [ILRVersionToStr(rRI.nFwVersion)]));
        if rRI.nFwBuildDate <> 0 then
          Write(format(' сборка %s', [ILRTimeToStr(rRI.nFwBuildDate)]));
        WriteLn;
      end;
    end
    else
      Writeln('не найдены');

    { TODO -oUser -cConsole Main : Insert code here }
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  iSearch := nil; // Освобождаем интерфей поиска считывателей
  iDll := nil;    // Освобождаем интерфей главный интерфейс SDK
  UnloadILR();    // Выгружаем DLL

  Readln;
end.

