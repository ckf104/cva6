#include "stdint.h"

void nv2cag(uint64_t *Yin, uint64_t *UVin, uint64_t *YUVout) {

  uint64_t Yin128[2] = {Yin[0], Yin[1]};
  uint64_t UVin128[2] = {UVin[0], UVin[1]};

  uint64_t YUVout192[3] = {0, 0, 0};

  for (int i = 0; i < 8; ++i) {
    if (i == 4) {
      Yin128[0] = Yin128[1];
      UVin128[0] = UVin128[1];
    }
    uint8_t y = Yin128[0] & 0xff;
    Yin128[0] >>= 16;
    uint8_t u = UVin128[0] & 0xff;
    UVin128[0] >>= 8;
    uint8_t v = UVin128[0] & 0xff;
    UVin128[0] >>= 8;

    YUVout192[(i * 3 + 0) / 8] |= ((uint64_t)y << ((i * 24 + 0) % 64));
    YUVout192[(i * 3 + 1) / 8] |= ((uint64_t)u << ((i * 24 + 8) % 64));
    YUVout192[(i * 3 + 2) / 8] |= ((uint64_t)v << ((i * 24 + 16) % 64));
  }

  YUVout[0] = YUVout192[0];
  YUVout[1] = YUVout192[1];
  YUVout[2] = YUVout192[2];

  return;
}

void cag2rgb(uint64_t *YUVin, uint64_t *RGBout) {

  uint64_t YUV192[3] = {YUVin[0], YUVin[1], YUVin[2]};
  uint64_t RGB192[3] = {0, 0, 0};

  for (int i = 0; i < 8; ++i) {
    uint8_t Y = (YUV192[(i * 3 + 0) / 8] >> ((i * 24 + 0) % 64)) & 0xff;
    uint8_t U = (YUV192[(i * 3 + 1) / 8] >> ((i * 24 + 8) % 64)) & 0xff;
    uint8_t V = (YUV192[(i * 3 + 2) / 8] >> ((i * 24 + 16) % 64)) & 0xff;

    int32_t y = Y;
    int32_t u = U;
    int32_t v = V;

    int32_t y1192 = 1192 * (y - 16);
    int32_t uv448 = 448 * (u - 128);
    int32_t uv128 = 128 * (v - 128);

    int32_t r = (y1192 + uv448) >> 10;
    int32_t g = (y1192 - uv128 - uv448) >> 10;
    int32_t b = (y1192 + uv128) >> 10;

    uint8_t R =
        (r < 0) ? ((uint8_t)0) : ((r > 255) ? (uint8_t)255 : (uint8_t)r);
    uint8_t G =
        (g < 0) ? ((uint8_t)0) : ((g > 255) ? (uint8_t)255 : (uint8_t)g);
    uint8_t B =
        (b < 0) ? ((uint8_t)0) : ((b > 255) ? (uint8_t)255 : (uint8_t)b);

    RGB192[(i * 3 + 0) / 8] |= ((uint64_t)B << ((i * 24 + 0) % 64));
    RGB192[(i * 3 + 1) / 8] |= ((uint64_t)G << ((i * 24 + 8) % 64));
    RGB192[(i * 3 + 2) / 8] |= ((uint64_t)R << ((i * 24 + 16) % 64));
  }

  RGBout[0] = RGB192[0];
  RGBout[1] = RGB192[1];
  RGBout[2] = RGB192[2];

  return;
}