import os
from enum import Enum
from typing import List

# OPCODES
NOP  = 0
CSRW = 1
MRET = 2
SRET = 3

# CSR Addresses
CSR_SSTATUS    = 0x100
CSR_SIE        = 0x104
CSR_STVEC      = 0x105
CSR_STVT       = 0x107
CSR_SEPC       = 0x141
CSR_SCAUSE     = 0x142
CSR_STVAL      = 0x143
CSR_SIP        = 0x144
CSR_SINTTHRESH = 0x147
CSR_SINTSTATUS = 0xDB1
CSR_MSTATUS    = 0x300
CSR_MIE        = 0x304
CSR_MTVEC      = 0x305
CSR_MTVT       = 0x307
CSR_MEPC       = 0x341
CSR_MCAUSE     = 0x342
CSR_MTVAL      = 0x343
CSR_MIP        = 0x344
CSR_MINTSTATUS = 0x346
CSR_MINTTHRESH = 0x347

# Banks base addresses
MMODE_BASE = 0x0000_0000_0000_0000
SMODE_BASE = 0x0000_0000_0000_3000
MMODE_TRAP = 0x0000_0000_0000_1000
SMODE_TRAP = 0x0000_0000_0000_2000

class Instruction():

	def __init__(self, opcode, addr=0, data=0):
		self.op   = opcode
		self.data = data
		self.addr = addr


def write_mem(program, filename = 'memory.h', outdir = './memories'):
	if not os.path.exists(outdir):
		os.mkdir(outdir)
	filepath = os.path.join(outdir, filename)
	with open(filepath, 'w') as f:
		for inst in program:
			f.write('%020X\n' % (inst.data + (inst.addr << 64) + (inst.op << 76)))	

def main():

	m_main : List[Instruction] = [
		Instruction(NOP),
		Instruction(NOP),
		Instruction(NOP),
		Instruction(NOP),
		Instruction(CSRW, addr=CSR_MEPC, data=0x0000_0000_0000_3000),
		Instruction(CSRW, addr=CSR_MTVEC, data=0x0000_0000_0000_1000),
		Instruction(CSRW, addr=CSR_MSTATUS, data=0x0000_0000_0000_0808), # set MIE=1, MPP=S
		Instruction(NOP),
		Instruction(NOP),
		Instruction(NOP),
		Instruction(NOP),
		Instruction(MRET),
		Instruction(NOP)
	]

	m_trap : List[Instruction] = [
		Instruction(NOP),
		Instruction(NOP),
		Instruction(NOP),
		Instruction(NOP),
		Instruction(NOP),
		Instruction(NOP),
		Instruction(NOP),
		Instruction(NOP),
		Instruction(NOP),
		Instruction(MRET),
		Instruction(NOP)
	]

	s_trap : List[Instruction] = [
		Instruction(NOP),
		Instruction(NOP),
		Instruction(NOP),
		Instruction(NOP),
		Instruction(NOP),
		Instruction(NOP),
		Instruction(NOP),
		Instruction(NOP),
		Instruction(NOP),
		Instruction(SRET),
		Instruction(NOP)
	]

	s_main : List[Instruction] = [
		Instruction(NOP),
		Instruction(NOP),
		Instruction(NOP),
		Instruction(NOP),
		Instruction(CSRW, addr=CSR_STVEC, data=0x0000_0000_0000_2000), # set STVEC to S-mode trap handler
		Instruction(CSRW, addr=CSR_SSTATUS, data=0x0000_0000_0000_0122), # set SIE=1, SPIE=1, SPP=S
		Instruction(NOP)
	]


	programs = [m_main, m_trap, s_trap, s_main]

	for i in range(4):
		filename = 'memory_%d.h' % (i + 1,)
		write_mem(programs[i], filename)


if __name__ == '__main__':
	main()