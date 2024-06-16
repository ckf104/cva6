void nv2cag(unsigned long long *in1, unsigned long long *in2,
            unsigned long long *out) {
  asm volatile("ld t0, 0(%0);"
               "ld t1, 8(%0);"
               "ld t2, 0(%1);"
               "ld t3, 8(%1);"
               ".word 0b00000000000000101001000000001011;"
               ".word 0b00000000000100110001000000001011;"
               ".word 0b00000000000000111001000010001011;"
               ".word 0b00000000000111100001000010001011;"
               ".word 0b00000100000100000000000100001011;"
               ".word 0b00000000000000010000001010001011;"
               ".word 0b00000000000100010000001100001011;"
               ".word 0b00000000001000010000001110001011;"
               "sd t0, 0(%2);"
               "sd t1, 8(%2);"
               "sd t2, 16(%2);"
               :
               : "r"(in1), "r"(in2), "r"(out)
               : "t0", "t1", "t2", "t3", "memory");
}
void cag2rgb(unsigned long long *in, unsigned long long *out) {
  asm volatile("ld t0, 0(%0);"
               "ld t1, 8(%0);"
               "ld t2, 16(%0);"
               ".word 0b00000000000000101001000000001011;"
               ".word 0b00000000000100110001000000001011;"
               ".word 0b00000000001000111001000000001011;"
               ".word 0b00000110000000000000000100001011;"
               ".word 0b00000000000000010000001010001011;"
               ".word 0b00000000000100010000001100001011;"
               ".word 0b00000000001000010000001110001011;"
               "sd t0, 0(%1);"
               "sd t1, 8(%1);"
               "sd t2, 16(%1);"
               :
               : "r"(in), "r"(out)
               : "t0", "t1", "t2", "memory");
}

int main() {
  unsigned long long y1[2] = {0x0011223344556677, 0x8899AABBCCDDEEFF};
  unsigned long long y2[2] = {0x0022446688AACCEE, 0x1133557799BBDDFF};
  unsigned long long yuv[3] = {0x663388aa55ccee77, 0xddddffff00221144,
                               0x1133995577bb99bb};
  unsigned long long yuv_imm[3] = {0, 0, 0};
  unsigned long long rgb[3] = {0x3b21623c51a83e81, 0xf1ffd3ff003a001d,
                               0x7dcf91c3d0c1ffd1};
  unsigned long long rgb_imm[3] = {0, 0, 0};

  nv2cag(y1, y2, yuv_imm);
  cag2rgb(yuv_imm, rgb_imm);
  for (int i = 0; i < 3; i++) {
    if (yuv[i] != yuv_imm[i]) {
      return i + 1;
    }
    if (rgb[i] != rgb_imm[i]) {
      return i + 4;
    }
  }

  return 0;
}