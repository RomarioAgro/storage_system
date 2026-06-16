#ifndef _ILREADERS_H
#define _ILREADERS_H

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

//#include <windows.h>
#include <wtypes.h>

// this is the switch to change between static and dynamic linking.
#define ILREADERS_LINKONREQUEST


#ifndef ILREADERS_LINKONREQUEST

#ifdef ILREADERS_EXPORTS
#define ILREADERS_API(type) extern "C" __declspec(dllexport) type __stdcall
#else
#ifdef ILREADERS_STATIC
#define ILREADERS_API(type) extern "C" type __stdcall 
#else
#define ILREADERS_API(type) extern "C" __declspec(dllimport) type __stdcall
#pragma comment(lib, "ILReaders.lib")
#endif // ILREADERS_STATIC
#endif // ILREADERS_EXPORTS

#endif // !ILREADERS_LINKONREQUEST

#if defined(_MSC_VER)
#define ILR_NOEXCEPT noexcept
#else
#if __BORLANDC__
#define ILR_NOEXCEPT throw()
#else
#define ILR_NOEXCEPT
#endif
#endif

#define ILR_DLL_NAME		TEXT("ILReaders.dll")
#define ILR_SDK_VERSION		0x0B0004	// Версия SDK Readers = v4.0.11

#pragma region Коды ошибок
// Коды ошибок SDK Readers
#ifndef ILREADERS_EXPORTS
// Неправильная версия Sdk Readers
#define ILR_E_WRONG_SDK_VERSION			((HRESULT)0x80040200L)
// Размер буфера слишком мал
#define ILR_E_BUFFER_TOO_SMALL			((HRESULT)0x80040202L)
// Недостаточно ресурсов для завершения операции
#define ILR_E_OUT_OF_RESOURCES			((HRESULT)0x80040203L)
// Блокирующий вызов функции из обработчика не разрешен
#define ILR_E_BLOCKING_CALL_NOT_ALLOWED	((HRESULT)0x80040204L)
// Ошибка функции Smart Cards
#define ILR_E_SCARD_ERROR				((HRESULT)0x80040205L)
// Неправильное имя порта
#define ILR_E_INVALID_PORTNAME			((HRESULT)0x80040400L)
// Порт не существует
#define ILR_E_PORT_NOT_EXIST			((HRESULT)0x80040401L)
// Порт занят (уже используется)
#define ILR_E_PORT_BUSY					((HRESULT)0x80040402L)
// Попытка подключения была отклонена
#define ILR_E_CONNECT_REFUSED			((HRESULT)0x80040403L)
// Ошибка открытия порта
#define ILR_E_PORT_OPEN_FAILED			((HRESULT)0x80040404L)
// Ошибка настройки порта
#define ILR_E_PORT_CONFIGURE_FAILED		((HRESULT)0x80040405L)
// Ошибка передачи данных через порт
#define ILR_E_PORT_TRANSPORT_ERROR		((HRESULT)0x80040406L)
// Связь с устройством была потеряна
#define ILR_E_PORT_NO_CONNECTION		((HRESULT)0x80040407L)
// Тайм-аут запроса к считывателю
#define ILR_E_REQUEST_TIMEOUT			((HRESULT)0x80040409L)
// Не распознан ответ считывателя
#define ILR_E_BAD_RESPONSE				((HRESULT)0x8004040AL)
// Неизвестная ошибка считывателя
#define ILR_E_READER_ERROR				((HRESULT)0x8004040BL)
// Нет карты
#define ILR_E_NO_CARD					((HRESULT)0x8004040CL)
// Страница карты заблокирована
#define ILR_E_CARD_PAGE_LOCK			((HRESULT)0x8004040DL)
// Не удалось записать на Temic
#define ILR_E_WRITE_T57					((HRESULT)0x8004040EL)
// Ошибка авторизации карты
#define ILR_E_CARD_AUTHORIZE			((HRESULT)0x8004040FL)
// Ошибка блока-значения Mifare
#define ILR_E_MIFARE_VALUE				((HRESULT)0x80040410L)
// Неправильный адрес Mifare
#define ILR_E_MIFARE_ADDRESS			((HRESULT)0x80040411L)
// Карта отказала от выполнения команды
#define ILR_E_CARD_NACK					((HRESULT)0x80040412L)
#endif // !ILREADERS_EXPORTS
#pragma endregion Коды ошибок

namespace ilr
{	
#pragma pack(1)   // turn byte alignment on

#pragma region Основные типы
	// Модель считывателя
	enum ReaderModel
	{
		rmUnknownModel,		// Неизвестная модель
		rmZ2RDALL,			// Z-2 (мод. RD_ALL) / Z-2 USB
		rmZ2USBMF,			// Z-2 (мод. MF) / Z-2 USB MF
		rmZ2MFI,			// Z-2 (мод. MF-I)
		rmZ2EHR,			// Z-2 (мод. E HTZ RF) / Z-2 EHR
		rmZ2Base,			// Z-1 (мод. N Z) / Z-2 Base
		rmRF1996,			// Z-2 (мод. E HT Hotel) / Z-2 RF-1996
		rmMatrix3RdAll,		// Matrix-III (мод. RD_All)
		rmMatrix3Net,		// Matrix-III (мод. MF K Net) / Matrix-III Net
		rmCPZ2MF,			// CP-Z 2MF
		rmMatrix5,			// Matrix-V (мод. E S RF) / Matrix-V
		rmZ2MfCcid,			// Z-2 (мод. MF CCID)
		rmMatrix6,          // Matrix-VI (мод. NFC K Net)
		rmSize				// Размер списка
	};

	// Тип порта считывателя
	enum PortType
	{
		ptUnknownPort,		// Не известно
		ptComPort,			// Имя последовательного порта (например COM3)
		ptCCID,				// CCID (Smart Cards)
		ptServer,			// Адрес конвертера в режиме "Сервер" (например 10.0.0.2:1000)
		ptClient			// Адрес конвертера в режиме "Клиент"
	};
	// Имя порта считывателя
	typedef WCHAR PortName[32];

	// Тип карты
	enum CardType
	{
		cUnknownCard,		// Не известно
		cEmMarine,			// Em-Marine
		cHID,				// HID
		cICode,				// iCode
		cCod433,			// Cod433
		cCod433Fix,			// Cod433 Fix
		cCame433,			// Радиобрелок CAME
		cDallas,			// Dallas
		cTemic,				// Temic (T5557)

		cMifareUltralight,		// Mifare UltraLight
		cMifareUltralightC,	// Mifare Ultralight C
		cMifareMini,			// Mifare Mini
		cMifareClassic1K,		// Mifare Classic 1K
		cMifareClassic2K,		// Mifare Classic 2K
		cMifareClassic4K,		// Mifare Classic 4K
		cMifarePlus,		// Mifare Plus
		cMifarePlus1K,			// Mifare Plus 1K
		cMifarePlus2K,			// Mifare Plus 2K
		cMifarePlus4K,			// Mifare Plus 4K
		cSmartMXwMf1K,			// Smart MX with Mifare 1K
		cSmartMXwMf4K,			// Smart MX with Mifare 4K
		cMifareDesfire,		// Mifare DESFire
		cMifareProX,		// Mifare ProX
		cCardTypeSize		// Размер списка
	};

	// Флаги типов карт (для авто приостановки сканирования при обнаружении карты)
	enum _RWCARD_TYPE_FLAGS : UINT
	{
		RWCT_F_MFULTRALIGHT = 0x00000001, // Mifare Ultralight
		RWCT_F_MFCLASSIC = 0x00000002, // Mifare Classic
		RWCT_F_MFPPLUS = 0x00000004, // Mifare Plus
		RWCT_F_TEMIC = 0x00000008  // Temic
	};
	typedef DWORD RWCTF;

	// Информация о считывателе
	typedef struct ReaderInfo
	{
		PortType nPortType;		// Тип порта
		PortName szPortName;	// Имя порта
		ReaderModel nModel;		// Модель считывателя
		INT nSn;				// Серийный номер считывателя
		DWORD nFwVersion;		// Версия прошивки считывателя
		INT64 nFwBuildDate;		// Дата и время сборки прошивки
		HRESULT nError;			// Код ошибки, если не удалось получить инфо считывателя

		// Возвращает биты типов карт, UID которых умеет читать считыватель
		DWORD GetIdCardTypes() const
		{
			DWORD res = 0;
			switch (nModel)
			{
			case rmZ2RDALL:
				res |= (1 << cEmMarine) | (1 << cHID) | 
					(1 << cMifareUltralight) | (1 << cMifareUltralightC) |
					(1 << cMifareMini) | (1 << cMifareClassic1K) | 
					(1 << cMifareClassic2K) | (1 << cMifareClassic4K) | 
					(1 << cMifareDesfire) | (1 << cMifareProX);
				if (nFwVersion >= 106)
					res |= (1 << cTemic);
				break;

			case rmZ2USBMF:
			case rmZ2MFI:
			case rmMatrix3Net:
			case rmCPZ2MF:
			case rmZ2MfCcid:
			case rmMatrix6:
				res |= (1 << cMifareUltralight) | (1 << cMifareUltralightC) |
					(1 << cMifareMini) | (1 << cMifareClassic1K) |
					(1 << cMifareClassic2K) | (1 << cMifareClassic4K) |
					(1 << cSmartMXwMf1K) | (1 << cSmartMXwMf4K) |
					(1 << cMifarePlus) | (1 << cMifarePlus1K) | 
					(1 << cMifarePlus2K) | (1 << cMifarePlus4K) | 
					(1 << cMifareDesfire) | (1 << cMifareProX);
				break;

			case rmZ2EHR:
				res |= (1 << cEmMarine) | (1 << cHID) | 
					(1 << cMifareUltralight) | (1 << cMifareUltralightC) |
					(1 << cMifareMini) | (1 << cMifareClassic1K) |
					(1 << cMifareClassic2K) | (1 << cMifareClassic4K) |
					(1 << cMifareDesfire) | (1 << cMifareProX) | (1 << cTemic) | 
					(1 << cDallas) | (1 << cCod433) | (1 << cCod433Fix);
				break;

			case rmRF1996:
				res |= (1 << cEmMarine) | (1 << cTemic);
				break;

			case rmMatrix3RdAll:
				res |= (1 << cEmMarine) | (1 << cHID) | 
					(1 << cMifareUltralight) | (1 << cMifareUltralightC) |
					(1 << cMifareMini) | (1 << cMifareClassic1K) |
					(1 << cMifareClassic2K) | (1 << cMifareClassic4K) |
					(1 << cMifareDesfire) | (1 << cMifareProX);
				break;

			case rmMatrix5:
				res |= (1 << cEmMarine) | (1 << cCame433) | (1 << cCod433) | 
					(1 << cCod433Fix);
				break;
			}
			return res;
		}
		// Возвращает типы карт, данные которых умеет читать/писать считыватель
		RWCTF CanRWCardTypes() const
		{
			RWCTF res = 0;
			switch (nModel)
			{
			case rmZ2RDALL:
				res |= RWCT_F_MFULTRALIGHT;
				if (nFwVersion >= 106)
					res |= RWCT_F_TEMIC;
				break;

			case rmZ2EHR:
				res |= RWCT_F_TEMIC;
				break;

			case rmMatrix3RdAll:
				res |= RWCT_F_MFULTRALIGHT;
				break;

			case rmZ2USBMF:
			case rmMatrix3Net:
			case rmCPZ2MF:
			case rmZ2MfCcid:
				res |= RWCT_F_MFULTRALIGHT | RWCT_F_MFCLASSIC;
				break;

			case rmZ2MFI:
			case rmMatrix6:
				res |= RWCT_F_MFULTRALIGHT | RWCT_F_MFCLASSIC | RWCT_F_MFPPLUS;
				break;
			}
			return res;
		}
	} *PReaderInfo;

	// Уровень лога
	enum LogLevel
	{
		llDisabled,		// Лог выключен
		llAssert,		// Неожиданные ошибки, которых быть не должно
		llError,		// Ошибки
		llWarning,		// Предупреждения. Показывает возможные проблемы, которые не являются ошибками
		llInfo,			// Уведомления. Показывает полезную информацию, в основном успехи
		llDebug,		// Отладочные сообщения. Показвает шаги программы, получаемые и отправляемые данные
		llVerbose,		// Подробные отладочные сообщения. Показывает каждую мелочь
		llSize			// Размер списка
	};
#pragma endregion Основные типы

#pragma region Поиск считывателей
	// Возвращает True когда нужно исключить порт из списка найденных портов
	typedef BOOL(CALLBACK* FilterPortProc)(PortType nPortType, LPCWSTR pszPortName, 
		void *pUserData);

	// Сообщение поиска считывателей (IILRSearch)
	enum SearchMsg
	{
		smAsyncCmdFinish,	// Завершилась асинхронная команда, созданная IILRSearchAsync
		smReaderFound,		// Считыватель найден, параметр PReaderInfo
		smReaderLost,		// Считыватель потерян, параметр PReaderInfo
		smListChanged		// Список считывателей изменён
	};

	// Тип функции для получения сообщений от IILRSearch
	typedef void(CALLBACK* SearchNotifyProc)(SearchMsg nMsg, LPCVOID pMsgData, void *pUserData);

	// Флаги типов считывателей
	enum _READER_TYPE_FLAGS : UINT
	{
		RT_F_ILUSB = 0x00000001,	// USB считыватели Ironlogic
		RT_F_TPUSB = 0x00000002,	// USB считыватели сторонних производителей
		RT_F_CCID = 0x00000004,		// Считыватели SmartCards
		RT_F_SERVER = 0x00000008,	// IP конвертеры в режиме "Сервер" (поиск по UDP)
		RT_F_CLIENT = 0x00000010	// IP конвертеры в режиме "Клиент" (прослушка TCP)
	};
	typedef DWORD RDTYPEF;
#pragma endregion Поиск считывателей

#pragma region Подключение к считывателю
	// Сообщение считывателя (IILReader)
	enum ReaderMsg
	{
		rmAsyncCmdFinish,	// Завершилась асинхронная команда, созданная IILReaderAsync
		rmConnectionChanged,// Изменилось состояние подключения к считывателю
		rmCardFound,		// Карта найдена, параметр PCardInfo
		rmCardLost			// Карта потеряна, параметр PCardInfo
	};

	// Тип функции для получения сообщений от IILReader
	typedef void(CALLBACK* ReaderNotifyProc)(ReaderMsg nMsg, LPCVOID pMsgData, void *pUserData);

	// Состояние подключения к считывателю
	enum ConnectionStatus
	{
		csDisconnected,	// Отключён
		csConnected,	// Подключён
		csConnecting	// Подключение
	};

	// ID карты
	typedef struct CardUID
	{
		INT8 nLength;		// Длина номера в байтах
		BYTE aBytes[15];	// Байты номера

		CardUID() ILR_NOEXCEPT
		{
		}
		CardUID(const CardUID &rUID) ILR_NOEXCEPT
		{
			nLength = rUID.nLength;
			memcpy(aBytes, rUID.aBytes, sizeof(aBytes));
		}
		CardUID(LPCVOID pData, size_t nSize) ILR_NOEXCEPT
		{
			Assign(pData, nSize);
		}
		void Clear() ILR_NOEXCEPT
		{
			memset(this, 0, sizeof(*this));
		}
		bool IsEmpty() const ILR_NOEXCEPT
		{
			return (0 == nLength);
		}
		void Assign(LPCVOID pData, size_t nSize) ILR_NOEXCEPT
		{
			//nLength = (INT8)min(nSize, sizeof(aBytes));
			if (nSize > sizeof(aBytes))
				nSize = sizeof(aBytes);
			nLength = (INT8)nSize;
			if (nLength != 0)
				memcpy(aBytes, pData, nLength);
		}
		int Compare(const CardUID &rUID) const ILR_NOEXCEPT
		{
			int n = (nLength - rUID.nLength);
			if (0 == n)
				n = memcmp(aBytes, rUID.aBytes, nLength);
			return n;
		}
		bool operator==(const CardUID &rUID) const ILR_NOEXCEPT
		{
			return (nLength == rUID.nLength) && (memcmp(aBytes, rUID.aBytes, nLength) == 0);
		}
		bool operator!=(const CardUID &rUID) const ILR_NOEXCEPT
		{
			return (nLength != rUID.nLength) || (memcmp(aBytes, rUID.aBytes, nLength) != 0);
		}
		bool operator>(const CardUID &rUID) const ILR_NOEXCEPT
		{
			return Compare(rUID) > 0;
		}
		bool operator>=(const CardUID &rUID) const ILR_NOEXCEPT
		{
			return Compare(rUID) >= 0;
		}
		bool operator<(const CardUID &rUID) const ILR_NOEXCEPT
		{
			return Compare(rUID) < 0;
		}
		bool operator<=(const CardUID &rUID) const ILR_NOEXCEPT
		{
			return Compare(rUID) <= 0;
		}
	}*PCardUID;

	// Уровнь безопасности Mifare Plus
	enum MfPlusSL : INT8
	{
		mpslUnknown = -1,	// Не известно
		mpslSL0,			// Уровень 0 (не инициализирована)
		mpslSL1,			// Уровень 1 (эмуляция Mifare Classic)
		mpslSL2,			// Уровень 2
		mpslSL3				// Уровень 3
	};

	// Тип Mifare Plus
	enum MfPlusType : BYTE
	{
		mptUnknown,			// Не известно
		mptS,				// Mifare Plus S
		mptX,				// Mifare Plus X
		mptSE,				// MIFARE Plus SE
		mptEV1,				// MIFARE Plus EV1
		mptEV2,				// MIFARE Plus EV2
		mptSize				// Размер списка
	};

	// Информация о карте
	typedef struct CardInfo
	{
		CardType nType;		// Тип карты
		CardUID rUID;		// Номер карты
		UINT nMemSize;		// Размер памяти карты (в байтах)
		MfPlusSL nSL;		// Уровнь безопасности Mifare Plus
		MfPlusType nMpType;	// Тип Mifare Plus
		CardType nType2;	// Тип карты
		CardUID rUID2;		// Номер карты

		void Clear()
		{
			memset(this, 0, sizeof(*this));
			nSL = mpslUnknown;
		}
		// Возвращает True если карта является Mifare Classic
		bool IsMfClassic() const
		{
			return (nType >= cMifareMini) && (nType <= cMifareClassic4K);
		}
		// Возвращает True если карта является Mifare Plus
		bool IsMfPlus() const
		{
			return (nType >= cMifarePlus) && (nType <= cSmartMXwMf4K);
		}
		// Возвращает True если карта является Mifare Classic или Mifare Plus SL1
		bool IsMfClassicMode() const
		{
			return IsMfClassic() || (IsMfPlus() && (mpslSL1 == nSL));
		}
		// Возвращает True если карта является Mifare Plus SL3
		bool IsMfPlusSL3Mode() const
		{
			return IsMfPlus() && (mpslSL3 == nSL);
		}
		// Возвращает количество блоков карты Mifare Classic/Plus
		int GetNumberOfMfBlocks() const
		{
			return nMemSize / 16;
		}
	}*PCardInfo;

	// Ключ аутентификации Mifare Classic
	typedef INT64 MfClassicKey;

	// Ключ аутентификации Mifare Plus
	typedef struct MfPlusKey
	{
		BYTE a[16];

		// Устанавливает значение ключа по умолчанию
		void SetDefault()
		{
			memset(a, 0xff, sizeof(a));
		}
	}*PMfPlusKey;

	// Данные блока Mifare Classic/Plus
	typedef struct MfBlockData
	{
		BYTE a[16];
	}*PMfBlockData;
#pragma endregion Подключение к считывателю

#pragma pack() // turn byte alignment off

#pragma region Интерфейсы
	//////////////////////////////////////////////////////////////////////////
	// IILRSearch - поиск RFID-считывателей

	// {6EAE522E-11FB-42AF-972A-726938CB68DB}
	DEFINE_GUID(IID_IILRSearch,
		0x6eae522e, 0x11fb, 0x42af, 0x97, 0x2a, 0x72, 0x69, 0x38, 0xcb, 0x68, 0xdb);
	DECLARE_INTERFACE_(IILRSearch, IUnknown)
	{
		// Устанавливает функцию обратного вызова для уведомлений
		STDMETHOD(SetNotifyCallback)(SearchNotifyProc pCallback, void *pUserData) PURE;
		// Вкл/выкл очередь сообщений (для синхронизации)
		STDMETHOD(EnableMsgQueue)(BOOL fEnable = TRUE) PURE;
		// Извлекает следующее сообщение из очереди
		STDMETHOD(GetMessage)(SearchMsg *pMsg, LPCVOID *pMsgData, BOOL *pFound) PURE;
		// Устанавливает типы считывателей, которые нужно искать
		STDMETHOD(SetReaderTypes)(RDTYPEF nTypes) PURE;
		// Возвращает типы считывателей, которые нужно искать
		STDMETHOD(GetReaderTypes)(RDTYPEF *pTypes) PURE;
		// Устанавливает период опроса IP конвертеров по UDP в миллисекундах
		//	(поиск конвертеров в режиме "Сервер")
		STDMETHOD(SetUdpScanPeriod)(DWORD nMs) PURE;
		// Возвращает период опроса IP конвертеров по UDP в миллисекундах
		STDMETHOD(GetUdpScanPeriod)(DWORD* pMs) PURE;
		// Устанавливает тайм-аут запроса по UDP
		STDMETHOD(SetUdpRequestTimeout)(DWORD nMs) PURE;
		// Возвращает тайм-аут запроса по UDP в миллисекундах
		STDMETHOD(GetUdpRequestTimeout)(DWORD* pMs) PURE;
		// Устанавливает количество попыток запроса по UDP (поиск IP конвертеров)
		STDMETHOD(SetUdpRequestAttempts)(INT nAttempts) PURE;
		// Возвращает количество попыток запроса по UDP
		STDMETHOD(GetUdpRequestAttempts)(INT* pAttempts) PURE;
		// Устанавливает IP адреса конвертеров для опроса по UDP, которые не находятся автоматически
		// pszAddress список адресов, разделённых символом ';'
		STDMETHOD(SetUdpCvtAddresses)(LPCWSTR pszAddresses) PURE;
		// Возвращает IP адреса конвертеров для опроса по UDP
		STDMETHOD(GetUdpCvtAddresses)(OUT BSTR * pAddresses) PURE;
		// Устанавливает список TCP-портов для прослушки конвертеров к режиме "Клиент"
		STDMETHOD(SetListenTcpPorts)(const WORD* pPorts, INT nCount) PURE;
		// Возвращает список TCP-портов для прослушки конвертеров к режиме "Клиент"
		STDMETHOD(GetListenTcpPorts)(WORD* pBuf, INT nCount, INT* pRCount) PURE;
		// Устанавливает период между попытками открыть TCP порт для прослушки Клиентов
		STDMETHOD(SetOpenListenerPeriod)(DWORD nMs) PURE;
		// Ищет считыватели
		STDMETHOD(Scan)(BOOL fReset = FALSE) PURE;
		// Возвращает количество найденных считывателей
		STDMETHOD(GetReaderCount)(INT *pCount) PURE;
		// Возвращает инфо о найденном считывателе
		STDMETHOD(GetReaderInfo)(INT nIdx, ReaderInfo *pInfo) PURE;
		// Вкл/выкл режим авто поиска считывателей
		STDMETHOD(EnableAutoScan)(BOOL fEnable = TRUE, BOOL fWait = TRUE) PURE;
		// Возвращает True если авто поиск включен
		STDMETHOD(GetAutoScanEnabled)(BOOL *pEnabled) PURE;
		// Открывает порт и возвращает дескриптор порта
		STDMETHOD(OpenPort)(PortType nPortType, LPCTSTR pszPortName,
			ReaderInfo* pInfo, HANDLE* pPort) PURE;
		// Закрывает порт
		STDMETHOD(ClosePort)(PortType nPortType, LPCTSTR pszPortName,
			HANDLE hPort) PURE;
	};

	//////////////////////////////////////////////////////////////////////////
	// IILReader - работа со RFID-считывателем

	// {C435D1AB-A1AC-455D-A1D9-0C53F5F21417}
	DEFINE_GUID(IID_IILReader,
		0xc435d1ab, 0xa1ac, 0x455d, 0xa1, 0xd9, 0xc, 0x53, 0xf5, 0xf2, 0x14, 0x17);
	DECLARE_INTERFACE_(IILReader, IUnknown)
	{
		// Устанавливает функцию обратного вызова для уведомлений
		STDMETHOD(SetNotifyCallback)(ReaderNotifyProc pCallback, void *pUserData) PURE;
		// Вкл/выкл очередь сообщений (для синхронизации)
		STDMETHOD(EnableMsgQueue)(BOOL fEnable = TRUE) PURE;
		// Извлекает следующее сообщение из очереди
		STDMETHOD(GetMessage)(ReaderMsg *pMsg, LPCVOID *pMsgData, BOOL *pFound) PURE;
		// Устанавливает модель для подключения
		STDMETHOD(SetModelToConnect)(ReaderModel nModel) PURE;
		// Возвращает модель для подключения
		STDMETHOD(GetModelToConnect)(ReaderModel* pModel) PURE;
		// Подключается к считывателю
		STDMETHOD(Connect)(BOOL fReconnect = FALSE) PURE;
		// Отключается от считывателя
		STDMETHOD(Disconnect)() PURE;
		// Возвращает состояние подключения к считывателю
		STDMETHOD(GetConnectionStatus)(ConnectionStatus *pStatus) PURE;
		// Возвращает информацию о считывателе
		STDMETHOD(GetReaderInfo)(ReaderInfo *pInfo) PURE;
		// Ищет карту в поле считывателя
		//	fPowerOff =True, выключает RF поле после сканирования
		STDMETHOD(Scan)(BOOL fReset = FALSE, BOOL fPowerOff = TRUE) PURE;
		// Возвращает информацию о карте в поле считывателя
		STDMETHOD(GetCardInfo)(CardInfo *pInfo) PURE;
		// Вкл/выкл автоматическое сканирование карт
		//	fWait =True ждать завершение команды
		STDMETHOD(EnableAutoScan)(BOOL fEnable = TRUE, BOOL fWait = TRUE) PURE;
		// Возвращает True если авто сканирование включено
		STDMETHOD(GetAutoScanEnabled)(BOOL *pEnabled) PURE;
		// Устанавливает типы карт, при обнаружении которых сканирование приостанавливается
		//	Чтобы возобновить сканирование карт нужно вызвать EnableAutoScan(TRUE)
		STDMETHOD(SetHoldCardTypes)(RWCTF nTypes) PURE;
		// Возвращает типы карт, при обнаружении которых автоматически 
		// приостанавливается сканирование.
		STDMETHOD(GetHoldCardTypes)(RWCTF* pTypes) PURE;

#pragma region Карта Mifare Ultralight
		// Читает данные карты Mifare Ultralight
		STDMETHOD(ReadMfUlralight)(INT nPageIdx, DWORD *pBuf, INT nPageCount, 
			INT *pRead = NULL) PURE;
		// Пишет данные карты Mifare Ultralight
		STDMETHOD(WriteMfUlralight)(INT nPageIdx, const DWORD *pData, INT nPageCount,
			INT *pWritten = NULL) PURE;
#pragma endregion

#pragma region Карта Mifare Classic/Plus
		// Загружает ключ для авторизации сектора Mifare Classic / Plus SL1
		STDMETHOD(LoadMfAuthKey)(const MfClassicKey nKey) PURE;
		// Загружает ключ для авторизации сектора Mifare Plus SL3
		STDMETHOD(LoadMfPlusAuthKey)(const MfPlusKey &rKey) PURE;
		// Авторизует сектор карты Mifare Classic / Plus, используя ключ, загруженный 
		// функцией LoadMfAuthKey / LoadMfPlusAuthKey
		//	nAddress номер блока или адрес Mifare Plus, 
		//	fKeyB =True по ключу B, иначе A, 
		// Возвращает pAuthOk =True, авторизация удалась
		STDMETHOD(AuthMfCard)(UINT nAddress, BOOL fKeyB, BOOL *pAuthOk) PURE;
		// Авторизует сектор карты Mifare Classic / Plus, используя ключи считывателя
		//	nAddress номер блока или адрес Mifare Plus, 
		//	fKeyB =True по ключу B, иначе A, 
		//	pRdKeyIdx позиция найденного ключа в памяти считывателя, =-1 ключ не найден
		STDMETHOD(AuthMfCardByRdKeys)(UINT nAddress, BOOL fKeyB, DWORD nRdKeys = 0xFFFF,
			INT *pRdKeyIdx = NULL) PURE;
		// Читает данные карты Mifare Classic или Mifare Plus SL1
		STDMETHOD(ReadMfClassic)(INT nBlockIdx, MfBlockData *pBuf, INT nBlockCount,
			INT *pRead = NULL) PURE;
		// Пишет данные карты Mifare Classic или Mifare Plus SL1
		STDMETHOD(WriteMfClassic)(INT nBlockIdx, const MfBlockData *pData, INT nBlockCount,
			INT *pWritten = NULL) PURE;
		// Читает данные карты Mifare Plus SL3
		//	nBlockCount количество блоков, которые нужно прочитать
		//	pRead количество прочитанных блоков
		STDMETHOD(ReadMfPlus)(UINT nAddress, MfBlockData *pBuf, INT nBlockCount, 
			BOOL fOpenText = TRUE, INT *pRead = NULL) PURE;
		// Пишет данные карты Mifare Plus SL3
		STDMETHOD(WriteMfPlus)(UINT nAddress, const MfBlockData *pData, INT nBlockCount, 
			BOOL fOpenText = TRUE, INT *pWritten = NULL) PURE;
		// Увеличивает содержимое блока-значения карты Mifare и сохраняет результат во временном 
		//	регистре данных
		STDMETHOD(MfIncrement)(INT nBlockIdx, DWORD nValue) PURE;
		// Уменьшает содержимое блока-значения карты Mifare и сохраняет результат во временном 
		//	регистре данных
		STDMETHOD(MfDecrement)(INT nBlockIdx, DWORD nValue) PURE;
		// Записывает содержимое во временном регистре данных в блок-значение
		STDMETHOD(MfTransfer)(INT nBlockIdx) PURE;
		// Перемещает содержимое блока в регист данных Mifare
		STDMETHOD(MfRestore)(INT nBlockIdx) PURE;
		// Выключает RF поле считывателя (после выключения нужно подождать 10 мс)
		STDMETHOD(MfPowerOff)() PURE;
		// R+A+S(Request+Anticollision+Select)
		STDMETHOD(MfRAS)(BOOL fWakeUp, BYTE *pSAK, WORD *pATQ, CardUID *pUID, 
			BOOL* pFound) PURE;
		// R+R(Request+Reselect(по известному номеру))
		STDMETHOD(MfRR)(BOOL fWakeUp, const CardUID& rUID, BOOL* pFound) PURE;
		// Halt
		STDMETHOD(MfHalt)() PURE;
		// Переходит на ISO 14443-4
		STDMETHOD(MfRATS)(BYTE *pAtsBuf = NULL, DWORD nBufSize = 0, DWORD *pRequiredSize = NULL) PURE;
		// Записывает ключи AES и всех блоков
		STDMETHOD(MfWritePerso)(UINT nAddress, const MfPlusKey &rKey) PURE;
		// Переключает Mifare Plus в SL1 или SL3(если SL1 нет)
		STDMETHOD(MfCommitPerso)() PURE;
		// Записывает ключи аутентификации Mifare Classic в память считывателя
		STDMETHOD(WriteMfAuthKeyToReader)(INT nIdx, BOOL fKeyB, const MfClassicKey *pKeys, INT nCount, 
			INT *pWritten = NULL) PURE;
		// Записывает ключи аутентификации Mifare Plus в память считывателя
		STDMETHOD(WriteMfPlusAuthKeyToReader)(INT nIdx, BOOL fKeyB, const MfPlusKey *pKeys, 
			INT nCount, INT *pWritten = NULL) PURE;
#pragma endregion

#pragma region Карта Temic
		// Загружает пароль Temic в память объекта считывателя
		STDMETHOD(LoadTemicPassword)(const INT64 nPassword) PURE;
		// Ищет карту Temic в поле считывателя
		STDMETHOD(ScanTemic)(INT nScanParam = -1) PURE;
		// Вкл/выкл сканирование карт Temic (для Z-2 Rd-All и Z-2 EHR)
		STDMETHOD(EnableAutoScanTemic)(BOOL fEnable = TRUE) PURE;
		// Возвращает True если авто сканирование Temic включено
		STDMETHOD(GetAutoScanTemicEnabled)(BOOL* pEnable) PURE;
		// Читает данные карты Temic
		STDMETHOD(ReadTemic)(INT nBlockIdx, DWORD *pBuf, INT nBlockCount, 
			INT nScanParam = -1, INT *pRead = NULL) PURE;
		// Пишет данные карты Temic
		STDMETHOD(WriteTemic)(INT nBlockIdx, const DWORD *pData, INT nBlockCount, 
			BOOL fLock = FALSE, INT nScanParam = -1, INT *pWritten = NULL) PURE;
		// Сброс TRES
		STDMETHOD(ResetTemic)(BOOL fWait = TRUE) PURE;
		// Кодирует данные для эмуляции Em-Marine, для записи в блоки 0..2
		STDMETHOD(EncodeTemicEmMarine)(const CardUID &rUID, DWORD *pBuf3, INT nBlockCount) PURE;
		// Декодирует номер Em-Marine из данных блоков 0..2 карты Temic
		STDMETHOD(DecodeTemicEmMarine)(const DWORD *pData3, INT nBlockCount, 
			CardUID *pUID, BOOL *pConfigOk = NULL) PURE;
		// Кодирует данные для эмуляции HID, для записи в блоки 0..3
		STDMETHOD(EncodeTemicHID)(const CardUID &rUID, DWORD *pBuf4, INT nBlockCount, INT nWiegand) PURE;
		// Декодирует номер HID из данных блоков 0..3 карты Temic
		STDMETHOD(DecodeTemicHID)(const DWORD *pData4, INT nBlockCount, CardUID *pUID, 
			INT *pWiegand, BOOL *pConfigOk = NULL) PURE;
#pragma endregion
	};

	//////////////////////////////////////////////////////////////////////////
	// IILR - главный интерфейс SDK Readers

	// {B5FDDC67-9CAE-49F1-84D0-0594D2D3B003}
	DEFINE_GUID(IID_IILR,
		0xb5fddc67, 0x9cae, 0x49f1, 0x84, 0xd0, 0x5, 0x94, 0xd2, 0xd3, 0xb0, 0x3);
	DECLARE_INTERFACE_(IILR, IUnknown)
	{
		// Устанавливает функцию обратного вызова для исключения портов
		STDMETHOD(SetFilterPortCallback)(FilterPortProc pCallback, void *pUserData) PURE;
		// Устанавливает путь к файлу лога отладки
		STDMETHOD(SetLogPath)(LPCWSTR pszPath) PURE;
		// Возвращает путь к файлу лога отладки
		STDMETHOD(GetLogPath)(OUT BSTR *pPath) PURE;
		// Устанавливает уровень лога отладки
		STDMETHOD(SetLogLevel)(LogLevel nLevel) PURE;
		// Возвращает уровень лога отладки
		STDMETHOD(GetLogLevel)(LogLevel *pLevel) PURE;
		// Очищает лог отладки
		STDMETHOD(ClearLog)() PURE;
		// Устанавливает количество стоповых бит для COM-порта
		STDMETHOD(SetStopBits)(BYTE nStopBits) PURE;
		// Возвращает количество стоповых бит для COM-порта
		STDMETHOD(GetStopBits)(BYTE* pStopBits) PURE;
		// Устанавливает тайм-аут запроса
		STDMETHOD(SetRequestTimeout)(DWORD nMs) PURE;
		// Возвращает тайм-аут запроса
		STDMETHOD(GetRequestTimeout)(DWORD* pMs) PURE;
		// Устанавливает количество попыток запроса
		STDMETHOD(SetRequestAttempts)(INT nAttempts) PURE;		
		// Возвращает количество попыток запроса
		STDMETHOD(GetRequestAttempts)(INT* pAttempts) PURE;

		// Возвращает интерфейс поиска считывателей
		STDMETHOD(GetSearch)(IILRSearch **ppObj) PURE;
		// Возвращает интерфейс подключения к считывателю
		STDMETHOD(GetReader)(PortType nPortType, LPCWSTR pszPortName, IILReader **ppObj) PURE;
	};
#pragma endregion

#pragma region Интерфейсы для асинхронного режима
	// {D82E158B-7B9D-46AC-B3F8-0D1D97422FF4}
	DEFINE_GUID(IID_IILRAsyncCommand,
		0xd82e158b, 0x7b9d, 0x46ac, 0xb3, 0xf8, 0xd, 0x1d, 0x97, 0x42, 0x2f, 0xf4);
	DECLARE_INTERFACE_(IILRAsyncCommand, IUnknown)
	{
		// Отменяет команду. Устанавливает статус E_ABORT
		STDMETHOD(Cancel)() PURE;
		// Возвращает состояние команды
		//	pStatus =E_PENDING команда ещё выполняется, иначе - завершена
		STDMETHOD(GetStatus)(HRESULT *pStatus) PURE;
		// Возвращает состояние прогресса выполнения команды
		STDMETHOD(GetProgress)(INT *pCurrent, INT *pTotal) PURE;
	};

	// {C61BA823-D1AC-459E-B483-5A5F6CFAA446}
	DEFINE_GUID(IID_IILRSearchAsync,
		0xc61ba823, 0xd1ac, 0x459e, 0xb4, 0x83, 0x5a, 0x5f, 0x6c, 0xfa, 0xa4, 0x46);
	DECLARE_INTERFACE_(IILRSearchAsync, IUnknown)
	{
		// Запускает асинхронную команду поиска считывателей
		STDMETHOD(Begin_Scan)(BOOL fReset, IILRAsyncCommand **ppCmd) PURE;
		// Запускает асинхронную команду вкл/выкл режим авто поиска считывателей
		STDMETHOD(Begin_EnableAutoScan)(BOOL fEnable, IILRAsyncCommand **ppCmd) PURE;
		// Запускает асинхронную команду открытия порта
		STDMETHOD(Begin_OpenPort)(PortType nPortType, LPCTSTR pszPortName,
			IILRAsyncCommand** ppCmd) PURE;
		// Возвращает результат открытия порта
		STDMETHOD(End_OpenPort)(IILRAsyncCommand* pCmd, HANDLE* pPort,
			ReaderInfo* pInfo) PURE;
		// Запускает асинхронную команду закрытия порта
		STDMETHOD(Begin_ClosePort)(PortType nPortType, LPCTSTR pszPortName,
			HANDLE hPort, IILRAsyncCommand** ppCmd) PURE;
	};

	// {83938709-8E3B-4581-82EE-C5163DA2FAF8}
	DEFINE_GUID(IID_IILReaderAsync,
		0x83938709, 0x8e3b, 0x4581, 0x82, 0xee, 0xc5, 0x16, 0x3d, 0xa2, 0xfa, 0xf8);
	DECLARE_INTERFACE_(IILReaderAsync, IUnknown)
	{
		// Запускает асинхронную команду подключения к считывателю
		STDMETHOD(Begin_Connect)(BOOL fReconnect /*= FALSE*/, IILRAsyncCommand **ppCmd) PURE;
		// Запускает асинхронную команду отключения от считывателя
		STDMETHOD(Begin_Disconnect)(IILRAsyncCommand **ppCmd) PURE;
		// Запускает асинхронную команду поиска карты
		//	fPowerOff =True, выключает RF поле после сканирования
		STDMETHOD(Begin_Scan)(BOOL fReset /*= FALSE*/, BOOL fPowerOff /*= TRUE*/, IILRAsyncCommand **ppCmd) PURE;
		// Запускает асинхронную команду вкл/выкл автоматического сканирования карт
		STDMETHOD(Begin_EnableAutoScan)(BOOL fEnable /*= TRUE*/, IILRAsyncCommand **ppCmd) PURE;

#pragma region Карта Mifare Ultralight
		// Запускает асинхронную команду чтения данных из карты Mifare Ultralight
		STDMETHOD(Begin_ReadMfUlralight)(INT nPageIdx, INT nPageCount, IILRAsyncCommand **ppCmd) PURE;
		// Возвращает результат чтения данных из карты Mifare Ultralight
		STDMETHOD(End_ReadMfUlralight)(IILRAsyncCommand *pCmd, DWORD *pBuf, INT nBufSize, INT *pRead) PURE;
		// Запускает асинхронную команду записи данных в карту Mifare Ultralight
		STDMETHOD(Begin_WriteMfUlralight)(INT nPageIdx, const DWORD *pData, INT nPageCount, IILRAsyncCommand **ppCmd) PURE;
		// Возвращает результат записи данных в карту Mifare Ultralight
		//	pWritten количество прочитанных страниц
		STDMETHOD(End_WriteMfUlralight)(IILRAsyncCommand *pCmd, INT *pWritten) PURE;
#pragma endregion

#pragma region Карта Mifare Classic/Plus
		// Запускает асинхронную команду авторизации сектора карты Mifare Classic / Plus
		// используя ключ, загруженный функцией LoadMfAuthKey / LoadMfPlusAuthKey
		//	nAddress номер блока или адрес Mifare Plus, 
		//	fKeyB =True по ключу B, иначе A, 
		STDMETHOD(Begin_AuthMfCard)(UINT nAddress, BOOL fKeyB, IILRAsyncCommand **ppCmd) PURE;
		// Возвращает результат авторизации сектора карты
		//	pAuthOk =True, авторизация прошла успешно
		STDMETHOD(End_AuthMfCard)(IILRAsyncCommand *pCmd, BOOL *pAuthOk) PURE;
		// Запускает асинхронную команду авторизации сектора карты Mifare Classic / Plus
		// используя ключи в памяти считывателя
		//	nAddress номер блока или адрес Mifare Plus, 
		//	fKeyB =True по ключу B, иначе A
		STDMETHOD(Begin_AuthMfCardByRdKeys)(UINT nAddress, BOOL fKeyB, DWORD nRdKeys /*= 0xFFFF*/,
			IILRAsyncCommand **ppCmd) PURE;
		// Возвращает результат авторизации сектора карты
		//	pKeyIdx позиция найденного ключа в памяти считывателя, =-1 ключ не найден
		STDMETHOD(End_AuthMfCardByRdKeys)(IILRAsyncCommand *pCmd, INT *pKeyIdx) PURE;

		// Запускает асинхронную команду чтения данных из карты Mifare Classic или Mifare Plus SL1
		STDMETHOD(Begin_ReadMfClassic)(INT nBlockIdx, INT nBlockCount, IILRAsyncCommand **ppCmd) PURE;
		// Возвращает результат чтения данных из карты Mifare Classic или Mifare Plus SL1
		//	pRead количество прочитанных блоков
		STDMETHOD(End_ReadMfClassic)(IILRAsyncCommand *pCmd, MfBlockData *pBuf, INT nBufSize, 
			INT *pRead) PURE;
		// Запускает асинхронную команду записи данных в карту Mifare Classic или Mifare Plus SL1
		STDMETHOD(Begin_WriteMfClassic)(INT nBlockIdx, const MfBlockData *pData, INT nBlockCount, 
			IILRAsyncCommand **ppCmd) PURE;
		// Возвращает результат записи данных в карту Mifare Classic или Mifare Plus SL1
		//	pWritten количество записанных блоков
		STDMETHOD(End_WriteMfClassic)(IILRAsyncCommand *pCmd, INT *pWritten) PURE;
		// Запускает асинхронную команду чтения данных из карты Mifare Plus SL3
		//	nBlockCount количество блоков, которые нужно прочитать
		STDMETHOD(Begin_ReadMfPlus)(UINT nAddress, INT nBlockCount, BOOL fOpenText,
			IILRAsyncCommand **ppCmd) PURE;
		// Возвращает результат чтения данных из карты Mifare Plus SL3
		//	pRead количество прочитанных блоков
		STDMETHOD(End_ReadMfPlus)(IILRAsyncCommand *pCmd, MfBlockData *pBuf, INT nBufSize, 
			INT *pRead) PURE;
		// Запускает асинхронную команду записи данных в карту Mifare Plus SL3
		STDMETHOD(Begin_WriteMfPlus)(UINT nAddress, const MfBlockData *pData, INT nBlockCount, 
			BOOL fOpenText, IILRAsyncCommand **ppCmd) PURE;
		// Возвращает результат записи данных в карту Mifare Plus SL3
		//	pWritten количество записанных блоков
		STDMETHOD(End_WriteMfPlus)(IILRAsyncCommand *pCmd, INT *pWritten) PURE;
		// Увеличивает содержимое блока-значения карты Mifare и сохраняет результат во временном 
		//	регистре данных
		STDMETHOD(Begin_MfIncrement)(INT nBlockIdx, DWORD nValue,
			IILRAsyncCommand **ppCmd) PURE;
		// Уменьшает содержимое блока-значения карты Mifare и сохраняет результат во временном 
		//	регистре данных
		STDMETHOD(Begin_MfDecrement)(INT nBlockIdx, DWORD nValue,
			IILRAsyncCommand **ppCmd) PURE;
		// Записывает содержимое во временном регистре данных в блок-значение
		STDMETHOD(Begin_MfTransfer)(INT nBlockIdx, IILRAsyncCommand **ppCmd) PURE;
		// Перемещает содержимое блока в регист данных Mifare
		STDMETHOD(Begin_MfRestore)(INT nBlockIdx, IILRAsyncCommand **ppCmd) PURE;
		// Запускает асинхронную команду записи ключей аутентификации Mifare Classic в память считывателя
		STDMETHOD(Begin_WriteMfAuthKeyToReader)(INT nIdx, BOOL fKeyB, const MfClassicKey *pKeys, 
			INT nCount, IILRAsyncCommand **ppCmd) PURE;
		// Возвращает результат записи ключей аутентификации Mifare Classic в память считывателя
		//	pWritten количество записанных ключей
		STDMETHOD(End_WriteMfAuthKeyToReader)(IILRAsyncCommand *pCmd, INT *pWritten) PURE;
		// Запускает асинхронную команду записи ключей аутентификации Mifare Plus в память считывателя
		STDMETHOD(Begin_WriteMfPlusAuthKeyToReader)(INT nIdx, BOOL fKeyB, const MfPlusKey *pKeys, 
			INT nCount, IILRAsyncCommand **ppCmd) PURE;
		// Возвращает результат записи ключей аутентификации Mifare Plus в память считывателя
		//	pWritten количество записанных ключей
		STDMETHOD(End_WriteMfPlusAuthKeyToReader)(IILRAsyncCommand *pCmd, INT *pWritten) PURE;
#pragma endregion

#pragma region Карта Temic
		// Запускает асинхронную команду поиска карты Temic в поле считывателя
		STDMETHOD(Begin_ScanTemic)(INT nScanParam /*= -1*/, IILRAsyncCommand **ppCmd) PURE;
		// Запускает асинхронную команду чтения данных из карты Temic
		STDMETHOD(Begin_ReadTemic)(INT nBlockIdx, INT nBlockCount, INT nScanParam, 
			IILRAsyncCommand **ppCmd) PURE;
		// Возвращает результат чтения данных из карты Temic
		//	pRead количество прочитанных блоков
		STDMETHOD(End_ReadTemic)(IILRAsyncCommand *pCmd, DWORD *pBuf, INT nBufSize, INT *pRead) PURE;
		// Запускает асинхронную команду записи данных в карту Temic
		STDMETHOD(Begin_WriteTemic)(INT nBlockIdx, const DWORD *pData, INT nBlockCount,
			BOOL fLock, INT nScanParam, IILRAsyncCommand **ppCmd) PURE;
		// Возвращает результат записи данных в карту Temic
		//	pWritten количество записанных блоков
		STDMETHOD(End_WriteTemic)(IILRAsyncCommand *pCmd, INT *pWritten) PURE;
		// Запускает асинхронную команду сброса TRES
		STDMETHOD(Begin_ResetTemic)(IILRAsyncCommand **ppCmd) PURE;
#pragma endregion
	};
#pragma endregion

#ifndef ILREADERS_LINKONREQUEST
	// Возвращает номер версии библиотеки ILReaders.dll
	ILREADERS_API(DWORD) ILR_GetVersion();
	// Возвращает описание ошибки по её коду. Для освобождения памяти используйте SysFreeString(pText)
	ILREADERS_API(HRESULT) ILR_GetErrorText(HRESULT nErrorCode, OUT BSTR *pText);
	// Возвращает главный интерфейс библиотеки. Эта функция не потокобезопасная
	ILREADERS_API(HRESULT) ILR_GetInterface(IILR **ppObj, DWORD nVersionRequested = ILR_SDK_VERSION);

#else

	extern "C"
	{
		// Общие функции библиотеки
		typedef DWORD(__stdcall* ILR_GETVERSION)();
		typedef HRESULT(__stdcall* ILR_GETERRORTEXT)(HRESULT nErrorCode, OUT BSTR *pText);
		typedef HRESULT(__stdcall* ILR_GETINTERFACE)(IILR **ppObj, DWORD nVersionRequested);
	} // extern "C"

	extern ILR_GETVERSION ILR_GetVersion;
	extern ILR_GETERRORTEXT ILR_GetErrorText;
	extern ILR_GETINTERFACE ILR_GetInterface;

	extern HMODULE	g_hILRLib;
	extern ULONG g_nILRLoadCount;

#endif // !ILREADERS_LINKONREQUEST

#ifndef ILREADERS_EXPORTS
	bool IsILRLoaded();
	HRESULT LoadILR(LPCTSTR pszPath = NULL);
	VOID UnloadILR();
	bool CheckSdkVersion();
#endif // !ILREADERS_EXPORTS

}; // namespace ilr

#endif // !_ILREADERS_H
