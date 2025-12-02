// demo.c
// STM32F103C8T6 裸机点亮 + 1Hz 闪烁 PC13（蓝丸板默认 LED 接在 PC13，低电平点亮）

#include <stdint.h>

#define RCC_BASE   0x40021000
#define GPIOC_BASE 0x40011000

#define RCC_APB2ENR (*(volatile uint32_t *)(RCC_BASE + 0x18))
#define GPIOC_CRH   (*(volatile uint32_t *)(GPIOC_BASE + 0x04))
#define GPIOC_ODR   (*(volatile uint32_t *)(GPIOC_BASE + 0x0C))

// 粗暴但极准的延时（HSI 8 MHz 下约 500 ms）
static void delay(volatile uint32_t d) {
    while (d--) __asm__("nop");
}

uint32_t u32debugTimes = 100;

int main(void) {
    // 1. 使能 GPIOC 时钟
    RCC_APB2ENR |= (1 << 4);

    // 2. 配置 PC13 为推挽输出，2 MHz（足够快）
    GPIOC_CRH &= ~(0xF << 20);   // 清零
    GPIOC_CRH |=  (0x2 << 20);   // 通用推挽输出，2 MHz

    // 3. 主循环闪烁
    while (1) {
        GPIOC_ODR |=  (1 << 13);   // 高电平 → 灯灭
        delay(200000);
        GPIOC_ODR &= ~(1 << 13);  // 低电平 → 灯亮
        delay(200000);
        u32debugTimes++;
    }
}