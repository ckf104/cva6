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

module cvxif_example_coprocessor
  import cvxif_pkg::*;
  import cvxif_instr_pkg::*;
#(
    parameter config_pkg::cva6_cfg_t CVA6Cfg = config_pkg::cva6_cfg_empty
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

  //Issue interface
  logic          x_issue_valid_i;
  logic          x_issue_ready_o;
  x_issue_req_t  x_issue_req_i;
  x_issue_resp_t x_issue_resp_o;

  assign x_issue_valid_i            = cvxif_req_i.x_issue_valid;
  assign x_issue_req_i              = cvxif_req_i.x_issue_req;
  assign x_issue_ready_o            = 1'b1;
  assign cvxif_resp_o.x_issue_ready = x_issue_ready_o;
  assign cvxif_resp_o.x_issue_resp  = x_issue_resp_o;

  custom_vec_op_e decoded_op;

  // Decode incoming instruction
  instr_decoder #(
      .NbInstr   (cvxif_instr_pkg::NbInstr),
      .EnableCustomVec(CVA6Cfg.EnableCustomVec),
      .CoproInstr(cvxif_instr_pkg::CoproInstr)
  ) instr_decoder_i (
      .clk_i         (clk_i),
      .req_valid_i   (x_issue_valid_i),
      .x_issue_req_i (x_issue_req_i),
      .x_issue_resp_o(x_issue_resp_o),
      .instr_op_o    (decoded_op)
  );

  typedef logic [$clog2(cva6_config_pkg::CVA6CustomVecNumWords)-1:0] vec_addr_t;
  typedef logic [cva6_config_pkg::CVA6ConfigXlen-1:0] vec_data_t;
  typedef logic [(cva6_config_pkg::CVA6ConfigXlen/8)-1:0] vec_be_t;
  logic                                    vec_we;  // write enable
  vec_addr_t                               vec_waddr;  // request address
  vec_data_t                               vec_wdata;  // write data
  vec_be_t                                 vec_be;  // write byte enable
  vec_addr_t [CVA6Cfg.CustomReadPorts-1:0] vec_raddr;  // read address
  vec_data_t [CVA6Cfg.CustomReadPorts-1:0] vec_rdata;  // read data

  logic                                    fired_new_instr;
  logic                                    new_instr_wb;
  assign fired_new_instr = x_issue_resp_o.accept;

  vec_data_t vec_rdata_q;
  logic result_valid_q, result_we_q, result_we_d;
  // TODO: add ID
  assign result_we_d = decoded_op == MV_V_X;

  logic [9:0] tmp_wt_complete_addr, tmp_rd_complete_addr;
  // Concatenate {rs2, rd} for MV_X_V
  assign tmp_wt_complete_addr = {x_issue_req_i.instr[24:20], x_issue_req_i.instr[11:7]};
  // Concatenate {rs2, rs1} for MV_V_X
  assign tmp_rd_complete_addr = {x_issue_req_i.instr[24:20], x_issue_req_i.instr[19:15]};

  always_comb begin : mv_instr_logic
    vec_we = 'b0;
    vec_waddr = 'b0;
    vec_be = 'b0;
    vec_wdata = 'b0;
    vec_raddr = 'b0;

    if (fired_new_instr) begin
      if (decoded_op == MV_V_X) begin
        vec_raddr[0] = tmp_rd_complete_addr[$size(vec_raddr)-1:0];
      end else if (decoded_op == MV_X_V) begin
        vec_we = 1'b1;
        vec_waddr = tmp_wt_complete_addr[$size(vec_waddr)-1:0];
        vec_be = ~'b0;
        vec_wdata = x_issue_req_i.rs[0];
      end else begin
        // Illegal instruction
      end
    end
  end

  logic fired_new_instr_id, instr_id_q;
  assign fired_new_instr_id = x_issue_req_i.id;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      // Don't need to reset `vec_rdata_q`
      // Don't need to reset `result_we_q`
      // Don't need to reset `instr_id_q`
      result_valid_q <= 1'b1;
    end else begin
      result_valid_q <= fired_new_instr;  // TODO: deal with multi cycle
      result_we_q <= result_we_d;
      vec_rdata_q <= vec_rdata[0];
      instr_id_q <= fired_new_instr_id;
    end
  end

  generate
    if (CVA6Cfg.EnableCustomVec) begin : vec_regfile_gen
      ariane_vecram #(
          .NumWords(CVA6Cfg.CustomVecNumWords),  // 512 64bits words --> 32 1024bits vreg
          .DataWidth(CVA6Cfg.XLEN),  // Data signal width
          .ByteWidth(32'd8),  // Width of a data byte
          .NumReadPorts(CVA6Cfg.CustomReadPorts),  // Number of read ports
          .NumWritePorts(32'd1)  // Number of write ports
      ) ariane_vecram (
          .clk_i(clk_i),    // Clock
          // input ports
          .we_i(vec_we),     // write enable
          .waddr_i(vec_waddr),  // request address
          .wdata_i(vec_wdata),  // write data
          .be_i(vec_be),     // write byte enable
          .raddr_i(vec_raddr),  // read address
          // input  logic  [NumReadPorts-1:0] req_i,      // request
          .rdata_o(vec_rdata) // read data
      );
    end else begin : no_vec_regfile_gen
      assign vec_rdata_o = 'b0;
    end
  endgenerate

  //Result interface
  logic      x_result_valid_o;
  logic      x_result_ready_i;
  x_result_t x_result_o;

  /*
    logic [X_ID_WIDTH-1:0]  id;
    logic [X_RFW_WIDTH-1:0] data;
    logic [4:0]             rd;
    logic                   we;
    logic                   exc;
    logic [5:0]             exccode;
  */
  // TODO: Currently we assume `cvxif_req_i.x_result_ready` always be true
  always_comb begin : result_commit_logic
    x_result_valid_o = result_valid_q;
    x_result_o = 'b0;

    x_result_o.id = instr_id_q;
    x_result_o.data = vec_rdata_q;
    x_result_o.we = result_we_q;
    // CPU will ignore `x_result_o.rd` currently
  end

  assign x_result_ready_i            = cvxif_req_i.x_result_ready;

  assign cvxif_resp_o.x_result_valid = x_result_valid_o;
  assign cvxif_resp_o.x_result       = x_result_o;

endmodule
