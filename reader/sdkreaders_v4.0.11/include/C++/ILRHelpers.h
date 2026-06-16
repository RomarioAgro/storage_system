#pragma once
#include "ILReaders.h"
#include <Windows.h>
#include <tchar.h>
#include <assert.h>
#include <exception>
#include <string>

using namespace std;

#ifdef _DEBUG

#if __BORLANDC__
	#define ASSERT(f)	assert(f)
#else
	#define ASSERT(f)	_ASSERT(f)
#endif

#else   // _DEBUG

#define ASSERT(f)	((VOID)0)

#endif // !_DEBUG

#if !defined(_countof)
#if __BORLANDC__ >= 0x0620
#define _countof(array)		RTL_NUMBER_OF(array)
#else
#define _countof(array)		sizeof(array)/sizeof(array[0])
#endif
#endif

typedef wstring CString;


#define GetTickSpan(old, curr)	(DWORD)((curr >= old) ? (curr - old) : (MAXDWORD - old + curr))
#define GetBit(val, bitN)		(BOOL)((val >> (bitN)) & 1)


/////////////////////////////////////////////////////////////////////////////
// CILRLoader - загружает/выгружает библиотеку "ILReaders.dll"

class CILRLoader
{
public:
	HRESULT m_hr;

public:
	CILRLoader() ILR_NOEXCEPT;
	~CILRLoader() ILR_NOEXCEPT;
};


namespace ilr
{
	// Названия моделей считывателей
	extern const LPCTSTR kRdModelNames[rmSize];
	// Название типов карт
	extern const LPCTSTR kCardTypeNames[cCardTypeSize];
	// Название подтипов карт Mifare Plus
	extern const LPCTSTR kMpTypeNames[mptSize];

	//////////////////////////////////////////////////////////////////////////
	// CILRException - ошибка ILReaders.dll

	class CILRException :
		public exception
	{
	public:
		HRESULT m_hr;
		string m_sErrorText;

	public:
		CILRException(HRESULT hr, LPCTSTR pszErrorText = NULL);
		virtual ~CILRException() ILR_NOEXCEPT;

		char const* what() const;
	};

	VOID ILRCheck(HRESULT hr);
	VOID ILRGetErrorText(HRESULT hr, CString *pText);

#ifndef _versionhelpers_H_INCLUDED_
	// Возвращает TRUE если текущая версия Windows = Vista или более новая
	BOOL IsWindowsVistaOrGreater();
#endif
	// Преобразует Wide строку в Ansi строку
	int toAnsiString(LPCWSTR pszSrc, int nSrcLen, std::string* pDst);
	// Преобразует версию 0x04030201 в строку в формате '1.2.3.4'
	VOID VersionToStr(DWORD nVersion, CString* pStr);
	// Преобразует дату и время в строку
	INT_PTR TimeToStr(const time_t& tTime, LPCTSTR pszFmt, CString *pStr);
	// Возвращает TRUE если файл существует по указанному пути
	bool IsFileExists(LPCTSTR szPath);
	// Преобразует ID карты в строку
	void CardUIDToStr(CardType nType, const CardUID &rUId, CString *pStr);
	// Возвращает номер сектора по номеру блока Mifare
	int GetMfSectorByBlock(int nBlock);
	// Возвращает биты доступа сектора Mifare
	DWORD GetMfAccessBits(const MfBlockData &rTrailerData);
	// Возвращает биты доступа для области сектора Mifare (3 бита)
	DWORD GetMfAreaAccess(DWORD nSectorAccess, INT nArea);
}; // namespace ilr
