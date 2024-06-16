#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

typedef unsigned char uchar8;

#pragma pack(push, 1)
typedef struct BMPFileHeader {
  uint16_t bfType; // 'BM'
  uint32_t bfSize;
  uint16_t bfReserved1;
  uint16_t bfReserved2;
  uint32_t bfOffBits;
} BMPFileHeader_t;

typedef struct BMPInfoHeader {
  uint32_t biSize;
  int32_t biWidth;
  int32_t biHeight;
  uint16_t biPlanes;
  uint16_t biBitCount;
  uint32_t biCompression;
  uint32_t biSizeImage;
  int32_t biXPelsPerMeter;
  int32_t biYPelsPerMeter;
  uint32_t biClrUsed;
  uint32_t biClrImportant;
} BMPInfoHeader_t;
#pragma pack(pop)

void saveRGB888AsBMP_isax(const char *filename, const uchar8 *data, int width,
                          int height) {
  BMPFileHeader_t fileHeader = {
      .bfType = 0x4D42, .bfOffBits = 54, .bfReserved1 = 0, .bfReserved2 = 0};
  BMPInfoHeader_t infoHeader = {.biSize = 40,
                                .biPlanes = 1,
                                .biBitCount = 24,
                                .biCompression = 0,
                                .biXPelsPerMeter = 0,
                                .biYPelsPerMeter = 0,
                                .biClrUsed = 0,
                                .biClrImportant = 0};

  int rowSize = (width * 3 + 3) & ~3;
  int imageSize = rowSize * height;

  fileHeader.bfSize = fileHeader.bfOffBits + imageSize;
  infoHeader.biWidth = width;
  infoHeader.biHeight = -height;
  infoHeader.biSizeImage = imageSize;

  //    std::ofstream file(filename, std::ios::out | std::ios::binary);
  FILE *file = fopen(filename, "wb");
  if (!file) {
    //        std::cerr << "open error" << filename << std::endl;
    printf("Open Error %s\n", filename);
    return;
  }

  //    file.write(reinterpret_cast<const char*>(&fileHeader),
  //    sizeof(fileHeader)); file.write(reinterpret_cast<const
  //    char*>(&infoHeader), sizeof(infoHeader));
  assert(fwrite(&fileHeader, sizeof(fileHeader), 1, file) == 1);
  assert(fwrite(&infoHeader, sizeof(infoHeader), 1, file) == 1);

  for (int y = 0; y < height; ++y) {
    //        file.write(reinterpret_cast<const char*>(data + y * width * 3),
    //        width * 3);
    assert(fwrite(data + (y * width * 3), width * 3, 1, file) == 1);
    if (width * 3 % 4 != 0) {
      uchar8 padding[3] = {0};
      assert(fwrite(padding, rowSize - width * 3, 1, file) == 1);
    }
  }

  assert(fclose(file) == 0);
  printf("BMP saved as %s\n", filename);
}

void nv2cag(unsigned long long *in1, unsigned long long *in2,
            unsigned long long *out);
void cag2rgb(unsigned long long *in, unsigned long long *out);

int main() {
  // full test
  const char *filename = "infrared_test07_01_0005.yuv";

  unsigned int src_width = 1024;
  unsigned int src_height = 768;

  unsigned int src_size = src_width * src_height;
  unsigned int frameSize = src_size * 3 / 2;
  unsigned char frameSrc[frameSize + 10];
  FILE *file = fopen(filename, "rb");
  if (!file) {
    printf("ERROR ON OPEN FILE!\n");
    return -1;
  }

  unsigned int bytesRead = fread(frameSrc, 1, frameSize, file);
  if (bytesRead != frameSize) {
    printf("File length not compat!\n");
    return -1;
  }

  assert(fclose(file) == 0);

  unsigned int dst_width = src_width / 2;
  unsigned int dst_height = src_height / 2;
  unsigned int dst_size = dst_width * dst_height;
  unsigned char CAG444[dst_size * 3 + 10];
  unsigned char RGB888[dst_size * 3 + 10];

  unsigned int UVoffset_base = 1 * (src_width) * (src_height);
  for (unsigned int dh = 0; dh < dst_height; ++dh) {
    for (unsigned int dw = 0; dw < dst_width; dw += 8) {
      unsigned int Y_offset = (dh * 2) * (src_width) + (dw * 2);
      unsigned int UV_offset = UVoffset_base + dh * (src_width) + (dw * 2);
      unsigned int RGB_offset = (dh * (dst_width) + dw) * 3;

      unsigned long long *Yin = (unsigned long long *)(frameSrc + Y_offset);
      unsigned long long *UVin = (unsigned long long *)(frameSrc + UV_offset);
      unsigned long long *CAGin = (unsigned long long *)(CAG444 + RGB_offset);
      unsigned long long *RGBin = (unsigned long long *)(RGB888 + RGB_offset);

      nv2cag(Yin, UVin, CAGin);
      cag2rgb(CAGin, RGBin);
    }
  }

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
      printf("Error: yuv[%d] = %llx, yuv_imm[%d] = %llx\n", i, yuv[i], i,
             yuv_imm[i]);
      return -1;
    }
    if (rgb[i] != rgb_imm[i]) {
      printf("Error: rgb[%d] = %llx, rgb_imm[%d] = %llx\n", i, rgb[i], i,
             rgb_imm[i]);
      return -1;
    }
  }
  saveRGB888AsBMP_isax("Example.bmp", RGB888, dst_width, dst_height);

  return 0;
}
