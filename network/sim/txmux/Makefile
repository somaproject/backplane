VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/networkstack/prim.var: ../../vhdl/networkstack.vhd
	$(VHDLC) ../../vhdl/networkstack.vhd

$(WORKDIR)/txmux/_behavioral.var: ../../vhdl/networkstack.vhd ../../vhdl/txmux.vhd
	$(VHDLC) ../../vhdl/txmux.vhd

hw: $(WORKDIR)/networkstack/prim.var $(WORKDIR)/txmux/_behavioral.var 

comp: 

$(WORKDIR)/txmuxtest/_behavioral.var: txmuxtest.vhd
	$(VHDLC) txmuxtest.vhd

sim: $(WORKDIR)/txmuxtest/_behavioral.var 
runsim: all
	$(VHDLS) txmuxtest


clean:
	rm -Rf $(WORKDIR)$

