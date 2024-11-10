/*============================================================================

    fourierf.c  -  Don Cross <dcross@intersrv.com>

    http://www.intersrv.com/~dcross/fft.html

    Contains definitions for doing Fourier transforms
    and inverse Fourier transforms.

    This module performs operations on arrays of 'float'.

    Revision history:

1998 September 19 [Don Cross]
    Updated coding standards.
    Improved efficiency of trig calculations.

============================================================================*/

void NumberOfBitsNeeded(unsigned PowerOfTwo, unsigned *num) {
  // [OPTIMIZED]
  unsigned ans = 0;
  PowerOfTwo = PowerOfTwo ^ (PowerOfTwo - 1);
  if (PowerOfTwo == 1)
    ans = 0;
  else if (PowerOfTwo == 3)
    ans = 1;
  else if (PowerOfTwo == 7)
    ans = 2;
  else if (PowerOfTwo == 15)
    ans = 3;
  else if (PowerOfTwo == 31)
    ans = 4;
  else if (PowerOfTwo == 63)
    ans = 5;
  else if (PowerOfTwo == 127)
    ans = 6;
  else if (PowerOfTwo == 255)
    ans = 7;
  else if (PowerOfTwo == 511)
    ans = 8;
  else if (PowerOfTwo == 1023)
    ans = 9;
  else if (PowerOfTwo == 2047)
    ans = 10;
  else if (PowerOfTwo == 4095)
    ans = 11;
  else if (PowerOfTwo == 8191)
    ans = 12;
  else if (PowerOfTwo == 16383)
    ans = 13;
  else if (PowerOfTwo == 32767)
    ans = 14;
  else if (PowerOfTwo == 65535)
    ans = 15;
  else if (PowerOfTwo == 131071)
    ans = 16;
  else if (PowerOfTwo == 262143)
    ans = 17;
  else if (PowerOfTwo == 524287)
    ans = 18;
  else if (PowerOfTwo == 1048575)
    ans = 19;
  else if (PowerOfTwo == 2097151)
    ans = 20;
  else if (PowerOfTwo == 4194303)
    ans = 21;
  else if (PowerOfTwo == 8388607)
    ans = 22;
  else if (PowerOfTwo == 16777215)
    ans = 23;
  else if (PowerOfTwo == 33554431)
    ans = 24;
  else if (PowerOfTwo == 67108863)
    ans = 25;
  else if (PowerOfTwo == 134217727)
    ans = 26;
  else if (PowerOfTwo == 268435455)
    ans = 27;
  else if (PowerOfTwo == 536870911)
    ans = 28;
  else if (PowerOfTwo == 1073741823)
    ans = 29;
  else if (PowerOfTwo == 2147483647)
    ans = 30;
  else if (PowerOfTwo == 4294967295)
    ans = 31;
  *num = ans;
  return;
}

// opcode 0
/// echo NumberOfBitsNeeded 1in, 1out
/// exec.p.f, 0, t0, 0, a0, x0, 0
void NumberOfBitsNeeded_ex(unsigned PowerOfTwo, unsigned *num) {
  asm volatile(".word 0b00000000000001010000001010001011;"
               "sw t0, 0(%0);"
               :
               : "r"(num)
               : "t0", "memory");
}

void ReverseBits(unsigned index, unsigned NumBits, unsigned *ans) {
  unsigned rev = 0;
  // for ( i=0; i<32; ++i) {   // full unroll
  //     rev |= ((index >> i) & 1) << (31-i);
  //     // index >> = 1;
  // }
  rev |= ((index >> 0) & 1) << (31 - 0);
  rev |= ((index >> 1) & 1) << (31 - 1);
  rev |= ((index >> 2) & 1) << (31 - 2);
  rev |= ((index >> 3) & 1) << (31 - 3);
  rev |= ((index >> 4) & 1) << (31 - 4);
  rev |= ((index >> 5) & 1) << (31 - 5);
  rev |= ((index >> 6) & 1) << (31 - 6);
  rev |= ((index >> 7) & 1) << (31 - 7);
  rev |= ((index >> 8) & 1) << (31 - 8);
  rev |= ((index >> 9) & 1) << (31 - 9);
  rev |= ((index >> 10) & 1) << (31 - 10);
  rev |= ((index >> 11) & 1) << (31 - 11);
  rev |= ((index >> 12) & 1) << (31 - 12);
  rev |= ((index >> 13) & 1) << (31 - 13);
  rev |= ((index >> 14) & 1) << (31 - 14);
  rev |= ((index >> 15) & 1) << (31 - 15);
  rev |= ((index >> 16) & 1) << (31 - 16);
  rev |= ((index >> 17) & 1) << (31 - 17);
  rev |= ((index >> 18) & 1) << (31 - 18);
  rev |= ((index >> 19) & 1) << (31 - 19);
  rev |= ((index >> 20) & 1) << (31 - 20);
  rev |= ((index >> 21) & 1) << (31 - 21);
  rev |= ((index >> 22) & 1) << (31 - 22);
  rev |= ((index >> 23) & 1) << (31 - 23);
  rev |= ((index >> 24) & 1) << (31 - 24);
  rev |= ((index >> 25) & 1) << (31 - 25);
  rev |= ((index >> 26) & 1) << (31 - 26);
  rev |= ((index >> 27) & 1) << (31 - 27);
  rev |= ((index >> 28) & 1) << (31 - 28);
  rev |= ((index >> 29) & 1) << (31 - 29);
  rev |= ((index >> 30) & 1) << (31 - 30);
  rev |= ((index >> 31) & 1) << (31 - 31);
  rev = rev >> (32 - NumBits);
  *ans = rev;
  // return rev;
  return;
}

// opcode 1
/// echo ReverseBits 2in, 1out
/// exec.p.f, 0, t0, 0, a0, a1, 1
void ReverseBits_ex(unsigned index, unsigned NumBits, unsigned *ans) {
  asm volatile(".word 0b00000010101101010000001010001011;"
               "sw t0, 0(%0);"
               :
               : "r"(ans)
               : "t0", "memory");
}

void group2(unsigned char opcode, unsigned int in1, unsigned int in2,
            unsigned int *out) {
  if (opcode == 0)
#ifdef USE_EXT_INST
    NumberOfBitsNeeded_ex(in1, out);
#else
    NumberOfBitsNeeded(in1, out);
#endif
  else if (opcode == 1)
#ifdef USE_EXT_INST
    ReverseBits_ex(in1, in2, out);
#else
    ReverseBits(in1, in2, out);
#endif
  return;
}

/*============================================================================

       fourier.h  -  Don Cross <dcross@intersrv.com>

       http://www.intersrv.com/~dcross/fft.html

       Contains definitions for doing Fourier transforms
       and inverse Fourier transforms.

============================================================================*/
#ifdef __cplusplus
extern "C" {
#endif

/*
**   fft() computes the Fourier transform or inverse transform
**   of the complex inputs to produce the complex outputs.
**   The number of samples must be a power of two to do the
**   recursive decomposition of the FFT algorithm.
**   See Chapter 12 of "Numerical Recipes in FORTRAN" by
**   Press, Teukolsky, Vetterling, and Flannery,
**   Cambridge University Press.
**
**   Notes:  If you pass ImaginaryIn = NULL, this function will "pretend"
**           that it is an array of all zeroes.  This is convenient for
**           transforming digital samples of real number data without
**           wasting memory.
*/

void fft_double(unsigned NumSamples,   /* must be a power of 2 */
                int InverseTransform,  /* 0=forward FFT, 1=inverse FFT */
                double *RealIn,        /* array of input's real samples */
                double *ImaginaryIn,   /* array of input's imag samples */
                double *RealOut,       /* array of output's reals */
                double *ImaginaryOut); /* array of output's imaginaries */

void fft_float(unsigned NumSamples,  /* must be a power of 2 */
               int InverseTransform, /* 0=forward FFT, 1=inverse FFT */
               float *RealIn,        /* array of input's real samples */
               float *ImaginaryIn,   /* array of input's imag samples */
               float *RealOut,       /* array of output's reals */
               float *ImaginaryOut); /* array of output's imaginaries */

/*
**   The following function returns an "abstract frequency" of a
**   given index into a buffer with a given number of frequency samples.
**   Multiply return value by sampling rate to get frequency expressed in Hz.
*/
double Index_to_frequency(unsigned NumSamples, unsigned Index);

#ifdef __cplusplus
}
#endif

/*--- end of file fourier.h ---*/

/*==========================================================================

    ddcmath.h  -  Don Cross <dcross@intersrv.com>, October 1994.

    Contains useful math stuff.

==========================================================================*/

#ifndef __ddcmath_h
#define __ddcmath_h

#define DDC_PI (3.14159265358979323846)

#endif /* __ddcmath_h */

/*--- end of file ddcmath.h ---*/

// Generate sin\theta value from 0 to 90 degree
double sinTable[] = {
    0.0,          0.0174524064, 0.0348994967, 0.0523359562, 0.0697564737,
    0.0871557427, 0.104528463,  0.121869343,  0.139173101,  0.156434465,
    0.173648178,  0.190808995,  0.207911691,  0.224951054,  0.241921896,
    0.258819045,  0.275637356,  0.292371705,  0.309016994,  0.325568154,
    0.342020143,  0.35836795,   0.374606593,  0.390731128,  0.406736643,
    0.422618262,  0.438371147,  0.4539905,    0.469471563,  0.48480962,
    0.5,          0.515038075,  0.529919264,  0.544639035,  0.559192903,
    0.573576436,  0.587785252,  0.601815023,  0.615661475,  0.629320391,
    0.64278761,   0.656059029,  0.669130606,  0.68199836,   0.69465837,
    0.707106781,  0.7193398,    0.731353702,  0.743144825,  0.75470958,
    0.766044443,  0.777145961,  0.788010754,  0.79863551,   0.809016994,
    0.819152044,  0.829037573,  0.838670568,  0.848048096,  0.857167301,
    0.866025404,  0.874619707,  0.882947593,  0.891006524,  0.898794046,
    0.906307787,  0.913545458,  0.920504853,  0.927183855,  0.933580426,
    0.939692621,  0.945518576,  0.951056516,  0.956304756,  0.961261696,
    0.965925826,  0.970295726,  0.974370065,  0.978147601,  0.981627183,
    0.984807753,  0.987688341,  0.990268069,  0.992546152,  0.994521895,
    0.996194698,  0.99756405,   0.998629535,  0.999390827,  0.999847695,
    1.0};

double sin(double degree) {
  int revert = 0;
  if (degree < 0.0f) {
    degree = -degree;
    revert = 1;
  }
  while (degree >= 360.0) {
    degree -= 360.0;
  }
  if (degree >= 270.0) {
    degree = 360.0 - degree;
    revert = !revert;
  } else if (degree >= 180.0) {
    degree -= 180.0;
    revert = !revert;
  } else if (degree >= 90.0) {
    degree = 180.0 - degree;
  }
  int idx = (int)degree;
  double r;
  // Do a linear interpretation
  if (idx == 90)
    r = 1.0;
  else
    r = sinTable[idx] + (sinTable[idx + 1] - sinTable[idx]) * (degree - idx);
  return revert ? -r : r;
}

double cos(double degree) {
  int revert = 0;
  if (degree < 0.0f) {
    degree = -degree;
  }
  while (degree >= 360.0) {
    degree -= 360.0;
  }
  if (degree >= 270.0) {
    degree = 360.0 - degree;
  } else if (degree >= 180.0) {
    degree -= 180.0;
    revert = !revert;
  } else if (degree >= 90.0) {
    degree = 180.0 - degree;
    revert = !revert;
  }
  double invert_deg = 90.0 - degree;
  int idx = (int)invert_deg;
  // Do a linear interpretation
  double r;
  if (idx == 90)
    r = 1.0;
  else
    r = sinTable[idx] +
        (sinTable[idx + 1] - sinTable[idx]) * (invert_deg - idx);
  return revert ? -r : r;
}

void fft_float(unsigned NumSamples, int InverseTransform, float *RealIn,
               float *ImagIn, float *RealOut, float *ImagOut) {
  unsigned NumBits; /* Number of bits needed to store indices */
  unsigned i, j, k, n;
  unsigned BlockSize, BlockEnd;

  double angle_numerator = 360.0;
  double tr, ti; /* temp real, temp imaginary */

  if (InverseTransform)
    angle_numerator = -angle_numerator;

  // NumBits = NumberOfBitsNeeded ( NumSamples );
  group2(0, NumSamples, 0, &NumBits);

  /*
  **   Do simultaneous data copy and bit-reversal ordering into outputs...
  */

  for (i = 0; i < NumSamples; i++) {
    // j = ReverseBits ( i, NumBits );
    group2(1, i, NumBits, &j);
    RealOut[j] = RealIn[i];
    ImagOut[j] = (ImagIn == 0) ? 0.0 : ImagIn[i];
  }

  /*
  **   Do the FFT itself...
  */

  BlockEnd = 1;
  for (BlockSize = 2; BlockSize <= NumSamples; BlockSize <<= 1) {
    double delta_angle = angle_numerator / (double)BlockSize;
    double sm2 = sin(-2 * delta_angle);
    double sm1 = sin(-delta_angle);
    double cm2 = cos(-2 * delta_angle);
    double cm1 = cos(-delta_angle);

    double w = 2 * cm1;
    double ar[3], ai[3];
    double temp;

    for (i = 0; i < NumSamples; i += BlockSize) {
      ar[2] = cm2;
      ar[1] = cm1;

      ai[2] = sm2;
      ai[1] = sm1;

      for (j = i, n = 0; n < BlockEnd; j++, n++) {
        ar[0] = w * ar[1] - ar[2];
        ar[2] = ar[1];
        ar[1] = ar[0];

        ai[0] = w * ai[1] - ai[2];
        ai[2] = ai[1];
        ai[1] = ai[0];

        k = j + BlockEnd;
        // [OPTIMIZED]
        tr = ar[0] * RealOut[k] - ai[0] * ImagOut[k];
        ti = ar[0] * ImagOut[k] + ai[0] * RealOut[k];

        RealOut[k] = RealOut[j] - tr;
        ImagOut[k] = ImagOut[j] - ti;

        RealOut[j] += tr;
        ImagOut[j] += ti;
        // end here
      }
    }

    BlockEnd = BlockSize;
  }

  /*
  **   Need to normalize if inverse transform...
  */

  if (InverseTransform) {
    double denom = (double)NumSamples;

    for (i = 0; i < NumSamples; i++) {
      RealOut[i] /= denom;
      ImagOut[i] /= denom;
    }
  }
}

#define TRUE 1
#define FALSE 0

#define BITS_PER_WORD (sizeof(unsigned) * 8)

// unsigned NumberOfBitsNeeded ( unsigned PowerOfTwo )
// {
//     // [OPTIMIZED]
//     unsigned i;

//     if ( PowerOfTwo < 2 )
//     {
//         fprintf (
//             stderr,
//             ">>> Error in fftmisc.c: argument %d to NumberOfBitsNeeded is too
//             small.\n", PowerOfTwo );

//         exit(1);
//     }

//     for ( i=0; ; i++ )
//     {
//         if ( PowerOfTwo & (1 << i) )
//             return i;
//     }
// }

// unsigned ReverseBits ( unsigned index, unsigned NumBits )
// {
//     // [OPTIMIZED]
//     unsigned i, rev;

//     for ( i=rev=0; i < NumBits; i++ )
//     {
//         rev = (rev << 1) | (index & 1);
//         index >>= 1;
//     }

//     return rev;
// }

double Index_to_frequency(unsigned NumSamples, unsigned Index) {
  if (Index >= NumSamples)
    return 0.0;
  else if (Index <= NumSamples / 2)
    return (double)Index / (double)NumSamples;

  return -(double)(NumSamples - Index) / (double)NumSamples;
}

#define MAXSIZE 128
#define MAXWAVES 8
float RealIn[] = {
    2316.000000,  1168.376709,  -1020.097229, -771.886597,  -1492.326172,
    -983.757751,  1628.191162,  1711.497925,  -334.943420,  386.600067,
    1871.495483,  -565.446716,  792.852722,   1290.721436,  -1141.717041,
    -1114.083252, -630.643982,  -2466.156982, 1127.915161,  156.391678,
    -839.531433,  -2023.918335, 378.248779,   -940.563782,  1056.511597,
    1071.815674,  870.217468,   -1564.582642, 1281.639771,  -2039.902100,
    42.445141,    -1251.409180, 101.539528,   -602.632690,  1363.619263,
    569.329529,   1415.901001,  -1246.223877, 1262.406494,  -1457.240234,
    1162.587646,  43.522148,    879.683594,   -717.454468,  -513.137878,
    -1140.404541, 749.869568,   778.423645,   593.972046,   -746.085693,
    644.046082,   -1104.754883, 2605.516602,  1413.312256,  1168.816772,
    -1775.356323, -96.052223,   -2548.879150, 790.547974,   416.752533,
    414.063477,   403.702026,   197.395111,   -1721.512939, 263.667206,
    1235.324707,  1565.404175,  -723.662537,  -216.745361,  -1481.704834,
    36.944515,    -87.109123,   -31.424662,   -1070.352417, 1303.444458,
    -1183.191528, 955.933289,   -75.443665,   739.596191,   -1871.519531,
    933.986572,   -158.150787,  387.756378,   -1465.398682, 1580.672119,
    -941.939880,  620.347717,   -858.145874,  1431.252075,  -543.081482,
    1050.855347,  -1060.762329, -341.943939,  916.053711,   -184.254272,
    -1328.618530, -884.851929,  -2185.185791, 324.613739,   -191.661850,
    1281.515381,  10.537456,    1002.177124,  -848.507935,  79.472862,
    1061.081177,  663.594604,   -2414.561523, 704.075134,   -1783.036499,
    -64.578392,   814.156067,   1123.315796,  905.779907,   737.034790,
    -1153.000488, 1806.247559,  99.954834,    1658.724976,  -481.974579,
    -387.253906,  -1142.467407, -245.001251,  -531.141602,  -151.657425,
    -1132.612305, 456.826752,   -1025.754272};
float ImagIn[MAXSIZE];
float RealOut[MAXSIZE];
float ImagOut[MAXSIZE];

float GoldReal[] = {
    -1217.581665,  -758.850952,  3707.031982,  4572.430176,   -4915.333496,
    -4446.520020,  -4447.620117, -7753.353516, -5636.360352,  -3765.419434,
    25092.843750,  5258.505371,  3329.276855,  -2224.474609,  9035.143555,
    16503.708984,  177.907043,   4334.474121,  -3634.532471,  12088.370117,
    -2171.396973,  3623.479004,  24703.320312, 2198.419189,   2302.203613,
    1891.299561,   2322.789551,  10100.059570, -4009.651855,  2852.739746,
    -2591.124756,  -6662.127441, -5037.522461, 6645.624512,   -1923.074463,
    2681.044189,   -957.946411,  -626.610901,  2484.905762,   3585.298828,
    12201.324219,  16142.431641, -1744.204468, -85.579758,    4478.743652,
    -3819.606201,  -715.573242,  -1773.436646, -5393.204590,  -6201.816406,
    6786.472168,   13645.928711, 6785.788086,  -5865.717285,  4786.999023,
    4262.995117,   -5275.369629, 2885.095215,  -1379.445557,  5192.187500,
    -5116.208496,  1357.401123,  -9360.499023, -10211.235352, 74900.101562,
    -10186.243164, -9443.715820, 1597.935913,  -4906.424316,  5225.216309,
    -1118.222168,  2948.364746,  -5233.805664, 4330.509277,   4470.682617,
    -5953.303711,  6802.041504,  13990.422852, 6826.514648,   -6131.348145,
    -5401.098633,  -1838.104980, -856.329834,  -4073.947266,  5059.391602,
    196.614090,    -725.686584,  16042.141602, 12214.159180,  3435.198975,
    2546.721191,   -555.924194,  -981.461060,  2647.620605,   -1929.263916,
    6481.818359,   -4730.063477, -6782.435547, -2620.539307,  2809.226318,
    -3968.598633,  10185.613281, 2409.287109,  1812.255981,   2400.089844,
    2163.564697,   25693.048828, 3705.653564,  -1627.780762,  11651.370117,
    -3834.746094,  4198.344727,  275.546448,   16491.779297,  8986.871094,
    -2092.257324,  3286.468750,  5030.715332,  24710.736328,  -3679.310791,
    -5474.563965,  -7662.715820, -4196.949219, -4340.072754,  -4675.317871,
    4771.994629,   3573.503174,  -698.143982};

float GoldImag[] = {
    -0.434028,     1161.818359,   -7814.712402,  -355.409515,   4054.479492,
    10802.670898,  6907.136719,   873.607605,    8378.371094,   -2509.491943,
    -13536.235352, -7960.942383,  -3797.987305,  1952.730469,   -5702.458984,
    -2714.048340,  5365.746094,   -2339.471191,  -3286.473389,  -17290.283203,
    13072.693359,  -2088.514160,  29708.398438,  3860.006836,   1660.855103,
    -141.748535,   2697.304688,   -3218.014160,  5266.705078,   3051.046875,
    3507.332764,   -69.490746,    9362.674805,   -5252.021484,  -2069.434082,
    -4340.331543,  -5406.975586,  5992.067871,   1369.266357,   -7677.179199,
    888.517212,    -8240.133789,  22720.304688,  12889.550781,  14084.743164,
    -3195.090576,  -4147.095215,  756.914062,    -2227.731445,  4991.561035,
    5013.710938,   13355.341797,  2403.597168,   -635.762268,   -152.476990,
    4175.825195,   -4572.507812,  3249.033936,   6612.788086,   -4640.138672,
    7490.357910,   10942.627930,  1684.869141,   -773.647461,   2.548337,
    540.992432,    -1935.169312,  -10990.944336, -7496.438965,  4818.860840,
    -6563.591309,  -3114.476318,  4494.605957,   -4093.526123,  -29.466831,
    428.931854,    -2195.459961,  -13067.050781, -4994.730469,  -5412.832031,
    2133.760986,   -895.446228,   4128.528809,   2893.041748,   -13961.319336,
    -12982.965820, -23281.906250, 8594.346680,   -578.198853,   7748.216309,
    -1271.146240,  -6156.447754,  5515.006836,   4333.650391,   2044.855225,
    5544.441895,   -9363.215820,  -171.399872,   -3503.407715,  -3077.510742,
    -5360.661133,  3429.034912,   -2763.610840,  139.084198,    -1771.335083,
    -4061.679688,  -29144.671875, 2194.761475,   -13235.555664, 17561.298828,
    3145.554688,   2430.462891,   -5272.108398,  3204.920166,   5852.128906,
    -2184.606689,  3665.678711,   8134.850586,   13815.650391,  2307.184326,
    -8501.548828,  -1099.974365,  -7057.174316,  -11019.877930, -4098.864746,
    423.422852,    8045.930664,   -1011.848999};

int main() {
  unsigned i, j;
  int invfft = 0;

  // if (argc<3)
  // {
  // 	printf("Usage: fft <waves> <length> -i\n");
  // 	printf("-i performs an inverse fft\n");
  // 	printf("make <waves> random sinusoids");
  // 	printf("<length> is the number of samples\n");
  // 	exit(-1);
  // }
  // else if (argc==4)
  // 	invfft = !strncmp(argv[3],"-i",2);
  // MAXSIZE=atoi(argv[2]);
  // MAXWAVES=atoi(argv[1]);

  /* regular*/
  for (int i = 0; i < 10; ++i)
    fft_float(MAXSIZE, invfft, RealIn, ImagIn, RealOut, ImagOut);

  for (i = 0; i < MAXSIZE; i++) {
    if (RealOut[i] - GoldReal[i] >= 0.0001f ||
        RealOut[i] - GoldReal[i] <= -0.0001f) {
      return i + 1;
    } else if (ImagOut[i] - GoldImag[i] >= 0.0001f ||
               ImagOut[i] - GoldImag[i] <= -0.0001f) {
      return i + 1 + MAXSIZE;
    }
  }

  return 0;
}
