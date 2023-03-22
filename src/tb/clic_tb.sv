import clic_tb_pkg::*;

module clic_tb;

  localparam int unsigned CLOCK_PERIOD = 20ns;

  longint unsigned cycles; 
  longint unsigned max_cycles; 

  // TB signals
  logic clk;
  logic rst_n;

  req_t                     reg_req;
  rsp_t                     reg_rsp;
  
  // External interrupt lines
  logic    [N_IRQ_SRCS-1:0] intr_src;

  // CLIC IF
  logic                     irq_valid;
  logic                     irq_ready;
  logic [IRQ_SRC_WIDTH-1:0] irq_id;
  logic               [7:0] irq_level;
  logic                     irq_shv;
  logic               [1:0] irq_priv;

  // Standard RISC-V interrupts (e.g. from CLINT)
  logic msip, mtip, meip; // machine software, timer, external interrupts
  logic ssip, stip, seip; // supervisor software, timer, external interrupts

  // RISC-V privileged spec interrupts
  logic [63:0] local_irqs;

  assign local_irqs = {
    {48{1'b0}},      // 64-16: designated for platform use
    {4{1'b0}},       // 15-12: reserved
    meip,            //    11: meip
    1'b0,            //    10: reserved
    seip,            //     9: seip
    1'b0,            //     8: reserved
    mtip,            //     7: mtip
    1'b0,            //     6: reserved
    stip,            //     5: stip
    1'b0,            //     4: reserved
    msip,            //     3: msip
    1'b0,            //     2: reserved
    ssip,            //     1: ssip
    1'b0             //     0: reserved
  };

  assign intr_src = {
    {(N_IRQ_SRCS-64){1'b0}},
    local_irqs
  };

  /////////////////////////////
  // CLIC registers buffers  //
  /////////////////////////////
  // Use these registers to store  the information read from 
  // the CLIC register file
  data_t  clic_info_d,     // CLIC INFO 
          clic_info_q;
  data_t  clic_cfg_d,      // CLIC CFG (Smclicconfig)
          clic_cfg_q;
  data_t  clic_intip_d,    // CLIC Interrupt pending
          clic_intip_q;
  data_t  clic_intie_d,    // CLIC Interrupt enable 
          clic_intie_q;
  data_t  clic_intattr_d,  // CLIC Interrupt Attributes 
          clic_intattr_q;
  data_t  clic_intctrl_d,  // CLIC Interrupt Control 
          clic_intctrl_q;

  ////////////////////////////
  //           DUT          //
  ////////////////////////////
  clic #(

    .N_SOURCE   (clic_reg_pkg::NumSrc),         // 256
    .INTCTLBITS (clic_reg_pkg::ClicIntCtlBits), // 8
    .reg_req_t  (req_t),
    .reg_rsp_t  (rsp_t)

  ) i_clic (
    
    .clk_i       (clk),
    .rst_ni      (rst_n),
    
    .reg_req_i   (reg_req),
    .reg_rsp_o   (reg_rsp),

    .intr_src_i  (intr_src),

    .irq_valid_o (irq_valid),
    .irq_ready_i (irq_ready),
    .irq_id_o    (irq_id),
    .irq_level_o (irq_level),
    .irq_shv_o   (irq_shv),
    .irq_priv_o  (irq_priv)
  );

  // Simple CLIC target (simulates hart behaviour)
  clic_controller #(

    .N_SOURCE   (clic_reg_pkg::NumSrc),         // 256
    .INTCTLBITS (clic_reg_pkg::ClicIntCtlBits)  // 8
  
  ) i_clic_controller (

    .clk_i             (clk),
    .rst_ni            (rst_n),

    // CLIC IF
    .clic_irq_valid_i  (irq_valid),
    .clic_irq_ready_o  (irq_ready),
    .clic_irq_id_i     (irq_id),
    .clic_irq_level_i  (irq_level),
    .clic_irq_shv_i    (irq_shv),
    .clic_irq_priv_i   (irq_priv)
  );

  /////////////////////////
  //  RST/CLK generator  //
  /////////////////////////
  initial begin
    cycles = 0;
    max_cycles = 1000; // Note: simulation stops after max_cycles
    clk   = 1'b0;
    rst_n = 1'b0;
    repeat(8)
      #(CLOCK_PERIOD/2) clk = ~clk;
    rst_n = 1'b1;
    forever begin
      #(CLOCK_PERIOD/2) clk = 1'b1;
      #(CLOCK_PERIOD/2) clk = 1'b0;

      if(cycles > max_cycles) begin
        $stop();
      end

      cycles++;
    end
  end


  /////////////////////////////////
  //    Write buffer registers   //
  /////////////////////////////////
  always_comb begin : reg_write

    clic_info_d = clic_info_q;
    clic_cfg_d = clic_cfg_q;
    clic_intip_d = clic_intip_q;
    clic_intie_d = clic_intie_q;
    clic_intattr_d = clic_intattr_q;
    clic_intctrl_d = clic_intctrl_q;

    if(reg_req.valid == 1'b1 && reg_rsp.ready == 1'b1) begin
      
      unique case (reg_req.addr) inside

        clic_reg_pkg::CLIC_CLICINFO_OFFSET: begin
          clic_info_d = reg_rsp.rdata;
        end
        
        clic_reg_pkg::CLIC_CLICCFG_OFFSET: begin
          clic_cfg_d = reg_rsp.rdata;
        end

        clic_reg_pkg::CLIC_CLICINTIP_MASK: begin
          clic_intip_d = reg_rsp.rdata;
        end

        clic_reg_pkg::CLIC_CLICINTIE_MASK: begin
          clic_intie_d = reg_rsp.rdata;
        end

        clic_reg_pkg::CLIC_CLICINTATTR_MASK: begin
          clic_intattr_d = reg_rsp.rdata;
        end
      
        clic_reg_pkg::CLIC_CLICINTCTRL_MASK: begin
          clic_intctrl_d = reg_rsp.rdata;
        end

        default: begin
          clic_info_d    = clic_info_q;
          clic_cfg_d     = clic_cfg_q;
          clic_intip_d   = clic_intip_q;
          clic_intie_d   = clic_intie_q;
          clic_intattr_d = clic_intattr_q;
          clic_intctrl_d = clic_intctrl_q;
        end

      endcase
    end

  end

  /////////////////////////////
  //      Helper tasks       //
  /////////////////////////////
  
  // Write CLIC register
  task clic_reg_write(input int unsigned addr, data);
    @(posedge clk);
    reg_req.wdata = data;
    reg_req.write = 1'b1;
    reg_req.addr  = addr;
    reg_req.valid = 1'b1;
    @(posedge clk);
    reg_req.wdata = 32'h0000_0000;
    reg_req.write = 1'b0;
    reg_req.addr  = '0;
    reg_req.valid = 1'b0;
  endtask

  // Read CLIC register
  task clic_reg_read(input int unsigned addr);
    @(posedge clk);
    reg_req.addr  = addr;
    reg_req.valid = 1'b1;
    @(posedge clk);
    reg_req.addr  = '0;
    reg_req.valid = 1'b0;
  endtask

  ///////////////////////////// 
  //     Testbench logic     //
  /////////////////////////////
  // Manually set external interrup signals (e.g. M/S-mode Timer Interrupts (m/stip))
  // to simulate a precise external interrupts pattern
  initial begin 

    // initialize
    reg_req.valid =  1'b0;
    reg_req.addr  = 32'b0;
    reg_req.wstrb =  1'b0;    
    reg_req.wdata = 32'b0;
    reg_req.write =  1'b0;

    // external interrupts
    msip = 1'b0;
    mtip = 1'b0;
    meip = 1'b0;
    ssip = 1'b0;
    stip = 1'b0;
    seip = 1'b0;

    // CLIC global configuration
    wait(cycles == 20);
    clic_reg_write(clic_reg_pkg::CLIC_CLICCFG_OFFSET, 32'b0101_0000); // set nmbits=2, nlbits=8, nvbits=0

    // Read global information/configuration registers
    wait(cycles == 50);
    clic_reg_read(clic_reg_pkg::CLIC_CLICINFO_OFFSET);
    clic_reg_read(clic_reg_pkg::CLIC_CLICCFG_OFFSET);

    // Set-up machine and supervisor timer interrupts configuration
    wait(cycles == 100);
    clic_reg_write(32'h0000_1058, 32'b0100_0000); // set clicintattr[STIP].{shv=0, trig=0b00, mode=0b01} (not vectored, positive-level-triggered, S-mode)
    clic_reg_write(32'h0000_1078, 32'b1100_0000); // set clicintattr[MTIP].{shv=0, trig=0b00, mode=0b11} (not vectored, positive-level-triggered, M-mode)

    // Set mtip/stip priorities
    wait(cycles == 120);
    clic_reg_write(32'h0000_107C, 32'h01); // set clicintctrl[MTIP] = 1 (priority/level)
    clic_reg_write(32'h0000_105C, 32'h02); // set clicintctrl[STIP] = 2 (priority/level)

    // Enable mtip/stip
    wait(cycles == 140);
    clic_reg_write(32'h0000_1074, 32'b1); // set clicintie[MTIP] = 1
    clic_reg_write(32'h0000_1054, 32'b1); // set clicintie[STIP] = 1

    // Simulate both interrupts arriving at the same time
    wait(cycles == 200);
    @(posedge clk);
    mtip = 1'b1;
    stip = 1'b1;
    @(posedge clk);

    // External mtip is de-asserted (software also needs to explicitly clear the clicintip register)
    wait(cycles == 300);
    mtip = 1'b0;
    // clic_reg_write(32'h0000_1070, 32'h0); // clear clicintip[MTIP] = 0

    // External stip is de-asserted (software also needs to explicitly clear the clicintip register)
    wait(cycles == 350);
    stip = 1'b0;
    // clic_reg_write(32'h0000_1050, 32'h0); // clear clicintip[STIP] = 0

    wait(cycles == 400);
    // stip = 1'b0;

    // wait forever
    forever begin
      @(posedge clk);
    end

  end

  // FFs to save CLIC registers content
  always_ff @(posedge clk or negedge rst_n) begin

    if (~rst_n) begin
      clic_info_q    <= '0;
      clic_cfg_q     <= '0;
      clic_intip_q   <= '0;
      clic_intie_q   <= '0;
      clic_intattr_q <= '0;
      clic_intctrl_q <= '0;
    end else begin
      clic_info_q    <= clic_info_d;
      clic_cfg_q     <= clic_cfg_d;
      clic_intip_q   <= clic_intip_d;
      clic_intie_q   <= clic_intie_d;
      clic_intattr_q <= clic_intattr_d;
      clic_intctrl_q <= clic_intctrl_d;
    end

  end

endmodule