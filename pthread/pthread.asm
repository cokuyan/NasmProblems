;;; 
; Section for declaring initialized data
[SECTION .data]
HelloText db "Hello Thread", 10, 0 ; output text for the threads
NUM_THREADS EQU 4

;;;
; Section for declaring uninitialized data
[SECTION .bss]
threads resd NUM_THREADS ; array to hold threads

;;;
; Section for the actual code
[SECTION .text]

; declaring what functions we need from C
extern printf ; for printing output easily
extern pthread_create ; to create the threads
extern pthread_join ; to join the threads when done

; so C can find where to start
global main

main:
; how all C functions start
  push ebp
  mov ebp, esp
  push ebx
  push esi
  push edi

  mov ebx, NUM_THREADS ; initialize ebx with thread count
; pushing arguments for pthread_create
  push 0 ; NULL for no arguments to give to thread
  push hello ; function for threads to run
  push 0 ; NULL for options
  push threads ; pointer for address of first thread
startThread:
  call pthread_create ; create and run thread
  add dword [esp], 4 ; move to next address of array threads
  dec ebx ; decrement counter
  jnz startThread ; continue starting threads until we're done

  add esp, 16 ; clear stack
  mov ebx, 0 ; initialize counter to zero
; pushing arguments for pthread_join
  push 0 ; NULL for no options
joinThread:
  push dword [threads + ebx * 4] ; push thread to join
  call pthread_join ; join the thread
  pop eax ; remove thread from stack
  inc ebx ; increment counter
  cmp ebx, NUM_THREADS ; check to see if we've joined all threads
  jne joinThread ; continue joining until done

  add esp, 4 ; clear stack

exit:
  pop edi
  pop esi
  pop ebx
  mov esp, ebp
  pop ebp
  ret

; function for threads to run
hello:
  push ebp
  mov ebp, esp
  push ebx
  push esi
  push edi

  push HelloText
  call printf
  add esp, 4

  pop edi
  pop esi
  pop ebx
  mov esp, ebp
  pop ebp
  ret
