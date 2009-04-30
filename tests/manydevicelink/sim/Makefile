VHDLC=vcom
VHDLS=vsim
WORKDIR=work
all: hw comp sim

$(WORKDIR)/coredevicelink/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/devicelink/coredevicelink.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../../vhdl/devicelink/coredevicelink.vhd

$(WORKDIR)/deserialize/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/devicelink/coredevicelink.vhd ../../../vhdl/devicelink/coredevicelink.vhd ../../../vhdl/devicelink/deserialize.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../../vhdl/devicelink/deserialize.vhd

$(WORKDIR)/serialize/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/devicelink/coredevicelink.vhd ../../../vhdl/devicelink/coredevicelink.vhd ../../../vhdl/devicelink/deserialize.vhd ../../../vhdl/devicelink/deserialize.vhd ../../../vhdl/devicelink/serialize.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../../vhdl/devicelink/serialize.vhd

$(WORKDIR)/somabackplane/body.dat: $(WORKDIR)/touched ../../../vhdl/devicelink/coredevicelink.vhd ../../../vhdl/devicelink/coredevicelink.vhd ../../../vhdl/devicelink/deserialize.vhd ../../../vhdl/devicelink/deserialize.vhd ../../../vhdl/devicelink/serialize.vhd ../../../vhdl/devicelink/serialize.vhd ../../../vhdl/somabackplane.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../../vhdl/somabackplane.vhd

$(WORKDIR)/encode8b10b/encode8b10b_a.dat: $(WORKDIR)/touched ../../../vhdl/devicelink/coredevicelink.vhd ../../../vhdl/devicelink/coredevicelink.vhd ../../../vhdl/devicelink/deserialize.vhd ../../../vhdl/devicelink/deserialize.vhd ../../../vhdl/devicelink/serialize.vhd ../../../vhdl/devicelink/serialize.vhd ../../../vhdl/somabackplane.vhd ../../../vhdl/somabackplane.vhd ../vhdl/encode8b10b.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../vhdl/encode8b10b.vhd

$(WORKDIR)/decode8b10b/decode8b10b_a.dat: $(WORKDIR)/touched ../../../vhdl/devicelink/coredevicelink.vhd ../../../vhdl/devicelink/coredevicelink.vhd ../../../vhdl/devicelink/deserialize.vhd ../../../vhdl/devicelink/deserialize.vhd ../../../vhdl/devicelink/serialize.vhd ../../../vhdl/devicelink/serialize.vhd ../../../vhdl/somabackplane.vhd ../../../vhdl/somabackplane.vhd ../vhdl/encode8b10b.vhd ../vhdl/encode8b10b.vhd ../vhdl/decode8b10b.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../vhdl/decode8b10b.vhd

$(WORKDIR)/manydevicelink/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/devicelink/coredevicelink.vhd ../../../vhdl/devicelink/coredevicelink.vhd ../../../vhdl/devicelink/deserialize.vhd ../../../vhdl/devicelink/deserialize.vhd ../../../vhdl/devicelink/serialize.vhd ../../../vhdl/devicelink/serialize.vhd ../../../vhdl/somabackplane.vhd ../../../vhdl/somabackplane.vhd ../vhdl/encode8b10b.vhd ../vhdl/encode8b10b.vhd ../vhdl/decode8b10b.vhd ../vhdl/decode8b10b.vhd ../vhdl/manydevicelink.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../vhdl/manydevicelink.vhd

$(WORKDIR)/linktester/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/devicelink/coredevicelink.vhd ../../../vhdl/devicelink/coredevicelink.vhd ../../../vhdl/devicelink/deserialize.vhd ../../../vhdl/devicelink/deserialize.vhd ../../../vhdl/devicelink/serialize.vhd ../../../vhdl/devicelink/serialize.vhd ../../../vhdl/somabackplane.vhd ../../../vhdl/somabackplane.vhd ../vhdl/encode8b10b.vhd ../vhdl/encode8b10b.vhd ../vhdl/decode8b10b.vhd ../vhdl/decode8b10b.vhd ../vhdl/manydevicelink.vhd ../vhdl/manydevicelink.vhd ../vhdl/linktester.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../vhdl/linktester.vhd

hw: $(WORKDIR)/coredevicelink/behavioral.dat $(WORKDIR)/deserialize/behavioral.dat $(WORKDIR)/serialize/behavioral.dat $(WORKDIR)/somabackplane/body.dat $(WORKDIR)/encode8b10b/encode8b10b_a.dat $(WORKDIR)/decode8b10b/decode8b10b_a.dat $(WORKDIR)/manydevicelink/behavioral.dat $(WORKDIR)/linktester/behavioral.dat 

$(WORKDIR)/devicelink/behavioral.dat: $(WORKDIR)/touched ../../../deviceio/vhdl/devicelink.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../../deviceio/vhdl/devicelink.vhd

$(WORKDIR)/dlloop/behavioral.dat: $(WORKDIR)/touched ../../../deviceio/vhdl/devicelink.vhd ../../../deviceio/tests/deviceloopback/dlloop.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../../deviceio/tests/deviceloopback/dlloop.vhd

comp: $(WORKDIR)/devicelink/behavioral.dat $(WORKDIR)/dlloop/behavioral.dat 

$(WORKDIR)/manydevicelinktest/behavioral.dat: $(WORKDIR)/touched ../../../deviceio/vhdl/devicelink.vhd ../../../deviceio/tests/deviceloopback/dlloop.vhd manydevicelinktest.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) manydevicelinktest.vhd

sim: $(WORKDIR)/manydevicelinktest/behavioral.dat 
runsim: all
	$(VHDLS) manydevicelinktest


clean:
	rm -Rf work 

work/touched:
	vlib  work
	touch  work/touched
