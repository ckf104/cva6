// Copyright 2021 Thales DIS design services SAS
//
// Licensed under the Solderpad Hardware Licence, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.0
// You may obtain a copy of the License at https://solderpad.org/licenses/
//
// Original Author: Guillaume Chauvon (guillaume.chauvon@thalesgroup.com)

package cvxif_instr_pkg;

  typedef enum logic [2:0] {
    MV_V_X = 'b0,
    MV_X_V = 'b1,
    VADD2 = 'b10, // VADD2 should be first one
    NV12toCAG444 = 'b11,
    CAG444toRGB888 = 'b100,
    NumCustomInst  = CAG444toRGB888 + 1
  } custom_vec_op_e;

  typedef logic [9:0] vlen_t;

  typedef struct packed {
    logic [31:0]              instr;
    logic [31:0]              mask;
    cvxif_pkg::x_issue_resp_t resp;
    custom_vec_op_e           op;
    vlen_t                    vlen_in1;
    vlen_t                    vlen_in2;
    vlen_t                    vlen_out;
  } copro_issue_resp_t;



  // 2 Possible RISCV instructions for Coprocessor
  parameter int unsigned NbInstr = 5;
  parameter copro_issue_resp_t CoproInstr[NbInstr] = '{
      '{
          instr: 32'b00000_00_00000_00000_0_00_00000_0001011,  // v to x mv
          mask: 32'b11111_11_00000_00000_1_11_00000_1111111,
          op: MV_V_X,
          vlen_in1: 'b0,
          vlen_in2: 'b0,
          vlen_out: 'b0,
          resp : '{
              accept : 1'b1,
              writeback : 1'b0,
              dualwrite : 1'b0,
              dualread : 1'b0,
              loadstore : 1'b0,
              exc : 1'b0
          }
      },
      '{
          instr: 32'b00000_00_00000_00000_0_01_00000_0001011,  // x to v mv
          mask: 32'b11111_11_00000_00000_1_11_00000_1111111,
          op: MV_X_V,
          vlen_in1: 'b0,
          vlen_in2: 'b0,
          vlen_out: 'b0,
          resp : '{
              accept : 1'b1,
              writeback : 1'b1,
              dualwrite : 1'b0,
              dualread : 1'b0,
              loadstore : 1'b0,
              exc : 1'b0
          }
      },
      '{
          instr: 32'b00000_01_00000_00000_0_00_00000_0001011,  // vadd4
          mask: 32'b11111_11_00000_00000_1_11_00000_1111111,
          op: VADD2,
          vlen_in1: 'd2,
          vlen_in2: 'd2,
          vlen_out: 'd2,
          resp : '{
              accept : 1'b1,
              writeback : 1'b0,
              dualwrite : 1'b0,
              dualread : 1'b0,
              loadstore : 1'b0,
              exc : 1'b0
          }
      },
      '{
          instr: 32'b00000_10_00000_00000_0_00_00000_0001011,  // NV12toCAG444
          mask: 32'b11111_11_00000_00000_1_11_00000_1111111,
          op: NV12toCAG444,
          vlen_in1: 'd2,
          vlen_in2: 'd2,
          vlen_out: 'd3,
          resp : '{
              accept : 1'b1,
              writeback : 1'b0,
              dualwrite : 1'b0,
              dualread : 1'b0,
              loadstore : 1'b0,
              exc : 1'b0
          }
      },
      '{
          instr: 32'b00000_11_00000_00000_0_00_00000_0001011,  // CAG444toRGB888
          mask: 32'b11111_11_00000_00000_1_11_00000_1111111,
          op: CAG444toRGB888,
          vlen_in1: 'd3,
          vlen_in2: 'd0,
          vlen_out: 'd3,
          resp : '{
              accept : 1'b1,
              writeback : 1'b0,
              dualwrite : 1'b0,
              dualread : 1'b0,
              loadstore : 1'b0,
              exc : 1'b0
          }
      }
  };

endpackage
