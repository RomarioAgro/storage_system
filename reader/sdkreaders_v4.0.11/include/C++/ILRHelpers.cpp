#include "pch.h"
#include "ILRHelpers.h"
#include <time.h>


//////////////////////////////////////////////////////////////////////////
// CILRLoader

CILRLoader::CILRLoader() ILR_NOEXCEPT
{
	m_hr = ilr::LoadILR();
}
	
CILRLoader::~CILRLoader() ILR_NOEXCEPT
{
	if (SUCCEEDED(m_hr))
		ilr::UnloadILR();
}

namespace ilr
{
	const LPCTSTR kRdModelNames[] = {
		_T(""),
		_T("Z-2 RD_ALL"),
		_T("Z-2 USB MF"),
		_T("Z-2 MF-I"),
		_T("Z-2 EHR"),
		_T("Z-2 Base"),
		_T("RF-1996"),
		_T("Matrix III Rd-All"),
		_T("Matrix III Net"),
		_T("CP-Z 2MF"),
		_T("Matrix V"),
		_T("Z-2 MF CCID"),
		_T("Matrix-VI (NFC K Net)")
	};
	const LPCTSTR kCardTypeNames[] = {
		_T(""),
		_T("Em-Marine"),
		_T("HID"),
		_T("iCode"),
		_T("Cod433"),
		_T("Cod433 Fix"),
		_T("CAME"),
		_T("Dallas"),
		_T("Temic"),
		_T("Mifare UltraLight"),
		_T("Mifare UltraLight C"),
		_T("Mifare Mini"),
		_T("Mifare Classic 1K"),
		_T("Mifare Classic 2K"),
		_T("Mifare Classic 4K"),
		_T("Smart MX with Mifare Classic 1K"),
		_T("Smart MX with Mifare Classic 4K"),
		_T("Mifare Plus"),
		_T("Mifare Plus 1K"),
		_T("Mifare Plus 2K"),
		_T("Mifare Plus 4K"),
		_T("Mifare DESFire"),
		_T("Mifare ProX")
	};
	const LPCTSTR kMpTypeNames[] = {
		_T(""),
		_T("S"),
		_T("X"),
		_T("SE"),
		_T("EV1"),
		_T("EV2")
	};

	//////////////////////////////////////////////////////////////////////////
	// CILRException

	CILRException::CILRException(HRESULT hr, LPCTSTR pszErrorText /*= NULL*/) :
		m_hr(hr)
	{
		if (pszErrorText != NULL)
			toAnsiString(pszErrorText, -1, &m_sErrorText);
		else
		{
			DWORD nFlags = FORMAT_MESSAGE_ALLOCATE_BUFFER;
			LPCVOID pSource;
			if (HRESULT_FACILITY(hr) == FACILITY_ITF)
			{
				pSource = GetModuleHandle(ILR_DLL_NAME);
				nFlags |= FORMAT_MESSAGE_FROM_HMODULE;
			}
			else
			{
				pSource = NULL;
				nFlags |= FORMAT_MESSAGE_FROM_SYSTEM;
			}

			LPSTR pBuffer = NULL;
			try
			{
				DWORD nLen = ::FormatMessageA(nFlags, pSource, hr, 0, (LPSTR)&pBuffer, 0, NULL);
				m_sErrorText.assign(pBuffer, nLen);
			}
			catch(...)
			{
			}
			if (pBuffer)
				LocalFree(pBuffer);
		}
	}

	CILRException::~CILRException() ILR_NOEXCEPT
	{
	}

	char const* CILRException::what() const
	{
		return m_sErrorText.c_str();
	}

	VOID ILRCheck(HRESULT hr)
	{
		if (FAILED(hr))
			throw CILRException(hr);
	}

	VOID ILRGetErrorText(HRESULT hr, CString *pText)
	{
		ASSERT(pText != NULL);

		DWORD nFlags = FORMAT_MESSAGE_ALLOCATE_BUFFER;
		LPCVOID pSource;
		if (HRESULT_FACILITY(hr) == FACILITY_ITF)
		{
			pSource = GetModuleHandle(ILR_DLL_NAME);
			nFlags |= FORMAT_MESSAGE_FROM_HMODULE;
		}
		else
		{
			pSource = NULL;
			nFlags |= FORMAT_MESSAGE_FROM_SYSTEM;
		}

		LPTSTR pBuffer = NULL;
		__try
		{
			DWORD nLen = ::FormatMessage(nFlags, pSource, hr, 0, (LPTSTR)&pBuffer, 0, NULL);
			pText->assign(pBuffer, nLen);
		}
		__finally
		{
			if (pBuffer)
				LocalFree(pBuffer);
		}
	}

#ifndef _versionhelpers_H_INCLUDED_
	BOOL IsWindowsVistaOrGreater()
	{
		OSVERSIONINFOEX osvi = { sizeof(osvi), 0, 0, 0, 0, {0}, 0, 0 };
		DWORDLONG nlConditionMask = 0;
		int op = VER_GREATER_EQUAL;
		osvi.dwMajorVersion = HIBYTE(_WIN32_WINNT_VISTA);
		VER_SET_CONDITION(nlConditionMask, VER_MAJORVERSION, op);
		return VerifyVersionInfo(&osvi, VER_MAJORVERSION, nlConditionMask);
	}
#endif

	int toAnsiString(LPCWSTR pszSrc, int nSrcLen, std::string* pDst)
	{
		ASSERT(pszSrc != NULL);
		ASSERT((nSrcLen >= 0) || (-1 == nSrcLen));

		if (-1 == nSrcLen)
			nSrcLen = (int)wcslen(pszSrc);
		int nSize = WideCharToMultiByte(CP_ACP, 0, pszSrc, nSrcLen, NULL, 0, NULL, NULL);
		if (nSize > 0)
		{
			pDst->resize(nSize);
			if (WideCharToMultiByte(CP_ACP, 0, pszSrc, nSrcLen, const_cast<char*>(pDst->data()), (INT)pDst->size(), NULL, NULL) > 0)
				pDst->resize(nSize);
			else
				pDst->clear();
		}
		else
			pDst->clear();

		return (int)pDst->length();
	}

	VOID VersionToStr(DWORD nVersion, CString* pStr)
	{
		ASSERT(pStr != NULL);

		pStr->clear();
		if (0 == nVersion)
			return;
		if ((nVersion & 0xFF) == 0xFF)
		{
			nVersion >>= 8;
			pStr->resize(12);
#if defined(_MSC_VER)
			_ultot_s(nVersion, const_cast<LPTSTR>(pStr->data()), pStr->size(), 10);
#else
			_ultot(nVersion, const_cast<LPTSTR>(pStr->data()), 10);
#endif
			pStr->resize(_tcslen(pStr->c_str()));
			return;
		}
		DWORD nMask = 0xFF000000;
		int nLen = 4;
		while (nMask != 0)
		{
			if ((nVersion & nMask) != 0)
				break;
			--nLen;
			nMask >>= 8;
		}
		if (nLen != 0)
		{
			TCHAR szBuf[4];
			pStr->reserve(4 * nLen);
#if defined(_MSC_VER)
			_itot_s(nVersion & 0xFF, szBuf, 10);
#else
			_itot(nVersion & 0xFF, szBuf, 10);
#endif
			pStr->append(szBuf);
			nVersion >>= 8;
			for (int i = 1; i < nLen; i++)
			{
#if defined(_MSC_VER)
				_itot_s(nVersion & 0xFF, szBuf, 10);
#else
				_itot(nVersion & 0xFF, szBuf, 10);
#endif
				pStr->push_back(_T('.'));
				pStr->append(szBuf);
				nVersion >>= 8;
			}
		}
	}

	INT_PTR TimeToStr(const time_t& tTime, LPCTSTR pszFmt, CString *pStr)
	{
		ASSERT((pszFmt != NULL) && (pStr != NULL));

		INT_PTR nRes;
		TCHAR szBuffer[128];

#if __BORLANDC__
		tm ptmTemp;
		if (localtime_s(&tTime, &ptmTemp) == NULL)
			nRes = 0;
		else
			nRes = (INT_PTR)_tcsftime(szBuffer, _countof(szBuffer), pszFmt, &ptmTemp);
#else
		struct tm ptmTemp;
		errno_t err = _localtime64_s(&ptmTemp, &tTime);
		if (err != 0)
			nRes = 0;
		else
			nRes = (INT_PTR)_tcsftime(szBuffer, _countof(szBuffer), pszFmt, &ptmTemp);
#endif
		if (nRes > 0)
			pStr->assign(szBuffer);
		else
			pStr->clear();
		return nRes;
	}

	bool IsFileExists(LPCTSTR szPath)
	{
		ASSERT(szPath != NULL);

		DWORD nFAttr = GetFileAttributes(szPath);
		return (nFAttr != INVALID_FILE_ATTRIBUTES) && ((nFAttr & FILE_ATTRIBUTE_DIRECTORY) == 0);
	}

	void CardUIDToStr(CardType nType, const CardUID &rUId, CString *pStr)
	{
		ASSERT(pStr != NULL);

		switch (nType)
		{
		case ilr::cEmMarine:
		case ilr::cICode:
		case ilr::cCod433:
		case ilr::cCod433Fix:
		case ilr::cCame433:
		{
			pStr->resize(32);
			int n = _stprintf_s((LPTSTR)pStr->data(), pStr->size(), TEXT("[%.2X%.2X] %.3u,%.5u"), 
				rUId.aBytes[4], rUId.aBytes[3], rUId.aBytes[2], *(PWORD)rUId.aBytes);
			pStr->resize(max(n, 0));
			break;
		}

		case ilr::cHID:
		{
			DWORD nFacility = 0;
			int nFLen = min(rUId.nLength - 2, 4);
			memcpy_s(&nFacility, sizeof(nFacility), &rUId.aBytes[2], nFLen);
			pStr->resize(32);
			int n = _stprintf_s((LPTSTR)pStr->data(), pStr->size(), TEXT("[%.*X] %u"), 
				nFLen * 2, nFacility, *(PWORD)rUId.aBytes);
			pStr->resize(max(n, 0));
			break;
		}

		default:
		{
			pStr->resize(rUId.nLength * 2 + 1);
			INT j = 0;
			for (INT i = (rUId.nLength - 1); i >= 0; i--, j += 2)
				_stprintf_s(&(*pStr)[j], pStr->size() - j, TEXT("%.2X"), rUId.aBytes[i]);
			pStr->resize(rUId.nLength * 2);
			break;
		}
		}
	}

	int GetMfSectorByBlock(int nBlock)
	{
		return (nBlock < 128) ? (nBlock / 4) : (32 + ((nBlock - 128) / 16));
	}

	DWORD GetMfAccessBits(const MfBlockData &rTrailerData)
	{
		DWORD nAccessBits = 0;
		memcpy_s(&nAccessBits, sizeof(nAccessBits), &rTrailerData.a[6], 3);
		return nAccessBits;
	}

	DWORD GetMfAreaAccess(DWORD nAccessBits, INT nArea)
	{
		return ((nAccessBits >> (12 + nArea)) & 1) | 
			(((nAccessBits >> (16 + nArea)) & 1) << 1) |
			(((nAccessBits >> (20 + nArea)) & 1) << 2);
	}

}; // namespace ilr
