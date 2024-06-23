bootrom_img = cust_inst_bootrom.img cust_inst_bootrom.sv cust_inst_bootrom.elf

RISCV_GCC?=riscv-none-elf-gcc
RISCV_OBJCOPY?=riscv-none-elf-objcopy
PYTHON=python

all: $(bootrom_img)

%.img: %.bin
	dd if=$< of=$@ bs=128

%.bin: %.elf
	$(RISCV_OBJCOPY) -O binary $< $@

%.elf: %.S main.c linker.ld
	$(RISCV_GCC) -Tlinker.ld -march=rv64imc_zicsr -mcmodel=medany -nostartfiles -mabi=lp64 $< main.c -nostdlib -static -Wl,--no-gc-sections -O3 -o $@

%.sv: %.img
	$(PYTHON) ../gen_rom.py $<

clean:
	rm -f $(bootrom_img)