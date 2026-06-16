using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using IL.Readers;

namespace EnumReaders
{
    class Program
    {
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
                pSearch.SetReaderTypes(RDTYPEF.RT_F_ILUSB | RDTYPEF.RT_F_CCID);
                // Ищем считыватели
                Console.Write("Поиск считывателей... ");
                pSearch.Scan();
                // Перечисляем найденные считыватели
                int count = pSearch.GetReaderCount();
                if (count != 0)
                {
                    Console.WriteLine("найдено {0} считывателей:", count);
                    ReaderInfo ri;
                    for (int i = 0; i < count; ++i)
                    {
                        pSearch.GetReaderInfo(i, out ri);
                        Console.Write("{0}. {1}: {2}",
                            1 + i,
                            ri.PortName,
                            ILR.kRdModelNames[(int)ri.Model]);
                        if (ri.Sn != -1)
                            Console.Write(" с/н:{0}", ri.Sn);
                        if (ri.FwVersion != 0)
                            Console.Write(" прошивка:{0}", ILR.VersionToStr(ri.FwVersion));
                        if (ri.FwBuildTime != 0)
                            Console.Write(" сборка {0}", ILR.TimeToDateTime(ri.FwBuildTime));
                        Console.WriteLine();
                    }
                }
                else
                    Console.WriteLine("не найдены");
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
