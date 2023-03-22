# RISC-V CLIC
RISC-V Core Local Interrupt Controller (CLIC) is an interrupt controller for
RISC-V cores subsuming the original RISC-V local interrupt scheme (CLINT). It
promises pre-emptive, low-latency, vectored, priority/level based interrupts.

This IP is meant to be used together with a suitably modified version of a core.
Currently, a modified version of the
[CV32E40P](https://github.com/openhwgroup/cv32e40p) is supported.

[Here](./doc/clic.adoc) is the detailed specification this IP is based on. For
the upstream specification visit
[this](https://github.com/riscv/riscv-fast-interrupt/blob/master/clic.adoc)
link.

Note that this IP is based on an intermediate development version of the CLIC
specification which will still change substantially. This IP will try to track
the changes of the specification. The [specification document](./doc/clic.adoc)
in this repository is a snapshot of the upstream specification and the version
this IP is based on.

## Features

- RISC-V Core Local Interrupt Controller (CLIC) compliant interrupt controller
- Support up to 4096 interrupt lines
- Support up to 8 bits of priority/level information per interrupt line
- Supports (a modified) [CV32E40P](#CLIC-and-CV32E40P)

## Parametrization
Some parameters are configurable. See the marked variables in the table below.

```
Name             Value Range                   Description
CLICANDBASIC     0-1     (depends on core)     Implements original basic mode also?
CLICPRIVMODES    1-3     (depends on core)     Number privilege modes: 1=M, 2=M/U,
                                                                       3=M/S/U
CLICLEVELS       2-256                         Number of interrupt levels including 0
*NUM_INTERRUPT*  4-4096  (default=256)         Always has MSIP, MTIP, MEIP, CSIP
CLICMAXID        12-4095                       Largest interrupt ID
*CLICINTCTLBITS* 0-8     (default=8)           Number of bits implemented in
                                               clicintctl[i]
CLICCFGMBITS     0-ceil(lg2(CLICPRIVMODES))    Number of bits implemented for
                                               cliccfg.nmbits
CLICCFGLBITS     0-ceil(lg2(CLICLEVELS))       Number of bits implemented for
                                               cliccfg.nlbits
CLICSELHVEC      0-1     (0-1)                 Selective hardware vectoring supported?
CLICMTVECALIGN   6-13    (depends on core)     Number of hardwired-zero least
                                               significant bits in mtvec address.
CLICXNXTI        0-1     (depends on core)     Has xnxti CSR implemented?
CLICXCSW         0-1     (depends on core)     Has xscratchcsw/xscratchcswl
                                               implemented?
```

## Integration and Dependencies
This IP requires

- [common_cells](https://github.com/pulp-platform/common_cells)
- [register_interface](https://github.com/pulp-platform/register_interface)

and a suitably modified core (see sections below).

The [bender](https://github.com/pulp-platform/bender) and legacy
[IPApproX](https://github.com/pulp-platform/IPApproX) flow are supported.

Besides the native
[register_interface](https://github.com/pulp-platform/register_interface) there
is an APB wrapper available.


## CLIC and CV32E40P
The patch required to use the CV32E40P together with the CLIC lives in this
[branch](https://github.com/pulp-platform/cv32e40p/tree/clic). The CLIC mode is
an elaboration time parameter at this moment, but will support a dynamic switch
at some point.

Here is the summary
```
Name             Value
CLICANDBASIC     0   (dynamic mode under development)
CLICPRIVMODES    2
NUM_INTERRUPT    32-256
CLICINTCTLBITS   0-8
CLICSELHVEC      1
CLICMTVECALIGN   8
CLICXNXTI        0   (partial, under development)
CLICXCSW         1
```

## CLIC and CVA6
Not supported yet.

## FreeRTOS Support
There is very basic support for the CLIC in
[pulp-freertos](https://github.com/pulp-platform/pulp-freertos) with more a more
complete level/priority implementation in the works.

## Register interface
By default the CLIC's register file is manually written requiring no attention
of the user.

Alternatively, [regtool](https://docs.opentitan.org/doc/rm/register_tool/) can
be used to generate the register file. For that, go to `src/gen/` and call `make
all` with the environment variable `REGTOOL` pointing to `regtool.py` of the
[register_interface](https://github.com/pulp-platform/register_interface)
repository and `NUM_INTERRUPT` and `CLICINTCTLBITS` appropriately set. These
three environment variables can be passed when using make, e.g. 

```console
    make NUM_INTERRUPT=128 CLICINTCTLBITS=4
```

Finally, make sure your `src_files.yml` or `Bender.yml` points to

- `src/gen/clic_reg_pkg.sv`
- `src/gen/clic_reg_top.sv`
- `src/gen/clic_reg_adapater.sv`

`regtool` has various limitations on how the register map can look like,
requiring the memory map description (`src/gen/clic.hjson`) to be derived from a
template (`src/gen/clic.hjson.tpl`), resulting in rather unwieldy code and
documentation.

## CLIC Testbench

All testbench files are located in *src/tb/*. The testbench consists of a top level wrapper (*clic_tb.sv*) that contains an instance of the CLIC IP and a CLIC-compliant target (aka [CLIC controller](./src/tb/clic_controller.sv). The controller simulates the behaviour of a privileged (U/S/M) RISC-V core that support the CLIC interface. It contains a simple pipeline that fetches pseudo-instruction from a Read-Only Memory (ROM) submodule. Currently, the only pseudo-instructions supported are CSR writes, M-/S-RET, and NOPs. The implementation complexity is minimized by only implementing a subset of the CSR registers normally implemented by a RISC-V core (only the ones related to exceptional control flow). The implementation simulates a single-hart capable of running in U-/S-/M-mode and of handling incoming CLIC interrupts at M and S privilege levels. Traces are generated for every retired instruction/interrupt, and can be used to observe the behaviour of the hart upon interrupts reception. 
Upon reset, the controller pipeline starts fetching from address 0x0000 (M-mode main). In order to execute meaningful tests, a set of 4 headers containing the respective ROM banks initial values must be generated. This can be done by the helper [Python script](./utils/py/gen_memories.py). By default, it generates a minimal set of pseudo-instructions that enables M-/S-mode interrupts, sets the m-/s-tvec CSRs to the base addresses of banks 2 and 3, and traps to S-mode. It also initiates the M-/S-mode trap handlers to execute a bunch of NOPs followed by an m-/s-ret. This is enough to simulate the behaviour of a hart running in S-mode and capable of handling S-/M-mode interrupts.
The top-level testbench also provides some utilities that can be used to write/read configuration registers of the CLIC, and to simulate incoming interrupts (e.g. from an external platform-level interrupt controller). All these things combined form a complete testbench that is capable of emulating a simple RISC-V hart receiving and acknowledging interrupts from the CLIC.

### Testing

To test CLIC with the provided testbench:
- [Optional] Edit the top-level testbench ([clic_tb.sv](./scr/tb/clic_tb.sv)) to provide the desired interrupt pattern.
- Compile the testbench (make all)
- Run the simulation (make run)

Traces will be generated in *./traces/trace.log*.


### Limitations
- Not able to clear interrupts from controller yet (the register interface is not implemented).

## Directory Structure
```
.
├── doc      CLIC spec, Blockdiagrams
├── src      RTL
├── src/gen  Templates and python scripts
```

## License
This project uses sourcecode from lowRISC licensed under Apache 2.0. The changes
and additions are being made available using Apache 2.0 see LICENSE for more
details.
