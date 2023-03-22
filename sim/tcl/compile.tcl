# This script was generated automatically by bender.
set ROOT "/home/msc23f1/workdir/forks/clic"

if {[catch {vlog -incr -sv \
    -work sim/work \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_VSIM \
    "$ROOT/.bender/git/checkouts/common_verification-d201c9cb50868760/src/clk_rst_gen.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-d201c9cb50868760/src/rand_id_queue.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-d201c9cb50868760/src/rand_stream_mst.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-d201c9cb50868760/src/rand_synch_holdable_driver.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-d201c9cb50868760/src/rand_verif_pkg.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-d201c9cb50868760/src/signal_highlighter.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-d201c9cb50868760/src/sim_timeout.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-d201c9cb50868760/src/stream_watchdog.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-d201c9cb50868760/src/rand_synch_driver.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-d201c9cb50868760/src/rand_stream_slv.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -work sim/work \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_VSIM \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-8c3c5437f1bc3808/src/rtl/tc_sram.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-8c3c5437f1bc3808/src/rtl/tc_sram_impl.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -work sim/work \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_VSIM \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-8c3c5437f1bc3808/src/rtl/tc_clk.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -work sim/work \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_VSIM \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-8c3c5437f1bc3808/src/deprecated/cluster_pwr_cells.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-8c3c5437f1bc3808/src/deprecated/generic_memory.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-8c3c5437f1bc3808/src/deprecated/generic_rom.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-8c3c5437f1bc3808/src/deprecated/pad_functional.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-8c3c5437f1bc3808/src/deprecated/pulp_buffer.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-8c3c5437f1bc3808/src/deprecated/pulp_pwr_cells.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -work sim/work \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_VSIM \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-8c3c5437f1bc3808/src/tc_pwr.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -work sim/work \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_VSIM \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-8c3c5437f1bc3808/src/deprecated/pulp_clock_gating_async.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-8c3c5437f1bc3808/src/deprecated/cluster_clk_cells.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-8c3c5437f1bc3808/src/deprecated/pulp_clk_cells.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -work sim/work \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/include" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/binary_to_gray.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -work sim/work \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/include" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/cb_filter_pkg.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -work sim/work \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/include" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/cc_onehot.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/cf_math_pkg.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/clk_int_div.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/delta_counter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/ecc_pkg.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/edge_propagator_tx.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/exp_backoff.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/fifo_v3.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/gray_to_binary.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/isochronous_4phase_handshake.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/isochronous_spill_register.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/lfsr.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/lfsr_16bit.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/lfsr_8bit.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/mv_filter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/onehot_to_bin.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/plru_tree.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/popcount.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/rr_arb_tree.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/rstgen_bypass.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/serial_deglitch.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/shift_reg.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/spill_register_flushable.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/stream_demux.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/stream_filter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/stream_fork.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/stream_intf.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/stream_join.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/stream_mux.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/stream_throttle.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/sub_per_hash.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/sync.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/sync_wedge.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/unread.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/read.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/cdc_reset_ctrlr_pkg.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/addr_decode_napot.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/cdc_2phase.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/cdc_4phase.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/addr_decode.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -work sim/work \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/include" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/cb_filter.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -work sim/work \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/include" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/cdc_fifo_2phase.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/counter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/ecc_decode.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/ecc_encode.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/edge_detect.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/lzc.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/max_counter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/rstgen.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/spill_register.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/stream_delay.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/stream_fifo.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/stream_fork_dynamic.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/clk_mux_glitch_free.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/cdc_reset_ctrlr.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/cdc_fifo_gray.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/fall_through_register.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/id_queue.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/stream_to_mem.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/stream_arbiter_flushable.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/stream_fifo_optimal_wrap.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/stream_register.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/stream_xbar.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/cdc_fifo_gray_clearable.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/cdc_2phase_clearable.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/mem_to_banks.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/stream_arbiter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/stream_omega_net.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -work sim/work \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/include" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/deprecated/sram.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -work sim/work \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/include" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/deprecated/clock_divider_counter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/deprecated/clk_div.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/deprecated/find_first_one.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/deprecated/generic_LFSR_8bit.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/deprecated/generic_fifo.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/deprecated/prioarbiter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/deprecated/pulp_sync.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/deprecated/pulp_sync_wedge.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/deprecated/rrarbiter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/deprecated/clock_divider.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/deprecated/fifo_v2.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/deprecated/fifo_v1.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/edge_propagator_ack.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/edge_propagator.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/src/edge_propagator_rx.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -work sim/work \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/apb-a6842004b4264fbe/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/include" \
    "$ROOT/.bender/git/checkouts/apb-a6842004b4264fbe/src/apb_pkg.sv" \
    "$ROOT/.bender/git/checkouts/apb-a6842004b4264fbe/src/apb_intf.sv" \
    "$ROOT/.bender/git/checkouts/apb-a6842004b4264fbe/src/apb_err_slv.sv" \
    "$ROOT/.bender/git/checkouts/apb-a6842004b4264fbe/src/apb_regs.sv" \
    "$ROOT/.bender/git/checkouts/apb-a6842004b4264fbe/src/apb_cdc.sv" \
    "$ROOT/.bender/git/checkouts/apb-a6842004b4264fbe/src/apb_demux.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -work sim/work \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/apb-a6842004b4264fbe/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/include" \
    "$ROOT/.bender/git/checkouts/apb-a6842004b4264fbe/src/apb_test.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -work sim/work \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/include" \
    "+incdir+$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/include" \
    "$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/src/axi_pkg.sv" \
    "$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/src/axi_intf.sv" \
    "$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/src/axi_atop_filter.sv" \
    "$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/src/axi_burst_splitter.sv" \
    "$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/src/axi_cdc_dst.sv" \
    "$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/src/axi_cdc_src.sv" \
    "$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/src/axi_cut.sv" \
    "$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/src/axi_delayer.sv" \
    "$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/src/axi_demux.sv" \
    "$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/src/axi_dw_downsizer.sv" \
    "$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/src/axi_dw_upsizer.sv" \
    "$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/src/axi_fifo.sv" \
    "$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/src/axi_id_remap.sv" \
    "$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/src/axi_id_prepend.sv" \
    "$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/src/axi_isolate.sv" \
    "$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/src/axi_join.sv" \
    "$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/src/axi_lite_demux.sv" \
    "$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/src/axi_lite_join.sv" \
    "$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/src/axi_lite_lfsr.sv" \
    "$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/src/axi_lite_mailbox.sv" \
    "$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/src/axi_lite_mux.sv" \
    "$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/src/axi_lite_regs.sv" \
    "$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/src/axi_lite_to_apb.sv" \
    "$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/src/axi_lite_to_axi.sv" \
    "$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/src/axi_modify_address.sv" \
    "$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/src/axi_mux.sv" \
    "$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/src/axi_serializer.sv" \
    "$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/src/axi_throttle.sv" \
    "$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/src/axi_to_mem.sv" \
    "$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/src/axi_cdc.sv" \
    "$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/src/axi_err_slv.sv" \
    "$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/src/axi_dw_converter.sv" \
    "$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/src/axi_id_serialize.sv" \
    "$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/src/axi_lfsr.sv" \
    "$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/src/axi_multicut.sv" \
    "$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/src/axi_to_axi_lite.sv" \
    "$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/src/axi_to_mem_banked.sv" \
    "$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/src/axi_to_mem_interleaved.sv" \
    "$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/src/axi_to_mem_split.sv" \
    "$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/src/axi_iw_converter.sv" \
    "$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/src/axi_lite_xbar.sv" \
    "$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/src/axi_xbar.sv" \
    "$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/src/axi_xp.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -work sim/work \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/include" \
    "+incdir+$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/include" \
    "$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/src/axi_dumper.sv" \
    "$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/src/axi_sim_mem.sv" \
    "$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/src/axi_test.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -work sim/work \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/axi-7b2f4d727835e579/include" \
    "+incdir+$ROOT/.bender/git/checkouts/apb-a6842004b4264fbe/include" \
    "+incdir+$ROOT/.bender/git/checkouts/register_interface-395ec29a9cb77b36/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/include" \
    "$ROOT/.bender/git/checkouts/register_interface-395ec29a9cb77b36/src/reg_intf.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-395ec29a9cb77b36/vendor/lowrisc_opentitan/src/prim_subreg_arb.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-395ec29a9cb77b36/vendor/lowrisc_opentitan/src/prim_subreg_ext.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-395ec29a9cb77b36/src/apb_to_reg.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-395ec29a9cb77b36/src/axi_to_reg.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-395ec29a9cb77b36/src/periph_to_reg.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-395ec29a9cb77b36/src/reg_cdc.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-395ec29a9cb77b36/src/reg_demux.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-395ec29a9cb77b36/src/reg_err_slv.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-395ec29a9cb77b36/src/reg_mux.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-395ec29a9cb77b36/src/reg_to_apb.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-395ec29a9cb77b36/src/reg_to_mem.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-395ec29a9cb77b36/src/reg_uniform.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-395ec29a9cb77b36/src/reg_to_tlul.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-395ec29a9cb77b36/vendor/lowrisc_opentitan/src/prim_subreg_shadow.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-395ec29a9cb77b36/vendor/lowrisc_opentitan/src/prim_subreg.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-395ec29a9cb77b36/src/axi_lite_to_reg.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -work sim/work \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/include" \
    "+incdir+$ROOT/.bender/git/checkouts/register_interface-395ec29a9cb77b36/include" \
    "$ROOT/src/clic_reg_pkg.sv" \
    "$ROOT/src/clic_reg_top.sv" \
    "$ROOT/src/clic_reg_adapter.sv" \
    "$ROOT/src/clic_gateway.sv" \
    "$ROOT/src/clic_target.sv" \
    "$ROOT/src/clic.sv"
}]} {return 1}

if {[catch {vlog -incr -sv \
    -work sim/work \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/register_interface-395ec29a9cb77b36/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-9f5a99864546ad39/include" \
    "$ROOT/src/tb/clic_tb_pkg.sv" \
    "$ROOT/src/tb/clic_csr_regfile.sv" \
    "$ROOT/src/tb/clic_if.sv" \
    "$ROOT/src/tb/clic_tracer.sv" \
    "$ROOT/src/tb/clic_memory.sv" \
    "$ROOT/src/tb/clic_pipeline.sv" \
    "$ROOT/src/tb/clic_controller.sv" \
    "$ROOT/src/tb/clic_tb.sv"
}]} {return 1}
