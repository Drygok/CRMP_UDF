#CommentFlag //
#include common.ahk



/*
	
	AHK UDF для CR:MP и SA:MP версии 0.3.7 R3
	Перевел, обновил, доработал и отредактировал Снегирев Максим
	
	vk.com/idDrygok | яМаксим.рф
	
*/

/*
	
	Доступные функции:
	
	*** Функции чтения, связанные с локальным персонажем ***
	- getPlayerHealth()																получить уровень здоровья (HP) игрока
	- getPlayerArmour()																получить уровень брони игрока
	- getPlayerMoney()																получить количество денег игрока
	- getPlayerInteriorId()															получить ID интерьера игрока
	- getPlayerSkinId()																получить ID скина игрока
	- getPlayerWeaponId()															получить ID оружия в руках
	
	*** Функции чтения, связанные с текущим транспортом ***
	- isPlayerInAnyVehicle()														проверить, находится ли игрок в транспорте (0 - если игрок не в транспорте, иначе вернется указатель на этот транспорт)
	- getVehicleHealth()															получить уровень здоровья текущего транспорта
	- isPlayerDriver()																проверить, за рулем ли игрок
	- getVehicleColor()																получить ID цветов текущего транспорта (возвращается одномерный массив с первым и вторым цветом)
	- getVehicleSpeed()																получить скорость транспорта
	
	*** Функции, связанные с координатами ***
	- getCoordinates()																получить координаты игрока или транспорта, в котором находится игрок (возвращается одномерный массив [X, Y, Z])
	- getPlayerCoordinates()														получить координаты игрока (возвращается одномерный массив [X, Y, Z])
	- getCameraCoordinates()														получить координаты камеры (возвращается одномерный массив [X, Y, Z])
	
	*** Функции, связанные с модулем мультиплеера ***
	- addChatMessageEx(Color, Text)													отправить сообщение в локальный чат (вывести самому себе)
	- sendChat(Text)																отправить сообщение/команду в чат
	- showDialog(Style, Caption, Text, Button1, Button2 := "", Id := 1)				вывести диалог (функция практически не отредактирована); Благодарю MurKotik за ее реализацию ;)
	- isInChat()																	проверить, открыт ли чат у пользователя скрипта (true - чат открыт, false - чат закрыт)
	
*/


// Если Вы не понимаете, что делаете - дальше путь закрыт. Ниже идет РЕАЛИЗАЦИЯ функций, трогать это не стоит.


// Функции чтения, связанные с локальным игроком
getPlayerHealth() {
	if (!checkHandles())
		return -1
		
	return readFloat(hGTA, readDWORD(hGTA, 0xB6F5F0) + 0x540)
}
getPlayerArmour() {
	if (!checkHandles())
		return -1
		
	return readFloat(hGTA, readDWORD(hGTA, 0xB6F5F0) + 0x548)
}
getPlayerMoney() {
	if (!checkHandles())
		return -1
		
	return readDWORD(hGTA, 0x0B7CE54)
}
getPlayerInteriorId() {
	if (!checkHandles())
		return -1
		
	return readDWORD(hGTA, 0xA4ACE8)
}
getPlayerSkinId() {
	if (!checkHandles())
		return -1
		
	return readMem(hGTA, readDWORD(hGTA, 0xB6F5F0) + 0x22, 2, "byte")
}
getPlayerWeaponId() {
	if (!checkHandles())
		return -1
		
	return readDWORD(hGTA, 0xBAA410)
}

// Функции чтения, связанные с текущим транспортом
isPlayerInAnyVehicle() {
	if (!checkHandles())
		return -1
		
	return readDWORD(hGTA, 0xBA18FC)
}
getVehicleHealth() {
	if (!checkHandles())
		return -1
		
	return readFloat(hGTA, readDWORD(hGTA, 0xBA18FC) + 0x4C0)
}
isPlayerDriver() {
	if (!checkHandles())
		return -1
		
	return (readDWORD(hGTA, readDWORD(hGTA, 0xBA18FC) + 0x460) == readDWORD(hGTA, 0xB6F5F0))
}
getVehicleColor() {
	if (!checkHandles())
		return -1
		
	dwAddress := isPlayerInAnyVehicle()
	return [readMem(hGTA, dwAddress + 1076, 1, "byte"), readMem(hGTA, dwAddress + 1077, 1, "byte")]
}
getVehicleSpeed() {
	if(!checkHandles())
		return -1
 
	dwAddress := isPlayerInAnyVehicle()
	
	fSpeedX := readMem(hGTA, dwAddress + 0x44, 4, "float")
	fSpeedY := readMem(hGTA, dwAddress + 0x48, 4, "float")
	fSpeedZ := readMem(hGTA, dwAddress + 0x4C, 4, "float")
	
	fVehicleSpeed := sqrt((fSpeedX * fSpeedX) + (fSpeedY * fSpeedY) + (fSpeedZ * fSpeedZ))
	fVehicleSpeed := (fVehicleSpeed * 100) * 1.43
 
	return Round(fVehicleSpeed)
}

// Функции, связанные с координатами
getCoordinates() {
	if (!checkHandles())
		return -1
		
	dwAddress := isPlayerInAnyVehicle()
	if (dwAddress == 0)
		dwAddress := readDWORD(hGTA, 0xB6F5F0)
	dwAddress := readDWORD(hGTA, dwAddress + 0x14)
	
	return [readFloat(hGTA, dwAddress + 0x30), readFloat(hGTA, dwAddress + 0x34), readFloat(hGTA, dwAddress + 0x38)]
}
getPlayerCoordinates() {
	if (!checkHandles())
		return -1
		
	dwAddress := readDWORD(hGTA, readDWORD(hGTA, 0xB6F5F0) + 0x14)
	
	return [readFloat(hGTA, dwAddress + 0x30), readFloat(hGTA, dwAddress + 0x34), readFloat(hGTA, dwAddress + 0x38)]
}
getCameraCoordinates() {
	if (!checkHandles())
		return -1
	
	return [readFloat(hGTA, 0xB6F9CC), readFloat(hGTA, 0xB6F9D0), readFloat(hGTA, 0xB6F9D4)]
}

// Функции, связанные с модулем мультиплеера
addChatMessageEx(Color, Text) {
	if (!checkHandles())
		return -1
   
	VarSetCapacity(data2, 4, 0)
	NumPut(HexToDec(Color), data2, 0, "Int")
	
	dwAddress := readDWORD(hGTA, dwSAMP + 0x26E8C8)
	VarSetCapacity(data1, 4, 0)
	NumPut(readDWORD(hGTA, dwAddress + 0x4), data1, 0, "Int") 
	WriteRaw(hGTA, dwAddress + 0x4, &data2, 4)
   
	callWithParams(hGTA, dwSAMP + 0x67970, [["p", readDWORD(hGTA, dwSAMP + 0x26E8C8)], ["s", "" Text]], true)
	WriteRaw(hGTA, dwAddress + 0x4, &data1, 4)
}
sendChat(Text) {	
	if (!checkHandles())
		return -1
	
	dwFunc := 0
	if (SubStr(Text, 1, 1) == "/") {
		dwFunc := dwSAMP + 0x69190
	} else {
		dwFunc := dwSAMP + 0x5820
	}
	
	callWithParams(hGTA, dwFunc, [["s", "" Text]], false)
}
isInChat() {	
	if (!checkHandles())
		return -1
	
	return (readDWORD(hGTA, readDWORD(hGTA, dwSAMP + 0x26E8F4) + 0x61) > 0)
}
getAuthor() {
	return "vk.com/idDrygok"
}
showDialog(style, caption, text, button1, button2 := "", id := 1) {
	style += 0
	style := Floor(style)
	id += 0
	id := Floor(id)
	caption := "" caption
	text := "" text
	button1 := "" button1
	button2 := "" button2

	if (id < 0 || id > 32767 || style < 0 || style > 5 || StrLen(caption) > 64 || StrLen(text) > 4096 || StrLen(button1) > 10 || StrLen(button2) > 10)
		return false

	if (!checkHandles())
		return -1

	dwFunc := dwSAMP + 0x6F8C0
	sleep 200
	dwAddress := readDWORD(hGTA, dwSAMP + 0x26E898)
	if (!dwAddress) {
		return -1
	}

	writeString(hGTA, pParam5, caption)
	writeString(hGTA, pParam1, text)
	writeString(hGTA, pParam5 + 512, button1)
	writeString(hGTA, pParam5+StrLen(caption) + 1, button2)

	dwLen := 5 + 7 * 5 + 5 + 1
	VarSetCapacity(injectData, dwLen, 0)

	NumPut(0xB9, injectData, 0, "UChar")
	NumPut(dwAddress, injectData, 1, "UInt")
	NumPut(0x68, injectData, 5, "UChar")
	NumPut(1, injectData, 6, "UInt")
	NumPut(0x68, injectData, 10, "UChar")
	NumPut(pParam5 + StrLen(caption) + 1, injectData, 11, "UInt")
	NumPut(0x68, injectData, 15, "UChar")
	NumPut(pParam5 + 512, injectData, 16, "UInt")
	NumPut(0x68, injectData, 20, "UChar")
	NumPut(pParam1, injectData, 21, "UInt")
	NumPut(0x68, injectData, 25, "UChar")
	NumPut(pParam5, injectData, 26, "UInt")
	NumPut(0x68, injectData, 30, "UChar")
	NumPut(style, injectData, 31, "UInt")
	NumPut(0x68, injectData, 35, "UChar")
	NumPut(id, injectData, 36, "UInt")

	NumPut(0xE8, injectData, 40, "UChar")
	offset := dwFunc - (pInjectFunc + 45)
	NumPut(offset, injectData, 41, "Int")
	NumPut(0xC3, injectData, 45, "UChar")

	writeRaw(hGTA, pInjectFunc, &injectData, dwLen)

	hThread := createRemoteThread(hGTA, 0, 0, pInjectFunc, 0, 0, 0)

	waitForSingleObject(hThread, 0xFFFFFFFF)
	closeProcess(hThread)
}