// CardDetector.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include "ILReaders.h"
#include "ILRHelpers.h"
#include <atlcomcli.h>
#include <locale>

using namespace ilr;


void CALLBACK ReaderNotify(ReaderMsg nMsg, LPCVOID pMsgData, void *pUserData)
{
	switch (nMsg)
	{
	case ilr::rmCardFound:	// Карта поднесена
	case ilr::rmCardLost:	// Карта удалена
	{
		ilr::CardInfo *pCI = (ilr::CardInfo *)pMsgData;
		CString sUID, s;
		CardUIDToStr(pCI->nType, pCI->rUID, &sUID);
		if (pCI->nMpType != mptUnknown)
		{
			s += _T(' ');
			s += kMpTypeNames[pCI->nMpType];
		}
		if (pCI->nSL != mpslUnknown)
		{
			s += _T(" SL");
			s += _T('0') + pCI->nSL;
		}
		_tprintf(_T("{!} %s карта %s %s%s\n"),
			(ilr::rmCardFound == nMsg) ? _T("Найдена") : _T("Потеряна"),
			ilr::kCardTypeNames[pCI->nType], 
			sUID.c_str(), s.c_str());
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
		// Подключаемся к считывателю
		_tprintf(_T("Подключение к считывателю... "));
		ILRCheck(oReader->Connect());
		_tprintf(_T("успешно\n"));
		// Устанавливаем функцию для получения уведомлений об поднесении/удалении карты
		ILRCheck(oReader->SetNotifyCallback(ReaderNotify, NULL));
		_tprintf(_T("Ожидание поднесения карты...\n"));

		getchar();
	}
	catch (std::exception &e)
	{
		printf("%s\r\n", e.what());
		getchar();
	}

	return 0;
}
