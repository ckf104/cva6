#define ROMBase (0)
#define LOCALRAMBase (0x10000000) // 8kb
#define CTRLBase (0x20000000)
#define EXTDDRBase (0x38000000)

volatile const unsigned long long *src_width =
    (unsigned long long *)(CTRLBase + 0);
volatile const unsigned long long *src_height =
    (unsigned long long *)(CTRLBase + 8);
volatile const unsigned long long *src_offset_addr =
    (unsigned long long *)(CTRLBase + 16);
volatile const unsigned long long *src_image_size =
    (unsigned long long *)(CTRLBase + 24);
volatile const unsigned long long *dst_width =
    (unsigned long long *)(CTRLBase + 32);
volatile const unsigned long long *dst_height =
    (unsigned long long *)(CTRLBase + 40);
volatile const unsigned long long *dst_offset_addr =
    (unsigned long long *)(CTRLBase + 48);
volatile const unsigned long long *dst_image_size =
    (unsigned long long *)(CTRLBase + 56);
volatile const unsigned long long *start =
    (unsigned long long *)(CTRLBase + 64);

volatile unsigned long long *idle = (unsigned long long *)(CTRLBase + 72);
volatile unsigned long long *exit_ = (unsigned long long *)(CTRLBase + 80);

void expHandler() {
  asm volatile("csrr t0, mcause;"  // Read mcause into t0
               "addi t0, t0, 0x2;" // Add 0x2 to t0
               "sw t0, 0(%0);"     // Write t0 to exit_
               :                   // No output operands
               : "r"(exit_)        // Input operand
               : "t0"              // Clobber list
  );
  while (1)
    ;
}

// Basic test
/*void main_logic_test0() {
  volatile int a = 1;
  volatile int b = 2;
  volatile int c = a + b;
  if (c == 3) {
    *exit_ = 1;
  } else {
    *exit_ = 200;
  }
}*/

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

// custom inst
/*void main_logic_test1() {
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
      *exit_ = (i + 1) * 10 + 1;
      return;
    }
    if (rgb[i] != rgb_imm[i]) {
      *exit_ = (i + 1) * 10 + 2;
      return;
    }
  }
  *exit_ = 1;
}*/

typedef unsigned int uint32;
void pure_func(unsigned int src_width, unsigned int src_height,
               unsigned int src_size, unsigned char *src_ptr,
               unsigned int dst_width, unsigned int dst_height,
               unsigned int dst_size, unsigned char *dst_ptr) {
  // assert(src_width == 1024);
  // assert(src_height == 768);
  // assert(src_size == src_width * src_height * 3 / 2);
  // assert (dst_width*2 == src_width);
  // assert (dst_height*2 == src_height);
  // assert (dst_size == dst_width * dst_height * 3);

  unsigned int UVoffset_base = 1 * (src_width) * (src_height);
  for (uint32 dh = 0; dh < dst_height; ++dh) {
    for (uint32 dw = 0; dw < dst_width; dw += 8) {
      unsigned int Y_offset = (dh * 2) * (src_width) + (dw * 2);
      unsigned int UV_offset = UVoffset_base + dh * (src_width) + (dw * 2);
      unsigned int RGB_offset = (dh * (dst_width) + dw) * 3;

      unsigned long long *Yin = (unsigned long long *)(src_ptr + Y_offset);
      unsigned long long *UVin = (unsigned long long *)(src_ptr + UV_offset);
      unsigned long long *RGBin = (unsigned long long *)(dst_ptr + RGB_offset);

      unsigned long long CAGin[3]; // Here can use RGBin too. Just need 3 width
                                   // unsigned long long.

      nv2cag(Yin, UVin, CAGin);
      cag2rgb(CAGin, RGBin);
    }
  }
}

// Final desired logic
void main_logic_final() {
  while (1) {
    if (*start != 0) {
      unsigned int src_img_w = (unsigned int)*src_width;
      unsigned int src_img_h = (unsigned int)*src_height;
      unsigned int src_addr = (unsigned int)*src_offset_addr;
      unsigned int src_size = (unsigned int)*src_image_size;
      unsigned int dst_img_w = (unsigned int)*dst_width;
      unsigned int dst_img_h = (unsigned int)*dst_height;
      unsigned int dst_addr = (unsigned int)*dst_offset_addr;
      unsigned int dst_size = (unsigned int)*dst_image_size;

      unsigned char *src_ptr = (unsigned char *)((unsigned long long)src_addr);
      unsigned char *dst_ptr = (unsigned char *)((unsigned long long)dst_addr);
      /*if (src_img_w != 16) {
        *exit_ = 50;
      } else if (src_img_h != 12) {
        *exit_ = 51;
      } else if (src_addr == 0){
        *exit_ = 70;
      } else if (src_addr == 1){
        *exit_ = 81;
      }
      else if (src_addr != 0x38000000) {
        *exit_ = src_addr;
      } else if (src_size != 0) {
        *exit_ = 53;
      } else if (dst_img_w != 8) {
        *exit_ = 54;
      } else if (dst_img_h != 6) {
        *exit_ = 55;
      } else if (dst_addr != 0x3c000000) {
        *exit_ = 56;
      } else if (dst_size != 0) {
        *exit_ = 57;
      }*/
      pure_func(src_img_w, src_img_h, src_size, src_ptr, dst_img_w, dst_img_h,
                dst_size, dst_ptr);
      __sync_synchronize();
      *idle = 1;
    }
  }
}

void main() {
  asm volatile("la t0, %0;"       // Load the address of expHandler into t0
               "csrw mtvec, t0;"  // Set mtvec to the address in t0
               :                  // No output operands
               : "i"(&expHandler) // Input operands
               : "t0"             // Clobber list
  );
  /*volatile unsigned char *p = (volatile unsigned char *)EXTDDRBase;
  for (int i = 0; i < 1000; ++i)
    p[i] = i % 18;*/
  main_logic_final();
}