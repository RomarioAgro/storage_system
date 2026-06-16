using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using IL.Readers;

namespace MfClassic
{
    class Program
    {
        // Ключ аутентификации Mifare
        public static Int64 g_AuthKey = 0xffffffffffff;
        // True, авторизовать по ключу B, иначе - A
        public static bool g_AuthKeyB = false;
        // Биты ключей аутентификации считывателя
        public static UInt32 g_RdKeys = 0;


        static void DoReadClassic(IILReader pReader)
        {
            try
            {
                CardInfo rCI;
                pReader.GetCardInfo(out rCI);
                int blockMax = rCI.GetNumberOfMfBlocks();
                MfBlockData[] blocks = new MfBlockData[blockMax];
                Console.Write("Чтение данных карты... ");
                int startTick = Environment.TickCount;
                if (g_RdKeys != 0)
                {
                    int keyIdx = pReader.AuthMfCardByRdKeys(0, g_AuthKeyB, g_RdKeys);
                    if (-1 == keyIdx)
                    {
                        Console.WriteLine("Нет подходящего ключа аутентификации");
                        return;
                    }
                }
                else
                {
                    pReader.LoadMfAuthKey(g_AuthKey);
                    if (!pReader.AuthMfCard(0, g_AuthKeyB))
                    {
                        Console.WriteLine("Ключ аутентификации не подошёл");
                        return;
                    }
                }
                int read = 0;
                pReader.ReadMfClassic(0, blocks, blocks.Length, out read);
                int span = Environment.TickCount - startTick;
                Console.WriteLine("прочитано {0} блоков за {1} мс", read, span);

                int sectorIdx = 0;
                int SBlockIdx = 0;
                uint accessBits = 0;

                for (int i = 0; i < read; ++i)
                {
                    int STrailer = (i < 128) ? 3 : 15;
                    if (0 == SBlockIdx)
                        accessBits = ILR.GetMfAccessBits(blocks[i + STrailer]);
                    // Выводим байты блока
                    MfBlockData blockData = blocks[i];
                    Console.WriteLine("{0} ({1}-{2}). " +
                        "{3:X2}{4:X2}{5:X2}{6:X2} {7:X2}{8:X2}{9:X2}{10:X2}" +
                        "{11:X2}{12:X2}{13:X2}{14:X2} {15:X2}{16:X2}{17:X2}{18:X2}",
                        i, sectorIdx, SBlockIdx,
                        blockData.a[0], blockData.a[1], blockData.a[2], blockData.a[3],
                        blockData.a[4], blockData.a[5], blockData.a[6], blockData.a[7],
                        blockData.a[8], blockData.a[9], blockData.a[10], blockData.a[11],
                        blockData.a[12], blockData.a[13], blockData.a[14], blockData.a[15]);

                    int areaN = (SBlockIdx * 3) / STrailer;
                    uint areaAccess = ILR.GetMfAreaAccess(accessBits, areaN);
                    // Если это блок-прицеп,
                    if (SBlockIdx == STrailer)
                    {
                        // Выводим параметры доступа прицепа
                        Console.Write("  Прицеп. Доступ ({0}, {1}, {2}): ",
                            (areaAccess & 1),
                            (areaAccess >> 1) & 1,
                            (areaAccess >> 2) & 1);
                        switch (areaAccess)
                        {
                            case 0: // 0 0 0
                                Console.WriteLine("Ключ A [-w]; Биты доступа [r-]; Ключ B [rw]");
                                break;

                            case 2: // 0 1 0
                                Console.WriteLine("Ключ A [--]; Биты доступа [r-]; Ключ B [r-]");
                                break;

                            case 1: // 1 0 0
                                if (g_AuthKeyB)
                                    Console.WriteLine("Ключ A [-w]; Биты доступа [r-]; Ключ B [-w]");
                                else
                                    Console.WriteLine("Ключ A [--]; Биты доступа [r-]; Ключ B [--]");
                                break;

                            case 3: // 1 1 0
                                Console.WriteLine("Ключ A [--]; Биты доступа [r-]; Ключ B [--]");
                                break;

                            case 4: // 0 0 1
                                Console.WriteLine("Ключ A [-w]; Биты доступа [rw]; Ключ B [rw]; транспортная");
                                break;

                            case 6: // 0 1 1
                                if (g_AuthKeyB)
                                    Console.WriteLine("Ключ A [-w]; Биты доступа [rw]; Ключ B [-w]");
                                else
                                    Console.WriteLine("Ключ A [--]; Биты доступа [r-]; Ключ B [--]");
                                break;

                            case 5: // 1 0 1
                                if (g_AuthKeyB)
                                    Console.WriteLine("Ключ A [--]; Биты доступа [rw]; Ключ B [-w]");
                                else
                                    Console.WriteLine("Ключ A [--]; Биты доступа [r-]; Ключ B [--]");
                                break;

                            case 7: // 1 1 1
                                Console.WriteLine("Ключ A [--]; Биты доступа [r-]; Ключ B [--]");
                                break;
                        }
                        ++sectorIdx;
                        SBlockIdx = 0;
                    }
                    else
                    {
                        // Выводим параметры доступа блока данных
                        Console.Write("  Данные. Доступ ({0}, {1}, {2}): ",
                            (areaAccess & 1),
                            (areaAccess >> 1) & 1,
                            (areaAccess >> 2) & 1);
                        switch (areaAccess)
                        {
                            case 0: // 0 0 0
                                Console.WriteLine("rwidtr; транспортная");
                                break;

                            case 2: // 0 1 0
                                Console.WriteLine("r-----");
                                break;

                            case 1:	// 1 0 0
                                if (g_AuthKeyB)
                                    Console.WriteLine("rw----");
                                else
                                    Console.WriteLine("r-----");
                                break;

                            case 3:	// 1 1 0
                                if (g_AuthKeyB)
                                    Console.WriteLine("rwidtr; блок-значение");
                                else
                                    Console.WriteLine("r--dtr; блок-значение");
                                break;

                            case 4: // 0 0 1
                                Console.WriteLine("r--dtr; блок-значение");
                                break;

                            case 6:	// 0 1 1
                                if (g_AuthKeyB)
                                    Console.WriteLine("rw----");
                                else
                                    Console.WriteLine("------");
                                break;

                            case 5:	// 1 0 1
                                if (g_AuthKeyB)
                                    Console.WriteLine("r-----");
                                else
                                    Console.WriteLine("------");
                                break;

                            case 7: // 1 1 1
                                Console.WriteLine("------");
                                break;
                        }
                        ++SBlockIdx;
                    }
                }
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
            }
        }

        static void DoWriteClassic(IILReader pReader)
        {
            try
            {
                // Запрашиваем номер сектора и номер блока Mifare
                Console.WriteLine("Введите номер сектора и номер блока:");
                string s = Console.ReadLine();
                char[] delimiterChars = { ' ', ',', ';', '\t' };
                string[] a = s.Split(delimiterChars, System.StringSplitOptions.RemoveEmptyEntries);
                if (a.Length != 2)
                {
                    Console.WriteLine("Неправильный ввод");
                    return;
                }
                int sectorIdx = Convert.ToInt32(a[0]);
                int SBlockIdx = Convert.ToInt32(a[1]);
                if ((sectorIdx < 0) || (SBlockIdx < 0))
                {
                    Console.WriteLine("Неправильный ввод");
                    return;
                }

                // Запрашиваем значения байтов блока Mifare
                Console.WriteLine("Введите байты 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 (16-ричные):");
                s = Console.ReadLine();
                a = s.Split(delimiterChars, System.StringSplitOptions.RemoveEmptyEntries);
                if (a.Length != 16)
                {
                    Console.WriteLine("Неправильный ввод");
                    return;
                }
                MfBlockData[] blocks = new MfBlockData[1];
                for (int i = 0; i < blocks[0].a.Length; i++)
                    blocks[0].a[i] = Convert.ToByte(a[i], 16);

                int blockIdx;
                bool isTrailer;
                if (sectorIdx < 32)
                {
                    blockIdx = (sectorIdx * 4) + SBlockIdx;
                    isTrailer = (3 == SBlockIdx);
                }
                else
                {
                    blockIdx = 128 + ((sectorIdx - 32) * 16) + SBlockIdx;
                    isTrailer = (15 == SBlockIdx);
                }
                // Если это блок-прицеп,
                if (isTrailer)
                {
                    // Проверяем корректность битов доступа
                    uint accessBits = BitConverter.ToUInt32(blocks[0].a, 6);
                    if (((accessBits & 0xFFF) ^ (accessBits >> 12)) != 0xFFF)
                    {
                        Console.WriteLine("Некорректное значение битов доступа. Запись отменена");
                        return;
                    }
                    // Выводим ключ A
                    UInt64 key = BitConverter.ToUInt64(blocks[0].a, 0) & 0xffffffffffff;
                    Console.WriteLine("Ключ A: 0x{0:X12}", key);
                    // Выводим ключ B
                    key = BitConverter.ToUInt64(blocks[0].a, 10) & 0xffffffffffff;
                    Console.WriteLine("Ключ B: 0x{0:X12}", key);
                }

                Console.Write("Запись... ");
                int written;
                int startTick = Environment.TickCount;
                if (g_RdKeys != 0)
                {
                    int keyIdx = pReader.AuthMfCardByRdKeys((uint)blockIdx, g_AuthKeyB, g_RdKeys);
                    if (-1 == keyIdx)
                    {
                        Console.WriteLine("Нет подходящего ключа аутентификации");
                        return;
                    }
                }
                else
                {
                    pReader.LoadMfAuthKey(g_AuthKey);
                    if (!pReader.AuthMfCard((uint)blockIdx, g_AuthKeyB))
                    {
                        Console.WriteLine("Ключ аутентификации не подошёл");
                        return;
                    }
                }
                pReader.WriteMfClassic(blockIdx, blocks, blocks.Length, out written);
                int span = Environment.TickCount - startTick;
                Console.WriteLine("записано {0} блок за {1} мс", written, span);
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
            }
        }

        static void DoWriteAuthKeyToReader(IILReader pReader)
        {
            try
            {
                // Запрашиваем номер ключа и значение ключа аутентификации Mifare
                Console.WriteLine("Введите номер ключа (10-тичное) и значение ключа (16-тичное):");
                string s = Console.ReadLine();
                char[] delimiterChars = { ' ', ',', ';', '\t' };
                string[] a = s.Split(delimiterChars, System.StringSplitOptions.RemoveEmptyEntries);
                if (a.Length != 2)
                {
                    Console.WriteLine("Неправильный ввод");
                    return;
                }
                int keyIdx = Convert.ToInt32(a[0]);
                Int64[] authKeys = new Int64[1];
                authKeys[0] = Convert.ToInt64(a[1]);

                Console.Write("Запись... ");
                int written;
                int startTick = Environment.TickCount;
                pReader.WriteMfAuthKeyToReader(keyIdx, g_AuthKeyB, authKeys, authKeys.Length, out written);
                int span = Environment.TickCount - startTick;
                Console.WriteLine("записано {0} ключей за {1} мс", written, span);
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
            }
        }

        static void DoSwitchAuthKeyType()
        {
            // Запрашиваем тип ключа: A или B
            Console.WriteLine("Введите тип ключа A или B:");
            string s = Console.ReadLine().ToUpper();
            if (s == "A")
                g_AuthKeyB = false;
            else if (s == "B")
                g_AuthKeyB = true;
            else
                Console.WriteLine("Неправильный ввод");
        }

        static void DoEnterAuthKey()
        {
            Console.WriteLine("Введите ключ аутентификации (16-ричное):");
            string s = Console.ReadLine().ToUpper();
            Int64 authKey = Convert.ToInt64(s, 16);
            if ((authKey < 0) || (authKey > 0xffffffffffff))
            {
                Console.WriteLine("Неправильный ввод");
                return;
            }
            g_AuthKey = authKey;
        }

        static void DoSelectRdAuthKeys()
        {
            Console.WriteLine("Введите номера ключей аутентификации (0..15) или '=' + битовую " +
                "маску (16-ричное):");
            string s = Console.ReadLine();
            if ((s != "") && (s[0] == '='))
                g_RdKeys = Convert.ToUInt32(s.Substring(1), 16);
            else
            {
                UInt32 RdKeys = 0;
                int keyIdx;
                char[] delimiterChars = { ' ', ',', ';', '\t' };
                string[] a = s.Split(delimiterChars, System.StringSplitOptions.RemoveEmptyEntries);
                for(int i = 0; i < a.Length; ++i)
                {
                    keyIdx = Convert.ToInt32(a[i]);
                    RdKeys |= (UInt32)(1 << keyIdx);
                }
                g_RdKeys = RdKeys;
            }
        }

        static void Main(string[] args)
        {
            try
            {
                // Получаем главный интерфейс SDK
                IILR piILR = null;
                ILR.Check(ILR.ILR_GetInterface(out piILR));

                // Ищем считыватель
                Console.Write("Поиск считывателя... ");
                IILRSearch pSearch = piILR.GetSearch();
                pSearch.Scan();
                if (pSearch.GetReaderCount() == 0)
                {
                    Console.WriteLine("не найден");
                    return;
                }
                ReaderInfo rRI;
                pSearch.GetReaderInfo(0, out rRI);
                pSearch = null;
                Console.WriteLine("{0}: {1}",
                    rRI.PortName,
                    ILR.kRdModelNames[(int)rRI.Model]);

                // Получаем интерфейс считывателя
                IILReader pReader = piILR.GetReader(rRI.PortType, rRI.PortName);
                // Отключаем авто поиск карт
                pReader.EnableAutoScan(false, false);
                // Подключаемся к считывателю
                Console.Write("Подключение к считывателю... ");
                pReader.Connect();
                Console.WriteLine("успешно");
               pReader.GetReaderInfo(out rRI);
                bool canRW = rRI.CanRWCardTypes().Contains(RWCardType.MfClassic);
                CardInfo rCI;
                string s;
                while (true)
                {
                    Console.Write("Поиск карты Mifare Classic... ");
                    pReader.Scan(false);
                    pReader.GetCardInfo(out rCI);
                    bool cardFound = rCI.IsMfClassicMode();

                    // Если карта Mifare Classic найдена,
                    if (cardFound)
                        Console.WriteLine("{0} {1}",
                            ILR.kCardTypeNames[(int)rCI.type],
                            ILR.CardUIDToStr(rCI.type, rCI.UID));
                    else // Mifare Classic не найдена
                        Console.WriteLine("не найдена");

                    Console.WriteLine("-----");
                    Console.WriteLine("Введите номер команды:");
                    Console.WriteLine("1 - Искать снова");
                    if (cardFound && canRW)
                    {
                        Console.WriteLine("2 - Прочитать данные из карты");
                        Console.WriteLine("3 - Записать данные на карту...");
                    }
                    Console.WriteLine("4 - Записать ключ аутентификации в считыватель...");
                    Console.WriteLine("5 - Переключить тип ключа A или B [{0}]...",
                        g_AuthKeyB ? 'B' : 'A');
                    Console.WriteLine("6 - Ввести ключ аутентификации [{0:X12}]...",
                        g_AuthKey);
                    Console.WriteLine("7 - Выбрать ключи аутентификации считывателя [{0:X4}]...",
                        g_RdKeys);
                    Console.WriteLine("0 - Выйти из программы");
                    s = Console.ReadLine();
                    Console.WriteLine();
                    switch (Convert.ToInt32(s))
                    {
                        case 0:
                            return;

                        case 1:
                            break;

                        case 2:
                            if (cardFound && canRW)
                                DoReadClassic(pReader);
                            break;

                        case 3:
                            if (cardFound && canRW)
                                DoWriteClassic(pReader);
                            break;

                        case 4:
                            DoWriteAuthKeyToReader(pReader);
                            break;

                        case 5:
                            DoSwitchAuthKeyType();
                            break;

                        case 6:
                            DoEnterAuthKey();
                            break;

                        case 7:
                            DoSelectRdAuthKeys();
                            break;

                        default:
                            Console.WriteLine("Неправильный ввод");
                            break;
                    }
                }
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
            }

            Console.Write("\nНажмите любую клавишу для выхода...");
            Console.ReadKey();
        }
    }
}
