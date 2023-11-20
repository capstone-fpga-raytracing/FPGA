/* Address */

/* Memory */
#define DDR_BASE              0x00000000 // 0x00000000 - 0x3FFFFFFF, HPS 1GB SDRAM (DDR3)
#define SDRAM_BASE            0xC0000000 // 0xC0000000 - 0xC3FFFFFF, FPGA 64MB SDRAM
#define FPGA_ONCHIP_BASE      0xC8000000 // 0xC8000000 - 0xC803FFFF, FPGA 256KB on-chip: default pixel buffer
#define FPGA_CHAR_BASE        0xC9000000 // 0xC9000000 - 0xC9001FFF, FPGA 8KB on-chip: default char buffer
#define A9_ONCHIP_BASE        0xFFFF0000 // 0xFFFF0000 - 0xFFFFFFFF, HPS 64KB on-chip

/* Cyclone V FPGA devices */
#define LEDR_BASE             0xFF200000
#define HEX3_HEX0_BASE        0xFF200020
#define HEX5_HEX4_BASE        0xFF200030
#define SW_BASE               0xFF200040
#define KEY_BASE              0xFF200050
#define JP1_BASE              0xFF200060
#define JP2_BASE              0xFF200070
#define PS2_BASE              0xFF200100
#define PS2_DUAL_BASE         0xFF200108
#define JTAG_UART_BASE        0xFF201000
#define JTAG_UART_2_BASE      0xFF201008
#define IrDA_BASE             0xFF201020
#define TIMER_BASE            0xFF202000
#define AV_CONFIG_BASE        0xFF203000
#define PIXEL_BUF_CTRL_BASE   0xFF203020
#define CHAR_BUF_CTRL_BASE    0xFF203030
#define AUDIO_BASE            0xFF203040
#define FPGA_SDRAM_TRIGGER    0xFF203050 // 0xFF203050 - 0xFF203053, 3B (for avalon_sdr)
#define VIDEO_IN_BASE         0xFF203060
#define ADC_BASE              0xFF204000

/* Cyclone V HPS devices */
#define HPS_GPIO1_BASE        0xFF709000
#define HPS_TIMER0_BASE       0xFFC08000
#define HPS_TIMER1_BASE       0xFFC09000
#define HPS_TIMER2_BASE       0xFFD00000
#define HPS_TIMER3_BASE       0xFFD01000
#define FPGA_BRIDGE           0xFFD0501C

/* ARM A9 MPCORE devices */
#define   PERIPH_BASE         0xFFFEC000    // base address of peripheral devices
#define   MPCORE_PRIV_TIMER   0xFFFEC600    // PERIPH_BASE + 0x0600

/* Interrupt controller (GIC) CPU interface(s) */
#define MPCORE_GIC_CPUIF      0xFFFEC100    // PERIPH_BASE + 0x100
#define ICCICR                0x00          // offset to CPU interface control reg
#define ICCPMR                0x04          // offset to interrupt priority mask reg
#define ICCIAR                0x0C          // offset to interrupt acknowledge reg
#define ICCEOIR               0x10          // offset to end of interrupt reg
/* Interrupt controller (GIC) distributor interface(s) */
#define MPCORE_GIC_DIST       0xFFFED000    // PERIPH_BASE + 0x1000
#define ICDDCR                0x00          // offset to distributor control reg
#define ICDISER               0x100         // offset to interrupt set-enable regs
#define ICDICER               0x180         // offset to interrupt clear-enable regs
#define ICDIPTR               0x800         // offset to interrupt processor targets regs
#define ICDICFR               0xC00         // offset to interrupt configuration regs



#define ABS(x) (((x) > 0) ? (x) : -(x))

/* Constants */
#define RESOLUTION_X 320
#define X_BOUND 319
#define RESOLUTION_Y 240
#define Y_BOUND 239


#include <stdlib.h>
/*
#include <math.h>
#include <stdio.h>
#include <time.h>
*/


// Global variables



// Helper functions



int main(void) {
    volatile int * ptr = (int *) SDRAM_BASE;
    // Copy to 15 memory locations including the base address
    *ptr = 0xFF; // First 
    ptr = (int *) SDRAM_BASE + 4; // Move to second location
    *ptr = 0x55; // Second
    ptr = (int *) SDRAM_BASE + 8; // Move to third location
    *ptr = 0xaa; // Third
    ptr = (int *) SDRAM_BASE + 12; // Move to fourth location
    *ptr = 0x55; // Fourth
    ptr = (int *) SDRAM_BASE + 16; // Move to fifth location
    *ptr = 0xaa; // Fifth
    ptr = (int *) SDRAM_BASE + 20; // Move to sixth location
    *ptr = 0x55; // Sixth
    ptr = (int *) SDRAM_BASE + 24; // Move to seventh location
    *ptr = 0xaa; // Seventh
    ptr = (int *) SDRAM_BASE + 28; // Move to eighth location
    *ptr = 0x55; // Eighth
    ptr = (int *) SDRAM_BASE + 32; // Move to ninth location
    *ptr = 0xaa; // Ninth
    ptr = (int *) SDRAM_BASE + 36; // Move to tenth location
    *ptr = 0x55; // Tenth
    ptr = (int *) SDRAM_BASE + 40; // Move to eleventh location
    *ptr = 0xaa; // Eleventh
    ptr = (int *) SDRAM_BASE + 44; // Move to twelfth location
    *ptr = 0x55; // Twelfth
    ptr = (int *) SDRAM_BASE + 48; // Move to thirteenth location
    *ptr = 0xaa; // Thirteenth
    ptr = (int *) SDRAM_BASE + 52; // Move to fourteenth location
    *ptr = 0x55; // Fourteenth
    ptr = (int *) SDRAM_BASE + 56; // Move to fifteenth location
    *ptr = 0xaa; // Fifteenth
    ptr = (int *) FPGA_SDRAM_TRIGGER; // Set to point to read trigger
    *ptr = 1; // trigger read
}