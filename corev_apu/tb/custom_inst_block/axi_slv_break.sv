module axi_slv_break #(
    parameter int unsigned IdWidthSlave = 1,
    parameter int unsigned DataWidth = 32,
    parameter int unsigned AddrWidth = 32
) (
    AXI_BUS.Slave slv_port,

    // AR channel
    output [IdWidthSlave-1:0] m_axi_arid,
    output [   AddrWidth-1:0] m_axi_araddr,
    output [             7:0] m_axi_arlen,
    output [             2:0] m_axi_arsize,
    output [             1:0] m_axi_arburst,
    output                    m_axi_arvalid,
    input                     m_axi_arready,
    // R channel
    input  [IdWidthSlave-1:0] m_axi_rid,
    input  [   DataWidth-1:0] m_axi_rdata,
    input                     m_axi_rlast,
    input  [             1:0] m_axi_rresp,
    input                     m_axi_rvalid,
    output                    m_axi_rready,
    // AW channel
    output [IdWidthSlave-1:0] m_axi_awid,
    output [   AddrWidth-1:0] m_axi_awaddr,
    output [             7:0] m_axi_awlen,
    output [             2:0] m_axi_awsize,
    output [             1:0] m_axi_awburst,
    output                    m_axi_awvalid,
    input                     m_axi_awready,
    // W channel
    output [   DataWidth-1:0] m_axi_wdata,
    output [ DataWidth/8-1:0] m_axi_wstrb,
    output                    m_axi_wlast,
    output                    m_axi_wvalid,
    input                     m_axi_wready,
    // B channel
    input  [IdWidthSlave-1:0] m_axi_bid,
    input  [             1:0] m_axi_bresp,
    input                     m_axi_bvalid,
    output                    m_axi_bready
);
  // AR channel
  assign m_axi_arid = slv_port.ar_id;
  assign m_axi_araddr = slv_port.ar_addr;
  assign m_axi_arlen = slv_port.ar_len;
  assign m_axi_arsize = slv_port.ar_size;
  assign m_axi_arburst = slv_port.ar_burst;
  assign m_axi_arvalid = slv_port.ar_valid;
  assign slv_port.ar_ready = m_axi_arready;

  // R channel
  assign slv_port.r_id = m_axi_rid;
  assign slv_port.r_data = m_axi_rdata;
  assign slv_port.r_last = m_axi_rlast;
  assign slv_port.r_resp = m_axi_rresp;
  assign slv_port.r_valid = m_axi_rvalid;
  assign slv_port.r_user = 'b0;
  assign m_axi_rready = slv_port.r_ready;

  // AW channel
  assign m_axi_awid = slv_port.aw_id;
  assign m_axi_awaddr = slv_port.aw_addr;
  assign m_axi_awlen = slv_port.aw_len;
  assign m_axi_awsize = slv_port.aw_size;
  assign m_axi_awburst = slv_port.aw_burst;
  assign m_axi_awvalid = slv_port.aw_valid;
  assign slv_port.aw_ready = m_axi_awready;

  // W channel
  assign m_axi_wstrb = slv_port.w_strb;
  assign m_axi_wdata = slv_port.w_data;
  assign m_axi_wlast = slv_port.w_last;
  assign m_axi_wvalid = slv_port.w_valid;
  assign slv_port.w_ready = m_axi_wready;

  // B channel
  assign slv_port.b_id = m_axi_bid;
  assign slv_port.b_resp = m_axi_bresp;
  assign slv_port.b_valid = m_axi_bvalid;
  assign slv_port.b_user = 'b0;
  assign m_axi_bready = slv_port.b_ready;

endmodule
