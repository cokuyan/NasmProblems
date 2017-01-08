This repository just holds some personal nasm projects on 32 bit Linux.

# `lib/`
This folder holds a few standard procedures to be used in other projects

# `line_nums/`
This folder holds a procedure with sample input and output files. The procedure itself simply prefixes each line of the input file with its line number.
To compile and run this program, do:
```
nasm -f elf line_nums.asm
gcc line_nums.o -o line_nums
```
and then run:
```
./line_nums input.txt
```
If you would like to specify and output file, add it after the name of the input file:
```
./line_nums input.txt output.txt
```
