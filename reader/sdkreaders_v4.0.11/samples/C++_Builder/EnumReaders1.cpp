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
		oILR.Release();
		// Выбираем типы считывателей для поиска
		ILRCheck(oSearch->SetReaderTypes(ilr::RT_F_ILUSB | ilr::RT_F_TPUSB | ilr::RT_F_CCID));
		// Ищем считыватели
		_tprintf(_T("Поиск считывателей... "));
		ILRCheck(oSearch->Scan());
		// Перечисляем найденные считыватели
		INT nCount = 0;
		ILRCheck(oSearch->GetReaderCount(&nCount));
		if (nCount != 0)
		{
			_tprintf(_T("найдено %d считывателей:\n"), nCount);
			ilr::ReaderInfo rRI;
			CString sVersion, sTime;
			for (int i = 0; i < nCount; i++)
			{
				ILRCheck(oSearch->GetReaderInfo(i, &rRI));
				_tprintf(_T("%d. %s: %s"),
					1 + i,
					rRI.szPortName,
					ilr::kRdModelNames[rRI.nModel]);

				if (rRI.nSn != -1)
					_tprintf(_T(" с/н:%d"), rRI.nSn);

				if (rRI.nFwVersion != 0)
				{
					VersionToStr(rRI.nFwVersion, &sVersion);
					_tprintf(_T(" прошивка:%s"), sVersion.c_str());
				}
				if (rRI.nFwBuildDate != 0)
				{
					TimeToStr(rRI.nFwBuildDate, _T("%c"), &sTime);
					_tprintf(_T(" сборка %s"), sTime.c_str());
				}
				_tprintf(_T("\n"));
			}
		}
		else
			_tprintf(_T("не найдены\n"));
	}
	catch(std::exception &e)
	{
		printf("%s\r\n", e.what());
	}
	getchar();

	return 0;
}
