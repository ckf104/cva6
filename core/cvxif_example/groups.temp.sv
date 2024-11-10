{{ comments }}

// Outer logic should not assert xx_vld_i and exec_i if `busy_o` is asserted.
module groups
  import cvxif_instr_pkg::*;
  import cvxif_pkg::*;
#(
  parameter type instr_id_t = logic [X_ID_WIDTH-1:0],

  parameter int unsigned inputWidth,
  parameter int unsigned outputWidth,
  parameter int unsigned opocdeWidth,
  parameter int unsigned inputIndexWidth,
  parameter int unsigned outputIndexWidth,

  parameter type opcode_t   = logic [     opocdeWidth-1:0],
  parameter type in_data_t  = logic [      inputWidth-1:0],
  parameter type out_data_t = logic [     outputWidth-1:0],
  parameter type in_idx_t   = logic [ inputIndexWidth-1:0],
  parameter type out_idx_t  = logic [outputIndexWidth-1:0]
) (
  input logic clk_i,
  input logic rst_ni,

  input logic      exec_i,     // Fire execution
  input opcode_t   opcode_i,   // Instruction opcode
  input instr_id_t instr_id_i, // Instruction id

  input logic           in_data_vld_i,  // Is fill valid?
  input in_idx_t        in_idx_i,       // input data index
  input in_data_t [1:0] in_data_i,

  input  logic      out_data_vld_i,  // Is pick valid?
  input  out_idx_t  out_idx_i,       // output data index
  output logic      invalid_instr_o, // Whether the instruction is invalid
  output out_data_t out_data_o,
  output instr_id_t instr_id_o,
  output logic      done_o,          // execution of one instruction is done and can be written back
  output logic      busy_o            // Whether we can accept this new instruction, depend on opcode    
);
  localparam int numGroup = {{ var.numGroup }};
  localparam int unsigned opcodeToGroup[numGroup:0] = {{ var.opcodeToGroup }};

  logic [        numGroup-1:0] onehot_vld;  // one hot valid encoding
  logic [$clog2(numGroup == 1 ? 2 : numGroup)-1:0] vld_group_id;  // valid group id for this instruction
  logic [numGroup-1:0] in_data_vld, out_data_vld;  // one hot valid for input/output data
  logic [numGroup-1:0] exec_vld;  // one hot valid for execution

  always_comb begin : vld_group
    vld_group_id = 'b0;
    for (int unsigned i = 0; i < numGroup; ++i) begin
      onehot_vld[i]   = (opcode_i >= opcodeToGroup[i]) && (opcode_i < opcodeToGroup[i+1]);
      in_data_vld[i]  = onehot_vld[i] && in_data_vld_i;
      out_data_vld[i] = onehot_vld[i] && out_data_vld_i;
      exec_vld[i]     = onehot_vld[i] && exec_i;

      if (onehot_vld[i]) vld_group_id = i;
    end
  end

  assign invalid_instr_o = opcode_i >= opcodeToGroup[numGroup];

  // Only one group can commit its output at each cycle, so we need additional `buf_q` to
  // hold the output data. `can_writeback_gnt` is used to indicate whether the group can writeback
  logic [numGroup-1:0] done, can_writeback_gnt;

  typedef struct packed {
    out_data_t out_data;
    instr_id_t instr_id;
  } buffer_data_t;

  buffer_data_t [numGroup-1:0] buf_q, buf_d;
  out_data_t [numGroup-1:0] out_data;
  logic [numGroup-1:0] buf_vld_q, buf_vld_d;

  // Pick/Fill without exec will be done immediately, so give it highest priority
  logic is_pick_fill_without_exec;
  assign is_pick_fill_without_exec = !exec_i && (out_data_vld_i || in_data_vld_i);

  logic arb_out_req;
  buffer_data_t arb_buf;

  rr_arb_tree #(
    .NumIn   (numGroup),
    .DataType(buffer_data_t)
  ) i_rr_arb_tree (
    .clk_i  (clk_i),
    .rst_ni (rst_ni),
    .flush_i('0),
    .rr_i   ('0),
    .req_i  (buf_vld_q),
    .gnt_o  (can_writeback_gnt),
    .data_i (buf_q),
    .gnt_i  (!is_pick_fill_without_exec),
    .req_o  (arb_out_req),
    .data_o (arb_buf),
    .idx_o  ()
  );

  // To simplify our logic, we will buffer each group's output data before output to cva6.
  always_comb begin : buffer_out_data
    for (int unsigned i = 0; i < numGroup; i++) begin
      buf_d[i]     = buf_q[i];
      buf_vld_d[i] = buf_vld_q[i];

      if (can_writeback_gnt[i] && buf_vld_q[i]) begin
        buf_vld_d[i] = 1'b0;
      end
      if (done[i]) begin
        buf_vld_d[i]      = 1'b1;
        buf_d[i].out_data = out_data[i];
      end

      if (exec_vld[i]) begin
        buf_d[i].instr_id = instr_id_i;
      end
    end

    out_data_o = is_pick_fill_without_exec ? out_data[vld_group_id] : arb_buf.out_data;
    instr_id_o = is_pick_fill_without_exec ? instr_id_i : arb_buf.instr_id;
    // we can commit a execution if req/grant handshake succeed
    done_o = arb_out_req && !is_pick_fill_without_exec;
  end

  logic [numGroup-1:0] busy_q, busy_d, busy;

  always_comb begin : acc_or_busy
    busy_d = busy_q;
    for (int unsigned i = 0; i < numGroup; i++) begin
      if(can_writeback_gnt[i] && buf_vld_q[i]) begin
        busy_d[i] = 1'b0;
      end  
      if (exec_vld[i]) begin
        busy_d[i] = 1'b1;
      end
    end

    busy_o = '0;
    for (int unsigned i = 0; i < numGroup; i++) begin
      busy_o = busy_o || (onehot_vld[i] && busy_q[i]);
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin : regs_update
    if (!rst_ni) begin
      // Do not need to reset `buf_q`
      buf_vld_q <= 'b0;
      busy_q    <= 'b0;
    end else begin
      buf_vld_q <= buf_vld_d;
      buf_q     <= buf_d;
      busy_q    <= busy_d;
    end
  end

  localparam int unsigned groupInputRegs[numGroup-1:0] = {{ var.groupInputRegs }};
  localparam int unsigned groupOutputRegs[numGroup-1:0] = {{ var.groupOutputRegs }};

  // generate
  //   genvar i;
  //   for (i = 0; i < numGroup; i++) begin
  //     group #(
  //       .numInputReg (groupInputRegs[i]),
  //       .numOutputReg(groupOutputRegs[i]),
  //       .inputWidth  (inputWidth),
  //       .outputWidth (outputWidth),
  //       .opocdeWidth (opocdeWidth)
  //     ) group_inst (
  //       .clk_i        (clk_i),
  //       .rst_ni       (rst_ni),
  //       .exec_i       (exec_vld[i]),
  //       .opcode_i     (opcode_i),
  //       .in_data_vld_i(in_data_vld[i]),
  //       .in_idx_i     (in_idx_i),
  //       .in_data_i    (in_data_i),
  //       .out_idx_i    (out_idx_i),
  //       .out_data_o   (out_data[i]),
  //       .done_o       (done[i])
  //     );
  //   end
  // endgenerate

  {% for group_name in var.groupNames %}
      {{ group_name }} #(
        .numInputReg (groupInputRegs[{{ loop.index0 }}]),
        .numOutputReg(groupOutputRegs[{{ loop.index0 }}]),
        .inputWidth  (inputWidth),
        .outputWidth (outputWidth),
        .opocdeWidth (opocdeWidth)
      ) group_inst_{{ loop.index0 }} (
        .clk_i        (clk_i),
        .rst_ni       (rst_ni),
        .exec_i       (exec_vld[{{ loop.index0 }}]),
        .opcode_i     (opcode_i),
        .in_data_vld_i(in_data_vld[{{ loop.index0 }}]),
        .in_idx_i     ({in_idx_i, 1'b0}),
        .in_data_i    (in_data_i),
        .out_idx_i    (out_idx_i),
        .out_data_o   (out_data[{{ loop.index0 }}]),
        .done_o       (done[{{ loop.index0 }}])
      );
  {% endfor %}

endmodule

