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

void CALLBACK SearchNotify(SearchMsg nMsg, LPCVOID pMsgData, void *pUserData)
{
	switch (nMsg)
	{
	case smReaderFound:	// Считыватель найден
	case smReaderLost:	// Считыватель потерян
	{
		ilr::ReaderInfo *pRI = (ilr::ReaderInfo *)pMsgData;

		_tprintf(_T("{!} %s считыватель (%s): %s"),
			(smReaderFound == nMsg) ? _T("Найден") : _T("Потерян"),
			pRI->szPortName,
			ilr::kRdModelNames[pRI->nModel]);
		if (pRI->nSn != -1)
			_tprintf(_T(" с/н:%d"), pRI->nSn);
		if (pRI->nFwVersion != 0)
		{
			CString sVersion;
			VersionToStr(pRI->nFwVersion, &sVersion);
			_tprintf(_T(" прошивка:%s"), sVersion.c_str());
		}
		if (pRI->nFwBuildDate != 0)
		{
			CString sTime;
			TimeToStr(pRI->nFwBuildDate, _T("%c"), &sTime);
			_tprintf(_T(" сборка %s"), sTime.c_str());
		}
		_tprintf(_T("\n"));
		break;
	}

	case smListChanged:	// Список считывателей изменился
		_tprintf(_T("{!} Список считыватель изменился\n"));
		break;
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
		oILR.Release();
		// Выбираем типы считывателей для поиска
		ILRCheck(oSearch->SetReaderTypes(ilr::RT_F_ILUSB | ilr::RT_F_TPUSB | ilr::RT_F_CCID));
		// Устанавливаем функцию для получения сообщений о нахождении/потери считывателей
		ILRCheck(oSearch->SetNotifyCallback(SearchNotify, NULL));
		// Включаем авто поиск считывателей
		ILRCheck(oSearch->EnableAutoScan());

		getchar();
	}
	catch(std::exception &e)
	{
		printf("%s\r\n", e.what());
		getchar();
	}

	return 0;
}
