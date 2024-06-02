# Copyright 2022 Thales DIS design services SAS
#
# Licensed under the Solderpad Hardware Licence, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.0
# You may obtain a copy of the License at https://solderpad.org/licenses/
#
# Original Author: Guillaume Chauvon (guillaume.chauvon@thalesgroup.fr)

#*****************************************************************************
# vec_mv_test.S
#-----------------------------------------------------------------------------
#

  .globl main
main:
# core of the test
# (example of) final self-check test
  li a0, 0xCAFE;
  li a1, 0xCAFE;

# funct7: 0000000, rs2: 00000, rs1: 00000, funct3: 100, rd: 00000, opcode: 0110011
# instr: 32'b00000_00_00000_00000_0_00_00000_0001011,
# mask: 32'b11111_11_00000_00000_1_11_00000_1111111
# func7      rs2      rs1  func3  rd  opcode

# 0000000    rs2      rs1  000    rd  0001011  custmv v1 -> r1 向量->标量

# 0000000    rs2      rs1  001    rd  0001011  custmv r1 -> v1  标量->向量
#               7    5    5  3    5      7
  .word 0b00000000000001011001000000001011    # mv x11(a1) -> v0.0
  .word 0b00000000000000000000011010001011    # mv v0.0 -> x13(a3)
  xor a2, a0, a3;
  beqz a2, pass;

fail:
  # Failure post-processing (messages, ecall setup etc.)
  li a0, 0x1;
  jal exit;

pass:
  # Success post-processing (messages, ecall setup etc.)
  li a0, 0x0;
  jal exit;

