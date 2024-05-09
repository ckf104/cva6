// Asynchronous read, synchronous write.
module ariane_vecram #(
    parameter int unsigned NumWords = 32'd1024,  // Number of Words in data array
    parameter int unsigned DataWidth = 32'd64,  // Data signal width
    parameter int unsigned ByteWidth = 32'd8,  // Width of a data byte
    parameter int unsigned NumReadPorts = 32'd2,  // Number of read ports
    parameter int unsigned NumWritePorts = 32'd1,  // Number of write ports
    // DEPENDENT PARAMETERS, DO NOT OVERWRITE!
    parameter int unsigned AddrWidth = (NumWords > 32'd1) ? $clog2(NumWords) : 32'd1,
    parameter int unsigned BeWidth = (DataWidth + ByteWidth - 32'd1) / ByteWidth,  // ceil_div
    parameter type addr_t = logic [AddrWidth-1:0],
    parameter type data_t = logic [DataWidth-1:0],
    parameter type be_t = logic [BeWidth-1:0]
) (
    input  logic                      clk_i,    // Clock
    // input ports
    input  logic  [NumWritePorts-1:0] we_i,     // write enable
    input  addr_t [NumWritePorts-1:0] waddr_i,  // request address
    input  data_t [NumWritePorts-1:0] wdata_i,  // write data
    input  be_t   [NumWritePorts-1:0] be_i,     // write byte enable
    input  addr_t [ NumReadPorts-1:0] raddr_i,  // read address
    // TODO: Should we gate read operation? Should we support write mask?
    // input  logic  [NumReadPorts-1:0] req_i,      // request
    // output ports
    output data_t [ NumReadPorts-1:0] rdata_o   // read data
);

  // memory array
  data_t sram[NumWords-1:0];

  always_comb begin
    for (int unsigned i = 0; i < NumReadPorts; i++) begin
      rdata_o[i] = sram[raddr_i[i]];
    end
  end

  always_ff @(posedge clk_i) begin
    for (int unsigned i = 0; i < NumWritePorts; i++) begin
      if (we_i[i]) begin
        for (int unsigned j = 0; j < BeWidth; j++) begin
          if (be_i[i][j]) begin
            sram[waddr_i[i]][j*ByteWidth+:ByteWidth] <= wdata_i[i][j*ByteWidth+:ByteWidth];
          end
        end
      end
    end
  end

endmodule

