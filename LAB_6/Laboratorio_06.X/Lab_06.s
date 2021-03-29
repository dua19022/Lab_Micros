;******************************************************************************
; Laboratorio 06
;*****************************************************************************
; Archivo:	Lab_06.s
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
  CONFIG  FOSC =    INTRC_NOCLKOUT   ; Oscillator Selection bits (XT oscillator: Crystal/resonator on RA6/OSC2/CLKOUT and RA7/OSC1/CLKIN)
  CONFIG  WDTE =    OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  PWRTE =   OFF            ; Power-up Timer Enable bit (PWRT enabled)
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
reset02 macro	    ; Se crea una macro para reiniciar el timer2
    BANKSEL PR2
    movlw   100	    ; Tiempo de intruccion
    movwf   PR2

    endm
;******************************************************************************
; Variables
;******************************************************************************
        ; Se definen variables , pero por el momento no las estoy usando
PSECT udata_shr ;Common memory
    
    W_TEMP:	    ; Variable para que se guarde w
	DS 1
    STATUS_TEMP:    ; Variable para que guarde status
	DS 1
    nibble:
	DS  2
    count:
	DS 1
    disp_var:	   ; Variable para los displays
	DS  2
    flags:
	DS  1

PSECT udata_bank0 
    var:
	DS  1
    count01:
	DS  1
    blinkact:
	DS  1

	
;******************************************************************************
; Vector Reset
;******************************************************************************
PSECT resVect, class=code, abs, delta=2
;--------------------------vector reset-----------------------------------------
ORG 00h        ;posicion 0000h para el reset
resetVec:
    PAGESEL main
    goto main
;******************************************************************************
; Interrupciones
;******************************************************************************
PSECT code, delta=2, abs
ORG 04h 
    
push:			; Mover las variables temporales a w
    movwf   W_TEMP
    swapf   STATUS, W
    movwf   STATUS_TEMP

isr:

    BANKSEL PORTB	
    btfsc   TMR1IF	; Revisar si hay overflow del timer1
    call    int_tmr1	; Se llama la subrutina del timer1
    btfsc   T0IF	; Se verifica el overflow del timer0
    call    int_tmr	; Se llama la subrutina del timer0
    
    BANKSEL PIR1
    btfsc   TMR2IF     ; Verificar el overflow del timer2
    call    int_tmr2   ; Llamar la interrupcion del timer2
    BANKSEL TMR2
    bcf	    TMR2IF     ; Se limpia la bandera del timer2
 
pop:			; Regresar w al status
    swapf   STATUS_TEMP, W
    movwf   STATUS
    swapf   W_TEMP, F
    swapf   W_TEMP, W
    retfie

;******************************************************************************
; Subrutinas de Interrupcion
;******************************************************************************
int_tmr2:	; Interrupcion timer2
    btfsc   blinkact, 0	    ; Verificar bandera
    goto    off

on:
    bsf	    blinkact, 0	    ; Activar bandera
    return    
    
off:
    bcf	    blinkact, 0	   ; Descativar bandera
    return

int_tmr1:	; Interruocion timer1
    BANKSEL TMR1H   
    movlw   0xE1       ; Modifico los registros del timer1
    movwf   TMR1H
    
    BANKSEL TMR1L
    movlw   0x7C
    movwf   TMR1L
    
    incf    count01	; Se incrementa la variable para el timer
    bcf	    TMR1IF
    return    
    
int_tmr:
    call    reset0	;Se limpia el TMR0
    bcf	    PORTD, 1	;Se limpian todos los puertos que van a los transistores
    bcf	    PORTD, 2
    btfsc   flags, 0
    goto    disp_02   
 
    ; Se crean varias rutinas internas para activar los displays
disp_01:
    movf    disp_var, w
    movwf   PORTC
    bsf	    PORTD, 2
    goto    next_disp01
disp_02:
    movf    disp_var+1, W
    movwf   PORTC
    bsf	    PORTD, 1
next_disp01:
    movlw   1
    xorwf   flags, f
    return
 
;******************************************************************************
; Configuracion de tabla
;******************************************************************************
PSECT code, delta=2, abs
ORG 100h    ;posicion para el codigo
 
; Tabla de la traduccion de binario a decimal
table:
    clrf	PCLATH
    bsf		PCLATH, 0
    andlw	0x0F	    ; Se pone como limite F , en hex 15
    addwf	PCL
    RETLW	00111111B   ;0
    RETLW	00000110B   ;1
    RETLW	01011011B   ;2
    RETLW	01001111B   ;3
    RETLW	01100110B   ;4
    RETLW	01101101B   ;5
    RETLW	01111101B   ;6
    RETLW	00000111B   ;7
    RETLW	01111111B   ;8
    RETLW	01101111B   ;9
    RETLW	01110111B   ;A
    RETLW	01111100B   ;B
    RETLW	00111001B   ;C
    RETLW	01011110B   ;D
    RETLW	01111001B   ;E
    RETLW	01110001B   ;F
    
    
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
        
    
    ; Se llama las configuraciones del clock
    call    clock		; Llamo a la configurcion del oscilador interno   
    
    ;***************Configuracion de interrupciones****************************
    BANKSEL INTCON
    bsf	    GIE		; Interrupcion global
    bsf	    T0IE	; Interrupcion timer0
    bcf	    T0IF
    
    BANKSEL PIE1
    bsf	    TMR2IE	;habilita timer2 para pr2
    bsf	    TMR1IE	;habilita timer1 interrupcion por overflow
    
    BANKSEL PIR1
    bcf	    TMR2IF	;limpiar banderas para timer2
    bcf	    TMR1IF	;limpiar banderas de interrupcion para tiemr 1
    ;**************************************************************************
    
    ;***************Configuracion de Timer0************************************
    BANKSEL OPTION_REG
    BCF	    T0CS
    BCF	    PSA		;prescaler asignado al timer0
    BSF	    PS0		;prescaler tenga un valor 1:256
    BSF	    PS1
    BSF	    PS2
    ;**************************************************************************
    
    ;****************Configuracion de Timer1***********************************
    BANKSEL T1CON
    bsf	    T1CKPS1	;prescaler 1:8
    bsf	    T1CKPS0
    bcf	    TMR1CS	;internal clock
    bsf	    TMR1ON	;habilitar timer1
    ;**************************************************************************

    ;****************Configuracion de Timer2***********************************
    BANKSEL T2CON
    movlw   1001110B     ;1001 para el postcaler, 1 timer 2 on, 10 precaler 16
    movwf   T2CON
    ;**************************************************************************
    
    ; Limpiar los puertos
    BANKSEL PORTA
    clrf    PORTA
    clrf    PORTB
    clrf    PORTC
    clrf    PORTD
    clrf    PORTE
    
;******************************************************************************
; Loop Principal
;******************************************************************************
loop:
    reset02
    BANKSEL PORTA
    call    div_nib	; Se llama a la division de los nibbles
    
    btfss   blinkact, 0
    call    prep_nib	; Se mandan los nibbles a cada display
    
    btfsc   blinkact, 0
    call    blink	; Se llama al papaedeo
    
    
goto    loop
;******************************************************************************
; Sub-Rutinas 
;******************************************************************************
div_nib:    ; Se separan los nibbles para la primera parte
    movf    count01, w
    andlw   00001111B
    movwf   nibble
    swapf   count01, w	; Se cambian los ultimos 4 bits por los primeros
    andlw   00001111B
    movwf   nibble+1 
    return
    
prep_nib:   ; Se mandan los valores que se quieren desplegar en el 7 segmentos
    movf    nibble, w
    call    table
    movwf   disp_var, F		; Display 1
    movf    nibble+1, w
    call    table
    movwf   disp_var+1, F	; Display 2
    bsf	    PORTD, 0
    return

blink:	    ; Parpadeo
    movlw   0
    movwf   disp_var
    movwf   disp_var+1
    bcf	    PORTD, 0
    return
    
reset0:
    ;BANKSEL PORTA
    movlw   255	    ; Tiempo de intruccion
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
        
END

