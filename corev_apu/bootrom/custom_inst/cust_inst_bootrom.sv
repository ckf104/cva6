/* Copyright 2018 ETH Zurich and University of Bologna.
 * Copyright and related rights are licensed under the Solderpad Hardware
 * License, Version 0.51 (the "License"); you may not use this file except in
 * compliance with the License.  You may obtain a copy of the License at
 * http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
 * or agreed to in writing, software, hardware and materials distributed under
 * this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 * CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 *
 * File: $filename.v
 *
 * Description: Auto-generated bootrom
 */

// Auto-generated code
module cust_inst_bootrom (
   input  logic         clk_i,
   input  logic         req_i,
   input  logic [63:0]  addr_i,
   output logic [63:0]  rdata_o
);
    localparam int RomSize = 107;

    const logic [RomSize-1:0][63:0] mem = {
        64'h00000000_20000000,
        64'h00000000_20000008,
        64'h00000000_20000010,
        64'h00000000_20000018,
        64'h00000000_20000020,
        64'h00000000_20000028,
        64'h00000000_20000030,
        64'h00000000_20000038,
        64'h00000000_20000040,
        64'h00000000_20000048,
        64'h00000000_20000050,
        64'h00000000_00000000,
        64'h0000e7bf_f0ef3052,
        64'h9073d222_82930000,
        64'h0297e406_1141bdd9,
        64'he3984705_609c0ff0,
        64'h000ff5af_97e340c8,
        64'h88bb01b6_0dbb008e,
        64'h843b2d05_6622f7d6,
        64'he8e325e1_274126a1,
        64'h0077b823_0067b423,
        64'h0057b023_0021038b,
        64'h0011030b_0001028b,
        64'h0600010b_0023900b,
        64'h0013100b_0002900b,
        64'h01083383_00883303,
        64'h00083283_97fa9381,
        64'h02059793_00783823,
        64'h00683423_00583023,
        64'h0021038b_0011030b,
        64'h0001028b_0410010b,
        64'h001e108b_0003908b,
        64'h0013100b_0002900b,
        64'h0087be03_0007b383,
        64'h00863303_00063283,
        64'h97aa962a_93819201,
        64'h17820207_16130117,
        64'h07bbe432_46819da1,
        64'h001d971b_0014159b,
        64'h8fb6847e_8d228dea,
        64'h866e0c0e_82634401,
        64'h4d014f81_c6f1001f,
        64'h7f330015_75332d81,
        64'h2e81031d_88bb2681,
        64'h639c0007_3f036294,
        64'h00063e83_618c6108,
        64'h0008b883_00033d83,
        64'h00093783_0009b703,
        64'h000a3683_000ab603,
        64'h000b3583_000bb503,
        64'h000c3883_000cb303,
        64'hdffd631c_63983100,
        64'h07930200_d0933080,
        64'h04930181_08133180,
        64'h09133200_09933280,
        64'h0a133300_0a933380,
        64'h0b133400_0b933480,
        64'h0c133500_0c93fc6e,
        64'he0eae922_e4e6e8e2,
        64'hecdef0da_f4d6f8d2,
        64'hfccee14a_e52650fd,
        64'hed067135_80828082,
        64'h80826121_79827922,
        64'h74c27462_f48919e3,
        64'h9fb940af_8fbb9ca9,
        64'h2405f6e9_e7e32ee1,
        64'h25c129a1_00763823,
        64'h00663423_00563023,
        64'h0021038b_0011030b,
        64'h0001028b_0600010b,
        64'h0023900b_0013100b,
        64'h0002900b_010f3383,
        64'h008f3303_000f3283,
        64'h96469201_020e9613,
        64'h007f3823_006f3423,
        64'h005f3023_0021038b,
        64'h0011030b_0001028b,
        64'h0410010b_001e108b,
        64'h0003908b_0013100b,
        64'h0002900b_00863e03,
        64'h00063383_00883303,
        64'h00083283_96369836,
        64'h92010208_58131602,
        64'h02059813_01f5863b,
        64'h498100fe_8ebb0014,
        64'h959b0017_9e9b0081,
        64'h0f134401_47814481,
        64'h893ef04e_f44af826,
        64'hfc227139_cf61cfe1,
        64'h02b50fbb_80820075,
        64'hb8230065_b4230055,
        64'hb0230021_038b0011,
        64'h030b0001_028b0600,
        64'h010b0023_900b0013,
        64'h100b0002_900b0105,
        64'h33830085_33030005,
        64'h32838082_00763823,
        64'h00663423_00563023,
        64'h0021038b_0011030b,
        64'h0001028b_0410010b,
        64'h001e108b_0003908b,
        64'h0013100b_0002900b,
        64'h0085be03_0005b383,
        64'h00853303_00053283,
        64'ha0010057_a0230289,
        64'h342022f3_30003783,
        64'h2de000ef_10007137
    };

    logic [$clog2(RomSize)-1:0] addr_q;

    always_ff @(posedge clk_i) begin
        if (req_i) begin
            addr_q <= addr_i[$clog2(RomSize)-1+3:3];
        end
    end

    // this prevents spurious Xes from propagating into
    // the speculative fetch stage of the core
    assign rdata_o = (addr_q < RomSize) ? mem[addr_q] : '0;
endmodule
