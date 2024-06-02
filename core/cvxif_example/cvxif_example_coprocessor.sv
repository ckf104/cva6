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

// TODO: read / write hazard detection

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
  assign cvxif_resp_o.x_issue_ready = x_issue_ready_o;
  assign cvxif_resp_o.x_issue_resp  = x_issue_resp_o;

  custom_vec_op_e decoded_op;
  vlen_t          decoded_vlen;

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
      .instr_op_o    (decoded_op),
      .vlen_o        (decoded_vlen)
  );

  typedef enum logic {
    IDLE,
    WORKING
  } state_e;

  state_e state_d, state_q;

  logic fired_new_instr;
  logic new_calc_instr;
  assign fired_new_instr = x_issue_resp_o.accept;
  assign new_calc_instr  = fired_new_instr && decoded_op != MV_V_X && decoded_op != MV_X_V;

  logic inst_done;

  always_comb begin : state_machine
    state_d = state_q;
    if (state_q == IDLE && new_calc_instr) begin
      state_d = WORKING;
    end else if (state_q == WORKING && inst_done) begin
      state_d = IDLE;
    end
  end
  assign x_issue_ready_o = state_q == IDLE;

  ///////////////////////////////////////////////////
  //    Vector Register File Read / Write Logic    //
  ///////////////////////////////////////////////////

  localparam int unsigned log2WordNumberOneReg = $clog2(CVA6Cfg.CustomVecNumWords / 32);
  localparam logic [log2WordNumberOneReg-1:0] PrefixZero = 'b0;

  typedef logic [$clog2(cva6_config_pkg::CVA6CustomVecNumWords)-1:0] vec_addr_t;
  typedef logic [cva6_config_pkg::CVA6ConfigXlen-1:0] vec_data_t;
  typedef logic [(cva6_config_pkg::CVA6ConfigXlen/8)-1:0] vec_be_t;
  logic vec_we;  // write enable
  vec_addr_t vec_waddr, vec_waddr_d, vec_waddr_q;  // request address
  vec_data_t vec_wdata;  // write data
  vec_be_t   vec_be;  // write byte enable

  vec_addr_t tmp_wt_complete_addr, tmp_rd_complete_addr;
  // Concatenate {rd, rs2} for MV_X_V, rd specify reg number, rs2 specify word number
  assign tmp_wt_complete_addr = {
    x_issue_req_i.instr[11:7], x_issue_req_i.instr[20+log2WordNumberOneReg-1:20]
  };
  // Concatenate {rs1, rs2} for MV_V_X, rs1 specify reg number, rs2 specify word number
  assign tmp_rd_complete_addr = {
    x_issue_req_i.instr[19:15], x_issue_req_i.instr[20+log2WordNumberOneReg-1:20]
  };

  logic blk_write_ready, blk_write_ack;
  vec_data_t blk_write_data;
  assign blk_write_ready = state_q == WORKING;

  always_comb begin : vrf_write
    vec_we = 1'b0;
    if (fired_new_instr && decoded_op == MV_X_V) vec_we = 1'b1;
    else if (blk_write_ack) vec_we = 1'b1;

    vec_waddr_d = vec_waddr_q;
    vec_waddr   = vec_waddr_q;
    if (new_calc_instr) begin
      vec_waddr_d = {x_issue_req_i.instr[11:7], PrefixZero};
    end else if (fired_new_instr && decoded_op == MV_X_V) begin
      vec_waddr = tmp_wt_complete_addr;
    end else if (blk_write_ack) begin
      vec_waddr_d = vec_waddr_q + 1;
    end

    vec_be = {$size(vec_be) {1'b1}};

    vec_wdata = x_issue_req_i.rs[0];
    if (blk_write_ack) vec_wdata = blk_write_data;
  end

  vec_addr_t [CVA6Cfg.CustomReadPorts-1:0] vec_raddr_d, vec_raddr_q;  // read address
  vec_data_t [CVA6Cfg.CustomReadPorts-1:0] vec_rdata_d, vec_rdata_q;  // read out data

  vlen_t [CVA6Cfg.CustomReadPorts-1:0] vlen_d, vlen_q;
  logic [CVA6Cfg.CustomReadPorts-1:0] rdata_valid;

  logic [CVA6Cfg.CustomReadPorts-1:0] blkbox_read_ack;

  always_comb begin : vrf_read
    vlen_d = vlen_q;
    vec_raddr_d = vec_raddr_q;

    if (new_calc_instr) begin
      vec_raddr_d[0] = {x_issue_req_i.instr[19:15], PrefixZero};  // rs1
      vec_raddr_d[1] = {x_issue_req_i.instr[24:20], PrefixZero};  // rs2
      for (int i = 0; i < CVA6Cfg.CustomReadPorts; i++) begin
        vlen_d[i] = decoded_vlen;
      end
    end else if (fired_new_instr) begin
      vec_raddr_d[0] = tmp_rd_complete_addr;
    end

    for (int i = 0; i < CVA6Cfg.CustomReadPorts; i++) begin
      rdata_valid[i] = vlen_q[i] != 'b0;
      if (blkbox_read_ack[i]) begin
        vlen_d[i] = vlen_q[i] - 1;
        vec_raddr_d[i] = vec_raddr_q[i] + 1;
      end
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
          .raddr_i(vec_raddr_d),  // read address
          // input  logic  [NumReadPorts-1:0] req_i,      // request
          .rdata_o(vec_rdata_d) // read data
      );
    end else begin : no_vec_regfile_gen
      assign vec_rdata_d = 'b0;
    end
  endgenerate

  /*
    logic [X_ID_WIDTH-1:0]  id;
    logic [X_RFW_WIDTH-1:0] data;
    logic [4:0]             rd;
    logic                   we;
    logic                   exc;
    logic [5:0]             exccode;
  */
  ////////////////////////////////////
  ////// Result Commit Logic /////////
  ////////////////////////////////////

  //Result interface
  logic      x_result_valid_o;
  logic      x_result_ready_i;
  x_result_t x_result_o;

  logic result_valid_q, result_valid_d;
  logic result_we_q, result_we_d;
  logic [X_ID_WIDTH-1:0] instr_id_q, instr_id_d;

  always_comb begin : result_commit_logic
    result_we_d = 1'b0;
    if (fired_new_instr && decoded_op == MV_V_X) result_we_d = 1'b1;

    result_valid_d = 1'b0;
    if (fired_new_instr && !new_calc_instr) result_valid_d = 1'b1;
    else if (inst_done) result_valid_d = 1'b1;

    instr_id_d = instr_id_q;
    if (fired_new_instr) instr_id_d = x_issue_req_i.id;

    x_result_valid_o = result_valid_q;
    x_result_o = 'b0;
    x_result_o.id = instr_id_q;
    x_result_o.data = vec_rdata_q[0];
    x_result_o.we = result_we_q;
    // CPU will ignore `x_result_o.rd` currently
  end

  assign x_result_ready_i            = cvxif_req_i.x_result_ready;

  assign cvxif_resp_o.x_result_valid = x_result_valid_o;
  assign cvxif_resp_o.x_result       = x_result_o;

  ///////////////
  // Black Box //
  ///////////////

  logic inst_ready;  // The module can accept new instruction
  logic inst_start_d, inst_start_q;
  logic blkbox_idle;  // debug only

  always_comb begin : inst_exec_control
    inst_start_d = inst_start_q;
    if (new_calc_instr) begin
      inst_start_d = 1'b1;
    end else if (inst_ready) begin
      inst_start_d = 1'b0;
    end
  end

  uint64_vadd64b2w blackbox (
      .ap_clk(clk_i),
      .ap_rst_n(rst_ni),
      .ap_start(inst_start_d),
      .ap_done(inst_done),
      .ap_idle(blkbox_idle),
      .ap_ready(inst_ready),
      .in1_dout(vec_rdata_q[0]),
      .in1_empty_n(rdata_valid[0]),
      .in1_read(blkbox_read_ack[0]),
      .in2_dout(vec_rdata_q[1]),
      .in2_empty_n(rdata_valid[1]),
      .in2_read(blkbox_read_ack[1]),
      .out_r_din(blk_write_data),
      .out_r_full_n(blk_write_ready),
      .out_r_write(blk_write_ack)
  );


  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      // Don't need to reset `vec_rdata_q`
      // Don't need to reset `result_we_q`
      // Don't need to reset `instr_id_q`
      // Don't need to reset `vec_raddr_q`
      // Don't need to reset `vec_waddr_q`
      result_valid_q <= 1'b0;
      state_q <= IDLE;
      inst_start_q <= 1'b0;
      vlen_q <= 'b0;
    end else begin
      result_valid_q <= result_valid_d;
      result_we_q <= result_we_d;
      instr_id_q <= instr_id_d;
      state_q <= state_d;

      vec_rdata_q <= vec_rdata_d;
      vec_raddr_q <= vec_raddr_d;
      vec_waddr_q <= vec_waddr_d;
      vlen_q <= vlen_d;

      inst_start_q <= inst_start_d;
    end
  end

endmodule
