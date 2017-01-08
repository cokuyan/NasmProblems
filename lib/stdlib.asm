SECTION .data
  STDOUT equ 1
  SYS_WRITE equ 4
  SYS_EXIT equ 1
  Debug db "I am here"
  DLEN equ $-Debug

SECTION .text

GLOBAL PrintStr, Atoi, PrintInt, PrintNL ; Procedures
GLOBAL STDOUT, SYS_WRITE, SYS_EXIT ; Data items

;;;
; Print string in EAX to STDOUT
; EAX: address of string
; EBX: num bytes to print
PrintStr:
  ; store registers
  push eax
  push ebx
  push ecx
  push edx

  mov ecx, eax ; move string to ECX to print
  mov edx, ebx ; move length of string to EBX
  ; call sys_write to stdout
  mov eax, SYS_WRITE
  mov ebx, STDOUT
  int 80h 

  ; restore registers and exit
  pop edx
  pop ecx
  pop ebx
  pop eax
  ret

;;;
; Convert an ASCII string to integer
; Stores the digit in EAX until it encounters end of string or a non-digit
; EAX: String address
; out -> EAX: integer
Atoi:
  ; save registers
  push ebx
  push ecx
  push edx
  push esi

  mov esi, eax ; move string address to ESI
  mov eax, 0
  mov ecx, 0
; loop to convert ascii values one at a time
.convert:
  xor ebx, ebx
  mov bl, [esi+ecx] ; move single ascii value to EBX
  ; ensure value is an actual digit
  cmp bl, '0'
  jb .finish
  cmp bl, '9'
  ja .finish
  
  sub bl, '0' ; convert ascii value to digit
  add eax, ebx ; add into EAX
  ; multiply EAX by 10 to prepare addition
  ; of the next ascii value
  mov ebx, 10
  mul ebx
  inc ecx
  jmp .convert ; continue loop if not done yet

.finish:
  ; undo extra multiplication
  mov ebx, 10
  div ebx
  ; restore register values
  pop esi
  pop edx
  pop ecx
  pop ebx
  ret

;;;
; Print a new line character
PrintNL:
  ; store registers
  push eax
  push ebx

  mov eax, 10 ; move ascii for '\n'
  push eax ; save on stack
  mov eax, esp ; move address of stack to eax
  mov ebx, 1
  call PrintStr ; print NL

  ; restore registers and return
  pop eax
  pop ebx
  pop eax
  ret

;;;
; Print an integer
; EAX: integer to print
PrintInt:
  ; store registers
  push eax
  push ebx
  push ecx
  push edx
  xor ecx, ecx ; clear counter

; build string by dividing by 10
; the remainder is converted into ascii
; and saved on the stack
.build:
  xor edx, edx ; clear remainder
  mov ebx, 10 ; prepare division
  idiv ebx ; divide by 10
  add edx, 48 ; convert remainder into ascii
  push edx ; save on stack
  inc ecx ; increment to keep track of length
  cmp eax, 0 ; check if done
  jnz .build

; print string
.print:
  mov eax, esp
  mov ebx, 1
  call PrintStr
  pop eax
  dec ecx
  jnz .print

  ; restore registers and return
  pop edx
  pop ecx
  pop ebx
  pop eax
  ret
