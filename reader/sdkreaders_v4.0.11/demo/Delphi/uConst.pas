unit uConst;

interface

uses
  IL.Readers;

const
  // Имя файла со списком паролей Temic
  kTemicPasswordsFilename = 'TemicPasswords.csv';
  // Имя файла со списком ключей аутентификации Mifare Classic
  kMfClassicKeysFilename = 'MfClassicKeys.csv';
  // Имя файла со списком ключей аутентификации Mifare Plus
  kMfPlusKeysFilename = 'MfPlusKeys.csv';

resourcestring
  // '[%s] Найден считыватель (%s): %s'
  SReaderFound_SSS = '[%s] Reader found (%s): %s';
  // '[%s] Потерян считыватель (%s): %s'
  SReaderLost_SSS = '[%s] Reader lost (%s): %s';
  // 'с/н:%d'
  SSn_D = 's/n:%d';
  // 'fw:%s'
  SFW_S = 'fw:%s';
  // 'сборка %s'
  SBuild_S = 'build %s';
  // 'Поиск...'
  SSearching = 'Searching...';
  // 'Поиск завершён (%f с)'
  SSearchComplite_F = 'Search is completed (%f s)';
  // 'Нет карты'
  SNoCard = 'No card';
  // 'Страница/Байт'
  SPageByte = 'Page/Byte';
  // 'Блк Стр-Блок\Байт'
  StrLockPgBlockByte = 'Lock Pg-Block\Byte';
  // 'Пароль'
  SPassword = 'Password';
  // 'Комментарий'
  SComment = 'Comment';
  // 'Нет эмулируемой карты'
  SNoEmulatedCard = 'No emulated card';
  // 'Ключ'
  SKey = 'Key';
  // 'Запись ключей аутентификации...'
  SWritingAuthKeys = 'Writing authentication keys...';
  // 'Чтение блоков...'
  SReadingBlocks = 'Reading blocks...';
  // 'Чтение блоков завершено (%f с).'
  SReadingBlocksCompleted_F = 'Reading blocks completed (%f sec).';
  // 'Не удалось авторизовать сектор %d'
  SEAuthorizeSector_D = 'Failed to authorize sector %d';
  // 'Не удалось прочитать блок %d: %s'
  SEReadBlock_DS = 'Failed to read block %d: %s';
  // 'Неправильные биты передачи 0x%.2X сектора %d'
  SEWrongTransferBits_DD = 'Incorrect transfer bits 0x%.2X sectors %d';
  // 'Запись блоков...'
  SWritingBlocks = 'Writing blocks...';
  // 'Не удалось записать блок %d: %s'
  SEWriteBlock_DS = 'Failed to write block %d: %s';
  // 'Не удалось установить ключ аутентификации A для сектора %d'
  SESetAuthKeyA_DS = 'Failed to set authentication key A for sector %d: %s';
  // 'Не удалось установить ключ аутентификации B для сектора %d'
  SESetAuthKeyB_DS = 'Failed to set authentication key B for sector %d: %s';
  // 'Ключ сектора %d не введён, блок-прицеп не записан'
  SENoInitSectorKey_D = 'Sector key %d has not been entered, block trailer has not been written.';
  // 'Записать блоков завершена (%f с).'
  SWriteBlocksCompleted_F = 'Write blocks completed (%f sec).';
  // 'Отменено.'
  SCancelled = 'Cancelled.';
  // 'Авто'
  SAuto = 'Auto';
  // 'Уверены?'
  SConfirm = 'Really?';

  { Состояния подключения к считывателю }

  // 'Подключён'
  SConnected = 'Connected';
  // 'Отключён'
  SDisconnected = 'Disconnected';
  // 'Подключение...'
  SConnecting = 'Connecting...';

  { Группы окна "Mifare Classic" }

  // 'Сектор %d'
  SSector_D = 'Sector %d';
  // 'Все'
  SAll = 'All';
  // 'Малые (до 32)'
  SSmallUnder32 = 'Small (up to 31)';
  // 'Большие (от 32)'
  SBigFrom32 = 'Large (from 32)';

  { Столбцы таблицы "Mifare Classic" }

  // 'Б'
  SColBlock = 'B';
  // 'С.б'
  SColSBlock = 'S.b';

  { Столбцы Combobox "Доступ к области данных" и "Доступ к блоку-прицепу" }

  SDataAccessCols = 'State|Read|Write|Increment|Decrement, transfer, restore|Application';
  STrailerAccessCols = 'State|Read A|Write A|Read Access|Write Access|Read B|Write B|Remark';

  { Области сектора в окне "Mifare Classic" }

  SBlock0_4 = 'Block 0-4:';
  SBlock5_9 = 'Block 5-9:';
  SBlock10_14 = 'Block 10-14:';
  SBlock0 = 'Block 0:';
  SBlock1 = 'Block 1:';
  SBlock2 = 'Block 2:';

  // 'Блок значение №%d'
  SValueBlock_D = 'Value block #%d';

const
  // Название состояний подключения устройства
  kConnectionStatusNames: array[csDisconnected .. csConnecting] of PResStringRec = (
    @SDisconnected,
    @SConnected,
    @SConnecting
  );

implementation

end.
