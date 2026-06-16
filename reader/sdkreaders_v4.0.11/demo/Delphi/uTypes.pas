unit uTypes;

interface

uses
  System.Generics.Collections,
  IL.Readers;

type
  // Информация о языке интерфейса программы
  TLangInfo = record
    m_sExt          : string;   // Расширение файла без точки = аббревиатура языка
    m_nLocale       : Cardinal; // Id языка
    m_sName         : string;   // Отображаемое имя языка
  end;
  PLangInfo = ^TLangInfo;

  // Вид окна с изменяемыми размерами
  TSizeWinKind = (
    swMainWnd,            // Главное окно
    swTemicPasswordsDlg,  // Окно "Temic passwords"
    swMfClassicDlg,       // Окно "Mifare Classic"
    swMfClassicKeysDlg,   // Окно "Mifare Classic keys"
    swMfReaderMcKeysDlg,  // Окно "Mifare reader Classic keys"
    swMfPlusSL3Dlg,       // Окно "Mifare Plus"
    swMfPlusKeysDlg,      // Окно "Mifare Plus keys"
    swMfReaderMpKeysDlg   // Окно "Mifare reader Plus keys"
  );

  // Формат значения в ячейке TStringGrid
  TCellFormat = (
    cfBin,    // Двоичный
    cfDec,    // Десятичный
    cfHex     // Шестнадцатеричный
  );

  // Инфо о пароле Temic
  TTemicPassword = record
    m_nPassword     : Cardinal; // Пароль Temic
    m_sComment      : string;   // Комментарий
  end;
  PTemicPassword = ^TTemicPassword;

  // Формат пароля Temic
  TTmcPasswFormat = (
    tpfDec,   // Десятичный
    tpfHex    // Шестнадцатеричный
  );

  // Формат номера HID
  THidFormat = (
    hfDec,    // Десятичный
    hfHex     // Шестнадцатеричный
  );

  // Инфо о ключе аутентификации Mifare Classic
  TMcKeyInfo = record
    m_nKey          : TMfClassicKey;  // Ключ аутентификации
    m_sComment      : string;         // Комментарий
  end;
  PMcKeyInfo = ^TMcKeyInfo;

  // Инфо о ключе аутентификации Mifare Plus
  TMpKeyInfo = record
    m_rKey          : TMfPlusKey;  // Ключ аутентификации
    m_sComment      : string;      // Комментарий
  end;
  PMpKeyInfo = ^TMpKeyInfo;


implementation


end.
