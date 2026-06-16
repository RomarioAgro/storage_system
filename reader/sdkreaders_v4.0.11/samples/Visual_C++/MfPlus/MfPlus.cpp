// MfPlus.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include "ILReaders.h"
#include "ILRHelpers.h"
#include <atlcomcli.h>
#include <vector>
#include <locale>

using namespace ilr;


ilr::MfPlusKey g_AuthKey;	// Ключ аутентификации Mifare
bool g_fAuthKeyB = false;	// True, авторизовать по ключу B, иначе - A
bool g_fOpenText = true;	// True, открытая передача, иначе - зашифрованная
DWORD g_nRdKeys = 0;					// Биты ключей аутентификации считывателя
ilr::MfPlusKey g_aSavedRdKeys[2][16];	// Сохранённые ключи считывателя


void DoReadPlusSL3(IILReader *pReader)
{
	try
	{
		ilr::CardInfo rCI;
		ILRCheck(pReader->GetCardInfo(&rCI));
		int nBlockMax = rCI.GetNumberOfMfBlocks();
		std::vector<MfBlockData> oBlocks;
		oBlocks.resize(nBlockMax);
		_tprintf(_T("Чтение данных карты... "));
		DWORD nStartTick = GetTickCount();
		if (g_nRdKeys != 0)
		{
			int nKeyIdx;
			ILRCheck(pReader->AuthMfCardByRdKeys(0, g_fAuthKeyB, g_nRdKeys, &nKeyIdx));
			if (-1 == nKeyIdx)
			{
				_tprintf(_T("Нет подходящего ключа аутентификации\n"));
				return;
			}
		}
		else
		{
			ILRCheck(pReader->LoadMfPlusAuthKey(g_AuthKey));
			BOOL fAuthOk;
			ILRCheck(pReader->AuthMfCard(0, g_fAuthKeyB, &fAuthOk));
			if (!fAuthOk)
			{
				_tprintf(_T("Ключ аутентификации не подошёл\n"));
				return;
			}
		}
		int nRead = 0;
		ILRCheck(pReader->ReadMfPlus(0, oBlocks.data(), (int)oBlocks.size(), g_fOpenText, &nRead));
		DWORD nSpan = GetTickSpan(nStartTick, GetTickCount());
		_tprintf(_T("прочитано %d блоков за %d мс\n"), nRead, nSpan);

		int nSectorIdx = 0;
		int nSBlockIdx = 0;
		int nSTrailer, nAreaN;
		PMfBlockData pBData;
		DWORD nAccessBits, nAreaAccess, nC1, nC2, nC3;
		BYTE nEn;
		LPCTSTR kOpenText[2] = { _T("Зашифрованная передача"), _T("Открытая передача") };
		for (int i = 0; i < nRead; ++i)
		{
			if (0 == nSBlockIdx)
			{
				nSTrailer = (i < 128) ? 3 : 15;
				pBData = &oBlocks[i + nSTrailer - nSBlockIdx];
				nAccessBits = 0;
				memcpy_s(&nAccessBits, sizeof(nAccessBits), &pBData->a[6], 3);
				nC1 = (nAccessBits >> 12) & 0xF;
				nC2 = (nAccessBits >> 16) & 0xF;
				nC3 = (nAccessBits >> 20) & 0xF;
				nEn = pBData->a[5];
			}
			pBData = &oBlocks[i];
			// Выводим байты блока
			_tprintf(TEXT("%.2d (%.2d). %.2X %.2X %.2X %.2X %.2X %.2X %.2X %.2X %.2X %.2X %.2X %.2X %.2X %.2X %.2X %.2X\n"),
				i, nSectorIdx,
				pBData->a[0], pBData->a[1], pBData->a[2], pBData->a[3],
				pBData->a[4], pBData->a[5], pBData->a[6], pBData->a[7],
				pBData->a[8], pBData->a[9], pBData->a[10], pBData->a[11],
				pBData->a[12], pBData->a[13], pBData->a[14], pBData->a[15]);

			nAreaN = nSBlockIdx / (nSTrailer / 3);
			nAreaAccess = ((nC1 >> nAreaN) & 1) | (((nC2 >> nAreaN) & 1) << 1) |
				(((nC3 >> nAreaN) & 1) << 2);
			if (nSBlockIdx == nSTrailer)
			{
				// Выводим параметры доступа прицепа
				_tprintf(TEXT("\tПрицеп. Доступ (En=%X) (%d, %d, %d): "),
					nEn & 0xF,
					(nAreaAccess & 1),
					(nAreaAccess >> 1) & 1,
					(nAreaAccess >> 2) & 1);
				switch (nAreaAccess)
				{
				case 0: // 0 0 0
					ASSERT(!g_fAuthKeyB);
					_tprintf(TEXT("Ключ A [-w]; Биты доступа [r-]; Ключ B [rw]\n"));
					break;

				case 2: // 0 1 0
					ASSERT(!g_fAuthKeyB);
					_tprintf(TEXT("Ключ A [--]; Биты доступа [r-]; Ключ B [r-]\n"));
					break;

				case 1: // 1 0 0
					if (g_fAuthKeyB)
						_tprintf(TEXT("Ключ A [-w]; Биты доступа [r-]; Ключ B [-w]\n"));
					else
						_tprintf(TEXT("Ключ A [--]; Биты доступа [r-]; Ключ B [--]\n"));
					break;

				case 3: // 1 1 0
					_tprintf(TEXT("Ключ A [--]; Биты доступа [r-]; Ключ B [--]\n"));
					break;

				case 4: // 0 0 1
					ASSERT(!g_fAuthKeyB);
					_tprintf(TEXT("Ключ A [-w]; Биты доступа [rw]; Ключ B [rw]; транспортная\n"));
					break;

				case 6: // 0 1 1
					if (g_fAuthKeyB)
						_tprintf(TEXT("Ключ A [-w]; Биты доступа [rw]; Ключ B [-w]\n"));
					else
						_tprintf(TEXT("Ключ A [--]; Биты доступа [r-]; Ключ B [--]\n"));
					break;

				case 5: // 1 0 1
					if (g_fAuthKeyB)
						_tprintf(TEXT("Ключ A [--]; Биты доступа [rw]; Ключ B [-w]\n"));
					else
						_tprintf(TEXT("Ключ A [--]; Биты доступа [r-]; Ключ B [--]\n"));
					break;

				case 7: // 1 1 1
					_tprintf(TEXT("Ключ A [--]; Биты доступа [r-]; Ключ B [--]\n"));
					break;
				}
				++nSectorIdx;
				nSBlockIdx = 0;
			}
			else
			{
				// Выводим параметры доступа блока данных
				_tprintf(TEXT("  Данные. Доступ (%d, %d, %d): "),
					(nAreaAccess & 1), 
					(nAreaAccess >> 1) & 1, 
					(nAreaAccess >> 2) & 1);
				switch (nAreaAccess)
				{
				case 0: // 0 0 0
					_tprintf(TEXT("rwidtr; транспортная\n"));
					break;

				case 2: // 0 1 0
					_tprintf(TEXT("r-----\n"));
					break;

				case 1:	// 1 0 0
					if (g_fAuthKeyB)
						_tprintf(TEXT("rw----\n"));
					else
						_tprintf(TEXT("r-----\n"));
					break;

				case 3:	// 1 1 0
					if (g_fAuthKeyB)
						_tprintf(TEXT("rwidtr; блок-значение\n"));
					else
						_tprintf(TEXT("r--dtr; блок-значение\n"));
					break;

				case 4:	// 0 0 1
					_tprintf(TEXT("r--dtr; блок-значение\n"));
					break;

				case 6:	// 0 1 1
					if (g_fAuthKeyB)
						_tprintf(TEXT("rw----\n"));
					else
						_tprintf(TEXT("------\n"));
					break;

				case 5:	// 1 0 1
					if (g_fAuthKeyB)
						_tprintf(TEXT("r-----\n"));
					else
						_tprintf(TEXT("------\n"));
					break;

				case 7:	// 1 1 1
					_tprintf(TEXT("------\n"));
					break;
				}
				++nSBlockIdx;
			}
			_tprintf(TEXT("\t%s\n"), kOpenText[GetBit(nEn, nAreaN)]);
		}
		_tprintf(TEXT("-----\n"));
	}
	catch (std::exception &e)
	{
		printf("%s\r\n", e.what());
	}
}

void DoWritePlusSL3(IILReader *pReader)
{
	try
	{
		// Запрашиваем номер сектора и номер блока Mifare
		_tprintf(TEXT("Введите номер сектора и номер блока:\n"));
		int nSectorIdx, nSBlockIdx;
		if (_tscanf_s(TEXT("%d, %d"), &nSectorIdx, &nSBlockIdx) != 2)
		{
			_tprintf(TEXT("Неправильный ввод\n"));
			return;
		}
		// Запрашиваем значения байтов блока Mifare
		_tprintf(TEXT("Введите байты 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 (16-ричное):\n"));
		int aN[15];
		if (_tscanf_s(TEXT("%x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x"),
			&aN[0], &aN[1], &aN[2], &aN[3],
			&aN[4], &aN[5], &aN[6], &aN[7],
			&aN[8], &aN[9], &aN[10], &aN[11],
			&aN[12], &aN[13], &aN[14], &aN[15]) != 16)
		{
			_tprintf(TEXT("Неправильный ввод\n"));
			return;
		}
		MfBlockData rBlockData;
		for (int i = 0; i < _countof(rBlockData.a); i++)
			rBlockData.a[i] = (BYTE)aN[i];

		bool fTrailer;
		int nBlockIdx;
		if (nSectorIdx < 32)
		{
			nBlockIdx = (nSectorIdx * 4) + nSBlockIdx;
			fTrailer = (3 == nSBlockIdx);
		}
		else
		{
			nBlockIdx = 128 + ((nSectorIdx - 32) * 16) + nSBlockIdx;
			fTrailer = (15 == nSBlockIdx);
		}
		// Если это блок-прицеп,
		if (fTrailer)
		{
			// Проверяем корректность битов доступа
			DWORD nAccessBits = 0;
			memcpy_s(&nAccessBits, sizeof(nAccessBits), &rBlockData.a[6], 3);
			DWORD nC1 = (nAccessBits >> 12) & 0xF;
			DWORD nC2 = (nAccessBits >> 16) & 0xF;
			DWORD nC3 = (nAccessBits >> 20) & 0xF;
			DWORD nT1 = (nAccessBits & 0xF);
			DWORD nT2 = (nAccessBits >> 4) & 0xF;
			DWORD nT3 = (nAccessBits >> 8) & 0xF;
			if (((nC1 ^ nT1) != 0xF) || ((nC2 ^ nT2) != 0xF) || ((nC3 ^ nT3) != 0xF))
			{
				_tprintf(TEXT("Некорректное значение битов доступа. Запись отменена\n"));
				return;
			}
			// Проверяем корректность битов доступа En
			BYTE nEn = rBlockData.a[5];
			if (((nEn & 0xF) ^ (nEn >> 4)) != 0xF)
			{
				_tprintf(TEXT("Некорректное значение битов доступа En. Запись отменена\n"));
				return;
			}
		}

		_tprintf(TEXT("Запись... "));
		DWORD nStartTick = GetTickCount();
		if (g_nRdKeys != 0)
		{
			int nKeyIdx;
			ILRCheck(pReader->AuthMfCardByRdKeys(nBlockIdx, g_fAuthKeyB, g_nRdKeys, &nKeyIdx));
			if (-1 == nKeyIdx)
			{
				_tprintf(_T("Нет подходящего ключа аутентификации\n"));
				return;
			}
		}
		else
		{
			ILRCheck(pReader->LoadMfPlusAuthKey(g_AuthKey));
			BOOL fAuthOk;
			ILRCheck(pReader->AuthMfCard(nBlockIdx, g_fAuthKeyB, &fAuthOk));
			if (!fAuthOk)
			{
				_tprintf(_T("Ключ аутентификации не подошёл\n"));
				return;
			}
		}
		INT nWritten = 0;
		ILRCheck(pReader->WriteMfPlus(nBlockIdx, &rBlockData, 1, g_fOpenText, &nWritten));
		DWORD nSpan = GetTickSpan(nStartTick, GetTickCount());
		_tprintf(_T("записано %d блоков за %d мс\n"), nWritten, nSpan);
	}
	catch (std::exception &e)
	{
		printf("%s\r\n", e.what());
	}
}

int main()
{
	setlocale(LC_ALL, "Russian");
#ifdef ILREADERS_LINKONREQUEST
	CILRLoader oILRLoader;
	if (FAILED(oILRLoader.m_hr))
	{
		_tprintf(_T("Ошибка зашрузки \"%s\": 0x%x\n"), ILR_DLL_NAME, oILRLoader.m_hr);
		return -1;
	}
#endif // ILREADERS_LINKONREQUEST
	try
	{
		// Получаем главный интерфейс SDK
		CComPtr<IILR> oILR;
		ILRCheck(ILR_GetInterface(&oILR.p, ILR_SDK_VERSION));

		// Ищем считыватель
		_tprintf(_T("Поиск считывателя... "));
		CComPtr<IILRSearch> oSearch;
		ILRCheck(oILR->GetSearch(&oSearch.p));
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
		CComPtr<IILReader> oReader;
		ILRCheck(oILR->GetReader(rRI.nPortType, rRI.szPortName, &oReader.p));
		// Отключаем авто поиск карт
		oReader->EnableAutoScan(FALSE, FALSE);
		// Подключаемся к считывателю
		_tprintf(_T("Подключение к считывателю... "));
		ILRCheck(oReader->Connect());
		_tprintf(_T("успешно\n"));
		ILRCheck(oReader->GetReaderInfo(&rRI));
		bool fCanRW = (rRI.CanRWCardTypes() & RWCT_F_MFPPLUS) != 0;

		while (true)
		{
			_tprintf(TEXT("Поиск карты Mifare Plus... "));
			ILRCheck(oReader->Scan(FALSE));
			ilr::CardInfo rCI;
			ILRCheck(oReader->GetCardInfo(&rCI));
			bool fCardFound = rCI.IsMfPlusSL3Mode();
			// Если карта Mifare Plus SL3 найдена,
			if (fCardFound)
			{
				CString sUID;
				CardUIDToStr(rCI.nType, rCI.rUID, &sUID);
				_tprintf(TEXT("%s %s\n"), ilr::kCardTypeNames[rCI.nType], sUID.c_str());
			}
			else // Mifare Plus SL3 не найдена
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
						DoReadPlusSL3(oReader);
					continue;

				case 3:
					if (fCardFound && fCanRW)
						DoWritePlusSL3(oReader);
					continue;
				}
			}
			_tprintf(TEXT("Неправильный ввод\n"));
		}

		getchar();
	}
	catch (std::exception &e)
	{
		printf("%s\r\n", e.what());
		getchar();
	}
	return 0;
}
