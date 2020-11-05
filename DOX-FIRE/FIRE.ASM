; Simple FiRe example ... random generator + blur
;
;
; Code by dox
; dox@malenstwo.iinf.polsl.gliwice.pl
; http://www.emugaming.com/hash


start equ 20    ;HEIGHT
ilel equ 20     ;WIDTH


SECTION "vblank",HOME[$40]
       push af
       push hl
       xor a
       ld [$ff4f],a   ;vram bank 0
       ld hl,$ff51
       ld a,$c4       ;$c400 -> $9800
       ld [hl+],a
       xor a
       ld [hl+],a
       ld a,$18
       ld [hl+],a
       xor a
       ld [hl+],a
       ld a,35        ;32*18/16-1
       ld [hl+],a     ;GDMA

       ld a,1
       ld [$ff4f],a  ;vram bank 1
       ld hl,$ff51
       ld a,$c8      ;$c800 -> $9800
       ld [hl+],a
       xor a
       ld [hl+],a
       ld a,$18
       ld [hl+],a
       xor a
       ld [hl+],a
       ld a,35       ;32*18/16-1
       ld [hl+],a    ;GDMA
       pop hl
       pop af
       reti

SECTION "header",HOME[$100]
        nop
        jp code_start
        ds 48
        db "FiRe          ", 0, $80
        db 0,0,0
        db 0                          ; rom only
        db 0                          ; 32kB rom
        db 0                          ; 0kB ram
        db 1,0,0,0,0,0

code_start:

        di
        ld a,1
        ld [$ffff],a    ;vbi enable
        ld [$ff4d],a
        stop            ;2x speed
wait:
        ld a,[$ff44]
        cp $91
        jr nz,wait
        ld hl,$ff40
        res 7,[hl]      ;lcd off
        ld a,8
        ld [$ff43],a    ;scx
        ld hl,tiles
        ld de,$8000
        ld c,112
copy_tiles:
        ld a,[hl+]
        ld [de],a
        inc de
        dec c
        jr nz,copy_tiles

        ld a,128
        ld hl,$ff68
        ld [hl+],a
        ld de,colors
        ld c,64
set_pal:
        ld a,[de]
        ld [hl],a
        inc de
        dec c
        jr nz,set_pal


        ld hl,$ff40
        set 7,[hl]      ;lcd on

        ld hl,$c000
        ld bc,1024*3+1
clear_ram:
        xor a
        ld [hl+],a
        dec bc
        ld a,b
        or c
        jr nz,clear_ram
        ei

main_loop:

        ld c,ilel+2
        ld d,start      ;y
        ld e,0          ;x
line:
        ld a,[old_value]
        ld hl,$ff04
        xor [hl]
        ld [old_value],a
        ld hl,$ff41
        xor [hl]
        cp 128
        ld a,0          ;!NOT xor
        jr c,detour
        ld a,55
detour:
        push af
        call set_pixel ; (x,y)
        dec d
        pop af
        call set_pixel ; (x,y-1)
        inc d
        inc e
        dec c
        jr nz,line
        call blur
        jr main_loop


blur:
        ld d,start-1     ; y
        ld e,0           ; x

loop:
        ld h,d
        ld l,e
        call get_pixel   ;(x,y)
        ld c,a
        inc l
        call get_pixel   ;(x+1,y)
        add c
        ld c,a
        dec l
        inc h
        call get_pixel   ;(x,y+1)
        add c
        ld c,a
        dec h
        dec l
        call get_pixel   ;(x-1,y)
        add c
        srl a
        srl a            ;/4
        call set_pixel
        inc e
        ld a,ilel+2
        cp e
        jr nc,loop
        ld e,0
        dec d
        jr nz,loop
        ret

get_pixel:
        push bc
        push de
        push hl
        ld a,h
        ld h,0
        swap a          ;*16
        srl a           ;/2  , bit 0 (a) (bit 4 of Y coord)  -> c
        rl h            ;c -> bit 0 (h)
        add a,a         ;just one byte - sla a  - 2  ;)
        sla a           ;*2 (*32) ; bit 7 (a)  -> c
        rl h            ;hl = y*32
        and %11100000
        or l
        ld l,a          ;hl -> map offset (32*y+x)
        ld bc,map
        add hl,bc
        ld a,[hl]
        pop hl
        pop de
        pop bc
        ret


set_pixel:
        push bc
        push de
        push hl
        ld c,a
        ld a,d
        ld d,0
        swap a
        srl a
        rl d
        add a,a
        sla a
        rl d
        and %11100000
        or e
        ld e,a
        ld a,c          ;de -> map offset
        ld hl,map
        add hl,de
        ld [hl],a
        ld hl,pixeltab
        ld b,0
        sla c
        add hl,bc
        ld a,[hl+]      ;palette
        ld b,a
        ld a,[hl+]      ;tile
        ld hl,scmap
        add hl,de
        ld [hl],a
        ld a,b
        ld hl,scmapa
        add hl,de
        ld [hl],a
        pop hl
        pop de
        pop bc
        ret


tiles:

db 0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,85,0,170,0,85,0,170,0
db 85,0,170,0,85,0,170,0,255,0,255,0
db 255,0,255,0,255,0,255,0,255,0,255,0
db 85,170,170,85,85,170,170,85,85,170,170,85
db 85,170,170,85,0,255,0,255,0,255,0,255
db 0,255,0,255,0,255,0,255,170,255,85,255
db 170,255,85,255,170,255,85,255,170,255,85,255
db 255,255,255,255,255,255,255,255,255,255,255,255
db 255,255,255,255

colors:

db 0,0,3,0,7,0,11,0,15,0,19,0
db 23,0,27,0,31,0,127,0,255,0,127,1
db 255,1,127,2,255,2,127,3,255,3,255,15
db 255,31,255,47,255,63,255,79,255,95,255,111
db 255,123,255,123,255,123,255,123,255,123,255,123
db 255,123,255,123

pixeltab:

PALT SET 0
REPT 8
TILEN SET 0
REPT 7
db PALT,TILEN
TILEN SET TILEN+1
ENDR
PALT SET PALT+1
ENDR


Section "RAM", BSS[$c000]

map:
      ds 1024    ;pixel map

scmap:
      ds 1024    ;tile map

scmapa:
      ds 1024    ;attr map

old_value :   ds 1