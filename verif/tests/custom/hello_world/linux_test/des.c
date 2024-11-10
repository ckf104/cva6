#define uint32_t unsigned int
#define uint64_t unsigned long long

void groundkeyop(uint32_t C, uint32_t D, uint32_t *rk1, uint32_t *rk2) {
  uint64_t combined = ((uint64_t)C << 28) | D;
  uint64_t ork = 0;

  ork |= ((combined >> (56 - 14)) & 1) << (47 - 0);
  ork |= ((combined >> (56 - 17)) & 1) << (47 - 1);
  ork |= ((combined >> (56 - 11)) & 1) << (47 - 2);
  ork |= ((combined >> (56 - 24)) & 1) << (47 - 3);
  ork |= ((combined >> (56 - 1)) & 1) << (47 - 4);
  ork |= ((combined >> (56 - 5)) & 1) << (47 - 5);
  ork |= ((combined >> (56 - 3)) & 1) << (47 - 6);
  ork |= ((combined >> (56 - 28)) & 1) << (47 - 7);
  ork |= ((combined >> (56 - 15)) & 1) << (47 - 8);
  ork |= ((combined >> (56 - 6)) & 1) << (47 - 9);
  ork |= ((combined >> (56 - 21)) & 1) << (47 - 10);
  ork |= ((combined >> (56 - 10)) & 1) << (47 - 11);
  ork |= ((combined >> (56 - 23)) & 1) << (47 - 12);
  ork |= ((combined >> (56 - 19)) & 1) << (47 - 13);
  ork |= ((combined >> (56 - 12)) & 1) << (47 - 14);
  ork |= ((combined >> (56 - 4)) & 1) << (47 - 15);
  ork |= ((combined >> (56 - 26)) & 1) << (47 - 16);
  ork |= ((combined >> (56 - 8)) & 1) << (47 - 17);
  ork |= ((combined >> (56 - 16)) & 1) << (47 - 18);
  ork |= ((combined >> (56 - 7)) & 1) << (47 - 19);
  ork |= ((combined >> (56 - 27)) & 1) << (47 - 20);
  ork |= ((combined >> (56 - 20)) & 1) << (47 - 21);
  ork |= ((combined >> (56 - 13)) & 1) << (47 - 22);
  ork |= ((combined >> (56 - 2)) & 1) << (47 - 23);
  ork |= ((combined >> (56 - 41)) & 1) << (47 - 24);
  ork |= ((combined >> (56 - 52)) & 1) << (47 - 25);
  ork |= ((combined >> (56 - 31)) & 1) << (47 - 26);
  ork |= ((combined >> (56 - 37)) & 1) << (47 - 27);
  ork |= ((combined >> (56 - 47)) & 1) << (47 - 28);
  ork |= ((combined >> (56 - 55)) & 1) << (47 - 29);
  ork |= ((combined >> (56 - 30)) & 1) << (47 - 30);
  ork |= ((combined >> (56 - 40)) & 1) << (47 - 31);
  ork |= ((combined >> (56 - 51)) & 1) << (47 - 32);
  ork |= ((combined >> (56 - 45)) & 1) << (47 - 33);
  ork |= ((combined >> (56 - 33)) & 1) << (47 - 34);
  ork |= ((combined >> (56 - 48)) & 1) << (47 - 35);
  ork |= ((combined >> (56 - 44)) & 1) << (47 - 36);
  ork |= ((combined >> (56 - 49)) & 1) << (47 - 37);
  ork |= ((combined >> (56 - 39)) & 1) << (47 - 38);
  ork |= ((combined >> (56 - 56)) & 1) << (47 - 39);
  ork |= ((combined >> (56 - 34)) & 1) << (47 - 40);
  ork |= ((combined >> (56 - 53)) & 1) << (47 - 41);
  ork |= ((combined >> (56 - 46)) & 1) << (47 - 42);
  ork |= ((combined >> (56 - 42)) & 1) << (47 - 43);
  ork |= ((combined >> (56 - 50)) & 1) << (47 - 44);
  ork |= ((combined >> (56 - 36)) & 1) << (47 - 45);
  ork |= ((combined >> (56 - 29)) & 1) << (47 - 46);
  ork |= ((combined >> (56 - 32)) & 1) << (47 - 47);

  *rk1 = ork & 0xFFFFFFFF;
  *rk2 = (ork >> 32) & 0xFFFFFFFF;
  return;
}

// opcode: 0
/// echo groundkeyop 2in, 2out
/// exec.p.f 0, t0, 0, a0, a1, 0
/// pick 1, t1, 0
void groundkeyop_ex(uint32_t C, uint32_t D, uint32_t *rk1, uint32_t *rk2) {
  asm volatile(".word 0b00000000101101010000001010001011;"
               ".word 0b00000000000000000001001101011011;"
               "sw t0, 0(%0);"
               "sw t1, 0(%1);"
               :
               : "r"(rk1), "r"(rk2)
               : "t0", "t1", "memory");
}

void genrotate(uint32_t val, uint32_t *res) {
  *res = ((val << 1) | (val >> (28 - 1))) & ((1 << 28) - 1);
  return;
}

// opcode: 1
/// echo genrotate 1in, 1out
/// exec.p.f 0, t0, 0, a0, x0, 1
void genrotate_ex(uint32_t val, uint32_t *res) {
  asm volatile(".word 0b00000010000001010000001010001011;"
               "sw t0, 0(%0);"
               :
               : "r"(res)
               : "t0", "memory");
}

void genkey56(uint32_t key1, uint32_t key2, uint32_t *key56_1,
              uint32_t *key56_2) {
  // 从PC1中提取56位密钥
  uint64_t key = key1 | ((uint64_t)key2 << 32);
  uint64_t key56 = 0;
  key56 |= ((key >> (64 - 57)) & 1) << (55 - 0);
  key56 |= ((key >> (64 - 49)) & 1) << (55 - 1);
  key56 |= ((key >> (64 - 41)) & 1) << (55 - 2);
  key56 |= ((key >> (64 - 33)) & 1) << (55 - 3);
  key56 |= ((key >> (64 - 25)) & 1) << (55 - 4);
  key56 |= ((key >> (64 - 17)) & 1) << (55 - 5);
  key56 |= ((key >> (64 - 9)) & 1) << (55 - 6);
  key56 |= ((key >> (64 - 1)) & 1) << (55 - 7);
  key56 |= ((key >> (64 - 58)) & 1) << (55 - 8);
  key56 |= ((key >> (64 - 50)) & 1) << (55 - 9);
  key56 |= ((key >> (64 - 42)) & 1) << (55 - 10);
  key56 |= ((key >> (64 - 34)) & 1) << (55 - 11);
  key56 |= ((key >> (64 - 26)) & 1) << (55 - 12);
  key56 |= ((key >> (64 - 18)) & 1) << (55 - 13);
  key56 |= ((key >> (64 - 10)) & 1) << (55 - 14);
  key56 |= ((key >> (64 - 2)) & 1) << (55 - 15);
  key56 |= ((key >> (64 - 59)) & 1) << (55 - 16);
  key56 |= ((key >> (64 - 51)) & 1) << (55 - 17);
  key56 |= ((key >> (64 - 43)) & 1) << (55 - 18);
  key56 |= ((key >> (64 - 35)) & 1) << (55 - 19);
  key56 |= ((key >> (64 - 27)) & 1) << (55 - 20);
  key56 |= ((key >> (64 - 19)) & 1) << (55 - 21);
  key56 |= ((key >> (64 - 11)) & 1) << (55 - 22);
  key56 |= ((key >> (64 - 3)) & 1) << (55 - 23);
  key56 |= ((key >> (64 - 60)) & 1) << (55 - 24);
  key56 |= ((key >> (64 - 52)) & 1) << (55 - 25);
  key56 |= ((key >> (64 - 44)) & 1) << (55 - 26);
  key56 |= ((key >> (64 - 36)) & 1) << (55 - 27);
  key56 |= ((key >> (64 - 28)) & 1) << (55 - 28);
  key56 |= ((key >> (64 - 20)) & 1) << (55 - 29);
  key56 |= ((key >> (64 - 12)) & 1) << (55 - 30);
  key56 |= ((key >> (64 - 4)) & 1) << (55 - 31);
  key56 |= ((key >> (64 - 61)) & 1) << (55 - 32);
  key56 |= ((key >> (64 - 53)) & 1) << (55 - 33);
  key56 |= ((key >> (64 - 45)) & 1) << (55 - 34);
  key56 |= ((key >> (64 - 37)) & 1) << (55 - 35);
  key56 |= ((key >> (64 - 29)) & 1) << (55 - 36);
  key56 |= ((key >> (64 - 21)) & 1) << (55 - 37);
  key56 |= ((key >> (64 - 13)) & 1) << (55 - 38);
  key56 |= ((key >> (64 - 5)) & 1) << (55 - 39);
  key56 |= ((key >> (64 - 62)) & 1) << (55 - 40);
  key56 |= ((key >> (64 - 54)) & 1) << (55 - 41);
  key56 |= ((key >> (64 - 46)) & 1) << (55 - 42);
  key56 |= ((key >> (64 - 38)) & 1) << (55 - 43);
  key56 |= ((key >> (64 - 30)) & 1) << (55 - 44);
  key56 |= ((key >> (64 - 22)) & 1) << (55 - 45);
  key56 |= ((key >> (64 - 14)) & 1) << (55 - 46);
  key56 |= ((key >> (64 - 6)) & 1) << (55 - 47);
  key56 |= ((key >> (64 - 63)) & 1) << (55 - 48);
  key56 |= ((key >> (64 - 55)) & 1) << (55 - 49);
  key56 |= ((key >> (64 - 47)) & 1) << (55 - 50);
  key56 |= ((key >> (64 - 39)) & 1) << (55 - 51);
  key56 |= ((key >> (64 - 31)) & 1) << (55 - 52);
  key56 |= ((key >> (64 - 23)) & 1) << (55 - 53);
  key56 |= ((key >> (64 - 15)) & 1) << (55 - 54);
  key56 |= ((key >> (64 - 7)) & 1) << (55 - 55);
  *key56_1 = key56 & 0xFFFFFFFF;
  *key56_2 = (key56 >> 32) & 0xFFFFFFFF;
  return;
}

// opcode: 2
/// echo genkey56 2in, 2out
/// exec.p.f 0, t0, 0, a0, a1, 2
/// pick 1, t1, 2
void genkey56_ex(uint32_t key1, uint32_t key2, uint32_t *key56_1,
                 uint32_t *key56_2) {
  asm volatile(".word 0b00000100101101010000001010001011;"
               ".word 0b00000100000000000001001101011011;"
               "sw t0, 0(%0);"
               "sw t1, 0(%1);"
               :
               : "r"(key56_1), "r"(key56_2)
               : "t0", "t1", "memory");
}

void genstate(uint32_t plaintext_1, uint32_t plaintext_2, uint32_t *state_1,
              uint32_t *state_2) {
  // 初始置换
  uint64_t plaintext = plaintext_1 | ((uint64_t)plaintext_2 << 32);
  uint64_t state = 0;
  state |= ((plaintext >> (64 - 58)) & 1) << (63 - 0);
  state |= ((plaintext >> (64 - 50)) & 1) << (63 - 1);
  state |= ((plaintext >> (64 - 42)) & 1) << (63 - 2);
  state |= ((plaintext >> (64 - 34)) & 1) << (63 - 3);
  state |= ((plaintext >> (64 - 26)) & 1) << (63 - 4);
  state |= ((plaintext >> (64 - 18)) & 1) << (63 - 5);
  state |= ((plaintext >> (64 - 10)) & 1) << (63 - 6);
  state |= ((plaintext >> (64 - 2)) & 1) << (63 - 7);
  state |= ((plaintext >> (64 - 60)) & 1) << (63 - 8);
  state |= ((plaintext >> (64 - 52)) & 1) << (63 - 9);
  state |= ((plaintext >> (64 - 44)) & 1) << (63 - 10);
  state |= ((plaintext >> (64 - 36)) & 1) << (63 - 11);
  state |= ((plaintext >> (64 - 28)) & 1) << (63 - 12);
  state |= ((plaintext >> (64 - 20)) & 1) << (63 - 13);
  state |= ((plaintext >> (64 - 12)) & 1) << (63 - 14);
  state |= ((plaintext >> (64 - 4)) & 1) << (63 - 15);
  state |= ((plaintext >> (64 - 62)) & 1) << (63 - 16);
  state |= ((plaintext >> (64 - 54)) & 1) << (63 - 17);
  state |= ((plaintext >> (64 - 46)) & 1) << (63 - 18);
  state |= ((plaintext >> (64 - 38)) & 1) << (63 - 19);
  state |= ((plaintext >> (64 - 30)) & 1) << (63 - 20);
  state |= ((plaintext >> (64 - 22)) & 1) << (63 - 21);
  state |= ((plaintext >> (64 - 14)) & 1) << (63 - 22);
  state |= ((plaintext >> (64 - 6)) & 1) << (63 - 23);
  state |= ((plaintext >> (64 - 64)) & 1) << (63 - 24);
  state |= ((plaintext >> (64 - 56)) & 1) << (63 - 25);
  state |= ((plaintext >> (64 - 48)) & 1) << (63 - 26);
  state |= ((plaintext >> (64 - 40)) & 1) << (63 - 27);
  state |= ((plaintext >> (64 - 32)) & 1) << (63 - 28);
  state |= ((plaintext >> (64 - 24)) & 1) << (63 - 29);
  state |= ((plaintext >> (64 - 16)) & 1) << (63 - 30);
  state |= ((plaintext >> (64 - 8)) & 1) << (63 - 31);
  state |= ((plaintext >> (64 - 57)) & 1) << (63 - 32);
  state |= ((plaintext >> (64 - 49)) & 1) << (63 - 33);
  state |= ((plaintext >> (64 - 41)) & 1) << (63 - 34);
  state |= ((plaintext >> (64 - 33)) & 1) << (63 - 35);
  state |= ((plaintext >> (64 - 25)) & 1) << (63 - 36);
  state |= ((plaintext >> (64 - 17)) & 1) << (63 - 37);
  state |= ((plaintext >> (64 - 9)) & 1) << (63 - 38);
  state |= ((plaintext >> (64 - 1)) & 1) << (63 - 39);
  state |= ((plaintext >> (64 - 59)) & 1) << (63 - 40);
  state |= ((plaintext >> (64 - 51)) & 1) << (63 - 41);
  state |= ((plaintext >> (64 - 43)) & 1) << (63 - 42);
  state |= ((plaintext >> (64 - 35)) & 1) << (63 - 43);
  state |= ((plaintext >> (64 - 27)) & 1) << (63 - 44);
  state |= ((plaintext >> (64 - 19)) & 1) << (63 - 45);
  state |= ((plaintext >> (64 - 11)) & 1) << (63 - 46);
  state |= ((plaintext >> (64 - 3)) & 1) << (63 - 47);
  state |= ((plaintext >> (64 - 61)) & 1) << (63 - 48);
  state |= ((plaintext >> (64 - 53)) & 1) << (63 - 49);
  state |= ((plaintext >> (64 - 45)) & 1) << (63 - 50);
  state |= ((plaintext >> (64 - 37)) & 1) << (63 - 51);
  state |= ((plaintext >> (64 - 29)) & 1) << (63 - 52);
  state |= ((plaintext >> (64 - 21)) & 1) << (63 - 53);
  state |= ((plaintext >> (64 - 13)) & 1) << (63 - 54);
  state |= ((plaintext >> (64 - 5)) & 1) << (63 - 55);
  state |= ((plaintext >> (64 - 63)) & 1) << (63 - 56);
  state |= ((plaintext >> (64 - 55)) & 1) << (63 - 57);
  state |= ((plaintext >> (64 - 47)) & 1) << (63 - 58);
  state |= ((plaintext >> (64 - 39)) & 1) << (63 - 59);
  state |= ((plaintext >> (64 - 31)) & 1) << (63 - 60);
  state |= ((plaintext >> (64 - 23)) & 1) << (63 - 61);
  state |= ((plaintext >> (64 - 15)) & 1) << (63 - 62);
  state |= ((plaintext >> (64 - 7)) & 1) << (63 - 63);
  *state_1 = state & 0xFFFFFFFF;
  *state_2 = state >> 32;
  return;
}

// opcode: 3
/// echo genstate 2in, 2out
/// exec.p.f 0, t0, 0, a0, a1, 3
/// pick 1, t1, 3
void genstate_ex(uint32_t plaintext_1, uint32_t plaintext_2, uint32_t *state_1,
                 uint32_t *state_2) {
  asm volatile(".word 0b00000110101101010000001010001011;"
               ".word 0b00000110000000000001001101011011;"
               "sw t0, 0(%0);"
               "sw t1, 0(%1);"
               :
               : "r"(state_1), "r"(state_2)
               : "t0", "t1", "memory");
}

void genexpendR(uint32_t R, uint32_t *expandedR_1, uint32_t *expandedR_2) {
  uint64_t expandedR = 0;
  expandedR |= 1ull * ((R >> (32 - 32)) & 1) << (47 - 0);
  expandedR |= 1ull * ((R >> (32 - 1)) & 1) << (47 - 1);
  expandedR |= 1ull * ((R >> (32 - 2)) & 1) << (47 - 2);
  expandedR |= 1ull * ((R >> (32 - 3)) & 1) << (47 - 3);
  expandedR |= 1ull * ((R >> (32 - 4)) & 1) << (47 - 4);
  expandedR |= 1ull * ((R >> (32 - 5)) & 1) << (47 - 5);
  expandedR |= 1ull * ((R >> (32 - 4)) & 1) << (47 - 6);
  expandedR |= 1ull * ((R >> (32 - 5)) & 1) << (47 - 7);
  expandedR |= 1ull * ((R >> (32 - 6)) & 1) << (47 - 8);
  expandedR |= 1ull * ((R >> (32 - 7)) & 1) << (47 - 9);
  expandedR |= 1ull * ((R >> (32 - 8)) & 1) << (47 - 10);
  expandedR |= 1ull * ((R >> (32 - 9)) & 1) << (47 - 11);
  expandedR |= 1ull * ((R >> (32 - 8)) & 1) << (47 - 12);
  expandedR |= 1ull * ((R >> (32 - 9)) & 1) << (47 - 13);
  expandedR |= 1ull * ((R >> (32 - 10)) & 1) << (47 - 14);
  expandedR |= 1ull * ((R >> (32 - 11)) & 1) << (47 - 15);
  expandedR |= 1ull * ((R >> (32 - 12)) & 1) << (47 - 16);
  expandedR |= 1ull * ((R >> (32 - 13)) & 1) << (47 - 17);
  expandedR |= 1ull * ((R >> (32 - 12)) & 1) << (47 - 18);
  expandedR |= 1ull * ((R >> (32 - 13)) & 1) << (47 - 19);
  expandedR |= 1ull * ((R >> (32 - 14)) & 1) << (47 - 20);
  expandedR |= 1ull * ((R >> (32 - 15)) & 1) << (47 - 21);
  expandedR |= 1ull * ((R >> (32 - 16)) & 1) << (47 - 22);
  expandedR |= 1ull * ((R >> (32 - 17)) & 1) << (47 - 23);
  expandedR |= 1ull * ((R >> (32 - 16)) & 1) << (47 - 24);
  expandedR |= 1ull * ((R >> (32 - 17)) & 1) << (47 - 25);
  expandedR |= 1ull * ((R >> (32 - 18)) & 1) << (47 - 26);
  expandedR |= 1ull * ((R >> (32 - 19)) & 1) << (47 - 27);
  expandedR |= 1ull * ((R >> (32 - 20)) & 1) << (47 - 28);
  expandedR |= 1ull * ((R >> (32 - 21)) & 1) << (47 - 29);
  expandedR |= 1ull * ((R >> (32 - 20)) & 1) << (47 - 30);
  expandedR |= 1ull * ((R >> (32 - 21)) & 1) << (47 - 31);
  expandedR |= 1ull * ((R >> (32 - 22)) & 1) << (47 - 32);
  expandedR |= 1ull * ((R >> (32 - 23)) & 1) << (47 - 33);
  expandedR |= 1ull * ((R >> (32 - 24)) & 1) << (47 - 34);
  expandedR |= 1ull * ((R >> (32 - 25)) & 1) << (47 - 35);
  expandedR |= 1ull * ((R >> (32 - 24)) & 1) << (47 - 36);
  expandedR |= 1ull * ((R >> (32 - 25)) & 1) << (47 - 37);
  expandedR |= 1ull * ((R >> (32 - 26)) & 1) << (47 - 38);
  expandedR |= 1ull * ((R >> (32 - 27)) & 1) << (47 - 39);
  expandedR |= 1ull * ((R >> (32 - 28)) & 1) << (47 - 40);
  expandedR |= 1ull * ((R >> (32 - 29)) & 1) << (47 - 41);
  expandedR |= 1ull * ((R >> (32 - 28)) & 1) << (47 - 42);
  expandedR |= 1ull * ((R >> (32 - 29)) & 1) << (47 - 43);
  expandedR |= 1ull * ((R >> (32 - 30)) & 1) << (47 - 44);
  expandedR |= 1ull * ((R >> (32 - 31)) & 1) << (47 - 45);
  expandedR |= 1ull * ((R >> (32 - 32)) & 1) << (47 - 46);
  expandedR |= 1ull * ((R >> (32 - 1)) & 1) << (47 - 47);
  *expandedR_1 = expandedR & 0xFFFFFFFF;
  *expandedR_2 = expandedR >> 32;
  return;
}

// opcode: 4
/// echo genexpendR 1in, 2out
/// exec.p.f 0, t0, 0, a0, x0, 4
/// pick 1, t1, 4
void genexpendR_ex(uint32_t R, uint32_t *expandedR_1, uint32_t *expandedR_2) {
  asm volatile(".word 0b00001000000001010000001010001011;"
               ".word 0b00001000000000000001001101011011;"
               "sw t0, 0(%0);"
               "sw t1, 0(%1);"
               :
               : "r"(expandedR_1), "r"(expandedR_2)
               : "t0", "t1", "memory");
}

void genpermutedR(uint32_t tempR, uint32_t *ret) {
  uint32_t permutedR = 0;
  permutedR |= ((tempR >> (32 - 16)) & 1) << (31 - 0);
  permutedR |= ((tempR >> (32 - 7)) & 1) << (31 - 1);
  permutedR |= ((tempR >> (32 - 20)) & 1) << (31 - 2);
  permutedR |= ((tempR >> (32 - 21)) & 1) << (31 - 3);
  permutedR |= ((tempR >> (32 - 29)) & 1) << (31 - 4);
  permutedR |= ((tempR >> (32 - 12)) & 1) << (31 - 5);
  permutedR |= ((tempR >> (32 - 28)) & 1) << (31 - 6);
  permutedR |= ((tempR >> (32 - 17)) & 1) << (31 - 7);
  permutedR |= ((tempR >> (32 - 1)) & 1) << (31 - 8);
  permutedR |= ((tempR >> (32 - 15)) & 1) << (31 - 9);
  permutedR |= ((tempR >> (32 - 23)) & 1) << (31 - 10);
  permutedR |= ((tempR >> (32 - 26)) & 1) << (31 - 11);
  permutedR |= ((tempR >> (32 - 5)) & 1) << (31 - 12);
  permutedR |= ((tempR >> (32 - 18)) & 1) << (31 - 13);
  permutedR |= ((tempR >> (32 - 31)) & 1) << (31 - 14);
  permutedR |= ((tempR >> (32 - 10)) & 1) << (31 - 15);
  permutedR |= ((tempR >> (32 - 2)) & 1) << (31 - 16);
  permutedR |= ((tempR >> (32 - 8)) & 1) << (31 - 17);
  permutedR |= ((tempR >> (32 - 24)) & 1) << (31 - 18);
  permutedR |= ((tempR >> (32 - 14)) & 1) << (31 - 19);
  permutedR |= ((tempR >> (32 - 32)) & 1) << (31 - 20);
  permutedR |= ((tempR >> (32 - 27)) & 1) << (31 - 21);
  permutedR |= ((tempR >> (32 - 3)) & 1) << (31 - 22);
  permutedR |= ((tempR >> (32 - 9)) & 1) << (31 - 23);
  permutedR |= ((tempR >> (32 - 19)) & 1) << (31 - 24);
  permutedR |= ((tempR >> (32 - 13)) & 1) << (31 - 25);
  permutedR |= ((tempR >> (32 - 30)) & 1) << (31 - 26);
  permutedR |= ((tempR >> (32 - 6)) & 1) << (31 - 27);
  permutedR |= ((tempR >> (32 - 22)) & 1) << (31 - 28);
  permutedR |= ((tempR >> (32 - 11)) & 1) << (31 - 29);
  permutedR |= ((tempR >> (32 - 4)) & 1) << (31 - 30);
  permutedR |= ((tempR >> (32 - 25)) & 1) << (31 - 31);
  *ret = permutedR;
  return;
}

// opcode: 5
/// echo genpermutedR 1in, 1out
/// exec.p.f 0, t0, 0, a0, x0, 5
void genpermutedR_ex(uint32_t tempR, uint32_t *ret) {
  asm volatile(".word 0b00001010000001010000001010001011;"
               "sw t0, 0(%0);"
               :
               : "r"(ret)
               : "t0", "memory");
}

void genrowcol(uint32_t expandedR_1, uint32_t expandedR_2, uint32_t *row_ret,
               uint32_t *col_ret) {
  uint64_t expandedR = expandedR_1 | ((uint64_t)expandedR_2 << 32);
  uint32_t r, c;
  uint32_t row = 0;
  uint32_t col = 0;
  r = ((expandedR >> (47 - 0 * 6)) & 1) * 2 +
      ((expandedR >> (47 - 0 * 6 - 5)) & 1);
  c = (expandedR >> (47 - 0 * 6 - 1)) & 0xF;
  row |= r << (4 * 0);
  col |= c << (4 * 0);
  r = ((expandedR >> (47 - 1 * 6)) & 1) * 2 +
      ((expandedR >> (47 - 1 * 6 - 5)) & 1);
  c = (expandedR >> (47 - 1 * 6 - 1)) & 0xF;
  row |= r << (4 * 1);
  col |= c << (4 * 1);
  r = ((expandedR >> (47 - 2 * 6)) & 1) * 2 +
      ((expandedR >> (47 - 2 * 6 - 5)) & 1);
  c = (expandedR >> (47 - 2 * 6 - 1)) & 0xF;
  row |= r << (4 * 2);
  col |= c << (4 * 2);
  r = ((expandedR >> (47 - 3 * 6)) & 1) * 2 +
      ((expandedR >> (47 - 3 * 6 - 5)) & 1);
  c = (expandedR >> (47 - 3 * 6 - 1)) & 0xF;
  row |= r << (4 * 3);
  col |= c << (4 * 3);
  r = ((expandedR >> (47 - 4 * 6)) & 1) * 2 +
      ((expandedR >> (47 - 4 * 6 - 5)) & 1);
  c = (expandedR >> (47 - 4 * 6 - 1)) & 0xF;
  row |= r << (4 * 4);
  col |= c << (4 * 4);
  r = ((expandedR >> (47 - 5 * 6)) & 1) * 2 +
      ((expandedR >> (47 - 5 * 6 - 5)) & 1);
  c = (expandedR >> (47 - 5 * 6 - 1)) & 0xF;
  row |= r << (4 * 5);
  col |= c << (4 * 5);
  r = ((expandedR >> (47 - 6 * 6)) & 1) * 2 +
      ((expandedR >> (47 - 6 * 6 - 5)) & 1);
  c = (expandedR >> (47 - 6 * 6 - 1)) & 0xF;
  row |= r << (4 * 6);
  col |= c << (4 * 6);
  r = ((expandedR >> (47 - 7 * 6)) & 1) * 2 +
      ((expandedR >> (47 - 7 * 6 - 5)) & 1);
  c = (expandedR >> (47 - 7 * 6 - 1)) & 0xF;
  row |= r << (4 * 7);
  col |= c << (4 * 7);

  *row_ret = row;
  *col_ret = col;
  return;
}

// opcode: 6
/// echo genrowcol 2in, 2out
/// exec.p.f 0, t0, 0, a0, a1, 6
/// pick 1, t1, 6
void genrowcol_ex(uint32_t expandedR_1, uint32_t expandedR_2, uint32_t *row_ret,
                  uint32_t *col_ret) {
  asm volatile(".word 0b00001100101101010000001010001011;"
               ".word 0b00001100000000000001001101011011;"
               "sw t0, 0(%0);"
               "sw t1, 0(%1);"
               :
               : "r"(row_ret), "r"(col_ret)
               : "t0", "t1", "memory");
}

void genresult(uint32_t L, uint32_t R, uint32_t *result_1, uint32_t *result_2) {
  uint64_t combined = ((uint64_t)R << 32) | L;
  uint64_t result = 0;
  result |= ((combined >> (64 - 58)) & 1) << (63 - 0);
  result |= ((combined >> (64 - 50)) & 1) << (63 - 1);
  result |= ((combined >> (64 - 42)) & 1) << (63 - 2);
  result |= ((combined >> (64 - 34)) & 1) << (63 - 3);
  result |= ((combined >> (64 - 26)) & 1) << (63 - 4);
  result |= ((combined >> (64 - 18)) & 1) << (63 - 5);
  result |= ((combined >> (64 - 10)) & 1) << (63 - 6);
  result |= ((combined >> (64 - 2)) & 1) << (63 - 7);
  result |= ((combined >> (64 - 60)) & 1) << (63 - 8);
  result |= ((combined >> (64 - 52)) & 1) << (63 - 9);
  result |= ((combined >> (64 - 44)) & 1) << (63 - 10);
  result |= ((combined >> (64 - 36)) & 1) << (63 - 11);
  result |= ((combined >> (64 - 28)) & 1) << (63 - 12);
  result |= ((combined >> (64 - 20)) & 1) << (63 - 13);
  result |= ((combined >> (64 - 12)) & 1) << (63 - 14);
  result |= ((combined >> (64 - 4)) & 1) << (63 - 15);
  result |= ((combined >> (64 - 62)) & 1) << (63 - 16);
  result |= ((combined >> (64 - 54)) & 1) << (63 - 17);
  result |= ((combined >> (64 - 46)) & 1) << (63 - 18);
  result |= ((combined >> (64 - 38)) & 1) << (63 - 19);
  result |= ((combined >> (64 - 30)) & 1) << (63 - 20);
  result |= ((combined >> (64 - 22)) & 1) << (63 - 21);
  result |= ((combined >> (64 - 14)) & 1) << (63 - 22);
  result |= ((combined >> (64 - 6)) & 1) << (63 - 23);
  result |= ((combined >> (64 - 64)) & 1) << (63 - 24);
  result |= ((combined >> (64 - 56)) & 1) << (63 - 25);
  result |= ((combined >> (64 - 48)) & 1) << (63 - 26);
  result |= ((combined >> (64 - 40)) & 1) << (63 - 27);
  result |= ((combined >> (64 - 32)) & 1) << (63 - 28);
  result |= ((combined >> (64 - 24)) & 1) << (63 - 29);
  result |= ((combined >> (64 - 16)) & 1) << (63 - 30);
  result |= ((combined >> (64 - 8)) & 1) << (63 - 31);
  result |= ((combined >> (64 - 57)) & 1) << (63 - 32);
  result |= ((combined >> (64 - 49)) & 1) << (63 - 33);
  result |= ((combined >> (64 - 41)) & 1) << (63 - 34);
  result |= ((combined >> (64 - 33)) & 1) << (63 - 35);
  result |= ((combined >> (64 - 25)) & 1) << (63 - 36);
  result |= ((combined >> (64 - 17)) & 1) << (63 - 37);
  result |= ((combined >> (64 - 9)) & 1) << (63 - 38);
  result |= ((combined >> (64 - 1)) & 1) << (63 - 39);
  result |= ((combined >> (64 - 59)) & 1) << (63 - 40);
  result |= ((combined >> (64 - 51)) & 1) << (63 - 41);
  result |= ((combined >> (64 - 43)) & 1) << (63 - 42);
  result |= ((combined >> (64 - 35)) & 1) << (63 - 43);
  result |= ((combined >> (64 - 27)) & 1) << (63 - 44);
  result |= ((combined >> (64 - 19)) & 1) << (63 - 45);
  result |= ((combined >> (64 - 11)) & 1) << (63 - 46);
  result |= ((combined >> (64 - 3)) & 1) << (63 - 47);
  result |= ((combined >> (64 - 61)) & 1) << (63 - 48);
  result |= ((combined >> (64 - 53)) & 1) << (63 - 49);
  result |= ((combined >> (64 - 45)) & 1) << (63 - 50);
  result |= ((combined >> (64 - 37)) & 1) << (63 - 51);
  result |= ((combined >> (64 - 29)) & 1) << (63 - 52);
  result |= ((combined >> (64 - 21)) & 1) << (63 - 53);
  result |= ((combined >> (64 - 13)) & 1) << (63 - 54);
  result |= ((combined >> (64 - 5)) & 1) << (63 - 55);
  result |= ((combined >> (64 - 63)) & 1) << (63 - 56);
  result |= ((combined >> (64 - 55)) & 1) << (63 - 57);
  result |= ((combined >> (64 - 47)) & 1) << (63 - 58);
  result |= ((combined >> (64 - 39)) & 1) << (63 - 59);
  result |= ((combined >> (64 - 31)) & 1) << (63 - 60);
  result |= ((combined >> (64 - 23)) & 1) << (63 - 61);
  result |= ((combined >> (64 - 15)) & 1) << (63 - 62);
  result |= ((combined >> (64 - 7)) & 1) << (63 - 63);
  *result_1 = result & 0xFFFFFFFF;
  *result_2 = result >> 32;
  return;
}

// opcode: 7
/// echo genresult 2in, 2out
/// exec.p.f 0, t0, 0, a0, a1, 7
/// pick 1, t1, 7
void genresult_ex(uint32_t L, uint32_t R, uint32_t *result_1,
                  uint32_t *result_2) {
  asm volatile(".word 0b00001110101101010000001010001011;"
               ".word 0b00001110000000000001001101011011;"
               "sw t0, 0(%0);"
               "sw t1, 0(%1);"
               :
               : "r"(result_1), "r"(result_2)
               : "t0", "t1", "memory");
}

void group1(unsigned char opcode, uint32_t in1, uint32_t in2, uint32_t *out1,
            uint32_t *out2) {
  if (opcode == 0) {
#ifdef USE_EXT_INST
    groundkeyop_ex(in1, in2, out1, out2);
#else
    groundkeyop(in1, in2, out1, out2);
#endif
  } else if (opcode == 1) {
#ifdef USE_EXT_INST
    genrotate_ex(in1, out1);
#else
    genrotate(in1, out1);
#endif
  } else if (opcode == 2) {
#ifdef USE_EXT_INST
    genkey56_ex(in1, in2, out1, out2);
#else
    genkey56(in1, in2, out1, out2);
#endif
  } else if (opcode == 3) {
#ifdef USE_EXT_INST
    genstate_ex(in1, in2, out1, out2);
#else
    genstate(in1, in2, out1, out2);
#endif
  } else if (opcode == 4) {
#ifdef USE_EXT_INST
    genexpendR_ex(in1, out1, out2);
#else
    genexpendR(in1, out1, out2);
#endif
  } else if (opcode == 5) {
#ifdef USE_EXT_INST
    genpermutedR_ex(in1, out1);
#else
    genpermutedR(in1, out1);
#endif
  } else if (opcode == 6) {
#ifdef USE_EXT_INST
    genrowcol_ex(in1, in2, out1, out2);
#else
    genrowcol(in1, in2, out1, out2);
#endif
  } else if (opcode == 7) {
#ifdef USE_EXT_INST
    genresult_ex(in1, in2, out1, out2);
#else
    genresult(in1, in2, out1, out2);
#endif
  }
}

void group1_ex(unsigned char opcode, uint32_t in1, uint32_t in2, uint32_t *out1,
               uint32_t *out2) {
  if (opcode == 0) {
    groundkeyop_ex(in1, in2, out1, out2);
  } else if (opcode == 1) {
    genrotate_ex(in1, out1);
  } else if (opcode == 2) {
    genkey56_ex(in1, in2, out1, out2);
  } else if (opcode == 3) {
    genstate_ex(in1, in2, out1, out2);
  } else if (opcode == 4) {
    genexpendR_ex(in1, out1, out2);
  } else if (opcode == 5) {
    genpermutedR_ex(in1, out1);
  } else if (opcode == 6) {
    genrowcol_ex(in1, in2, out1, out2);
  } else if (opcode == 7) {
    genresult_ex(in1, in2, out1, out2);
  }
}

#define NUM_ROUNDS 16

// 初始置换表 (IP)
const int IP[64] = {58, 50, 42, 34, 26, 18, 10, 2,  60, 52, 44, 36, 28,
                    20, 12, 4,  62, 54, 46, 38, 30, 22, 14, 6,  64, 56,
                    48, 40, 32, 24, 16, 8,  57, 49, 41, 33, 25, 17, 9,
                    1,  59, 51, 43, 35, 27, 19, 11, 3,  61, 53, 45, 37,
                    29, 21, 13, 5,  63, 55, 47, 39, 31, 23, 15, 7};

// 置换选择1 (PC-1)
const int PC1[56] = {57, 49, 41, 33, 25, 17, 9,  1,  58, 50, 42, 34, 26, 18,
                     10, 2,  59, 51, 43, 35, 27, 19, 11, 3,  60, 52, 44, 36,
                     28, 20, 12, 4,  61, 53, 45, 37, 29, 21, 13, 5,  62, 54,
                     46, 38, 30, 22, 14, 6,  63, 55, 47, 39, 31, 23, 15, 7};

// 置换选择2 (PC-2)
const int PC2[48] = {14, 17, 11, 24, 1,  5,  3,  28, 15, 6,  21, 10,
                     23, 19, 12, 4,  26, 8,  16, 7,  27, 20, 13, 2,
                     41, 52, 31, 37, 47, 55, 30, 40, 51, 45, 33, 48,
                     44, 49, 39, 56, 34, 53, 46, 42, 50, 36, 29, 32};

// 扩展置换E表
const int E[48] = {32, 1,  2,  3,  4,  5,  4,  5,  6,  7,  8,  9,
                   8,  9,  10, 11, 12, 13, 12, 13, 14, 15, 16, 17,
                   16, 17, 18, 19, 20, 21, 20, 21, 22, 23, 24, 25,
                   24, 25, 26, 27, 28, 29, 28, 29, 30, 31, 32, 1};

// S-Box表
const int S[8][4][16] = {
    {{14, 4, 13, 1, 2, 15, 11, 8, 3, 10, 6, 12, 5, 9, 0, 7},
     {0, 15, 7, 4, 14, 2, 13, 1, 10, 6, 12, 11, 9, 5, 3, 8},
     {4, 1, 14, 8, 13, 6, 2, 11, 15, 12, 9, 7, 3, 10, 5, 0},
     {15, 12, 8, 2, 4, 9, 1, 7, 5, 11, 3, 14, 10, 0, 6, 13}},
    {{15, 1, 8, 14, 6, 11, 3, 4, 9, 7, 2, 13, 12, 0, 5, 10},
     {3, 13, 4, 7, 15, 2, 8, 14, 12, 0, 1, 10, 6, 9, 11, 5},
     {0, 14, 7, 11, 10, 4, 13, 1, 5, 8, 12, 6, 9, 3, 2, 15},
     {13, 8, 10, 1, 3, 15, 4, 2, 11, 6, 7, 9, 5, 0, 14, 12}},
    {{10, 0, 9, 14, 6, 3, 15, 5, 1, 13, 12, 7, 11, 4, 2, 8},
     {13, 7, 0, 9, 3, 4, 6, 10, 2, 8, 5, 14, 15, 1, 11, 12},
     {13, 6, 4, 9, 8, 15, 3, 0, 11, 1, 2, 12, 5, 10, 14, 7},
     {1, 10, 13, 0, 6, 9, 8, 7, 4, 15, 14, 3, 11, 5, 2, 12}},
    {{7, 13, 14, 3, 0, 6, 9, 10, 1, 2, 8, 5, 11, 12, 15, 4},
     {13, 8, 11, 5, 6, 15, 0, 3, 10, 14, 9, 12, 2, 7, 1, 4},
     {2, 12, 9, 6, 10, 15, 14, 5, 1, 13, 7, 11, 4, 3, 8, 0},
     {14, 11, 10, 7, 13, 1, 4, 9, 8, 15, 3, 5, 0, 6, 12, 2}},
    {{9, 14, 15, 5, 1, 3, 8, 13, 12, 2, 11, 10, 6, 0, 7, 4},
     {2, 12, 6, 13, 7, 14, 0, 9, 10, 11, 1, 4, 15, 8, 5, 3},
     {15, 9, 14, 8, 1, 13, 3, 10, 5, 11, 7, 12, 4, 2, 0, 6},
     {12, 15, 10, 1, 9, 14, 11, 5, 8, 13, 6, 0, 4, 3, 7, 2}},
    {{12, 9, 15, 5, 1, 10, 0, 14, 7, 11, 6, 3, 4, 13, 8, 2},
     {14, 3, 13, 10, 7, 15, 12, 1, 5, 2, 6, 9, 8, 0, 4, 11},
     {1, 15, 14, 13, 5, 11, 10, 7, 12, 8, 0, 3, 9, 6, 4, 2},
     {12, 10, 9, 6, 5, 13, 8, 3, 0, 14, 1, 7, 11, 4, 15, 2}},
    {{9, 3, 6, 4, 8, 15, 14, 1, 7, 13, 11, 0, 2, 5, 10, 12},
     {3, 7, 10, 15, 5, 4, 9, 0, 6, 8, 12, 1, 2, 14, 11, 13},
     {12, 7, 11, 15, 10, 1, 0, 8, 3, 13, 9, 5, 6, 2, 14, 4},
     {1, 3, 6, 8, 15, 5, 7, 14, 10, 11, 2, 9, 4, 12, 13, 0}},
    {{8, 15, 5, 3, 1, 9, 12, 11, 13, 10, 7, 6, 14, 4, 2, 0},
     {12, 1, 13, 8, 5, 3, 15, 4, 7, 2, 9, 6, 10, 14, 0, 11},
     {15, 12, 11, 9, 6, 0, 14, 1, 8, 13, 5, 3, 7, 4, 2, 10},
     {7, 9, 2, 6, 12, 10, 5, 11, 1, 14, 15, 8, 13, 3, 0, 4}}};

// P4置换表
const int P4[32] = {16, 7, 20, 21, 29, 12, 28, 17, 1,  15, 23,
                    26, 5, 18, 31, 10, 2,  8,  24, 14, 32, 27,
                    3,  9, 19, 13, 30, 6,  22, 11, 4,  25};

// 左循环移位的帮助函数
uint32_t rotate_left(uint32_t val, int shifts, int size) {
  return ((val << shifts) | (val >> (size - shifts))) & ((1 << size) - 1);
}

// 生成16轮的子密钥
void generate_round_keys(uint64_t key, uint64_t roundKeys[NUM_ROUNDS]) {
  uint64_t key56 = 0;
  uint32_t C, D;

  // // 从PC1中提取56位密钥
  // for (int i = 0; i < 56; i++) {
  //     key56 |= ((key >> (64 - PC1[i])) & 1) << (55 - i);
  // }
  uint32_t r1, r2;
  // genkey56(key&0xFFFFFFFF, key>>32, r1, r2);
  group1(2, key & 0xFFFFFFFF, key >> 32, &r1, &r2);
  key56 = ((uint64_t)r2 << 32) | r1;

  // 分为C和D部分
  C = (key56 >> 28) & 0xFFFFFFF;
  D = key56 & 0xFFFFFFF;

  // uint64_t ans;
  // groundkeyop(C, D, ans);
  // genkeyop(key, ans);

  // 生成16轮的密钥
  for (int round = 0; round < NUM_ROUNDS; round++) {
    // C = rotate_left(C, 1, 28);
    // D = rotate_left(D, 1, 28);
    uint32_t nC, nD;
    // genrotate(C, nC);
    // genrotate(D, nD);
    group1(1, C, 0, &nC, 0);
    group1(1, D, 0, &nD, 0);
    C = nC;
    D = nD;

    // uint64_t combined = ((uint64_t)C << 28) | D;
    // roundKeys[round] = 0;

    // for (int i = 0; i < 48; i++) {
    //     roundKeys[round] |= ((combined >> (56 - PC2[i])) & 1) << (47 - i);
    // }
    uint32_t r1, r2;
    // groundkeyop(C, D, roundKeys[round]);
    // groundkeyop(C, D, r1, r2);
    group1(0, C, D, &r1, &r2);
    roundKeys[round] = ((uint64_t)r2 << 32) | r1;
    // roundKeys[round] = ans;
  }
}

// 主加密函数
uint64_t encrypt(uint64_t plaintext, uint64_t roundKeys[NUM_ROUNDS]) {
  uint64_t state = 0;
  uint32_t L, R;

  // // 初始置换
  // for (int i = 0; i < 64; i++) {
  //     state |= ((plaintext >> (64 - IP[i])) & 1) << (63 - i);
  // }
  uint32_t r1, r2;
  // genstate(plaintext & 0xFFFFFFFF, plaintext >> 32, r1, r2);
  group1(3, (uint32_t)(plaintext & 0xFFFFFFFF), (uint32_t)(plaintext >> 32),
         &r1, &r2);
  state = ((uint64_t)r2 << 32) | r1;

  L = (state >> 32) & 0xFFFFFFFF;
  R = state & 0xFFFFFFFF;

  // 16轮加密
  for (int round = 0; round < NUM_ROUNDS; round++) {
    uint64_t expandedR = 0;

    // 扩展R0 -> 48位
    // for (int i = 0; i < 48; i++) {
    //     expandedR |= ((R >> (32 - E[i])) & 1) << (47 - i);
    // }
    uint32_t r11, r21;
    // genexpendR(R, r1, r2);
    group1(4, R, 0, &r11, &r21);
    expandedR = ((uint64_t)r21 << 32) | r11;
    // genexpendR(R, expandedR);

    // 与轮密钥异或
    expandedR ^= roundKeys[round];

    // S盒变换并P4置换
    uint32_t tempR = 0;
    uint32_t trow, tcol;
    // genrowcol(expandedR & 0xFFFFFFFF, expandedR >> 32, trow, tcol);
    group1(6, expandedR & 0xFFFFFFFF, expandedR >> 32, &trow, &tcol);
    for (int i = 0; i < 8; i++) {
      // int row = ((expandedR >> (47 - i * 6)) & 1) * 2 + ((expandedR >> (47 -
      // i * 6 - 5)) & 1); int col = (expandedR >> (47 - i * 6 - 1)) & 0xF;
      int row = (trow >> (i * 4)) & 0xF;
      int col = (tcol >> (i * 4)) & 0xF;
      tempR |= S[i][row][col] << (28 - i * 4);
    }

    uint32_t permutedR = 0;
    // for (int i = 0; i < 32; i++) {
    //     permutedR |= ((tempR >> (32 - P4[i])) & 1) << (31 - i);
    // }
    // genpermutedR(tempR, permutedR);
    group1(5, tempR, 0, &permutedR, 0);

    uint32_t newL = R;
    R = L ^ permutedR;
    L = newL;
  }

  // 最后交换并进行最终置换
  uint64_t combined = ((uint64_t)R << 32) | L;
  uint64_t result = 0;
  r1 = 0;
  r2 = 0;
  // genresult(L, R, r1, r2);
  group1(7, L, R, &r1, &r2);
  result = ((uint64_t)r2 << 32) | r1;
  // genresult(L, R, result);

  // for (int i = 0; i < 64; i++) {
  //     result |= ((combined >> (64 - IP[i])) & 1) << (63 - i);
  // }

  return result;
}

// 将字符串转换为64位的二进制表示
uint64_t string_to_uint64(const char *str) {
  uint64_t result = 0;
  for (int i = 0; i < 8; i++) {
    result = (result << 8) | (unsigned char)str[i];
  }
  return result;
}

// 测试代码
int main() {
  const char *plaintext = "12345678";   // 待加密的文本 (8字节)
  const char *key = "133457799BBCDFF1"; // 64位密钥 (8字节)

  // 转换明文和密钥
  uint64_t plainTextBits = string_to_uint64(plaintext);
  uint64_t keyBits = string_to_uint64(key);

  // 生成轮密钥
  uint64_t ciphertext;
  for (int i = 0; i < 40; ++i) {
    uint64_t roundKeys[NUM_ROUNDS];
    generate_round_keys(keyBits, roundKeys);

    // 加密
    ciphertext = encrypt(plainTextBits, roundKeys);
  };
  uint64_t gold = 0x8D3608068439E02B;

  return gold == ciphertext
             ? 0
             : (((ciphertext & 0xff) == 0) ? 0xff : (ciphertext & 0xff));

  // 输出加密结果
  // printf("Encrypted ciphertext: %016llX\n", ciphertext);
}
