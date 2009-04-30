VHDLC=vcom
VHDLS=vsim
WORKDIR=work
all: hw comp sim

$(WORKDIR)/somabackplane/body.dat: $(WORKDIR)/touched ../../vhdl/somabackplane.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/somabackplane.vhd

$(WORKDIR)/coredevicelink/behavioral.dat: $(WORKDIR)/touched ../../vhdl/somabackplane.vhd ../../vhdl/somabackplane.vhd ../../vhdl/devicelink/coredevicelink.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/devicelink/coredevicelink.vhd

$(WORKDIR)/deserialize/behavioral.dat: $(WORKDIR)/touched ../../vhdl/somabackplane.vhd ../../vhdl/somabackplane.vhd ../../vhdl/devicelink/coredevicelink.vhd ../../vhdl/devicelink/coredevicelink.vhd ../../vhdl/devicelink/deserialize.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/devicelink/deserialize.vhd

$(WORKDIR)/devicelinkclk/behavioral.dat: $(WORKDIR)/touched ../../vhdl/somabackplane.vhd ../../vhdl/somabackplane.vhd ../../vhdl/devicelink/coredevicelink.vhd ../../vhdl/devicelink/coredevicelink.vhd ../../vhdl/devicelink/deserialize.vhd ../../vhdl/devicelink/deserialize.vhd ../../vhdl/devicelink/devicelinkclk.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/devicelink/devicelinkclk.vhd

$(WORKDIR)/serialize/behavioral.dat: $(WORKDIR)/touched ../../vhdl/somabackplane.vhd ../../vhdl/somabackplane.vhd ../../vhdl/devicelink/coredevicelink.vhd ../../vhdl/devicelink/coredevicelink.vhd ../../vhdl/devicelink/deserialize.vhd ../../vhdl/devicelink/deserialize.vhd ../../vhdl/devicelink/devicelinkclk.vhd ../../vhdl/devicelink/devicelinkclk.vhd ../../vhdl/devicelink/serialize.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/devicelink/serialize.vhd

$(WORKDIR)/bootdeserialize/behavioral.dat: $(WORKDIR)/touched ../../vhdl/somabackplane.vhd ../../vhdl/somabackplane.vhd ../../vhdl/devicelink/coredevicelink.vhd ../../vhdl/devicelink/coredevicelink.vhd ../../vhdl/devicelink/deserialize.vhd ../../vhdl/devicelink/deserialize.vhd ../../vhdl/devicelink/devicelinkclk.vhd ../../vhdl/devicelink/devicelinkclk.vhd ../../vhdl/devicelink/serialize.vhd ../../vhdl/devicelink/serialize.vhd ../../deviceio/vhdl/bootdeser.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../deviceio/vhdl/bootdeser.vhd

$(WORKDIR)/devicelink/behavioral.dat: $(WORKDIR)/touched ../../vhdl/somabackplane.vhd ../../vhdl/somabackplane.vhd ../../vhdl/devicelink/coredevicelink.vhd ../../vhdl/devicelink/coredevicelink.vhd ../../vhdl/devicelink/deserialize.vhd ../../vhdl/devicelink/deserialize.vhd ../../vhdl/devicelink/devicelinkclk.vhd ../../vhdl/devicelink/devicelinkclk.vhd ../../vhdl/devicelink/serialize.vhd ../../vhdl/devicelink/serialize.vhd ../../deviceio/vhdl/bootdeser.vhd ../../deviceio/vhdl/bootdeser.vhd ../../deviceio/vhdl/devicelink.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../deviceio/vhdl/devicelink.vhd

$(WORKDIR)/serialrx/behavioral.dat: $(WORKDIR)/touched ../../vhdl/somabackplane.vhd ../../vhdl/somabackplane.vhd ../../vhdl/devicelink/coredevicelink.vhd ../../vhdl/devicelink/coredevicelink.vhd ../../vhdl/devicelink/deserialize.vhd ../../vhdl/devicelink/deserialize.vhd ../../vhdl/devicelink/devicelinkclk.vhd ../../vhdl/devicelink/devicelinkclk.vhd ../../vhdl/devicelink/serialize.vhd ../../vhdl/devicelink/serialize.vhd ../../deviceio/vhdl/bootdeser.vhd ../../deviceio/vhdl/bootdeser.vhd ../../deviceio/vhdl/devicelink.vhd ../../deviceio/vhdl/devicelink.vhd ../../deviceio/vhdl/serialrx.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../deviceio/vhdl/serialrx.vhd

$(WORKDIR)/encode8b10b/encode8b10b_a.dat: $(WORKDIR)/touched ../../vhdl/somabackplane.vhd ../../vhdl/somabackplane.vhd ../../vhdl/devicelink/coredevicelink.vhd ../../vhdl/devicelink/coredevicelink.vhd ../../vhdl/devicelink/deserialize.vhd ../../vhdl/devicelink/deserialize.vhd ../../vhdl/devicelink/devicelinkclk.vhd ../../vhdl/devicelink/devicelinkclk.vhd ../../vhdl/devicelink/serialize.vhd ../../vhdl/devicelink/serialize.vhd ../../deviceio/vhdl/bootdeser.vhd ../../deviceio/vhdl/bootdeser.vhd ../../deviceio/vhdl/devicelink.vhd ../../deviceio/vhdl/devicelink.vhd ../../deviceio/vhdl/serialrx.vhd ../../deviceio/vhdl/serialrx.vhd encode8b10b.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) encode8b10b.vhd

$(WORKDIR)/decode8b10b/decode8b10b_a.dat: $(WORKDIR)/touched ../../vhdl/somabackplane.vhd ../../vhdl/somabackplane.vhd ../../vhdl/devicelink/coredevicelink.vhd ../../vhdl/devicelink/coredevicelink.vhd ../../vhdl/devicelink/deserialize.vhd ../../vhdl/devicelink/deserialize.vhd ../../vhdl/devicelink/devicelinkclk.vhd ../../vhdl/devicelink/devicelinkclk.vhd ../../vhdl/devicelink/serialize.vhd ../../vhdl/devicelink/serialize.vhd ../../deviceio/vhdl/bootdeser.vhd ../../deviceio/vhdl/bootdeser.vhd ../../deviceio/vhdl/devicelink.vhd ../../deviceio/vhdl/devicelink.vhd ../../deviceio/vhdl/serialrx.vhd ../../deviceio/vhdl/serialrx.vhd encode8b10b.vhd encode8b10b.vhd decode8b10b.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) decode8b10b.vhd

$(WORKDIR)/serdes/behavioral.dat: $(WORKDIR)/touched ../../vhdl/somabackplane.vhd ../../vhdl/somabackplane.vhd ../../vhdl/devicelink/coredevicelink.vhd ../../vhdl/devicelink/coredevicelink.vhd ../../vhdl/devicelink/deserialize.vhd ../../vhdl/devicelink/deserialize.vhd ../../vhdl/devicelink/devicelinkclk.vhd ../../vhdl/devicelink/devicelinkclk.vhd ../../vhdl/devicelink/serialize.vhd ../../vhdl/devicelink/serialize.vhd ../../deviceio/vhdl/bootdeser.vhd ../../deviceio/vhdl/bootdeser.vhd ../../deviceio/vhdl/devicelink.vhd ../../deviceio/vhdl/devicelink.vhd ../../deviceio/vhdl/serialrx.vhd ../../deviceio/vhdl/serialrx.vhd encode8b10b.vhd encode8b10b.vhd decode8b10b.vhd decode8b10b.vhd serdes.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) serdes.vhd

hw: $(WORKDIR)/somabackplane/body.dat $(WORKDIR)/coredevicelink/behavioral.dat $(WORKDIR)/deserialize/behavioral.dat $(WORKDIR)/devicelinkclk/behavioral.dat $(WORKDIR)/serialize/behavioral.dat $(WORKDIR)/bootdeserialize/behavioral.dat $(WORKDIR)/devicelink/behavioral.dat $(WORKDIR)/serialrx/behavioral.dat $(WORKDIR)/encode8b10b/encode8b10b_a.dat $(WORKDIR)/decode8b10b/decode8b10b_a.dat $(WORKDIR)/serdes/behavioral.dat 

comp: 

$(WORKDIR)/coredevicelinktest/behavioral.dat: $(WORKDIR)/touched coredevicelinktest.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) coredevicelinktest.vhd

sim: $(WORKDIR)/coredevicelinktest/behavioral.dat 
runsim: all
	$(VHDLS) coredevicelinktest


clean:
	rm -Rf work 

work/touched:
	vlib  work
	touch  work/touched
