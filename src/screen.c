#include "screen.h"

#define SCREEN_BASE  ((volatile uint16_t*)0x202400)
#define SCREEN_WIDTH 32
#define SCREEN_HEIGHT 16

static int cursor_x = 0;
static int cursor_y = 0;

void map_screen_address_to_tile(uint16_t* tile, ScreenPos* pos) {
    uint16_t ch = *tile;

    if (ch >= 0x60) {
        if (ch == 0x60) *tile = 0x1C;
        else if (ch < 0x7B) *tile &= 0x1F;
        else if (ch == 0x5B) *tile = 0x28;
        else if (ch == 0x5D) *tile = 0x29;
        else *tile &= 0x3F;
    } else {
        switch (ch) {
            case 0x24: *tile = 0x1C; break;
            case 0x5B: *tile = 0x28; break;
            case 0x5D: *tile = 0x29; break;
            default:   *tile &= 0x3F; break;
        }
    }

    uint32_t offset = pos->y * SCREEN_WIDTH + pos->x;
    volatile uint16_t* screen_addr = SCREEN_BASE + offset;
    *screen_addr = *tile;
}

void print_string(const char* str) {
    while (*str) {
        if (*str == '\n') {
            cursor_x = 0;
            cursor_y++;
            if (cursor_y >= SCREEN_HEIGHT) {
                cursor_y = 0; // or scroll if you want
            }
        } else {
            ScreenPos pos = { cursor_x, cursor_y };
            uint16_t ch = (uint16_t)(*str);
            map_screen_address_to_tile(&ch, &pos);

            cursor_x++;
            if (cursor_x >= SCREEN_WIDTH) {
                cursor_x = 0;
                cursor_y++;
                if (cursor_y >= SCREEN_HEIGHT) {
                    cursor_y = 0; // or scroll
                }
            }
        }
        str++;
    }
}

void InitIO(short device_code, short value) {
    __asm__ volatile (
        "move.w %[v], -(%%sp)\n\t"
        "move.w %[d], -(%%sp)\n\t"
        "jsr 0x3BCE\n\t"
        "addq.l #4, %%sp\n\t"
        :
        : [d] "d" (device_code), [v] "d" (value)
        : "memory"
    );
}
