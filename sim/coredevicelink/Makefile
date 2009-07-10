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

$(WORKDIR)/windowdetect/behavioral.dat: $(WORKDIR)/touched ../../vhdl/somabackplane.vhd ../../vhdl/somabackplane.vhd ../../vhdl/devicelink/coredevicelink.vhd ../../vhdl/devicelink/coredevicelink.vhd ../../vhdl/devicelink/deserialize.vhd ../../vhdl/devicelink/deserialize.vhd ../../vhdl/devicelink/devicelinkclk.vhd ../../vhdl/devicelink/devicelinkclk.vhd ../../vhdl/devicelink/serialize.vhd ../../vhdl/devicelink/serialize.vhd ../../vhdl/devicelink/windowdetect.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/devicelink/windowdetect.vhd

$(WORKDIR)/delaytable/behavioral.dat: $(WORKDIR)/touched ../../vhdl/somabackplane.vhd ../../vhdl/somabackplane.vhd ../../vhdl/devicelink/coredevicelink.vhd ../../vhdl/devicelink/coredevicelink.vhd ../../vhdl/devicelink/deserialize.vhd ../../vhdl/devicelink/deserialize.vhd ../../vhdl/devicelink/devicelinkclk.vhd ../../vhdl/devicelink/devicelinkclk.vhd ../../vhdl/devicelink/serialize.vhd ../../vhdl/devicelink/serialize.vhd ../../vhdl/devicelink/windowdetect.vhd ../../vhdl/devicelink/windowdetect.vhd ../../vhdl/devicelink/delaytable.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/devicelink/delaytable.vhd

$(WORKDIR)/delaylock/behavioral.dat: $(WORKDIR)/touched ../../vhdl/somabackplane.vhd ../../vhdl/somabackplane.vhd ../../vhdl/devicelink/coredevicelink.vhd ../../vhdl/devicelink/coredevicelink.vhd ../../vhdl/devicelink/deserialize.vhd ../../vhdl/devicelink/deserialize.vhd ../../vhdl/devicelink/devicelinkclk.vhd ../../vhdl/devicelink/devicelinkclk.vhd ../../vhdl/devicelink/serialize.vhd ../../vhdl/devicelink/serialize.vhd ../../vhdl/devicelink/windowdetect.vhd ../../vhdl/devicelink/windowdetect.vhd ../../vhdl/devicelink/delaytable.vhd ../../vhdl/devicelink/delaytable.vhd ../../vhdl/devicelink/delaylock.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/devicelink/delaylock.vhd

$(WORKDIR)/devicelink/behavioral.dat: $(WORKDIR)/touched ../../vhdl/somabackplane.vhd ../../vhdl/somabackplane.vhd ../../vhdl/devicelink/coredevicelink.vhd ../../vhdl/devicelink/coredevicelink.vhd ../../vhdl/devicelink/deserialize.vhd ../../vhdl/devicelink/deserialize.vhd ../../vhdl/devicelink/devicelinkclk.vhd ../../vhdl/devicelink/devicelinkclk.vhd ../../vhdl/devicelink/serialize.vhd ../../vhdl/devicelink/serialize.vhd ../../vhdl/devicelink/windowdetect.vhd ../../vhdl/devicelink/windowdetect.vhd ../../vhdl/devicelink/delaytable.vhd ../../vhdl/devicelink/delaytable.vhd ../../vhdl/devicelink/delaylock.vhd ../../vhdl/devicelink/delaylock.vhd ../../../dspboard/vhdl/serial-deviceio/vhdl/devicelink.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../../dspboard/vhdl/serial-deviceio/vhdl/devicelink.vhd

$(WORKDIR)/dlencode8b10b/dlencode8b10b_a.dat: $(WORKDIR)/touched ../../vhdl/somabackplane.vhd ../../vhdl/somabackplane.vhd ../../vhdl/devicelink/coredevicelink.vhd ../../vhdl/devicelink/coredevicelink.vhd ../../vhdl/devicelink/deserialize.vhd ../../vhdl/devicelink/deserialize.vhd ../../vhdl/devicelink/devicelinkclk.vhd ../../vhdl/devicelink/devicelinkclk.vhd ../../vhdl/devicelink/serialize.vhd ../../vhdl/devicelink/serialize.vhd ../../vhdl/devicelink/windowdetect.vhd ../../vhdl/devicelink/windowdetect.vhd ../../vhdl/devicelink/delaytable.vhd ../../vhdl/devicelink/delaytable.vhd ../../vhdl/devicelink/delaylock.vhd ../../vhdl/devicelink/delaylock.vhd ../../../dspboard/vhdl/serial-deviceio/vhdl/devicelink.vhd ../../../dspboard/vhdl/serial-deviceio/vhdl/devicelink.vhd dlencode8b10b.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) dlencode8b10b.vhd

$(WORKDIR)/dldecode8b10b/dldecode8b10b_a.dat: $(WORKDIR)/touched ../../vhdl/somabackplane.vhd ../../vhdl/somabackplane.vhd ../../vhdl/devicelink/coredevicelink.vhd ../../vhdl/devicelink/coredevicelink.vhd ../../vhdl/devicelink/deserialize.vhd ../../vhdl/devicelink/deserialize.vhd ../../vhdl/devicelink/devicelinkclk.vhd ../../vhdl/devicelink/devicelinkclk.vhd ../../vhdl/devicelink/serialize.vhd ../../vhdl/devicelink/serialize.vhd ../../vhdl/devicelink/windowdetect.vhd ../../vhdl/devicelink/windowdetect.vhd ../../vhdl/devicelink/delaytable.vhd ../../vhdl/devicelink/delaytable.vhd ../../vhdl/devicelink/delaylock.vhd ../../vhdl/devicelink/delaylock.vhd ../../../dspboard/vhdl/serial-deviceio/vhdl/devicelink.vhd ../../../dspboard/vhdl/serial-deviceio/vhdl/devicelink.vhd dlencode8b10b.vhd dlencode8b10b.vhd dldecode8b10b.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) dldecode8b10b.vhd

$(WORKDIR)/coredlencode8b10b/coredlencode8b10b_a.dat: $(WORKDIR)/touched ../../vhdl/somabackplane.vhd ../../vhdl/somabackplane.vhd ../../vhdl/devicelink/coredevicelink.vhd ../../vhdl/devicelink/coredevicelink.vhd ../../vhdl/devicelink/deserialize.vhd ../../vhdl/devicelink/deserialize.vhd ../../vhdl/devicelink/devicelinkclk.vhd ../../vhdl/devicelink/devicelinkclk.vhd ../../vhdl/devicelink/serialize.vhd ../../vhdl/devicelink/serialize.vhd ../../vhdl/devicelink/windowdetect.vhd ../../vhdl/devicelink/windowdetect.vhd ../../vhdl/devicelink/delaytable.vhd ../../vhdl/devicelink/delaytable.vhd ../../vhdl/devicelink/delaylock.vhd ../../vhdl/devicelink/delaylock.vhd ../../../dspboard/vhdl/serial-deviceio/vhdl/devicelink.vhd ../../../dspboard/vhdl/serial-deviceio/vhdl/devicelink.vhd dlencode8b10b.vhd dlencode8b10b.vhd dldecode8b10b.vhd dldecode8b10b.vhd coredlencode8b10b.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) coredlencode8b10b.vhd

$(WORKDIR)/coredldecode8b10b/coredldecode8b10b_a.dat: $(WORKDIR)/touched ../../vhdl/somabackplane.vhd ../../vhdl/somabackplane.vhd ../../vhdl/devicelink/coredevicelink.vhd ../../vhdl/devicelink/coredevicelink.vhd ../../vhdl/devicelink/deserialize.vhd ../../vhdl/devicelink/deserialize.vhd ../../vhdl/devicelink/devicelinkclk.vhd ../../vhdl/devicelink/devicelinkclk.vhd ../../vhdl/devicelink/serialize.vhd ../../vhdl/devicelink/serialize.vhd ../../vhdl/devicelink/windowdetect.vhd ../../vhdl/devicelink/windowdetect.vhd ../../vhdl/devicelink/delaytable.vhd ../../vhdl/devicelink/delaytable.vhd ../../vhdl/devicelink/delaylock.vhd ../../vhdl/devicelink/delaylock.vhd ../../../dspboard/vhdl/serial-deviceio/vhdl/devicelink.vhd ../../../dspboard/vhdl/serial-deviceio/vhdl/devicelink.vhd dlencode8b10b.vhd dlencode8b10b.vhd dldecode8b10b.vhd dldecode8b10b.vhd coredlencode8b10b.vhd coredlencode8b10b.vhd coredldecode8b10b.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) coredldecode8b10b.vhd

$(WORKDIR)/serdes/behavioral.dat: $(WORKDIR)/touched ../../vhdl/somabackplane.vhd ../../vhdl/somabackplane.vhd ../../vhdl/devicelink/coredevicelink.vhd ../../vhdl/devicelink/coredevicelink.vhd ../../vhdl/devicelink/deserialize.vhd ../../vhdl/devicelink/deserialize.vhd ../../vhdl/devicelink/devicelinkclk.vhd ../../vhdl/devicelink/devicelinkclk.vhd ../../vhdl/devicelink/serialize.vhd ../../vhdl/devicelink/serialize.vhd ../../vhdl/devicelink/windowdetect.vhd ../../vhdl/devicelink/windowdetect.vhd ../../vhdl/devicelink/delaytable.vhd ../../vhdl/devicelink/delaytable.vhd ../../vhdl/devicelink/delaylock.vhd ../../vhdl/devicelink/delaylock.vhd ../../../dspboard/vhdl/serial-deviceio/vhdl/devicelink.vhd ../../../dspboard/vhdl/serial-deviceio/vhdl/devicelink.vhd dlencode8b10b.vhd dlencode8b10b.vhd dldecode8b10b.vhd dldecode8b10b.vhd coredlencode8b10b.vhd coredlencode8b10b.vhd coredldecode8b10b.vhd coredldecode8b10b.vhd serdes.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) serdes.vhd

hw: $(WORKDIR)/somabackplane/body.dat $(WORKDIR)/coredevicelink/behavioral.dat $(WORKDIR)/deserialize/behavioral.dat $(WORKDIR)/devicelinkclk/behavioral.dat $(WORKDIR)/serialize/behavioral.dat $(WORKDIR)/windowdetect/behavioral.dat $(WORKDIR)/delaytable/behavioral.dat $(WORKDIR)/delaylock/behavioral.dat $(WORKDIR)/devicelink/behavioral.dat $(WORKDIR)/dlencode8b10b/dlencode8b10b_a.dat $(WORKDIR)/dldecode8b10b/dldecode8b10b_a.dat $(WORKDIR)/coredlencode8b10b/coredlencode8b10b_a.dat $(WORKDIR)/coredldecode8b10b/coredldecode8b10b_a.dat $(WORKDIR)/serdes/behavioral.dat 

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
