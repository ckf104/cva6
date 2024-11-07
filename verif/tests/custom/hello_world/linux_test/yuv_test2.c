void RGB2YUV(unsigned char Rin, unsigned char Gin, unsigned char Bin,
             unsigned char *Yout, unsigned char *Uout, unsigned char *Vout) {
  int R = (int)Rin;
  int G = (int)Gin;
  int B = (int)Bin;
  int Y = (77 * R + 150 * G + 29 * B) >> 8;
  int U = ((-44 * R - 87 * G + 131 * B) >> 8) + 128;
  int V = ((131 * R - 110 * G - 21 * B) >> 8) + 128;
  *Yout = Y > 0 ? (Y < 256 ? Y : 255) : 0;
  *Uout = U > 0 ? (U < 256 ? U : 255) : 0;
  *Vout = V > 0 ? (V < 256 ? V : 255) : 0;
  return;
}

// format: instr, rdIdx, rd, rsIdx, rs1, rs2, opcode
/// echo rgb2yuv 3in 3out
/// fill, 0, a0, a1, 0
/// exec.p.f, 0, t0, 2, a2, x0, 0
/// pick, 1, t1, 0
/// pick, 2, t2, 0
// a0, a1, a2, a3, a4, a5
void RGB2YUV_EX(unsigned char Rin, unsigned char Gin, unsigned char Bin,
                unsigned char *Yout, unsigned char *Uout, unsigned char *Vout) {
  asm volatile(".word 0b00000000101101010000000001111011;"
               ".word 0b00100000000001100000001010001011;"
               ".word 0b00000000000000000001001101011011;"
               ".word 0b00000000000000000010001111011011;"
               "sb t0, 0(%0);"
               "sb t1, 0(%1);"
               "sb t2, 0(%2);"
               :
               : "r"(Yout), "r"(Uout), "r"(Vout)
               : "t0", "t1", "t2", "memory");
}

void RGB2Y(unsigned char Rin, unsigned char Gin, unsigned char Bin,
           unsigned char *Yout) {
  int R = (int)Rin;
  int G = (int)Gin;
  int B = (int)Bin;
  int Y = (77 * R + 150 * G + 29 * B) >> 8;
  *Yout = Y > 0 ? (Y < 256 ? Y : 255) : 0;
  return;
}

/// echo rgb2y 3in 1out
/// fill, 0, a0, a1, 1
/// exec.p.f, 0, t0, 2, a2, x0, 1
// a0, a1, a2, a3
void RGB2Y_EX(unsigned char Rin, unsigned char Gin, unsigned char Bin,
              unsigned char *Yout) {
  asm volatile(".word 0b00000010101101010000000001111011;"
               ".word 0b00100010000001100000001010001011;"
               "sb t0, 0(%0);"
               :
               : "r"(Yout)
               : "t0", "memory");
}

void RGB2U(unsigned char Rin, unsigned char Gin, unsigned char Bin,
           unsigned char *Uout) {
  int R = (int)Rin;
  int G = (int)Gin;
  int B = (int)Bin;
  int U = ((-44 * R - 87 * G + 131 * B) >> 8) + 128;
  *Uout = U > 0 ? (U < 256 ? U : 255) : 0;
  return;
}

/// echo rgb2u 3in 1out
/// fill, 0, a0, a1, 2
/// exec.p.f, 0, t0, 2, a2, x0, 2
// a0, a1, a2, a3
void RGB2U_EX(unsigned char Rin, unsigned char Gin, unsigned char Bin,
              unsigned char *Uout) {
  asm volatile(".word 0b00000100101101010000000001111011;"
               ".word 0b00100100000001100000001010001011;"
               "sb t0, 0(%0);"
               :
               : "r"(Uout)
               : "t0", "memory");
}

void RGB2V(unsigned char Rin, unsigned char Gin, unsigned char Bin,
           unsigned char *Vout) {
  int R = (int)Rin;
  int G = (int)Gin;
  int B = (int)Bin;
  int V = ((131 * R - 110 * G - 21 * B) >> 8) + 128;
  *Vout = V > 0 ? (V < 256 ? V : 255) : 0;
  return;
}

/// echo rgb2v 3in 1out
/// fill, 0, a0, a1, 3
/// exec.p.f, 0, t0, 2, a2, x0, 3
// a0, a1, a2, a3
/// echo test
/// fill, 2 ,a0, a1, 1
void RGB2V_EX(unsigned char Rin, unsigned char Gin, unsigned char Bin,
              unsigned char *Vout) {
  asm volatile(".word 0b00000110101101010000000001111011;"
               ".word 0b00100110000001100000001010001011;"
               "sb t0, 0(%0);"
               :
               : "r"(Vout)
               : "t0", "memory");
}

void group0(unsigned char opcode, unsigned char in1, unsigned char in2,
            unsigned char in3, unsigned char *out1, unsigned char *out2,
            unsigned char *out3) {
  if (opcode == 0) {
    RGB2YUV(in1, in2, in3, out1, out2, out3);
  }
  return;
}

void group1(unsigned char opcode, unsigned char in1, unsigned char in2,
            unsigned char in3, unsigned char *out1) {
  if (opcode == 1) {
    RGB2Y_EX(in1, in2, in3, out1);
  } else if (opcode == 2) {
    RGB2U_EX(in1, in2, in3, out1);
  } else if (opcode == 3) {
    RGB2V_EX(in1, in2, in3, out1);
  }
  return;
}

int main() {
  unsigned char testRGB[][3] = {
      {255, 255, 255}, {255, 0, 0},   {0, 255, 0},   {0, 0, 255},
      {255, 255, 0},   {0, 255, 255}, {255, 0, 255},
  };
  unsigned char testYUV[][3] = {
      {255, 128, 128}, {76, 84, 255}, {149, 41, 18},   {28, 255, 107},
      {226, 0, 148},   {178, 171, 0}, {105, 214, 237},
  };

  int err = 0;

  for (int i = 0; i < 7; ++i) {
    unsigned char YY, UU, VV;

    //		RGB2YUV(testRGB[i][0], testRGB[i][1], testRGB[i][2], YY, UU,
    // VV);
    group0(0, testRGB[i][0], testRGB[i][1], testRGB[i][2], &YY, &UU, &VV);
    if (YY != testYUV[i][0]) {
      err = i * 0x1000;
      break;
    } else if (UU != testYUV[i][1]) {
      err = i * 0x1000 + 1;
      break;
    } else if (VV != testYUV[i][2]) {
      err = i * 0x1000 + 2;
      break;
    }

    group1(1, testRGB[i][0], testRGB[i][1], testRGB[i][2], &YY);
    if (YY != testYUV[i][0]) {
      err = i * 0x1000 + 3;
      break;
    }
    group1(2, testRGB[i][0], testRGB[i][1], testRGB[i][2], &UU);
    if (UU != testYUV[i][1]) {
      err = i * 0x1000 + 4;
      break;
    }
    group1(3, testRGB[i][0], testRGB[i][1], testRGB[i][2], &VV);
    if (VV != testYUV[i][2]) {
      err = i * 0x1000 + 5;
      break;
    }
  }

  return err;
}