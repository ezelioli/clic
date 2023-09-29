// Copyright lowRISC contributors.
// Copyright 2022 ETH Zurich
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// SPDX-License-Identifier: Apache-2.0

`include "common_cells/assertions.svh"

module clic import mclic_reg_pkg::*; import clicint_reg_pkg::*; import clicintv_reg_pkg::*; import clicvs_reg_pkg::*; #(
  parameter type reg_req_t = logic,
  parameter type reg_rsp_t = logic,
  parameter int  N_SOURCE = 256,
  parameter int  INTCTLBITS = 8,
  parameter bit  SSCLIC = 0,
  parameter bit  USCLIC = 0,
  parameter bit  VSCLIC = 0, // enable vCLIC (requires SSCLIC)

  // vCLIC dependent parameters
  parameter int unsigned N_VSCTXTS = 0, // Number of Virtual Contexts supported. 
                                        // This implementation assumes CLIC is mapped to an address 
                                        // range that allows up to 64 contexts (at least 512KiB)
  parameter bit  VSPRIO = 0, // enable VS prioritization (requires VSCLIC)
  
  // do not edit below, these are derived
  localparam int SRC_W = $clog2(N_SOURCE),
  localparam int unsigned MAX_VSCTXTS = 64, // up to 64 VS contexts
  localparam int unsigned VSID_W = $clog2(MAX_VSCTXTS)
)(
  input logic        clk_i,
  input logic        rst_ni,

  // Bus Interface (device)
  input reg_req_t    reg_req_i,
  output reg_rsp_t   reg_rsp_o,

  // Interrupt Sources
  input [N_SOURCE-1:0] intr_src_i,

  // Interrupt notification to core
  output logic              irq_valid_o,
  input  logic              irq_ready_i,
  output logic [SRC_W-1:0]  irq_id_o,
  output logic [7:0]        irq_level_o,
  output logic              irq_shv_o,
  output logic [1:0]        irq_priv_o,
  output logic [VSID_W-1:0] irq_vsid_o,
  output logic              irq_v_o,
  output logic              irq_kill_req_o,
  input  logic              irq_kill_ack_i
);

  if (USCLIC)
    $fatal(1, "usclic mode is not supported");

  if (VSCLIC) begin
    if (N_VSCTXTS <= 0 || N_VSCTXTS > MAX_VSCTXTS)
      $fatal(1, "vsclic extension requires N_VSCTXTS in [1, 64]");
    if (!SSCLIC)
      $fatal(1, "vsclic extension requires ssclic");
  end else begin
    if(VSPRIO)
      $fatal(1, "vsprio extension requires vsclic");
  end

  localparam logic [1:0] U_MODE = 2'b00;
  localparam logic [1:0] S_MODE = 2'b01;
  localparam logic [1:0] M_MODE = 2'b11;

  ///////////////////////////////////////////////////
  //            CLIC internal addressing           //
  ///////////////////////////////////////////////////
  //
  // The address range is divided into blocks of 32KB.
  // There is one block each for S-mode and M-mode, 
  // and there are up to MAX_VSCTXTS extra blocks, 
  // one per guest VS.
  //
  // M_MODE   : [0x000000 - 0x007fff]
  // S_MODE   : [0x008000 - 0x00ffff]
  // VS_1     : [0x010000 - 0x017fff]
  // VS_2     : [0x018000 - 0x01ffff]
  //   :
  // VS_64    : [0x208000 - 0x20ffff]

  // Some value between 16 (VSCLIC = 0) and 22 (64 VS contexts)
  localparam int unsigned ADDR_W = $clog2((N_VSCTXTS + 2) * 32 * 1024); 

  // Each privilege mode address space is aligned to a 32KiB physical memory region
  localparam logic [ADDR_W-1:0] MCLICCFG_START  = 'h00000;
  localparam logic [ADDR_W-1:0] MCLICINT_START  = 'h01000;
  localparam logic [ADDR_W-1:0] MCLICINT_END    = 'h04fff;

  localparam logic [ADDR_W-1:0] SCLICCFG_START  = 'h08000;
  localparam logic [ADDR_W-1:0] SCLICINT_START  = 'h09000;
  localparam logic [ADDR_W-1:0] SCLICINT_END    = 'h0cfff;
  localparam logic [ADDR_W-1:0] SCLICINTV_START = 'h0d000;
  localparam logic [ADDR_W-1:0] SCLICINTV_END   = 'h0dfff;

  localparam logic [ADDR_W-1:0] VSCLICPRIO_START = 'h0e000;
  localparam logic [ADDR_W-1:0] VSCLICPRIO_END   = 'h0efff;

  //////////////////////////////////////////////////////////////////////
  // NOTE: Replaced defines with explicit list of parameters due to   //
  //       Synopsys DC error during synthesys in intel16 technology.  //
  //////////////////////////////////////////////////////////////////////

  // VS `i` (1 <= i <= 64) will be mapped to VSCLIC*(i) address space
  // `define VSCLICCFG_START(i)  ('h08000 * (i + 1))
  // `define VSCLICINT_START(i)  ('h08000 * (i + 1) + 'h01000)
  // `define VSCLICINT_END(i)    ('h08000 * (i + 1) + 'h04fff)

  localparam logic [ADDR_W-1:0] VSCLICINT_START_1 = 'h11000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_1   = 'h14fff;

  localparam logic [ADDR_W-1:0] VSCLICINT_START_2 = 'h19000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_2   = 'h1cfff;

  localparam logic [ADDR_W-1:0] VSCLICINT_START_3 = 'h21000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_3   = 'h24fff;

  localparam logic [ADDR_W-1:0] VSCLICINT_START_4 = 'h29000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_4   = 'h2cfff;

  localparam logic [ADDR_W-1:0] VSCLICINT_START_5 = 'h31000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_5   = 'h34fff;

  localparam logic [ADDR_W-1:0] VSCLICINT_START_6 = 'h39000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_6   = 'h3cfff;

  localparam logic [ADDR_W-1:0] VSCLICINT_START_7 = 'h41000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_7   = 'h44fff;

  localparam logic [ADDR_W-1:0] VSCLICINT_START_8 = 'h49000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_8   = 'h4cfff;

  localparam logic [ADDR_W-1:0] VSCLICINT_START_9 = 'h51000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_9   = 'h54fff;

  localparam logic [ADDR_W-1:0] VSCLICINT_START_10 = 'h59000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_10   = 'h5cfff;

  localparam logic [ADDR_W-1:0] VSCLICINT_START_11 = 'h61000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_11   = 'h64fff;

  localparam logic [ADDR_W-1:0] VSCLICINT_START_12 = 'h69000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_12   = 'h6cfff;

  localparam logic [ADDR_W-1:0] VSCLICINT_START_13 = 'h071000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_13   = 'h074fff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_14 = 'h079000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_14   = 'h07cfff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_15 = 'h081000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_15   = 'h084fff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_16 = 'h089000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_16   = 'h08cfff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_17 = 'h091000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_17   = 'h094fff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_18 = 'h099000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_18   = 'h09cfff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_19 = 'h0a1000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_19   = 'h0a4fff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_20 = 'h0a9000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_20   = 'h0acfff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_21 = 'h0b1000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_21   = 'h0b4fff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_22 = 'h0b9000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_22   = 'h0bcfff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_23 = 'h0c1000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_23   = 'h0c4fff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_24 = 'h0c9000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_24   = 'h0ccfff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_25 = 'h0d1000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_25   = 'h0d4fff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_26 = 'h0d9000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_26   = 'h0dcfff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_27 = 'h0e1000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_27   = 'h0e4fff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_28 = 'h0e9000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_28   = 'h0ecfff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_29 = 'h0f1000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_29   = 'h0f4fff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_30 = 'h0f9000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_30   = 'h0fcfff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_31 = 'h101000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_31   = 'h104fff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_32 = 'h109000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_32   = 'h10cfff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_33 = 'h111000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_33   = 'h114fff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_34 = 'h119000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_34   = 'h11cfff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_35 = 'h121000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_35   = 'h124fff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_36 = 'h129000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_36   = 'h12cfff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_37 = 'h131000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_37   = 'h134fff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_38 = 'h139000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_38   = 'h13cfff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_39 = 'h141000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_39   = 'h144fff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_40 = 'h149000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_40   = 'h14cfff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_41 = 'h151000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_41   = 'h154fff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_42 = 'h159000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_42   = 'h15cfff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_43 = 'h161000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_43   = 'h164fff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_44 = 'h169000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_44   = 'h16cfff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_45 = 'h171000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_45   = 'h174fff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_46 = 'h179000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_46   = 'h17cfff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_47 = 'h181000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_47   = 'h184fff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_48 = 'h189000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_48   = 'h18cfff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_49 = 'h191000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_49   = 'h194fff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_50 = 'h199000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_50   = 'h19cfff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_51 = 'h1a1000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_51   = 'h1a4fff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_52 = 'h1a9000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_52   = 'h1acfff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_53 = 'h1b1000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_53   = 'h1b4fff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_54 = 'h1b9000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_54   = 'h1bcfff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_55 = 'h1c1000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_55   = 'h1c4fff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_56 = 'h1c9000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_56   = 'h1ccfff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_57 = 'h1d1000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_57   = 'h1d4fff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_58 = 'h1d9000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_58   = 'h1dcfff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_59 = 'h1e1000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_59   = 'h1e4fff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_60 = 'h1e9000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_60   = 'h1ecfff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_61 = 'h1f1000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_61   = 'h1f4fff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_62 = 'h1f9000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_62   = 'h1fcfff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_63 = 'h201000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_63   = 'h204fff;
  
  localparam logic [ADDR_W-1:0] VSCLICINT_START_64 = 'h209000;
  localparam logic [ADDR_W-1:0] VSCLICINT_END_64   = 'h20cfff;

  localparam logic [ADDR_W-1:0] VSCLICINT_START_ADDR [64] = '{
    VSCLICINT_START_1,   VSCLICINT_START_2,  VSCLICINT_START_3,  VSCLICINT_START_4,
    VSCLICINT_START_5,   VSCLICINT_START_6,  VSCLICINT_START_7,  VSCLICINT_START_8,
    VSCLICINT_START_9,  VSCLICINT_START_10, VSCLICINT_START_11, VSCLICINT_START_12,
    VSCLICINT_START_13, VSCLICINT_START_14, VSCLICINT_START_15, VSCLICINT_START_16,
    VSCLICINT_START_17, VSCLICINT_START_18, VSCLICINT_START_19, VSCLICINT_START_20,
    VSCLICINT_START_21, VSCLICINT_START_22, VSCLICINT_START_23, VSCLICINT_START_24,
    VSCLICINT_START_25, VSCLICINT_START_26, VSCLICINT_START_27, VSCLICINT_START_28,
    VSCLICINT_START_29, VSCLICINT_START_30, VSCLICINT_START_31, VSCLICINT_START_32,
    VSCLICINT_START_33, VSCLICINT_START_34, VSCLICINT_START_35, VSCLICINT_START_36,
    VSCLICINT_START_37, VSCLICINT_START_38, VSCLICINT_START_39, VSCLICINT_START_40,
    VSCLICINT_START_41, VSCLICINT_START_42, VSCLICINT_START_43, VSCLICINT_START_44,
    VSCLICINT_START_45, VSCLICINT_START_46, VSCLICINT_START_47, VSCLICINT_START_48,
    VSCLICINT_START_49, VSCLICINT_START_50, VSCLICINT_START_51, VSCLICINT_START_52,
    VSCLICINT_START_53, VSCLICINT_START_54, VSCLICINT_START_55, VSCLICINT_START_56,
    VSCLICINT_START_57, VSCLICINT_START_58, VSCLICINT_START_59, VSCLICINT_START_60,
    VSCLICINT_START_61, VSCLICINT_START_62, VSCLICINT_START_63, VSCLICINT_START_64
  };

    localparam logic [ADDR_W-1:0] VSCLICINT_END_ADDR [64] = '{
    VSCLICINT_END_1,   VSCLICINT_END_2,  VSCLICINT_END_3,  VSCLICINT_END_4,
    VSCLICINT_END_5,   VSCLICINT_END_6,  VSCLICINT_END_7,  VSCLICINT_END_8,
    VSCLICINT_END_9,  VSCLICINT_END_10, VSCLICINT_END_11, VSCLICINT_END_12,
    VSCLICINT_END_13, VSCLICINT_END_14, VSCLICINT_END_15, VSCLICINT_END_16,
    VSCLICINT_END_17, VSCLICINT_END_18, VSCLICINT_END_19, VSCLICINT_END_20,
    VSCLICINT_END_21, VSCLICINT_END_22, VSCLICINT_END_23, VSCLICINT_END_24,
    VSCLICINT_END_25, VSCLICINT_END_26, VSCLICINT_END_27, VSCLICINT_END_28,
    VSCLICINT_END_29, VSCLICINT_END_30, VSCLICINT_END_31, VSCLICINT_END_32,
    VSCLICINT_END_33, VSCLICINT_END_34, VSCLICINT_END_35, VSCLICINT_END_36,
    VSCLICINT_END_37, VSCLICINT_END_38, VSCLICINT_END_39, VSCLICINT_END_40,
    VSCLICINT_END_41, VSCLICINT_END_42, VSCLICINT_END_43, VSCLICINT_END_44,
    VSCLICINT_END_45, VSCLICINT_END_46, VSCLICINT_END_47, VSCLICINT_END_48,
    VSCLICINT_END_49, VSCLICINT_END_50, VSCLICINT_END_51, VSCLICINT_END_52,
    VSCLICINT_END_53, VSCLICINT_END_54, VSCLICINT_END_55, VSCLICINT_END_56,
    VSCLICINT_END_57, VSCLICINT_END_58, VSCLICINT_END_59, VSCLICINT_END_60,
    VSCLICINT_END_61, VSCLICINT_END_62, VSCLICINT_END_63, VSCLICINT_END_64
  };

  // VS prioritization parameter (depends on VSPRIO)
  // Determines how many bits are used to encode a VS priority
  // TODO : make this a top level parameter
  // TODO : make this dependent on VSPRIO 
  localparam VsprioWidth = 2;

  mclic_reg2hw_t mclic_reg2hw;

  clicint_reg2hw_t [N_SOURCE-1:0] clicint_reg2hw;
  clicint_hw2reg_t [N_SOURCE-1:0] clicint_hw2reg;

  clicintv_reg2hw_t [(N_SOURCE/4)-1:0] clicintv_reg2hw;
  // clicintv_hw2reg_t [(N_SOURCE/4)-1:0] clicintv_hw2reg; // Not needed

  clicvs_reg2hw_t [(MAX_VSCTXTS/4)-1:0] clicvs_reg2hw;
  // clicvs_hw2reg_t [(MAX_VSCTXTS/4)-1:0] clicvs_hw2reg; // Not needed

  logic [7:0] intctl [N_SOURCE];
  logic [7:0] irq_max;

  logic [1:0] intmode [N_SOURCE];
  logic [1:0] irq_mode;

  logic [VSID_W-1:0] vsid [N_SOURCE]; // Per-IRQ Virtual Supervisor (VS) ID
  logic              intv [N_SOURCE]; // Per-IRQ virtualization bit

  logic [VsprioWidth-1:0] vsprio [MAX_VSCTXTS];

  logic [N_SOURCE-1:0] le; // 0: level-sensitive 1: edge-sensitive
  logic [N_SOURCE-1:0] ip;
  logic [N_SOURCE-1:0] ie;
  logic [N_SOURCE-1:0] ip_sw; // sw-based edge-triggered interrupt
  logic [N_SOURCE-1:0] shv; // Handle per-irq SHV bits

  logic [N_SOURCE-1:0] claim;

  // handle incoming interrupts
  clic_gateway #(
    .N_SOURCE   (N_SOURCE)
  ) i_clic_gateway (
    .clk_i,
    .rst_ni,

    .src_i         (intr_src_i),
    .sw_i          (ip_sw),
    .le_i          (le),

    .claim_i       (claim),

    .ip_o          (ip)
  );

  // generate interrupt depending on ip, ie, level and priority
  clic_target #(
    .N_SOURCE    (N_SOURCE),
    .MAX_VSCTXTS (MAX_VSCTXTS),
    .PrioWidth   (INTCTLBITS),
    .ModeWidth   (2),
    .VsidWidth   (VSID_W),
    .VsprioWidth (VsprioWidth)
  ) i_clic_target (
    .clk_i,
    .rst_ni,

    .ip_i        (ip),
    .ie_i        (ie),
    .le_i        (le),
    .shv_i       (shv),

    .prio_i      (intctl),
    .mode_i      (intmode),
    .intv_i      (intv),
    .vsid_i      (vsid),

    .vsprio_i    (vsprio),

    .claim_o     (claim),

    .irq_valid_o,
    .irq_ready_i,
    .irq_id_o,
    .irq_max_o   (irq_max),
    .irq_mode_o  (irq_mode),
    .irq_v_o,
    .irq_vsid_o,
    .irq_shv_o,

    .irq_kill_req_o,
    .irq_kill_ack_i
  );

  // configuration registers
  // 0x0000 (machine mode)
  reg_req_t reg_mclic_req;
  reg_rsp_t reg_mclic_rsp;

  mclic_reg_top #(
    .reg_req_t (reg_req_t),
    .reg_rsp_t (reg_rsp_t)
  ) i_mclic_reg_top (
    .clk_i,
    .rst_ni,

    .reg_req_i (reg_mclic_req),
    .reg_rsp_o (reg_mclic_rsp),

    .reg2hw (mclic_reg2hw),

    .devmode_i  (1'b1)
  );

  // interrupt control and status registers (per interrupt line)
  // 0x1000 - 0x4fff (machine mode)
  reg_req_t reg_all_int_req;
  reg_rsp_t reg_all_int_rsp;
  logic [ADDR_W-1:0] int_addr;

  reg_req_t [N_SOURCE-1:0] reg_int_req;
  reg_rsp_t [N_SOURCE-1:0] reg_int_rsp;

  // TODO: improve decoding by only deasserting valid
  always_comb begin
    int_addr = reg_all_int_req.addr[ADDR_W-1:2];

    reg_int_req = '0;
    reg_all_int_rsp = '0;

    reg_int_req[int_addr] = reg_all_int_req;
    reg_all_int_rsp = reg_int_rsp[int_addr];
  end

  for (genvar i = 0; i < N_SOURCE; i++) begin : gen_clic_int
    clicint_reg_top #(
      .reg_req_t (reg_req_t),
      .reg_rsp_t (reg_rsp_t)
    ) i_clicint_reg_top (
      .clk_i,
      .rst_ni,

      .reg_req_i (reg_int_req[i]),
      .reg_rsp_o (reg_int_rsp[i]),

      .reg2hw (clicint_reg2hw[i]),
      .hw2reg (clicint_hw2reg[i]),

      .devmode_i  (1'b1)
    );
  end

  // interrupt control and status registers (per interrupt line)
  // 0x???? - 0x???? (machine mode)
  reg_req_t reg_all_v_req;
  reg_rsp_t reg_all_v_rsp;
  logic [ADDR_W-1:0] v_addr;

  reg_req_t [(N_SOURCE/4)-1:0] reg_v_req;
  reg_rsp_t [(N_SOURCE/4)-1:0] reg_v_rsp;

  // VSPRIO register interface signals
  reg_req_t reg_all_vs_req;
  reg_rsp_t reg_all_vs_rsp;
  logic [ADDR_W-1:0] vs_addr;

  reg_req_t [(MAX_VSCTXTS/4)-1:0] reg_vs_req;
  reg_rsp_t [(MAX_VSCTXTS/4)-1:0] reg_vs_rsp;

  if (VSCLIC) begin
    
    always_comb begin
      reg_v_req       = '0;
      reg_all_v_rsp   = '0;
      
      v_addr = reg_all_v_req.addr[ADDR_W-1:2];

      reg_v_req[v_addr] = reg_all_v_req;
      reg_all_v_rsp = reg_v_rsp[v_addr];
    end

    for (genvar i = 0; i < (N_SOURCE/4); i++) begin : gen_clic_intv
      clicintv_reg_top #(
        .reg_req_t (reg_req_t),
        .reg_rsp_t (reg_rsp_t)
      ) i_clicintv_reg_top (
        .clk_i,
        .rst_ni,

        .reg_req_i (reg_v_req[i]),
        .reg_rsp_o (reg_v_rsp[i]),

        .reg2hw (clicintv_reg2hw[i]),
        // .hw2reg (clicintv_hw2reg[i]),

        .devmode_i  (1'b1)
      );
    end
    
    if (VSPRIO) begin

      always_comb begin
        reg_vs_req       = '0;
        reg_all_vs_rsp   = '0;
      
        vs_addr = reg_all_vs_req.addr[ADDR_W-1:2];

        reg_vs_req[vs_addr] = reg_all_vs_req;
        reg_all_vs_rsp = reg_vs_rsp[vs_addr];
      end
      
      for(genvar i = 0; i < (MAX_VSCTXTS/4); i++) begin : gen_clic_vs
          
        clicvs_reg_top #(
          .reg_req_t (reg_req_t),
          .reg_rsp_t (reg_rsp_t)
        ) i_clicvs_reg_top (
          .clk_i,
          .rst_ni,

          .reg_req_i (reg_vs_req[i]),
          .reg_rsp_o (reg_vs_rsp[i]),

          .reg2hw (clicvs_reg2hw[i]),
          // .hw2reg (clicvs_hw2reg[i]),

          .devmode_i  (1'b1)
        );

      end

    end else begin
      assign clicvs_reg2hw      = '0;
      // assign clicvs_hw2reg   = '0;
      assign reg_vs_req         = '0;
      assign reg_vs_rsp         = '0;
      assign vs_addr            = '0;
      assign reg_all_vs_rsp     = '0;
    end

  end else begin
    assign clicintv_reg2hw    = '0;
    // assign clicintv_hw2reg = '0;
    assign reg_v_req          = '0;
    assign reg_v_rsp          = '0;
    assign v_addr             = '0;
    assign reg_all_v_rsp      = '0;
  end

  // top level address decoding and bus muxing

  // Helper signal used to store intermediate address
  logic [ADDR_W-1:0] addr_tmp;
  
  always_comb begin : clic_addr_decode
    reg_mclic_req   = '0;
    reg_all_int_req = '0;
    reg_all_v_req   = '0;
    reg_all_vs_req  = '0;
    reg_rsp_o       = '0;

    addr_tmp        = '0;

    unique case(reg_req_i.addr[ADDR_W-1:0]) inside
      MCLICCFG_START: begin
        reg_mclic_req = reg_req_i;
        reg_rsp_o = reg_mclic_rsp;
      end
      [MCLICINT_START:MCLICINT_END]: begin
        reg_all_int_req = reg_req_i;
        reg_all_int_req.addr = reg_req_i.addr - MCLICINT_START;
        reg_rsp_o = reg_all_int_rsp;
      end
      SCLICCFG_START: begin
        if (SSCLIC) begin
          reg_mclic_req = reg_req_i;
          reg_rsp_o = reg_mclic_rsp;
        end
      end
      [SCLICINT_START:SCLICINT_END]: begin
        if (SSCLIC) begin
          addr_tmp = reg_req_i.addr[ADDR_W-1:0] - SCLICINT_START;
          if (intmode[addr_tmp[ADDR_W-1:2]] <= S_MODE) begin
            // check whether the irq we want to access is s-mode or lower
            reg_all_int_req = reg_req_i;
            reg_all_int_req.addr = addr_tmp;
            // Prevent setting interrupt mode to m-mode . This is currently a
            // bit ugly but will be nicer once we do away with auto generated
            // clicint registers
            reg_all_int_req.wdata[23] = 1'b0;
            reg_rsp_o = reg_all_int_rsp;
          end else begin
            // inaccesible (all zero)
            reg_rsp_o.rdata = '0;
            reg_rsp_o.error = '0;
            reg_rsp_o.ready = 1'b1;
          end
        end
      end
      [SCLICINTV_START:SCLICINTV_END]: begin
        if (VSCLIC) begin
          addr_tmp = reg_req_i.addr[ADDR_W-1:0] - SCLICINTV_START;
          reg_all_v_req = reg_req_i;
          reg_all_v_req.addr = addr_tmp;
          addr_tmp = {addr_tmp[ADDR_W-1:2], 2'b0};
          reg_rsp_o = reg_all_v_rsp;
          if(intmode[addr_tmp + 0] > S_MODE) begin
            reg_all_v_req.wdata[7:0] = 8'b0;
            reg_rsp_o.rdata[7:0] = 8'b0;
          end
          if(intmode[addr_tmp + 1] > S_MODE) begin
            reg_all_v_req.wdata[15:8] = 8'b0;
            reg_rsp_o.rdata[15:8] = 8'b0;
          end
          if(intmode[addr_tmp + 2] > S_MODE) begin
            reg_all_v_req.wdata[23:16] = 8'b0;
            reg_rsp_o.rdata[23:16] = 8'b0;
          end
          if(intmode[addr_tmp + 3] > S_MODE) begin
            reg_all_v_req.wdata[31:24] = 8'b0;
            reg_rsp_o.rdata[31:24] = 8'b0;
          end
        end else begin
          // VSCLIC disabled
          reg_rsp_o.rdata = '0;
          reg_rsp_o.error = '0;
          reg_rsp_o.ready = 1'b1;
        end
      end
      [VSCLICPRIO_START:VSCLICPRIO_END]: begin
        if(VSCLIC && VSPRIO) begin
          addr_tmp = reg_req_i.addr[ADDR_W-1:0] - VSCLICPRIO_START;
          reg_all_vs_req = reg_req_i;
          reg_all_vs_req.addr = addr_tmp;
          reg_rsp_o = reg_all_vs_rsp;
        end else begin
          reg_rsp_o.rdata = '0;
          reg_rsp_o.error = '0;
          reg_rsp_o.ready = 1'b1;
        end
      end
      default: begin
        // inaccesible (all zero)
        reg_rsp_o.rdata = '0;
        reg_rsp_o.error = '0;
        reg_rsp_o.ready = 1'b1;
      end
    endcase // unique case (reg_req_i.addr)

    // Match VS address space
    if (VSCLIC) begin
        for (int i = 1; i <= N_VSCTXTS; i++) begin
          case(reg_req_i.addr[ADDR_W-1:0]) inside
            [VSCLICINT_START_ADDR[i-1]:VSCLICINT_END_ADDR[i-1]]: begin
              addr_tmp = reg_req_i.addr[ADDR_W-1:0] - VSCLICINT_START_ADDR[i-1];
              if ((intmode[addr_tmp[ADDR_W-1:2]] == S_MODE) && 
                  (intv[addr_tmp[ADDR_W-1:2]])              && 
                  (vsid[addr_tmp[ADDR_W-1:2]] == i)) begin
                // check whether the irq we want to access is s-mode and its v bit is set and the VSID corresponds
                reg_all_int_req = reg_req_i;
                reg_all_int_req.addr = addr_tmp;
                // Prevent setting interrupt mode to m-mode . This is currently a
                // bit ugly but will be nicer once we do away with auto generated
                // clicint registers
                reg_all_int_req.wdata[23] = 1'b0;
                reg_rsp_o = reg_all_int_rsp;
              end else begin
                // inaccesible (all zero)
                reg_rsp_o.rdata = '0;
                reg_rsp_o.error = '0;
                reg_rsp_o.ready = 1'b1;
              end
            end
          endcase
        end
    end

  end

  // adapter
  clic_reg_adapter #(
    .N_SOURCE    (N_SOURCE),
    .INTCTLBITS  (INTCTLBITS),
    .MAX_VSCTXTS (MAX_VSCTXTS),
    .VsidWidth   (VSID_W),
    .VsprioWidth (VsprioWidth)
  ) i_clic_reg_adapter (
    .clk_i,
    .rst_ni,

    .mclic_reg2hw,

    .clicint_reg2hw,
    .clicint_hw2reg,

    .clicintv_reg2hw,
    // .clicintv_hw2reg,

    .clicvs_reg2hw,
    // .clicvs_hw2reg,

    .intctl_o  (intctl),
    .intmode_o (intmode),
    .shv_o     (shv),
    .vsid_o    (vsid),
    .intv_o    (intv),
    .vsprio_o  (vsprio),
    .ip_sw_o   (ip_sw),
    .ie_o      (ie),
    .le_o      (le),

    .ip_i      (ip)
  );

  // Create level and prio signals with dynamic indexing (#bits are read from
  // registers and stored in logic signals)
  logic [3:0] mnlbits;

  always_comb begin
    // Saturate nlbits if nlbits > clicintctlbits (nlbits > 0 && nlbits <= 8)
    mnlbits = INTCTLBITS;
    if (mclic_reg2hw.mcliccfg.mnlbits.q <= INTCTLBITS)
      mnlbits = mclic_reg2hw.mcliccfg.mnlbits.q;
  end

  logic [7:0] irq_level_tmp;

  always_comb begin
      // Get level value of the highest level, highest priority interrupt from
      // clic_target (still in the form `L-P-1`)
      irq_level_tmp = 8'hff;
      unique case (mnlbits)
        4'h0: begin
          irq_level_tmp = 8'hff;
        end
        4'h1: begin
          irq_level_tmp[7] = irq_max[7];
        end
        4'h2: begin
          irq_level_tmp[7:6] = irq_max[7:6];
        end
        4'h3: begin
          irq_level_tmp[7:5] = irq_max[7:5];
        end
        4'h4: begin
          irq_level_tmp[7:4] = irq_max[7:4];
        end
        4'h5: begin
          irq_level_tmp[7:3] = irq_max[7:3];
        end
        4'h6: begin
          irq_level_tmp[7:2] = irq_max[7:2];
        end
        4'h7: begin
          irq_level_tmp[7:1] = irq_max[7:1];
        end
        4'h8: begin
          irq_level_tmp[7:0] = irq_max[7:0];
        end
        default:
          irq_level_tmp = 8'hff;
      endcase
  end

  logic [1:0] nmbits;

  always_comb begin
    // m-mode only supported means no configuration
    nmbits = 2'b0;

    if (VSCLIC || SSCLIC || USCLIC)
      nmbits[0] = mclic_reg2hw.mcliccfg.nmbits.q[0];

    if ((VSCLIC || SSCLIC) && USCLIC)
      nmbits[1] = mclic_reg2hw.mcliccfg.nmbits.q[1];
  end

  logic [1:0] irq_mode_tmp;

  always_comb begin
      // Get mode of the highest level, highest priority interrupt from
      // clic_target (still in the form `L-P-1`)
      irq_mode_tmp = M_MODE;
      unique case (nmbits)
        4'h0: begin
          irq_mode_tmp = M_MODE;
        end
        4'h1: begin
          irq_mode_tmp[1] = irq_mode[1];
        end
        4'h2: begin
          irq_mode_tmp = irq_mode;
        end
        4'h3: begin // this is reserved, not sure what to do
          irq_mode_tmp = irq_mode;
        end
        default:
          irq_mode_tmp = M_MODE;
      endcase
  end


  assign irq_level_o = irq_level_tmp;
  assign irq_priv_o  = irq_mode_tmp;

endmodule // clic
