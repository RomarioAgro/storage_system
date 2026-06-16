using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Runtime.InteropServices;
using IL.Readers;

namespace ReaderDetector
{
    class Program
    {
        public static void SearchNotify(SearchMsg msgType, IntPtr msgData, IntPtr userData)
        {
            switch (msgType)
            {
                case SearchMsg.ReaderFound: // Считыватель найден
                case SearchMsg.ReaderLost:  // Считыватель потерян
                    {
                        ReaderInfo rRI = (ReaderInfo)Marshal.PtrToStructure(msgData, typeof(ReaderInfo));
                        Console.Write("{{!}} {0} считыватель ({1}): {2}", 
                            (SearchMsg.ReaderFound == msgType) ? "Найден" : "Потерян",
                            rRI.PortName,
                            ILR.kRdModelNames[(int)rRI.Model]);
                        if (rRI.Sn != -1)
                            Console.Write(" с/н:{0}", rRI.Sn);
                        if (rRI.FwVersion != 0)
                            Console.Write(" прошивка:{0}", ILR.VersionToStr(rRI.FwVersion));
                        if (rRI.FwBuildTime != 0)
                            Console.Write(" сборка {0}", ILR.TimeToDateTime(rRI.FwBuildTime));
                        Console.WriteLine();
                    }
                    break;

                case SearchMsg.ListChanged:   // Список считывателей изменился
                    Console.WriteLine("{{!}} Список считыватель изменился");
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
                // Получает интерфейс поиска считывателей
                IILRSearch pSearch = piILR.GetSearch();
                // Выбираем типы считывателей для поиска
                pSearch.SetReaderTypes(RDTYPEF.RT_F_ILUSB | RDTYPEF.RT_F_TPUSB | RDTYPEF.RT_F_CCID);
                // Устанавливаем функцию для получения сообщений о подключении/отключении считывателей
                pSearch.SetNotifyCallback(SearchNotify, IntPtr.Zero);
                // Включаем авто поиск считывателей
                pSearch.EnableAutoScan();
                Console.WriteLine("Поиск считывателей...");
                Console.ReadKey();
            }
            catch (Exception e)
            {
                Console.Write(e.Message);
            }

            Console.Write("\nНажмите любую клавишу для выхода...");
            Console.ReadKey();
        }
    }
}
