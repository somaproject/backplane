VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/deserialize/_behavioral.var: ../../../vhdl/devicelink/deserialize.vhd
	$(VHDLC) ../../../vhdl/devicelink/deserialize.vhd

$(WORKDIR)/serialize/_behavioral.var: ../../../vhdl/devicelink/serialize.vhd
	$(VHDLC) ../../../vhdl/devicelink/serialize.vhd

$(WORKDIR)/lvdstest/_behavioral.var: ../vhdl/lvdstest.vhd
	$(VHDLC) ../vhdl/lvdstest.vhd

$(WORKDIR)/lvdsclient/_behavioral.var: ../clientvhdl/lvdsclient.vhd
	$(VHDLC) ../clientvhdl/lvdsclient.vhd

$(WORKDIR)/encode8b10b/_encode8b10b_a.var: ../vhdl/encode8b10b.vhd
	$(VHDLC) ../vhdl/encode8b10b.vhd

$(WORKDIR)/decode8b10b/_decode8b10b_a.var: ../vhdl/decode8b10b.vhd
	$(VHDLC) ../vhdl/decode8b10b.vhd

hw: $(WORKDIR)/deserialize/_behavioral.var $(WORKDIR)/serialize/_behavioral.var $(WORKDIR)/lvdstest/_behavioral.var $(WORKDIR)/lvdsclient/_behavioral.var $(WORKDIR)/encode8b10b/_encode8b10b_a.var $(WORKDIR)/decode8b10b/_decode8b10b_a.var 

$(WORKDIR)/serdes/_behavioral.var: ../../../deviceio/sim/components/serdes/serdes.vhd
	$(VHDLC) ../../../deviceio/sim/components/serdes/serdes.vhd

comp: $(WORKDIR)/serdes/_behavioral.var 

$(WORKDIR)/lvdstesttest/_behavioral.var: lvdstesttest.vhd
	$(VHDLC) lvdstesttest.vhd

sim: $(WORKDIR)/lvdstesttest/_behavioral.var 
runsim: all
	$(VHDLS) lvdstesttest


clean:
	rm -Rf $(WORKDIR)$

