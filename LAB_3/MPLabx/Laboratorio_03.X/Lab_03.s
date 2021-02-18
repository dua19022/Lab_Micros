;******************************************************************************
; Laboratorio 03
;******************************************************************************
; Archivo:	Lab_03.s
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
  CONFIG  FOSC = INTRC_CLKOUT   ; Oscillator Selection bits (XT oscillator: Crystal/resonator on RA6/OSC2/CLKOUT and RA7/OSC1/CLKIN)
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
PSECT udata_shr ;Common memory
    
    var:	; Se crea una variable para usar en el contador hex
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
	
main:
    ; Configurar puertos digitales
    BANKSEL ANSEL	; Se selecciona bank 3
    clrf    ANSEL	; Definir puertos digitales
    clrf    ANSELH
    bcf	    STATUS, 5
    bcf	    STATUS, 6
    
    ; Configurar puertos de salida A
    BANKSEL TRISA	; Se selecciona bank 1
    bsf	    TRISA,  0	; R0 lo defino como input
    bsf	    TRISA,  1	; R1 lo defino como input
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
    bcf	    TRISC,  4	; R4 lo defino como output
    bcf	    TRISC,  5	; R5 lo defino como output
    bcf	    TRISC,  6	; R6 lo defino como output
    bcf	    TRISC,  7	; R7 lo defino como output
    
    ; Configurar puertos de salida D
    BANKSEL TRISD	; Se selecciona el bank 1
    bcf	    TRISD,  0	; R0 lo defino como output
    
    BANKSEL OPTION_REG
    movlw   11000110B	; Prescaler de 1:256
    movwf   OPTION_REG
    
    call clock		; Llamo a la configurcion del oscilador interno
    
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
    
    btfss   T0IF	; Sumar cuando llegue al overflow el timer0
    goto    $-1
    call    reset0	; Regresa el overflow a 0
    incf    PORTB
    
    bcf	    PORTD, 0 
    call    Prueba
    
    goto loop		; Regresa al inicio
    
;******************************************************************************
; Sub-Rutinas 
;******************************************************************************
    ; Aqui se definen los antirebotes y el incremento y decremento
counter01: ; Incremento
    btfss   PORTA, 0
    goto    $-1
    incf    var		; Se incrementa el valor en la variable var
    movf    var, W	; Se mueve var a W
    call    table	; Se llama a la tabla para la traduccion
    movwf   PORTC
    return
    
discount01: ; Decremento
    btfss   PORTA, 1	; Donde esta ubicado el boton
    goto    $-1		; Regresa una instruccion y se queda en un loop
    decfsz  var		; Se decrementa el valor de la variable var
    movf    var, w
    call    table
    movwf   PORTC
    return		; Regresa el main loop
     
reset0:
    movlw   12	    ; Tiempo de intruccion
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
    
comp:
    clrf    STATUS
    movf    PORTB, W
    subwf   var, w
    btfss   STATUS, 2
    ;goto    $-1
    movwf   PORTD, 0
    ;incf    PORTD
    ;clrf    PORTB
    ;clrf    PORTD
    return
    
Prueba:
    movf    PORTB, w
    subwf   var, w
    btfsc   STATUS, 2 
    call    alarma
    return
    
alarma:
    bsf	    PORTD,0
    clrf    PORTB
    return
    
    
END


