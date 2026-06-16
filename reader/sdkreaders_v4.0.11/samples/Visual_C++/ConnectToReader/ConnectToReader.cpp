// ConnectToReader.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include "ILReaders.h"
#include "ILRHelpers.h"
#include <atlcomcli.h>
#include <locale>

using namespace ilr;


void CALLBACK ReaderNotify(ReaderMsg nMsg, LPCVOID pMsgData, void *pUserData)
{
	if (ilr::rmConnectionChanged == nMsg)
	{
		try
		{
			IILReader *pReader = (IILReader *)pUserData;
			ConnectionStatus nStatus;
			ILRCheck(pReader->GetConnectionStatus(&nStatus));
			switch (nStatus)
			{
			case ilr::csDisconnected:
				_tprintf(TEXT("Считыватель отключён\n"));
				break;
			case ilr::csConnected:
				_tprintf(TEXT("Считыватель подключён\n"));
				break;
			case ilr::csConnecting:
				_tprintf(TEXT("Идёт подключение к считывателю\n"));
				break;
			}
		}
		catch (std::exception &e)
		{
			printf("%s\r\n", e.what());
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
		// Получаем информацию о считывателе
		ILRCheck(oReader->GetReaderInfo(&rRI));
		_tprintf(_T("%s: %s"),
			rRI.szPortName,
			ilr::kRdModelNames[rRI.nModel]);
		if (rRI.nSn != -1)
			_tprintf(_T(" с/н:%d"), rRI.nSn);
		if (rRI.nFwVersion != 0)
		{
			CString sVersion;
			VersionToStr(rRI.nFwVersion, &sVersion);
			_tprintf(_T(" прошивка:%s"), sVersion.c_str());
		}
		if (rRI.nFwBuildDate != 0)
		{
			CString sTime;
			TimeToStr(rRI.nFwBuildDate, _T("%c"), &sTime);
			_tprintf(_T(" сборка %s"), sTime.c_str());
		}
		// Устанавливаем функцию для получения сообщений об потери/восстановлении связи 
		//	со считывателем
		ILRCheck(oReader->SetNotifyCallback(ReaderNotify, oReader.p));
		_tprintf(_T("\n"));

		while (true)
		{
			_tprintf(TEXT("-----\n"));
			_tprintf(TEXT("Введите номер команды:\n"));
			_tprintf(TEXT("1 - Подключиться\n"));
			_tprintf(TEXT("2 - Отключиться\n"));
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
					ILRCheck(oReader->Connect());
					continue;

				case 2:
					ILRCheck(oReader->Disconnect());
					continue;
				}
			}
			_tprintf(TEXT("Неправильный ввод\n"));
		}
	}
	catch (std::exception &e)
	{
		printf("%s\r\n", e.what());
	}
	getchar();

	return 0;
}
