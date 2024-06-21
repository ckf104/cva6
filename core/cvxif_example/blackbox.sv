

module blackbox
  import cvxif_instr_pkg::*;
(
    input  logic        ap_clk,
    input  logic        ap_rst_n,
    input  logic        ap_start,
    output logic        ap_done,
    output logic        ap_idle,
    output logic        ap_ready,
    input  logic [63:0] in1_dout,
    input  logic        in1_empty_n,
    output logic        in1_read,
    input  logic [63:0] in2_dout,
    input  logic        in2_empty_n,
    output logic        in2_read,
    output logic [63:0] out_r_din,
    input  logic        out_r_full_n,
    output logic        out_r_write,

    input custom_vec_op_e opcode,
    input logic           fire
);
  custom_vec_op_e opcode_d, opcode_q;
  assign opcode_d = fire ? opcode : opcode_q;
  always_ff @(posedge ap_clk or negedge ap_rst_n) begin
    if (!ap_rst_n) begin
      opcode_q <= custom_vec_op_e'(0);
    end else begin
      opcode_q <= opcode_d;
    end
  end

  logic [NumCustomInst-1:0] inst_ap_start;

  logic [NumCustomInst-1:0] inst_ap_done;
  logic [NumCustomInst-1:0] inst_ap_idle;
  logic [NumCustomInst-1:0] inst_ap_ready;
  logic [NumCustomInst-1:0] inst_in1_read;
  logic [NumCustomInst-1:0] inst_in2_read;
  logic [NumCustomInst-1:0] inst_out_r_write;
  logic [NumCustomInst-1:0][63:0] inst_out_r_din;

  logic [NumCustomInst-1:0] inst_in1_empty_n;
  logic [NumCustomInst-1:0] inst_in2_empty_n;

  always_comb begin
    inst_ap_done[MV_V_X] = 'b0;
    inst_ap_idle[MV_V_X] = 'b0;
    inst_ap_ready[MV_V_X] = 'b0;
    inst_in1_read[MV_V_X] = 'b0;
    inst_in2_read[MV_V_X] = 'b0;
    inst_out_r_write[MV_V_X] = 'b0;
    inst_out_r_din[MV_V_X] = 'b0;
    inst_in1_empty_n[MV_V_X] = 'b0;
    inst_in2_empty_n[MV_V_X] = 'b0;

    inst_ap_done[MV_X_V] = 'b0;
    inst_ap_idle[MV_X_V] = 'b0;
    inst_ap_ready[MV_X_V] = 'b0;
    inst_in1_read[MV_X_V] = 'b0;
    inst_in2_read[MV_X_V] = 'b0;
    inst_out_r_write[MV_X_V] = 'b0;
    inst_out_r_din[MV_X_V] = 'b0;
    inst_in1_empty_n[MV_X_V] = 'b0;
    inst_in2_empty_n[MV_X_V] = 'b0;

    inst_in2_read[CAG444toRGB888] = 'b0;
  end

  always_comb begin
    inst_ap_start = 'b0;
    inst_in1_empty_n = 'b0;
    inst_in2_empty_n = 'b0;

    ap_done = 'b0;
    ap_idle = 'b0;
    ap_ready = 'b0;
    in1_read = 'b0;
    in2_read = 'b0;
    out_r_write = 'b0;
    out_r_din = 'b0;

    for (int i = MV_X_V + 1; i < NumCustomInst; i++) begin
      if (opcode_d == i) begin
        inst_ap_start[i] = ap_start;
        inst_in1_empty_n[i] = in1_empty_n;
        inst_in2_empty_n[i] = in2_empty_n;

        ap_done = inst_ap_done[i];
        ap_idle = inst_ap_idle[i];
        ap_ready = inst_ap_ready[i];
        in1_read = inst_in1_read[i];
        in2_read = inst_in2_read[i];
        out_r_write = inst_out_r_write[i];
        out_r_din = inst_out_r_din[i];
      end
    end
  end

  // vlen in = 2 , vlen out = 3
  t64_nv12toCAG444_k8 nv12tocag444 (
      .ap_clk       (ap_clk),
      .ap_rst_n     (ap_rst_n),
      .ap_start     (inst_ap_start[NV12toCAG444]),
      .ap_done      (inst_ap_done[NV12toCAG444]),
      .ap_idle      (inst_ap_idle[NV12toCAG444]),
      .ap_ready     (inst_ap_ready[NV12toCAG444]),
      .Yin_dout     (in1_dout),
      .Yin_empty_n  (inst_in1_empty_n[NV12toCAG444]),
      .Yin_read     (inst_in1_read[NV12toCAG444]),
      .UVin_dout    (in2_dout),
      .UVin_empty_n (inst_in2_empty_n[NV12toCAG444]),
      .UVin_read    (inst_in2_read[NV12toCAG444]),
      .YUVout_din   (inst_out_r_din[NV12toCAG444]),
      .YUVout_full_n(out_r_full_n),
      .YUVout_write (inst_out_r_write[NV12toCAG444])
  );

  // vlen in = 3, vlen out = 3, only one operator
  t64_CAG444toRGB888_k8 cag444torgb888 (
      .ap_clk       (ap_clk),
      .ap_rst_n     (ap_rst_n),
      .ap_start     (inst_ap_start[CAG444toRGB888]),
      .ap_done      (inst_ap_done[CAG444toRGB888]),
      .ap_idle      (inst_ap_idle[CAG444toRGB888]),
      .ap_ready     (inst_ap_ready[CAG444toRGB888]),
      .YUVin_dout   (in1_dout),
      .YUVin_empty_n(inst_in1_empty_n[CAG444toRGB888]),
      .YUVin_read   (inst_in1_read[CAG444toRGB888]),
      .RGBout_din   (inst_out_r_din[CAG444toRGB888]),
      .RGBout_full_n(out_r_full_n),
      .RGBout_write (inst_out_r_write[CAG444toRGB888])
  );

endmodule
