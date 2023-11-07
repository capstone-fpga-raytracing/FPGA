#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>


// Data width is 32 bits, therefore addresses are 4 bytes

#define SDRAM 0x20000000
#define TRIGGER 0xC0000000

// 3x4 byte addresses, 12 bytes total
#define BRIDGE_SPAN 0x0C

int main(void)
{
    uint32_t a = 0;

    a = 0xAA;

    uint32_t *fpgaportrst = (uint32_t*) 0xFFC25080;
    printf("fpgaportrst: %" PRIu32 "\n", *fpgaportrst);
    uint32_t *staticcfg = (uint32_t*) 0xFFC2505C;
    printf("staticcfg: %" PRIu32 "\n", *staticcfg);
    
    *staticcfg = 0xA;
    printf("staticcfg: %" PRIu32 "\n", *staticcfg);
    *fpgaportrst = 0xFFFF;
    printf("fpgaportrst: %" PRIu32 "\n", *fpgaportrst);

    uint8_t *sdram_map = SDRAM;
    uint8_t *trigger_map = TRIGGER;

    *((uint32_t *)sdram_map) = a;
    *((uint32_t *)trigger_map) = 0x1;

    uint32_t *read_val = NULL;
    read_val = (uint32_t *)sdram_map;

    printf("%" PRIu32 "\n", *read_val);
    return 0;
}