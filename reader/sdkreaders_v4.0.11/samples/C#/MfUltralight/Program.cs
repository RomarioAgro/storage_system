using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using IL.Readers;

namespace MfUltralight
{
    class Program
    {
        static void DoReadUltralight(IILReader pReader)
        {
            try
            {
                Console.Write("Чтение данных карты... ");
                UInt32[] pages = new UInt32[16]; // 16 страниц по 4 байта
                int read = 0;
                int startTick = Environment.TickCount;
                pReader.ReadMfUlralight(0, pages, pages.Length, out read);
                int span = Environment.TickCount - startTick;
                Console.WriteLine("прочитано {0} страниц за {1} мс", read, span);

                Console.WriteLine();
                Console.WriteLine("Страница. Байты 0..3");
                UInt32 pageData, n;
                bool locked;
                for (int i = 0; i < 16; ++i)
                {
                    pageData = pages[i];
                    Console.Write("{0}. {1:X2} {2:X2} {3:X2} {4:X2}",
                        i, 
                        pageData & 0xff, 
                        (pageData >> 8) & 0xff, 
                        (pageData >> 16) & 0xff, 
                        (pageData >> 24));
                    switch(i)
                    {
                        case 0: // Serial Number
                        case 1:
                            Console.WriteLine(" Серийный номер");
                            break;

                        case 2: // Internal / Lock
                            Console.WriteLine(" Внутреннее / Блокировка");
                            n = (pageData >> 16);
                            Console.WriteLine("Lock0[{0:X2}] BOTP:{1}, BL9-4:{2}, BL15-10:{3}, OTP:{4}, L4:{5}, L5:{6}, L6:{7}, L7:{8}",
                                n & 0xff,
                                n & 1,
                                (n >> 1) & 1,
                                (n >> 2) & 1,
                                (n >> 3) & 1,
                                (n >> 4) & 1,
                                (n >> 5) & 1,
                                (n >> 6) & 1,
                                (n >> 7) & 1);
                            Console.WriteLine("Lock1[{0:X2}] L8:{1}, L9:{2}, L10:{3}, L11:{4}, L12:{5}, L13:{6}, L14:{7}, L15:{8}",
                                n >> 8,
                                (n >> 8) & 1,
                                (n >> 9) & 1,
                                (n >> 10) & 1,
                                (n >> 11) & 1,
                                (n >> 12) & 1,
                                (n >> 13) & 1,
                                (n >> 14) & 1,
                                (n >> 15) & 1);
                            break;

                        case 3: // OTP
                            StringBuilder builder = new StringBuilder("00000000 00000000 00000000 00000000");
                            n = pageData;
                            for(int j = 0; j < builder.Length; ++j)
                            {
                                if (builder[j] == ' ')
                                    continue;
                                if ((n & 1) != 0)
                                    builder[j] = '1';
                                n >>= 1;
                            }
                            Console.Write(" OTP {0} [{1}]",
                                pageData, builder.ToString());
                            locked = ((pages[2] >> 16) & 8) != 0;
                            if (locked)
                                Console.WriteLine("Заблокировано");
                            else
                                Console.WriteLine();
                            break;

                        default:
                            locked = (((pages[2] >> 16) & (1 << i)) != 0);
                            Console.WriteLine(" Данные ({0}) {1}",
                                pageData,
                                locked ? "Заблокировано" : "");
                            break;
                    }
                }
                Console.WriteLine("-----");
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
            }
        }

        static void DoWriteUltralight(IILReader pReader)
        {
            try
            {
                Console.WriteLine("Введите номер страницы (10-тичное), байты 0 1 2 3 (16-ричные):");
                string s = Console.ReadLine();
                char[] delimiterChars = { ' ', ',', ';', '\t' };
                string[] a = s.Split(delimiterChars, System.StringSplitOptions.RemoveEmptyEntries);
                if (a.Length != 5)
                {
                    Console.WriteLine("Неправильный ввод");
                    return;
                }
                int pageN = Convert.ToInt32(a[0]);
                UInt32[] pages = new UInt32[1];
                pages[0] = 0;
                for (int i = 1; i < a.Length; ++i)
                    pages[0] |= ((UInt32)(Convert.ToInt32(a[i], 16) & 0xff) << (8 * (i - 1)));

                Console.Write("Запись... ");
                int written;
                int startTick = Environment.TickCount;
                pReader.WriteMfUlralight(pageN, pages, pages.Length, out written);
                int span = Environment.TickCount - startTick;
                Console.WriteLine("записана {0} страница за {1} мс", written, span);
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
                // Подключаемся к считывателю
                Console.Write("Подключение к считывателю... ");
                pReader.Connect();
                Console.WriteLine("успешно");
                pReader.GetReaderInfo(out rRI);
                bool canRW = rRI.CanRWCardTypes().Contains(RWCardType.MfUltralight);

                while (true)
                {
                    Console.Write("Поиск карты Mifare Ultralight... ");
                    pReader.Scan(false);
                    CardInfo rCI;
                    pReader.GetCardInfo(out rCI);
                    bool cardFound = (rCI.type == CardType.MifareUltralight);
                    // Если карта Mifare Ultralight найдена,
                    if (cardFound)
                        Console.WriteLine("{0} {1}", 
                            ILR.kCardTypeNames[(int)rCI.type],
                            ILR.CardUIDToStr(rCI.type, rCI.UID));
                    else // Mifare Ultralight не найдена
                        Console.WriteLine("не найдена");
                    Console.WriteLine("-----");
                    Console.WriteLine("Введите номер команды:");
                    Console.WriteLine("1 - Искать снова");
                    if (cardFound && canRW)
                    {
                        Console.WriteLine("2 - Прочитать данные из карты");
                        Console.WriteLine("3 - Записать данные на карту...");
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
                            if (cardFound && canRW)
                                DoReadUltralight(pReader);
                            break;

                        case 3:
                            if (cardFound && canRW)
                                DoWriteUltralight(pReader);
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
