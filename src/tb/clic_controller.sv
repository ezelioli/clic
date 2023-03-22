import clic_tb_pkg::*;

module clic_controller #(
  parameter int  N_SOURCE   = 256,
  parameter int  INTCTLBITS = 8,
  // derived params
  localparam int SRC_W = $clog2(N_SOURCE)
) (
  input  logic                  clk_i,
  input  logic                  rst_ni,
  
  // CLIC IF
  input  logic                  clic_irq_valid_i,    // interrupt is valid
  output logic                  clic_irq_ready_o,    // interrupt is acknowledged
  input  logic      [SRC_W-1:0] clic_irq_id_i,       // interrupt ID
  input  logic            [7:0] clic_irq_level_i,    // interrupt level
  input  logic                  clic_irq_shv_i,      // interrupt vector-mode enable
  input  logic            [1:0] clic_irq_priv_i      // interrupt privilege level
);

  // Signals from CLIC interface
  irq_t       clic_if_irq;
  
  // Signals from pipeline
  logic       pipeline_csr_write;
  csr_reg_t   pipeline_csr_addr;
  xlen_t      pipeline_csr_wdata;
  logic       pipeline_mret;
  logic       pipeline_sret;
  logic       pipeline_inst_valid;
  mode_t      pipeline_inst_priv;
  xlen_t      pipeline_inst_pc;
  irq_t       pipeline_irq;
  
  // Signals from CSRs / control logic
  xlen_t      pc;
  mode_t      priv_lvl;
  irq_ctrl_t  irq_ctrl;
  logic       flush;

  clic_if #(
    .N_SOURCE   (N_SOURCE),
    .INTCTLBITS (INTCTLBITS)
  ) i_clic_if (
    .clk_i             (clk_i),
    .rst_ni            (rst_ni),

    .priv_lvl_i        (priv_lvl),
    .irq_ctrl_i        (irq_ctrl),

    .clic_irq_valid_i  (clic_irq_valid_i),
    .clic_irq_ready_o  (clic_irq_ready_o),
    .clic_irq_id_i     (clic_irq_id_i),
    .clic_irq_level_i  (clic_irq_level_i),
    .clic_irq_shv_i    (clic_irq_shv_i),
    .clic_irq_priv_i   (clic_irq_priv_i),

    .irq_o             (clic_if_irq)
  );

  clic_csr_regfile #(
  ) i_clic_csr_regfile (
    .clk_i            (clk_i),
    .rst_ni           (rst_ni),

    .csr_write_i      (pipeline_csr_write),
    .csr_addr_i       (pipeline_csr_addr),
    .csr_wdata_i      (pipeline_csr_wdata),
    .mret_i           (pipeline_mret),
    .sret_i           (pipeline_sret),
    .inst_valid_i     (pipeline_inst_valid),
    .inst_priv_lvl_i  (pipeline_inst_priv),
    .inst_pc_i         (pipeline_inst_pc),
    .irq_i            (pipeline_irq),
    
    .priv_lvl_o       (priv_lvl),
    .pc_o             (pc),
    .irq_ctrl_o       (irq_ctrl),
    .flush_o          (flush)
  );

  clic_pipeline #(
    .N_STAGES(3)
  ) i_clic_pipeline (
    .clk_i           (clk_i),
    .rst_ni          (rst_ni),
    
    .pc_i            (pc),

    .irq_i           (clic_if_irq),

    .flush_i         (flush),
    .priv_lvl_i      (priv_lvl),

    .csr_write_o     (pipeline_csr_write),
    .csr_addr_o      (pipeline_csr_addr),
    .csr_wdata_o     (pipeline_csr_wdata),
    .mret_o          (pipeline_mret),
    .sret_o          (pipeline_sret),
    .inst_valid_o    (pipeline_inst_valid),
    .inst_priv_lvl_o (pipeline_inst_priv),
    .inst_pc_o       (pipeline_inst_pc),
    .irq_o           (pipeline_irq)
  );

endmodule
