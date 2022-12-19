#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%



; foo(bar){
;     MsgBox, %bar%
;     return
; }

; Critical , On
; global threadCount := 0

; async(func, arguments, delay:=0){

;     ; threadCount++
;     fn := Func(func).Bind(arguments)
;     ms := (delay==0) ? 1 : delay
;     SetTimer, % "threadCompleted",% -delay
;     ; SetTimer, % fn, % -delay
    
;     return
; }

; threadCompleted(){
;     threadCount:=threadCount+1
;     return
; }

; threadJoin(){
;     while(threadCount > 0){
;         MsgBox, waiting for %threadCount% threads to complete
;         Sleep, 10
;     }
;     return
; }

; ; async("foo","async with 1s delay",500)
; ; async("foo","async with 0s delay",1)

; SetTimer, % "threadCompleted",% -1


; ; threadJoin()
; sleep 1000


; MsgBox, %threadCount%

MsgBox, hey
n := 1000
Sleep, n

MsgBox, hey 222