VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/deserialize/_behavioral.var: ../../../vhdl/devicelink/deserialize.vhd
	$(VHDLC) ../../../vhdl/devicelink/deserialize.vhd

$(WORKDIR)/lvdstest/_behavioral.var: ../vhdl/lvdstest.vhd
	$(VHDLC) ../vhdl/lvdstest.vhd

$(WORKDIR)/lvdsclient/_behavioral.var: ../clientvhdl/lvdsclient.vhd
	$(VHDLC) ../clientvhdl/lvdsclient.vhd

hw: $(WORKDIR)/deserialize/_behavioral.var $(WORKDIR)/lvdstest/_behavioral.var $(WORKDIR)/lvdsclient/_behavioral.var 

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

