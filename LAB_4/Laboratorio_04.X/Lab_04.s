;******************************************************************************
; Laboratorio 04
;******************************************************************************
; Archivo:	Lab_04.s
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
  CONFIG  FOSC =    INTRC_CLKOUT   ; Oscillator Selection bits (XT oscillator: Crystal/resonator on RA6/OSC2/CLKOUT and RA7/OSC1/CLKIN)
  CONFIG  WDTE =    OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  PWRTE =   ON            ; Power-up Timer Enable bit (PWRT enabled)
  CONFIG  MCLRE =   OFF           ; RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
  CONFIG  CP =	    OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD =	    OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN =   OFF           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  IESO =    OFF            ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
  CONFIG  FCMEN =   OFF           ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
  CONFIG  LVP =	    ON              ; Low Voltage Programming Enable bit (RB3/PGM pin has PGM function, low voltage programming enabled)

; CONFIG2
  CONFIG  BOR4V =   BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT =	    OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)

;******************************************************************************
; Macros 
;******************************************************************************
   
active_int macro    ; La macro para incrementar y decrementar
    btfss   PORTB, 0
    incf    PORTA
    btfss   PORTB, 1
    decf    PORTA
    endm
    
resetD macro	    ; Reset del timer0
    btfss   T0IF    ; overflow timer0
    movlw   12	    ; de donde empieza el timer
    movwf   TMR0    ; Mover el valor anterior al registro
    bcf	    T0IF
    endm  

;******************************************************************************
; Variables
;******************************************************************************
    ; Se definen variables , pero por el momento no las estoy usando
PSECT udata_shr ;Common memory
    
    W_TEMP:	    ; Variable para	que se guarde w
	DS 1
	
    STATUS_TEMP:    ; Variable para que guarde status
	DS 1
	
    var:
	DS 1
	
    delay:
	DS 1
       
;******************************************************************************
; Vector Reset
;******************************************************************************
PSECT resVect, class=code, abs, delta=2
;--------------------------vector reset-----------------------------------------
ORG 00h        ;posicion 0000h para el reset
resetVec:
    PAGESEL main
    goto main
;--------------------------Interrupcion-----------------------------------------
PSECT code, delta=2, abs
ORG 04h 
    
push:			; Mover las variables temporales a w
    movwf   W_TEMP
    swapf   STATUS, W
    movwf   STATUS_TEMP

isr:
    BANKSEL PORTB
    btfsc   RBIF	; Revisar si hay interrupciones en el puerto b
    call    active	; Se llama a la subrutina de los botones
    bcf	    RBIF	
    btfsc   T0IF	; Revisar si hay overflow del timer0
    call    timer0
    
pop:			; Regresar w al status
    swapf   STATUS_TEMP, W
    movwf   STATUS
    swapf   W_TEMP, F
    swapf   W_TEMP, W
    retfie
    
PSECT code, delta=2, abs
ORG 100h    ;posicion para el codigo
 
; Tabla de la traduccion de binario a hex
table:
    clrf    PCLATH
    bsf	    PCLATH, 0
    andlw   0x0F	; Se pone como limite 16 , en hex F
    addwf   PCL
    retlw   00111111B	; 0
    retlw   00000110B	; 1
    retlw   01011011B	; 2
    retlw   01001111B	; 3
    retlw   01100110B	; 4
    retlw   01101101B	; 5
    retlw   01111101B	; 6
    retlw   00000111B	; 7
    retlw   01111111B	; 8
    retlw   01101111B	; 9
    retlw   01110111B	; A
    retlw   01111100B	; b
    retlw   00111001B	; C
    retlw   01011110B	; d
    retlw   01111001B	; E
    retlw   01110001B	; F
   
;******************************************************************************
; Configuracion 
;******************************************************************************
    ; Esta es la configuracion de los pines
ORG 118h
main:
    ; Configurar puertos digitales
    BANKSEL ANSEL	; Se selecciona bank 3
    clrf    ANSEL	; Definir puertos digitales
    clrf    ANSELH
    
    ; Configurar puertos de salida A
    BANKSEL TRISA	; Se selecciona bank 1
    bcf	    TRISA,  0	; R0 lo defino como output
    bcf	    TRISA,  1	; R1 lo defino como output
    bcf	    TRISA,  2	; R2 lo defino como output
    bcf	    TRISA,  3	; R3 lo defino como output
    
    ; Configurar puertos de salida B
    BANKSEL TRISB	; Se selecciona bank 1
    bsf	    TRISB,  0	; R0 lo defino como input
    bsf	    TRISB,  1	; R1 lo defino como input
        
    ; Configurar puertos de salida C
    BANKSEL TRISC	; Se selecciona bank 1
    bcf	    TRISC,  0	; R0 lo defino como output
    bcf	    TRISC,  1	; R1 lo defino como output
    bcf	    TRISC,  2	; R2 lo defino como output
    bcf	    TRISC,  3	; R3 lo defino como output
    bcf	    TRISC,  4	; R4 lo defino como output
    bcf	    TRISC,  5	; R5 lo defino como output
    bcf	    TRISC,  6	; R6 lo defino como output
    bcf	    TRISC,  7	; R7 lo defino como output
    
    ; Configurar puertos de salida D
    BANKSEL TRISD	; Se selecciona el bank 1
    bcf	    TRISD,  0	; R0 lo defino como output
    bcf	    TRISD,  1	; R1 lo defino como output
    bcf	    TRISD,  2	; R2 lo defino como output
    bcf	    TRISD,  3	; R3 lo defino como output
    bcf	    TRISD,  4	; R4 lo defino como output
    bcf	    TRISD,  5	; R5 lo defino como output
    bcf	    TRISD,  6	; R6 lo defino como output
    bcf	    TRISD,  7	; R7 lo defino como output
    
    ; Poner puerto b en pull-up
    BANKSEL OPTION_REG
    bcf	    OPTION_REG, 7
    
    BANKSEL WPUB
    bsf	    WPUB, 0	; Se activa el pull-up interno
    bsf	    WPUB, 1	; Se activa el pull-up interno
    bcf	    WPUB, 2
    bcf	    WPUB, 3
    bcf	    WPUB, 4
    bcf	    WPUB, 5
    bcf	    WPUB, 6
    bcf	    WPUB, 7
    
    ; Se llama las configuraciones del clock
    call    clock		; Llamo a la configurcion del oscilador interno
    
    ; Interrupciones
    BANKSEl IOCB	; Activar interrupciones
    movlw   00000011B	; Activar las interrupciones en RB0 y RB1
    movwf   IOCB
    
    
    BANKSEL INTCON
    movf    PORTB, 0
    bcf	    RBIF
    
    ; Bits de interrupcion
    bsf	    GIE		; Interrupcion global
    bsf	    RBIE	; Interrupcion puerto b
    bsf	    T0IE	; Interrupcion timer0
    bcf	    T0IF
    
    ; Configuracion de Timer0
    BANKSEL OPTION_REG
    BCF	    T0CS
    BCF	    PSA		;prescaler asignado al timer0
    BSF	    PS0		;prescaler tenga un valor 1:256
    BSF	    PS1
    BSF	    PS2
    
    
    ; Limpiar los puertos
    BANKSEL PORTA
    clrf    PORTA
    clrf    PORTB
    clrf    PORTC
    clrf    PORTD
    
;******************************************************************************
; Loop Principal
;******************************************************************************
    loop:
    
    movf    PORTA, w	; Se mueve el contador binario a w
    call    table	; Se manda a traducir el contador binario
    movwf   PORTC	; Se mueve la traduccion al puerto c
    
    goto    loop
;******************************************************************************
; Sub-Rutinas 
;******************************************************************************
     
reset0:
    movlw   1	    ; Tiempo de intruccion
    movwf   TMR0
    bcf	    T0IF    ; Volver 0 al bit del overflow
    return
    
clock:		    ; Se configura el oscilador interno
    BANKSEL OSCCON
    bcf	    IRCF2   ; Se selecciona 010
    bsf	    IRCF1   
    bcf	    IRCF0   ; Frecuencia de 250 KHz
    bsf	    SCS	    ; Activar oscilador interno
    return
    
timer0:
    btfss   T0IF	; Sumar cuando llegue al overflow el timer0
    goto    $-1
    call    reset0		; Regresa el overflow a 0
    incf    var
    movf    var, w
    call    table
    movwf   PORTD
    return
    
active:   ; La subrutina para incrementar y decrementar
    btfss   PORTB, 0	; Se revisa si se apacha el boton 1
    incf    PORTA	; Se incrmenta
    btfss   PORTB, 1	; Se revisa si se apacha el boton 2
    decf    PORTA	; Se decrementa
    return    
    
END
