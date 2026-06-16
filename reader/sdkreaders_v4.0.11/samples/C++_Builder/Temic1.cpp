#pragma hdrstop
#pragma argsused

#ifdef _WIN32
#include <tchar.h>
#else
  typedef char _TCHAR;
  #define _tmain main
#endif

#include <stdio.h>
#include <locale>
#include <utilcls.h>
#include "ILReaders.h"
#include "ILRHelpers.h"

using namespace ilr;

const INT64 kPassword = -1;	// Пароль для доступа к Temic, =-1 нет пароля

void DoReadTemic(IILReader *pReader)
{
	try
	{
		const INT kBitRates[8] = { 8, 16, 32, 40, 50, 64, 100, 128 };
		const LPCTSTR kPskCf[4] = { TEXT("RF/2"), TEXT("RF/4"), TEXT("RF/8"), TEXT("Reserved") };
		const LPCTSTR kFlagStrs[2] = { TEXT("False"), TEXT("True") };

		_tprintf(TEXT("Чтение данных карты... "));
		DWORD aBlocks[10];
		DWORD nStartTick = GetTickCount();
		ILRCheck(pReader->LoadTemicPassword(kPassword));
		INT nRead;
		ILRCheck(pReader->ReadTemic(0, aBlocks, _countof(aBlocks), -1, &nRead));
		DWORD nSpan = GetTickSpan(nStartTick, GetTickCount());
		_tprintf(TEXT("прочитано %d блоков за %d мс\n"), nRead, nSpan);

		DWORD nConfig = 0;
		DWORD nDataRate = 0;
		DWORD nModulation = 0;
		DWORD nMaxBlock = 0;
		DWORD nBlockData;
		for (int i = 0; i < _countof(aBlocks); ++i)
		{
			nBlockData = aBlocks[i];
			_tprintf(TEXT("%.2d. %.2X %.2X %.2X %.2X "),
				i,
				nBlockData & 0xff,
				(nBlockData >> 8) & 0xff,
				(nBlockData >> 16) & 0xff,
				nBlockData >> 24);
			switch (i)
			{
			case 0:	// Configuration data
			{
				_tprintf(TEXT("Конфигурация\n"));
				nConfig = nBlockData;
				bool fXMode = GetBit(nConfig, 9);
				if (fXMode)
					_tprintf(TEXT("\tРежим: X-Mode\n"));
				else
					_tprintf(TEXT("\tРежим: e5550 Compatibility Mode\n"));

				_tprintf(TEXT("\tMaster Key: %d\n"), (nConfig >> 4) & 0xf);

				if (fXMode)
					nDataRate = ((nConfig >> 10) & 0x3F) * 2 + 2;
				else
					nDataRate = kBitRates[(nConfig >> 10) & 7];
				_tprintf(TEXT("\tData Bit Rate: RF/%d\n"), nDataRate);

				nModulation = ((nConfig >> 20) & 0xF) | (((nConfig >> 8) & 1) << 4);
				CString s;
				switch (nModulation)
				{
				case 0:	// 0 0 0 0 0
					s = TEXT("Direct");
					break;

				case 1:	// 0 0 0 0 1
					s = TEXT("PSK1");
					break;

				case 2:	// 0 0 0 1 0
					s = TEXT("PSK2");
					break;

				case 3:	// 0 0 0 1 1
					s = TEXT("PSK3");
					break;

				case 4:	// 0 0 1 0 0
					s = TEXT("FSK1");
					break;

				case 5:	// 0 0 1 0 1
					s = TEXT("FSK2");
					break;

				case 6:	// 0 0 1 1 0
					s = TEXT("FSK1a");
					break;

				case 7:	// 0 0 1 1 1
					s = TEXT("FSK2a");
					break;

				case 8:	// 0 1 0 0 0
					s = TEXT("Manchester");
					break;

				case 0x10: // 1 0 0 0 0
					s = TEXT("Biphase('50)");
					break;

				case 0x18: // 1 1 0 0 0
					s = TEXT("Biphase('57)");
					break;
				}
				_tprintf(TEXT("\tModulation: %s\n"), s.c_str());

				_tprintf(TEXT("\tPSK-CF: %s\n"), kPskCf[(nConfig >> 18) & 3]);
				_tprintf(TEXT("\tAOR: %s\n"), kFlagStrs[GetBit(nConfig, 17)]);
				if (fXMode)
					_tprintf(TEXT("\tOTP: %s\n"), kFlagStrs[GetBit(nConfig, 16)]);
				nMaxBlock = (nConfig >> 29) & 7;
				_tprintf(TEXT("\tMAX-BLOCK: %d\n"), nMaxBlock);
				_tprintf(TEXT("\tPassword: %s\n"), kFlagStrs[GetBit(nConfig, 28)]);
				if (fXMode)
				{
					_tprintf(TEXT("\tSST-Sequence Start Marker: %s\n"), kFlagStrs[GetBit(nConfig, 27)]);
					_tprintf(TEXT("\tFastwrite: %s\n"), kFlagStrs[GetBit(nConfig, 26)]);
					_tprintf(TEXT("\tInverse Data: %s\n"), kFlagStrs[GetBit(nConfig, 25)]);
				}
				else
					_tprintf(TEXT("\tST-Sequence Terminator: %s\n"), kFlagStrs[GetBit(nConfig, 27)]);
				_tprintf(TEXT("\tPOR delay: %s\n"), kFlagStrs[GetBit(nConfig, 24)]);
				break;
			}

			case 7:	// User data or password
				if (GetBit(nConfig, 28))
					_tprintf(TEXT("Пароль\n"));
				else
					_tprintf(TEXT("Данные пользователя\n"));
				break;

			case 8:	// Traceability data
				_tprintf(TEXT("Данные производителя\n"));
				_tprintf(TEXT("\tACL: 0x%.2X\n"), nBlockData & 0xff);
				_tprintf(TEXT("\tMFC: 0x%.2X\n"), (nBlockData >> 8) & 0xff);
				_tprintf(TEXT("\tICR: 0x%.2X\n"), (nBlockData >> 16) & 0xff);
				_tprintf(TEXT("\tMSN LotID: %d\n"), nBlockData >> 24);
				break;

			case 9:	// Traceability data
			{
				_tprintf(TEXT("Данные производителя\n"));
				_tprintf(TEXT("\tLotID: %d\n"), nBlockData & 0xFFF);
				_tprintf(TEXT("\twafer #: 0x%X\n"), (nBlockData >> 12) & 0x3F);
				_tprintf(TEXT("\tdie on wafer #: 0x%X\n"), (nBlockData >> 18) & 0x3FFF);
				break;
			}

			default:
				_tprintf(TEXT("Данные пользователя\n"));
				break;
			}
		}

		CardType nType = cUnknownCard;
		CardUID rUID;
		int nWiegand;
		rUID.Clear();
		if ((64 == nDataRate) && (8 == nModulation) && (2 == nMaxBlock))
		{
			pReader->DecodeTemicEmMarine(aBlocks, 3, &rUID);
			nType = cEmMarine;
		}
		else if ((50 == nDataRate) && (5 == nModulation) && (3 == nMaxBlock))
		{
			pReader->DecodeTemicHID(aBlocks, 4, &rUID, &nWiegand);
			nType = cHID;
		}
		if (!rUID.IsEmpty())
		{
			CString s;
			CardUIDToStr(nType, rUID, &s);
			if (cHID == nType)
				_tprintf(TEXT("Эмулирует HID (W%d) %s\n"), nWiegand, s.c_str());
			else
				_tprintf(TEXT("Эмулирует Em-Marine %s\n"), s.c_str());
		}

		_tprintf(TEXT("-----\n"));
	}
	catch (std::exception &e)
	{
		printf("%s\r\n", e.what());
	}
}

void DoWriteTemic(IILReader *pReader)
{
	try
	{
		// Запрашиваем номер блока и значения байтов блока Temic
		_tprintf(TEXT("Введите номер блока и байты 0 1 2 3 (16-ричное):\n"));
		int nBlockN, a[4];
		if (_tscanf_s(TEXT("%x %x %x %x %x"),
			&nBlockN, &a[0], &a[1], &a[2], &a[3]) != 5)
		{
			_tprintf(TEXT("Неправильный ввод\n"));
			return;
		}
		BYTE aBytes[4];
		for (int i = 0; i < _countof(aBytes); ++i)
			aBytes[i] = (BYTE)a[i];

		_tprintf(TEXT("Запись... "));
		DWORD nStartTick = GetTickCount();
		ILRCheck(pReader->LoadTemicPassword(kPassword));
		INT nWritten;
		ILRCheck(pReader->WriteTemic(nBlockN, (DWORD *)aBytes, 1, FALSE, -1, &nWritten));
		DWORD nSpan = GetTickSpan(nStartTick, GetTickCount());
		_tprintf(_T("записано %d блок за %d мс\n"), nWritten, nSpan);
	}
	catch (std::exception &e)
	{
		printf("%s\r\n", e.what());
	}
}

void DoWriteEmMarine(IILReader *pReader)
{
	try
	{
		// Запрашиваем номер Em-Marine: 1) код производителя (шестнадцатиричное число),
		//  2) номер серии  (десятичное), 3) номер (десятичное)
		_tprintf(TEXT("Enter Em-Marine number: facility code (hex) series (dec) number (dec):\n"));
		int nFacility, nSeries, nNumber;
		if (_tscanf_s(TEXT("%x %d %d"), &nFacility, &nSeries, &nNumber) != 3)
		{
			_tprintf(TEXT("Неправильный ввод\n"));
			return;
		}

		// Подготавливаем данные для записи
		CardUID rUID;
		rUID.Clear();
		*(PWORD)&rUID.aBytes[0]	= nNumber;
		rUID.aBytes[2] = nSeries;
		*(PWORD)&rUID.aBytes[3] = nFacility;
		rUID.nLength = 5;
		DWORD aBlocks[3];
		ILRCheck(pReader->EncodeTemicEmMarine(rUID, aBlocks, _countof(aBlocks)));

		// Пишем номер Em-Marine в Temic
		_tprintf(TEXT("Запись... "));
		DWORD nStartTick = GetTickCount();
		ILRCheck(pReader->LoadTemicPassword(kPassword));
		INT nWritten;
		ILRCheck(pReader->WriteTemic(0, aBlocks, _countof(aBlocks), FALSE, -1, &nWritten));
		DWORD nSpan = GetTickSpan(nStartTick, GetTickCount());
		_tprintf(_T("записано %d блока за %d мс\n"), nWritten, nSpan);
	}
	catch (std::exception &e)
	{
		printf("%s\r\n", e.what());
	}
}

void DoWriteHID(IILReader *pReader)
{
	try
	{
		// Запрашиваем номер HID: 1) номер кодировки Wiegand (десятичное число),
		//  2) код производителя (шестнадцатиричное), 3) номер (десятичное)
		_tprintf(TEXT("Enter HID number: wiegand (dec) facility code (hex) number (dec):\n"));
		int nWiegand, nFacility, nNumber;
		if ((_tscanf_s(TEXT("%d %x %d"), &nWiegand, &nFacility, &nNumber) != 3) ||
			(nWiegand < 10) || (nWiegand > 37))
		{
			_tprintf(TEXT("Неправильный ввод\n"));
			return;
		}

		// Подготавливаем данные для записи
		CardUID rUID;
		rUID.Clear();
		int nFSize = (nWiegand - 2 - 16);
		int nFCount = nFSize / 8;
		if ((nFSize % 8) != 0)
			++nFCount;
		*(PWORD)&rUID.aBytes[0]	= nNumber;
		if (nFCount > 0)
			memcpy_s(&rUID.aBytes[2], sizeof(rUID.aBytes) - 2, &nFacility, nFCount);
		rUID.nLength = (2 + nFCount);
		DWORD aBlocks[4];
		ILRCheck(pReader->EncodeTemicHID(rUID, aBlocks, _countof(aBlocks), nWiegand));

		// Пишем номер HID в Temic
		_tprintf(TEXT("Запись... "));
		DWORD nStartTick = GetTickCount();
		ILRCheck(pReader->LoadTemicPassword(kPassword));
		INT nWritten;
		ILRCheck(pReader->WriteTemic(0, aBlocks, _countof(aBlocks), FALSE, -1, &nWritten));
		DWORD nSpan = GetTickSpan(nStartTick, GetTickCount());
		_tprintf(_T("записано %d блока за %d мс\n"), nWritten, nSpan);
	}
	catch (std::exception &e)
	{
		printf("%s\r\n", e.what());
	}
}

void DoInitTemic(IILReader *pReader)
{
	try
	{
		// Подготавливаем данные для записи - стандартная конфигурация
		DWORD nConfigData = 0x40801400;

		_tprintf(TEXT("Запись... "));
		DWORD nStartTick = GetTickCount();
		ILRCheck(pReader->LoadTemicPassword(kPassword));
		INT nWritten;
		ILRCheck(pReader->WriteTemic(0, &nConfigData, 1, FALSE, -1, &nWritten));
		DWORD nSpan = GetTickSpan(nStartTick, GetTickCount());
		_tprintf(TEXT("записано %d блок за %d мс\n"), nWritten, nSpan);
	}
	catch (std::exception &e)
	{
		printf("%s\r\n", e.what());
	}
}

 int _tmain(int argc, _TCHAR* argv[]) 
{
	setlocale(LC_ALL, "Russian");
#ifdef ILREADERS_LINKONREQUEST
	CILRLoader oILRLoader;
	if (FAILED(oILRLoader.m_hr))
	{
		CString sErrorText;
		ILRGetErrorText(oILRLoader.m_hr, &sErrorText);
		_tprintf(_T("Ошибка загрузки \"%s\" (код: 0x%x): %s\n"),
			ILR_DLL_NAME, oILRLoader.m_hr, sErrorText.c_str());
		return -1;
	}
#endif // ILREADERS_LINKONREQUEST
	try
	{
		// Получаем главный интерфейс SDK
		TComInterface<IILR> oILR;
		ILRCheck(ILR_GetInterface(&oILR, ILR_SDK_VERSION));
		// Получает интерфейс поиска считывателей
		TComInterface<IILRSearch> oSearch;
		ILRCheck(oILR->GetSearch(&oSearch));
		// Ищем считыватель
		_tprintf(_T("Поиск считывателя... "));
		ILRCheck(oSearch->SetReaderTypes(RT_F_ILUSB | RT_F_TPUSB));
		ILRCheck(oSearch->Scan());
		INT nCount;
		ILRCheck(oSearch->GetReaderCount(&nCount));
		if (0 == nCount)
		{
			_tprintf(TEXT("не найден\n"));
			return 0;
		}
		ilr::ReaderInfo rRI;
		ILRCheck(oSearch->GetReaderInfo(0, &rRI));
		oSearch.Release();
		_tprintf(_T("%s: %s\n"),
			rRI.szPortName,
			ilr::kRdModelNames[rRI.nModel]);

		// Получаем интерфейс считывателя
		TComInterface<IILReader> oReader;
		ILRCheck(oILR->GetReader(rRI.nPortType, rRI.szPortName, &oReader));
		oILR.Release();
		// Отключаем авто поиск карт
		ILRCheck(oReader->EnableAutoScan(FALSE, FALSE));
		// Подключаемся к считывателю
		_tprintf(TEXT("Подключение к считывателю... "));
		ILRCheck(oReader->Connect());
		_tprintf(TEXT("успешно\n"));
		ILRCheck(oReader->GetReaderInfo(&rRI));
		// True, считыватель поддерживает чтение/запись данных Temic
		bool fCanRW = (rRI.CanRWCardTypes() & RWCT_F_TEMIC) != 0;
		if (fCanRW)
			ILRCheck(oReader->EnableAutoScanTemic(TRUE));

		while (true)
		{
			_tprintf(TEXT("Поиск карты Temic... "));
			ILRCheck(oReader->Scan(FALSE));
			ilr::CardInfo rCI;
			ILRCheck(oReader->GetCardInfo(&rCI));
			bool fCardFound = (cTemic == rCI.nType);
			// Если карта Temic найдена,
			if (fCardFound)
			{
				CString sUID;
				CardUIDToStr(rCI.nType, rCI.rUID, &sUID);
				_tprintf(TEXT("%s %s\n"), ilr::kCardTypeNames[rCI.nType], sUID.c_str());
			}
			else // Temic не найдена
				_tprintf(TEXT("не найдена\n"));

			_tprintf(TEXT("-----\n"));
			_tprintf(TEXT("Введите номер команды:\n"));
			_tprintf(TEXT("1 - Искать снова\n"));
			if (fCanRW)
			{
				if (fCardFound)
				{
					_tprintf(TEXT("2 - Прочитать данные из карты\n"));
					_tprintf(TEXT("3 - Записать данные на карту...\n"));
					_tprintf(TEXT("4 - Записать Em-Marine...\n"));
					_tprintf(TEXT("5 - Записать HID...\n"));
				}
				else
					_tprintf(TEXT("2 - Инициализировать карту Temic\n"));
			}
			_tprintf(TEXT("0 - Выйти из программы\n"));
			int nCommand;
			if (_tscanf_s(TEXT("%d"), &nCommand) == 1)
			{
				_tprintf(TEXT("\n"));
				switch (nCommand)
				{
				case 1:
					continue;

				case 2:
					if (fCanRW)
					{
						if (fCardFound)
							DoReadTemic(oReader);
						else
							DoInitTemic(oReader);
					}
					continue;

				case 3:
					if (fCardFound && fCanRW)
						DoWriteTemic(oReader);
					continue;

				case 4:
					if (fCardFound && fCanRW)
						DoWriteEmMarine(oReader);
					continue;

				case 5:
					if (fCardFound && fCanRW)
						DoWriteHID(oReader);
					continue;

				case 0:
					return 0;
				}
			}
			else
				while(getchar() != '\n');

			_tprintf(TEXT("Неправильный ввод\n"));
		}
	}
	catch(std::exception &e)
	{
		printf("%s\r\n", e.what());
		getchar();
	}
	return 0;
}
