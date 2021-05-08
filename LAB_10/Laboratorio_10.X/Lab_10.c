/******************************************************************************
 * Laboratorio 10
 ******************************************************************************
 * File:   Lab_10.c
 * Author: Marco
 * 
 *
 */

//  Bits de configuracion   //
// CONFIG1
#pragma config FOSC = INTRC_NOCLKOUT// Oscillator Selection bits (INTOSCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
#pragma config WDTE = OFF       // Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
#pragma config PWRTE = OFF      // Power-up Timer Enable bit (PWRT disabled)
#pragma config MCLRE = OFF      // RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
#pragma config CP = OFF         // Code Protection bit (Program memory code protection is disabled)
#pragma config CPD = OFF        // Data Code Protection bit (Data memory code protection is disabled)
#pragma config BOREN = OFF      // Brown Out Reset Selection bits (BOR disabled)
#pragma config IESO = OFF       // Internal External Switchover bit (Internal/External Switchover mode is disabled)
#pragma config FCMEN = OFF      // Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
#pragma config LVP = OFF        // Low Voltage Programming Enable bit (RB3 pin has digital I/O, HV on MCLR must be used for programming)

// CONFIG2
#pragma config BOR4V = BOR40V   // Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
#pragma config WRT = OFF        // Flash Program Memory Self Write Enable bits (Write protection off)

// #pragma config statements should precede project file includes.
// Use project enums instead of #define for ON and OFF.

#define _XTAL_FREQ 8000000
#include <xc.h>
#include <stdint.h>
#include <stdio.h>  // Para usar printf
//-----------------------------------------------------------------------------
//                            Variables 
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
//                            Prototipos 
//-----------------------------------------------------------------------------
void setup(void);   // Defino las funciones antes de crearlas
void putch(char data); //funcion para recibir el dato que se desea transmitir
void text(void);    // Donde se introduce las cadenas de texto

//-----------------------------------------------------------------------------
//                            Main
//-----------------------------------------------------------------------------
void main(void) {
    
    setup();    // Llamo a mi configuracion

    
    while(1)    // Equivale al loop
    {
    text();    // Funcion de cadenas de caracteres
       
    }
}

void putch(char data){      // Funcion especifica de libreria stdio.h
    while(TXIF == 0);
    TXREG = data; // lo que se muestra de la cadena
    return;
}
// Funcion donde se definen las cadenas mediante printf
void text(void){
    __delay_ms(250); //Tiempos para el despliegue de los caracteres
    printf("\r Elija una opcion: \r");
    __delay_ms(250);
    printf(" 1. Desplegar cadena de caracteres \r");
    __delay_ms(250);
    printf(" 2. Desplegar PORTA \r");
    __delay_ms(250);
    printf(" 3. Desplegar PORTB \r");
    while (RCIF == 0);
    // Se establecen las opciones del menu
    if (RCREG == '1'){
        __delay_ms(500);
        printf("\r Cadena de caracteres cargando...... \r");
    }
    if (RCREG == '2'){ //segunda opcion del menu
        printf("\r Insertar caracter para desplegar en PORTA: \r");
        while (RCIF == 0);
        PORTA = RCREG; //para recibir un caracter
    }
    if (RCREG == '3'){ //tercera opcion del menu
        printf("\r Insertar caracter para desplegar en PORTB: \r");
        while (RCIF == 0);
        PORTB = RCREG;
    }
    else{ //Si se ingresa una popcion fuera de la lista, no sucede nada
        NULL;       // equivalente a un nop
    }
    return;
}

void setup(void){
    
    // Configuraciones de puertos digitales
    ANSEL = 0;
    ANSELH = 0;
    
    // Configurar bits de salida o entradaas
    TRISA = 0x0;
    TRISB = 0x0;
    
    // Se limpian los puertos
    PORTA = 0x00;
    PORTB = 0x00;
    
    
    // Se configura el oscilador
    OSCCONbits.IRCF2 = 1;
    OSCCONbits.IRCF1 = 1;
    OSCCONbits.IRCF0 = 1;   // Se configura a 8MHz
    OSCCONbits.SCS = 1;
    
    // Configuacion de las interrupciones
    INTCONbits.GIE = 1;
    INTCONbits.PEIE = 1;    // Periferical interrupt
    PIE1bits.RCIE = 1;      // Interrupcion rx
    PIE1bits.TXIE = 1;      // Interrupcion TX


    // Configuraciones TX y RX
    TXSTAbits.SYNC = 0;
    TXSTAbits.BRGH = 1;
    BAUDCTLbits.BRG16 = 1;
    
    SPBRG = 208;
    SPBRGH = 0;
    
    RCSTAbits.SPEN = 1;
    RCSTAbits.RX9 = 0;
    RCSTAbits.CREN = 1;
    
    TXSTAbits.TXEN = 1;
    
    PIR1bits.RCIF = 0;  // Bandera rx
    PIR1bits.TXIF = 0;  // bandera tx

}