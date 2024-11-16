{{ comments }}

// Outer logic should record whether this group is busy.
module {{ group_name }} #(
  parameter int unsigned numInputReg,
  parameter int unsigned numOutputReg,
  parameter int unsigned inputWidth,
  parameter int unsigned outputWidth,

  // local parameter
  parameter type in_data_t  = logic [          inputWidth-1:0],
  parameter type out_data_t = logic [         outputWidth-1:0],
  parameter type in_idx_t   = logic [$clog2(numInputReg == 1 ? 2 : numInputReg)-1:0],
  parameter type out_idx_t  = logic [$clog2(numOutputReg == 1 ? 2 : numOutputReg)-1:0]
) (
  input logic clk_i,
  input logic rst_ni,

  input logic exec_i,  // Is exec valid?

  input  logic            in_data_vld_i,  // Is fill valid?
  input  in_idx_t         in_idx_i,       // input data index
  input  in_data_t  [1:0] in_data_i,
  input  out_idx_t        out_idx_i,      // output data index
  output out_data_t       out_data_o,
  output logic            done_o
);

  in_data_t [numInputReg-1:0] in_data_q, in_data_d;
  out_data_t [numOutputReg-1:0] out_data_q, out_data_d, out_data;

  out_idx_t out_idx_q, out_idx_d;  // Record which index will be picked by execution

  logic exec_q, exec_d;
  // control signal of ap_ctrl_hs protocol
  logic ap_start, ap_done, ap_idle, ap_ready;

  always_comb begin : block_control
    ap_start = exec_q;
    if (ap_ready) begin
      ap_start = 1'b0;
    end

    exec_d = exec_q;
    if (ap_done) begin
      exec_d = 1'b0;
    end
    if (exec_i) begin
      exec_d = 1'b1;
    end

    done_o = ap_done;
  end

  always_comb begin : input_output
    for (int unsigned i = 0; i < numOutputReg; i++) begin
      out_data_d[i] = ap_done ? out_data[i] : out_data_q[i];
    end

    for (int unsigned i = 0; i < numInputReg; i++) begin
      in_data_d[i] = in_data_q[i];
    end

    if (in_data_vld_i) begin
      in_data_d[in_idx_i] = in_data_i[0];
      if (in_idx_i != numInputReg - 1) begin
        in_data_d[in_idx_i+1] = in_data_i[1];
      end
    end

    out_data_o = ap_done ? out_data_d[out_idx_q] : out_data_d[out_idx_i];

    out_idx_d  = exec_i ? out_idx_i : out_idx_q;
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin : regs_update
    if (!rst_ni) begin
      // Do not need to reset the input, output data
      // Do not need to reset `out_idx_q`
      exec_q <= '0;
    end else begin
      in_data_q  <= in_data_d;
      out_data_q <= out_data_d;
      exec_q     <= exec_d;
      out_idx_q  <= out_idx_d;
    end
  end

  {{ top_module_name }} blackbox (
    .ap_clk(clk_i),
    .ap_rst_n(rst_ni),
    .ap_start(ap_start),
    .ap_done(ap_done),
    .ap_idle(ap_idle),
    .ap_ready(ap_ready),
  {% for i in range(numInputReg) %}
    .in{{ i+1 }}(in_data_q[{{ i }}]),
  {% endfor %}
  {% for i in range(numOutputReg-1) %}
    .out{{ i+1 }}(out_data[{{ i }}]),
  {% endfor %}
    .out{{ numOutputReg }}(out_data[{{ numOutputReg-1}}])
  );
endmodule