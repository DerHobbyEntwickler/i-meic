echo on
color f0
mode con: cols=120 lines=400

set name=BIOS

nasm -f bin %name%.ASM -o %name%.BIN

COM2INC.exe %name%.BIN %name%.INC Laenge_BIOS_Array BIOS_ARR

copy %name%.INC ..\%name%.INC


pause

exit
