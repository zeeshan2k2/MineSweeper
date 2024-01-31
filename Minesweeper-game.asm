printdigit macro p1 ; Macro for printing 8 bit digits
mov dl, p1
add dl, 48
mov ah, 2
int 21h
endm


printdigit16 macro p1 ; Macro for printing 16 bit digits
mov dx, p1
add dx, 48
mov ah, 2
int 21h
endm

printchr macro p1 ; Macro for printing character in single quote
mov dl, p1
mov ah, 2
int 21h
endm

printstr macro p1 ; Macro for printing string
mov dx, offset p1
mov ah,9
int 21h
endm

printer macro p1 ; Macro for printing the actual grid that is shown to the user
call enterkey
mov si, offset p1

call numberproc ; procedure for printing the first row of the grid
call enterkey

call extraproc ; procedure for printing the actual field 


endm


.model small
.stack 100h
.data
easymine db 0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,1,42,1,0,0,0,1,1,1,1,1,1,0,1,2,3,42,1,1,1,1,0,1,42,42,2,1,1,42,2,0,1,2,2,1,0,1,2,42,1,1,1,0,1,1,1,1,1,1,42,3,2,2,42,1,0,0,1,2,42,42,2,1,1,0,0
easywinner db 71
mediummine db 1,42,2,2,42,42,2,2,42,2,2,4,42,4,3,42,2,1,1,42,4,42,3,3,2,2,0,2,3,42,3,42,2,42,1,0,42,3,2,3,3,3,2,1,0,42,2,1,42,3,42,1,0,0,1,1,1,2,42,3,3,1,1,0,0,0,1,3,42,3,42,2,0,0,0,0,2,42,3,2,42
difficultmine db 42,2,1,42,42,42,2,42,1,42,3,2,4,42,5,4,3,2,1,3,42,4,4,42,42,4,42,1,3,42,42,5,42,42,5,42,42,2,2,3,42,42,5,5,42,1,1,1,2,4,42,3,42,42,0,0,1,42,3,2,3,4,4,1,2,3,3,42,2,2,42,42,1,42,42,2,1,2,42,3,2
actmine db 81 dup("#")
greet db "Welcome to the minesweeper game. $"
pro db "Choose your difficulty: $"
opt1 db "1.Easy$"
opt2 db "2.Medium$"
opt3 db "3.Hard$"
str1 db "Enter the row: $"
str2 db "Enter the column: $"
over db "Game Over.$"
str3 db "Choose the option what to do: $"
str4 db "1. Flag$"
str5 db "2. Mine$"
str6 db "3. Unflag$"
win db "You have won the game$"
winchecker db 0
row dw ?
flag db 33
choice db 0
.code
main proc


mov ax, @data
mov ds, ax

; logic for checking the level for mine

printstr greet
call enterkey
printstr opt1
call enterkey
printstr opt2
call enterkey
printstr opt3
call enterkey
printstr pro

mov ah,1
int 21h
sub al, 48

; checking for mediumn level

cmp al, 2
jne forhard
sub easywinner, 10
mov choice, 2

jmp play

; checking for hard level
forhard:
cmp al, 3
jne play
sub easywinner, 20
mov choice, 3

play:
; logic for asking the cell through row and column in which we have to mine, flag or unflag
printer actmine
call enterkey
mov dx, offset str1
mov ah, 9
int 21h
mov al, 0
mov ah, 1
int 21h
sub al, 49

mov bl, 9
mul bl
mov row, ax

call enterkey

mov dx, offset str2
mov ah, 9
int 21h

mov ah, 1
int 21h


sub ax, 48
xor ah, ah
dec ax
add row, ax

call enterkey

mov dx, offset str4
mov ah, 9
int 21h

call enterkey

mov dx, offset str5
mov ah, 9
int 21h

call enterkey

printstr str6

call enterkey

mov dx, offset str3
mov ah, 9
int 21h

mov ah, 0
mov ah, 1
int 21h
sub ax, 48
xor ah, ah
cmp ax, 1
je flagger
cmp ax, 3
je unflagger
call enterkey

cmp choice, 2
jg ste1
jb ste2
mov si, offset mediummine
jmp now1

ste2:
mov si, offset easymine
jmp now1

ste1:
mov si, offset difficultmine

now1:
mov ax, row
add si, ax
mov dl, [si]
mov si, offset actmine
add si, ax
mov bl, '#' ; here checking for unmine cell only unmine cell can increase the counter(winchecker) 
cmp [si], bl
jne nextera
mov [si], dl
cmp dl, 42
je overnow
inc winchecker
xor bl,bl
nextera:
mov bl, winchecker
cmp bl, easywinner
jge winner
call enterkey
jmp play

flagger: ; logic for remembering warning of a cell that there might be a bomb
mov ax, row
mov si, offset actmine
add si, ax
mov dl, 33 
mov [si], dl

jmp play

unflagger:  ; logic for checking if there is a flag to remove it 
mov ax, row 
mov si, offset actmine 
add si, ax
mov dl, '#'
mov bl, flag
cmp [si], bl
jne nextera 
mov [si], dl
jmp play

overnow: ; when the game is not win and it is over
printer actmine
mov dx, offset over
mov ah, 9
int 21h

mov ah, 4ch 
int 21h

winner: ; win the game message
mov dx, offset win
mov ah, 9 
int 21h

mov ah,4ch
int 21h



main endp


enterkey proc

mov dl, 10
mov ah, 2
int 21h
mov dl, 13
mov ah, 2
int 21h

ret
enterkey endp
numberproc proc

mov cl, 9
mov bl, 1
printchr ' '

col:
printchr ' '
printdigit bl
inc bl

loop col

ret

numberproc endp

extraproc proc

mov cx, 9
mov bl,48

outerloop:
mov dl, bl
inc dl
mov ah, 2
int 21h
mov bl, dl
push cx
mov cl, 9

gridprinter: 
mov dl, ' '
mov ah, 2
int 21h

mov dl, [si]
cmp dl, 10
jg next
add dl, 48

next:
mov ah, 2
int 21h

inc si

loop gridprinter

call enterkey

pop cx

loop outerloop



ret
extraproc endp
end main
