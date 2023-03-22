add wave -group tb {sim:/clic_tb/*}

add wave -group clic {sim:/clic_tb/i_clic/*}

add wave -group clic -group gw {sim:/clic_tb/i_clic/u_gateway/*}

add wave -group clic -group reg {sim:/clic_tb/i_clic/u_reg/*}

add wave -group clic -group tgt {sim:/clic_tb/i_clic/u_target/*}

add wave -group controller {sim:/clic_tb/i_clic_controller/*}

add wave -group controller -group clic_if {sim:/clic_tb/i_clic_controller/i_clic_if/*}

add wave -group controller -group csr_regfile {sim:/clic_tb/i_clic_controller/i_clic_csr_regfile/*}

add wave -group controller -group pipeline {sim:/clic_tb/i_clic_controller/i_clic_pipeline/*}

add wave -group controller -group pipeline -group i_rom -group bank0 {sim:/clic_tb/i_clic_controller/i_clic_pipeline/i_instruction_rom/genblk1[0]/i_generic_rom/*}
add wave -group controller -group pipeline -group i_rom -group bank1 {sim:/clic_tb/i_clic_controller/i_clic_pipeline/i_instruction_rom/genblk1[1]/i_generic_rom/*}
add wave -group controller -group pipeline -group i_rom -group bank2 {sim:/clic_tb/i_clic_controller/i_clic_pipeline/i_instruction_rom/genblk1[2]/i_generic_rom/*}
add wave -group controller -group pipeline -group i_rom -group bank3 {sim:/clic_tb/i_clic_controller/i_clic_pipeline/i_instruction_rom/genblk1[3]/i_generic_rom/*}



add wave -group regs sim:/clic_tb/clic_info_q \
					 sim:/clic_tb/clic_cfg_q \
					 sim:/clic_tb/clic_intip_q \
					 sim:/clic_tb/clic_intie_q \
					 sim:/clic_tb/clic_intattr_q \
					 sim:/clic_tb/clic_intctrl_q 