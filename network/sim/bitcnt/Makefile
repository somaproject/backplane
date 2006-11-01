VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/bitcnt/_behavioral.var: ../../vhdl/bitcnt.vhd
	$(VHDLC) ../../vhdl/bitcnt.vhd

hw: $(WORKDIR)/bitcnt/_behavioral.var 

comp: 

$(WORKDIR)/bitcnttest/_behavioral.var: bitcnttest.vhd
	$(VHDLC) bitcnttest.vhd

sim: $(WORKDIR)/bitcnttest/_behavioral.var 
runsim: all
	$(VHDLS) bitcnttest


clean:
	rm -Rf $(WORKDIR)$

