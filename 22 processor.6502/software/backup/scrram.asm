;__SCRRAM_______________________________________________________
;
; This is a quick program that can be put on a ROM to test the
; 65C02 board. It will output a continuous stream of TEXT
; to the UART. It does not require the stack, BUT DOES TEST RAM and
; is pretty much the simplest code imaginable. :)
;
; It assumes that the 65C02 board is set for IOPage $DF.
;
; ** Note that this program will set the console port to 9600/8/n/1.
;
;_______________________________________________________________

; UART 16C550 SERIAL
UART0           = $DF58         ; DATA IN/OUT
UART1           = $DF59         ; CHECK RX
UART2           = $DF5A         ; INTERRUPTS
UART3           = $DF5B         ; LINE CONTROL
UART4           = $DF5C         ; MODEM CONTROL
UART5           = $DF5D         ; LINE STATUS
UART6           = $DF5E         ; MODEM STATUS
UART7           = $DF5F         ; SCRATCH REG.

BANK00          = $DF50
BANK40          = $DF51
BANK80          = $DF52
BANKC0          = $DF53

        .SEGMENT "ROM"

;__COLD_START___________________________________________________
;
; PERFORM SYSTEM COLD INIT
;
;_______________________________________________________________
COLD_START:

;* Setup Memory Banks (RAM 0000-C000, ROM C000-FFFF)
        LDA     #$80
        STA     BANK00
        LDA     #$81
        STA     BANK40
        LDA     #$82
        STA     BANK80
        LDA     #$03
        STA     BANKC0

        LDA     #$80            ;
        STA     UART3           ; SET DLAB FLAG
        LDA     #12             ; SET TO 12 = 9600 BAUD
        STA     UART0           ; save baud rate
        LDA     #00             ;
        STA     UART1           ;
        LDA     #03             ;
        STA     UART3           ; SET 8 BIT DATA, 1 STOPBIT
        LDA     #$0B             ; ACTIVATE MAPPER
        STA     UART4           ;

        LDA     #'A'
        STA     $1000

SERIAL_OUTCH:
TX_BUSYLP:
        LDA     UART5           ; READ LINE STATUS REGISTER
        AND     #$20            ; TEST IF UART IS READY TO SEND (BIT 5)
        CMP     #$00
        BEQ     TX_BUSYLP       ; IF NOT REPEAT
        LDA     $1000
        STA     UART0           ; THEN WRITE THE CHAR TO UART
        INC     $1000
        LDA     $1000
        CMP     #'Z'
        BNE     SERIAL_OUTCH
        LDA     #'A'
        STA     $1000
        JMP     SERIAL_OUTCH


        .SEGMENT "VECTORS"
; $FFFA
NMIVECTOR:
        .WORD   COLD_START      ;
RSTVECTOR:
        .WORD   COLD_START      ;
INTVECTOR:
        .WORD   COLD_START      ;

        .END
