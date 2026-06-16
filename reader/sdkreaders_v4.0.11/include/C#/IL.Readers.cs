using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.InteropServices;
using Microsoft.Win32.SafeHandles;

namespace IL.Readers
{
    #region Основные типы

    // Модель считывателя
    public enum ReaderModel
    {
        UnknownModel,   // Не известно
        Z2RDALL,        // Z-2 (мод. RD_ALL) / Z-2 USB
        Z2USBMF,        // Z-2 (мод. MF) / Z-2 USB MF
        Z2MFI,          // Z-2 (мод. MF-I)
        Z2EHR,          // Z-2 (мод. E HTZ RF) / Z-2 EHR
        Z2Base,         // Z-1 (мод. N Z) / Z-2 Base
        RF1996,         // Z-2 (мод. E HT Hotel) / Z-2 RF-1996
        Matrix3RdAll,   // Matrix-III (мод. RD_All)
        Matrix3Net,     // Matrix-III (мод. MF K Net) / Matrix-III Net
        CPZ2MF,         // CP-Z 2MF
        Matrix5,        // Matrix-V (мод. E S RF) / Matrix-V
        Z2MfCcid,       // Z-2 (мод. MF CCID)
        Matrix6         // Matrix-VI (мод. NFC K Net)
    }

    // Тип порта считывателя
    public enum PortType
    {
        UnknownPort,    // Не известно
        ComPort,        // Имя последовательного порта (например COM3)
        CCID,           // CCID (Smart Cards)
        Server,         // Адрес конвертера в режиме "Сервер" (например 10.0.0.2:1000)
        Client          // Адрес конвертера в режиме "Клиент" (например 123@25000)
    }

    // Тип карты
    public enum CardType
    {
        UnknownCard,        // Не известно
        EmMarine,           // Em-Marine
        HID,                // HID
        ICode,              // iCode
        Cod433,             // Cod433
        Cod433Fix,          // Cod433 Fix
        Came433,            // Радиобрелок CAME
        Dallas,             // Dallas
        Temic,              // Temic (T5557)

        MifareUltralight,       // Mifare Ultralight
        MifareUltralightC,      // Mifare Ultralight C
        MifareMini,             // Mifare Mini
        MifareClassic1K,		// Mifare Classic 1K
        MifareClassic2K,		// Mifare Classic 2K
        MifareClassic4K,		// Mifare Classic 4K
        MifarePlus,             // Mifare Plus
        MifarePlus1K,			// Mifare Plus 1K
        MifarePlus2K,			// Mifare Plus 2K
        MifarePlus4K,			// Mifare Plus 4K
        SmartMXwMf1K,	        // Smart MX with Mifare 1K
        SmartMXwMf4K,	        // Smart MX with Mifare 4K
        MifareDesfire,          // Mifare DESFire
        MifareProX              // Mifare ProX
    }

    // Типы карт, данные которых умеет читать/писать считыватель
    public enum RWCardType
    {
        MfUltralight,   // Mifare Ultralight
        MfClassic,      // Mifare Classic
        MfPlus,         // Mifare Plus
        Temic           // Temic
    }

    // Информация о считывателе
    [StructLayout(LayoutKind.Sequential, Pack = 1, CharSet = CharSet.Unicode)]
    public struct ReaderInfo
    {
        public PortType PortType;           // Тип порта
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)]
        public String PortName;             // Имя порта
        public ReaderModel Model;           // Модель считывателя
        public Int32 Sn;                    // Серийный номер считывателя
        public UInt32 FwVersion;            // Версия прошивки
        public Int64 FwBuildTime;           // Дата и время сборки прошивки
        public Int32 Error;                 // Код ошибки, если не удалось получить инфо считывателя

        /// <summary>
        /// Возвращает типы карт, UID которых умеет читать считыватель
        /// </summary>
        /// <returns></returns>
        public HashSet<CardType> GetIdCardTypes()
        {
            HashSet<CardType> res = new HashSet<CardType>();
            switch (Model)
            {
                case ReaderModel.Z2RDALL:
                    res.Add(CardType.EmMarine);
                    res.Add(CardType.HID);
                    res.Add(CardType.MifareUltralight);
                    res.Add(CardType.MifareUltralightC);
                    res.Add(CardType.MifareMini);
                    res.Add(CardType.MifareClassic1K);
                    res.Add(CardType.MifareClassic2K);
                    res.Add(CardType.MifareClassic4K);
                    res.Add(CardType.SmartMXwMf1K);
                    res.Add(CardType.SmartMXwMf4K);
                    res.Add(CardType.MifareDesfire);
                    res.Add(CardType.MifareProX);
                    if (FwVersion >= 106)
                        res.Add(CardType.Temic);
                    break;

                case ReaderModel.Z2USBMF:
                case ReaderModel.Z2MFI:
                case ReaderModel.Matrix3Net:
                case ReaderModel.CPZ2MF:
                case ReaderModel.Z2MfCcid:
                case ReaderModel.Matrix6:
                    res.Add(CardType.MifareUltralight);
                    res.Add(CardType.MifareUltralightC);
                    res.Add(CardType.MifareMini);
                    res.Add(CardType.MifareClassic1K);
                    res.Add(CardType.MifareClassic2K);
                    res.Add(CardType.MifareClassic4K);
                    res.Add(CardType.SmartMXwMf1K);
                    res.Add(CardType.SmartMXwMf4K);
                    res.Add(CardType.MifarePlus);
                    res.Add(CardType.MifarePlus1K);
                    res.Add(CardType.MifarePlus2K);
                    res.Add(CardType.MifarePlus4K);
                    res.Add(CardType.MifareDesfire);
                    res.Add(CardType.MifareProX);
                    break;

                case ReaderModel.Z2EHR:
                    res.Add(CardType.EmMarine);
                    res.Add(CardType.HID);
                    res.Add(CardType.MifareUltralight);
                    res.Add(CardType.MifareUltralightC);
                    res.Add(CardType.MifareMini);
                    res.Add(CardType.MifareClassic1K);
                    res.Add(CardType.MifareClassic2K);
                    res.Add(CardType.MifareClassic4K);
                    res.Add(CardType.SmartMXwMf1K);
                    res.Add(CardType.SmartMXwMf4K);
                    res.Add(CardType.MifareDesfire);
                    res.Add(CardType.MifareProX);
                    res.Add(CardType.Temic);
                    res.Add(CardType.Dallas);
                    res.Add(CardType.Cod433);
                    res.Add(CardType.Cod433Fix);
                    break;

                case ReaderModel.RF1996:
                    res.Add(CardType.EmMarine);
                    res.Add(CardType.Temic);
                    break;

                case ReaderModel.Matrix3RdAll:
                    res.Add(CardType.EmMarine);
                    res.Add(CardType.HID);
                    res.Add(CardType.MifareUltralight);
                    res.Add(CardType.MifareUltralightC);
                    res.Add(CardType.MifareMini);
                    res.Add(CardType.MifareClassic1K);
                    res.Add(CardType.MifareClassic2K);
                    res.Add(CardType.MifareClassic4K);
                    res.Add(CardType.SmartMXwMf1K);
                    res.Add(CardType.SmartMXwMf4K);
                    res.Add(CardType.MifareDesfire);
                    res.Add(CardType.MifareProX);
                    break;

                case ReaderModel.Matrix5:
                    res.Add(CardType.EmMarine);
                    res.Add(CardType.Came433);
                    res.Add(CardType.Cod433);
                    res.Add(CardType.Cod433Fix);
                    break;
            }
            return res;
        }

        /// <summary>
        /// Возвращает типы карт, данные которых умеет читать/писать считыватель
        /// </summary>
        /// <returns>Множество типов карт</returns>
        public HashSet<RWCardType> CanRWCardTypes()
        {
            HashSet<RWCardType> res = new HashSet<RWCardType>();
            switch (Model)
            {
                case ReaderModel.Z2RDALL:
                    res.Add(RWCardType.MfUltralight);
                    if (FwVersion >= 106)
                        res.Add(RWCardType.Temic);
                    break;

                case ReaderModel.Matrix3RdAll:
                    res.Add(RWCardType.MfUltralight);
                    break;

                case ReaderModel.Z2EHR:
                    res.Add(RWCardType.Temic);
                    break;

                case ReaderModel.Z2USBMF:
                case ReaderModel.Matrix3Net:
                case ReaderModel.CPZ2MF:
                case ReaderModel.Z2MfCcid:
                    res.Add(RWCardType.MfUltralight);
                    res.Add(RWCardType.MfClassic);
                    break;

                case ReaderModel.Z2MFI:
                case ReaderModel.Matrix6:
                    res.Add(RWCardType.MfUltralight);
                    res.Add(RWCardType.MfClassic);
                    res.Add(RWCardType.MfPlus);
                    break;
            }
            return res;
        }
    }

    // Уровень лога
    public enum LogLevel
    {
        Disabled,       // Лог выключен
        Assert,         // Неожиданные ошибки, которых быть не должно
        Error,          // Ошибки
        Warning,        // Предупреждения. Показывает возможные проблемы, которые не являются ошибками
        Info,           // Уведомления. Показывает полезную информацию, в основном успехи
        Debug,          // Отладочные сообщения. Показвает шаги программы, получаемые и отправляемые данные
        Verbose         // Подробные отладочные сообщения. Показывает каждую мелочь
    }
    #endregion

    #region Поиск считывателей
    // Callback функция для фильтрации портов
    // Возвращает True когда нужно исключить порт из списка найденных портов
    [UnmanagedFunctionPointer(CallingConvention.StdCall)]
    public delegate Int32 FilterPortProc(
        PortType portType,
        [MarshalAs(UnmanagedType.LPWStr)] string portName,
        IntPtr UserData);

    // Сообщение поиска считывателей (IILRSearch)
    public enum SearchMsg
    {
        AsyncCmdFinish, // Завершилась асинхронная команда, созданная IILRSearchAsync
        ReaderFound,    // Считыватель найден, параметр ReaderInfo
        ReaderLost,     // Считыватель потерян, параметр ReaderInfo
        ListChanged     // Список считывателей изменён
    }
    // Тип функции для получения уведомлений от IILRSearch
    [UnmanagedFunctionPointer(CallingConvention.StdCall)]
    public delegate void SearchNotifyProc(
        SearchMsg msgType, IntPtr msgData, IntPtr userData);

    // Флаги типов считывателей
    [Flags]
    public enum RDTYPEF : UInt32
    {
        RT_F_ILUSB = 0x00000001,    // USB считыватели Ironlogic
        RT_F_TPUSB = 0x00000002,    // USB считыватели сторонних производителей
        RT_F_CCID = 0x00000004,     // Считыватели SmartCards
        RT_F_SERVER = 0x00000008,   // IP конвертеры в режиме "Сервер" (поиск по UDP)
        RT_F_CLIENT = 0x00000010    // IP конвертеры в режиме "Клиент" (прослушка TCP)
    }
    #endregion

    #region Подключение к считывателю
    // Сообщение считывателя (IILReader)
    public enum ReaderMsg
    {
        AsyncCmdFinish,     // Завершилась асинхронная команда, созданная IILReaderAsync
        ConnectionChanged,  // Изменилось состояние подключения к считывателю
        CardFound,          // Карта найдена, параметр CardInfo
        CardLost            // Карта потеряна, параметр CardInfo
    }
    // Тип функции для получения уведомлений от IILReader
    [UnmanagedFunctionPointer(CallingConvention.StdCall)]
    public delegate void ReaderNotifyProc(
        ReaderMsg msgType, IntPtr msgData, IntPtr userData);

    // Состояние подключения
    public enum ConnectionStatus
    {
        Disconnected = 0,   // Отключен
        Connecting,         // Идет подключение...
        Connected           // Подключен
    }

    // ID карты
    [StructLayout(LayoutKind.Sequential, Pack = 1)]
    public struct CardUID
    {
        public sbyte Length;    // Длина номера в байтах

        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 15)]
        public byte[] bytes;   // Байты номера

        public bool IsEmpty()
        {
            return Length == 0;
        }
        public void Clear()
        {
            Length = 0;
            if (bytes != null)
                Array.Clear(bytes, 0, bytes.Length);
        }
        public bool Equals(CardUID uid)
        {
            if (Length != uid.Length)
                return false;
            for (int i = 0; i < Length; i++)
                if (!bytes[i].Equals(uid.bytes[i]))
                    return false;
            return true;
        }
        public void SetEmMarine(Byte series, UInt16 number, UInt16 facility)
        {
            if (null == bytes)
                bytes = new byte[15];
            bytes[0] = (Byte)number;
            bytes[1] = (Byte)(number >> 8);
            bytes[2] = series;
            bytes[3] = (Byte)facility;
            bytes[4] = (Byte)(facility >> 8);
            Length = 5;
        }
        public void SetHID(int nWiegand, UInt16 number, uint facility)
        {
            if (null == bytes)
                bytes = new byte[15];
            int nFSize = (nWiegand - 2 - 16);
            int nFCount = nFSize / 8;
            if ((nFSize % 8) != 0)
                ++nFCount;
            bytes[0] = (Byte)number;
            bytes[1] = (Byte)(number >> 8);
            for (int i = 0; i < nFCount; ++i)
            {
                bytes[2 + i] = (Byte)facility;
                facility >>= 8;
            }
            Length = (sbyte)(2 + nFCount);
        }
    }

    // Уровнь безопасности Mifare Plus
    public enum MfPlusSL : SByte
    {
        Unknown = -1,   // Не известно
        SL0,            // Уровень 0 (не инициализирована)
        SL1,            // Уровень 1 (эмуляция Mifare Classic)
        SL2,            // Уровень 2
        SL3             // Уровень 3
    }

    // Тип Mifare Plus
    public enum MfPlusType : Byte
    {
        Unknown,        // Не известно
        S,              // Тип Mifare Plus S
        X,              // Тип Mifare Plus X
        SE,             // MIFARE Plus SE
        EV1,            // MIFARE Plus EV1
        EV2             // MIFARE Plus EV2
    }

    // Информация о карте
    [StructLayout(LayoutKind.Sequential, Pack = 1)]
    public struct CardInfo
    {
        public CardType type;       // Тип карты
        public CardUID UID;         // Номер карты
        public UInt32 memSize;      // Размер памяти карты (в байтах)
        public MfPlusSL SL;         // Уровнь безопасности Mifare Plus
        public MfPlusType mpType;   // Тип Mifare Plus
        public CardType type2;      // Тип карты
        public CardUID UID2;        // Номер карты

        /// <summary>
        /// Возвращает True если карта является Mifare Classic
        /// </summary>
        /// <returns></returns>
        public bool IsMfClassic()
        {
            return (type >= CardType.MifareMini) && (type <= CardType.MifareClassic4K);
        }
        /// <summary>
        /// Возвращает True если карта является Mifare Plus
        /// </summary>
        /// <returns></returns>
        public bool IsMfPlus()
        {
            return (type >= CardType.MifarePlus) && (type <= CardType.SmartMXwMf4K);
        }
        /// <summary>
        /// Возвращает True если карта является Mifare Classic или Mifare Plus SL1
        /// </summary>
        /// <returns></returns>
        public bool IsMfClassicMode()
        {
            return IsMfClassic() || (IsMfPlus() && (SL == MfPlusSL.SL1));
        }
        /// <summary>
        /// Возвращает True если карта является Mifare Plus SL3
        /// </summary>
        /// <returns></returns>
        public bool IsMfPlusSL3Mode()
        {
            return IsMfPlus() && (SL == MfPlusSL.SL3);
        }
        /// <summary>
        /// Возвращает количество блоков карты Mifare Classic/Plus
        /// </summary>
        /// <returns></returns>
        public int GetNumberOfMfBlocks()
        {
            return (int)memSize / 16;
        }
    }

    // Ключ Mifare Plus
    [StructLayout(LayoutKind.Sequential, Pack = 1, Size = 16)]
    public struct MfPlusKey
    {
        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 16)]
        public Byte[] a;

        // Устанавливает значение ключа по умолчанию
        public void SetDefault()
        {
            if (null == a)
                a = new byte[16];
            for (int i = 0; i < a.Length; i++)
                a[i] = 0xff;
        }
        public static MfPlusKey Default()
        {
            MfPlusKey r = new MfPlusKey();
            r.SetDefault();
            return r;
        }
    }

    // Данные блока Mifare Classic/Plus
    [StructLayout(LayoutKind.Sequential, Pack = 1)]
    public struct MfBlockData
    {
        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 16)]
        public Byte[] a;
    }

    // Флаги типов карт (для авто приостановки сканирования при обнаружении карты)
    [Flags]
    public enum RWCTF : UInt32
    {
        RWCT_F_MFULTRALIGHT = 0x00000001, // Mifare Ultralight
        RWCT_F_MFCLASSIC = 0x00000002, // Mifare Classic
        RWCT_F_MFPPLUS = 0x00000004, // Mifare Plus
        RWCT_F_TEMIC = 0x00000008  // Temic
    }
    #endregion

    #region Интерфейсы
    [Guid("6EAE522E-11FB-42AF-972A-726938CB68DB")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IILRSearch
    {
        /// <summary>
        /// Устанавливает функцию обратного вызова для уведомлений
        /// </summary>
        /// <param name="callback">Функция обратного вызова</param>
        /// <param name="userData">Ссылка на данные пользователя, которая передаётся в функцию
        /// обратного вызова</param>
        /// <returns>Ничего не возвращает</returns>
        void SetNotifyCallback(
            [MarshalAs(UnmanagedType.FunctionPtr)] SearchNotifyProc callback, 
            IntPtr userData);
        /// <summary>
        /// Вкл/выкл очередь сообщений для синхронизации событий функции обратного вызова для 
        /// уведомлений, установленную через SetNotifyCallback
        /// </summary>
        /// <param name="enable">True включает очередь, иначе - выключает</param>
        /// <returns>Ничего не возвращает</returns>
        void EnableMsgQueue(
            [MarshalAs(UnmanagedType.Bool)] bool enable = true);
        [return: MarshalAs(UnmanagedType.Bool)]
        /// <summary>
        /// Извлекает следующее сообщение из очереди
        /// </summary>
        /// <param name="msgType">Тип уведомления</param>
        /// <param name="msgData">Данные уведомления</param>
        /// <returns>True сообщение найдено, иначе - нет сообщений</returns>
        bool GetMessage(out SearchMsg msgType, out IntPtr msgData);
        /// <summary>
        /// Устанавливает типы считывателей, которые нужно искать
        /// </summary>
        /// <param name="types">Типы считывателей</param>
        /// <returns>Ничего не возвращает</returns>
        void SetReaderTypes(RDTYPEF types);
        /// <summary>
        /// Возвращает типы считывателей, которые нужно искать
        /// </summary>
        /// <returns>Типы считывателей</returns>
        RDTYPEF GetReaderTypes();
        /// <summary>
        /// Устанавливает период опроса IP конвертеров по UDP в миллисекундах
        /// </summary>
        /// <param name="ms">Количество миллисекунд</param>
        /// <returns>Ничего не возвращает</returns>
        void SetUdpScanPeriod(uint ms);
        /// <summary>
        /// Возвращает период опроса IP конвертеров по UDP в миллисекундах
        /// </summary>
        /// <returns>Период опроса IP конвертеров по UDP</returns>
        uint GetUdpScanPeriod();
        /// <summary>
        /// Устанавливает тайм-аут запроса по UDP
        /// </summary>
        /// <param name="ms">Количество миллисекунд</param>
        /// <returns>Ничего не возвращает</returns>
        void SetUdpRequestTimeout(uint ms);
        /// <summary>
        /// Возвращает тайм-аут запроса по UDP в миллисекундах
        /// </summary>
        /// <returns>Тайм-аут запроса по UDP</returns>
        uint GetUdpRequestTimeout();
        /// <summary>
        /// Устанавливает количество попыток запроса по UDP (поиск IP конвертеров)
        /// </summary>
        /// <param name="attempts">Количество попыток запроса по UDP</param>
        /// <returns>Ничего не возвращает</returns>
        void SetUdpRequestAttempts(int attempts);
        /// <summary>
        /// Возвращает количество попыток запроса по UDP
        /// </summary>
        /// <returns>Количество попыток запроса по UDP</returns>
        int GetUdpRequestAttempts();
        /// <summary>
        /// Устанавливает IP адреса конвертеров для опроса по UDP, которые 
        /// не находятся автоматически
        /// </summary>
        /// <param name="addresses">Список адресов, разделённых символом ';'</param>
        /// <returns>Ничего не возвращает</returns>
        void SetUdpCvtAddresses(string addresses);
        /// <summary>
        /// Возвращает IP адреса конвертеров для опроса по UDP
        /// </summary>
        /// <returns>Список адресов, разделённых символом ';'</returns>
        string GetUdpCvtAddresses();
        /// <summary>
        /// Устанавливает список TCP-портов для прослушки конвертеров к режиме "Клиент"
        /// </summary>
        /// <param name="ports">Список номеров TCP-портов</param>
        /// <param name="count">Количество TCP-портов</param>
        /// <returns>Ничего не возвращает</returns>
        void SetListenTcpPorts([In, MarshalAs(UnmanagedType.LPArray, SizeParamIndex = 1)] UInt16 ports, int count);
        /// <summary>
        /// Возвращает список TCP-портов для прослушки конвертеров к режиме "Клиент"
        /// </summary>
        /// <param name="ports">Буфер для списка номеров TCP-портов</param>
        /// <param name="count">Размер буфера = количество портов</param>
        /// <returns>Полученное количество TCP-портов</returns>
        int GetListenTcpPorts([Out, MarshalAs(UnmanagedType.LPArray, SizeParamIndex = 1)] UInt16 ports, int count);
        /// <summary>
        /// Устанавливает период между попытками открыть TCP порт для прослушки Клиентов
        /// </summary>
        /// <param name="ms">Количество миллисекунд</param>
        /// <returns>Ничего не возвращает</returns>
        void SetOpenListenerPeriod(UInt32 ms);
        /// <summary>
        /// Ищет считыватели
        /// </summary>
        /// <param name="reset">True очистить список найденных перед поиском</param>
        /// <returns>Ничего не возвращает</returns>
        void Scan([MarshalAs(UnmanagedType.Bool)] bool reset = false);
        /// <summary>
        /// Возвращает количество найденных считывателей
        /// </summary>
        /// <returns></returns>
        int GetReaderCount();
        /// <summary>
        /// Возвращает инфо о найденном считывателе
        /// </summary>
        /// <param name="idx">Позиция в списке найденных считывателей</param>
        /// <param name="info">Информация о найденном считывателе</param>
        /// <returns>Ничего не возвращает</returns>
        void GetReaderInfo(int idx, out ReaderInfo info);
        /// <summary>
        /// Вкл/выкл режим авто поиска считывателей
        /// </summary>
        /// <param name="enable">True включает поиск в реальном времени, иначе - выключает</param>
        /// <param name="wait">True ждать завершение операции</param>
        /// <returns>Ничего не возвращает</returns>
        void EnableAutoScan([MarshalAs(UnmanagedType.Bool)] bool enable = true,
            [MarshalAs(UnmanagedType.Bool)] bool wait = true);
        [return: MarshalAs(UnmanagedType.Bool)]
        /// <summary>
        /// Возвращает True если авто поиск включен, иначе - выключен
        /// </summary>
        /// <returns>True если авто поиск включен</returns>
        bool GetAutoScanEnabled();
        /// <summary>
        /// Открывает порт и возвращает дескриптор порта
        /// </summary>
        /// <param name="Type">Тип порта</param>
        /// <param name="Name">Имя порта</param>
        /// <param name="Info">Информация о считывателе (если найден)</param>
        /// <returns>Дескриптор порта</returns>
        IntPtr OpenPort(PortType Type, string Name, out ReaderInfo Info);
        /// <summary>
        /// Закрывает порт
        /// </summary>
        /// <param name="Type">Тип порта</param>
        /// <param name="Name">Имя порта</param>
        /// <param name="hPort">Дескриптор порта</param>
        void ClosePort(PortType Type, string Name, IntPtr hPort);
    }

    [Guid("C435D1AB-A1AC-455D-A1D9-0C53F5F21417")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IILReader
    {
        /// <summary>
        /// Устанавливает функцию обратного вызова для уведомлений
        /// </summary>
        /// <param name="callback">Функция обратного вызова</param>
        /// <param name="userData">Ссылка на данные пользователя, которая передаётся в функцию
        /// обратного вызова</param>
        /// <returns>Ничего не возвращает</returns>
        void SetNotifyCallback(
            [MarshalAs(UnmanagedType.FunctionPtr)] ReaderNotifyProc callback,
            IntPtr userData);
        /// <summary>
        /// Вкл/выкл очередь сообщений (для синхронизации уведомлений)
        /// </summary>
        /// <param name="enable">True включает очередь, иначе - выключает</param>
        /// <returns>Ничего не возвращает</returns>
        void EnableMsgQueue(
            [MarshalAs(UnmanagedType.Bool)] bool enable = true);
        [return: MarshalAs(UnmanagedType.Bool)]
        /// <summary>
        /// Извлекает следующее сообщение из очереди
        /// </summary>
        /// <param name="msgType">Тип сообщения считывателя</param>
        /// <param name="msgData">Ссылка на данные сообщения</param>
        /// <returns>True сообщение извлечено, иначе - нет сообщений</returns>
        bool GetMessage(out ReaderMsg msgType, out IntPtr msgData);
        /// <summary>
        /// Устанавливает модель для подключения
        /// </summary>
        /// <param name="model">Модель считывателя. Если =ReaderModel.UnknownModel, то 
        /// авто определение</param>
        /// <returns>Ничего не возвращает</returns>
        void SetModelToConnect(ReaderModel model);
        /// <summary>
        /// Возвращает модель для подключения
        /// </summary>
        /// <returns>Модель считывателя для подключения</returns>
        ReaderModel GetModelToConnect();
        /// <summary>
        /// Подключается к считывателю
        /// </summary>
        /// <param name="reconnect">True, переподключиться</param>
        /// <returns>Ничего не возвращает</returns>
        void Connect([MarshalAs(UnmanagedType.Bool)] bool reconnect = false);
        /// <summary>
        /// Отключается от считывателя
        /// </summary>
        /// <returns>Ничего не возвращает</returns>
        void Disconnect();
        /// <summary>
        /// Возвращает состояние подключения к считывателю
        /// </summary>
        /// <returns>Состояние подключения к считывателю</returns>
        ConnectionStatus GetConnectionStatus();
        /// <summary>
        /// Возвращает информацию о считывателе
        /// </summary>
        /// <param name="info">Информация о считывателе</param>
        /// <returns>Ничего не возвращает</returns>
        void GetReaderInfo(out ReaderInfo info);
        /// <summary>
        /// Ищет карты
        /// </summary>
        /// <param name="reset">True, сбросить старые результаты поиска</param>
        /// <param name="powerOff">True, выключает RF поле после сканирования</param>
        /// <returns>Ничего не возвращает</returns>
        void Scan([MarshalAs(UnmanagedType.Bool)] bool reset = false,
            [MarshalAs(UnmanagedType.Bool)] bool powerOff = true);
        /// <summary>
        /// Возвращает информацию о карте в поле считывателя
        /// </summary>
        /// <param name="info">Информация о карте. Если info.UID.IsEmpty =True, то нет карты</param>
        /// <returns>Ничего не возвращает</returns>
        void GetCardInfo(out CardInfo info);
        /// <summary>
        /// Вкл/выкл автоматическое сканирование карт
        /// </summary>
        /// <param name="enable">True включить авто сканирование, иначе - выключить</param>
        /// <param name="wait">True ждать завершение команды</param>
        /// <returns></returns>
        void EnableAutoScan(
            [MarshalAs(UnmanagedType.Bool)] bool enable = true,
            [MarshalAs(UnmanagedType.Bool)] bool wait = true);
        [return: MarshalAs(UnmanagedType.Bool)]
        /// <summary>
        /// Возвращает True если авто сканирование включено, иначе - выключено
        /// </summary>
        /// <returns>True если авто сканирование включено</returns>
        bool GetAutoScanEnabled();

        /// <summary>
        /// Устанавливает типы карт, при обнаружении которых нужно автоматически приостанавливать 
        /// сканирование. Чтобы возобновить сканирование карт нужно вызвать EnableAutoScan(true)
        /// </summary>
        /// <param name="types">Биты типов карт</param>
        /// <returns>Ничего не возвращает</returns>
        void SetHoldCardTypes(RWCTF types);
        /// <summary>
        /// Возвращает типы карт, при обнаружении которых автоматически приостанавливается 
        /// сканирование
        /// </summary>
        /// <returns>Биты типов карт</returns>
        RWCTF GetHoldCardTypes();

        #region Карта Mifare Ultralight
        /// <summary>
        /// Читает данные карты Mifare Ultralight
        /// </summary>
        /// <param name="pageIdx">Номер первой читаемой страницы (0..15)</param>
        /// <param name="buf">Буфер для прочитанных страниц</param>
        /// <param name="pageCount">Количиство страниц, которые нужно прочитать</param>
        /// <param name="read">Количество прочитанных страниц</param>
        /// <returns>Ничего не возвращает</returns>
        void ReadMfUlralight(int pageIdx, 
            [Out, MarshalAs(UnmanagedType.LPArray, SizeParamIndex = 2)] UInt32[] buf, 
            int pageCount, out int read);
        /// <summary>
        /// Пишет данные карты Mifare Ultralight
        /// </summary>
        /// <param name="pageIdx">Номер первой записываемой страницы (0..15)</param>
        /// <param name="data">Данные страниц</param>
        /// <param name="pageCount">Количиство страниц, которые нужно записать</param>
        /// <param name="written">Количество записанных страниц</param>
        /// <returns>Ничего не возвращает</returns>
        void WriteMfUlralight(int pageIdx,
            [In, MarshalAs(UnmanagedType.LPArray, SizeParamIndex = 2)] UInt32[] data, 
            int pageCount, out int written);
        #endregion

        #region Карта Карта Mifare Classic/Plus
        /// <summary>
        /// Загружает ключ для авторизации сектора Mifare Classic / Plus SL1
        /// </summary>
        /// <param name="key">Ключ аутентификации Mifare Classic</param>
        /// <returns>Ничего не возвращает</returns>
        void LoadMfAuthKey(Int64 key);
        /// <summary>
        /// Загружает ключ для авторизации сектора Mifare Plus SL3
        /// </summary>
        /// <param name="key">Ключ аутентификации Mifare Plus</param>
        /// <returns>Ничего не возвращает</returns>
        void LoadMfPlusAuthKey(ref MfPlusKey key);
        [return: MarshalAs(UnmanagedType.Bool)]
        /// <summary>
        /// Авторизует сектор карты Mifare Classic / Plus
        /// </summary>
        /// <param name="address">Номер блока (0..255) или адрес Mifare Plus</param>
        /// <param name="keyB">True, авторизовать по ключу Б, иначе - по ключу А</param>
        /// <returns>True сектор успешно авторизован</returns>
        bool AuthMfCard(uint address, [MarshalAs(UnmanagedType.Bool)] bool keyB);
        /// <summary>
        /// Авторизует сектор карты Mifare Classic / Plus по ключам в памяти считывателя
        /// </summary>
        /// <param name="address">Номер блока (0..255) или адрес Mifare Plus</param>
        /// <param name="keyB">True, авторизовать по ключу Б, иначе - по ключу А</param>
        /// <param name="rdKeys">Биты (0..15) ключей в памяти считывателя</param>
        /// <returns>Номер найденного ключа или -1 если ключ не найден</returns>
        int AuthMfCardByRdKeys(uint address, [MarshalAs(UnmanagedType.Bool)] bool keyB,
            UInt32 rdKeys);
        /// <summary>
        /// Читает данные карты Mifare Classic или Mifare Plus SL1
        /// </summary>
        /// <param name="blockIdx">Номер первого читаемого блока (0..255)</param>
        /// <param name="buf">Буфер для прочитанных блоков</param>
        /// <param name="blockCount">Количество блоков, которые нужно прочитать</param>
        /// <param name="read">Количество прочитанных блоков</param>
        /// <returns>Ничего не возвращает</returns>
        void ReadMfClassic(int blockIdx, 
            [Out, MarshalAs(UnmanagedType.LPArray, SizeParamIndex = 2)] MfBlockData[] buf, 
            int blockCount, out int read);
        /// <summary>
        /// Пишет данные карты Mifare Classic или Mifare Plus SL1
        /// </summary>
        /// <param name="blockIdx">Номер первого записываемого блока (0..255)</param>
        /// <param name="data">Данные записываемых блоков</param>
        /// <param name="blockCount">Количество блоков, которые нужно записать</param>
        /// <param name="written">Количество записанных блоков</param>
        /// <returns>Ничего не возвращает</returns>
        void WriteMfClassic(int blockIdx, 
            [In, MarshalAs(UnmanagedType.LPArray, SizeParamIndex = 2)] MfBlockData[] data, 
            int blockCount, out int written);
        /// <summary>
        /// Читает данные карты Mifare Plus SL3
        /// </summary>
        /// <param name="address">Номер первого читаемого блока (0..255)</param>
        /// <param name="buf">Буфер для прочитанных блоков</param>
        /// <param name="blockCount">Количество блоков, которые нужно прочитать</param>
        /// <param name="openText">True, открытая передача, иначе - зашифрованная</param>
        /// <param name="read">Количество прочитанных блоков</param>
        /// <returns>Ничего не возвращает</returns>
        void ReadMfPlus(uint address,
            [Out, MarshalAs(UnmanagedType.LPArray, SizeParamIndex = 2)] MfBlockData[] buf, 
            int blockCount,
            [MarshalAs(UnmanagedType.Bool)] bool openText /*= true*/, out int read);
        /// <summary>
        /// Пишет данные карты Mifare Plus SL3
        /// </summary>
        /// <param name="address">Номер первого записываемого блока (0..255) или 
        /// адрес Mifare Plus</param>
        /// <param name="data">Данные записываемых блоков</param>
        /// <param name="blockCount">Количество блоков, которые нужно записать</param>
        /// <param name="openText">True, открытая передача, иначе - зашифрованная</param>
        /// <param name="written">Количество записанных блоков</param>
        /// <returns>Ничего не возвращает</returns>
        void WriteMfPlus(uint address,
            [In, MarshalAs(UnmanagedType.LPArray, SizeParamIndex = 2)] MfBlockData[] data, 
            int blockCount,
            [MarshalAs(UnmanagedType.Bool)] bool openText /*= true*/, out int written);
        /// <summary>
        /// Увеличивает содержимое блока-значения карты Mifare и сохраняет результат во временном 
        /// регистре данных
        /// </summary>
        /// <param name="blockIdx">Номер блока (0..255)</param>
        /// <param name="value">Величина инкремента</param>
        /// <returns>Ничего не возвращает</returns>
        void MfIncrement(int blockIdx, uint value);
        /// <summary>
        /// Уменьшает содержимое блока-значения карты Mifare и сохраняет результат во временном 
        /// регистре данных
        /// </summary>
        /// <param name="blockIdx">Номер блока (0..255)</param>
        /// <param name="value">Величина декремента</param>
        /// <returns>Ничего не возвращает</returns>
        void MfDecrement(int blockIdx, uint value);
        /// <summary>
        /// Записывает содержимое во временном регистре данных в блок-значение
        /// </summary>
        /// <param name="blockIdx">Номер блока (0..255)</param>
        /// <returns>Ничего не возвращает</returns>
        void MfTransfer(int blockIdx);
        /// <summary>
        /// Перемещает содержимое блока в регист данных Mifare
        /// </summary>
        /// <param name="blockIdx">Номер блока (0..255)</param>
        /// <returns>Ничего не возвращает</returns>
        void MfRestore(int blockIdx);
        /// <summary>
        /// Выключает RF поле считывателя
        /// </summary>
        /// <returns>Ничего не возвращает</returns>
        void MfPowerOff();
        /// <summary>
        /// R+A+S(Request+Anticollision+Select)
        /// </summary>
        /// <param name="wakeUp">True, разбудить карту</param>
        /// <param name="SAK">Код SAK</param>
        /// <param name="ATQ">Код ATQ</param>
        /// <param name="uID">Номер карты</param>
        /// <returns>Ничего не возвращает</returns>
        [return: MarshalAs(UnmanagedType.Bool)]
        bool MfRAS([MarshalAs(UnmanagedType.Bool)] bool wakeUp, 
            out Byte SAK, out Int16 ATQ, out CardUID uID);
        /// <summary>
        /// R+R(Request+Reselect(по известному номеру))
        /// </summary>
        /// <param name="wakeUp">True, разбудить карту</param>
        /// <param name="uID">Номер карты</param>
        /// <returns>Возвращает true если карта найдена</returns>
        [return: MarshalAs(UnmanagedType.Bool)]
        bool MfRR([MarshalAs(UnmanagedType.Bool)] bool wakeUp, [In] CardUID uID);
        /// <summary>
        /// Halt
        /// </summary>
        /// <returns>Ничего не возвращает</returns>
        void MfHalt();
        /// <summary>
        /// Переходит на ISO 14443-4
        /// </summary>
        /// <param name="atsBuf">Буфер для данных ATS</param>
        /// <param name="bufSize">Размер буфера. Обычно нужно 12 байт</param>
        /// <param name="requiredSize">Требуемый размер</param>
        /// <returns>Ничего не возвращает</returns>
        void MfRATS([Out, MarshalAs(UnmanagedType.LPArray, SizeParamIndex = 1)] Byte[] atsBuf, 
            uint bufSize, out uint requiredSize);
        /// <summary>
        /// Записывает ключи AES и всех блоков
        /// </summary>
        /// <param name="address">Адрес ключа</param>
        /// <param name="rey">Значение ключа</param>
        /// <returns>Ничего не возвращает</returns>
        void MfWritePerso(uint address, ref MfPlusKey rey);
        /// <summary>
        /// Переключает Mifare Plus в SL1 или SL3(если SL1 нет)
        /// </summary>
        /// <returns>Ничего не возвращает</returns>
        void MfCommitPerso();
        /// <summary>
        /// Записывает ключи аутентификации Mifare Classic в память считывателя
        /// </summary>
        /// <param name="idx">Номер ячейки в памяти считывателя, в которую записывается первый 
        /// ключ</param>
        /// <param name="keyB">True, ключ Б, иначе - ключ А</param>
        /// <param name="keys">Список записываемых ключей</param>
        /// <param name="nCount">Количество ключей, которые нужно записать</param>
        /// <param name="written">Количество записанных ключей</param>
        /// <returns>Ничего не возвращает</returns>
        void WriteMfAuthKeyToReader(int idx, 
            [MarshalAs(UnmanagedType.Bool)] bool keyB,
            [In, MarshalAs(UnmanagedType.LPArray, SizeParamIndex = 3)] Int64[] keys, 
            int nCount, out int written);
        /// <summary>
        /// Записывает ключи аутентификации Mifare Plus в память считывателя
        /// </summary>
        /// <param name="idx">Номер ячейки в памяти считывателя, в которую записывается первый 
        /// ключ</param>
        /// <param name="keyB">True, ключ Б, иначе - ключ А</param>
        /// <param name="keys">Список записываемых ключей</param>
        /// <param name="nCount">Количество ключей, которые нужно записать</param>
        /// <param name="written">Количество записанных ключей</param>
        /// <returns>Ничего не возвращает</returns>
        void WriteMfPlusAuthKeyToReader(int idx, 
            [MarshalAs(UnmanagedType.Bool)] bool keyB,
            [In, MarshalAs(UnmanagedType.LPArray, SizeParamIndex = 3)] MfPlusKey[] keys, 
            int nCount, out int written);
        #endregion

        #region Карта Temic
        /// <summary>
        /// Загружает пароль Temic в память DLL. Пароль используется при автоматическом 
        /// сканировании карт Temic, и используется методами ReadTemic, WriteTemic, Begin_ReadTemic,
        /// Begin_WriteTemic
        /// </summary>
        /// <param name="password">Пароль Temic. Если =-1, то нет пароля</param>
        /// <returns>Ничего не возвращает</returns>
        void LoadTemicPassword(Int64 password);
        /// <summary>
        /// Ищет карту Temic в поле считывателя
        /// </summary>
        /// <param name="scanParam">Параметры сканирования Temic. =-1 авто определение</param>
        /// <returns>Ничего не возвращает</returns>
        void ScanTemic(int scanParam = -1);
        /// <summary>
        /// Вкл/выкл автоматическое сканирование карт Temic (для Z-2 Rd-All и Z-2 EHR)
        /// </summary>
        /// <param name="enable">True, включает сканирование Temic</param>
        /// <returns>Ничего не возвращает</returns>
        void EnableAutoScanTemic(
            [MarshalAs(UnmanagedType.Bool)] bool enable = true);
        [return: MarshalAs(UnmanagedType.Bool)]
        /// <summary>
        /// Возвращает True если авто сканирование Temic включено, иначе - выключено
        /// </summary>
        /// <returns>True если авто сканирование Temic включено</returns>
        bool GetAutoScanTemicEnabled();
        /// <summary>
        /// Читает данные карты Temic
        /// </summary>
        /// <param name="blockN">Номер первого блока, который нужно причитать (0..9)</param>
        /// <param name="buf">Буфер для прочитанных данных</param>
        /// <param name="blockCount">Количество блоков, которые нужно прочитать</param>
        /// <param name="scanParam">Параметры сканирования Temic. =-1 авто определение</param>
        /// <param name="read">Количество прочитанных блоков</param>
        /// <returns>Ничего не возвращает</returns>
        void ReadTemic(int blockN,
            [Out, MarshalAs(UnmanagedType.LPArray, SizeParamIndex = 2)] UInt32[] buf, 
            int blockCount, int scanParam /*= -1*/, out int read);
        /// <summary>
        /// Пишет данные карты Temic
        /// </summary>
        /// <param name="blockN">Номер первого блока, в который нужно записать (0..7)</param>
        /// <param name="data">Данные блоков для записи</param>
        /// <param name="blockCount">Количество блоков, которые нужно записать</param>
        /// <param name="Lock">True заблокировать блоки от перезаписи</param>
        /// <param name="scanParam">Параметры сканирования Temic. =-1 авто определение</param>
        /// <param name="written">Количество записанных блоков</param>
        /// <returns>Ничего не возвращает</returns>
        void WriteTemic(int blockN,
            [In, MarshalAs(UnmanagedType.LPArray, SizeParamIndex = 2)] UInt32[] data, 
            int blockCount,
            [MarshalAs(UnmanagedType.Bool)] bool Lock /*= false*/, 
            int scanParam /*= -1*/, out int written);
        /// <summary>
        /// Сброс TRES
        /// </summary>
        /// <param name="wait">True, ждать завершения команды</param>
        /// <returns>Ничего не возвращает</returns>
        void ResetTemic([MarshalAs(UnmanagedType.Bool)] bool wait = true);
        /// <summary>
        /// Шифрует данные для эмуляции Em-Marine, для записи в блоки 0..2
        /// </summary>
        /// <param name="uid">Номер Em-Marine, который нужно эмулировать</param>
        /// <param name="buf3">Буфер для данных 3-х блоков</param>
        /// <param name="blockCount">Размер буфера в блоках</param>
        /// <returns>Ничего не возвращает</returns>
        void EncodeTemicEmMarine(CardUID uid,
            [In, Out, MarshalAs(UnmanagedType.LPArray, SizeParamIndex = 2)] uint[] buf3, 
            int blockCount);
        /// <summary>
        /// Дешифрует номер Em-Marine из данных блока 1 карты Temic
        /// </summary>
        /// <param name="data3">Данные блоков 0..2</param>
        /// <param name="blockCount">Количество блоков. Должно быть не меньше 3</param>
        /// <param name="uid">Номер Em-Marine. Если Em-Marine не обнаружен, то пустой номер</param>
        /// <param name="configOk">True, конфигурация Temic для эмуляции Em-Marine правильная</param>
        /// <returns>Ничего не возвращает</returns>
        void DecodeTemicEmMarine(
            [In, MarshalAs(UnmanagedType.LPArray, SizeParamIndex = 1)] uint[] data3, 
            int blockCount, out CardUID uid,
            [MarshalAs(UnmanagedType.Bool)] out bool configOk);
        /// <summary>
        /// Шифрует данные для эмуляции HID, для записи в блоки 0-3
        /// </summary>
        /// <param name="uid">Номер HID, который нужно эмулировать</param>
        /// <param name="buf4">Буфер для данных 4-х блоков</param>
        /// <param name="blockCount">Размер буфера в блоках</param>
        /// <param name="wiegand">Номер кодировки Wiegand 18..37</param>
        /// <returns>Ничего не возвращает</returns>
        void EncodeTemicHID(CardUID uid,
            [In, Out, MarshalAs(UnmanagedType.LPArray, SizeParamIndex = 2)] uint[] buf4, 
            int blockCount, int wiegand);
        /// <summary>
        /// Дешифрует номер HID из данных блока 1-3 карты Temic
        /// </summary>
        /// <param name="data4">Данные блоков 0..3</param>
        /// <param name="blockCount">Количество блоков. Должно быть не меньше 4</param>
        /// <param name="uid">Номер HID. Если HID не обнаружен, то пустой номер</param>
        /// <param name="wiegand">Номер кодировки Wiegand</param>
        /// <param name="configOk">True конфигурация Temic правильная</param>
        /// <returns>Ничего не возвращает</returns>
        void DecodeTemicHID(
            [In, MarshalAs(UnmanagedType.LPArray, SizeParamIndex = 1)] uint[] data4, 
            int blockCount, out CardUID uid, out int wiegand,
            [MarshalAs(UnmanagedType.Bool)] out bool configOk);
        #endregion
    }

    [Guid("B5FDDC67-9CAE-49F1-84D0-0594D2D3B003")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IILR
    {
        /// <summary>
        /// Устанавливает функцию обратного вызова для исключения портов
        /// </summary>
        /// <param name="callback">Функция обратного вызова</param>
        /// <param name="userData">Ссылка на данные пользователя, которая передаётся в функцию
        /// обратного вызова</param>
        /// <returns>Ничего не возвращает</returns>
        void SetFilterPortCallback(
            [MarshalAs(UnmanagedType.FunctionPtr)] FilterPortProc callback, IntPtr userData);
        /// <summary>
        /// Устанавливает путь к файлу лога отладки
        /// </summary>
        /// <param name="path">Путь к лог файлу</param>
        /// <returns>Ничего не возвращает</returns>
        void SetLogPath(String path);
        /// <summary>
        /// Возвращает путь к файлу лога отладки
        /// </summary>
        /// <returns>Путь к лог файлу</returns>
        String GetLogPath();
        /// <summary>
        /// Устанавливает уровень лога отладки
        /// </summary>
        /// <param name="level">Уровень лога</param>
        /// <returns>Ничего не возвращает</returns>
        void SetLogLevel(LogLevel level);
        /// <summary>
        /// Возвращает уровень лога отладки
        /// </summary>
        /// <returns>Уровень лога</returns>
        LogLevel GetLogLevel();
        [PreserveSig]
        /// <summary>
        /// Очищает лог отладки
        /// </summary>
        /// <returns>Возвращает 0 при успехе</returns>
        int ClearLog();
        /// <summary>
        /// Устанавливает количество стоповых бит для COM-порта
        /// </summary>
        /// <param name="stopBits">Количество стоповых бит. =0 один бит, 
        /// =1 полтора бита, =2 два бита</param>
        /// <returns>Ничего не возвращает</returns>
        void SetStopBits(Byte stopBits);
        /// <summary>
        /// Возвращает количество стоповых бит для COM-порта
        /// </summary>
        /// <returns>Количество стоповых бит для COM-порта</returns>
        Byte GetStopBits();
        /// <summary>
        /// Устанавливает тайм-аут запроса к считывателю
        /// </summary>
        /// <param name="ms">Количество миллисекунд</param>
        /// <returns>Ничего не возвращает</returns>
        void SetRequestTimeout(uint ms);
        /// <summary>
        /// Возвращает тайм-аут запроса
        /// </summary>
        /// <returns>Тайм-аут запроса в миллисекундах</returns>
        uint GetRequestTimeout();
        /// <summary>
        /// Устанавливает количество попыток запроса
        /// </summary>
        /// <param name="attempts">Количество попыток отправить запрос</param>
        /// <returns>Ничего не возвращает</returns>
        void SetRequestAttempts(int attempts);
        /// <summary>
        /// Возвращает количество попыток запроса
        /// </summary>
        /// <returns>Количество попыток отправить запрос</returns>
        int GetRequestAttempts();

        /// <summary>
        /// Возвращает интерфейс поиска считывателей
        /// </summary>
        /// <returns>Интерфейс поиска считывателей</returns>
        [return: MarshalAs(UnmanagedType.Interface)]
        IILRSearch GetSearch();
        /// <summary>
        /// Возвращает интерфейс подключения к считывателю. Возможно получить несколько 
        /// дескрипторов для одного порта
        /// </summary>
        /// <param name="portType">Тип порта</param>
        /// <param name="portName">Имя порта</param>
        /// <returns>Интерфейс считывателя</returns>
        [return: MarshalAs(UnmanagedType.Interface)]
        IILReader GetReader(PortType portType, string portName);
    }  
    #endregion

    #region Интерфейсы для асинхронного режима
    [Guid("D82E158B-7B9D-46AC-B3F8-0D1D97422FF4")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IILRAsyncCommand
    {
        /// <summary>
        /// Отменяет команду. Устанавливает статус E_ABORT
        /// </summary>
        /// <returns>Ничего не возвращает</returns>
        void Cancel();
        /// <summary>
        /// Возвращает состояние команды
        /// </summary>
        /// <returns>E_PENDING команда ещё выполняется, иначе - завершена</returns>
        Int32 GetStatus();
        /// <summary>
        /// Возвращает состояние прогресса выполнения команды
        /// </summary>
        /// <param name="current">Текущий шаг</param>
        /// <param name="total">Всего шагов</param>
        /// <returns>Ничего не возвращает</returns>
        void GetProgress(out int current, out int total);
    }
    [Guid("C61BA823-D1AC-459E-B483-5A5F6CFAA446")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IILRSearchAsync
    {
        [return: MarshalAs(UnmanagedType.Interface)]
        /// <summary>
        /// Запускает асинхронную команду поиска считывателей
        /// </summary>
        /// <param name="reset">True, очистить список найденных перед поиском</param>
        /// <returns>Команда</returns>
        IILRAsyncCommand Begin_Scan(
            [MarshalAs(UnmanagedType.Bool)] bool reset = false);
        [return: MarshalAs(UnmanagedType.Interface)]
        /// <summary>
        /// Запускает асинхронную команду вкл/выкл режим авто поиска считывателей
        /// </summary>
        /// <param name="enable">True, включает поиск в реальном времени, иначе - выключает</param>
        /// <returns>Команда</returns>
        IILRAsyncCommand Begin_EnableAutoScan(
            [MarshalAs(UnmanagedType.Bool)] bool enable = true);
        /// <summary>
        /// Запускает асинхронную команду открытия порта
        /// </summary>
        /// <param name="portType">Тип порта</param>
        /// <param name="portName">Имя порта</param>
        /// <returns>Команда</returns>
        IILRAsyncCommand Begin_OpenPort(PortType portType, string portName);
        /// <summary>
        /// Возвращает результат открытия порта
        /// </summary>
        /// <param name="cmd">Команда, которую вернул метод Begin_OpenPort</param>
        /// <param name="hPort">Дескриптор порта</param>
        /// <param name="info">Информация о конвертере (если известно)</param>
        /// <returns>Ничего не возвращает</returns>
        void End_OpenPort([In, MarshalAs(UnmanagedType.Interface)] IILRAsyncCommand cmd,
            out IntPtr hPort, out ReaderInfo info);
        [return: MarshalAs(UnmanagedType.Interface)]
        /// <summary>
        /// Запускает асинхронную команду закрытия порта
        /// </summary>
        /// <param name="portType">Тип порта</param>
        /// <param name="portName">Имя порта</param>
        /// <param name="hPort">Дескриптор порта</param>
        /// <returns>Команда</returns>
        IILRAsyncCommand Begin_ClosePort(PortType portType, string portName, IntPtr hPort);
    }
    [Guid("83938709-8E3B-4581-82EE-C5163DA2FAF8")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IILReaderAsync
    {
        [return: MarshalAs(UnmanagedType.Interface)]
        /// <summary>
        /// Запускает асинхронную команду подключения к считывателю
        /// </summary>
        /// <param name="reconnect">True, переподключиться</param>
        /// <returns>Команда</returns>
        IILRAsyncCommand Begin_Connect([MarshalAs(UnmanagedType.Bool)] bool reconnect = false);
        [return: MarshalAs(UnmanagedType.Interface)]
        /// <summary>
        /// Запускает асинхронную команду отключения от считывателя
        /// </summary>
        /// <returns>Команда</returns>
        IILRAsyncCommand Begin_Disconnect();
        [return: MarshalAs(UnmanagedType.Interface)]
        /// <summary>
        /// Запускает асинхронную команду поиска карты
        /// </summary>
        /// <param name="reset">True, сбросить старые результаты поиска</param>
        /// <param name="powerOff">True, выключает RF поле после сканирования</param>
        /// <returns>Команда</returns>
        IILRAsyncCommand Begin_Scan(
            [MarshalAs(UnmanagedType.Bool)] bool reset = false,
            [MarshalAs(UnmanagedType.Bool)] bool powerOff = true);
        [return: MarshalAs(UnmanagedType.Interface)]
        /// <summary>
        /// Запускает асинхронную команду вкл/выкл автоматического сканирования карт
        /// </summary>
        /// <param name="enable">True включает авто сканирование, иначе - выключает</param>
        /// <returns>Команда</returns>
        IILRAsyncCommand Begin_EnableAutoScan(
            [MarshalAs(UnmanagedType.Bool)] bool enable = true);

        #region Карта Mifare Ultralight
        [return: MarshalAs(UnmanagedType.Interface)]
        /// <summary>
        /// Запускает асинхронную команду чтения данных из карты Mifare Ultralight
        /// </summary>
        /// <param name="pageIdx">Номер первой читаемой страницы (начиная от 0)</param>
        /// <param name="pageCount">Количество читаемых страниц</param>
        /// <returns>Команда</returns>
        IILRAsyncCommand Begin_ReadMfUlralight(int pageIdx, int pageCount);
        /// <summary>
        /// Возвращает результат чтения данных из карты Mifare Ultralight
        /// </summary>
        /// <param name="cmd">Команда, которую вернул метод Begin_ReadMfUlralight</param>
        /// <param name="buf">Буфер для данных страниц</param>
        /// <param name="bufSize">Размер буфера в страницах</param>
        /// <param name="read">Количество прочитанных страниц</param>
        /// <returns>Ничего не возвращает</returns>
        void End_ReadMfUlralight(
            [In, MarshalAs(UnmanagedType.Interface)] IILRAsyncCommand cmd,
            [Out, MarshalAs(UnmanagedType.LPArray, SizeParamIndex = 2)] UInt32[] buf,
            int bufSize, out int read);

        [return: MarshalAs(UnmanagedType.Interface)]
        /// <summary>
        /// Запускает асинхронную команду записи данных в карту Mifare Ultralight
        /// </summary>
        /// <param name="pageIdx">Номер первой записываемой страницы (начиная от 0)</param>
        /// <param name="data">Данные страниц</param>
        /// <param name="pageCount">Количество записываемых страниц</param>
        /// <returns>Команда</returns>
        IILRAsyncCommand Begin_WriteMfUlralight(int pageIdx,
            [In, MarshalAs(UnmanagedType.LPArray, SizeParamIndex = 2)] UInt32[] data,
            int pageCount);
        /// <summary>
        /// Возвращает результат записи данных в карту Mifare Ultralight
        /// </summary>
        /// <param name="cmd">Команда, которую вернул метод Begin_WriteMfUlralight</param>
        /// <param name="written">Количество записанных страниц</param>
        /// <returns>Ничего не возвращает</returns>
        void End_WriteMfUlralight(
            [In, MarshalAs(UnmanagedType.Interface)] IILRAsyncCommand cmd,
            out int written);
        #endregion

        #region Карта Карта Mifare Classic/Plus
        [return: MarshalAs(UnmanagedType.Interface)]
        /// <summary>
        /// Запускает асинхронную команду авторизации сектора карты Mifare Classic / Plus,
        /// используя ключ, загруженный функцией LoadMfAuthKey / LoadMfPlusAuthKey
        /// </summary>
        /// <param name="address">Номер блока или адрес Mifare Plus</param>
        /// <param name="keyB">=True авторизовать по ключу B, иначе A</param>
        /// <returns>Команда</returns>
        IILRAsyncCommand Begin_AuthMfCard(uint address, [MarshalAs(UnmanagedType.Bool)] bool keyB);
        /// <summary>
        /// Возвращает результат авторизации сектора карты
        /// </summary>
        /// <param name="cmd">Команда, которую вернул метод Begin_AuthMfCard</param>
        /// <param name="authOk">=True, авторизация прошла успешно</param>
        /// <returns>Ничего не возвращает</returns>
        void End_AuthMfCard(
            [In, MarshalAs(UnmanagedType.Interface)] IILRAsyncCommand cmd,
            [MarshalAs(UnmanagedType.Bool)] out bool authOk);
        [return: MarshalAs(UnmanagedType.Interface)]
        /// <summary>
        /// Запускает асинхронную команду авторизации сектора карты Mifare Classic / Plus 
        /// используя ключи в памяти считывателя
        /// </summary>
        /// <param name="address">Номер блока или адрес Mifare Plus</param>
        /// <param name="keyB">True по ключу B, иначе A</param>
        /// <param name="rdKeys">Биты номеров ключей в памяти считывателя</param>
        /// <returns>Команда</returns>
        IILRAsyncCommand Begin_AuthMfCardByRdKeys(uint address, 
            [MarshalAs(UnmanagedType.Bool)] bool keyB,
            uint rdKeys = 0xffff);
        /// <summary>
        /// Возвращает результат авторизации сектора карты
        /// </summary>
        /// <param name="cmd">Команда, которую вернул метод Begin_AuthMfCardByRdKeys</param>
        /// <param name="keyIdx">Позиция найденного ключа в памяти считывателя, 
        /// =-1 ключ не найден</param>
        /// <returns>Ничего не возвращает</returns>
        void End_AuthMfCardByRdKeys(
            [In, MarshalAs(UnmanagedType.Interface)] IILRAsyncCommand cmd,
            out int keyIdx);
        [return: MarshalAs(UnmanagedType.Interface)]
        /// <summary>
        /// Запускает асинхронную команду чтения данных из карты Mifare Classic или Mifare Plus SL1
        /// </summary>
        /// <param name="blockIdx">Номер блока Mifare Classic</param>
        /// <param name="blockCount">Количество блоков</param>
        /// <returns>Команда</returns>
        IILRAsyncCommand Begin_ReadMfClassic(int blockIdx, int blockCount);
        /// <summary>
        /// Возвращает результат чтения данных из карты Mifare Classic или Mifare Plus SL1
        /// </summary>
        /// <param name="cmd">Команда, которую вернул метод Begin_ReadMfClassic</param>
        /// <param name="buf">Буфер для данных блоков</param>
        /// <param name="bufSize">Размер буфера в блоках</param>
        /// <param name="read">Количество прочитанных блоков</param>
        /// <returns>Ничего не возвращает</returns>
        void End_ReadMfClassic(
            [In, MarshalAs(UnmanagedType.Interface)] IILRAsyncCommand cmd,
            [Out, MarshalAs(UnmanagedType.LPArray, SizeParamIndex = 2)] MfBlockData[] buf, 
            int bufSize, out int read);
        [return: MarshalAs(UnmanagedType.Interface)]
        /// <summary>
        /// Запускает асинхронную команду записи данных в карту Mifare Classic или Mifare Plus SL1
        /// </summary>
        /// <param name="blockIdx">Номер блока Mifare Classic</param>
        /// <param name="data">Данные блоков для записи</param>
        /// <param name="blockCount">Количество записываемых блоков</param>
        /// <returns>Команда</returns>
        IILRAsyncCommand Begin_WriteMfClassic(int blockIdx,
            [In, MarshalAs(UnmanagedType.LPArray, SizeParamIndex = 2)] MfBlockData[] data,
            int blockCount);
        /// <summary>
        /// Возвращает результат записи данных в карту Mifare Classic или Mifare Plus SL1
        /// </summary>
        /// <param name="cmd">Команда, которую вернул метод Begin_WriteMfClassic</param>
        /// <param name="written">Количество записанных блоков</param>
        /// <returns>Ничего не возвращает</returns>
        void End_WriteMfClassic(
            [In, MarshalAs(UnmanagedType.Interface)] IILRAsyncCommand cmd,
            out int written);
        [return: MarshalAs(UnmanagedType.Interface)]
        /// <summary>
        /// Запускает асинхронную команду чтения данных из карты Mifare Plus SL3
        /// </summary>
        /// <param name="address">Номер блока карты Mifare</param>
        /// <param name="blockCount">Количество блоков, которые нужно прочитать</param>
        /// <param name="openText">True, открытая передача, иначе зашифрованная</param>
        /// <returns>Команда</returns>
        IILRAsyncCommand Begin_ReadMfPlus(uint address, int blockCount,
            [MarshalAs(UnmanagedType.Bool)] bool openText);
        /// <summary>
        /// Возвращает результат чтения данных из карты Mifare Plus SL3
        /// </summary>
        /// <param name="cmd">Команда, которую вернул метод Begin_ReadMfPlusSL3</param>
        /// <param name="buf">Буфер для данных блоков</param>
        /// <param name="bufSize">Размер буфера в блоках</param>
        /// <param name="read">Количество прочитанных блоков</param>
        /// <returns>Ничего не возвращает</returns>
        void End_ReadMfPlus(
            [In, MarshalAs(UnmanagedType.Interface)] IILRAsyncCommand cmd,
            [Out, MarshalAs(UnmanagedType.LPArray, SizeParamIndex = 2)] MfBlockData[] buf,
            int bufSize, out int read);
        [return: MarshalAs(UnmanagedType.Interface)]
        /// <summary>
        /// Запускает асинхронную команду записи данных в карту Mifare Plus SL3
        /// </summary>
        /// <param name="address">Номер блока или адрес Mifare Plus</param>
        /// <param name="data">Данные блоков для записи</param>
        /// <param name="blockCount">Количество блоков</param>
        /// <param name="openText">True, открытая передача, иначе зашифрованная</param>
        /// <returns>Команда</returns>
        IILRAsyncCommand Begin_WriteMfPlus(uint address,
            [In, MarshalAs(UnmanagedType.LPArray, SizeParamIndex = 2)] MfBlockData[] data,
            int blockCount,
            [MarshalAs(UnmanagedType.Bool)] bool openText);
        /// <summary>
        /// Возвращает результат записи данных в карту Mifare Plus SL3
        /// </summary>
        /// <param name="cmd">Команда, которую вернул метод Begin_WriteMfPlusSL3</param>
        /// <param name="written">Количество записанных блоков</param>
        /// <returns>Ничего не возвращает</returns>
        void End_WriteMfPlus(
            [In, MarshalAs(UnmanagedType.Interface)] IILRAsyncCommand cmd,
            out int written);
        [return: MarshalAs(UnmanagedType.Interface)]
        /// <summary>
        /// Увеличивает содержимое блока-значения карты Mifare и сохраняет результат во временном 
        /// регистре данных
        /// </summary>
        /// <param name="blockIdx">Номер блока Mifare Plus</param>
        /// <param name="value">Величина инкремента</param>
        /// <returns>Команда</returns>
        IILRAsyncCommand Begin_MfIncrement(int blockIdx, uint value);
        [return: MarshalAs(UnmanagedType.Interface)]
        /// <summary>
        /// Уменьшает содержимое блока-значения карты Mifare и сохраняет результат во временном 
        /// регистре данных
        /// </summary>
        /// <param name="blockIdx">Номер блока Mifare Plus</param>
        /// <param name="value">Величина декремента</param>
        /// <returns>Команда</returns>
        IILRAsyncCommand Begin_MfDecrement(int blockIdx, uint value);
        [return: MarshalAs(UnmanagedType.Interface)]
        /// <summary>
        /// Записывает содержимое во временном регистре данных в блок-значение
        /// </summary>
        /// <param name="blockIdx">Номер блока Mifare Plus</param>
        /// <returns>Команда</returns>
        IILRAsyncCommand Begin_MfTransfer(int blockIdx);
        [return: MarshalAs(UnmanagedType.Interface)]
        /// <summary>
        /// Перемещает содержимое блока в регист данных Mifare
        /// </summary>
        /// <param name="blockIdx">Номер блока Mifare Plus</param>
        /// <returns>Команда</returns>
        IILRAsyncCommand Begin_MfRestore(int blockIdx);
        [return: MarshalAs(UnmanagedType.Interface)]
        /// <summary>
        /// Запускает асинхронную команду записи ключей аутентификации Mifare Classic в память 
        /// считывателя
        /// </summary>
        /// <param name="idx">Позиция первого ключа в памяти считывателя</param>
        /// <param name="keyB">True ключ B, иначе ключ A</param>
        /// <param name="keys">Список ключей аутентификации</param>
        /// <param name="count">Количество ключей аутентификации</param>
        /// <returns>Команда</returns>
        IILRAsyncCommand Begin_WriteMfAuthKeyToReader(int idx,
            [MarshalAs(UnmanagedType.Bool)] bool keyB,
            [In, MarshalAs(UnmanagedType.LPArray, SizeParamIndex = 3)] Int64[] keys,
            int count);
        /// <summary>
        /// Возвращает результат записи ключей аутентификации Mifare Classic в память считывателя
        /// </summary>
        /// <param name="cmd">Команда, которую вернул метод Begin_WriteMfAuthKeyToReader</param>
        /// <param name="written">Количество записанных ключей</param>
        /// <returns>Ничего не возвращает</returns>
        void End_WriteMfAuthKeyToReader(
            [In, MarshalAs(UnmanagedType.Interface)] IILRAsyncCommand cmd,
            out int written);
        [return: MarshalAs(UnmanagedType.Interface)]
        /// <summary>
        /// Запускает асинхронную команду записи ключей аутентификации Mifare Plus в память считывателя
        /// </summary>
        /// <param name="idx">Позиция первого ключа в памяти считывателя</param>
        /// <param name="keyB">True ключ B, иначе ключ A</param>
        /// <param name="keys">Список ключей аутентификации</param>
        /// <param name="count">Количество ключей аутентификации</param>
        /// <returns>Команда</returns>
        IILRAsyncCommand Begin_WriteMfPlusAuthKeyToReader(int idx,
            [MarshalAs(UnmanagedType.Bool)] bool keyB,
            [In, MarshalAs(UnmanagedType.LPArray, SizeParamIndex = 3)] MfPlusKey[] keys,
            int count);
        /// <summary>
        /// Возвращает результат записи ключей аутентификации Mifare Plus в память считывателя
        /// </summary>
        /// <param name="cmd">Команда, которую вернул метод Begin_WriteMfPlusAuthKeyToReader</param>
        /// <param name="written">Количество записанных ключей</param>
        /// <returns>Ничего не возвращает</returns>
        void End_WriteMfPlusAuthKeyToReader(
            [In, MarshalAs(UnmanagedType.Interface)] IILRAsyncCommand cmd,
            out int written);
        #endregion

        #region Карта Temic
        [return: MarshalAs(UnmanagedType.Interface)]
        /// <summary>
        /// Запускает асинхронную команду поиска карты Temic в поле считывателя
        /// </summary>
        /// <param name="scanParam">Параметры сканирования Temic. =-1 авто определение</param>
        /// <returns>Команда</returns>
        IILRAsyncCommand Begin_ScanTemic(int scanParam = -1);
        [return: MarshalAs(UnmanagedType.Interface)]
        /// <summary>
        /// Запускает асинхронную команду чтения данных из карты Temic
        /// </summary>
        /// <param name="blockIdx">Номер блока карты</param>
        /// <param name="blockCount">Количество блоков</param>
        /// <param name="scanParam">Параметр сканирования Temic. =-1 авто определение</param>
        /// <returns>Команда</returns>
        IILRAsyncCommand Begin_ReadTemic(int blockIdx, int blockCount, int scanParam = -1);
        /// <summary>
        /// Возвращает результат чтения данных из карты Temic
        /// </summary>
        /// <param name="cmd">Команда, которую вернул метод Begin_ReadTemic</param>
        /// <param name="buf">Буфер для прочитанных данных</param>
        /// <param name="blockSize">Размер буфера в блоках</param>
        /// <param name="read">Количество прочитанных блоков</param>
        /// <returns>Ничего не возвращает</returns>
        void End_ReadTemic(
            [In, MarshalAs(UnmanagedType.Interface)] IILRAsyncCommand cmd,
            [Out, MarshalAs(UnmanagedType.LPArray, SizeParamIndex = 2)] uint[] buf,
            int blockSize, out int read);
        [return: MarshalAs(UnmanagedType.Interface)]
        /// <summary>
        /// Запускает асинхронную команду записи данных в карту Temic
        /// </summary>
        /// <param name="blockIdx">Номер блока карты</param>
        /// <param name="data">Данные для записи</param>
        /// <param name="blockCount">Количество блоков</param>
        /// <param name="Lock">True блокировать от перезаписи</param>
        /// <param name="scanParam">Параметр сканирования Temic. =-1 авто определение</param>
        /// <returns>Команда</returns>
        IILRAsyncCommand Begin_WriteTemic(int blockIdx, 
            [In, MarshalAs(UnmanagedType.LPArray, SizeParamIndex = 2)] uint[] data,
            int blockCount, 
            [MarshalAs(UnmanagedType.Bool)] bool Lock = false,
            int scanParam = -1);
        /// <summary>
        /// Возвращает результат записи данных в карту Temic
        /// </summary>
        /// <param name="cmd">Команда, которую вернул метод Begin_WriteTemic</param>
        /// <param name="written">Количество записанных блоков</param>
        /// <returns>Ничего не возвращает</returns>
        void End_WriteTemic(
            [In, MarshalAs(UnmanagedType.Interface)] IILRAsyncCommand cmd,
            out int written);
        [return: MarshalAs(UnmanagedType.Interface)]
        /// <summary>
        /// Запускает асинхронную команду сброса TRES
        /// </summary>
        /// <returns>Команда</returns>
        IILRAsyncCommand Begin_ResetTemic();
        #endregion
    }
    #endregion

    // Класс исключения SDK Readers
    public class ILRException : COMException
    {
        public ILRException(Int32 errorCode) :
            base(ILR.GetErrorText(errorCode), errorCode)
        {
        }
    }

    class ILR
    {
        #region Совместимая версия SDK
        public const UInt32 SDK_VERSION = 0x0B0004; // Версия SDK Readers = v4.0.11
        #endregion

        #region Коды ошибок SDK
        // Операция выполнена успешно
        public static readonly Int32 S_OK = 0;
        // Операция выполняется асинхронно
        public static readonly Int32 E_PENDING = unchecked((Int32)0x8000000A);
        // Индекс вне диапазона
        public static readonly Int32 E_BOUNDS = unchecked((Int32)0x8000000B);
        // Неправильный указатель
        public static readonly Int32 E_POINTER = unchecked((Int32)0x80004003);
        // Функция прервана
        public static readonly Int32 E_ABORT = unchecked((Int32)0x80004004);
        // Неопознанная ошибка
        public static readonly Int32 E_FAIL = unchecked((Int32)0x80004005);
        // Недостаточно памяти для обработки команды
        public static readonly Int32 E_OUTOFMEMORY = unchecked((Int32)0x8007000E);
        // Неправильный параметр
        public static readonly Int32 E_INVALIDARG = unchecked((Int32)0x80070057);
        // Неправильная версия Sdk Readers передана в ILR_GetInterface
        public static readonly Int32 ILR_E_WRONG_SDK_VERSION = unchecked((Int32)0x80040200);
        // Размер буфера слишком мал
        public static readonly Int32 ILR_E_BUFFER_TOO_SMALL = unchecked((Int32)0x80040202);
        // Недостаточно ресурсов для завершения операции
        public static readonly Int32 ILR_E_OUT_OF_RESOURCES = unchecked((Int32)0x80040203);
        // Блокирующий вызов функции из обработчика не разрешен
        public static readonly Int32 ILR_E_BLOCKING_CALL_NOT_ALLOWED = unchecked((Int32)0x80040204);
        // Ошибка функции Smart Cards
        public static readonly Int32 ILR_E_SCARD_ERROR = unchecked((Int32)0x80040205);

        // Неправильное имя порта
        public static readonly Int32 ILR_E_INVALID_PORTNAME = unchecked((Int32)0x80040400);
        // Порт не существует
        public static readonly Int32 ILR_E_PORT_NOT_EXIST = unchecked((Int32)0x80040401);
        // Порт занят (уже используется)
        public static readonly Int32 ILR_E_PORT_BUSY = unchecked((Int32)0x80040402);
        // Попытка подключения была отклонена
        public static readonly Int32 ILR_E_CONNECT_REFUSED = unchecked((Int32)0x80040403);
        // Ошибка открытия порта
        public static readonly Int32 ILR_E_PORT_OPEN_FAILED = unchecked((Int32)0x80040404);
        // Ошибка настройки порта
        public static readonly Int32 ILR_E_PORT_CONFIGURE_FAILED = unchecked((Int32)0x80040405);
        // Ошибка передачи данных через порт
        public static readonly Int32 ILR_E_PORT_TRANSPORT_ERROR = unchecked((Int32)0x80040406);
        // Связь с устройством была потеряна
        public static readonly Int32 ILR_E_PORT_NO_CONNECTION = unchecked((Int32)0x80040407);
        // Тайм-аут запроса к считывателю
        public static readonly Int32 ILR_E_REQUEST_TIMEOUT = unchecked((Int32)0x80040409);
        // Не распознан ответ считывателя
        public static readonly Int32 ILR_E_BAD_RESPONSE = unchecked((Int32)0x8004040A);
        // Неизвестная ошибка считывателя
        public static readonly Int32 ILR_E_READER_ERROR = unchecked((Int32)0x8004040B);
        // Нет карты
        public static readonly Int32 ILR_E_NO_CARD = unchecked((Int32)0x8004040C);
        // Страница карты заблокирована
        public static readonly Int32 ILR_E_CARD_PAGE_LOCK = unchecked((Int32)0x8004040D);
        // Не удалось записать на Temic
        public static readonly Int32 ILR_E_WRITE_T57 = unchecked((Int32)0x8004040E);
        // Ошибка авторизации карты
        public static readonly Int32 ILR_E_CARD_AUTHORIZE = unchecked((Int32)0x8004040F);
        // Ошибка блока-значения Mifare
        public static readonly Int32 ILR_E_MIFARE_VALUE = unchecked((Int32)0x80040410);
        // Неправильный адрес Mifare
        public static readonly Int32 ILR_E_MIFARE_ADDRESS = unchecked((Int32)0x80040411);
        // Карта отказала от выполнения команды
        public static readonly Int32 ILR_E_CARD_NACK = unchecked((Int32)0x80040412);
        #endregion

        #region Названия моделей считывателей
        public static readonly string[] kRdModelNames = {
            "",
            "Z-2 RD_ALL",
            "Z-2 USB MF",
            "Z-2 MF-I",
            "Z-2 EHR",
            "Z-2 Base",
            "RF-1996",
            "Matrix III Rd-All",
            "Matrix III Net",
            "CP-Z 2MF",
            "Matrix V",
            "Z-2 MF CCID",
            "Matrix-VI (NFC K Net)"
        };
        #endregion
        #region Названия типов карт
        // Название типов карт
        public static readonly string[] kCardTypeNames = {
            "",
            "Em-Marine",
            "HID",
            "iCode",
            "Cod433",
            "Cod433 Fix",
            "CAME",
            "Dallas",
            "Temic",
            "Mifare UltraLight",
            "Mifare UltraLight C",
            "Mifare Mini",
            "Mifare Classic 1K",
            "Mifare Classic 2K",
            "Mifare Classic 4K",
            "Mifare Plus",
            "Mifare Plus 1K",
            "Mifare Plus 2K",
            "Mifare Plus 4K",
            "Smart MX with Mifare 1K",
            "Smart MX with Mifare 4K",
            "Mifare DESFire",
            "Mifare ProX"
        };
        // Название подтипов карт Mifare Plus
        public static readonly string[] kMpTypeNames = {
            "",
            "S",
            "X",
            "SE",
            "EV1",
            "EV2"
        };
        #endregion

        public const String DllName = "ILReaders.dll";

        /// <summary>
        /// Возвращает номер версии SDK Readers
        /// </summary>
        /// <returns>Номер версии SDK Readers</returns>
        [DllImport(DllName, CallingConvention = CallingConvention.StdCall, EntryPoint = "ILR_GetVersion")]
        public static extern UInt32 ILR_GetVersion();

        /// <summary>
        /// Возвращает описание ошибки по её коду. Для освобождения памяти используйте SysFreeString(Text)
        /// </summary>
        /// <param name="errorCode">Код ошибки SDK</param>
        /// <param name="text">Возвращаемый текст ошибки</param>
        /// <returns>Код возврата SDK</returns>
        [DllImport(DllName, CharSet = CharSet.Unicode, CallingConvention = CallingConvention.StdCall, EntryPoint = "ILR_GetErrorText")]
        public static extern Int32 ILR_GetErrorText(Int32 errorCode,
            [MarshalAs(UnmanagedType.BStr)] out String text);

        /// <summary>
        /// Возвращает главный интерфейс библиотеки. Эта функция не потокобезопасная
        /// </summary>
        /// <param name="errorCode">Код ошибки SDK</param>
        /// <param name="text">Возвращаемый текст ошибки</param>
        /// <returns>Код возврата SDK</returns>
        [DllImport(DllName, CallingConvention = CallingConvention.StdCall, EntryPoint = "ILR_GetInterface")]
        public static extern Int32 ILR_GetInterface(
            [MarshalAs(UnmanagedType.Interface)] out IILR obj,
            UInt32 versionRequested = SDK_VERSION);


        /// <summary>
        /// Возвращает текст ощибки по коду, который вернула функция ILReaders.dll
        /// </summary>
        /// <param name="errorCode">Код ошибки</param>
        /// <returns>Текст сообщения об ошибке</returns>
        public static String GetErrorText(Int32 errorCode)
        {
            String s;
            ILR_GetErrorText(errorCode, out s);
            return s;
        }

        /// <summary>
        /// Проверяет код возврата функции и если это код ошибки, то генерирует исключение
        /// </summary>
        /// <param name="returnCode">Код возврата Sdk</param>
        /// <returns>Ничего не возвращает</returns>
        public static void Check(Int32 returnCode)
        {
            if ((returnCode < 0) && (returnCode != E_PENDING))
            {
                if (((returnCode >> 16) & 0x1fff) == 4) // if (HRESULT_FACILITY(hr) == FACILITY_ITF)
                    throw new ILRException(returnCode);
                else
                    Marshal.ThrowExceptionForHR(returnCode);
            }
        }

        /// <summary>
        /// Преобразовывает типы ключей в флаги RWCTF
        /// </summary>
        /// <param name="types">Типы ключей</param>
        /// <returns>Флаги RWCTF</returns>
        public static RWCTF RWCardTypesToFlags(HashSet<RWCardType> types)
        {
            RWCTF res = 0;
            if (types.Contains(RWCardType.MfUltralight))
                res |= RWCTF.RWCT_F_MFULTRALIGHT;
            if (types.Contains(RWCardType.MfClassic))
                res |= RWCTF.RWCT_F_MFCLASSIC;
            if (types.Contains(RWCardType.MfPlus))
                res |= RWCTF.RWCT_F_MFPPLUS;
            if (types.Contains(RWCardType.Temic))
                res |= RWCTF.RWCT_F_TEMIC;
            return res;
        }

        /// <summary>
        /// Преобразует номер версии в формате SDK Readers в строку
        /// </summary>
        /// <param name="version">Номер версии</param>
        /// <returns>Строка с номером версии</returns>
        public static string VersionToStr(UInt32 version)
        {
            if (0 == version)
                return "";
            if ((version & 0xff) == 0xff)
            {
                version >>= 8;
                return version.ToString();
            }
            string s = (version & 0xff).ToString();
            int len = s.Length;
            UInt32 n;
            for(int i = 1; i < 4; ++i)
            {
                version >>= 8;
                n = (version & 0xff);
                s += "." + n.ToString();
                if (n != 0)
                    len = s.Length;
            }
            s.Remove(len);
            return s;
        }

        /// <summary>
        /// Преобразует дату/время в формате SDK Readers в дату/время C#
        /// </summary>
        /// <param name="timestamp"></param>
        /// <returns></returns>
        public static DateTime TimeToDateTime(Int64 timestamp)
        {
            DateTime date = new DateTime(1970, 1, 1).AddSeconds(timestamp);
            DateTimeOffset offs = DateTimeOffset.Now;
            date += offs.Offset;
            return date;
        }

        /// <summary>
        /// Преобразует номер карты в строку
        /// </summary>
        /// <param name="type">Тип карты</param>
        /// <param name="uid">Номер карты</param>
        /// <returns>Строка с номером карты</returns>
        public static string CardUIDToStr(CardType type, CardUID uid)
        {
            string s = "";
            switch (type)
            {
                case CardType.EmMarine:
                    return string.Format("{0},{1:D5}", uid.bytes[2], uid.bytes[0] + (uid.bytes[1] << 8));

                case CardType.HID:
                    {
                        int nFCount = Math.Min(uid.Length - 2, 4);
                        int nFacility = 0;
                        int nOffs = 0;
                        for (int i = 0; i < nFCount; i++, nOffs += 8)
                            nFacility |= (uid.bytes[2 + i] << nOffs);

                        s = string.Format("[{0}] {1:D5}",
                            nFacility.ToString(string.Format("X{0}", nFCount * 2)),
                            uid.bytes[0] + (uid.bytes[1] << 8));
                    }
                    break;

                default:
                    {
                        for (int i = (uid.Length - 1); i >= 0; --i)
                            s = s + uid.bytes[i].ToString("X2");
                    }
                    break;
            }
            return s;
        }

        /// <summary>
        /// Возвращает номер сектора по номеру блока Mifare
        /// </summary>
        /// <param name="nBlock">Номер блока 0..255</param>
        /// <returns></returns>
        public static int GetMfSectorByBlock(int nBlock)
        {
            return (nBlock < 128) ? (nBlock / 4) : (32 + ((nBlock - 128) / 16));
        }

        /// <summary>
        /// Возвращает биты доступа сектора Mifare
        /// </summary>
        /// <param name="trailerData">Данные блока-прицепа</param>
        /// <returns>Биты доступа сектора Mifare</returns>
        public static uint GetMfAccessBits(MfBlockData trailerData)
        {
            return BitConverter.ToUInt32(trailerData.a, 6) & 0xFFF;
        }

        /// <summary>
        /// Возвращает биты доступа для области сектора Mifare (3 бита)
        /// </summary>
        /// <param name="accessBits">Биты доступа сектора Mifare. 
        /// Можно получить функцией GetMfAccessBits</param>
        /// <param name="area">Номер области сектора</param>
        /// <returns>Биты доступа области сектора Mifare</returns>
        public static uint GetMfAreaAccess(uint accessBits, int area)
        {
            return ((accessBits >> (12 + area)) & 1) | 
                (((accessBits >> (16 + area)) & 1) << 1) | 
                (((accessBits >> (20 + area)) & 1) << 2);
        }
    }
}
