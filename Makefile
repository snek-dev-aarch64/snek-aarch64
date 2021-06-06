ARMGNU ?= aarch64-linux-gnu

SRC_DIR = src/

AOPS = -g --warn --fatal-warnings
ASM_SRCS = $(shell find $(SRC_DIR) -name *.s)
ASM_OBJS = $(patsubst $(SRC_DIR)%.s,%.o,$(ASM_SRCS))

all: kernel8.img

start.o:  $(SRC_DIR)start.s screen.o
app.o:    $(SRC_DIR)app.s screen.o snek.o random.o
snek.o:   $(SRC_DIR)snek.s screen.o
screen.o: $(SRC_DIR)screen.s
random.o: $(SRC_DIR)random.s
food.o:   $(SRC_DIR)food.s screen.o snek.o random.o

$(ASM_OBJS):
	$(ARMGNU)-as $(AOPS) $< -o $@

kernel8.img : memmap $(ASM_OBJS)
	$(ARMGNU)-ld $(ASM_OBJS) -T memmap -o kernel8.elf -M > memory_map.txt
	$(ARMGNU)-objdump -D kernel8.elf > kernel8.list
	$(ARMGNU)-objcopy kernel8.elf -O binary kernel8.img

run : all
	qemu-system-aarch64 -M raspi3 -kernel kernel8.img -serial stdio

run-qemu : kernel8.img
	qemu-system-aarch64 -s -S -M raspi3 -kernel kernel8.img

run-gdb:
	$(ARMGNU)-gdb -ex "set architecture aarch64" -ex "target remote localhost:1234" --ex "dashboard registers -style list 'x0 x1 x2 x3 x4 x5 x6 x7 x8 x9 x10 x11 x12 x13 x14 x15 x16 x17 x18 x19 x20 x21 x22 x23 x24 x25 x26 x27 x28 x29 x30 sp pc cpsr'"

.PHONY: clean
clean :
	-rm -f $(ASM_OBJS) memory_map.txt kernel8.list kernel8.img kernel8.elf
