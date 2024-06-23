module axi_mst_join #(
    parameter int unsigned IdWidthSlave = 1,
    parameter int unsigned DataWidth = 32,
    parameter int unsigned AddrWidth = 32
) (
    AXI_BUS.Master mst_port,

    // AR channel
    input  [IdWidthSlave-1:0] m_axi_arid,
    input  [   AddrWidth-1:0] m_axi_araddr,
    input  [             7:0] m_axi_arlen,
    input  [             2:0] m_axi_arsize,
    input  [             1:0] m_axi_arburst,
    input                     m_axi_arvalid,
    output                    m_axi_arready,
    // R channel
    output [IdWidthSlave-1:0] m_axi_rid,
    output [   DataWidth-1:0] m_axi_rdata,
    output                    m_axi_rlast,
    output [             1:0] m_axi_rresp,
    output                    m_axi_rvalid,
    input                     m_axi_rready,
    // AW channel
    input  [IdWidthSlave-1:0] m_axi_awid,
    input  [   AddrWidth-1:0] m_axi_awaddr,
    input  [             7:0] m_axi_awlen,
    input  [             2:0] m_axi_awsize,
    input  [             1:0] m_axi_awburst,
    input                     m_axi_awvalid,
    output                    m_axi_awready,
    // W channel
    input  [   DataWidth-1:0] m_axi_wdata,
    output [ DataWidth/8-1:0] m_axi_wstrb,
    input                     m_axi_wlast,
    input                     m_axi_wvalid,
    output                    m_axi_wready,
    // B channel
    output [IdWidthSlave-1:0] m_axi_bid,
    output [             1:0] m_axi_bresp,
    output                    m_axi_bvalid,
    input                     m_axi_bready
);

  // AR channel
  assign mst_port.ar_id = m_axi_arid;
  assign mst_port.ar_addr = m_axi_araddr;
  assign mst_port.ar_len = m_axi_arlen;
  assign mst_port.ar_size = m_axi_arsize;
  assign mst_port.ar_burst = m_axi_arburst;
  assign mst_port.ar_valid = m_axi_arvalid;
  assign mst_port.ar_lock = 'b0;
  assign mst_port.ar_cache = 'b0;
  assign mst_port.ar_prot = 'b0;
  assign mst_port.ar_qos = 'b0;
  assign mst_port.ar_region = 'b0;
  assign mst_port.ar_user = 'b0;
  assign m_axi_arready = mst_port.ar_ready;

  // R channel
  assign m_axi_rid = mst_port.r_id;
  assign m_axi_rdata = mst_port.r_data;
  assign m_axi_rlast = mst_port.r_last;
  assign m_axi_rresp = mst_port.r_resp;
  assign m_axi_rvalid = mst_port.r_valid;
  assign mst_port.r_ready = m_axi_rready;

  // AW channel
  assign mst_port.aw_id = m_axi_awid;
  assign mst_port.aw_addr = m_axi_awaddr;
  assign mst_port.aw_len = m_axi_awlen;
  assign mst_port.aw_size = m_axi_awsize;
  assign mst_port.aw_burst = m_axi_awburst;
  assign mst_port.aw_valid = m_axi_awvalid;
  assign mst_port.aw_lock = 'b0;
  assign mst_port.aw_cache = 'b0;
  assign mst_port.aw_prot = 'b0;
  assign mst_port.aw_qos = 'b0;
  assign mst_port.aw_region = 'b0;
  assign mst_port.aw_user = 'b0;
  assign m_axi_awready = mst_port.aw_ready;

  // W channel
  assign mst_port.w_strb = m_axi_wstrb;
  assign mst_port.w_data = m_axi_wdata;
  assign mst_port.w_last = m_axi_wlast;
  assign mst_port.w_valid = m_axi_wvalid;
  assign mst_port.w_user = 'b0;
  assign m_axi_wready = mst_port.w_ready;

  // B channel
  assign m_axi_bid = mst_port.b_id;
  assign m_axi_bresp = mst_port.b_resp;
  assign m_axi_bvalid = mst_port.b_valid;
  assign mst_port.b_ready = m_axi_bready;

endmodule
