VHDLC=vcom
VHDLS=vsim
WORKDIR=work
all: hw comp sim

$(WORKDIR)/devicelinkclk/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/devicelink/devicelinkclk.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../../vhdl/devicelink/devicelinkclk.vhd

$(WORKDIR)/coredevicelink/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/devicelink/devicelinkclk.vhd ../../../vhdl/devicelink/devicelinkclk.vhd ../../../vhdl/devicelink/coredevicelink.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../../vhdl/devicelink/coredevicelink.vhd

$(WORKDIR)/deserialize/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/devicelink/devicelinkclk.vhd ../../../vhdl/devicelink/devicelinkclk.vhd ../../../vhdl/devicelink/coredevicelink.vhd ../../../vhdl/devicelink/coredevicelink.vhd ../../../vhdl/devicelink/deserialize.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../../vhdl/devicelink/deserialize.vhd

$(WORKDIR)/serialize/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/devicelink/devicelinkclk.vhd ../../../vhdl/devicelink/devicelinkclk.vhd ../../../vhdl/devicelink/coredevicelink.vhd ../../../vhdl/devicelink/coredevicelink.vhd ../../../vhdl/devicelink/deserialize.vhd ../../../vhdl/devicelink/deserialize.vhd ../../../vhdl/devicelink/serialize.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../../vhdl/devicelink/serialize.vhd

$(WORKDIR)/windowdetect/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/devicelink/devicelinkclk.vhd ../../../vhdl/devicelink/devicelinkclk.vhd ../../../vhdl/devicelink/coredevicelink.vhd ../../../vhdl/devicelink/coredevicelink.vhd ../../../vhdl/devicelink/deserialize.vhd ../../../vhdl/devicelink/deserialize.vhd ../../../vhdl/devicelink/serialize.vhd ../../../vhdl/devicelink/serialize.vhd ../../../vhdl/devicelink/windowdetect.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../../vhdl/devicelink/windowdetect.vhd

$(WORKDIR)/delaytable/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/devicelink/devicelinkclk.vhd ../../../vhdl/devicelink/devicelinkclk.vhd ../../../vhdl/devicelink/coredevicelink.vhd ../../../vhdl/devicelink/coredevicelink.vhd ../../../vhdl/devicelink/deserialize.vhd ../../../vhdl/devicelink/deserialize.vhd ../../../vhdl/devicelink/serialize.vhd ../../../vhdl/devicelink/serialize.vhd ../../../vhdl/devicelink/windowdetect.vhd ../../../vhdl/devicelink/windowdetect.vhd ../../../vhdl/devicelink/delaytable.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../../vhdl/devicelink/delaytable.vhd

$(WORKDIR)/delaylock/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/devicelink/devicelinkclk.vhd ../../../vhdl/devicelink/devicelinkclk.vhd ../../../vhdl/devicelink/coredevicelink.vhd ../../../vhdl/devicelink/coredevicelink.vhd ../../../vhdl/devicelink/deserialize.vhd ../../../vhdl/devicelink/deserialize.vhd ../../../vhdl/devicelink/serialize.vhd ../../../vhdl/devicelink/serialize.vhd ../../../vhdl/devicelink/windowdetect.vhd ../../../vhdl/devicelink/windowdetect.vhd ../../../vhdl/devicelink/delaytable.vhd ../../../vhdl/devicelink/delaytable.vhd ../../../vhdl/devicelink/delaylock.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../../vhdl/devicelink/delaylock.vhd

$(WORKDIR)/somabackplane/body.dat: $(WORKDIR)/touched ../../../vhdl/devicelink/devicelinkclk.vhd ../../../vhdl/devicelink/devicelinkclk.vhd ../../../vhdl/devicelink/coredevicelink.vhd ../../../vhdl/devicelink/coredevicelink.vhd ../../../vhdl/devicelink/deserialize.vhd ../../../vhdl/devicelink/deserialize.vhd ../../../vhdl/devicelink/serialize.vhd ../../../vhdl/devicelink/serialize.vhd ../../../vhdl/devicelink/windowdetect.vhd ../../../vhdl/devicelink/windowdetect.vhd ../../../vhdl/devicelink/delaytable.vhd ../../../vhdl/devicelink/delaytable.vhd ../../../vhdl/devicelink/delaylock.vhd ../../../vhdl/devicelink/delaylock.vhd ../../../vhdl/somabackplane.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../../vhdl/somabackplane.vhd

$(WORKDIR)/coredlencode8b10b/coredlencode8b10b_a.dat: $(WORKDIR)/touched ../../../vhdl/devicelink/devicelinkclk.vhd ../../../vhdl/devicelink/devicelinkclk.vhd ../../../vhdl/devicelink/coredevicelink.vhd ../../../vhdl/devicelink/coredevicelink.vhd ../../../vhdl/devicelink/deserialize.vhd ../../../vhdl/devicelink/deserialize.vhd ../../../vhdl/devicelink/serialize.vhd ../../../vhdl/devicelink/serialize.vhd ../../../vhdl/devicelink/windowdetect.vhd ../../../vhdl/devicelink/windowdetect.vhd ../../../vhdl/devicelink/delaytable.vhd ../../../vhdl/devicelink/delaytable.vhd ../../../vhdl/devicelink/delaylock.vhd ../../../vhdl/devicelink/delaylock.vhd ../../../vhdl/somabackplane.vhd ../../../vhdl/somabackplane.vhd ../vhdl/coredlencode8b10b.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../vhdl/coredlencode8b10b.vhd

$(WORKDIR)/coredldecode8b10b/coredldecode8b10b_a.dat: $(WORKDIR)/touched ../../../vhdl/devicelink/devicelinkclk.vhd ../../../vhdl/devicelink/devicelinkclk.vhd ../../../vhdl/devicelink/coredevicelink.vhd ../../../vhdl/devicelink/coredevicelink.vhd ../../../vhdl/devicelink/deserialize.vhd ../../../vhdl/devicelink/deserialize.vhd ../../../vhdl/devicelink/serialize.vhd ../../../vhdl/devicelink/serialize.vhd ../../../vhdl/devicelink/windowdetect.vhd ../../../vhdl/devicelink/windowdetect.vhd ../../../vhdl/devicelink/delaytable.vhd ../../../vhdl/devicelink/delaytable.vhd ../../../vhdl/devicelink/delaylock.vhd ../../../vhdl/devicelink/delaylock.vhd ../../../vhdl/somabackplane.vhd ../../../vhdl/somabackplane.vhd ../vhdl/coredlencode8b10b.vhd ../vhdl/coredlencode8b10b.vhd ../vhdl/coredldecode8b10b.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../vhdl/coredldecode8b10b.vhd

$(WORKDIR)/dlencode8b10b/dlencode8b10b_a.dat: $(WORKDIR)/touched ../../../vhdl/devicelink/devicelinkclk.vhd ../../../vhdl/devicelink/devicelinkclk.vhd ../../../vhdl/devicelink/coredevicelink.vhd ../../../vhdl/devicelink/coredevicelink.vhd ../../../vhdl/devicelink/deserialize.vhd ../../../vhdl/devicelink/deserialize.vhd ../../../vhdl/devicelink/serialize.vhd ../../../vhdl/devicelink/serialize.vhd ../../../vhdl/devicelink/windowdetect.vhd ../../../vhdl/devicelink/windowdetect.vhd ../../../vhdl/devicelink/delaytable.vhd ../../../vhdl/devicelink/delaytable.vhd ../../../vhdl/devicelink/delaylock.vhd ../../../vhdl/devicelink/delaylock.vhd ../../../vhdl/somabackplane.vhd ../../../vhdl/somabackplane.vhd ../vhdl/coredlencode8b10b.vhd ../vhdl/coredlencode8b10b.vhd ../vhdl/coredldecode8b10b.vhd ../vhdl/coredldecode8b10b.vhd ../vhdl/dlencode8b10b.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../vhdl/dlencode8b10b.vhd

$(WORKDIR)/dldecode8b10b/dldecode8b10b_a.dat: $(WORKDIR)/touched ../../../vhdl/devicelink/devicelinkclk.vhd ../../../vhdl/devicelink/devicelinkclk.vhd ../../../vhdl/devicelink/coredevicelink.vhd ../../../vhdl/devicelink/coredevicelink.vhd ../../../vhdl/devicelink/deserialize.vhd ../../../vhdl/devicelink/deserialize.vhd ../../../vhdl/devicelink/serialize.vhd ../../../vhdl/devicelink/serialize.vhd ../../../vhdl/devicelink/windowdetect.vhd ../../../vhdl/devicelink/windowdetect.vhd ../../../vhdl/devicelink/delaytable.vhd ../../../vhdl/devicelink/delaytable.vhd ../../../vhdl/devicelink/delaylock.vhd ../../../vhdl/devicelink/delaylock.vhd ../../../vhdl/somabackplane.vhd ../../../vhdl/somabackplane.vhd ../vhdl/coredlencode8b10b.vhd ../vhdl/coredlencode8b10b.vhd ../vhdl/coredldecode8b10b.vhd ../vhdl/coredldecode8b10b.vhd ../vhdl/dlencode8b10b.vhd ../vhdl/dlencode8b10b.vhd ../vhdl/dldecode8b10b.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../vhdl/dldecode8b10b.vhd

$(WORKDIR)/manydevicelink/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/devicelink/devicelinkclk.vhd ../../../vhdl/devicelink/devicelinkclk.vhd ../../../vhdl/devicelink/coredevicelink.vhd ../../../vhdl/devicelink/coredevicelink.vhd ../../../vhdl/devicelink/deserialize.vhd ../../../vhdl/devicelink/deserialize.vhd ../../../vhdl/devicelink/serialize.vhd ../../../vhdl/devicelink/serialize.vhd ../../../vhdl/devicelink/windowdetect.vhd ../../../vhdl/devicelink/windowdetect.vhd ../../../vhdl/devicelink/delaytable.vhd ../../../vhdl/devicelink/delaytable.vhd ../../../vhdl/devicelink/delaylock.vhd ../../../vhdl/devicelink/delaylock.vhd ../../../vhdl/somabackplane.vhd ../../../vhdl/somabackplane.vhd ../vhdl/coredlencode8b10b.vhd ../vhdl/coredlencode8b10b.vhd ../vhdl/coredldecode8b10b.vhd ../vhdl/coredldecode8b10b.vhd ../vhdl/dlencode8b10b.vhd ../vhdl/dlencode8b10b.vhd ../vhdl/dldecode8b10b.vhd ../vhdl/dldecode8b10b.vhd ../vhdl/manydevicelink.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../vhdl/manydevicelink.vhd

$(WORKDIR)/linktester/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/devicelink/devicelinkclk.vhd ../../../vhdl/devicelink/devicelinkclk.vhd ../../../vhdl/devicelink/coredevicelink.vhd ../../../vhdl/devicelink/coredevicelink.vhd ../../../vhdl/devicelink/deserialize.vhd ../../../vhdl/devicelink/deserialize.vhd ../../../vhdl/devicelink/serialize.vhd ../../../vhdl/devicelink/serialize.vhd ../../../vhdl/devicelink/windowdetect.vhd ../../../vhdl/devicelink/windowdetect.vhd ../../../vhdl/devicelink/delaytable.vhd ../../../vhdl/devicelink/delaytable.vhd ../../../vhdl/devicelink/delaylock.vhd ../../../vhdl/devicelink/delaylock.vhd ../../../vhdl/somabackplane.vhd ../../../vhdl/somabackplane.vhd ../vhdl/coredlencode8b10b.vhd ../vhdl/coredlencode8b10b.vhd ../vhdl/coredldecode8b10b.vhd ../vhdl/coredldecode8b10b.vhd ../vhdl/dlencode8b10b.vhd ../vhdl/dlencode8b10b.vhd ../vhdl/dldecode8b10b.vhd ../vhdl/dldecode8b10b.vhd ../vhdl/manydevicelink.vhd ../vhdl/manydevicelink.vhd ../vhdl/linktester.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../vhdl/linktester.vhd

hw: $(WORKDIR)/devicelinkclk/behavioral.dat $(WORKDIR)/coredevicelink/behavioral.dat $(WORKDIR)/deserialize/behavioral.dat $(WORKDIR)/serialize/behavioral.dat $(WORKDIR)/windowdetect/behavioral.dat $(WORKDIR)/delaytable/behavioral.dat $(WORKDIR)/delaylock/behavioral.dat $(WORKDIR)/somabackplane/body.dat $(WORKDIR)/coredlencode8b10b/coredlencode8b10b_a.dat $(WORKDIR)/coredldecode8b10b/coredldecode8b10b_a.dat $(WORKDIR)/dlencode8b10b/dlencode8b10b_a.dat $(WORKDIR)/dldecode8b10b/dldecode8b10b_a.dat $(WORKDIR)/manydevicelink/behavioral.dat $(WORKDIR)/linktester/behavioral.dat 

$(WORKDIR)/devicelink/behavioral.dat: $(WORKDIR)/touched ../../../../dspboard/vhdl/serial-deviceio/vhdl/devicelink.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../../../dspboard/vhdl/serial-deviceio/vhdl/devicelink.vhd

$(WORKDIR)/dlloop/behavioral.dat: $(WORKDIR)/touched ../../../../dspboard/vhdl/serial-deviceio/vhdl/devicelink.vhd ../../../../dspboard/tests/deviceloopback/dlloop.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../../../dspboard/tests/deviceloopback/dlloop.vhd

$(WORKDIR)/serdes/behavioral.dat: $(WORKDIR)/touched ../../../../dspboard/vhdl/serial-deviceio/vhdl/devicelink.vhd ../../../../dspboard/tests/deviceloopback/dlloop.vhd ../../../sim/coredevicelink/serdes.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../../sim/coredevicelink/serdes.vhd

comp: $(WORKDIR)/devicelink/behavioral.dat $(WORKDIR)/dlloop/behavioral.dat $(WORKDIR)/serdes/behavioral.dat 

$(WORKDIR)/manydevicelinktest/behavioral.dat: $(WORKDIR)/touched ../../../../dspboard/vhdl/serial-deviceio/vhdl/devicelink.vhd ../../../../dspboard/tests/deviceloopback/dlloop.vhd ../../../sim/coredevicelink/serdes.vhd manydevicelinktest.vhd
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
