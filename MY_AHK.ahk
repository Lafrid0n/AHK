#Requires AutoHotkey v2.0
#SingleInstance Force
ProcessSetPriority "High"

; ==============================================================================
; РАЗДЕЛ 0: Задаем пути и Запуск программ
; ==============================================================================

;	=========пути к файлам=============

; Путь к Корневой папке Total Commander
TC := "..\..\..\"

TC_Path := TC . "\TOTALCMD64.EXE — ярлык.lnk"

notepadPath := TC . "\soft\Notepad++\notepad++.exe"

MY_BAT_Path := A_ScriptDir "\" "MY_BAT.BAT"
SplitPath(MY_BAT_Path, &MY_BAT_Name, &MY_BAT_Dir)

everythingPath := TC . "\soft\Everything\everything.exe"

AmneziaPath := "c:\Program Files\AmneziaVPN\AmneziaVPN.exe"

; пути к файлам в MY_BAT.BAT для их обновления
newPath := "
(
set "AhkExePath=..\..\..\soft\AHK\AutoHotkey64.exe"
set "AhkScriptsPath=MY_AHK.ahk"

set ButtonMyAhk=ButtonMyAhk.bat
set "StartupMyAhk=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\StartupMyAhk.bat"

for %%i in ("%AhkExePath%") do set "AhkExeFullPath=%%~fi"
for %%i in ("%AhkScriptsPath%") do set "AhkScriptsFullPath=%%~fi"
)"

;	========обновляем пути в MY_BAT.BAT ============
fileText := FileRead(MY_BAT_Path)

needle := "(?s)(\Q::start set\E).+(\Q::end set\E)"
replacement := "$1`r`n" . newPath . "`r`n$2"

newFileText := RegExReplace(fileText, needle, replacement, &matchCount)

if (matchCount > 0) {
    try {
        FileObj := FileOpen(MY_BAT_Path, "w")
        FileObj.Write(newFileText)
        FileObj.Close()
    } catch Error as err {
        MsgBox("Ошибка при записи файла: " err.Message)
    }
} else {
    MsgBox("Метки '::start set' и '::end set' не найдены.")
}

;	========обновляем кнопу, создаем автозагрузку============
Run(MY_BAT_Name, MY_BAT_Dir, "Hide")

;	========запуск everything============

RunWait(A_ComSpec ' /c start "" "' everythingPath '" -startup', , "Hide")

;	==========================запуск AmneziaVPN===========================

; Привязываем координаты мыши и пикселей к активному окну, а не к экрану
CoordMode("Pixel", "Window")
CoordMode("Mouse", "Window")

if FileExist(AmneziaPath){
	Run(AmneziaPath)

	if !WinWait("ahk_exe AmneziaVPN.exe", , 10) {
		MsgBox("Окно AmneziaVPN не загрузилось.")
		ExitApp()
	}

	WinActivate("ahk_exe AmneziaVPN.exe")
	WinWaitActive("ahk_exe AmneziaVPN.exe")

	WinMove(0, 0, , , "ahk_exe AmneziaVPN.exe")

	; Узнаем точные размеры окна Amnezia, чтобы искать только внутри него
	WinGetPos(&WinX, &WinY, &WinWidth, &WinHeight, "ahk_exe AmneziaVPN.exe")

	Loop 150 {
		WinActivate("ahk_exe AmneziaVPN.exe")
		; Ищем ОБРЕЗАННУЮ картинку отключенного состояния (допуск *60 обычно оптимален)
		if ImageSearch(&FoundX, &FoundY, 0, 0, WinWidth, WinHeight, "*60 AmneziaVPN-disconnect-100.png") {
			Sleep 100
			; Кликаем точно по найденной картинке, сместив клик чуть в центр (+10 пикселей)
			Click(FoundX + 10, FoundY + 5) 
			break
		}
		if ImageSearch(&FoundX, &FoundY, 0, 0, WinWidth, WinHeight, "*60 AmneziaVPN-disconnect-125.png") {
			Sleep 100
			; Кликаем точно по найденной картинке, сместив клик чуть в центр (+10 пикселей)
			Click(FoundX + 10, FoundY + 5) 
			break
		}
		; Ищем ОБРЕЗАННУЮ картинку подключенного состояния
		if ImageSearch(&FoundX, &FoundY, 0, 0, WinWidth, WinHeight, "*60 AmneziaVPN-connect-100.png") {
			break
		}
			if ImageSearch(&FoundX, &FoundY, 0, 0, WinWidth, WinHeight, "*60 AmneziaVPN-connect-125.png") {
		break
		}
		Sleep 10
	}
	Sleep 100 ; Даем  на старт процесса подключения
	WinClose("ahk_exe AmneziaVPN.exe")
}

;	=============запуск Total Commander==================

Send("!e")

; ==============================================================================
; РАЗДЕЛ 1: Total Commander
; ==============================================================================

!e:: {
    tcClass := "ahk_class TTOTAL_CMD"
	
    ; 1. БЫСТРОЕ ПЕРЕКЛЮЧЕНИЕ
    if WinExist(tcClass) {
        ; Если окно активно...
        if WinActive(tcClass) {
            ; Проверяем, развернуто ли оно (1 - развернуто, 0 - нет, -1 - свернуто)
            if (WinGetMinMax(tcClass) = 1) {
                WinMinimize(tcClass) ; Сворачиваем, если уже развернуто и активно
            }
			if (WinGetMinMax(tcClass) = 0) {
                WinMinimize(tcClass) ; Сворачиваем, если уже развернуто и активно
            }
        } else {
            ; Если окно существует, но не активно — активируем и разворачиваем
            WinActivate(tcClass)
        }
        return ; Завершаем работу хоткея, так как TC уже был открыт
    }

    ; 2. ЗАПУСК
    Run(TC_Path)
    
    ; 1. Включаем поиск по всему экрану (обязательно для A_ScreenWidth)
    CoordMode("Pixel", "Screen")
    
    ; 3. ТУРБО-ЦИКЛ (без задержек)
    Loop 150 { 
        
        ; Ищем кнопку №1
        if ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, "Total Commander №1-100.png") {
            WinActivate("ahk_exe TOTALCMD64.EXE") ; Активируем окно на всякий случай
            Send("1")                             ; Нажимаем 1
            break
        }
        if ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, "Total Commander №1-125.png") {
            WinActivate("ahk_exe TOTALCMD64.EXE") ; Активируем окно на всякий случай
            Send("1")                             ; Нажимаем 1
            break
        }
        ; Ищем кнопку №2
        if ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, "Total Commander №2-100.png") {
            WinActivate("ahk_exe TOTALCMD64.EXE")
            Send("2")                             ; Нажимаем 2
            break
        }
        if ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, "Total Commander №2-125.png") {
            WinActivate("ahk_exe TOTALCMD64.EXE")
            Send("2")                             ; Нажимаем 2
            break
        }
        ; Ищем кнопку №3
        if ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, "Total Commander №3-100.png") {
            WinActivate("ahk_exe TOTALCMD64.EXE")
            Send("3")                             ; Нажимаем 3
            break
        }
		if ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, "Total Commander №3-125.png") {
            WinActivate("ahk_exe TOTALCMD64.EXE")
            Send("3")                             ; Нажимаем 3
            break
        }
    }

    ; 4. МГНОВЕННОЕ РАЗВЕРТЫВАНИЕ
    ; Ждем появления основного окна (обычно это доли секунды после нажатия цифры)
    if WinWait(tcClass, , 2) {
        MonitorGet(1, &L, &T, &R, &B)
        ; Перемещаем и разворачиваем одной пачкой
        try {
            WinMove(L, T, , , tcClass)
            WinMaximize(tcClass)
            WinActivate(tcClass)
        }
    }
}

; ==============================================================================
; РАЗДЕЛ 1: УПРАВЛЕНИЕ СКРИПТОМ
; ==============================================================================

; Ctrl + Alt + R -> Перезагрузить скрипт (удобно при редактировании)
^!r:: {
    TrayTip("Скрипт перезагружен", "AutoHotkey")
    Sleep(1000)
    Reload()
}

; Ctrl + Alt + E -> Открыть этот файл для редактирования
^!e:: {
    Run('"' notepadPath '" "' A_ScriptFullPath '"')
}

; ==============================================================================
; РАЗДЕЛ 2: ГУГЛ
; ==============================================================================


; Alt + G -> Искать выделенный текст в Google
!g:: {
    oldClip := A_Clipboard
    A_Clipboard := ""
    Send("^c")
    if !ClipWait(1) {
        A_Clipboard := oldClip
        return
    }
    
    ; Преобразуем спецсимволы в безопасный формат
    SafeQuery := EncodeDecodeURI(A_Clipboard)
    Run("https://www.google.com/search?q=" . SafeQuery)
    
    A_Clipboard := oldClip
}

; Функция кодирования строки
EncodeDecodeURI(str) {
    static Doc, JS
    if !IsSet(Doc) {
        Doc := ComObject("htmlfile")
        Doc.write('<meta http-equiv="X-UA-Compatible" content="IE=9">')
        JS := Doc.parentWindow
    }
    return JS.encodeURIComponent(str)
}

; Открыть папку загрузок (Win + J)
#j:: {
    Run("explorer.exe shell:Downloads")
}

; Открыть калькулятор (Alt + C)
!c:: {
    Run("calc.exe")
}

; ==============================================================================
; РАЗДЕЛ 6: МЫШЬ И ЗВУК
; ==============================================================================

; Управление громкостью колесиком мыши, когда курсор над Панелью задач
#HotIf MouseIsOver("ahk_class Shell_TrayWnd")
WheelUp::Send("{Volume_Up}")
WheelDown::Send("{Volume_Down}")

MouseIsOver(WinTitle) {
    MouseGetPos(,, &Win)
    return WinExist(WinTitle . " ahk_id " . Win)
}
#HotIf