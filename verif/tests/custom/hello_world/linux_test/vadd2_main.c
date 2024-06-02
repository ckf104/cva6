#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

typedef struct packedUint64 {
  uint64_t s1;
  uint64_t s2;
} packedUint64_t;

packedUint64_t vadd2(uint64_t a0, uint64_t a1, uint64_t a2, uint64_t a3);

int main(int argc, char *argv[]) {
  // Generate code to convert argv to four uint64_t
  if (argc != 5) {
    printf("We need four arguments\n");
    return 1;
  }
  uint64_t a0 = strtoull(argv[1], NULL, 0);
  uint64_t a1 = strtoull(argv[2], NULL, 0);
  uint64_t a2 = strtoull(argv[3], NULL, 0);
  uint64_t a3 = strtoull(argv[4], NULL, 0);

  packedUint64_t ret = vadd2(a0, a1, a2, a3);

  if (a0 + a2 != ret.s1) {
    printf("Error: %lu + %lu != %lu\n", a0, a2, ret.s1);
    return 1;

  } else if (a1 + a3 != ret.s2) {
    printf("Error: %lu + %lu != %lu\n", a1, a3, ret.s2);
    return 1;
  }
  printf("Test Success\n");
  return 0;
}