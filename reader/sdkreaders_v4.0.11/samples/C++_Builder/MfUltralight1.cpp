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

void DoReadUltralight(IILReader *pReader)
{
	try
	{
		DWORD aPages[16]; // 16 страниц по 4 байта
		_tprintf(_T("Чтение данных карты... "));
		INT nRead;
		DWORD nStartTick = GetTickCount();
		ILRCheck(pReader->ReadMfUlralight(0, aPages, _countof(aPages), &nRead));
		DWORD nSpan = GetTickSpan(nStartTick, GetTickCount());
		_tprintf(_T("прочитано %d страниц за %d мс\n"), nRead, nSpan);

		const LPCTSTR kLocked[2] = { _T(""), TEXT("Locked") };
		DWORD nPageData, n;
		_tprintf(TEXT("Страница. Байты 0..3\n"));
		for (int i = 0; i < 16; i++) // цикл по страницам
		{
			nPageData = aPages[i];
			_tprintf(TEXT("%4d. %.2X %.2X %.2X %.2X"),
				i,
				nPageData & 0xff,
				(nPageData >> 8) & 0xff,
				(nPageData >> 16) & 0xff,
				nPageData >> 24);
			switch (i)
			{
			case 0: // Serial Number
			case 1:
				_tprintf(TEXT(" Серийный номер\n"));
				break;

			case 2: // Internal / Lock
			{
				_tprintf(TEXT(" Внутреннее / Блокировка\n"));
				n = (nPageData >> 16);
				_tprintf(TEXT("Lock0[%.2X] BOTP:%d, BL9-4:%d, BL15-10:%d, OTP:%d, L4:%d, L5:%d, L6:%d, L7:%d\n"),
					n & 0xff,
					n & 1,
					(n >> 1) & 1,
					(n >> 2) & 1,
					(n >> 3) & 1,
					(n >> 4) & 1,
					(n >> 5) & 1,
					(n >> 6) & 1,
					(n >> 7) & 1);
				_tprintf(TEXT("Lock1[%.2X] L8:%d, L9:%d, L10:%d, L11:%d, L12:%d, L13:%d, L14:%d, L15:%d\n"),
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
			}

			case 3: // OTP
			{
				CString s(TEXT("00000000 00000000 00000000 00000000"));
				n = nPageData;
				for (size_t j = 0; j < s.length(); ++j)
				{
					if (_T(' ') == s[j])
						continue;
					if (n & 1)
						s[j] = '1';
					n >>= 1;
				}
				_tprintf(TEXT(" OTP (%d) %s %s\n"),
					nPageData,
					s.c_str(),
					kLocked[GetBit(aPages[2] >> 16, 3)]);
				break;
			}

			default:
				_tprintf(TEXT(" Данные (%d) %s\n"),
					nPageData,
					kLocked[GetBit(aPages[2] >> 16, i)]);
				break;
			}
		}
		_tprintf(TEXT("-----\n"));
	}
	catch (std::exception &e)
	{
		printf("%s\r\n", e.what());
	}
}

void DoWriteUltralight(IILReader *pReader)
{
	try
	{
		INT nPageN, a[4];
		_tprintf(TEXT("Введите номер страницы (10-тичное), байты 0 1 2 3 (16-ричные):\n"));
		if (_tscanf_s(TEXT("%d, %x %x %x %x"),
			&nPageN, &a[0], &a[1], &a[2], &a[3]) != 5)
		{
			_tprintf(TEXT("Неправильный ввод\n"));
			return;
		}
		DWORD nPageData;
		for (UINT i = 0; i < _countof(a); ++i)
			((PBYTE)&nPageData)[i] = (BYTE)a[i];

		_tprintf(TEXT("Запись... "));
		DWORD nStartTick = GetTickCount();
		INT nWritten;
		ILRCheck(pReader->WriteMfUlralight(nPageN, &nPageData, 1, &nWritten));
		DWORD nSpan = GetTickSpan(nStartTick, GetTickCount());
		_tprintf(_T("записана %d страница за %d мс\n"), nWritten, nSpan);
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
		_tprintf(_T("Подключение к считывателю... "));
		ILRCheck(oReader->Connect());
		_tprintf(_T("успешно\n"));
		ILRCheck(oReader->GetReaderInfo(&rRI));
		bool fCanRW = (rRI.CanRWCardTypes() & RWCT_F_MFULTRALIGHT) != 0;

		while (true)
		{
			_tprintf(TEXT("Поиск карты Mifare Ultralight... "));
			ILRCheck(oReader->Scan(FALSE));
			ilr::CardInfo rCI;
			ILRCheck(oReader->GetCardInfo(&rCI));
			bool fCardFound = (cMifareUltralight == rCI.nType);
			// Если карта Mifare Ultralight найдена,
			if (fCardFound)
			{
				CString sUID;
				CardUIDToStr(rCI.nType, rCI.rUID, &sUID);
				_tprintf(TEXT("%s %s\n"), ilr::kCardTypeNames[rCI.nType], sUID.c_str());
			}
			else // Mifare Ultralight не найдена
				_tprintf(TEXT("не найдена\n"));

			_tprintf(TEXT("-----\n"));
			_tprintf(TEXT("Введите номер команды:\n"));
			_tprintf(TEXT("1 - Искать снова\n"));
			if (fCardFound && fCanRW)
			{
				_tprintf(TEXT("2 - Прочитать данные из карты\n"));
				_tprintf(TEXT("3 - Записать данные на карту...\n"));
			}
			_tprintf(TEXT("0 - Выйти из программы\n"));
			int nCommand;
			if (_tscanf_s(TEXT("%d"), &nCommand) == 1)
			{
				_tprintf(TEXT("\n"));
				switch (nCommand)
				{
				case 0:
					return 0;

				case 1:
					continue;

				case 2:
					if (fCardFound && fCanRW)
						DoReadUltralight(oReader);
					continue;

				case 3:
					if (fCardFound && fCanRW)
						DoWriteUltralight(oReader);
					continue;
				}
			}
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
