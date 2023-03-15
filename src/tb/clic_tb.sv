module clic_tb;

  localparam int unsigned CLOCK_PERIOD = 20ns;

  localparam int unsigned N_IRQ_SRCS    = clic_reg_pkg::NumSrc;
  localparam int unsigned IRQ_SRC_WIDTH = $clog2(N_IRQ_SRCS);

  localparam int unsigned REG_BUS_ADDR_WIDTH = 32;
  localparam int unsigned REG_BUS_DATA_WIDTH = 32;

  typedef logic   [REG_BUS_ADDR_WIDTH-1:0] addr_t;
  typedef logic   [REG_BUS_DATA_WIDTH-1:0] data_t;
  typedef logic [REG_BUS_DATA_WIDTH/8-1:0] strb_t;

  `define CLIC_INT_ATTR_OFFSET(i) (32'h1008 + 16*i)

  typedef struct packed {
    addr_t addr;
    logic  write;
    data_t wdata;
    logic  wstrb;
    logic  valid;
  } req_t;

  typedef struct packed {
    data_t rdata;
    logic  ready;
    logic  error;
  } rsp_t;

  longint unsigned cycles; 
  longint unsigned max_cycles; 

  // TB signals
  logic clk;
  logic rst_n;

  req_t                     reg_req;
  rsp_t                     reg_rsp;
  logic    [N_IRQ_SRCS-1:0] intr_src;
  logic                     irq_valid;
  logic                     irq_ready;
  logic [IRQ_SRC_WIDTH-1:0] irq_id;
  logic               [7:0] irq_level;
  logic                     irq_shv;

  // CLIC registers buffers
  
  // CLIC INFO
  data_t  clic_info_d, 
          clic_info_q;
  
  // CLIC CFG (Smclicconfig extension)
  data_t  clic_cfg_d, 
          clic_cfg_q;
  
  // CLIC Interrupt pending
  data_t  clic_intip_d, 
          clic_intip_q;
  
  // CLIC Interrupt enable
  data_t  clic_intie_d, 
          clic_intie_q;
  
  // CLIC Interrupt Attributes
  data_t  clic_intattr_d, 
          clic_intattr_q;
  
  // CLIC Interrupt Control
  data_t  clic_intctrl_d, 
          clic_intctrl_q;

  // DUT
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
    .irq_shv_o   (irq_shv)
  );

  // RST/CLK generation
  initial begin
    cycles = 0;
    max_cycles = 1000;
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
        // $fatal(1, "Simulation reached maximum cycle count (%d)", cycles);
      end

      cycles++;
    end
  end


  // Default signals
  always_comb begin

    intr_src  = 8'b0;
    irq_ready = 1'b0;

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
          clic_info_d = clic_info_q;
          clic_cfg_d = clic_cfg_q;
          clic_intip_d = clic_intip_q;
          clic_intie_d = clic_intie_q;
          clic_intattr_d = clic_intattr_q;
          clic_intctrl_d = clic_intctrl_q;
        end

      endcase
    end

  end

  // Helper tasks to read/write CLIC registers
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

  task clic_reg_read(input int unsigned addr);
    @(posedge clk);
    reg_req.addr  = addr;
    reg_req.valid = 1'b1;
    @(posedge clk);
    reg_req.addr  = '0;
    reg_req.valid = 1'b0;
  endtask

  // stuff happens here
  initial begin 

    // initialize
    reg_req.valid =  1'b0;
    reg_req.addr  = 32'b0;
    reg_req.wstrb =  1'b0;    
    reg_req.wdata = 32'b0;
    reg_req.write =  1'b0;

    // write registers
    wait(cycles == 24);
    clic_reg_write(clic_reg_pkg::CLIC_CLICINFO_OFFSET, 32'hAAAA_AAAA); // read-only
    clic_reg_write(clic_reg_pkg::CLIC_CLICCFG_OFFSET, 32'h0000_0010); // set nmbits=0, nlbits=8, nvbits=0

    // read back registers
    wait(cycles == 49);
    clic_reg_read(clic_reg_pkg::CLIC_CLICINFO_OFFSET);
    clic_reg_read(clic_reg_pkg::CLIC_CLICCFG_OFFSET);

    wait(cycles == 100);
    clic_reg_write(32'h0000_1008, 32'b1100_0010); // set clicintattr[0].{shv=0, trig=0b01, mode=0b11} (not vectored, positive-edge-triggered, M-mode)
    clic_reg_read(32'h0000_1008);

    // wait forever
    forever begin
      @(posedge clk);
    end

  end

  // FFs to save CLIC registers content
  always_ff @(posedge clk or negedge rst_n) begin

    if (!rst_n) begin
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