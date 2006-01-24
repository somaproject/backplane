VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/eventrx/_behavioral.var: ../../vhdl/core/eventrx.vhd
	$(VHDLC) ../../vhdl/core/eventrx.vhd

hw: $(WORKDIR)/eventrx/_behavioral.var 

comp: 

$(WORKDIR)/eventrxtest/_behavior.var: eventrxtest.vhd
	$(VHDLC) eventrxtest.vhd

sim: $(WORKDIR)/eventrxtest/_behavior.var 
runsim: all
	$(VHDLS) eventrxtest


clean:
	rm -Rf $(WORKDIR)$

