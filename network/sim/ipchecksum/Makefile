VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/ipchecksum/_behavioral.var: ../../vhdl/ipchecksum.vhd
	$(VHDLC) ../../vhdl/ipchecksum.vhd

hw: $(WORKDIR)/ipchecksum/_behavioral.var 

comp: 

$(WORKDIR)/ipchecksumtest/_behavioral.var: ipchecksumtest.vhd
	$(VHDLC) ipchecksumtest.vhd

sim: $(WORKDIR)/ipchecksumtest/_behavioral.var 
runsim: all
	$(VHDLS) ipchecksumtest


clean:
	rm -Rf $(WORKDIR)$

