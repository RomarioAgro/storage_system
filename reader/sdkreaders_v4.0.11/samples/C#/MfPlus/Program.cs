using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using IL.Readers;

namespace MfPlus
{
    class Program
    {
        public const bool kOpenText = true;
        public static bool g_AuthKeyB = false;
        public static MfPlusKey g_AuthKey = MfPlusKey.Default();
        public static UInt32 g_RdKeys = 0;

        static void DoReadPlusSL3(IILReader pReader)
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
                    pReader.LoadMfPlusAuthKey(ref g_AuthKey);
                    if (!pReader.AuthMfCard(0, g_AuthKeyB))
                    {
                        Console.WriteLine("Ключ аутентификации не подошёл");
                        return;
                    }
                }
                int read = 0;
                pReader.ReadMfPlus(0, blocks, blocks.Length, kOpenText, out read);
                int span = Environment.TickCount - startTick;
                Console.WriteLine("прочитано {0} блоков за {1} мс", read, span);

                int sectorIdx = 0;
                int SBlockIdx = 0;
                int STrailer, areaN;
                uint accessBits, areaAccess;
                byte c1 = 0, c2 = 0, c3 = 0, En = 0;
                MfBlockData blockData;
                string[] kOpenTextStrs = { "Зашифрованная передача", "Открытая передача" };
                for (int i = 0; i < read; ++i)
                {
                    STrailer = (i < 128) ? 3 : 15;
                    if (0 == SBlockIdx)
                    {
                        blockData = blocks[i + STrailer];
                        accessBits = 0;
                        BitConverter.ToUInt32(blockData.a, 6);
                        c1 = (Byte)(accessBits >> 12);
                        c2 = (Byte)(accessBits >> 16);
                        c3 = (Byte)(accessBits >> 20);
                        En = blockData.a[5];
                    }
                    // Выводим байты блока
                    blockData = blocks[i];
                    Console.WriteLine("{0} ({1}-{2}). " +
                        "{3:X2}{4:X2}{5:X2}{6:X2} {7:X2}{8:X2}{9:X2}{10:X2}" +
                        "{11:X2}{12:X2}{13:X2}{14:X2} {15:X2}{16:X2}{17:X2}{18:X2}",
                        i, sectorIdx, SBlockIdx,
                        blockData.a[0], blockData.a[1], blockData.a[2], blockData.a[3],
                        blockData.a[4], blockData.a[5], blockData.a[6], blockData.a[7],
                        blockData.a[8], blockData.a[9], blockData.a[10], blockData.a[11],
                        blockData.a[12], blockData.a[13], blockData.a[14], blockData.a[15]);

                    areaN = SBlockIdx / (STrailer / 3);
                    areaAccess = (((uint)c1 >> areaN) & 1) |
                        ((((uint)c2 >> areaN) & 1) << 1) |
                        ((((uint)c3 >> areaN) & 1) << 2);
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
                    Console.WriteLine("\t{0}", kOpenTextStrs[(En >> areaN) & 1]);
                }
                Console.WriteLine("-----");
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
            }
        }

        static void DoWritePlusSL3(IILReader pReader)
        {
            try
            {
                // Запрашиваем номер сектора и номер блока Mifare
                Console.WriteLine("Введите номер сектора и номер блока (10-тичное):");
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

                // Запрашиваем значения байтов блока Mifare
                Console.WriteLine("Введите байты 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 (16-ричное):");
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

                uint address;
                bool isTrailer;
                if (sectorIdx < 32)
                {
                    address = (uint)((sectorIdx * 4) + SBlockIdx);
                    isTrailer = (3 == SBlockIdx);
                }
                else
                {
                    address = (uint)(128 + ((sectorIdx - 32) * 16) + SBlockIdx);
                    isTrailer = (15 == SBlockIdx);
                }
                // Если это блок-прицеп,
                if (isTrailer)
                {
                    // Проверяем корректность битов доступа
                    uint accessBits = BitConverter.ToUInt32(blocks[0].a, 6);
                    Byte c1 = (Byte)((accessBits >> 12) & 0xF);
                    Byte c2 = (Byte)((accessBits >> 16) & 0xF);
                    Byte c3 = (Byte)((accessBits >> 20) & 0xF);
                    Byte t1 = (Byte)(accessBits & 0xF);
                    Byte t2 = (Byte)((accessBits >> 4) & 0xF);
                    Byte t3 = (Byte)((accessBits >> 8) & 0xF);
                    if (((c1 ^ t1) != 0xF) || ((c2 ^ t2) != 0xF) || ((c3 ^ t3) != 0xF))
                    {
                        Console.WriteLine("Некорректное значение битов доступа. Запись отменена");
                        return;
                    }
                    // Проверяем корректность битов доступа En
                    Byte En = blocks[0].a[5];
                    if (((En & 0xF) ^ (En >> 4)) != 0xF)
                    {
                        Console.WriteLine("Некорректное значение битов доступа En. Запись отменена");
                        return;
                    }
                }

                Console.Write("Запись... ");
                int written;
                int startTick = Environment.TickCount;
                if (g_RdKeys != 0)
                {
                    int keyIdx = pReader.AuthMfCardByRdKeys(address, g_AuthKeyB, g_RdKeys);
                    if (-1 == keyIdx)
                    {
                        Console.WriteLine("Нет подходящего ключа аутентификации");
                        return;
                    }
                }
                else
                {
                    pReader.LoadMfPlusAuthKey(ref g_AuthKey);
                    if (!pReader.AuthMfCard(address, g_AuthKeyB))
                    {
                        Console.WriteLine("Ключ аутентификации не подошёл");
                        return;
                    }
                }
                pReader.WriteMfPlus(address, blocks, blocks.Length, kOpenText, out written);
                int span = Environment.TickCount - startTick;
                Console.WriteLine("записано {0} блоков за {1} мс", written, span);
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
            }
        }

        static void WriteAuthKeyToReader(IILReader pReader)
        {
            try
            {
                Console.WriteLine("Введите номер ключа (10-тичное) и значение ключа (16-ричное):");
                string s = Console.ReadLine();
                int keyIdx = -1;
                MfPlusKey[] keys = new MfPlusKey[1];
                keys[0] = MfPlusKey.Default();
                char[] delimiterChars = { ' ', ',', ';', '\t' };
                int pos = s.IndexOfAny(delimiterChars);
                bool ok = (pos != -1);
                if (ok)
                {
                    keyIdx = Convert.ToInt32(s.Substring(0, pos));
                    s = s.Remove(0, pos + 1).Replace(" ", "");
                    ok = (s.Length == 32);
                    if (ok)
                    {
                        pos = s.Length - 2;
                        for (int i = 0; i < keys[0].a.Length; ++i)
                        {
                            keys[0].a[i] = Convert.ToByte(s.Substring(pos, 2), 16);
                            pos -= 2;
                        }
                    }
                }

                if (!ok)
                {
                    Console.WriteLine("Неправильный ввод");
                    return;
                }

                Console.Write("Запись... ");
                int written;
                int startTick = Environment.TickCount;
                pReader.WriteMfPlusAuthKeyToReader(keyIdx, g_AuthKeyB, keys, keys.Length, out written);
                int span = Environment.TickCount - startTick;
                Console.WriteLine("записано {0} ключей за {1} мс", written, span);
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
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
                bool canRW = rRI.CanRWCardTypes().Contains(RWCardType.MfPlus);

                while (true)
                {
                    Console.Write("Поиск карты Mifare Plus SL3... ");
                    pReader.Scan(false);
                    CardInfo rCI;
                    pReader.GetCardInfo(out rCI);
                    bool fCardFound = rCI.IsMfPlusSL3Mode();
                    // Если карта Mifare Plus SL3 найдена,
                    if (fCardFound)
                        Console.WriteLine("{0} {1}",
                            ILR.kCardTypeNames[(int)rCI.type],
                            ILR.CardUIDToStr(rCI.type, rCI.UID));
                    else // Mifare Plus SL3 не найдена
                        Console.WriteLine("не найдена");

                    Console.WriteLine("-----");
                    Console.WriteLine("Введите номер команды:");
                    Console.WriteLine("1 - Искать снова");
                    if (fCardFound && canRW)
                    {
                        Console.WriteLine("2 - Прочитать данные из карты");
                        Console.WriteLine("3 - Записать данные на карту...");
                    }
                    Console.WriteLine("4 - Записать ключ аутентификации в считыватель...");
                    Console.WriteLine("0 - Выйти из программы");
                    string s = Console.ReadLine();
                    Console.WriteLine();
                    switch (Convert.ToInt32(s))
                    {
                        case 0:
                            return;

                        case 1:
                            break;

                        case 2:
                            if (fCardFound && canRW)
                                DoReadPlusSL3(pReader);
                            break;

                        case 3:
                            if (fCardFound && canRW)
                                DoWritePlusSL3(pReader);
                            break;

                        case 4:
                            WriteAuthKeyToReader(pReader);
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
