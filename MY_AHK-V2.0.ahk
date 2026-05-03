#Requires AutoHotkey v2.0
#SingleInstance Force
SendMode("Input")
SetWorkingDir(A_ScriptDir)

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
    A_Clipboard := ""
    Send("^c")
    if !ClipWait(1)
        return
    Run("https://www.google.com/search?q=" . A_Clipboard)
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
    
; 1. ПРОВЕРКА: ЗАПУЩЕНО ЛИ ПРИЛОЖЕНИЕ?
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
    ; 1. Включаем поиск по всему экрану (обязательно для A_ScreenWidth)
    CoordMode("Pixel", "Screen")
	
    Run("c:\Program Files\totalcmd\TOTALCMD64.EXE")
    
    ; Ставим лимит на количество проверок (например, 20 раз по 0.5 сек = 10 секунд).
    ; Иначе, если картинки не будет, скрипт зависнет в вечном цикле.
    Loop 20 {
        
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
	; 3. РАЗВЕРТЫВАНИЕ НА ВНУТРЕННИЙ ЭКРАН
    ; Ждем появления основного окна (обычно оно имеет класс TTOTAL_CMD)
    if WinWait("ahk_class TTOTAL_CMD", , 5) {
        Sleep(200) ; Небольшая пауза для стабильности
        
        ; Получаем координаты ПЕРВОГО монитора (встроенный дисплей ноутбука)
        MonitorGet(1, &Left, &Top, &Right, &Bottom)
        
        ; Активируем окно
        WinActivate("ahk_class TTOTAL_CMD")
        
        ; Сначала восстанавливаем окно, если оно было свернуто, 
        ; перемещаем на нужный монитор и максимизируем
        WinRestore("ahk_class TTOTAL_CMD")
        WinMove(Left, Top, , , "ahk_class TTOTAL_CMD")
        WinMaximize("ahk_class TTOTAL_CMD")
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
