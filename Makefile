PROJECT   = stm32f103c8t6_blink
CC        = arm-none-eabi-gcc
OBJCOPY   = arm-none-eabi-objcopy
SIZE      = arm-none-eabi-size

CPU       = -mcpu=cortex-m3 -mthumb -mfloat-abi=soft

CFLAGS    = $(CPU) -Os -g3 -Wall -fdata-sections -ffunction-sections \
            -MMD -MP --specs=nano.specs -DSTM32F103xB

LDFLAGS   = $(CPU) -T$(PROJECT).ld -Wl,--gc-sections,--print-memory-usage -specs=nosys.specs

SRCS      = demo_00.c startup.s
OBJS      = $(SRCS:.c=.o)
OBJS      := $(OBJS:.s=.o)

all: $(PROJECT).elf $(PROJECT).hex $(PROJECT).bin size

%.o: %.c
	$(CC) -c $(CFLAGS) $< -o $@

%.o: %.s
	$(CC) -c $(CPU) $< -o $@

$(PROJECT).elf: $(OBJS) $(PROJECT).ld
	$(CC) $(LDFLAGS) $(OBJS) -o $@

$(PROJECT).hex: $(PROJECT).elf
	$(OBJCOPY) -O ihex $< $@

$(PROJECT).bin: $(PROJECT).elf
	$(OBJCOPY) -O binary $< $@

size: $(PROJECT).elf
	$(SIZE) --format=berkeley $<

clean:
	rm -f *.o *.d $(PROJECT).elf $(PROJECT).hex $(PROJECT).bin

flash: $(PROJECT).hex
	openocd -f interface/stlink.cfg -f target/stm32f1x.cfg \
	-c "init" -c "reset init" \
	-c "program $< verify reset exit"

.PHONY: all clean flash size

-include $(OBJS:.o=.d)