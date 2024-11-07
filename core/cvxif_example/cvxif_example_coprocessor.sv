// Copyright 2021 Thales DIS design services SAS
//
// Licensed under the Solderpad Hardware Licence, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.0
// You may obtain a copy of the License at https://solderpad.org/licenses/
//
// Original Author: Guillaume Chauvon (guillaume.chauvon@thalesgroup.com)
// Example coprocessor adds rs1,rs2(,rs3) together and gives back the result to the CPU via the CoreV-X-Interface.
// Coprocessor delays the sending of the result depending on result least significant bits.


// Two assumption I have made:
// 1. cvxif_req_i.x_issue_valid will not be asserted if cvxif_resp_o.x_issue_ready is low.
// 2. cvxif_req_i.x_result_ready will always be asserted.

module cvxif_example_coprocessor
  import cvxif_pkg::*;
  import cvxif_instr_pkg::*;
#(
  parameter config_pkg::cva6_cfg_t CVA6Cfg = config_pkg::cva6_cfg_empty,

  // TODO: We should read this from instruction config file
  parameter int unsigned inputWidth       = 64,
  parameter int unsigned outputWidth      = 64,
  parameter int unsigned opocdeWidth      = 4,
  parameter int unsigned inputIndexWidth  = 3,
  parameter int unsigned outputIndexWidth = 3
) (
  input  logic        clk_i,        // Clock
  input  logic        rst_ni,       // Asynchronous reset active low
  input  cvxif_req_t  cvxif_req_i,
  output cvxif_resp_t cvxif_resp_o
);
  // Commit interface is not supported by CPU
  // See https://github.com/openhwgroup/cva6/issues/897
  // logic      x_commit_valid_i;
  // x_commit_t x_commit_i;

  always_comb begin : assign_unused_signals
    // Compressed and memory interface is not supported by CPU
    cvxif_resp_o.x_compressed_ready = 'b0;
    cvxif_resp_o.x_compressed_resp  = 'b0;
    cvxif_resp_o.x_mem_valid        = 'b0;
    cvxif_resp_o.x_mem_req          = 'b0;
  end

  // TODO: properly deal with it if we don't use fixed witdth of opcode, input/output
  // index in instruction encoding.
  logic [31:0] instruction;
  assign instruction = cvxif_req_i.x_issue_req.instr;

  logic invalid_instr, valid_opcode, issue_valid;
  assign issue_valid = cvxif_req_i.x_issue_valid;
  assign valid_opcode = instruction[6:0] == CUSTOM0 || instruction[6:0] == CUSTOM1 || instruction[6:0] == CUSTOM2 ||
    instruction[6:0] == CUSTOM3;
  logic valid_instr;
  assign valid_instr = valid_opcode & ~invalid_instr & issue_valid;

  logic exec;
  assign exec = instruction[6:0] == CUSTOM0 & valid_instr & ~groups_busy;

  logic pick;
  assign pick = instruction[6:0] != CUSTOM3 & valid_instr & ~groups_busy;

  logic fill;
  assign fill = instruction[6:0] != CUSTOM2 & valid_instr & ~groups_busy;

  logic [3:0] opcode;
  assign opcode = instruction[28:25];

  logic [2:0] input_idx;
  assign input_idx = instruction[31:29];

  logic [2:0] output_idx;
  assign output_idx = instruction[14:12];

  logic [X_ID_WIDTH-1:0] instr_id;
  assign instr_id = cvxif_req_i.x_issue_req.id;

  logic groups_busy, busy;
  // Don't override issue -> ex stage registers if it's valid and we are busy
  assign busy = issue_valid & groups_busy;

  logic [1:0][inputWidth-1:0] in_data;
  assign in_data = cvxif_req_i.x_issue_req.rs;

  logic      [outputWidth-1:0] out_data;
  logic      [ X_ID_WIDTH-1:0] out_instr_id;
  logic                        done;

  logic                        x_result_valid_o;
  x_result_t                   x_result_o;

  // cvxif_fu.sv could deal with invalid instruction and valid output at the same time. 
  always_comb begin : commit
    // The result is valid, if execution of one instruction has done, or
    // it's a valid pick/fill instruction, which can be done within the same cycle.
    x_result_valid_o = done || (!exec && (pick || fill) && !groups_busy);

    x_result_o       = 'b0;
    x_result_o.id    = out_instr_id;
    x_result_o.data  = out_data;
    // If execution of one instruction has done, or it's a pick instruction,
    // we should write back the result
    x_result_o.we    = done || (!exec && pick);
    // CPU will ignore `x_result_o.rd` currently
  end

  assign cvxif_resp_o.x_result_valid = x_result_valid_o;
  assign cvxif_resp_o.x_result       = x_result_o;

  // `x_result_ready_i` is always asserted
  logic x_result_ready_i;
  assign x_result_ready_i = cvxif_req_i.x_result_ready;

  always_comb begin : issue_resp
    cvxif_resp_o.x_issue_resp        = 'b0;
    cvxif_resp_o.x_issue_resp.accept = valid_instr;
  end
  assign cvxif_resp_o.x_issue_ready = ~busy;

  groups #(
    .inputWidth      (inputWidth),
    .outputWidth     (outputWidth),
    .opocdeWidth     (opocdeWidth),
    .inputIndexWidth (inputIndexWidth),
    .outputIndexWidth(outputIndexWidth)
  ) groups (
    .clk_i (clk_i),
    .rst_ni(rst_ni),

    .exec_i    (exec),     // Fire execution
    .opcode_i  (opcode),   // Instruction opcode
    .instr_id_i(instr_id), // Instruction id

    .in_data_vld_i(fill),       // Is fill valid?
    .in_idx_i     (input_idx),  // input data index
    .in_data_i    (in_data),

    .out_data_vld_i (pick),           // Is pick valid?
    .out_idx_i      (output_idx),     // output data index
    .invalid_instr_o(invalid_instr),  // Whether the instruction is invalid
    .out_data_o     (out_data),
    .instr_id_o     (out_instr_id),
    .done_o         (done),
    .busy_o         (groups_busy)     // Whether we can accept this new instruction    
  );

endmodule
