; Made by Jesper Hustad aka. Snacksy


; If you have rebound any relevant key in Minecraft change them here
CREATE_NEW_WORLD_KEY={F6}
F3_KEY={F3 Down}{ESC}{F3 Up}

; hotkeys can be changed in program, but defaults can be changed here (^ =ctrl, ! = alt, # = shift)
defaultStartKey=^E
defaultResetKey=^Y

; slower computers may need to increase this value
cleanF3PauseMenuWaitTime:=500

; INSTRUCTIONS:
; Install Current Version of AutoHotKey here: https://www.autohotkey.com/
; Launch the script by double clicking the file
; Press the "Refresh" HotKey to start wall (hold CTRL and Y simoltaniously)
; Press the "Select" HotKey while hovering mouse over Minecraft window to select it
; This will fullscreen the selected Minecraft instance, you can now attempt a Speedrun
; Press the "Refresh" key at any time to go back to the wall


; SETTING UP MULTIPLE MINECRAFT INSTANCES:
; This script assumes you have multiple instances of minecraft running using MultiMC or similar
; Learn how to setup minecraft with MultiMC and speedrunning mods here:https://www.youtube.com/watch?v=VL8Syekw4Q0
; After setting up MultiMC select an instance and click "Copy Instance" to create more


; -----------------------   START OF WALL CODE   -----------------------
#SingleInstance, Force
SendMode Input
CoordMode, Mouse , Screen
#NoEnv  
#NoTrayIcon

VERSION=v1.0.0
currentGameWindow:=0
resetList:=[]
defaultPadding=0
inGame := false
previousInstanceCount:=-1
layoutChange := false
isSecondReset := false
globalInstanceList := 0

SysGet, screenWidth, 61 
SysGet, screenHeight, 62 
SysGet, fsWidth, 16 
SysGet, fsHeight, 17 

actionSelect(){
    global

    if(inGame)
        return

    ; get ID of window under mouse
    MouseGetPos,,,windowID,,
    
    ; skip if select ID is not minecraft window
    WinGetClass, className, ahk_id %windowID%,
    if(className != "GLFW30")
        return
    
    ; set selected window on top without activating focus (keep paused)
    WinSet, AlwaysOnTop, On, ahk_id %windowID%
    WinSet, AlwaysOnTop, Off, ahk_id %windowID%

    ; make fullscreen
    WinMove,ahk_id %windowID%,,0,0,A_ScreenWidth,A_ScreenHeight
    
    inGame := true, isSecondReset := false
    currentGameWindow := windowID
    return
}

actionReset(){
    global

    ; skip if user currently selecting new hotkey
    GuiControlGet, currentFocus, Focus
    if(currentFocus="msctls_hotkey321" || currentFocus="msctls_hotkey322")
        return

    ; stops game from auto starting after reset
    removeFocus() 

    ; set mouse in center when leaving game for easier selection
    if(inGame)
        MouseMove, (screenWidth // 2), (screenHeight // 2)

    ; calculate wall dimension
    row := verticalSlider
    col := horizontalSlider
    winHeight := (screenHeight-8)/row
    winWidth := fsWidth/col
    tileCount := row*col

    WinGet, newInstanceCount, Count, ahk_class GLFW30,, Program Manager
    if(newInstanceCount!=globalInstanceList) {
        layoutChange := true
        WinGet, globalInstanceList, list,ahk_class GLFW30,, Program Manager
    }

    windowCount := newInstanceCount<tileCount ? newInstanceCount : tileCount
    
    resetList := {}
    Loop % windowCount
    {
        windowID := globalInstanceList%A_Index%
        isActiveWindow := (currentGameWindow=windowID)

        if(layoutChange || isSecondReset || (inGame=isActiveWindow))
            resetList[A_Index-1] := windowID
    }

    ; only move windows if required
    if(layoutChange || inGame){
    for i, windowID in resetList
        positionWall(windowID, i, col, winWidth, winHeight)    
    }

    ; quick reset world with Autum mod (by default F6)
    for i, windowID in resetList
       performKeystroke(windowID, CREATE_NEW_WORLD_KEY)

    ; clean pause menu by pressing F3 + ESC simultaniously
    Sleep, cleanF3PauseMenuWaitTime
    for i, windowID in resetList 
        performKeystroke(windowID, F3_KEY)

    isSecondReset := (!inGame || isSecondReset)
    inGame := false
    layoutChange := false
    return
}

positionWall(windowID, index, columns, winWidth, winHeight){
    global
    p := currentPadding
    x := Mod(index,columns)
    y := Floor(index/columns)
    distX := winWidth*x
    distY := winHeight*y
    WinSet, Style, -0xC40000, ahk_id %windowID%
    WinMove,ahk_id %windowID%,,distX-p,distY-p,winWidth+p,winHeight+p
    return
}

performKeystroke(windowID, key){
    ControlSend, ahk_parent, {Blind}%key%, ahk_id %windowID%
    return
}

removeFocus(){
    Gui, 2: new
    Gui, 2: +LastFound +AlwaysOnTop +ToolWindow
    Gui, 2: Show
    return
}
; ------------------------------- Start of UI -----------------------------------

Menu, tray, add, Show GUI, GUIMenu
menu, tray, default, Show GUI

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
Gui, Add, Text, +E0x20 0x200 x142 y5 w%width% h22 BackgroundTrans gGuiMove , %VERSION%  

; hotkey input GUI
i1 := inputPosY+20, i2 :=i1+28, i3 :=i2+20, i4:=i3+28, i5:=i4+20

gui, Font, Q5 s10 cBlack w500, Bahnschrift 
Gui, Add, Text, +E0x20 0x200 cBlack x%inputPosX% y%inputPosY% w%width% h22 BackgroundTrans Left, Select
Gui, Add, Hotkey, +E0x20 0 cRed x%inputPosX% y%i1% w70 h23 cBlack vChosenStartKey gNewStartHotKey, %defaultStartKey%
Gui, Add, Text, +E0x20 0x200 cBlack x%inputPosX% y%i2% w%width% h22 BackgroundTrans Left, Refresh
Gui, Add, Hotkey, x%inputPosX% y%i3% w70 h23  vChosenResetKey gNewResetHotKey, %defaultResetKey%
Gui, Add, Text, +E0x20 0x200 cBlack x%inputPosX% y%i4% w%width% h22 BackgroundTrans Left, Spacing
Gui, Add, Edit, +E0x20 0 x%inputPosX% y%i5% w70 h23 Number cBlack BackgroundWhite, 0
Gui, Add, UpDown, vcurrentPadding gNewPadding Range-10-40, %defaultPadding%
currentPadding := defaultPadding

; offscreen button to remove focus from hotkey input
Gui, Add, Button, x-20 y-20 w10 h10 vDefaultButton Default, OK

; puts focus on DefaultButton when background is clicked
OnMessage(0x202, "clickedBackgroundRemoveFocus")

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

; I_Icon = C:\favicon.ico
; IfExist, %I_Icon%
; Menu, Tray, Icon, %I_Icon%, 1, 1

; display gui
gui, show, w%width% h%height%
gui, +lastfound +HwndThisGui
return
; end of gui initialization

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

clickedBackgroundRemoveFocus(){
    global
    MouseGetPos,,,, ControlClass, 

    ; ignore if the click is on a gui element
    if(!StrLen(ControlClass) || StrLen(ControlClass)=18) return

    ; set focus to defaultButton
    GuiControl, Focus, DefaultButton
}

; ---------------------- Subroutines ----------------------

startGameRoutine:
actionSelect()
return

newWorldRoutine:
actionReset()
return

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
layoutChange:=true
return

initializeLines:
sliderCol:
sliderRow:
    hideAllLines()
    displayLines(horizontalSlider, false)
    displayLines(verticalSlider, true)
    layoutChange:=true
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
ExitApp
return

GuiMove:     		
PostMessage, 0xA1, 2
sleep 75
winset, redraw
WB.Navigate(page)
return
