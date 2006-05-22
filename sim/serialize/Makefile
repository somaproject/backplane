VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/serialize/_behavioral.var: ../../vhdl/devicelink/serialize.vhd
	$(VHDLC) ../../vhdl/devicelink/serialize.vhd

$(WORKDIR)/serdes/_behavioral.var: ../../deviceio/sim/components/serdes/serdes.vhd
	$(VHDLC) ../../deviceio/sim/components/serdes/serdes.vhd

hw: $(WORKDIR)/serialize/_behavioral.var $(WORKDIR)/serdes/_behavioral.var 

comp: 

$(WORKDIR)/serializetest/_behavioral.var: serializetest.vhd
	$(VHDLC) serializetest.vhd

sim: $(WORKDIR)/serializetest/_behavioral.var 
runsim: all
	$(VHDLS) serializetest


clean:
	rm -Rf $(WORKDIR)$

