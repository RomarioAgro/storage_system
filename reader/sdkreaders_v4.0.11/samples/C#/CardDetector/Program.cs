using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Runtime.InteropServices;
using IL.Readers;

namespace CardDetector
{
    class Program
    {
        public static void ReaderNotify(ReaderMsg msgType, IntPtr msgData, IntPtr userData)
        {
            switch (msgType)
            {
                case ReaderMsg.CardFound:   // Карта поднесена
                case ReaderMsg.CardLost:    // Карта удалена
                    {
                        CardInfo rCI = (CardInfo)Marshal.PtrToStructure(msgData, typeof(CardInfo));
                        Console.Write("{{!}} {0} карта {1} {2}", 
                            (ReaderMsg.CardFound == msgType) ? "Найдена" : "Потеряна",
                            ILR.kCardTypeNames[(int)rCI.type], 
                            ILR.CardUIDToStr(rCI.type, rCI.UID));
                        if (rCI.mpType != MfPlusType.Unknown)
                            Console.Write(ILR.kMpTypeNames[(int)rCI.mpType]);
                        if (rCI.SL != MfPlusSL.Unknown)
                            Console.Write(" SL{0}", (int)rCI.SL);
                        Console.WriteLine();
                    }
                    break;
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
                // Устанавливаем функцию для получения уведомлений об поднесении/удалении карты
                pReader.SetNotifyCallback(ReaderNotify, IntPtr.Zero);
                Console.WriteLine("Ожидание поднесения карты...");
                Console.ReadKey();
            }
            catch (Exception e)
            {
                Console.Write(e.Message);
            }
        }
    }
}
