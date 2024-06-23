module custom_inst_cva6_top
  import ariane_axi_soc::*;
#(
    parameter config_pkg::cva6_cfg_t CVA6Cfg = build_config_pkg::build_config(
        cva6_config_pkg::cva6_cfg
    ),
    //
    parameter int unsigned AXI_USER_EN = CVA6Cfg.AXI_USER_EN,
    parameter int unsigned NUM_WORDS = 2 ** 25  // memory size
) (
    input logic clk_i,
    input logic rst_ni
);
  logic [31:0] src_width;
  logic [31:0] src_height;
  logic [31:0] src_offset_addr;
  logic [31:0] src_image_size;
  logic [31:0] dst_width;
  logic [31:0] dst_height;
  logic [31:0] dst_offset_addr;
  logic [31:0] dst_image_size;
  logic        start;
  logic        idle;
  logic [31:0] exit;

`ifdef VERILATOR

  initial begin
    exit = 'b0;
  end

`endif

  always @(posedge clk_i) begin
    if (exit != 0) begin
      if (exit != 1) begin
        $display("Exit signal is non-zero: %d. Time: %d", exit, $time);
        $stop;
      end else begin
        $finish;
      end
    end
    if ($time > 100000) begin
      $display("Timeout", $time);
      $stop;
    end
  end

  always_comb begin
    src_width       = 'd16;
    src_height      = 'd12;
    src_offset_addr = 'h3800_0000;
    src_image_size  = 'h0;
    dst_width       = 'd8;
    dst_height      = 'd6;
    dst_offset_addr = 'h3c00_0000;
    dst_image_size  = 'h0;
  end

  logic [4:0] counter;
  logic signal_out;

  always_comb begin
    start = 0;
    if (signal_out && idle) begin
      start = 1;
    end
  end

  always @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      counter <= 5'b0;
      signal_out <= 1'b0;
    end else if (counter == 5'b10100) begin  // 20 in binary
      counter <= 5'b0;
      signal_out <= ~signal_out;
    end else begin
      counter <= counter + 1;
    end
  end



  /////////////////
  // Fake EXTDDR //
  /////////////////

  logic [IdWidthSlave-1:0] m_axi_arid;
  logic [   AddrWidth-1:0] m_axi_araddr;
  logic [             7:0] m_axi_arlen;
  logic [             2:0] m_axi_arsize;
  logic [             1:0] m_axi_arburst;
  logic                    m_axi_arvalid;
  logic                    m_axi_arready;
  // R channel
  logic [IdWidthSlave-1:0] m_axi_rid;
  logic [   DataWidth-1:0] m_axi_rdata;
  logic                    m_axi_rlast;
  logic [             1:0] m_axi_rresp;
  logic                    m_axi_rvalid;
  logic                    m_axi_rready;
  // AW channel
  logic [IdWidthSlave-1:0] m_axi_awid;
  logic [   AddrWidth-1:0] m_axi_awaddr;
  logic [             7:0] m_axi_awlen;
  logic [             2:0] m_axi_awsize;
  logic [             1:0] m_axi_awburst;
  logic                    m_axi_awvalid;
  logic                    m_axi_awready;
  // W channel
  logic [ DataWidth/8-1:0] m_axi_wstrb;
  logic [   DataWidth-1:0] m_axi_wdata;
  logic                    m_axi_wlast;
  logic                    m_axi_wvalid;
  logic                    m_axi_wready;
  // B channel
  logic [IdWidthSlave-1:0] m_axi_bid;
  logic [             1:0] m_axi_bresp;
  logic                    m_axi_bvalid;
  logic                    m_axi_bready;

  AXI_BUS #(
      .AXI_ADDR_WIDTH(AddrWidth),
      .AXI_DATA_WIDTH(DataWidth),
      .AXI_ID_WIDTH  (ariane_axi_soc::IdWidthSlave),
      .AXI_USER_WIDTH(UserWidth)
  ) slave ();

  logic                   ram_req;
  logic                   ram_we;
  logic [DataWidth/8-1:0] ram_be;
  logic [  AddrWidth-1:0] ram_addr;
  logic [  DataWidth-1:0] ram_rdata;
  logic [  DataWidth-1:0] ram_wdata;
  logic [  UserWidth-1:0] ram_wuser;
  logic [  UserWidth-1:0] ram_ruser;

  axi2mem #(
      .AXI_ID_WIDTH  (ariane_axi_soc::IdWidthSlave),
      .AXI_ADDR_WIDTH(AddrWidth),
      .AXI_DATA_WIDTH(DataWidth),
      .AXI_USER_WIDTH(UserWidth)
  ) axi2ram (
      .clk_i (clk_i),
      .rst_ni(rst_ni),
      .slave (slave),
      .req_o (ram_req),
      .we_o  (ram_we),
      .addr_o(ram_addr),
      .be_o  (ram_be),
      .user_o(ram_wuser),
      .data_o(ram_wdata),
      .user_i(ram_ruser),
      .data_i(ram_rdata)
  );

  sram #(
      .DATA_WIDTH(DataWidth),
      .USER_WIDTH(UserWidth),
      .USER_EN   (AXI_USER_EN),
`ifdef VERILATOR
      .SIM_INIT  ("none"),
`else
      .SIM_INIT  ("zeros"),
`endif
      .NUM_WORDS (NUM_WORDS)
  ) i_sram (
      .clk_i  (clk_i),
      .rst_ni (rst_ni),
      .req_i  (ram_req),
      .we_i   (ram_we),
      .addr_i (ram_addr[$clog2(NUM_WORDS)-1+$clog2(DataWidth/8):$clog2(DataWidth/8)]),
      .wuser_i(ram_wuser),
      .wdata_i(ram_wdata),
      .be_i   (ram_be),
      .ruser_o(ram_ruser),
      .rdata_o(ram_rdata)
  );

  always @(posedge clk_i) begin
    if (ram_we && ram_req && ram_addr >= dst_offset_addr) begin
      $display("EXTDDR Write: Addr=%0x, Data=%0x, BE=%0x", ram_addr, ram_wdata, ram_be);
    end
  end

  axi_mst_join #(
      .IdWidthSlave(IdWidthSlave),
      .DataWidth(DataWidth),
      .AddrWidth(AddrWidth)
  ) axi_mst_join_inst (
      .mst_port(slave),
      // AR channel
      .m_axi_arid(m_axi_arid),
      .m_axi_araddr(m_axi_araddr),
      .m_axi_arlen(m_axi_arlen),
      .m_axi_arsize(m_axi_arsize),
      .m_axi_arburst(m_axi_arburst),
      .m_axi_arvalid(m_axi_arvalid),
      .m_axi_arready(m_axi_arready),
      // R channel
      .m_axi_rid(m_axi_rid),
      .m_axi_rdata(m_axi_rdata),
      .m_axi_rlast(m_axi_rlast),
      .m_axi_rresp(m_axi_rresp),
      .m_axi_rvalid(m_axi_rvalid),
      .m_axi_rready(m_axi_rready),
      // AW channel
      .m_axi_awid(m_axi_awid),
      .m_axi_awaddr(m_axi_awaddr),
      .m_axi_awlen(m_axi_awlen),
      .m_axi_awsize(m_axi_awsize),
      .m_axi_awburst(m_axi_awburst),
      .m_axi_awvalid(m_axi_awvalid),
      .m_axi_awready(m_axi_awready),
      // W channel
      .m_axi_wstrb(m_axi_wstrb),
      .m_axi_wdata(m_axi_wdata),
      .m_axi_wlast(m_axi_wlast),
      .m_axi_wvalid(m_axi_wvalid),
      .m_axi_wready(m_axi_wready),
      // B channel
      .m_axi_bid(m_axi_bid),
      .m_axi_bresp(m_axi_bresp),
      .m_axi_bvalid(m_axi_bvalid),
      .m_axi_bready(m_axi_bready)
  );

  custom_inst_cva6_with_reg #(
      .CVA6Cfg(CVA6Cfg),
      .AXI_USER_EN(AXI_USER_EN)
  ) cva6 (
      .clk_i          (clk_i),
      .rst_ni         (rst_ni),
      .src_width      (src_width),
      .src_height     (src_height),
      .src_offset_addr(src_offset_addr),
      .src_image_size (src_image_size),
      .dst_width      (dst_width),
      .dst_height     (dst_height),
      .dst_offset_addr(dst_offset_addr),
      .dst_image_size (dst_image_size),
      .start          (start),
      .idle           (idle),
      .exit           (exit),
      .m_axi_arid     (m_axi_arid),
      .m_axi_araddr   (m_axi_araddr),
      .m_axi_arlen    (m_axi_arlen),
      .m_axi_arsize   (m_axi_arsize),
      .m_axi_arburst  (m_axi_arburst),
      .m_axi_arvalid  (m_axi_arvalid),
      .m_axi_arready  (m_axi_arready),
      .m_axi_rid      (m_axi_rid),
      .m_axi_rdata    (m_axi_rdata),
      .m_axi_rlast    (m_axi_rlast),
      .m_axi_rresp    (m_axi_rresp),
      .m_axi_rvalid   (m_axi_rvalid),
      .m_axi_rready   (m_axi_rready),
      .m_axi_awid     (m_axi_awid),
      .m_axi_awaddr   (m_axi_awaddr),
      .m_axi_awlen    (m_axi_awlen),
      .m_axi_awsize   (m_axi_awsize),
      .m_axi_awburst  (m_axi_awburst),
      .m_axi_awvalid  (m_axi_awvalid),
      .m_axi_awready  (m_axi_awready),
      .m_axi_wstrb    (m_axi_wstrb),
      .m_axi_wdata    (m_axi_wdata),
      .m_axi_wlast    (m_axi_wlast),
      .m_axi_wvalid   (m_axi_wvalid),
      .m_axi_wready   (m_axi_wready),
      .m_axi_bid      (m_axi_bid),
      .m_axi_bresp    (m_axi_bresp),
      .m_axi_bvalid   (m_axi_bvalid),
      .m_axi_bready   (m_axi_bready)
  );

endmodule
