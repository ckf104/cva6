`include "axi/assign.svh"
`include "rvfi_types.svh"

module custom_inst_cva6_with_reg
  import ariane_axi_soc::*;
#(
    parameter config_pkg::cva6_cfg_t CVA6Cfg = build_config_pkg::build_config(
        cva6_config_pkg::cva6_cfg
    ),
    //
    parameter int unsigned AXI_USER_EN = CVA6Cfg.AXI_USER_EN,
    parameter int unsigned NUM_WORDS = 2 ** 12  // memory size
) (
    input logic clk_i,
    input logic rst_ni,

    input  logic [31:0] src_width,
    input  logic [31:0] src_height,
    input  logic [31:0] src_offset_addr,
    input  logic [31:0] src_image_size,
    input  logic [31:0] dst_width,
    input  logic [31:0] dst_height,
    input  logic [31:0] dst_offset_addr,
    input  logic [31:0] dst_image_size,
    input  logic        start,
    output logic        idle,
    output logic [31:0] exit,

    output logic [IdWidthSlave-1:0] m_axi_arid,
    output logic [   AddrWidth-1:0] m_axi_araddr,
    output logic [             7:0] m_axi_arlen,
    output logic [             2:0] m_axi_arsize,
    output logic [             1:0] m_axi_arburst,
    output logic                    m_axi_arvalid,
    input  logic                    m_axi_arready,
    // R channel
    input  logic [IdWidthSlave-1:0] m_axi_rid,
    input  logic [   DataWidth-1:0] m_axi_rdata,
    input  logic                    m_axi_rlast,
    input  logic [             1:0] m_axi_rresp,
    input  logic                    m_axi_rvalid,
    output logic                    m_axi_rready,
    // AW channel
    output logic [IdWidthSlave-1:0] m_axi_awid,
    output logic [   AddrWidth-1:0] m_axi_awaddr,
    output logic [             7:0] m_axi_awlen,
    output logic [             2:0] m_axi_awsize,
    output logic [             1:0] m_axi_awburst,
    output logic                    m_axi_awvalid,
    input  logic                    m_axi_awready,
    // W channel
    output logic [ DataWidth/8-1:0] m_axi_wstrb,
    output logic [   DataWidth-1:0] m_axi_wdata,
    output logic                    m_axi_wlast,
    output logic                    m_axi_wvalid,
    input  logic                    m_axi_wready,
    // B channel
    input  logic [IdWidthSlave-1:0] m_axi_bid,
    input  logic [             1:0] m_axi_bresp,
    input  logic                    m_axi_bvalid,
    output logic                    m_axi_bready
);
  // Slave 0: ROM for instruction
  // Slave 1: PS DDR
  // Slave 2: local SRAM
  // Slave 3: control regs
  // Master 1: cva6 core
  typedef enum int unsigned {
    ROM = 0,
    LOCALSRAM = 1,
    CTRLREGS = 2,
    EXTDDR = 3
  } axi_slaves_t;
  localparam int unsigned NrSlaves = 32'd4;  // be consistent with ariane_axi_soc_pkg.sv
  localparam int unsigned NrMasters = 32'd1;

  localparam logic [AddrWidth-1:0] ROMLength = 'h10000;
  localparam logic [AddrWidth-1:0] CTRLREGSLength = 'h100;  // 11 64-bit ctrl registers
  localparam logic [AddrWidth-1:0] LOCALRAMLength = 'h8000;  // 32KB of SRAM
  localparam logic [AddrWidth-1:0] EXTDDRLength     = 'h08000000; // 128MB of DDR

  localparam logic [AddrWidth-1:0] ROMBase = 'h0000_0000;
  localparam logic [AddrWidth-1:0] LOCALRAMBase = 'h1000_0000;
  localparam logic [AddrWidth-1:0] CTRLREGSBase = 'h2000_0000;
  localparam logic [AddrWidth-1:0] EXTDDRBase = 'h3800_0000;

  AXI_BUS #(
      .AXI_ADDR_WIDTH(AddrWidth),
      .AXI_DATA_WIDTH(DataWidth),
      .AXI_ID_WIDTH  (ariane_axi_soc::IdWidthSlave),
      .AXI_USER_WIDTH(UserWidth)
  ) slave[NrSlaves-1:0] ();

  AXI_BUS #(
      .AXI_ADDR_WIDTH(AddrWidth),
      .AXI_DATA_WIDTH(DataWidth),
      .AXI_ID_WIDTH  (ariane_axi_soc::IdWidth),
      .AXI_USER_WIDTH(UserWidth)
  ) master[NrMasters-1:0] ();

  // ---------------
  // AXI Xbar
  // ---------------

  axi_pkg::xbar_rule_64_t [NrSlaves-1:0] addr_map;

  assign addr_map = '{
          '{idx: ROM, start_addr: ROMBase, end_addr: ROMBase + ROMLength},
          '{idx: LOCALSRAM, start_addr: LOCALRAMBase, end_addr: LOCALRAMBase + LOCALRAMLength},
          '{idx: CTRLREGS, start_addr: CTRLREGSBase, end_addr: CTRLREGSBase + CTRLREGSLength},
          '{idx: EXTDDR, start_addr: EXTDDRBase, end_addr: EXTDDRBase + EXTDDRLength}
      };

  localparam axi_pkg::xbar_cfg_t AXI_XBAR_CFG = '{
      NoSlvPorts: NrMasters,
      NoMstPorts: NrSlaves,
      MaxMstTrans: unsigned'(1),  // Probably requires update
      MaxSlvTrans: unsigned'(1),  // Probably requires update
      FallThrough: 1'b0,
      LatencyMode: axi_pkg::NO_LATENCY,
      AxiIdWidthSlvPorts: unsigned'(ariane_axi_soc::IdWidth),
      AxiIdUsedSlvPorts: unsigned'(ariane_axi_soc::IdWidth),
      UniqueIds: 1'b0,
      AxiAddrWidth: unsigned'(AddrWidth),
      AxiDataWidth: unsigned'(DataWidth),
      NoAddrRules: unsigned'(NrSlaves)
  };

  axi_xbar_intf #(
      .AXI_USER_WIDTH(UserWidth),
      .Cfg           (AXI_XBAR_CFG),
      .rule_t        (axi_pkg::xbar_rule_64_t)
  ) i_axi_xbar (
      .clk_i                (clk_i),
      .rst_ni               (rst_ni),
      .test_i               ('b0),
      .slv_ports            (master),
      .mst_ports            (slave),
      .addr_map_i           (addr_map),
      .en_default_mst_port_i('0),
      .default_mst_port_i   ('0)
  );


  ///////////////////////
  // Master: cva6 core //
  ///////////////////////

  // RVFI
  localparam type rvfi_instr_t = `RVFI_INSTR_T(CVA6Cfg);
  localparam type rvfi_csr_elmt_t = `RVFI_CSR_ELMT_T(CVA6Cfg);
  localparam type rvfi_csr_t = `RVFI_CSR_T(CVA6Cfg, rvfi_csr_elmt_t);

  localparam type rvfi_probes_instr_t = `RVFI_PROBES_INSTR_T(CVA6Cfg);
  localparam type rvfi_probes_csr_t = `RVFI_PROBES_CSR_T(CVA6Cfg);
  localparam type rvfi_probes_t = struct packed {
    rvfi_probes_csr_t   csr;
    rvfi_probes_instr_t instr;
  };

  ariane_axi::req_t axi_ariane_req;
  ariane_axi::resp_t axi_ariane_resp;
  rvfi_probes_t rvfi_probes;

  `AXI_ASSIGN_FROM_REQ(master[0], axi_ariane_req)
  `AXI_ASSIGN_TO_RESP(axi_ariane_resp, master[0])

  ariane #(
      .CVA6Cfg            (CVA6Cfg),
      .rvfi_probes_instr_t(rvfi_probes_instr_t),
      .rvfi_probes_csr_t  (rvfi_probes_csr_t),
      .rvfi_probes_t      (rvfi_probes_t),
      .noc_req_t          (ariane_axi::req_t),
      .noc_resp_t         (ariane_axi::resp_t)
  ) i_ariane (
      .clk_i        (clk_i),
      .rst_ni       (rst_ni),
      .boot_addr_i  (ROMBase),         // start fetching from ROM
      .hart_id_i    ('b0),
      .irq_i        ('b0),
      .ipi_i        ('b0),
      .time_irq_i   ('b0),
      .rvfi_probes_o(rvfi_probes),     // Ignore rvfi probes 
      .debug_req_i  (1'b0),
      .noc_req_o    (axi_ariane_req),
      .noc_resp_i   (axi_ariane_resp)
  );

  cva6_rvfi #(
      .CVA6Cfg   (CVA6Cfg),
      .rvfi_instr_t(rvfi_instr_t),
      .rvfi_csr_t(rvfi_csr_t),
      .rvfi_probes_instr_t(rvfi_probes_instr_t),
      .rvfi_probes_csr_t(rvfi_probes_csr_t),
      .rvfi_probes_t(rvfi_probes_t)
  ) i_cva6_rvfi (
      .clk_i        (clk_i),
      .rst_ni       (rst_ni),
      .rvfi_probes_i(rvfi_probes),
      .rvfi_instr_o (rvfi_instr),
      .rvfi_csr_o   (rvfi_csr)
  );

  rvfi_tracer #(
      .CVA6Cfg(CVA6Cfg),
      .rvfi_instr_t(rvfi_instr_t),
      .rvfi_csr_t(rvfi_csr_t),
      //
      .HART_ID('b0),
      .DEBUG_START(0),
      .DEBUG_STOP(0)
  ) i_rvfi_tracer (
      .clk_i(clk_i),
      .rst_ni(rst_ni),
      .rvfi_i(rvfi_instr),
      .rvfi_csr_i(rvfi_csr),
      .end_of_test_o(rvfi_exit)
  );

  //////////////////////
  // AXI Slave 0: ROM //
  //////////////////////

  logic                 rom_req;
  logic [AddrWidth-1:0] rom_addr;
  logic [DataWidth-1:0] rom_rdata;

  axi2mem #(
      .AXI_ID_WIDTH  (ariane_axi_soc::IdWidthSlave),
      .AXI_ADDR_WIDTH(AddrWidth),
      .AXI_DATA_WIDTH(DataWidth),
      .AXI_USER_WIDTH(UserWidth)
  ) i_axi2rom (
      .clk_i (clk_i),
      .rst_ni(rst_ni),
      .slave (slave[ROM]),
      .req_o (rom_req),
      .we_o  (),
      .addr_o(rom_addr),
      .be_o  (),
      .user_o(),
      .data_o(),
      .user_i('0),
      .data_i(rom_rdata)
  );

  cust_inst_bootrom i_bootrom (
      .clk_i  (clk_i),
      .req_i  (rom_req),
      .addr_i (rom_addr),
      .rdata_o(rom_rdata)
  );

  ///////////////////////////
  // AXI Slave 1: LOCALRAM //
  ///////////////////////////

  logic                   req;
  logic                   we;
  logic [  AddrWidth-1:0] addr;
  logic [DataWidth/8-1:0] be;
  logic [  DataWidth-1:0] wdata;
  logic [  DataWidth-1:0] rdata;
  logic [  UserWidth-1:0] wuser;
  logic [  UserWidth-1:0] ruser;

  axi2mem #(
      .AXI_ID_WIDTH  (ariane_axi_soc::IdWidthSlave),
      .AXI_ADDR_WIDTH(AddrWidth),
      .AXI_DATA_WIDTH(DataWidth),
      .AXI_USER_WIDTH(UserWidth)
  ) i_axi2mem (
      .clk_i (clk_i),
      .rst_ni(rst_ni),
      .slave (slave[LOCALSRAM]),
      .req_o (req),
      .we_o  (we),
      .addr_o(addr),
      .be_o  (be),
      .user_o(wuser),
      .data_o(wdata),
      .user_i(ruser),
      .data_i(rdata)
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
      .req_i  (req),
      .we_i   (we),
      .addr_i (addr[$clog2(NUM_WORDS)-1+$clog2(DataWidth/8):$clog2(DataWidth/8)]),
      .wuser_i(wuser),
      .wdata_i(wdata),
      .be_i   (be),
      .ruser_o(ruser),
      .rdata_o(rdata)
  );

  ///////////////////////////
  // AXI Slave 2: CTRLREGS //
  ///////////////////////////

  logic                 ctrlreg_req;
  logic                 ctrlreg_we;
  logic [AddrWidth-1:0] ctrlreg_addr;
  logic [DataWidth-1:0] ctrlreg_wdata;
  logic [DataWidth-1:0] ctrlreg_rdata;

  axi2mem #(
      .AXI_ID_WIDTH  (ariane_axi_soc::IdWidthSlave),
      .AXI_ADDR_WIDTH(AddrWidth),
      .AXI_DATA_WIDTH(DataWidth),
      .AXI_USER_WIDTH(UserWidth)
  ) i_axi2ctrlregs (
      .clk_i (clk_i),
      .rst_ni(rst_ni),
      .slave (slave[CTRLREGS]),
      .req_o (ctrlreg_req),
      .we_o  (ctrlreg_we),
      .addr_o(ctrlreg_addr),
      .be_o  (),
      .user_o(),
      .data_o(ctrlreg_wdata),
      .user_i('0),
      .data_i(ctrlreg_rdata)
  );

  ctrlreg ctrlreg (
      .clk_i          (clk_i),
      .rst_ni         (rst_ni),
      .src_width      (src_width),        // offset 0
      .src_height     (src_height),       // offset 8
      .src_offset_addr(src_offset_addr),  // offset 16
      .src_image_size (src_image_size),   // offset 24
      .dst_width      (dst_width),        // offset 32
      .dst_height     (dst_height),       // offset 40
      .dst_offset_addr(dst_offset_addr),  // offset 48
      .dst_image_size (dst_image_size),   // offset 56
      .start          (start),            // offset 64
      .idle           (idle),             // offset 72
      .exit           (exit),             // offset 80

      .ctrlreg_req  (ctrlreg_req),
      .ctrlreg_we   (ctrlreg_we),
      .ctrlreg_addr (ctrlreg_addr),
      .ctrlreg_wdata(ctrlreg_wdata),
      .ctrlreg_rdata(ctrlreg_rdata)
  );

  /////////////////////////
  // AXI Slave 3: EXTDDR //
  /////////////////////////

  axi_slv_break #(
      .IdWidthSlave(IdWidthSlave),
      .DataWidth   (DataWidth),
      .AddrWidth   (AddrWidth)
  ) i_axi_slv_in_mst_out (
      .slv_port     (slave[EXTDDR]),
      // AR channel
      .m_axi_arid   (m_axi_arid),
      .m_axi_araddr (m_axi_araddr),
      .m_axi_arlen  (m_axi_arlen),
      .m_axi_arsize (m_axi_arsize),
      .m_axi_arburst(m_axi_arburst),
      .m_axi_arvalid(m_axi_arvalid),
      .m_axi_arready(m_axi_arready),
      // R channel
      .m_axi_rid    (m_axi_rid),
      .m_axi_rdata  (m_axi_rdata),
      .m_axi_rlast  (m_axi_rlast),
      .m_axi_rresp  (m_axi_rresp),
      .m_axi_rvalid (m_axi_rvalid),
      .m_axi_rready (m_axi_rready),
      // AW channel
      .m_axi_awid   (m_axi_awid),
      .m_axi_awaddr (m_axi_awaddr),
      .m_axi_awlen  (m_axi_awlen),
      .m_axi_awsize (m_axi_awsize),
      .m_axi_awburst(m_axi_awburst),
      .m_axi_awvalid(m_axi_awvalid),
      .m_axi_awready(m_axi_awready),
      // W channel
      .m_axi_wstrb  (m_axi_wstrb),
      .m_axi_wdata  (m_axi_wdata),
      .m_axi_wlast  (m_axi_wlast),
      .m_axi_wvalid (m_axi_wvalid),
      .m_axi_wready (m_axi_wready),
      // B channel
      .m_axi_bid    (m_axi_bid),
      .m_axi_bresp  (m_axi_bresp),
      .m_axi_bvalid (m_axi_bvalid),
      .m_axi_bready (m_axi_bready)
  );



endmodule
