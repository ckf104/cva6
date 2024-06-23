module ctrlreg
  import ariane_axi_soc::*;
#(

) (
    input  logic        clk_i,
    input  logic        rst_ni,
    input  logic [31:0] src_width,        // offset 0
    input  logic [31:0] src_height,       // offset 4
    input  logic [31:0] src_offset_addr,  // offset 8
    input  logic [31:0] src_image_size,   // offset 12
    input  logic [31:0] dst_width,        // offset 16
    input  logic [31:0] dst_height,       // offset 20
    input  logic [31:0] dst_offset_addr,  // offset 24
    input  logic [31:0] dst_image_size,   // offset 28
    input  logic        start,            //  offset 32
    output logic        idle,             // offset 36
    output logic [31:0] exit,             // offset 40

    input  logic                 ctrlreg_req,
    input  logic                 ctrlreg_we,
    input  logic [AddrWidth-1:0] ctrlreg_addr,
    input  logic [DataWidth-1:0] ctrlreg_wdata,
    output logic [DataWidth-1:0] ctrlreg_rdata
);
  logic start_d, start_q, prev_start_q;
  logic idle_d, idle_q;
  logic [31:0] exit_d, exit_q;

`ifdef VERILATOR

  initial begin
    exit_q = 'b0;
  end

`endif

  logic [31:0] rdata_d, rdata_q;

  always_comb begin : read_reg
    start_d = start_q;
    idle_d  = idle_q;
    exit_d  = 'b0;
    if (!prev_start_q && start) begin
      start_d = 1'b1;  // detect posedge
      idle_d  = 1'b0;
    end
    // We provide 64bits for upper C program since partial AXI write is not
    // supported by axi2mem.
    if (ctrlreg_req && ctrlreg_we && ctrlreg_addr[9:3] == 'd9) begin
      idle_d = 1'b1;
    end
    if (ctrlreg_req && ctrlreg_we && ctrlreg_addr[9:3] == 'd10) begin
      exit_d = ctrlreg_wdata[31:0];
    end

    case (ctrlreg_addr[9:3])
      'd0: rdata_d = src_width;
      'd1: rdata_d = src_height;
      'd2: rdata_d = src_offset_addr;
      'd3: rdata_d = src_image_size;
      'd4: rdata_d = dst_width;
      'd5: rdata_d = dst_height;
      'd6: rdata_d = dst_offset_addr;
      'd7: rdata_d = dst_image_size;
      'd8: begin
        rdata_d = start_q;
        // Reset start_q after reading
        if (start_q == 1'b1 && ctrlreg_req) start_d = 1'b0;
      end
      default: rdata_d = 'b0;
    endcase
  end

  // Delay a cycle to satisfy axi2mem's timing
  assign ctrlreg_rdata = rdata_q;
  assign idle = idle_q;
  assign exit = exit_q;

  always_ff @(posedge clk_i) begin
    rdata_q <= rdata_d;
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      prev_start_q <= 'b0;
      start_q <= 'b0;
      exit_q <= 'b0;
      idle_q <= 'b1;
    end else begin
      prev_start_q <= start;
      start_q <= start_d;
      exit_q <= exit_d;
      idle_q <= idle_d;
    end

  end


endmodule
