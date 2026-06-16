using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Runtime.InteropServices;
using IL.Readers;

namespace ConnectToReader
{
    class Program
    {
        public static void ReaderNotify(ReaderMsg msgType, IntPtr msgData, IntPtr userData)
        {
            switch (msgType)
            {
                case ReaderMsg.ConnectionChanged: // Изменилось состояние подключения
                    {
                        try
                        {
                            IILReader pReader = Marshal.GetObjectForIUnknown(userData) as IILReader;
                            ConnectionStatus Status = pReader.GetConnectionStatus();
                            switch (Status)
                            {
                                case ConnectionStatus.Connected:
                                    Console.WriteLine("Считыватель подключён");
                                    break;

                                case ConnectionStatus.Disconnected:
                                    Console.WriteLine("Считыватель отключён");
                                    break;

                                case ConnectionStatus.Connecting:
                                    Console.WriteLine("Идёт подключение к считывателю");
                                    break;
                            }
                        }
                        catch (Exception e)
                        {
                            Console.Write(e.Message);
                        }
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
                // Получаем информацию о считывателе
                pReader.GetReaderInfo(out rRI);
                Console.Write("{0}: {1}",
                    rRI.PortName,
                    ILR.kRdModelNames[(int)rRI.Model]);
                if (rRI.Sn != -1)
                    Console.Write(" с/н:{0}", rRI.Sn);
                if (rRI.FwVersion != 0)
                    Console.Write(" прошивка:{0}", ILR.VersionToStr(rRI.FwVersion));
                if (rRI.FwBuildTime != 0)
                    Console.Write(" сборка {0}", ILR.TimeToDateTime(rRI.FwBuildTime));
                Console.WriteLine();
                // Устанавливаем функцию для получения сообщений об потери/восстановлении связи 
                //	со считывателем
                pReader.SetNotifyCallback(ReaderNotify, Marshal.GetIUnknownForObject(pReader));

                while (true)
                {
                    Console.WriteLine("-----");
                    Console.WriteLine("Введите номер команды:");
                    Console.WriteLine("1 - Подключиться");
                    Console.WriteLine("2 - Отключиться");
                    Console.WriteLine("0 - Выйти из программы");
                    string s = Console.ReadLine();
                    Console.WriteLine();
                    switch (Convert.ToInt32(s))
                    {
                        case 0:
                            return;

                        case 1:
                            pReader.Connect();
                            break;

                        case 2:
                            pReader.Disconnect();
                            break;

                        default:
                            Console.WriteLine("Неправильный ввод");
                            break;
                    }
                }
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
