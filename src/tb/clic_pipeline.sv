import clic_tb_pkg::*;

module clic_pipeline #(
  parameter int unsigned N_STAGES = 3
) (
  input  logic        clk_i,
  input  logic        rst_ni,

  input  xlen_t       pc_i,

  // From CLIC IF
  input  irq_t        irq_i,

  // From CSR regfile
  input  mode_t       priv_lvl_i,
  input  logic        flush_i,

  // To CSR regfile
  output logic        csr_write_o,
  output csr_reg_t    csr_addr_o,
  output xlen_t       csr_wdata_o,
  output logic        mret_o,
  output logic        sret_o,
  output logic        inst_valid_o,
  output mode_t       inst_priv_lvl_o,
  output xlen_t       inst_pc_o,
  output irq_t        irq_o
);

  typedef struct packed {
    logic         valid;
    mode_t        priv_lvl;
    xlen_t        pc;
    irq_t         ex;
    instruction_t inst;
  } stage_t;

  // Next instruction (from instruction ROM)
  instruction_t next_inst;

  // Pipeline stages
  stage_t [N_STAGES-1:0] stages_q,
                         stages_d;
  // Helper signals
  stage_t       last_stage;
  instruction_t retiring_instruction;

  assign last_stage           = stages_q[N_STAGES-1];
  assign retiring_instruction = last_stage.inst;

  // pipeline input
  assign stages_d[0] = flush_i ? '0 : '{
    valid    : 1'b1,
    priv_lvl : priv_lvl_i,
    pc       : pc_i,
    inst     : next_inst,
    ex       : irq_i
  };

  generate
    for (genvar i = 0; i < N_STAGES-1; i++) begin
      assign stages_d[i+1] = flush_i ? '0 : stages_q[i];
    end
  endgenerate

  clic_memory #(
  ) i_instruction_rom (
    .clk_i    (clk_i),
    .addr_i   (pc_i),
    .rdata_o  (next_inst)
  );

  clic_tracer #(
  ) i_clic_tracer (
    .clk_i        (clk_i),
    .rst_ni       (rst_ni),

    .inst_valid_i (last_stage.valid),
    .priv_lvl_i   (last_stage.priv_lvl),
    .pc_i         (last_stage.pc),
    .inst_i       (last_stage.inst),

    .irq_i        (last_stage.ex)
  );

  always_comb begin // CSR instructions logic

    csr_write_o = 1'b0;
    csr_addr_o  = CSR_INVALID;
    csr_wdata_o = {XLEN{1'b0}};
    mret_o      = 1'b0;
    sret_o      = 1'b0;

    if(last_stage.valid) begin // retiring instruction is valid

      unique case (retiring_instruction.op)
  
        OP_NOP  : ;
        OP_CSRW : begin
          csr_write_o = 1'b1;
          csr_addr_o  = retiring_instruction.addr;
          csr_wdata_o = retiring_instruction.data;
        end
        OP_MRET : begin
          mret_o = 1'b1;
        end
        OP_SRET : begin
          sret_o = 1'b1;
        end
        default: begin end
  
      endcase

    end

  end

  // pipeline output
  assign inst_valid_o    = last_stage.valid;
  assign inst_priv_lvl_o = last_stage.priv_lvl;
  assign inst_pc_o       = last_stage.pc;
  assign irq_o           = last_stage.ex;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if(~rst_ni) begin
      stages_q <= '0;
    end else begin
      stages_q <= stages_d;
    end
  end

endmodule : clic_pipeline