; This program takes in a file and appends the line number
; of each line to the beginning of each line
; The CLI is: line_nums <input file> <output file>
; If an output file is not specified, the output will be
; put in a file called 'out.txt'.

[SECTION .data] ; section for initialized data

WriteBase db '%d: %s', 0 ; string format for output
WriteCode db 'w', 0 ; signifier for write access to file
ReadCode db 'r', 0 ; signifier for read access to file
DefaultWriteFile db 'out.txt', 0 ; output filename when not supplied
HelpText db 'Please specify an input file and an optional output file.', 10,0
HELPLEN EQU $-HelpText

[SECTION .bss] ; section for declared variables

LineCount resd 1 ; variable to hold the current line number being printed
BUFSIZE EQU 80 ; max size for string buffer
Buff resb BUFSIZE+5 ; string buffer to hold each line (+5 for safety)
ReadFile resd 1 ; pointer to input file handler
WriteFile resd 1 ; pointer to output file handler

[SECTION .text] ; section for code

; references to C standard library functions
extern fopen
extern fclose
extern fgets
extern fprintf
extern printf

global main ; declare main access point global so compiler can access it

main:
; setup stack frame for procedure
  push ebp
  mov ebp, esp
  push ebx
  push esi
  push edi

; check number of arguments supplied
; ensure there is at least an input file
checkArgCount:
  mov eax, [ebp + 8] ; move argument count into EAX
  cmp eax, 1 ; if there are more than one argument (more than just program name)
  ja openFirstFile ; open the input file
  jmp outputHelp ; otherwise output help text

; get file name from second command line argument,
; open file, then save file handler into ReadFile
openFirstFile:
  mov ebx, [ebp + 12] ; move pointer to arguments into EBX
  push ReadCode ; push signifier for read access onto stack for fopen
  push DWORD [ebx + 4] ; push input filename onto stack
  call fopen ; open the file (file handler saved in EAX)
  add esp, 8 ; clear stack by adding two double words' worth of bytes
  cmp eax, 0 ; check to see if file was opened successfully
  jle exit ; exit if file was not opened successfully
  mov [ReadFile], eax ; save file handler in ReadFile

; if an output file was specified, open/create it
; otherwise use the default filename
openSecondFile:
  mov eax, [ebp + 8] ; get argument count to see if a second file name was provided
  push WriteCode ; push signifier for write access for fopen
  cmp eax, 2 ; check to see if a second filename was given
  jna .useDefaultWriteFile ; use default file name if not given
  mov ebx, [ebp + 12] ; otherwise get pointer to argument list
  push DWORD [ebx + 8] ; and push second filename onto stack for fopen
  jmp .open ; jump to fopen

.useDefaultWriteFile:
  push DefaultWriteFile ; push default filename onto stack for fopen

.open:
  call fopen ; open output file
  add esp, 8 ; clear stack
  cmp eax, 0 ; check if file was opened successfully
  jle exit ; exit if file was not opened successfully
  mov [WriteFile], eax ; save file handler in WriteFile

  mov DWORD [LineCount], 0 ; initialize line count variable

copyText:
  add DWORD [LineCount], 1 ; increment line number
  push DWORD [ReadFile] ; push file handler onto stack for fgets
  push DWORD BUFSIZE ; give max size of buffer to avoid overflow
  push Buff ; give buffer to hold line
  call fgets ; call fgets
  add esp, 12 ; clear stack of variables
  cmp eax, 0 ; check to see if we reached end of file, or error
  jle closeFiles ; close files and exit if done

; take line from buffer and write to output file
; with the format in WriteBase
writeText:
  push Buff ; push line for %s in WriteBase format
  push DWORD [LineCount] ; push line number for %d
  push WriteBase ; push in actual format for fprintf
  push DWORD [WriteFile] ; push in file handler
  call fprintf ; print formatted line into file
  add esp, 16 ; clear stack
  jmp copyText ; get next line to write

; close both read and write files when done
closeFiles:
  push DWORD [ReadFile]
  call fclose
  add esp, 4
  push DWORD [WriteFile]
  call fclose
  add esp, 4

; clear up stack frame and return back to C shutdown code
exit:
  pop edi
  pop esi
  pop ebx
  mov esp, ebp
  pop ebp
  ret

; print out help line if arguments are not supplied
outputHelp:
  mov ecx, HelpText
  mov edx, HELPLEN
  mov eax, 4 ; sys_write system call code
  mov ebx, 1 ; stdout code
  int 80h ; trigger interrupt to make sys_write call to stdout
  jmp exit
