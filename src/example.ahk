#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#include UDF.ahk
#IfWinActive AMAZING ONLINE


:?:/utest::
SendChat("Привет! Я просто тестирую UDF для Амазинга, все нормально")
sleep 5000
SendChat("/b Привет! Я просто тестирую UDF для Амазинга, все нормально")
sleep 5000
addChatMessageEx(0xFFFFFF, "Если в процессе тестирования Вы отправили одно сообщение в обычный чат, одно в /b и увидели это - UDF работает нормально")
return