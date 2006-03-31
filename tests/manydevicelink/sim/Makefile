VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/coredevicelink/_behavioral.var: ../../../vhdl/devicelink/coredevicelink.vhd
	$(VHDLC) ../../../vhdl/devicelink/coredevicelink.vhd

$(WORKDIR)/deserialize/_behavioral.var: ../../../vhdl/devicelink/deserialize.vhd
	$(VHDLC) ../../../vhdl/devicelink/deserialize.vhd

$(WORKDIR)/serialize/_behavioral.var: ../../../vhdl/devicelink/serialize.vhd
	$(VHDLC) ../../../vhdl/devicelink/serialize.vhd

$(WORKDIR)/somabackplane/_somabackplane.var: ../../../vhdl/somabackplane.vhd
	$(VHDLC) ../../../vhdl/somabackplane.vhd

$(WORKDIR)/encode8b10b/_encode8b10b_a.var: ../vhdl/encode8b10b.vhd
	$(VHDLC) ../vhdl/encode8b10b.vhd

$(WORKDIR)/decode8b10b/_decode8b10b_a.var: ../vhdl/decode8b10b.vhd
	$(VHDLC) ../vhdl/decode8b10b.vhd

$(WORKDIR)/manydevicelink/_behavioral.var: ../vhdl/manydevicelink.vhd
	$(VHDLC) ../vhdl/manydevicelink.vhd

$(WORKDIR)/linktester/_behavioral.var: ../vhdl/linktester.vhd
	$(VHDLC) ../vhdl/linktester.vhd

hw: $(WORKDIR)/coredevicelink/_behavioral.var $(WORKDIR)/deserialize/_behavioral.var $(WORKDIR)/serialize/_behavioral.var $(WORKDIR)/somabackplane/_somabackplane.var $(WORKDIR)/encode8b10b/_encode8b10b_a.var $(WORKDIR)/decode8b10b/_decode8b10b_a.var $(WORKDIR)/manydevicelink/_behavioral.var $(WORKDIR)/linktester/_behavioral.var 

$(WORKDIR)/devicelink/_behavioral.var: ../../../deviceio/vhdl/devicelink.vhd
	$(VHDLC) ../../../deviceio/vhdl/devicelink.vhd

$(WORKDIR)/dlloop/_behavioral.var: ../../../deviceio/tests/deviceloopback/dlloop.vhd
	$(VHDLC) ../../../deviceio/tests/deviceloopback/dlloop.vhd

$(WORKDIR)/serdes/_behavioral.var: ../../../deviceio/sim/components/serdes/serdes.vhd
	$(VHDLC) ../../../deviceio/sim/components/serdes/serdes.vhd

comp: $(WORKDIR)/devicelink/_behavioral.var $(WORKDIR)/dlloop/_behavioral.var $(WORKDIR)/serdes/_behavioral.var 

$(WORKDIR)/manydevicelinktest/_behavioral.var: manydevicelinktest.vhd
	$(VHDLC) manydevicelinktest.vhd

sim: $(WORKDIR)/manydevicelinktest/_behavioral.var 
runsim: all
	$(VHDLS) manydevicelinktest


clean:
	rm -Rf $(WORKDIR)$

