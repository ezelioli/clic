package clic_tb_pkg;

  localparam XLEN = 64;

  typedef logic [XLEN-1:0] xlen_t;
  typedef logic      [7:0] intlvl_t;
  typedef logic      [7:0] intthresh_t;

  typedef struct packed {
    intlvl_t    mil;
    logic [7:0] rsv; // hsclic ?
    intlvl_t    sil; // ssclic
    intlvl_t    uil; // usclic
  } intstatus_t;

  typedef enum logic [1:0] {
    M_MODE = 2'b11,
    // H_MODE = 2'b10,
    S_MODE = 2'b01,
    U_MODE = 2'b00
  } mode_t;

  typedef struct packed {
    logic        irq;      //    63: Interrupt=1, Exception=0
    logic [31:0] rsv1;     // 62-31: Reserved
    logic        shv;      //    30: vector-mode enable (smclicshv)
    mode_t       mpp;      // 29-28: mpp  (from mstatus.mpp)
    logic        mpie;     //    27: mpie (from mstatus.mpie)
    logic  [2:0] rsv2;     // 26-24: Reserved
    logic  [7:0] mpil;     // 23-16: mpil
    logic  [3:0] rsv3;     // 15-12: Reserved
    logic [11:0] excode;   //  11-0: Excode
  } mcause_t;

  typedef struct packed {
    logic        irq;      //    63: Interrupt=1, Exception=0
    logic [31:0] rsv1;     // 62-31: Reserved
    logic        shv;      //    30: vector-mode enable (smclicshv)
    logic        rsv4;     //    29: Reserved
    logic        spp;      //    28: spp  (from mstatus.spp)
    logic        spie;     //    27: spie (from mstatus.xpie)
    logic  [2:0] rsv2;     // 26-24: Reserved
    logic  [7:0] spil;     // 23-16: spil
    logic  [3:0] rsv3;     // 15-12: Reserved
    logic [11:0] excode;   //  11-0: Excode
  } scause_t;

  typedef struct packed {
      logic         sd;     // signal dirty state - read-only
      logic [62:36] wpri4;  // writes preserved reads ignored
      logic   [1:0] sxl;    // variable supervisor mode xlen - hardwired to zero
      logic   [1:0] uxl;    // variable user mode xlen - hardwired to zero
      logic   [8:0] wpri3;  // writes preserved reads ignored
      logic         tsr;    // trap sret
      logic         tw;     // time wait
      logic         tvm;    // trap virtual memory
      logic         mxr;    // make executable readable
      logic         sum;    // permit supervisor user memory access
      logic         mprv;   // modify privilege - privilege level for ld/st
      logic   [1:0] xs;     // extension register - hardwired to zero
      logic   [1:0] fs;     // floating point extension register
      mode_t        mpp;    // holds the previous privilege mode up to machine
      logic   [1:0] wpri2;  // writes preserved reads ignored
      logic         spp;    // holds the previous privilege mode up to supervisor
      logic         mpie;   // machine interrupts enable bit active prior to trap
      logic         wpri1;  // writes preserved reads ignored
      logic         spie;   // supervisor interrupts enable bit active prior to trap
      logic         upie;   // user interrupts enable bit active prior to trap - hardwired to zero
      logic         mie;    // machine interrupts enable
      logic         wpri0;  // writes preserved reads ignored
      logic         sie;    // supervisor interrupts enable
      logic         uie;    // user interrupts enable - hardwired to zero
  } status_t;

  // All information from current status related to interrupts
  typedef struct packed {
    logic        xstatus_mie;
    logic        xstatus_sie;
    intthresh_t  mintthresh;
    intthresh_t  sintthresh;
    intstatus_t  mintstatus;
    logic        claim;
  } irq_ctrl_t;

  // Info about an incoming interrupt
  typedef struct packed {
    // Interrupt info
    logic        valid;
    logic        shv;
    mode_t       irq_priv;
    logic  [7:0] irq_lvl;
    logic [11:0] excode;
    // Hart state when taking interrupt
    mode_t       hart_priv_lvl;
    logic        hart_ie;
  } irq_t;

  // RISC-V interrupts encoding
  localparam int unsigned IRQ_S_SOFT  = 1;
  localparam int unsigned IRQ_M_SOFT  = 3;
  localparam int unsigned IRQ_S_TIMER = 5;
  localparam int unsigned IRQ_M_TIMER = 7;
  localparam int unsigned IRQ_S_EXT   = 9;
  localparam int unsigned IRQ_M_EXT   = 11;

  // CLIC TB parameters
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

  // CSRs
  typedef enum logic [11:0] {

    CSR_INVALID        = 12'h000,
        
    // Supervisor Mode CSRs
    CSR_SSTATUS        = 12'h100,
    CSR_SIE            = 12'h104,
    CSR_STVEC          = 12'h105,
    CSR_STVT           = 12'h107,
    CSR_SEPC           = 12'h141,
    CSR_SCAUSE         = 12'h142,
    CSR_STVAL          = 12'h143,
    CSR_SIP            = 12'h144,
    CSR_SINTTHRESH     = 12'h147,
    CSR_SINTSTATUS     = 12'hDB1,

    // Machine Mode CSRs
    CSR_MSTATUS        = 12'h300,
    CSR_MIE            = 12'h304,
    CSR_MTVEC          = 12'h305,
    CSR_MTVT           = 12'h307,
    CSR_MEPC           = 12'h341,
    CSR_MCAUSE         = 12'h342,
    CSR_MTVAL          = 12'h343,
    CSR_MIP            = 12'h344,
    CSR_MINTSTATUS     = 12'h346,
    CSR_MINTTHRESH     = 12'h347
  
  } csr_reg_t;

  localparam xlen_t SSTATUS_SIE  = 'h00000002;
  localparam xlen_t SSTATUS_SPIE = 'h00000020;
  localparam xlen_t SSTATUS_SPP  = 'h00000100;
  localparam xlen_t SSTATUS_FS   = 'h00006000;
  localparam xlen_t SSTATUS_SUM  = 'h00040000;
  localparam xlen_t SSTATUS_MXR  = 'h00080000;

  localparam xlen_t SMODE_STATUS_WRITE_MASK = SSTATUS_SIE
                                            | SSTATUS_SPIE
                                            | SSTATUS_SPP
                                            | SSTATUS_FS
                                            | SSTATUS_SUM
                                            | SSTATUS_MXR;

  // Instruction pipeline
  typedef enum logic [1:0] {
    OP_NOP  = 2'b00,
    OP_CSRW = 2'b01,
    OP_MRET = 2'b10,
    OP_SRET = 2'b11
  } opcode_t;

  typedef struct packed {
    logic [1:0] pad;
    opcode_t    op;
    csr_reg_t   addr;
    xlen_t      data;
  } instruction_t;

  typedef enum {
    ERR_GENERIC,
    ERR_ILLEGAL_MRET,
    ERR_ILLEGAL_SRET,
    ERR_MEPC_WRITE,
    ERR_MTVEC_WRITE,
    ERR_MSTATUS_WRITE,
    ERR_SEPC_WRITE,
    ERR_STVEC_WRITE,
    ERR_SSTATUS_WRITE,
    ERR_UNDEFINED_CSR_WRITE
  } error_t;

endpackage