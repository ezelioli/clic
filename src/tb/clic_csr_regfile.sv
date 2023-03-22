import clic_tb_pkg::*;

module clic_csr_regfile #(
  localparam SHV_SHIFT_W = $clog2(XLEN/8)
) (
  input  logic        clk_i,
  input  logic        rst_ni,

  // From pipeline
  input  logic        csr_write_i,
  input  csr_reg_t    csr_addr_i,
  input  xlen_t       csr_wdata_i,
  input  logic        mret_i,
  input  logic        sret_i,
  input  logic        inst_valid_i,
  input  mode_t       inst_priv_lvl_i,
  input  xlen_t       inst_pc_i,
  input  irq_t        irq_i,

  // Controller status
  output mode_t       priv_lvl_o,
  output xlen_t       pc_o,
  output irq_ctrl_t   irq_ctrl_o,
  output logic        flush_o
);
  
  ////////////////////////////////////
  //        Internal signals        //
  ////////////////////////////////////

  // Current privilege level
  mode_t      priv_lvl_q, 
              priv_lvl_d;

  // Status register
  status_t    xstatus_q,
              xstatus_d;

  // Machine interrupt threshold
  intthresh_t mintthresh_q,
              mintthresh_d;

  // Supervisor interrupt threshold
  intthresh_t sintthresh_q,
              sintthresh_d;

  // Machine interrupt cause
  mcause_t    mcause_q,
              mcause_d;

  // Supervisor interrupt cause
  scause_t    scause_q,
              scause_d;

  // Machine interrupt status
  intstatus_t mintstatus_q,
              mintstatus_d;

  // Machine trap vector base
  xlen_t      mtvec_q,
              mtvec_d;

  // Supervisor trap vector base
  xlen_t      stvec_q,
              stvec_d;

  // Machine trap vector table
  xlen_t      mtvt_q,
              mtvt_d;

  // Supervisor trap vector table
  xlen_t      stvt_q,
              stvt_d;

  // Program counter
  xlen_t      pc_q,
              pc_d;

  // Machine exception program counter
  xlen_t      mepc_q,
              mepc_d;

  // Supervisor exception program counter
  xlen_t      sepc_q,
              sepc_d;

  // Helper signals
  logic   illegal_instruction;
  error_t error_cause_q, error_cause_d;
  xlen_t  mask;
  
  always_comb begin

    illegal_instruction = 1'b0;
    error_cause_d       = error_cause_q;
    mask                = '0;

    priv_lvl_d    = priv_lvl_q;
    mintstatus_d  = mintstatus_q;
    mcause_d      = mcause_q;
    scause_d      = scause_q;
    mintthresh_d  = mintthresh_q;
    sintthresh_d  = sintthresh_q;
    mepc_d        = mepc_q;
    sepc_d        = sepc_q;
    mtvec_d       = mtvec_q;
    stvec_d       = stvec_q;
    mtvt_d        = mtvt_q;
    stvt_d        = stvt_q;
    xstatus_d     = xstatus_q;
    
    flush_o        = 1'b0;

    if(irq_i.valid) begin // the retiring instruction is associated with an interrupt
        
      priv_lvl_d     = irq_i.irq_priv;
      flush_o        = 1'b1;

      unique case (irq_i.irq_priv)
      
        M_MODE: begin

          // update mstatus
          xstatus_d.mie    = 1'b0;
          xstatus_d.mpp    = irq_i.hart_priv_lvl;
          xstatus_d.mpie   = irq_i.hart_ie;

          // update mcause
          mcause_d.irq     = 1'b1;
          mcause_d.shv     = irq_i.shv;
          mcause_d.mpp     = irq_i.hart_priv_lvl;  // same as xstatus.mpp
          mcause_d.mpie    = irq_i.hart_ie;        // same as xstatus.mpie
          mcause_d.mpil    = mintstatus_q.mil;     // save current machine interrupt level
          mcause_d.excode  = irq_i.excode;

          // update mintstatus
          mintstatus_d.mil = irq_i.irq_lvl;        // update current machine interrupt level
          
          // update mepc
          mepc_d           = inst_pc_i;

          // jump to M-mode trap handler
          // WARNING: this implementation of vectored mode is NOT compliant with the CLIC specification
          if(irq_i.shv) begin
            pc_d           = {mtvt_q[XLEN-1:6], 6'b0} + {{(XLEN-12-SHV_SHIFT_W){irq_i.excode}}, {SHV_SHIFT_W{1'b0}}}; // WARNING: NOT COMPLIANT!!
          end else begin
            pc_d           = {mtvec_q[XLEN-1:6], 6'b0};
          end

        end

        S_MODE: begin

          // update sstatus
          xstatus_d.sie    = 1'b0;
          xstatus_d.spp    = logic'(irq_i.hart_priv_lvl == S_MODE);
          xstatus_d.spie   = irq_i.hart_ie;

          // update scause
          scause_d.irq     = 1'b1;
          scause_d.shv     = irq_i.shv;
          scause_d.spp     = logic'(irq_i.hart_priv_lvl == S_MODE);  // same as xstatus.spp
          scause_d.spie    = irq_i.hart_ie;                          // same as xstatus.spie
          scause_d.spil    = mintstatus_q.sil;                       // save current supervisor interrupt level
          scause_d.excode  = irq_i.excode;

          // update mintstatus
          mintstatus_d.sil = irq_i.irq_lvl;                          // update current supervisor interrupt level
          
          // update sepc
          sepc_d           = inst_pc_i;

          // jump to S-mode trap handler
          // WARNING: this implementation of vectored mode is NOT compliant with the CLIC specification
          if(irq_i.shv) begin
            pc_d           = {stvt_q[XLEN-1:6], 6'b0} + {{(XLEN-12-SHV_SHIFT_W){irq_i.excode}}, {SHV_SHIFT_W{1'b0}}}; // WARNING: NOT COMPLIANT!!
          end else begin
            pc_d           = {stvec_q[XLEN-1:6], 6'b0};
          end

        end

        default:;

      endcase

    end else begin // no interrupts

      pc_d = pc_q + 1;

      if (inst_valid_i) begin // retiring instruction is valid
      
        if(mret_i) begin // MRET retiring

          if(inst_priv_lvl_i != M_MODE) begin
            error_cause_d         = ERR_ILLEGAL_MRET;
            illegal_instruction = 1'b1;
          end else begin
            pc_d             = mepc_q;
            priv_lvl_d       = xstatus_q.mpp;
            xstatus_d.mie    = xstatus_q.mpie;
            xstatus_d.mpie   = 1'b1;
            xstatus_d.mpp    = U_MODE;
            mintstatus_d.mil = mcause_q.mpil;
            flush_o          = 1'b1;
          end

        end else if(sret_i) begin // SRET retiring

          if(inst_priv_lvl_i != S_MODE) begin
            error_cause_d         = ERR_ILLEGAL_SRET;
            illegal_instruction = 1'b1;
          end else begin
            pc_d             = sepc_q;
            priv_lvl_d       = xstatus_q.spp ? S_MODE : U_MODE;
            xstatus_d.sie    = xstatus_q.spie;
            xstatus_d.spie   = 1'b1;
            xstatus_d.spp    = U_MODE;
            mintstatus_d.sil = scause_q.spil;
            flush_o          = 1'b1;
          end

        end else if(csr_write_i) begin

          unique case (csr_addr_i)

            CSR_MEPC : begin
              if(inst_priv_lvl_i != M_MODE) begin
                error_cause_d         = ERR_MEPC_WRITE;
                illegal_instruction = 1'b1;
              end else begin
                mepc_d = csr_wdata_i;
              end
            end

            CSR_MTVEC : begin
              if(inst_priv_lvl_i != M_MODE) begin
                error_cause_d         = ERR_MTVEC_WRITE;
                illegal_instruction = 1'b1;
              end else begin
                mtvec_d = csr_wdata_i;
              end
            end

            CSR_MSTATUS : begin
              if(inst_priv_lvl_i != M_MODE) begin
                error_cause_d         = ERR_MSTATUS_WRITE;
                illegal_instruction = 1'b1;
              end else begin
                xstatus_d = csr_wdata_i;
              end
            end

            CSR_SEPC : begin
              if((inst_priv_lvl_i != M_MODE) && (inst_priv_lvl_i != S_MODE)) begin
                error_cause_d         = ERR_SEPC_WRITE;
                illegal_instruction = 1'b1;
              end else begin
                sepc_d = csr_wdata_i;
              end
            end

            CSR_STVEC : begin
              if((inst_priv_lvl_i != M_MODE) && (inst_priv_lvl_i != S_MODE)) begin
                error_cause_d         = ERR_STVEC_WRITE;
                illegal_instruction = 1'b1;
              end else begin
                stvec_d = csr_wdata_i;
              end
            end

            CSR_SSTATUS : begin
              if((inst_priv_lvl_i != M_MODE) && (inst_priv_lvl_i != S_MODE)) begin
                error_cause_d         = ERR_SSTATUS_WRITE;
                illegal_instruction = 1'b1;
              end else begin
                mask = SMODE_STATUS_WRITE_MASK;
                xstatus_d = (xstatus_q & ~mask) | (csr_wdata_i & mask);
              end
            end
        
            default : begin
              error_cause_d         = ERR_UNDEFINED_CSR_WRITE;
              illegal_instruction = 1'b1;
            end
        
          endcase

        end

      end

    end

  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if(~rst_ni) begin
      priv_lvl_q   <= M_MODE;
      pc_q         <= '0;
      mepc_q       <= '0;
      sepc_q       <= '0;
      mintthresh_q <= '0;
      sintthresh_q <= '0;
      mintstatus_q <= '0;
      mcause_q     <= '0;
      scause_q     <= '0;
      mtvec_q      <= '0;
      stvec_q      <= '0;
      mtvt_q       <= '0;
      stvt_q       <= '0;
      xstatus_q    <= '{
        mpp     : M_MODE,  // MPP defaults to M-mode
        mie     : 1'b0,    // M-mode interrupts disabled
        sie     : 1'b0,    // S-mode interrupts disabled
        default : '0
      };

      error_cause_q <= ERR_GENERIC;
    end else begin
      priv_lvl_q   <= priv_lvl_d;
      pc_q         <= pc_d;
      mepc_q       <= mepc_d;
      sepc_q       <= sepc_d;
      mintthresh_q <= mintthresh_d;
      sintthresh_q <= sintthresh_d;
      mintstatus_q <= mintstatus_d;
      mcause_q     <= mcause_d;
      scause_q     <= scause_d;
      mtvec_q      <= mtvec_d;
      stvec_q      <= stvec_d;
      mtvt_q       <= mtvt_d;
      stvt_q       <= stvt_d;
      xstatus_q    <= xstatus_d;

      error_cause_q <= error_cause_d;
    end
  end

  // assign outputs
  assign priv_lvl_o = priv_lvl_q;
  assign pc_o       = pc_q;
  assign irq_ctrl_o = '{
    xstatus_mie : xstatus_q.mie,
    xstatus_sie : xstatus_q.sie,
    mintthresh  : mintthresh_q,
    sintthresh  : sintthresh_q,
    mintstatus  : mintstatus_q,
    claim       : irq_i.valid
  };

  // stop simulation if illegal instruction is executed (do not implement exception handling)
  assert property (
    @(posedge clk_i) disable iff (!rst_ni !== 1'b0) !(illegal_instruction))
  else begin $error("Illegal instruction (%0s)", error_cause_q.name()); $stop(); end

endmodule : clic_csr_regfile