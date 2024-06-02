// Copyright 2021 Thales DIS design services SAS
//
// Licensed under the Solderpad Hardware Licence, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.0
// You may obtain a copy of the License at https://solderpad.org/licenses/
//
// Original Author: Guillaume Chauvon (guillaume.chauvon@thalesgroup.com)

package cvxif_instr_pkg;

  typedef enum logic [1:0] {
    MV_V_X,
    MV_X_V,
    VADD2
  } custom_vec_op_e;

  typedef logic [9:0] vlen_t;

  typedef struct packed {
    logic [31:0]              instr;
    logic [31:0]              mask;
    cvxif_pkg::x_issue_resp_t resp;
    custom_vec_op_e           op;
    vlen_t                    vlen;
  } copro_issue_resp_t;



  // 2 Possible RISCV instructions for Coprocessor
  parameter int unsigned NbInstr = 3;
  parameter copro_issue_resp_t CoproInstr[NbInstr] = '{
      '{
          instr: 32'b00000_00_00000_00000_0_00_00000_0001011,  // v to x mv
          mask: 32'b11111_11_00000_00000_1_11_00000_1111111,
          op: MV_V_X,
          vlen: 'b0,
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
          vlen: 'b0,
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
          vlen: 'd2,
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
