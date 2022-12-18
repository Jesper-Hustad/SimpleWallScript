; Made by Jesper Hustad aka. Snacksy
; Version 0.1 Initial Release


; If you have rebound any key in Minecraft change them here
DEFAULT_CREATE_NEW_WORLD_KEY=F6
DEFAULT_F3_KEY=F3

; INSTRUCTIONS:
; Install Current Version of AutoHotKey here: https://www.autohotkey.com/
; Launch the script by double clicking the file
; Press the "Refresh" HotKey to start wall
; Press the "Select" HotKey while hovering mouse over Minecraft window to select it
; This will fullscreen the selected Minecraft instance, you can now attempt a Speedrun
; Press the "Refresh" key at any time to go back to the wall


; SETTING UP MULTIPLE MINECRAFT INSTANCES:
; This script assumes you have multiple instances of minecraft running using MultiMC or similar
; Learn how to setup minecraft with MultiMC and speedrunning mods here:https://www.youtube.com/watch?v=VL8Syekw4Q0
; After setting up MultiMC select an instance and click "Copy Instance" to create more


; SIMPLE WALL SCRIPT FEATURES:
; Change the HotKeys for Select and Refresh
; Adjust wall by using the sliders and the visualization
; Adjust the spacing between windows


; You can change initial starting values here (^ =ctrl, ! = alt, # = shift)
defaultStartKey=^E
defaultResetKey=^Y
defaultPadding=0

cleanF3PauseMenuWaitTime:=300

; -----------------------------------------------------------------------
; START OF SCRIPT CODE

#SingleInstance, Force
SendMode Input
#NoEnv  

Menu, tray, add, Show GUI, GUIMenu
menu, tray, default, Show GUI


SysGet, screenWidth, 61 
SysGet, screenHeight, 62 
SysGet, fsWidth, 16 
SysGet, fsHeight, 17 
inGame := false

WinGet, gameWindowList, list,ahk_class GLFW30,, Program Manager
Loop, %gameWindowList%
{
    WinSet, Style, -0xC00000, ahk_id gameWindowList%A_Index%
}


; -----------------------------------------------------------------------
; ------------------------------- GUI -----------------------------------
; -----------------------------------------------------------------------

GUIMenu:

guititle := "SimpleWall Script"
color1:="c1c1c1"	;title background color
color12:="000000"	;Title & Text
color13:="e5e5e5"  	;Gui background color
width := "340"
height:= "195"

globalLineArray := 0
globalIndex := 0
maxCollumnSize := 7

tablePosX := 15
tablePosY := 65
tableWidth := 190
tableHeight := 110

inputPosX := 248
inputPosY := 38


W1 := width - 7,w2 := width - 5,w3 := width - 3,w4 := width - 72
,w6:= width -47,w7:= width - 25,w5 := (width-72) //2,h1 := height - 50
,h3 := height - 20,h2 := height - 17,sbpart := (width-70) //2


gui, destroy

gui, color, %color13%, %color13% ;gui background color
gui, -caption 
Gui, Add, Progress,+E0x20 x-0 y0 w%width%+2 h26 Background%color1% Disabled ;title


Gui Add, Progress, x%tablePosX% y%tablePosY% w%tableWidth% h%tableHeight% Backgroundfcfcfc

gui, font, Q5 c%color12% s14, Bahnschrift Light	
Gui, Add, Text, +E0x20 0x200 x%w7% cBlack y2 w20 h20 BackgroundTrans Center gguiclose, X ;✕ ✖ ✗ ✘
gui, font, Q5 c%color12% s15, Consolas	
Gui, Add, Text, +E0x20 0x200 x%w6% cBlack y-2 w20 h20 BackgroundTrans Center gminimize , _	 ; - to min gui



; wall column and row editing GUI
t1 := tablePosX+tableWidth, t2 := tablePosY+tableHeight, t3 := tableHeight+2, tOffset:=25, t4 := tablePosY-tOffset, t5 := tableWidth+2, t6 := t1+5

; border lines
gui, add, text, x%tablePosX% y%tablePosY% w%tableWidth% h2 0x7
gui, add, text, x%tablePosX% y%tablePosY% w2 h%tableHeight% 0x7
gui, add, text, x%t1% y%tablePosY% w2 h%t3% 0x7
gui, add, text, x%tablePosX% y%t2% w%tableWidth% h2 0x7



; vertical and horizontal slider
Gui, Add, Slider,  +E0x20 0 cRed x%tablePosX% y%t4% w%t5% h23 GSliderCol NoTicks ToolTip Range1-7 cBlack vhorizontalSlider, 2
Gui, Add, Slider,  +E0x20 0 cRed x%t6% y%tablePosY% w23 h%tableHeight% GSliderRow NoTicks Left Range1-7 Invert Vertical cBlack vverticalSlider, 2


; title text
gui, font, Q5 c%color12% s13, Bahnschrift 	 ;color & size GuiTitle
Gui, Add, Text, +E0x20 0x200 cBlack x6 y3 w%width% h22 BackgroundTrans Left gGuiMove , %guititle%   
gui, font, Q5 c888888 s10, Calibri	 ;color & size GuiTitle
Gui, Add, Text, +E0x20 0x200 x142 y5 w%width% h22 BackgroundTrans gGuiMove , v0.1.2   

; hotkey input GUI
i1 := inputPosY+20, i2 :=i1+28, i3 :=i2+20, i4:=i3+28, i5:=i4+20

gui, Font, Q5 s10 cBlack w500, Bahnschrift 
Gui, Add, Text, +E0x20 0x200 cBlack x%inputPosX% y%inputPosY% w%width% h22 BackgroundTrans Left, Select
Gui, Add, Hotkey, +E0x20 0 cRed x%inputPosX% y%i1% w70 h23 cBlack vChosenStartKey gNewStartHotKey, %defaultStartKey%
Gui, Add, Text, +E0x20 0x200 cBlack x%inputPosX% y%i2% w%width% h22 BackgroundTrans Left, Refresh
Gui, Add, Hotkey, x%inputPosX% y%i3% w70 h23  vChosenResetKey gNewResetHotKey, %defaultResetKey%
Gui, Add, Text, +E0x20 0x200 cBlack x%inputPosX% y%i4% w%width% h22 BackgroundTrans Left, Spacing
Gui, Add, Edit, +E0x20 0 x%inputPosX% y%i5% w70 h23 Number cBlack BackgroundWhite, 0
Gui, Add, UpDown, vcurrentPadding gNewPadding Range0-40, %defaultPadding%
currentPadding := defaultPadding

; offscreen button to remove focus from hotkey input
Gui, Add, Button, x-20 y-20 w10 h10 vDefaultButton Default, OK

; puts focus on DefaultButton when background is clicked
OnMessage(0x202, "clickedBackgroundRemoveFocus")

clickedBackgroundRemoveFocus(){
    global
    MouseGetPos,,,, ControlClass, 

    ; ignore if the click is on a gui element
    if(!StrLen(ControlClass) || StrLen(ControlClass)=18) return

    ; set focus to defaultButton
    GuiControl, Focus, DefaultButton
}


hideAllLines(){
    global
    loop %globalIndex%{
        guiControl, Hide, globalLineArray%A_Index%
    }
    return
}

; displays lines in the wall preview gui by reversing the sequential algorithm they are stored in 
displayLines(n, isVertical){
    global
    offset := 0
    Loop %n% {
        offset := offset + A_Index
    }
    Loop %n% {
        arrayIndex := ((offset + A_Index - n) * 2) - isVertical
        guiControl, Show, globalLineArray%arrayIndex%
    }
    return
}


; generates all lines for the wall preview gui and stores them sequentially in globalLineArray
; done this way because ahk doesn't support deleting gui elements and the refrence need to be stored globally
Loop %maxCollumnSize% {
    i := A_Index
    Loop %i% {
        j := A_Index

        ; generate the horizontal lines
        globalIndex := globalIndex + 1
        rowY := ((tableHeight/i) * (j)) + tablePosY
        gui, add, text, x%tablePosX% y%rowY% w%tableWidth% h1 vglobalLineArray%globalIndex% 0x7

        ; generate the vertical lines
        globalIndex := globalIndex + 1
        colX := ((tableWidth/i) * (j)) + tablePosX
        gui, add, text, x%colX% y%tablePosY% w1 h%tableHeight% vglobalLineArray%globalIndex% 0x7
    }
}

; setup initial wall preview gui lines
hideAllLines() 
horizontalSlider := 2
verticalSlider := 2
Gosub initializeLines

; initialize default hotkeys
HotKey, %defaultResetKey%, newWorldRoutine, On
HotKey, %defaultStartKey%, startGameRoutine, On

; display gui
gui, show, w%width% h%height%
gui, +lastfound +HwndThisGui
return


; -----------------------------------------------------------------------
; -------------------------- Wall script --------------------------------
; -----------------------------------------------------------------------


startGameRoutine:
    if(inGame) {
        return
    }

    MouseGetPos,,,windowID,,
    WinGetClass, className, ahk_id %windowID%,
    
    if(className != "GLFW30") {
        return
    }
    
    ; WinSet, Style, +0xC00000, ahk_id %windowID%
    Sleep 200
    WinMove,ahk_id %windowID%,,0,0,A_ScreenWidth,A_ScreenHeight
    WinMaximize, ahk_id %windowID%
    
    WinSet, AlwaysOnTop, On, ahk_id %windowID%
    Sleep 100
    WinSet, AlwaysOnTop, Off, ahk_id %windowID%
    
    inGame := true
return

newWorldRoutine:

    GuiControlGet, currentFocus, Focus
    ; MsgBox, %currentFocus%
    if(currentFocus="msctls_hotkey321" || currentFocus="msctls_hotkey322") {
        return
    }

    row := verticalSlider
    col := horizontalSlider
    p := currentPadding
    winHeight := (screenHeight-8)/row
    winWidth := screenWidth/col

    WinGet, gameWindowList, list,ahk_class GLFW30,, Program Manager
    Loop, %gameWindowList%
    {
        if(A_index>(row*col)) {
            break
        }
        windowID := gameWindowList%A_Index%
        index := A_Index-1
        x := Mod(index,col)
        y := Floor((index)/col)
        distX := winWidth*x
        distY := winHeight*y
        WinSet, Style, -0xC40000, ahk_id %windowID%
        WinMove,ahk_id %windowID%,,distX-p,distY-p,winWidth+p,winHeight+p
        resetKey:=DEFAULT_CREATE_NEW_WORLD_KEY
        ControlSend, ahk_parent, {Blind}{%resetKey% Down}{%resetKey% Up}, ahk_id %windowID%
    }
    Sleep, cleanF3PauseMenuWaitTime
    Loop, %gameWindowList%
    {
        if(A_index>(row*col)) {
            break
        }
        windowID := gameWindowList%A_Index%
        f3Key:=DEFAULT_F3_KEY
        ControlSend, ahk_parent, {Blind}{%f3Key% Down}{Esc}{%f3Key% Up}, ahk_id %windowID%
    }

    Gui, 2: new
    Gui, 2: +LastFound +AlwaysOnTop +ToolWindow
    WinSet, TransColor, EEAA99
    Gui 2: Show

    inGame := false
return


; -------------- more gui ----------------

newHotKeyInput(ByRef globalKeyVar, newKey, routine)
{
    global
    if (RegExMatch(newKey, "[^#+!^]")=0) {
        return
    }
    if(globalKeyVar=newKey) {
        return
    }
    HotKey, %globalKeyVar%, %routine%, Off
    HotKey, %newKey%, %routine%, On
    globalKeyVar=%newKey%
    return
}


newStartHotKey:
    routine=startGameRoutine
    newKey=%ChosenStartKey%
    newHotKeyInput(defaultStartKey, newKey, routine)
return

NewResetHotKey:
    routine=newWorldRoutine
    newKey=%ChosenResetKey%
    newHotKeyInput(defaultResetKey, newKey, routine)
return


NewPadding:
return

initializeLines:
sliderCol:
sliderRow:
    hideAllLines()
    displayLines(horizontalSlider, false)
    displayLines(verticalSlider, true)
return


minimize:
winminimize,
return

GuiEscape:		
GuiClose:
ButtonCancel:
; fix all minecraft window borders and center them
WinGet, gameWindowList, list,ahk_class GLFW30,, Program Manager
Loop, %gameWindowList%
{
    windowID := gameWindowList%A_Index%
    WinSet, Style, +0xC00000, ahk_id %windowID%
    m0:=(screenWidth/4)-(A_Index*12),m1:=screenWidth/2,m2:=(screenHeight/4)-(A_Index*12),m3:=screenHeight/2
    WinMove,ahk_id %windowID%,,m0,m2,m1,m3
}
gui, destroy
return

GuiMove:     		
PostMessage, 0xA1, 2
sleep 75
winset, redraw
WB.Navigate(page)
return
