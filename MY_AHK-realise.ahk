#Requires AutoHotkey v2.0
#SingleInstance Force
ProcessSetPriority "High"
SetWinDelay 0 
SendMode("Input")
SetWorkingDir(A_ScriptDir)

; ==============================================================================
; РАЗДЕЛ 0: Запуск программ
; ==============================================================================

;запуск Total Commander
Send("!e")

;запуск AmneziaVPN
; Привязываем координаты мыши и пикселей к активному окну, а не к экрану
CoordMode("Pixel", "Window")
CoordMode("Mouse", "Window")

Run("c:\Users\Lafridon\Documents\AutoHotkey\AmneziaVPN.lnk")

if !WinWait("ahk_exe AmneziaVPN.exe", , 10) {
    MsgBox("Окно AmneziaVPN не загрузилось.")
    ExitApp()
}

WinActivate("ahk_exe AmneziaVPN.exe")
WinWaitActive("ahk_exe AmneziaVPN.exe")

; Узнаем точные размеры окна Amnezia, чтобы искать только внутри него
WinGetPos(&WinX, &WinY, &WinWidth, &WinHeight, "ahk_exe AmneziaVPN.exe")

Loop 150 {
    ; Ищем ОБРЕЗАННУЮ картинку отключенного состояния (допуск *60 обычно оптимален)
    if ImageSearch(&FoundX, &FoundY, 0, 0, WinWidth, WinHeight, "*60 AmneziaVPN-disconnect.png") {
        Sleep 200
        ; Кликаем точно по найденной картинке, сместив клик чуть в центр (+10 пикселей)
        Click(FoundX + 10, FoundY + 5) 
        break
    }
    
    ; Ищем ОБРЕЗАННУЮ картинку подключенного состояния
    if ImageSearch(&FoundX, &FoundY, 0, 0, WinWidth, WinHeight, "*60 AmneziaVPN-connect.png") {
        break
    }
    
    Sleep 100
}

Sleep 1000 ; Даем секунду на старт процесса подключения
WinClose("ahk_exe AmneziaVPN.exe")

;запуск raycast
Run("c:\Users\Lafridon\Documents\AutoHotkey\Raycast - Ярлык.lnk")


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
    Run("C:\Program Files\Notepad++\notepad++.exe `"" A_ScriptFullPath "`"")
}

; ==============================================================================
; РАЗДЕЛ 2: ГОРЯЧИЕ КЛАВИШИ (HOTKEYS)
; ==============================================================================

; Ctrl + Space -> Сделать активное окно "Всегда поверх остальных"
^Space:: {
    WinSetAlwaysOnTop(-1, "A")
    TrayTip("Режим 'Поверх всех' изменен", "Окно")
}

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
; РАЗДЕЛ 3: АВТОЗАМЕНЫ (HOTSTRINGS)
; ==============================================================================

:*:@@::mr.ung666@gmail.com

; Вставка текущей даты
:*:@date:: {
    SendInput(FormatTime(, "dd.MM.yyyy"))
}

; Исправление опечаток (пример)
::чтобв::чтобы
::вообщем::в общем

; ==============================================================================
; РАЗДЕЛ 4: МАНИПУЛЯЦИИ С ТЕКСТОМ
; ==============================================================================

; Выделите текст и нажмите Ctrl + Shift + U -> ВЕРХНИЙ РЕГИСТР
^+u:: {
    SavedClip := ClipboardAll()
    A_Clipboard := ""
    Send("^c")
    if !ClipWait(1)
        return
    A_Clipboard := StrUpper(A_Clipboard)
    Send("^v")
    Sleep(100)
    A_Clipboard := SavedClip
}

; Выделите текст и нажмите Ctrl + Shift + L -> нижний регистр
^+l:: {
    SavedClip := ClipboardAll()
    A_Clipboard := ""
    Send("^c")
    if !ClipWait(1)
        return
    A_Clipboard := StrLower(A_Clipboard)
    Send("^v")
    Sleep(100)
    A_Clipboard := SavedClip
}
; ==============================================================================
; РАЗДЕЛ 5: Total Commander
; ==============================================================================

!e:: {
    tcClass := "ahk_class TTOTAL_CMD"
    tcPath := "c:\Program Files\totalcmd\TOTALCMD64.EXE"
    
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
    Run(tcPath)
    
    ; 1. Включаем поиск по всему экрану (обязательно для A_ScreenWidth)
    CoordMode("Pixel", "Screen")
    
    ; 3. ТУРБО-ЦИКЛ (без задержек)
    Loop 150 { 
        
        ; Ищем кнопку №1
        if ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, "Total Commander №1.png") {
            WinActivate("ahk_exe TOTALCMD64.EXE") ; Активируем окно на всякий случай
            Send("1")                             ; Нажимаем 1
            break
        }
        
        ; Ищем кнопку №2
        if ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, "Total Commander №2.png") {
            WinActivate("ahk_exe TOTALCMD64.EXE")
            Send("2")                             ; Нажимаем 2
            break
        }
        
        ; Ищем кнопку №3
        if ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, "Total Commander №3.png") {
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