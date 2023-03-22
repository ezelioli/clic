import clic_tb_pkg::*;

module clic_tracer #(
  parameter string FILENAME = "traces/trace.log"
) (
  input  logic         clk_i,
  input  logic         rst_ni,

  input  logic         inst_valid_i,
  input  mode_t        priv_lvl_i,
  input  xlen_t        pc_i,
  input  instruction_t inst_i,

  input  irq_t         irq_i
);
  
  int f; // trace file descriptor
  longint unsigned clk_ticks;

  function void create_file();
    $display("[TRACER] Output filename is: %s", FILENAME);
    f = $fopen(FILENAME,"w");
  endfunction : create_file

  function void close();
    if (f) $fclose(f);
  endfunction : close

  task trace();

    forever begin

      automatic string inst_mnemonic = " INV";
      automatic string inst_data     = "0x0000_0000_0000_0000";
      automatic string inst_addr     = "0x000";
      automatic string pc            = "0x0000_0000_0000_0000";
      automatic string priv_lvl      = "M";
      automatic string reset         = "";
      automatic string cycles        = "";
      automatic string timestamp     = "";
      automatic string irq_type      = "I";
      automatic string irq_lvl       = "0x0";
      automatic string irq_excode    = "0x0";
      automatic string irq_shv       = "0";
      automatic string irq_xpie      = "0";

      @(posedge clk_i);

      clk_ticks++;

      if(~rst_ni) begin
        reset = "[R] ";
      end
  
      unique case (inst_i.op)
        OP_NOP  : inst_mnemonic = " NOP";
        OP_CSRW : inst_mnemonic = "CSRW";
        OP_MRET : inst_mnemonic = "MRET";
        OP_SRET : inst_mnemonic = "SRET";
        default : inst_mnemonic = " INV";
      endcase
  
      unique case (priv_lvl_i)
        M_MODE  : priv_lvl = "M";
        S_MODE  : priv_lvl = "S";
        U_MODE  : priv_lvl = "U";
        default : priv_lvl = "I";
      endcase

      irq_type     = 1'b1 ? "I" : "E"; // only interrupts supported for now
    
      $sformat(timestamp,  "%t", $time);
      $sformat(cycles,     "0x%X", clk_ticks);
      $sformat(inst_data,  "0x%X", inst_i.data);
      $sformat(inst_addr,  "0x%X (%s)", inst_i.addr, inst_i.addr.name());
      $sformat(pc,         "0x%X", pc_i);
      $sformat(irq_lvl,    "0x%X", irq_i.irq_lvl);
      $sformat(irq_excode, "0x%X", irq_i.excode);
      $sformat(irq_shv,    "%d",   irq_i.shv);
      $sformat(irq_xpie,   "%d",   irq_i.hart_ie);
    
      if(inst_valid_i) begin
        $fwrite(f, {timestamp, " ", cycles, " ", reset, "Mode: ", priv_lvl, " PC: ", pc, ", Instruction: ", inst_mnemonic, ", Addr: ", inst_addr, ", Data: ", inst_data, "\n"});
      end

      if(irq_i.valid) begin
        $fwrite(f, {"~~~> ", timestamp, " PC: ", pc, ", Type: ", irq_type, " , Priv: ", irq_i.irq_priv.name(), " , Lvl: ", irq_lvl, " , Cause: ", irq_excode, ", Shv: ", irq_shv, ", xPP: ", irq_i.hart_priv_lvl.name(), " , xPIE: ", irq_xpie, "\n"});
      end

    end

  endtask : trace

  initial begin
    $timeformat(-9, 2, " ns", 12);
    #15ns;
    clk_ticks = 0;
    create_file();
    trace();
  end

  final begin
    close();
  end

endmodule : clic_tracer
