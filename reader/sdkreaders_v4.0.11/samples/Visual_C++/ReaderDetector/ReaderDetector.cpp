// ReaderDetector.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include "ILReaders.h"
#include "ILRHelpers.h"
#include <atlcomcli.h>
#include <locale>

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
	{
		_tprintf(_T("{!} Список считыватель изменился\n"));
		break;
	}
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
		// Получает интерфейс поиска считывателей
		CComPtr<IILRSearch> oSearch;
		ILRCheck(oILR->GetSearch(&oSearch.p));
		ILRCheck(oSearch->SetReaderTypes(RT_F_ILUSB | RT_F_TPUSB | RT_F_CCID));
		// Устанавливаем функцию для получения сообщений о подключении/отключении считывателей
		ILRCheck(oSearch->SetNotifyCallback(SearchNotify, NULL));
		// Включаем авто поиск считывателей
		ILRCheck(oSearch->EnableAutoScan());
		_tprintf(_T("Поиск считывателей...\n"));
		getchar();
	}
	catch (std::exception &e)
	{
		printf("%s\r\n", e.what());
		getchar();
	}

	return 0;
}
