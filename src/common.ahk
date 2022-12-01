#CommentFlag //

global hGTA := 0x0
global dwGTAPID := 0x0
global dwSAMP := 0x0
global pMemory := 0x0
global pParam1 := 0x0
global pParam2 := 0x0
global pParam3 := 0x0
global pParam4 := 0x0
global pParam5 := 0x0
global pInjectFunc := 0x0
global iRefreshHandles := 0

global GAME_MP_ModuleName := "azmp.dll" // Название модуля мультиплеера
global GAME_PID := "AMAZING ONLINE" // Заголовок окна игры


waitForSingleObject(hThread, dwMilliseconds) {
	if (!hThread) {
		ErrorLevel := ERROR_INVALID_HANDLE
		return 0
	}
	
	dwRet := DllCall("WaitForSingleObject", "UInt", hThread, "UInt", dwMilliseconds, "UInt")
	if (dwRet == 0xFFFFFFFF) {
		ErrorLEvel := ERROR_WAIT_FOR_OBJECT
		return 0
	}
	
	ErrorLevel := ERROR_OK
	return dwRet
}
createRemoteThread(hProcess, lpThreadAttributes, dwStackSize, lpStartAddress, lpParameter, dwCreationFlags, lpThreadId) {
	if (!hProcess) {
		ErrorLevel := ERROR_INVALID_HANDLE
		return 0
	}
	
	dwRet := DllCall("CreateRemoteThread", "UInt", hProcess, "UInt", lpThreadAttributes, "UInt", dwStackSize, "UInt", lpStartAddress, "UInt", lpParameter, "UInt", dwCreationFlags, "UInt", lpThreadId, "UInt")
	if (dwRet == 0) {
		ErrorLEvel := ERROR_ALLOC_MEMORY
		return 0
	}
	
	ErrorLevel := ERROR_OK
	return dwRet
}
virtualFreeEx(hProcess, lpAddress, dwSize, dwFreeType) {
	if (!hProcess) {
		ErrorLevel := ERROR_INVALID_HANDLE
		return 0
	}
	
	dwRet := DllCall("VirtualFreeEx", "UInt", hProcess, "UInt", lpAddress, "UInt", dwSize, "UInt", dwFreeType, "UInt")
	if (dwRet == 0) {
		ErrorLEvel := ERROR_FREE_MEMORY
		return 0
	}
	ErrorLevel := ERROR_OK
	return dwRet
}
virtualAllocEx(hProcess, dwSize, flAllocationType, flProtect) {
	if (!hProcess) {
		ErrorLevel := ERROR_INVALID_HANDLE
		return 0
	}
	
	dwRet := DllCall("VirtualAllocEx", "UInt", hProcess, "UInt", 0, "UInt", dwSize, "UInt", flAllocationType, "UInt", flProtect, "UInt")
	if (dwRet == 0) {
		ErrorLEvel := ERROR_ALLOC_MEMORY
		return 0
	}
	
	ErrorLevel := ERROR_OK
	return dwRet
}
callWithParams(hProcess, dwFunc, aParams, bCleanupStack = true, thiscall = false) {
	if (!hProcess) {
		ErrorLevel := ERROR_INVALID_HANDLE
		return false
	}
	validParams := 0
	i := aParams.MaxIndex()
	dwLen := i * 5 + 5 + 1
	if (bCleanupStack)
		dwLen += 3
	VarSetCapacity(injectData, i * 5 + 5 + 3 + 1, 0)
	i_ := 1
	while(i > 0) {
		if (aParams[i][1] != "") {
			dwMemAddress := 0x0
			if (aParams[i][1] == "p") {
				dwMemAddress := aParams[i][2]
			} else if (aParams[i][1] == "s") {
				if (i_>3)
					return false
				dwMemAddress := pParam%i_%
				writeString(hProcess, dwMemAddress, aParams[i][2])
				if (ErrorLevel)
					return false
				i_ += 1
			} else if (aParams[i][1] == "i") {
				dwMemAddress := aParams[i][2]
			} else {
				return false
			}
			NumPut((thiscall && i == 1 ? 0xB9 : 0x68), injectData, validParams * 5, "UChar")
			NumPut(dwMemAddress, injectData, validParams * 5 + 1, "UInt")
			validParams += 1
		}
		i -= 1
	}
	offset := dwFunc - ( pInjectFunc + validParams * 5 + 5 )
	NumPut(0xE8, injectData, validParams * 5, "UChar")
	NumPut(offset, injectData, validParams * 5 + 1, "Int")
	if (bCleanupStack) {
		NumPut(0xC483, injectData, validParams * 5 + 5, "UShort")
		NumPut(validParams*4, injectData, validParams * 5 + 7, "UChar")
		NumPut(0xC3, injectData, validParams * 5 + 8, "UChar")
	} else {
		NumPut(0xC3, injectData, validParams * 5 + 5, "UChar")
	}
	writeRaw(hGTA, pInjectFunc, &injectData, dwLen)
	if (ErrorLevel)
		return false
	hThread := createRemoteThread(hGTA, 0, 0, pInjectFunc, 0, 0, 0)
	if (ErrorLevel)
		return false
	waitForSingleObject(hThread, 0xFFFFFFFF)
	closeProcess(hThread)
	return true
}
writeRaw(hProcess, dwAddress, pBuffer, dwLen) {
	if (!hProcess) {
		ErrorLevel := ERROR_INVALID_HANDLE
		return false
	}
	
	dwRet := DllCall("WriteProcessMemory", "UInt", hProcess, "UInt", dwAddress, "UInt", pBuffer, "UInt", dwLen, "UInt", 0, "UInt")
	if (dwRet == 0) {
		ErrorLEvel := ERROR_WRITE_MEMORY
		return false
	}
	
	ErrorLevel := ERROR_OK
	return true
}
writeString(hProcess, dwAddress, wString) {
	if (!hProcess) {
		ErrorLevel := ERROR_INVALID_HANDLE
		return false
	}
	
	sString := wString
	if (A_IsUnicode)
		sString := __unicodeToAnsi(wString)
	
	dwRet := DllCall("WriteProcessMemory", "UInt", hProcess, "UInt", dwAddress, "Str", sString, "UInt", StrLen(wString) + 1, "UInt", 0, "UInt")
	if (dwRet == 0) {
		ErrorLEvel := ERROR_WRITE_MEMORY
		return false
	}
	
	ErrorLevel := ERROR_OK
	return true
}
readMem(hProcess, dwAddress, dwLen=4, type="UInt") {
	if (!hProcess) {
		ErrorLevel := ERROR_INVALID_HANDLE
		return 0
	}
	
	VarSetCapacity(dwRead, dwLen)
	dwRet := DllCall("ReadProcessMemory", "UInt", hProcess, "UInt", dwAddress, "Str", dwRead, "UInt", dwLen, "UInt*", 0)
	if (dwRet == 0) {
		ErrorLevel := ERROR_READ_MEMORY
		return 0
	}
	
	ErrorLevel := ERROR_OK
	return NumGet(dwRead, 0, type)
}
readDWORD(hProcess, dwAddress) {
	if (!hProcess) {
		ErrorLevel := ERROR_INVALID_HANDLE
		return 0
	}
	
	VarSetCapacity(dwRead, 4)	// DWORD = 4
	dwRet := DllCall("ReadProcessMemory", "UInt", hProcess, "UInt", dwAddress, "Str", dwRead, "UInt", 4, "UInt*", 0)
	if (dwRet == 0) {
		ErrorLevel := ERROR_READ_MEMORY
		return 0
	}
	
	ErrorLevel := ERROR_OK
	return NumGet(dwRead, 0, "UInt")
}
readFloat(hProcess, dwAddress) {
	if (!hProcess) {
		ErrorLevel := ERROR_INVALID_HANDLE
		return 0
	}
	
	VarSetCapacity(dwRead, 4)	// float = 4
	dwRet := DllCall("ReadProcessMemory", "UInt", hProcess, "UInt", dwAddress, "Str", dwRead, "UInt", 4, "UInt*", 0, "UInt")
	if (dwRet == 0) {
		ErrorLevel := ERROR_READ_MEMORY
		return 0
	}
	
	ErrorLevel := ERROR_OK
	return NumGet(dwRead, 0, "Float")
}
readString(hProcess, dwAddress, dwLen) {
	if (!hProcess) {
		ErrorLevel := ERROR_INVALID_HANDLE
		return 0
	}
	
	VarSetCapacity(sRead, dwLen)
	dwRet := DllCall("ReadProcessMemory", "UInt", hProcess, "UInt", dwAddress, "Str", sRead, "UInt", dwLen, "UInt*", 0, "UInt")
	if (dwRet == 0) {
		ErrorLevel := ERROR_READ_MEMORY
		return 0
	}
	
	ErrorLevel := ERROR_OK
	if A_IsUnicode
		return __ansiToUnicode(sRead)
	return sRead
}
getModuleBaseAddress(sModule, hProcess) {
	if (!sModule) {
		ErrorLevel := ERROR_MODULE_NOT_FOUND
		return 0
	}
	
	if (!hProcess) {
		ErrorLevel := ERROR_INVALID_HANDLE
		return 0
	}
	
	dwSize = 1024*4					// 1024 * sizeof(HMODULE = 4)
	VarSetCapacity(hMods, dwSize)	
	VarSetCapacity(cbNeeded, 4)		// DWORD = 4
	dwRet := DllCall("Psapi.dll\EnumProcessModules", "UInt", hProcess, "UInt", &hMods, "UInt", dwSize, "UInt*", cbNeeded, "UInt")
	if (dwRet == 0) {
		ErrorLevel := ERROR_ENUM_PROCESS_MODULES
		return 0
	}
	
	dwMods := cbNeeded / 4			// cbNeeded / sizeof(HMDOULE = 4)
	i := 0
	VarSetCapacity(hModule, 4)		// HMODULE = 4
	VarSetCapacity(sCurModule, 260)	// MAX_PATH = 260
	while(i < dwMods) {
		hModule := NumGet(hMods, i*4)
		DllCall("Psapi.dll\GetModuleFileNameEx", 	"UInt", hProcess, 	"UInt", hModule, 	"Str", sCurModule, 	"UInt", 260)
		SplitPath, sCurModule, sFilename
		if (sModule == sFilename) {
			ErrorLevel := ERROR_OK
			return hModule
		}
		i := i + 1
	}
	
	ErrorLevel := ERROR_MODULE_NOT_FOUND
	return 0
}
closeProcess(hProcess) {
	if (hProcess == 0) {
		ErrorLevel := ERROR_INVALID_HANDLE
		return 0
	}
	
	dwRet := DllCall("CloseHandle", "Uint", hProcess, "UInt")
	ErrorLevel := ERROR_OK
}
openProcess(dwPID, dwRights = 0x1F0FFF) {
	hProcess := DllCall("OpenProcess", "UInt", dwRights, "int",  0, "UInt", dwPID, "Uint")
	if (hProcess == 0) {
		ErrorLevel := ERROR_OPEN_PROCESS
		return 0
	}
	
	ErrorLevel := ERROR_OK
	return hProcess
}
getPID(szWindow) {
	local dwPID := 0
	WinGet, dwPID, PID, %szWindow%
	return dwPID
}
refreshMemory() {
	if (!pMemory) {
		pMemory	 := virtualAllocEx(hGTA, 6144, 0x1000 | 0x2000, 0x40)
		if (ErrorLevel) {
			pMemory := 0x0
			return false
		}
		pParam1	:= pMemory
		pParam2	:= pMemory + 1024
		pParam3 := pMemory + 2048
		pParam4	:= pMemory + 3072
		pParam5	:= pMemory + 4096
		pInjectFunc := pMemory + 5120
	}
	return true
}
refreshSAMP() {
	if (dwSAMP)
		return true
	
	dwSAMP := getModuleBaseAddress(GAME_MP_ModuleName, hGTA)
	if (!dwSAMP) return false
	
	return true
}
refreshGTA() {
	newPID := getPID(GAME_PID)
	if (!newPID) {							// GTA not found
		if (hGTA) {							// open handle
			virtualFreeEx(hGTA, pMemory, 0, 0x8000)
			closeProcess(hGTA)
			hGTA := 0x0
		}
		dwGTAPID := 0
		hGTA := 0x0
		dwSAMP := 0x0
		pMemory := 0x0
		return false
	}
	
	if (!hGTA || (dwGTAPID != newPID)) {		// changed PID, closed handle
		hGTA := openProcess(newPID)
		if (ErrorLevel) {					// openProcess fail
			dwGTAPID := 0
			hGTA := 0x0
			dwSAMP := 0x0
			pMemory := 0x0
			return false
		}
		dwGTAPID := newPID
		dwSAMP := 0x0
		pMemory := 0x0
		return true
	}
	return true
}
checkHandles() {
	if (iRefreshHandles+500>A_TickCount)
		return true
	iRefreshHandles:=A_TickCount
	return (refreshGTA() && refreshSAMP() && refreshMemory())
}
writeMemory(hProcess, address, writevalue,length=4, datatype="int") {
	if (!hProcess) {
		ErrorLevel := ERROR_INVALID_HANDLE
		return false
	}

	VarSetCapacity(finalvalue,length, 0)
	NumPut(writevalue,finalvalue,0,datatype)
	dwRet := DllCall("WriteProcessMemory", "Uint", hProcess, "Uint", address, "Uint", &finalvalue, "Uint", length, "Uint", 0)
	if (dwRet == 0) {
		ErrorLevel := ERROR_WRITE_MEMORY
		return false
	}
	ErrorLevel := ERROR_OK
	return true
}
writeByte(hProcess, dwAddress, wInt) {
	if (!hProcess) {
		ErrorLevel := ERROR_INVALID_HANDLE
		return false
	}
	wInt := IntToHex(wInt)
	dwRet := DllCall("WriteProcessMemory", "UInt", hProcess, "UInt", dwAddress, "UInt *", wInt, "UInt", 1, "UInt *", 0)
}
FloatToHex(value) {
   format := A_FormatInteger
   SetFormat, Integer, H
   result := DllCall("MulDiv", Float, value, Int, 1, Int, 1, UInt)
   SetFormat, Integer, %format%
   return, result
}

IntToHex(int) {
	CurrentFormat := A_FormatInteger
	SetFormat, integer, hex
	int += 0
	SetFormat, integer, %CurrentFormat%
	return int
}
writeFloat(hProcess, dwAddress, wFloat) {
	if (!hProcess) {
		ErrorLevel := ERROR_INVALID_HANDLE
		return false
	}
	wFloat := FloatToHex(wFloat)
	dwRet := DllCall("WriteProcessMemory", "UInt", hProcess, "UInt", dwAddress, "UInt *", wFloat, "UInt", 4, "UInt *", 0)
	ErrorLevel := ERROR_OK
	return true
}
HexToDec(str) {   
	local newStr := ""
	static comp := {0:0, 1:1, 2:2, 3:3, 4:4, 5:5, 6:6, 7:7, 8:8, 9:9, "a":10, "b":11, "c":12, "d":13, "e":14, "f":15}
	StringLower, str, str
	str := RegExReplace(str, "^0x|[^a-f0-9]+", "")
	Loop, % StrLen(str)
		newStr .= SubStr(str, (StrLen(str)-A_Index)+1, 1)
	newStr := StrSplit(newStr, "")
	local ret := 0
	for i,char in newStr
		ret += comp[char]*(16**(i-1))
	return ret
}
HexToDecOne(Hex) {
	if (InStr(Hex, "0x") != 1)
	Hex := "0x" Hex
	return, Hex + 0
}
HexToDecTwo(hex) {
	VarSetCapacity(dec, 66, 0), 
	val := DllCall("msvcrt.dll\_wcstoui64", "Str", hex, "UInt", 0, "UInt", 16, "CDECL Int64"), DllCall("msvcrt.dll\_i64tow", "Int64", val, "Str", dec, "UInt", 10, "CDECL")
	return dec
}
hex2rgb(CR) {
	NumPut((InStr(CR, "#") ? "0x" SubStr(CR, 2) : "0x") SubStr(CR, -5), (V := "000000"))
	return NumGet(V, 2, "UChar") "," NumGet(V, 1, "UChar") "," NumGet(V, 0, "UChar")
}
rgb2hex(R, G, B, H := 1) {
	static U := A_IsUnicode ? "_wcstoui64" : "_strtoui64"
	static V := A_IsUnicode ? "_i64tow"	: "_i64toa"
	rgb := ((R << 16) + (G << 8) + B)
	H := ((H = 1) ? "#" : ((H = 2) ? "0x" : ""))
	VarSetCapacity(S, 66, 0)
	value := DllCall("msvcrt.dll\" U, "Str", rgb , "UInt", 0, "UInt", 10, "CDECL Int64")
	DllCall("msvcrt.dll\" V, "Int64", value, "Str", S, "UInt", 16, "CDECL")
	return H S
}
writeBytes(handle, address, bytes) {
	length := strlen(bytes) / 2
	VarSetCapacity(toInject, length, 0)
	Loop %length% {
		byte := "0x" substr(bytes, ((A_Index - 1) * 2) + 1, 2)
		NumPut(byte, toInject, A_Index - 1, "uchar")
	}
	return writeRaw(handle, address, &toInject, length)
}
__ansiToUnicode(sString, nLen = 0) {
	if (!nLen) {
		nLen := DllCall("MultiByteToWideChar", "Uint", 0, "Uint", 0, "Uint", &sString, "int",  -1, "Uint", 0, "int",  0)
	}
	VarSetCapacity(wString, nLen * 2)
	DllCall("MultiByteToWideChar", "Uint", 0, "Uint", 0, "Uint", &sString, "int",  -1, "Uint", &wString, "int",  nLen)
	return wString
}
__unicodeToAnsi(wString, nLen = 0) {
	pString := wString + 1 > 65536 ? wString : &wString
	if (!nLen) {
		nLen := DllCall("WideCharToMultiByte", "Uint", 0, "Uint", 0, "Uint", pString, "int",  -1, "Uint", 0, "int",  0, "Uint", 0, "Uint", 0)
	}
	VarSetCapacity(sString, nLen)
	DllCall("WideCharToMultiByte", "Uint", 0, "Uint", 0, "Uint", pString, "int",  -1, "str",  sString, "int",  nLen, "Uint", 0, "Uint", 0)
	return sString
}
Utf8ToAnsi(ByRef Utf8String, CodePage = 1251) {
	if ((NumGet(Utf8String) & 0xFFFFFF) = 0xBFBBEF)
		BOM = 3
	else
		BOM = 0
	UniSize := DllCall("MultiByteToWideChar", "UInt", 65001, "UInt", 0, "UInt", &Utf8String + BOM, "Int", -1, "Int", 0, "Int", 0)
	VarSetCapacity(UniBuf, UniSize * 2)
	DllCall("MultiByteToWideChar", "UInt", 65001, "UInt", 0, "UInt", &Utf8String + BOM, "Int", -1, "UInt", &UniBuf, "Int", UniSize)
	AnsiSize := DllCall("WideCharToMultiByte", "UInt", CodePage, "UInt", 0, "UInt", &UniBuf, "Int", -1, "Int", 0, "Int", 0, "Int", 0, "Int", 0)
	VarSetCapacity(AnsiString, AnsiSize)
	DllCall("WideCharToMultiByte", "UInt", CodePage, "UInt", 0, "UInt", &UniBuf, "Int", -1, "Str", AnsiString, "Int", AnsiSize, "Int", 0, "Int", 0)
	return AnsiString
}