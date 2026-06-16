program ConnectToReader;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  WinApi.Windows,
  System.SysUtils,
  IL.Readers, IL.RUtils;


procedure ReaderNotify(AMsg: TReaderMsg; AMsgData, AUserData: Pointer); stdcall;
var
  nStatus: TConnectionStatus;
  iReader: IILReader;
begin
  if AMsg = rmConnectionChanged then
  begin
    try
      iReader := IILReader(AUserData);
      nStatus := iReader.GetConnectionStatus;
      case nStatus of
        csDisconnected: Writeln('Считыватель отключён');
        csConnected: Writeln('Считыватель подключён');
        csConnecting: Writeln('Подключение к считывателю...');
      end;
    except
      on E: Exception do
        Writeln(E.ClassName, ': ', E.Message);
    end;
  end;
end;

var
  iDll: IILR;
  iSearch: IILRSearch;
  iReader: IILReader;
  rRI: TReaderInfo;
  s: string;
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
      // Получаем информацию о считывателе
      iReader.GetReaderInfo(rRI);
      Write(format('%s: %s', [
          StrPas(rRI.szPortName),
          kRdModelNames[rRI.nModel]]));
      if rRI.nSn <> -1 then
        Write(format(' с/н:%d', [rRI.nSn]));
      if rRI.nFwVersion <> 0 then
        Write(format(' прошивка:%s', [ILRVersionToStr(rRI.nFwVersion)]));
      if rRI.nFwBuildDate <> 0 then
        Write(format(' сборка %s', [ILRTimeToStr(rRI.nFwBuildDate)]));
      WriteLn;
      // Устанавливаем функцию для получения уведомлений о
      //  потери/восстановлении связи со считывателем
      iReader.SetNotifyCallback(ReaderNotify, Pointer(iReader));
      repeat
        Writeln('-----');
        Writeln('Введите номер команды:');
        Writeln('1 - Подключиться');
        Writeln('2 - Отключиться');
        Writeln('0 -  Выйти из программы');
        Readln(s);
        Writeln;
        case StrToIntDef(s, -1) of
          0: Exit;
          1: iReader.Connect();
          2: iReader.Disconnect();
          else Writeln('Неправильный ввод');
        end;
      until False;
      iReader := nil;
    finally
      iReader := nil;
      iSearch := nil;
      iDll := nil;
      // Выгружаем DLL
      UnloadILR();
    end;

    Readln;

    { TODO -oUser -cConsole Main : Insert code here }
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
