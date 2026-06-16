#include "pch.h"
#pragma hdrstop

//#include <initguid.h>
#include "ILReaders.h"


namespace ilr
{

#ifdef ILREADERS_LINKONREQUEST

	ILR_GETVERSION ILR_GetVersion = NULL;
	ILR_GETERRORTEXT ILR_GetErrorText = NULL;
	ILR_GETINTERFACE ILR_GetInterface = NULL;

	HMODULE	g_hILRLib = 0;
	ULONG g_nILRLoadCount = 0;

	bool IsILRLoaded()
	{
		return (g_hILRLib != NULL);
	}

	HRESULT LoadILR(LPCTSTR pszPath /*= NULL*/)
	{
		if (g_nILRLoadCount > 0)
		{
			++g_nILRLoadCount;
			return S_OK;
		}
		HRESULT hr;
		g_hILRLib = LoadLibrary(pszPath ? pszPath : ILR_DLL_NAME);
		if (g_hILRLib == 0)
			return HRESULT_FROM_WIN32(GetLastError());
		if (((ILR_GetVersion = (ILR_GETVERSION)GetProcAddress(g_hILRLib, "ILR_GetVersion")) != NULL) &&
			((ILR_GetErrorText = (ILR_GETERRORTEXT)GetProcAddress(g_hILRLib, "ILR_GetErrorText")) != NULL) &&
			((ILR_GetInterface = (ILR_GETINTERFACE)GetProcAddress(g_hILRLib, "ILR_GetInterface")) != NULL))
		{
			++g_nILRLoadCount;
			hr = S_OK;
		}
		else
			hr = ILR_E_WRONG_SDK_VERSION;
		if (FAILED(hr))
			UnloadILR();
		return hr;
	}

	VOID UnloadILR()
	{
		if (0 == g_nILRLoadCount)
			return;
		--g_nILRLoadCount;
		FreeLibrary(g_hILRLib);
		g_hILRLib = NULL;
		ILR_GetVersion = NULL;
		ILR_GetErrorText = NULL;
		ILR_GetInterface = NULL;
	}

#else

	bool IsILRLoaded()
	{
		return true;
	}

	HRESULT LoadILR(LPCTSTR pszPath /*= NULL*/)
	{
		return S_OK;
	}

	VOID UnloadILR()
	{
	}

#endif // ILREADERS_LINKONREQUEST

	bool CheckSdkVersion()
	{
		DWORD nVersion = ILR_GetVersion();
		return ((nVersion & 0xffff) == ILR_SDK_VERSION);
	}


}; // namespace ilr
