/// mv.xv a0, v0.0
/// mv.xv a1, v0.1
/// mv.xv a2, v1.0
/// mv.xv a3, v1.1
/// vadd2 v2, v1, v0
/// mv.vx v2.0, a0
/// mv.vx v2.1, a1

// C code: (uint64, uint64) vadd2(a0, a1, a2, a3) {return (a0 + a2, a1 + a3)};
// We can use a0 and a1 as return value at the same time. See
// https://github.com/riscv-non-isa/riscv-elf-psabi-doc/blob/master/riscv-cc.adoc

  .globl vadd2
vadd2:
  // Generated by parser_helper.py
  .word 0b00000000000001010001000000001011
  .word 0b00000000000101011001000000001011
  .word 0b00000000000001100001000010001011
  .word 0b00000000000101101001000010001011
  .word 0b00000010000000001000000100001011
  .word 0b00000000000000010000010100001011
  .word 0b00000000000100010000010110001011
  ret