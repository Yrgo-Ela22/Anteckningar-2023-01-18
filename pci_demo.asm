;/********************************************************************************
;* pci_demo.asm: Demonstration av PCI-avbrott i assembler. En lysdiod ansluten
;*               till pin 8 (PORTB0) togglas via nedtryckning av en tryckknapp
;*               ansluten till pin 13 (PORTB5).
;********************************************************************************/

; Makrodefinitioner:
.EQU LED1    = PORTB0 ; Lysdiod 1 ansluten till pin 8 (PORTB0).
.EQU BUTTON1 = PORTB5 ; Tryckknapp 1 ansluten till pin 13 (PORTB0).

.EQU RESET_vect  = 0x00 ; Reset-vektor, här startar programmet.
.EQU PCINT0_vect = 0x06 ; Avbrottsvektor för PCI-avbrott på I/O-port B.

;/********************************************************************************
;* .CSEG: Programminnet, här lagras programkoden.
;********************************************************************************/
.CSEG

;/********************************************************************************
;* RESET_vect: Programmets startadress. Vi hoppar till subrutinen main för att
;*             starta programmet.
;********************************************************************************/
.ORG RESET_vect
   RJMP main

;/********************************************************************************
;* PCINT0_vect: Avbrottsvektor för PCI-avbrott på I/O-port B. Vi hoppar till
;*              motsvarande avbrottsrutin ISR_PCINT0 för att hantera avbrottet.
;********************************************************************************/
.ORG PCINT0_vect
   RJMP ISR_PCINT0

;/********************************************************************************
;* ISR_PCINT0: Avbrottsrutin för PCI-avbrott på I/O-port B som äger rum vid
;*             nedtryckning och uppsläppning av tryckknappen. Vid nedtryckning
;*             togglas lysdioden, annars gör ingenting.
;********************************************************************************/
ISR_PCINT0:
   IN R24, PINB
   ANDI R24, (1 << BUTTON1)
   BREQ ISR_PCINT0_end
   OUT PINB, R16 
ISR_PCINT0_end:
   RETI

;/********************************************************************************
;* main: Initierar systemet vid start. Programmet hålls sedan igång så länge
;*       matningsspänning tillförs.
; ********************************************************************************/
main:

;/********************************************************************************
;* setup: Initierar I/O-portar samt aktiverar PCI-avbrott på tryckknappens pin.
;*        Följande innehåll skrivs till CPU-register R16 - R17 och bihålls sedan
;*        under programmets gång.
;*
;*        R16 = (1 << LED1)
;*        R17 = (1 << BUTTON1)
;*       
;*        För att aktivera PCI-avbrott I/O-port B ettställs biten PCIE0
;*        (Pin Change Interrupt Enable 0) i kontrollregistret PCICR
;*        (Pin Change Interrupt Control Register). Eftersom PCIE0 utgör bit 0
;*        i detta register, precis som LED1, används därmed innehållet i
;*        CPU-register R16 = (1 << LED1) för att ettställa denna bit. 
;*
;*        För att enbart aktivera PCI-avbrott på tryckknappens pin ettställs
;*        biten PCINT5 i maskregister PCMSK0 (Pin Change Mask Register 0).
;*        Då PCINT5 utgör bit i detta register, precis som BUTTON1, används 
;*        innehållet i CPU-register R17 = (1 << BUTTON) för att ettställa 
;*        denna bit. 
;********************************************************************************/
setup:
   LDI R16, (1 << LED1)
   OUT DDRB, R16
   LDI R17, (1 << BUTTON1)
   OUT PORTB, R17
   SEI
   STS PCICR, R16 
   STS PCMSK0, R17 

;/********************************************************************************
;* main_loop: Tom loop som håller igång programmet så länge matningsspänning
;*            tillförs.
; ********************************************************************************/
main_loop:
   RJMP main_loop