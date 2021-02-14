;******************************************************************************
; Laboratorio 01
;******************************************************************************
; Archivo:	Lab_02.s
; Dispositivo:	PIC16F887
; Autor:	Marco Duarte
; Compilador:	pic-as (v2.30), MPLABX V5.45
;******************************************************************************

PROCESSOR 16F887
#include <xc.inc>

;******************************************************************************
; Palabras de configuracion 
;******************************************************************************

; CONFIG1
  CONFIG  FOSC = XT             ; Oscillator Selection bits (XT oscillator: Crystal/resonator on RA6/OSC2/CLKOUT and RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  PWRTE = ON            ; Power-up Timer Enable bit (PWRT enabled)
  CONFIG  MCLRE = OFF           ; RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  IESO = OFF            ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
  CONFIG  LVP = ON              ; Low Voltage Programming Enable bit (RB3/PGM pin has PGM function, low voltage programming enabled)

; CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)
  

;******************************************************************************
; Variables
;******************************************************************************
    ; Se definen variables , pero por el momento no las estoy usando
PSECT udata_bank0 ;Common memory
    
/* counter01:
    DS 1 ; 1 byte
    
counter02:
    DS 1 ; 1 byte

discount01:
    DS 1 ; 1 byte
    
discount02:
    DS 1 ; 1 byte
    
sum:
    DS 1 ; 1 byte
*/
    
       
;******************************************************************************
; Vector Reset
;******************************************************************************
PSECT resVect, class=code, abs, delta=2
;--------------------------vector reset-----------------------------------------
ORG 00h        ;posicion 0000h para el reset
resetVec:
    PAGESEL main
    goto main

PSECT code, delta=2, abs
ORG 100h    ;posicion para el codigo

    
;******************************************************************************
; Configuracion 
;******************************************************************************
    ; Esta es la configuracion de los pines
	
main:
    ; Configurar puertos digitales
    BANKSEL ANSEL	; Se selecciona bank 3
    clrf    ANSEL	; Definir puertos digitales
    clrf    ANSELH
    
    ; Configurar puertos de salida A
    BANKSEL TRISA	; Se selecciona bank 1
    bsf	    TRISA,  0	; R0 lo defino como input
    bsf	    TRISA,  1	; R1 lo defino como input
    bsf	    TRISA,  2	; R2 lo defino como input
    bsf	    TRISA,  3	; R3 lo defino como input
    bsf	    TRISA,  4	; R4 lo defino como input
    bsf	    TRISA,  6	; R6 lo defino como input
    bsf	    TRISA,  7	; R7 lo defino como input
    
    ; Configurar puertos de salida B
    BANKSEL TRISB	; Se selecciona bank 1
    bcf	    TRISB,  0	; R0 lo defino como output
    bcf	    TRISB,  1	; R1 lo defino como output
    bcf	    TRISB,  2	; R2 lo defino como output
    bcf	    TRISB,  3	; R3 lo defino como output
    
    ; Configurar puertos de salida C
    BANKSEL TRISC	; Se selecciona bank 1
    bcf	    TRISC,  0	; R0 lo defino como output
    bcf	    TRISC,  1	; R1 lo defino como output
    bcf	    TRISC,  2	; R2 lo defino como output
    bcf	    TRISC,  3	; R3 lo defino como output
    
    ; Configurar puertos de salida D
    BANKSEL TRISD	; Se selecciona el bank 1
    bcf	    TRISD,  0	; R0 lo defino como output
    bcf	    TRISD,  1	; R1 lo defino como output
    bcf	    TRISD,  2	; R2 lo defino como output
    bcf	    TRISD,  3	; R3 lo defino como output
    bcf	    TRISD,  4	; R4 lo defino como output
    
    ; Limpiar los puertos
    BANKSEL PORTA
    clrf    PORTA
    clrf    PORTB
    clrf    PORTC
    clrf    PORTD
;******************************************************************************
; Loop Principal
;******************************************************************************

    ; Se define el loop que se va a realizar todo el tiempo
loop:
    
    btfss   PORTA, 0	; El puerto del primero boton
    call    counter01	; Llama a la subrutina de contador
    
    btfss   PORTA, 1
    call    discount01
    
    btfss   PORTA, 2
    call    counter02
    
    btfss   PORTA, 3
    call    discount02
    
    btfss   PORTA, 4
    call    sum
    
    goto loop		; Regresa al inicio
    
;******************************************************************************
; Sub-Rutinas 
;******************************************************************************
    ; Aqui se definen los antirebotes y el incremento y decremento
counter01: ; Incremento
    btfss   PORTA, 0
    goto    $-1
    incf    PORTB, 1
    return
    
counter02:
    btfss   PORTA, 2
    goto    $-1
    incf    PORTC, 1
    return
    
discount01: ; Decremento
    btfss   PORTA, 1	; Donde esta ubicado el boton
    goto    $-1		; Regresa una instruccion y se queda en un loop
    decfsz  PORTB, 1	; El puerto donde esta la led y 1 para que guarde el registro
    return		; Regresa el main loop
    
discount02:
    btfss   PORTA, 3
    goto    $-1
    decfsz  PORTC, 1
    return
    
sum:	    ; La suma de los contadores
    btfss   PORTA, 4	; Donde esta ubicado el bototn
    goto    $-1
    movf    PORTB, 0	; Muevo el registro del puerto B a W
    addwf   PORTC, 0	; Hago la suma entre W y el puerto 
    movwf   PORTD	; Muevo la suma de W y C al puerto D
    return
    

END