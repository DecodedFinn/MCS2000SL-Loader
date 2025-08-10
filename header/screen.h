#ifndef SCREEN_H
#define SCREEN_H

#include <stdint.h>

#define SCREEN_BASE  ((volatile unsigned short*)0x202400)
#define SCREEN_WIDTH 32
#define SCREEN_HEIGHT 16

typedef struct {
    int x;
    int y;
} ScreenPos;

void map_screen_address_to_tile(uint16_t* tile, ScreenPos* pos);
void InitIO(short device_code, short value);
void print_string(const char* str, ScreenPos pos);

#endif // SCREEN_H
