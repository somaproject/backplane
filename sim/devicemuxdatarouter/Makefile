VHDLC=vcom
VHDLS=vsim
WORKDIR=work
all: hw comp sim

soma/somabackplane/body.dat: soma/touched ../../vhdl/somabackplane.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../vhdl/somabackplane.vhd

soma/regfile/behavioral.dat: soma/touched ../../vhdl/somabackplane.vhd ../../vhdl/coredevicemux/regfile.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../vhdl/coredevicemux/regfile.vhd

soma/devicemuxtx/behavioral.dat: soma/touched ../../vhdl/somabackplane.vhd ../../vhdl/coredevicemux/regfile.vhd ../../vhdl/coredevicemux/devicemuxtx.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../vhdl/coredevicemux/devicemuxtx.vhd

soma/devicemuxeventrx2/behavioral.dat: soma/touched ../../vhdl/somabackplane.vhd ../../vhdl/coredevicemux/regfile.vhd ../../vhdl/coredevicemux/devicemuxtx.vhd ../../vhdl/coredevicemux/devicemuxeventrx2.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../vhdl/coredevicemux/devicemuxeventrx2.vhd

soma/devicemuxrx/behavioral.dat: soma/touched ../../vhdl/somabackplane.vhd ../../vhdl/coredevicemux/regfile.vhd ../../vhdl/coredevicemux/devicemuxtx.vhd ../../vhdl/coredevicemux/devicemuxeventrx2.vhd ../../vhdl/coredevicemux/devicemuxrx.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../vhdl/coredevicemux/devicemuxrx.vhd

soma/devicemux/behavioral.dat: soma/touched ../../vhdl/somabackplane.vhd ../../vhdl/coredevicemux/regfile.vhd ../../vhdl/coredevicemux/devicemuxtx.vhd ../../vhdl/coredevicemux/devicemuxeventrx2.vhd ../../vhdl/coredevicemux/devicemuxrx.vhd ../../vhdl/coredevicemux/devicemux.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../vhdl/coredevicemux/devicemux.vhd

soma/datasequencer/behavioral.dat: soma/touched ../../vhdl/somabackplane.vhd ../../vhdl/coredevicemux/regfile.vhd ../../vhdl/coredevicemux/devicemuxtx.vhd ../../vhdl/coredevicemux/devicemuxeventrx2.vhd ../../vhdl/coredevicemux/devicemuxrx.vhd ../../vhdl/coredevicemux/devicemux.vhd ../../vhdl/core/datasequencer.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../vhdl/core/datasequencer.vhd

soma/datarouter/behavioral.dat: soma/touched ../../vhdl/somabackplane.vhd ../../vhdl/coredevicemux/regfile.vhd ../../vhdl/coredevicemux/devicemuxtx.vhd ../../vhdl/coredevicemux/devicemuxeventrx2.vhd ../../vhdl/coredevicemux/devicemuxrx.vhd ../../vhdl/coredevicemux/devicemux.vhd ../../vhdl/core/datasequencer.vhd ../../vhdl/core/datarouter.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../vhdl/core/datarouter.vhd

$(WORKDIR)/encodemux/behavioral.dat: $(WORKDIR)/touched ../../vhdl/somabackplane.vhd ../../vhdl/coredevicemux/regfile.vhd ../../vhdl/coredevicemux/devicemuxtx.vhd ../../vhdl/coredevicemux/devicemuxeventrx2.vhd ../../vhdl/coredevicemux/devicemuxrx.vhd ../../vhdl/coredevicemux/devicemux.vhd ../../vhdl/core/datasequencer.vhd ../../vhdl/core/datarouter.vhd ../../../dspboard/vhdl/encodemux.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../../dspboard/vhdl/encodemux.vhd

$(WORKDIR)/decodemux/behavioral.dat: $(WORKDIR)/touched ../../vhdl/somabackplane.vhd ../../vhdl/coredevicemux/regfile.vhd ../../vhdl/coredevicemux/devicemuxtx.vhd ../../vhdl/coredevicemux/devicemuxeventrx2.vhd ../../vhdl/coredevicemux/devicemuxrx.vhd ../../vhdl/coredevicemux/devicemux.vhd ../../vhdl/core/datasequencer.vhd ../../vhdl/core/datarouter.vhd ../../../dspboard/vhdl/encodemux.vhd ../../../dspboard/vhdl/encodemux.vhd ../../../dspboard/vhdl/decodemux.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../../dspboard/vhdl/decodemux.vhd

$(WORKDIR)/encodedata/behavioral.dat: $(WORKDIR)/touched ../../vhdl/somabackplane.vhd ../../vhdl/coredevicemux/regfile.vhd ../../vhdl/coredevicemux/devicemuxtx.vhd ../../vhdl/coredevicemux/devicemuxeventrx2.vhd ../../vhdl/coredevicemux/devicemuxrx.vhd ../../vhdl/coredevicemux/devicemux.vhd ../../vhdl/core/datasequencer.vhd ../../vhdl/core/datarouter.vhd ../../../dspboard/vhdl/encodemux.vhd ../../../dspboard/vhdl/encodemux.vhd ../../../dspboard/vhdl/decodemux.vhd ../../../dspboard/vhdl/decodemux.vhd ../../../dspboard/vhdl/encodedata.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../../dspboard/vhdl/encodedata.vhd

$(WORKDIR)/datamux/behavioral.dat: $(WORKDIR)/touched ../../vhdl/somabackplane.vhd ../../vhdl/coredevicemux/regfile.vhd ../../vhdl/coredevicemux/devicemuxtx.vhd ../../vhdl/coredevicemux/devicemuxeventrx2.vhd ../../vhdl/coredevicemux/devicemuxrx.vhd ../../vhdl/coredevicemux/devicemux.vhd ../../vhdl/core/datasequencer.vhd ../../vhdl/core/datarouter.vhd ../../../dspboard/vhdl/encodemux.vhd ../../../dspboard/vhdl/encodemux.vhd ../../../dspboard/vhdl/decodemux.vhd ../../../dspboard/vhdl/decodemux.vhd ../../../dspboard/vhdl/encodedata.vhd ../../../dspboard/vhdl/encodedata.vhd ../../../dspboard/vhdl/datamux.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../../dspboard/vhdl/datamux.vhd

$(WORKDIR)/regfile/behavioral.dat: $(WORKDIR)/touched ../../vhdl/somabackplane.vhd ../../vhdl/coredevicemux/regfile.vhd ../../vhdl/coredevicemux/devicemuxtx.vhd ../../vhdl/coredevicemux/devicemuxeventrx2.vhd ../../vhdl/coredevicemux/devicemuxrx.vhd ../../vhdl/coredevicemux/devicemux.vhd ../../vhdl/core/datasequencer.vhd ../../vhdl/core/datarouter.vhd ../../../dspboard/vhdl/encodemux.vhd ../../../dspboard/vhdl/encodemux.vhd ../../../dspboard/vhdl/decodemux.vhd ../../../dspboard/vhdl/decodemux.vhd ../../../dspboard/vhdl/encodedata.vhd ../../../dspboard/vhdl/encodedata.vhd ../../../dspboard/vhdl/datamux.vhd ../../../dspboard/vhdl/datamux.vhd ../../../dspboard/vhdl/regfile.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../../dspboard/vhdl/regfile.vhd

$(WORKDIR)/datasport/behavioral.dat: $(WORKDIR)/touched ../../vhdl/somabackplane.vhd ../../vhdl/coredevicemux/regfile.vhd ../../vhdl/coredevicemux/devicemuxtx.vhd ../../vhdl/coredevicemux/devicemuxeventrx2.vhd ../../vhdl/coredevicemux/devicemuxrx.vhd ../../vhdl/coredevicemux/devicemux.vhd ../../vhdl/core/datasequencer.vhd ../../vhdl/core/datarouter.vhd ../../../dspboard/vhdl/encodemux.vhd ../../../dspboard/vhdl/encodemux.vhd ../../../dspboard/vhdl/decodemux.vhd ../../../dspboard/vhdl/decodemux.vhd ../../../dspboard/vhdl/encodedata.vhd ../../../dspboard/vhdl/encodedata.vhd ../../../dspboard/vhdl/datamux.vhd ../../../dspboard/vhdl/datamux.vhd ../../../dspboard/vhdl/regfile.vhd ../../../dspboard/vhdl/regfile.vhd ../../../dspboard/vhdl/datasport.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../../dspboard/vhdl/datasport.vhd

hw: soma/somabackplane/body.dat soma/regfile/behavioral.dat soma/devicemuxtx/behavioral.dat soma/devicemuxeventrx2/behavioral.dat soma/devicemuxrx/behavioral.dat soma/devicemux/behavioral.dat soma/datasequencer/behavioral.dat soma/datarouter/behavioral.dat $(WORKDIR)/encodemux/behavioral.dat $(WORKDIR)/decodemux/behavioral.dat $(WORKDIR)/encodedata/behavioral.dat $(WORKDIR)/datamux/behavioral.dat $(WORKDIR)/regfile/behavioral.dat $(WORKDIR)/datasport/behavioral.dat 

$(WORKDIR)/fakedspboard/behavioral.dat: $(WORKDIR)/touched fakedspboard.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) fakedspboard.vhd

comp: $(WORKDIR)/fakedspboard/behavioral.dat 

$(WORKDIR)/devicemuxdataroutertest/behavioral.dat: $(WORKDIR)/touched fakedspboard.vhd devicemuxdataroutertest.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) devicemuxdataroutertest.vhd

sim: $(WORKDIR)/devicemuxdataroutertest/behavioral.dat 
runsim: all
	$(VHDLS) devicemuxdataroutertest


clean:
	rm -Rf soma work 

soma/touched:
	vlib  soma
	touch  soma/touched
work/touched:
	vlib  work
	touch  work/touched
