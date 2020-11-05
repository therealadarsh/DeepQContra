rgbasm -ofire.obj -zff fire.asm
xlink -ts -zff -mfire.map fire.lnk
rgbfix -v -pff fire.gb

