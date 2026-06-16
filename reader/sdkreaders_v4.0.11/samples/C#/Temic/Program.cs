using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using IL.Readers;

namespace Temic
{
    class Program
    {
        // Пароль для доступа к Temic, =-1 нет пароля
        public const Int64 kPassword = -1;

        static void DoReadTemic(IILReader pReader)
        {
            try
            {
                Console.Write("Чтение данных карты... ");
                uint[] blocks = new uint[10];
                int read = 0;
                int startTick = Environment.TickCount;
                pReader.LoadTemicPassword(kPassword);
                pReader.ReadTemic(0, blocks, blocks.Length, -1, out read);
                int span = Environment.TickCount - startTick;
                Console.WriteLine("прочитано {0} блоков за {1} мс", read, span);

                uint[] kBitRates = { 8, 16, 32, 40, 50, 64, 100, 128 };
                string[] kPskCf = { "RF/2", "RF/4", "RF/8", "Reserved" };
                uint config = 0;
                uint dataRate = 0;
                uint modulation = 0;
                uint maxBlock = 0;
                uint blockData;
                for (int i = 0; i < blocks.Length; ++i)
                {
                    blockData = blocks[i];
                    Console.WriteLine("{0}. {1:X2} {2:X2} {3:X2} {4:X2}",
                        i,
                        blockData & 0xff,
                        (blockData >> 8) & 0xff,
                        (blockData >> 16) & 0xff,
                        blockData >> 24);
                    switch (i)
                    {
                        case 0: // Configuration data
                            Console.WriteLine("Конфигурация");
                            config = blockData;
                            bool XMode = (blockData & (1 << 9)) != 0;
                            if (XMode)
                                Console.WriteLine("\tРежим: X-Mode");
                            else
                                Console.WriteLine("\tРежим: e5550 Compatibility Mode");
                            Console.WriteLine("\tMaster Key: {0}", (config >> 4) & 0xf);
                            if (XMode)
                                dataRate = ((config >> 10) & 0x3F) * 2 + 2;
                            else
                                dataRate = kBitRates[(config >> 10) & 7];
                            Console.WriteLine("\tData Bit Rate: RF/{0}", dataRate);
                            modulation = ((config >> 20) & 0xF) | (((config >> 8) & 1) << 4);
                            string s;
                            switch (modulation)
                            {
                                case 0: // 0 0 0 0 0
                                    s = "Direct";
                                    break;

                                case 1: // 0 0 0 0 1
                                    s = "PSK1";
                                    break;

                                case 2: // 0 0 0 1 0
                                    s = "PSK2";
                                    break;

                                case 3: // 0 0 0 1 1
                                    s = "PSK3";
                                    break;

                                case 4: // 0 0 1 0 0
                                    s = "FSK1";
                                    break;

                                case 5: // 0 0 1 0 1
                                    s = "FSK2";
                                    break;

                                case 6: // 0 0 1 1 0
                                    s = "FSK1a";
                                    break;

                                case 7: // 0 0 1 1 1
                                    s = "FSK2a";
                                    break;

                                case 8: // 0 1 0 0 0
                                    s = "Manchester";
                                    break;

                                case 0x10: // 1 0 0 0 0
                                    s = "Biphase('50)";
                                    break;

                                case 0x18: // 1 1 0 0 0
                                    s = "Biphase('57)";
                                    break;

                                default:
                                    s = "";
                                    break;
                            }
                            Console.WriteLine("\tModulation: {0}", s);
                            Console.WriteLine("\tPSK-CF: {0}", kPskCf[(config >> 18) & 3]);
                            Console.WriteLine("\tAOR: {0}", (config & (1 << 17)) != 0);
                            if (XMode)
                                Console.WriteLine("\tOTP: {0}", (config & (1 << 16)) != 0);
                            maxBlock = (config >> 29) & 7;
                            Console.WriteLine("\tMAX-BLOCK: {0}", maxBlock);
                            Console.WriteLine("\tPassword: {0}", (config & (1 << 28)) != 0);
                            if (XMode)
                            {
                                Console.WriteLine("\tSST-Sequence Start Marker: {0}", (config & (1 << 27)) != 0);
                                Console.WriteLine("\tFastwrite: {0}", (config & (1 << 26)) != 0);
                                Console.WriteLine("\tInverse Data: {0}", (config & (1 << 25)) != 0);
                            }
                            else
                                Console.WriteLine("\tSST-Sequence Start Marker: {0}", (config & (1 << 27)) != 0);
                            Console.WriteLine("\tPOR delay: {0}", (config & (1 << 24)) != 0);
                            break;

                        case 7:	// User data or password
                            if ((config & (1 << 28)) != 0)
                                Console.WriteLine("Пароль");
                            else
                                Console.WriteLine("Данные пользователя");
                            break;

                        case 8: // Traceability data
                            Console.WriteLine("Данные производителя");
                            Console.WriteLine("\tACL: {0:X2}", blockData & 0xff);
                            Console.WriteLine("\tMFC: {0:X2}", (blockData >> 8) & 0xff);
                            Console.WriteLine("\tICR: {0:X2}", (blockData >> 16) & 0xff);
                            Console.WriteLine("\tMSN LotID: {0}", blockData >> 24);
                            break;

                        case 9:	// Traceability data
                            Console.WriteLine("Данные производителя");
                            Console.WriteLine("\tLotID: {0}", blockData & 0xFFF);
                            Console.WriteLine("\twafer #: 0x{0:X2}", (blockData >> 12) & 0x3F);
                            Console.WriteLine("\tdie on wafer #: 0x{0:X4}", (blockData >> 18) & 0x3FFF);
                            break;

                        default:
                            Console.WriteLine("Данные пользователя");
                            break;
                    }
                }
                CardUID uid;
                bool f;
                if ((64 == dataRate) && (8 == modulation) && (2 == maxBlock))
                {
                    pReader.DecodeTemicEmMarine(blocks, 3, out uid, out f);
                    if (!uid.IsEmpty())
                        Console.WriteLine("Эмулирует Em-Marine {0}", 
                            ILR.CardUIDToStr(CardType.EmMarine, uid));
                }
                else if ((50 == dataRate) && (5 == modulation) && (3 == maxBlock))
                {
                    int wiegand;
                    pReader.DecodeTemicHID(blocks, 4, out uid, out wiegand, out f);
                    if (!uid.IsEmpty())
                        Console.WriteLine("Эмулирует HID(W{0}) {1}",
                            wiegand,
                            ILR.CardUIDToStr(CardType.HID, uid));
                }
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
            }
        }

        static void DoWriteTemic(IILReader pReader)
        {
            try
            {
                // Запрашиваем номер блока Temic
                Console.WriteLine("Введите номер блока и байты 0 1 2 3 (16-ричное):");
                string s = Console.ReadLine();
                char[] delimiterChars = { ' ', ',', ';', '\t' };
                string[] a = s.Split(delimiterChars, System.StringSplitOptions.RemoveEmptyEntries);
                if (a.Length != 5)
                {
                    Console.WriteLine("Неправильный ввод");
                    return;
                }
                int blockIdx = Convert.ToInt32(a[0], 16);
                byte[] bytes = new byte[4];
                for (int i = 1; i < a.Length; ++i)
                    bytes[i - 1] = Convert.ToByte(a[i], 16);
                uint[] blocks = new uint[1];
                blocks[0] = BitConverter.ToUInt32(bytes, 0);

                Console.Write("Запись... ");
                int written;
                int startTick = Environment.TickCount;
                pReader.LoadTemicPassword(kPassword);
                pReader.WriteTemic(blockIdx, blocks, blocks.Length, false, -1, 
                    out written);
                int span = Environment.TickCount - startTick;
                Console.WriteLine("записано {0} блок за {1} мс", written, span);
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
            }
        }

        static void DoWriteEmMarine(IILReader pReader)
        {
            try
            {
                // Запрашиваем номер Em-Marine: 1) код производителя (шестнадцатиричное число),
                //  2) номер серии  (десятичное), 3) номер (десятичное)
                Console.WriteLine("Введите номер Em-Marine: код производителя (16-ричное), серия (10-тичное), номер (10-тичное):");
                string s = Console.ReadLine();
                char[] delimiterChars = { ' ', ',', ';', '\t' };
                string[] a = s.Split(delimiterChars, System.StringSplitOptions.RemoveEmptyEntries);
                if (a.Length != 3)
                {
                    Console.WriteLine("Неправильный ввод");
                    return;
                }
                UInt16 facility = Convert.ToUInt16(a[0], 16);
                Byte series = Convert.ToByte(a[1]);
                UInt16 number = Convert.ToUInt16(a[2]);
                CardUID uid = new CardUID();
                uid.SetEmMarine(series, number, facility);

                uint[] blocks = new uint[3];
                pReader.EncodeTemicEmMarine(uid, blocks, blocks.Length);

                Console.Write("Запись... ");
                int written;
                int startTick = Environment.TickCount;
                pReader.LoadTemicPassword(kPassword);
                pReader.WriteTemic(0, blocks, blocks.Length, false, -1, out written);
                int span = Environment.TickCount - startTick;
                Console.WriteLine("записано {0} блока за {1} мс", written, span);
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
            }
        }

        static void DoWriteHID(IILReader pReader)
        {
            try
            {
                // Запрашиваем номер HID: 1) номер кодировки Wiegand (десятичное число),
                //  2) код производителя (шестнадцатиричное), 3) номер (десятичное)
                Console.WriteLine("Введите номер HID: виганд (10-тичное), код прозводителя (16-ричное), номер (10-тичное):");
                string s = Console.ReadLine();
                char[] delimiterChars = { ' ', ',', ';', '\t' };
                string[] a = s.Split(delimiterChars, System.StringSplitOptions.RemoveEmptyEntries);
                if (a.Length != 3)
                {
                    Console.WriteLine("Неправильный ввод");
                    return;
                }
                Int32 wiegand = Convert.ToInt32(a[0]);
                UInt32 facility = Convert.ToUInt32(a[1], 16);
                UInt16 number = Convert.ToUInt16(a[2]);
                CardUID uid = new CardUID();
                uid.SetHID(wiegand, number, facility);

                uint[] blocks = new uint[4];
                pReader.EncodeTemicHID(uid, blocks, blocks.Length, wiegand);

                Console.Write("Запись... ");
                int written;
                int startTick = Environment.TickCount;
                pReader.LoadTemicPassword(kPassword);
                pReader.WriteTemic(0, blocks, blocks.Length, false, -1, out written);
                int span = Environment.TickCount - startTick;
                Console.WriteLine("записано {0} блока за {1} мс", written, span);
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
            }
        }

        static void DoInitTemic(IILReader pReader)
        {
            try
            {
                // Подготавливаем данные для записи - стандартная конфигурация
                uint[] blocks = new uint[1];
                blocks[0] = 0x40801400;

                Console.Write("Запись... ");
                int written;
                int startTick = Environment.TickCount;
                pReader.LoadTemicPassword(kPassword);
                pReader.WriteTemic(0, blocks, blocks.Length, false, -1, out written);
                int span = Environment.TickCount - startTick;
                Console.WriteLine("записан {0} блок за {1} мс", written, span);
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
                bool canRW = rRI.CanRWCardTypes().Contains(RWCardType.Temic);
                if (canRW)
                    pReader.EnableAutoScanTemic();

                while (true)
                {
                    Console.Write("Поиск карты Temic... ");
                    pReader.Scan(false);
                    CardInfo rCI;
                    pReader.GetCardInfo(out rCI);
                    bool cardFound = (rCI.type == CardType.Temic);
                    // Если карта Temic найдена,
                    if (cardFound)
                        Console.WriteLine("{0} {1}",
                            ILR.kCardTypeNames[(int)rCI.type],
                            ILR.CardUIDToStr(rCI.type, rCI.UID));
                    else // Temic не найдена
                        Console.WriteLine("не найдена");

                    Console.WriteLine("-----");
                    Console.WriteLine("Введите номер команды:");
                    Console.WriteLine("1 - Искать снова");
                    if (canRW)
                    {
                        if (cardFound)
                        {
                            Console.WriteLine("2 - Прочитать данные из карты");
                            Console.WriteLine("3 - Записать данные на карту...");
                            Console.WriteLine("4 - Записать Em-Marine...");
                            Console.WriteLine("5 - Записать HID...");
                        }
                        else
                            Console.WriteLine("2 - Инициализировать карту Temic");
                    }
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
                            if (canRW)
                            {
                                if (cardFound)
                                    DoReadTemic(pReader);
                                else
                                    DoInitTemic(pReader);
                            }
                            break;

                        case 3:
                            if (cardFound && canRW)
                                DoWriteTemic(pReader);
                            break;

                        case 4:
                            if (cardFound && canRW)
                                DoWriteEmMarine(pReader);
                            break;

                        case 5:
                            if (cardFound && canRW)
                                DoWriteHID(pReader);
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
