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
#include <vector>
#include <utilcls.h>
#include "ILReaders.h"
#include "ILRHelpers.h"

using namespace ilr;

// Настройки:
bool g_fAuthKeyB = false;				// True, авторизовать по ключу B, иначе - A
UINT64 g_AuthKey = 0xffffffffffffLL;	// Ключ аутентификации Mifare
DWORD g_nRdKeys = 0;					// Биты ключей аутентификации считывателя
MfClassicKey g_aSavedRdKeys[2][16];		// Сохранённые ключи считывателя

#pragma region Функции загрузки/сохранения настроек
void LoadSettings()
{
	TCHAR szCfgPath[MAX_PATH];
	GetModuleFileName(NULL, szCfgPath, _countof(szCfgPath));
	LPTSTR p = _tcsrchr(szCfgPath, _T('.'));
	_tcscpy_s(p, _countof(szCfgPath) - (p - szCfgPath), _T(".ini"));
	TCHAR szValue[128];
	GetPrivateProfileString(_T("Main"), _T("AuthKey"), NULL, szValue, _countof(szValue), szCfgPath);
	if (*szValue != _T('\0'))
		g_AuthKey = _tcstoull(szValue, &p, 16);
	g_fAuthKeyB = GetPrivateProfileInt(_T("Main"), _T("KeyB"), 0, szCfgPath) != 0;
	g_nRdKeys = GetPrivateProfileInt(_T("Main"), _T("RdKeys"), 0, szCfgPath);

	TCHAR szParams[128];
	int nKeyIdx;
	LPTSTR pszParam;
	for (int i = 0; i < _countof(g_aSavedRdKeys); ++i)
	{
		LPCTSTR pszSect = i ? _T("RdBKeys") : _T("RdAKeys");
		GetPrivateProfileString(pszSect, NULL, NULL, szParams, _countof(szParams), szCfgPath);
		pszParam = szParams;
		while (*pszParam != _T('\0'))
		{
			nKeyIdx = _ttoi(pszParam);
			if ((nKeyIdx >= 0) && (nKeyIdx < _countof(g_aSavedRdKeys[i])))
			{
				GetPrivateProfileString(pszSect, pszParam, NULL, szValue, _countof(szValue), szCfgPath);
				if (*szValue != _T('\0'))
					g_aSavedRdKeys[i][nKeyIdx] = _tcstoull(szValue, &p, 16);
			}
			pszParam += (_tcslen(pszParam) + 1);
		}
	}
}
void SaveRdKey(int nKeyIdx, bool fKeyB, const MfClassicKey &nKey)
{
	TCHAR szCfgPath[MAX_PATH];
	GetModuleFileName(NULL, szCfgPath, _countof(szCfgPath));
	LPTSTR p = _tcsrchr(szCfgPath, _T('.'));
	_tcscpy_s(p, _countof(szCfgPath) - (p - szCfgPath), _T(".ini"));
	TCHAR szKeyIdx[8];
	_itot(nKeyIdx, szKeyIdx, 10);
	TCHAR szAuthKey[16];
	_ui64tot(nKey, szAuthKey, 16);
	WritePrivateProfileString(fKeyB ? _T("RdBKeys") :  _T("RdAKeys"), szKeyIdx, szAuthKey, szCfgPath);
}
void SaveKeyType()
{
	TCHAR szCfgPath[MAX_PATH];
	GetModuleFileName(NULL, szCfgPath, _countof(szCfgPath));
	LPTSTR p = _tcsrchr(szCfgPath, _T('.'));
	_tcscpy_s(p, _countof(szCfgPath) - (p - szCfgPath), _T(".ini"));
	WritePrivateProfileString(_T("Main"), _T("KeyB"),
		g_fAuthKeyB ? _T("1") : _T("0"), szCfgPath);
}
void SaveAuthKey()
{
	TCHAR szAuthKey[16];
	_ui64tot(g_AuthKey, szAuthKey, 16);
	TCHAR szCfgPath[MAX_PATH];
	GetModuleFileName(NULL, szCfgPath, _countof(szCfgPath));
	LPTSTR p = _tcsrchr(szCfgPath, _T('.'));
	_tcscpy_s(p, _countof(szCfgPath) - (p - szCfgPath), _T(".ini"));
	WritePrivateProfileString(_T("Main"), _T("AuthKey"), szAuthKey, szCfgPath);
}
void SaveRdKeys()
{
	TCHAR szRdKeys[16];
	_ultot(g_nRdKeys, szRdKeys, 10);
	TCHAR szCfgPath[MAX_PATH];
	GetModuleFileName(NULL, szCfgPath, _countof(szCfgPath));
	LPTSTR p = _tcsrchr(szCfgPath, _T('.'));
	_tcscpy_s(p, _countof(szCfgPath) - (p - szCfgPath), _T(".ini"));
	WritePrivateProfileString(_T("Main"), _T("RdKeys"), szRdKeys, szCfgPath);
}
#pragma endregion

void DoReadClassic(IILReader *pReader)
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
			ILRCheck(pReader->LoadMfAuthKey(g_AuthKey));
			BOOL fAuthOk;
			ILRCheck(pReader->AuthMfCard(0, g_fAuthKeyB, &fAuthOk));
			if (!fAuthOk)
			{
				_tprintf(_T("Ключ аутентификации не подошёл\n"));
				return;
			}
		}
		int nRead = 0;
		ILRCheck(pReader->ReadMfClassic(0, &oBlocks[0], (int)oBlocks.size(), &nRead));
		DWORD nSpan = GetTickSpan(nStartTick, GetTickCount());
		_tprintf(_T("прочитано %d блоков за %d мс\n"), nRead, nSpan);

		int nSectorIdx = 0;
		int nSBlockIdx = 0;
		int nSTrailer, nAreaN;
		PMfBlockData pBData;
		DWORD nAccessBits, nAreaAccess;
		for (int i = 0; i < nRead; ++i)
		{
			nSTrailer = (i < 128) ? 3 : 15;
			if (0 == nSBlockIdx)
				nAccessBits = GetMfAccessBits(oBlocks[i + nSTrailer]);

			pBData = &oBlocks[i];
			// Выводим байты блока
			_tprintf(TEXT("%.2d (%.2d). %.2X %.2X %.2X %.2X %.2X %.2X %.2X %.2X %.2X %.2X %.2X %.2X %.2X %.2X %.2X %.2X\n"),
				i, nSectorIdx,
				pBData->a[0], pBData->a[1], pBData->a[2], pBData->a[3],
				pBData->a[4], pBData->a[5], pBData->a[6], pBData->a[7],
				pBData->a[8], pBData->a[9], pBData->a[10], pBData->a[11],
				pBData->a[12], pBData->a[13], pBData->a[14], pBData->a[15]);

			nAreaN = (nSBlockIdx * 3) / nSTrailer;
			nAreaAccess = GetMfAreaAccess(nAccessBits, nAreaN);

			// Если это блок-прицеп,
			if (nSBlockIdx == nSTrailer)
			{
				// Выводим параметры доступа прицепа
				_tprintf(TEXT("  Прицеп. Доступ (%d, %d, %d): "),
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
				_tprintf(TEXT("  Данные. Доступ (%d, %d, %d)"),
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
		}
		_tprintf(TEXT("-----\n"));
	}
	catch (std::exception &e)
	{
		printf("%s\r\n", e.what());
	}
}

void DoWriteClassic(IILReader *pReader)
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
		_tprintf(TEXT("Введите байты 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 (16-ричные):\n"));
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

		int nBlockIdx;
		bool fTrailer;
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
			if (((nAccessBits & 0xFFF) ^ (nAccessBits >> 12)) != 0xFFF)
			{
				_tprintf(TEXT("Некорректное значение битов доступа. Запись отменена\n"));
				return;
			}
			// Выводим ключ A
			UINT64 nKeyA = 0;
			memcpy_s(&nKeyA, sizeof(nKeyA), rBlockData.a, 6);
			_tprintf(_T("Ключ A: 0x%.12I64X\n"), nKeyA);
			// Выводим ключ B
			UINT64 nKeyB = 0;
			memcpy_s(&nKeyB, sizeof(nKeyB), &rBlockData.a[10], 6);
			_tprintf(_T("Ключ B: 0x%.12I64X\n"), nKeyB);
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
			ILRCheck(pReader->LoadMfAuthKey(g_AuthKey));
			BOOL fAuthOk;
			ILRCheck(pReader->AuthMfCard(nBlockIdx, g_fAuthKeyB, &fAuthOk));
			if (!fAuthOk)
			{
				_tprintf(_T("Ключ аутентификации не подошёл\n"));
				return;
			}
		}
		int nWritten;
		ILRCheck(pReader->WriteMfClassic(nBlockIdx, &rBlockData, 1, &nWritten));
		DWORD nSpan = GetTickSpan(nStartTick, GetTickCount());
		_tprintf(_T("записано %d блок за %d мс\n"), nWritten, nSpan);
	}
	catch (std::exception &e)
	{
		printf("%s\r\n", e.what());
	}
}

void DoWriteAuthKeyToReader(IILReader *pReader)
{
	try
	{
		_tprintf(TEXT("Введите номер ключа (10-тичное) и значение ключа (16-тичное):\n"));
		int nKeyIdx;
		MfClassicKey nAuthKey;
		if (_tscanf_s(TEXT("%d %I64X"), &nKeyIdx, &nAuthKey) != 2)
		{
			_tprintf(TEXT("Неправильный ввод\n"));
			return;
		}

		_tprintf(TEXT("Запись... "));
		DWORD nStartTick = GetTickCount();
		int nWritten;
		ILRCheck(pReader->WriteMfAuthKeyToReader(nKeyIdx, g_fAuthKeyB, &nAuthKey, 1, &nWritten));
		DWORD nSpan = GetTickSpan(nStartTick, GetTickCount());
		_tprintf(_T("записано %d ключей за %d мс\n"), nWritten, nSpan);

		// Сохраняем ключ в файл настроек
		SaveRdKey(nKeyIdx, g_fAuthKeyB, nAuthKey);
	}
	catch (std::exception &e)
	{
		printf("%s\r\n", e.what());
	}
}

#pragma region Функции просмотра/изменения настроек
void DoSwitchAuthKeyType()
{
	_tprintf(TEXT("Введите тип ключа A или B:\n"));
	TCHAR sz[2];
	if (_tscanf_s(TEXT("%1s"), sz, (unsigned)_countof(sz)) != 1)
	{
		_tprintf(TEXT("Неправильный ввод\n"));
		return;
	}
	*sz = toupper(*sz);
	if (*sz == _T('A'))
		g_fAuthKeyB = false;
	else if (*sz == _T('B'))
		g_fAuthKeyB = true;
	else
	{
		_tprintf(TEXT("Неправильный ввод\n"));
		return;
	}
	// Сохраняем тип ключа в файл настроек
	SaveKeyType();
}

void DoEnterAuthKey()
{
	_tprintf(TEXT("Введите ключ аутентификации (16-ричное):\n"));
	MfClassicKey nAuthKey;
	if ((_tscanf_s(TEXT("%I64X"), &nAuthKey) != 1) || (nAuthKey > 0xffffffffffffLL))
	{
		_tprintf(TEXT("Неправильный ввод\n"));
		return;
	}
	g_AuthKey = nAuthKey;
	// Сохраняем ключ в файл настроек
	SaveAuthKey();
}

void DoSelectRdAuthKeys()
{
	_tprintf(TEXT("Введите номера ключей аутентификации (0..15) или \"=\" + битовую маску (16-ричное):\n"));
	TCHAR szInput[256];
	if (_tscanf_s(TEXT("%255s"), szInput, (unsigned)_countof(szInput)) != 1)
	{
		_tprintf(TEXT("Неправильный ввод\n"));
		return;
	}
	LPTSTR p;
	if (*szInput == _T('='))
		g_nRdKeys = _tcstoul(szInput + 1, &p, 16);
	else
	{
		LPCTSTR pszDelimiters = _T(" ,;");
		p = NULL;
		LPTSTR pToken;
		int nKeyIdx;
		rsize_t s1max = _countof(szInput);
		g_nRdKeys = 0;
		pToken = _tcstok_s(szInput, &s1max, pszDelimiters, &p);
		while (pToken != NULL)
		{
			nKeyIdx = _ttoi(pToken);
			if ((nKeyIdx >= 0) && (nKeyIdx < 16))
				g_nRdKeys |= (1 << nKeyIdx);
			pToken = _tcstok_s(NULL, &s1max, pszDelimiters, &p);
		}
	}
	// Сохраняем биты ключей в файл настроек
	SaveRdKeys();
}

void ShowSavedReaderKeys()
{
	for (int i = 0; i < _countof(g_aSavedRdKeys); ++i)
	{
		_tprintf(TEXT("Сохранённые ключи %c:\n"), i ? _T('B') : _T('A'));
		for (int j = 0; j < _countof(g_aSavedRdKeys[i]); ++j)
		{
			if (g_aSavedRdKeys[i][j] != (MfClassicKey)-1)
				_tprintf(TEXT("%2d: %.12I64X\n"), j, g_aSavedRdKeys[i][j]);
			else
				_tprintf(TEXT("%2d: -\n"), j);
		}
		_tprintf(TEXT("\n"));
	}
}
#pragma endregion

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

		// Ищем считыватель
		_tprintf(_T("Поиск считывателя... "));
		TComInterface<IILRSearch> oSearch;
		ILRCheck(oILR->GetSearch(&oSearch));
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
		bool fCanRW = (rRI.CanRWCardTypes() & RWCT_F_MFCLASSIC) != 0;
		// Инициализируем список сохранённых ключей считывателя
		for (int i = 0; i < _countof(g_aSavedRdKeys); ++i)
			for (int j = 0; j < _countof(g_aSavedRdKeys[i]); ++j)
				g_aSavedRdKeys[i][j] = (MfClassicKey)-1;
		// Загружаем настройки из файла
		LoadSettings();

		while (true)
		{
			_tprintf(TEXT("Поиск карты Mifare Classic... "));
			ILRCheck(oReader->Scan(FALSE));
			ilr::CardInfo rCI;
			ILRCheck(oReader->GetCardInfo(&rCI));
			bool fCardFound = rCI.IsMfClassicMode();
			// Если карта Mifare Classic найдена,
			if (fCardFound)
			{
				CString sUID;
				CardUIDToStr(rCI.nType, rCI.rUID, &sUID);
				_tprintf(TEXT("%s %s\n"), ilr::kCardTypeNames[rCI.nType], sUID.c_str());
			}
			else // Mifare Classic не найдена
				_tprintf(TEXT("не найдена\n"));

			_tprintf(TEXT("-----\n"));
			_tprintf(TEXT("Введите номер команды:\n"));
			_tprintf(TEXT("1 - Искать снова\n"));
			if (fCardFound && fCanRW)
			{
				_tprintf(TEXT("2 - Прочитать данные из карты\n"));
				_tprintf(TEXT("3 - Записать данные на карту...\n"));
			}

			_tprintf(TEXT("4 - Записать ключ аутентификации в считыватель...\n"));
			_tprintf(TEXT("5 - Переключить тип ключа A или B [%c]...\n"),
				g_fAuthKeyB ? _T('B') : _T('A'));
			_tprintf(TEXT("6 - Ввести ключ аутентификации [0x%.12I64X]...\n"),
				g_AuthKey);
			_tprintf(TEXT("7 - Выбрать ключи аутентификации считывателя [0x%X]...\n"),
				g_nRdKeys);
			_tprintf(TEXT("8 - Показать сохранённые ключи считывателя\n"));
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
						DoReadClassic(oReader);
					continue;

				case 3:
					if (fCardFound && fCanRW)
						DoWriteClassic(oReader);
					continue;

				case 4:
					DoWriteAuthKeyToReader(oReader);
					continue;

				case 5:
					DoSwitchAuthKeyType();
					continue;

				case 6:
					DoEnterAuthKey();
					continue;

				case 7:
					DoSelectRdAuthKeys();
					continue;

				case 8:
					ShowSavedReaderKeys();
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
