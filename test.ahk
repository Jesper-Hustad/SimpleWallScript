#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

n:=(true&&!false) ? "true" : "false"

MsgBox, %n%