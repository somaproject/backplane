VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/serialize/_behavioral.var: ../../vhdl/devicelink/serialize.vhd
	$(VHDLC) ../../vhdl/devicelink/serialize.vhd

hw: $(WORKDIR)/serialize/_behavioral.var 

comp: 

$(WORKDIR)/serializetest/_behavioral.var: serializetest.vhd
	$(VHDLC) serializetest.vhd

sim: $(WORKDIR)/serializetest/_behavioral.var 
runsim: all
	$(VHDLS) serializetest


clean:
	rm -Rf $(WORKDIR)$

