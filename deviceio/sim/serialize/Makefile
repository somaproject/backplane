VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/serialize/_behavioral.var: ../../vhdl/serialize.vhd
	$(VHDLC) ../../vhdl/serialize.vhd

hw: $(WORKDIR)/serialize/_behavioral.var 

comp: 

$(WORKDIR)/serializetest/_behavior.var: serializetest.vhd
	$(VHDLC) serializetest.vhd

sim: $(WORKDIR)/serializetest/_behavior.var 
runsim: all
	$(VHDLS) serializetest


clean:
	rm -Rf $(WORKDIR)$

