import clic_tb_pkg::*;

module clic_if #(
  parameter int  N_SOURCE   = 256,
  parameter int  INTCTLBITS = 8,
  // derived params
  localparam int SRC_W = $clog2(N_SOURCE)
) (
  input  logic                  clk_i,
  input  logic                  rst_ni,
  // controller status (from CSR)
  input  mode_t                 priv_lvl_i,          // current privilege mode
  input  irq_ctrl_t             irq_ctrl_i,          // Interrupt related signals
  // CLIC IF
  input  logic                  clic_irq_valid_i,    // interrupt is valid
  output logic                  clic_irq_ready_o,    // interrupt is acknowledged
  input  logic      [SRC_W-1:0] clic_irq_id_i,       // interrupt ID
  input  logic            [7:0] clic_irq_level_i,    // interrupt level
  input  logic                  clic_irq_shv_i,      // interrupt vector-mode enable
  input  logic            [1:0] clic_irq_priv_i,     // interrupt privilege level
  // to controller
  output irq_t                  irq_o                // interrupt pending
);

  logic        mie;               // M-mode global interrupt enable
  logic        sie;               // S-mode global interrupt enable
  logic  [7:0] mintthresh;        // M-mode interrupt threshold
  logic  [7:0] sintthresh;        // S-mode interrupt threshold
  logic  [7:0] mil;               // M-mode current interrupt level
  logic  [7:0] sil;               // S-mode current interrupt level

  assign mie        = irq_ctrl_i.xstatus_mie;
  assign sie        = irq_ctrl_i.xstatus_sie;
  assign mintthresh = irq_ctrl_i.mintthresh;
  assign sintthresh = irq_ctrl_i.sintthresh;
  assign mil        = irq_ctrl_i.mintstatus.mil;
  assign sil        = irq_ctrl_i.mintstatus.sil;

  // x-MODE effective_level = max(xintstatus.xil, xintthresh.th)
  logic [7:0] effective_mil, effective_sil;

  assign effective_mil = mintthresh > mil ? mintthresh : mil;
  assign effective_sil = sintthresh > sil ? sintthresh : sil;

  // needed for safe cast
  mode_t irq_priv_lvl_enum;

  logic irq_taken;

  // Determine if CLIC interrupt shall be accepted
  always_comb begin : set_irq_taken

    // TODO: improve this
    // manual cast of clic_irq_priv_i
    unique case (clic_irq_priv_i)
      M_MODE  : irq_priv_lvl_enum = M_MODE;
      S_MODE  : irq_priv_lvl_enum = S_MODE;
      U_MODE  : irq_priv_lvl_enum = U_MODE;
      default : irq_priv_lvl_enum = U_MODE;
    endcase

    irq_taken = 1'b0;

    unique case (priv_lvl_i)
  
      M_MODE: begin
        // Take M-mode interrupts with higher level
        if (irq_priv_lvl_enum == M_MODE) begin
          irq_taken = logic'(clic_irq_level_i > effective_mil) & clic_irq_valid_i & mie;
        end
      end
  
      S_MODE: begin
        // Take all M-mode interrupts
        if (irq_priv_lvl_enum == M_MODE) begin
          irq_taken = clic_irq_valid_i;
        // Take S-mode interrupts with higher level
        end else if (irq_priv_lvl_enum == S_MODE) begin
          irq_taken = logic'(clic_irq_level_i > effective_sil) & clic_irq_valid_i & sie;
        end
      end
  
      U_MODE: begin
        // Take all M-mode and S-mode interrupts
        irq_taken = (clic_irq_valid_i &
                    ( 
                      (logic'(irq_priv_lvl_enum == M_MODE) | 
                      (logic'(irq_priv_lvl_enum == S_MODE) & sie)) // might not need check on sie 
                    ));
      end

      default: begin
        irq_taken = 1'b0;
      end

    endcase
  
  end : set_irq_taken

  assign irq_o = '{
    valid         : irq_taken,
    shv           : clic_irq_shv_i,
    irq_priv      : irq_priv_lvl_enum,
    irq_lvl       : clic_irq_level_i,
    excode        : clic_irq_id_i, 
    hart_priv_lvl : priv_lvl_i,
    hart_ie       : (priv_lvl_i == S_MODE) ? sie : mie
  };


  // Complete handshake when control logic claims interrupt
  assign clic_irq_ready_o = irq_ctrl_i.claim;

endmodule : clic_if