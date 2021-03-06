@Echo Off
"_Assembly Tools\AS\asl.exe" -q -cpu Z80 -gnuerrors -c -A -L -xx "Dual PCM\Z80.asm"
"_Assembly Tools\AS\p2bin.exe" "..\Z80.p" "Dual PCM\Z80.bin" -r 0x-0x

"_Assembly Tools\ListEqu.exe" AS z80 "Dual PCM\Z80.lst" asm68k 68k "Equz80.asm"

IF NOT EXIST "Dual PCM\Z80.p" goto Error
CLS
DEL "Dual PCM\Z80.lst"
DEL "Dual PCM\Z80.p"
DEL "Dual PCM\Z80.h"
cd rings
rings.exe
cd ..
"_Assembly Tools\Asm68k.exe" /o op+ /o os+ /o ow+ /o oz+ /o oaq+ /o osq+ /o omq+ /q /k /p /o ae- "sonic1.asm", "s1vt.gen", ,"sonic.lst"
"_Assembly Tools\CheckFix.exe" "s1vt.gen"

if "%1"=="1" goto Finish

:Error
pause

:Finish