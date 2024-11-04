;/*
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ANSI.CFG
;   Copied to CONFIG.ASM for general release.
;
;       Modify the parameters below to reflect your system
;
;
;   This version is for assembly by  NASM 0.98.39 or later
;
;   Copyright (C) 2010,2011 John R. Coffman.  All rights reserved.
;   Provided for hobbyist use on the N8VEM SBC-188 board.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Define the serial terminal that the Video BIOS must emulate
; Set one of the following to 1
; If you have no idea what to choose, set TTY to 1
TTY     equ     0       ; hardcopy -- cannot position the cursor
DUMB    equ     0       ; dumb CRT -- ^H, ^J, ^K, ^L can move the cursor
ANSI    equ     1       ; very smart, like a VT-100
WYSE    equ     0       ; very smart Wyse series (30, 50, ...)
; others may get added in the future
;  ONE OF THE ABOVE must BE SET TO 1!!!!!
;
; Define the UART startup bit rate - 1200-19200 are most common
;UART_RATE	equ	0		; 1200
;UART_RATE	equ	1		; 2400
;UART_RATE	equ	2		; 4800
UART_RATE	equ	3		; 9600
;UART_RATE	equ	4		; 19200
;UART_RATE	equ	5		; 38400
;UART_RATE	equ	6		; 57600
;UART_RATE	equ	7		; 115200

; Does the serial terminal use the DSR/DTR protocol for flow control?
;UART_DSR_PROTOCOL	equ		1	; Yes!
UART_DSR_PROTOCOL       equ             WYSE    ; Wyse always uses it
						; but not ANSI
; Define the size of the ROM image on the system in Kilobytes
; It may be smaller than the actual EPROM in use.
; The following sizes are supported:  32, 64, 128, and 256
%ifndef ROM
ROM             equ     32              ; 64 is the default
%endif

; Define the number of Wait States at which the ROM operates
ROM_WS          equ     1               ; 0..3  (1 is the default)

; Define the size in Kilobytes of DOS RAM (low SRAM plus EMM allocate RAM)
; This is a desired size and will only be present if a 4MEM board is added
RAM_DOS         equ     640

; Define the size of the low SRAM on the system in Kilobytes
; the default is 512 kilobytes
RAM             equ     512             ; (512 is the default)

; Define the number of Wait States at which the RAM operates
RAM_WS          equ     0               ; 0..3  (0 is the default)

; Define the number of Wait States for Local Peripheral devices (600-7FF)
LCL_IO_WS       equ     1               ; 0..3  (1 is the default)

; Define the number of Wait States for ECB BUS peripheral devices (4xx)
BUS_IO_WS       equ     3               ; 0..3  (3 is the default)

; Define the time zone in which we build the Relocatable BIOS
%ifndef TIMEZONE
%define TIMEZONE "CST"
%endif

; Has the REDBUG debugger been loaded?
%ifndef SOFT_DEBUG
%define SOFT_DEBUG 0
%endif

; Should the BIOS include "Tiny BASIC" in the image?
%ifndef TBASIC
TBASIC          equ     1		; default is 1
%endif

; Should the BIOS include the Floating Point Emulator?  The 80188 does
; not allow a floating point co-processor, so this is probably a good idea.
%ifndef FPEM
FPEM            equ     1               ; default is 1
%endif

; Define the maximum number of EMM (4MEM) boards supported
EMM_BOARDS      equ     0

; Should the Floating Point Emulator use temporary storage in the EBDA
; or at locations 0280h..3FFh in low memory?
%if SOFT_DEBUG
FPEM_USE_EBDA   equ     FPEM            ; default is 0
%else
FPEM_USE_EBDA   equ     0; FPEM            ; default is 0
%endif

; Define the size of the EPROM that is to be installed on the system
; It may be larger than the actual ROM image to be generated.
%ifndef CHIP
CHIP            equ     64
%endif

; Does the SBC-188 00.4 board have the LS138/LS08 piggyback fix
; Set to 1 for the SBC-188 v1.0 and later production boards
;FDC_PIGGYBACK_FIX       equ     0       ; Fix not installed
FDC_PIGGYBACK_FIX       equ     1       ; fix  IS  installed

; On SBC-188 rev 00.4 board, there is a published hardware fix (2010-09-18).
; If the wiring update is installed, or you have a later board, then
; set this to 0.  If you are using the software workaround, then set this
; to 1.  The rev 1.0 board has this fix already.
NEED_TIMER_FIX  equ     0               ; have revised hardware
;NEED_TIMER_FIX  equ     1               ; use workaround

; Define the UART oscillator speed
UART_OSC        equ     1843200         ; 1.8432 Mhz is specified


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; end of the User configuration
;       Do Not modify anything below this point
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Define existence of any uart chip
UART		equ	TTY+DUMB+ANSI+WYSE
startuplength   equ     512                     ; may be up to 1024
startseg        equ     0FFFFh - (ROM*64) + 1
highrom         equ     (ROM*400h)&0FFFFh
startupseg      equ     0FFFFh - (startuplength>>4) + 1
bios_data_seg   equ     040h            ; segment of BIOS data area


%define ARG(n) [bp+2+(n)*2]

%macro  check   1.nolist
 %if (%1)
   %error Check Failure: %1
 %endif
%endm
%macro  range   3.nolist
 %if (%1)<(%2)
   %error Out of Range: %1
 %elif (%1)>(%3)
   %error Out of Range: %1
 %endif
%endm
_terminal equ UART
 check   RAM_DOS&15
 check   RAM&(RAM-1)
 check   ROM&(ROM-1)
 range   RAM,32,512
 range   ROM,32,256
 range   RAM_WS,0,3
 range   ROM_WS,0,3
 range   RAM_DOS,RAM,(1024-ROM)
 range   LCL_IO_WS,0,3
 range   BUS_IO_WS,0,3
 range   UART_OSC,500000,16000000
 range   UART_RATE,0,7
 range	 UART,0,1
 range	 _terminal,1,2

%ifndef SOFT_DEBUG
%define SOFT_DEBUG 0
%endif

%ifndef TRACE
%define TRACE 0
%endif

%ifdef MAKE_OBJECT_FILE
        segment _DATA WORD PUBLIC CLASS=DATA
        export _ROMsize
        export _CHIPsize
_ROMsize        dw      ROM
_CHIPsize       dw      CHIP
%endif
; end of the Hardware configuration file
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;*/
