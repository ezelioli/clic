import clic_tb_pkg::*;

// `define nop  '{op: OP_NOP,  addr: '0, data: '0}
// `define mret '{op: OP_MRET, addr: '0, data: '0}
// `define sret '{op: OP_SRET, addr: '0, data: '0}
// `define csrw(addr, data) '{op: OP_CSRW, addr: addr, data: data}

module generic_rom
#(
  parameter int unsigned ADDR_W = 12,
  parameter int unsigned ROM_ID = 0,
  parameter string INSTR_INIT_FILE,
  // derived params
  localparam N_WORDS = 2**ADDR_W
)
(
  input  logic              clk_i,
  input  logic              en_ni,
  input  logic [ADDR_W-1:0] addr_i,
  output instruction_t      data_o
);

  instruction_t mem [N_WORDS-1:0];
  logic [ADDR_W-1:0] addr_q, addr_d;

  assign addr_d = addr_i;

  initial begin
    foreach (mem[i]) begin
      mem[i] = '0;
    end
    $display("[ROM %d] Initializing memory from file %s", ROM_ID, INSTR_INIT_FILE);
    $readmemh(INSTR_INIT_FILE, mem);
  end

  always_ff @(posedge clk_i) begin
    if (~en_ni) begin
      addr_q <= addr_d;
    end else begin 
      addr_q <= '0;
    end
  end

  assign data_o = mem[addr_q];

endmodule : generic_rom

////////////////////////////
//    Instruction ROM     //
////////////////////////////
//
// This module simulates a read-only memory containing 
// controller-compatible pseudo-instructions (as defined in clic_tb_pkg).
// To allow a larger address space, 4 ROM banks are used and mapped
// to different address ranges (determined by addr_i[13:12]). The banks
// are supposed to be used as follow:
// Bank ID:     Base:             Purpose:
// ---------------------------------------
//       1    0x0000           M-mode code
//       2    0x1000    M-mode trap vector
//       3    0x2000    S-mode trap vector
//       4    0x3000           S-mode code
// ---------------------------------------
// The memories are initialized with files located in the $(ROOT)/memories
// directory.

module clic_memory #(
) (
  input  logic          clk_i,
  input  xlen_t         addr_i,  
  output instruction_t  rdata_o
);

  instruction_t      data [3:0];

  localparam string filenames [3:0] = {"./memories/memory_4.h", "./memories/memory_3.h", "./memories/memory_2.h", "./memories/memory_1.h"};

  generate
    for(genvar i = 0; i < 4; ++i) begin
      logic rom_en;
      assign rom_en = ~(logic'(addr_i[13:12] == i));
      generic_rom #(
        .ADDR_W(12),
        .ROM_ID(i),
        .INSTR_INIT_FILE(filenames[i])
      ) i_generic_rom (
        .clk_i   (clk_i),
        .addr_i  (addr_i[11:0]),
        .en_ni   (rom_en),
        .data_o  (data[i])
      );
    end
  endgenerate

  always_comb begin
    rdata_o = '0;
    for(int i = 0; i < 4; ++i) begin
      if(i == addr_i[13:12]) begin
        rdata_o = data[i];
      end
    end
  end

endmodule : clic_memory