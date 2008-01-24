VHDLC=vcom
VHDLS=vsim
WORKDIR=work
all: hw comp sim

soma/somabackplane/body.dat: ../../../vhdl/somabackplane.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../../vhdl/somabackplane.vhd

network/networkstack/body.dat: ../../../network/vhdl/networkstack.vhd
	mkdir -p network
	$(VHDLC) -work network  ../../../network/vhdl/networkstack.vhd

network/netports/body.dat: ../../../network/vhdl/netports.vhd
	mkdir -p network
	$(VHDLC) -work network  ../../../network/vhdl/netports.vhd

soma/rxeventfifo/behavioral.dat: ../../../vhdl/rxeventfifo.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../../vhdl/rxeventfifo.vhd

soma/bootdeser/behavioral.dat: ../../../deviceio/vhdl/bootdeser.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../../deviceio/vhdl/bootdeser.vhd

soma/eventrouter/behavioral.dat: ../../../vhdl/core/eventrouter.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../../vhdl/core/eventrouter.vhd

soma/timer/behavioral.dat: ../../../vhdl/timer.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../../vhdl/timer.vhd

soma/nicserialio/behavioral.dat: ../../../vhdl/ether/nicserialio.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../../vhdl/ether/nicserialio.vhd

soma/ethercontrol/behavioral.dat: ../../../vhdl/ether/ethercontrol.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../../vhdl/ether/ethercontrol.vhd

soma/ether/behavioral.dat: ../../../vhdl/ether/ether.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../../vhdl/ether/ether.vhd

soma/txcounter/behavioral.dat: ../../../vhdl/netcontrol/txcounter.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../../vhdl/netcontrol/txcounter.vhd

soma/netcontrol/behavioral.dat: ../../../vhdl/netcontrol/netcontrol.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../../vhdl/netcontrol/netcontrol.vhd

jtag/jtagesend/behavioral.dat: ../../../jtag/vhdl/jtagesend.vhd
	mkdir -p jtag
	$(VHDLC) -work jtag  ../../../jtag/vhdl/jtagesend.vhd

jtag/jtagereceive/behavioral.dat: ../../../jtag/vhdl/jtagereceive.vhd
	mkdir -p jtag
	$(VHDLC) -work jtag  ../../../jtag/vhdl/jtagereceive.vhd

eproc/alu/behavioral.dat: ../../../eproc/vhdl/alu.vhd
	mkdir -p eproc
	$(VHDLC) -work eproc  ../../../eproc/vhdl/alu.vhd

eproc/ecore/behavioral.dat: ../../../eproc/vhdl/ecore.vhd
	mkdir -p eproc
	$(VHDLC) -work eproc  ../../../eproc/vhdl/ecore.vhd

eproc/eventtx/behavioral.dat: ../../../eproc/vhdl/eventtx.vhd
	mkdir -p eproc
	$(VHDLC) -work eproc  ../../../eproc/vhdl/eventtx.vhd

eproc/eproc/behavioral.dat: ../../../eproc/vhdl/eproc.vhd
	mkdir -p eproc
	$(VHDLC) -work eproc  ../../../eproc/vhdl/eproc.vhd

eproc/evtdnd/behavioral.dat: ../../../eproc/vhdl/evtdnd.vhd
	mkdir -p eproc
	$(VHDLC) -work eproc  ../../../eproc/vhdl/evtdnd.vhd

eproc/regfile/behavioral.dat: ../../../eproc/vhdl/regfile.vhd
	mkdir -p eproc
	$(VHDLC) -work eproc  ../../../eproc/vhdl/regfile.vhd

eproc/txeventbuffer/behavioral.dat: ../../../eproc/vhdl/txeventbuffer.vhd
	mkdir -p eproc
	$(VHDLC) -work eproc  ../../../eproc/vhdl/txeventbuffer.vhd

syscon/syscontrol/behavioral.dat: ../../../vhdl/syscontrol/syscontrol.vhd
	mkdir -p syscon
	$(VHDLC) -work syscon  ../../../vhdl/syscontrol/syscontrol.vhd

syscon/bootserialize/behavioral.dat: ../../../vhdl/syscontrol/bootserialize.vhd
	mkdir -p syscon
	$(VHDLC) -work syscon  ../../../vhdl/syscontrol/bootserialize.vhd

syscon/bootserperipheral/behavioral.dat: ../../../vhdl/syscontrol/bootserperipheral.vhd
	mkdir -p syscon
	$(VHDLC) -work syscon  ../../../vhdl/syscontrol/bootserperipheral.vhd

soma/bootspiio/behavioral.dat: ../../../vhdl/bootspiio.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../../vhdl/bootspiio.vhd

soma/bootstore/behavioral.dat: ../../../vhdl/bootstore.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../../vhdl/bootstore.vhd

soma/singleeventdesttx/behavioral.dat: ../../../vhdl/singleeventdesttx.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../../vhdl/singleeventdesttx.vhd

network/ipchecksum/behavioral.dat: ../../../network/vhdl/ipchecksum.vhd
	mkdir -p network
	$(VHDLC) -work network  ../../../network/vhdl/ipchecksum.vhd

network/udpheaderwriter/behavioral.dat: ../../../network/vhdl/udpheaderwriter.vhd
	mkdir -p network
	$(VHDLC) -work network  ../../../network/vhdl/udpheaderwriter.vhd

network/crc_combinational/behavioral.dat: ../../../network/crc/vhdl/crc_combinational.vhd
	mkdir -p network
	$(VHDLC) -work network  ../../../network/crc/vhdl/crc_combinational.vhd

network/crc16_combinational/behavioral.dat: ../../../network/crc/vhdl/crc16_combinational.vhd
	mkdir -p network
	$(VHDLC) -work network  ../../../network/crc/vhdl/crc16_combinational.vhd

network/crcverify/behavioral.dat: ../../../network/crc/vhdl/crcverify.vhd
	mkdir -p network
	$(VHDLC) -work network  ../../../network/crc/vhdl/crcverify.vhd

network/crcappend/behavioral.dat: ../../../network/crc/vhdl/crcappend.vhd
	mkdir -p network
	$(VHDLC) -work network  ../../../network/crc/vhdl/crcappend.vhd

network/arpresponse/behavioral.dat: ../../../network/vhdl/arpresponse.vhd
	mkdir -p network
	$(VHDLC) -work network  ../../../network/vhdl/arpresponse.vhd

network/dataacquire/behavioral.dat: ../../../network/vhdl/dataacquire.vhd
	mkdir -p network
	$(VHDLC) -work network  ../../../network/vhdl/dataacquire.vhd

network/datafifo/behavioral.dat: ../../../network/vhdl/datafifo.vhd
	mkdir -p network
	$(VHDLC) -work network  ../../../network/vhdl/datafifo.vhd

network/datapacketgen/behavioral.dat: ../../../network/vhdl/datapacketgen.vhd
	mkdir -p network
	$(VHDLC) -work network  ../../../network/vhdl/datapacketgen.vhd

network/dataretxresponse/behavioral.dat: ../../../network/vhdl/dataretxresponse.vhd
	mkdir -p network
	$(VHDLC) -work network  ../../../network/vhdl/dataretxresponse.vhd

network/dataretxbuf/behavioral.dat: ../../../network/vhdl/dataretxbuf.vhd
	mkdir -p network
	$(VHDLC) -work network  ../../../network/vhdl/dataretxbuf.vhd

network/data/behavioral.dat: ../../../network/vhdl/data.vhd
	mkdir -p network
	$(VHDLC) -work network  ../../../network/vhdl/data.vhd

network/bigmem/behavioral.dat: ../../../network/vhdl/bigmem.vhd
	mkdir -p network
	$(VHDLC) -work network  ../../../network/vhdl/bigmem.vhd

network/retxbuffer/behavioral.dat: ../../../network/vhdl/retxbuffer.vhd
	mkdir -p network
	$(VHDLC) -work network  ../../../network/vhdl/retxbuffer.vhd

network/eventbodywriter/behavioral.dat: ../../../network/vhdl/eventbodywriter.vhd
	mkdir -p network
	$(VHDLC) -work network  ../../../network/vhdl/eventbodywriter.vhd

network/eventrxbusoutput/behavioral.dat: ../../../network/vhdl/eventrxbusoutput.vhd
	mkdir -p network
	$(VHDLC) -work network  ../../../network/vhdl/eventrxbusoutput.vhd

network/eventrxresponsewr/behavioral.dat: ../../../network/vhdl/eventrxresponsewr.vhd
	mkdir -p network
	$(VHDLC) -work network  ../../../network/vhdl/eventrxresponsewr.vhd

network/eventtxpkfifo/behavioral.dat: ../../../network/vhdl/eventtxpkfifo.vhd
	mkdir -p network
	$(VHDLC) -work network  ../../../network/vhdl/eventtxpkfifo.vhd

network/eventretxresponse/behavioral.dat: ../../../network/vhdl/eventretxresponse.vhd
	mkdir -p network
	$(VHDLC) -work network  ../../../network/vhdl/eventretxresponse.vhd

network/eventrx/behavioral.dat: ../../../network/vhdl/eventrx.vhd
	mkdir -p network
	$(VHDLC) -work network  ../../../network/vhdl/eventrx.vhd

network/eventtx/behavioral.dat: ../../../network/vhdl/eventtx.vhd
	mkdir -p network
	$(VHDLC) -work network  ../../../network/vhdl/eventtx.vhd

network/bitcnt/behavioral.dat: ../../../network/vhdl/bitcnt.vhd
	mkdir -p network
	$(VHDLC) -work network  ../../../network/vhdl/bitcnt.vhd

network/pingicmpwriter/behavioral.dat: ../../../network/vhdl/pingicmpwriter.vhd
	mkdir -p network
	$(VHDLC) -work network  ../../../network/vhdl/pingicmpwriter.vhd

network/pingipwriter/behavioral.dat: ../../../network/vhdl/pingipwriter.vhd
	mkdir -p network
	$(VHDLC) -work network  ../../../network/vhdl/pingipwriter.vhd

network/pingresponse/behavioral.dat: ../../../network/vhdl/pingresponse.vhd
	mkdir -p network
	$(VHDLC) -work network  ../../../network/vhdl/pingresponse.vhd

network/txmux/behavioral.dat: ../../../network/vhdl/txmux.vhd
	mkdir -p network
	$(VHDLC) -work network  ../../../network/vhdl/txmux.vhd

network/inputcontrol/behavioral.dat: ../../../network/vhdl/inputcontrol.vhd
	mkdir -p network
	$(VHDLC) -work network  ../../../network/vhdl/inputcontrol.vhd

network/network/behavioral.dat: ../../../network/vhdl/network.vhd
	mkdir -p network
	$(VHDLC) -work network  ../../../network/vhdl/network.vhd

memory/dqalign/behavioral.dat: ../../../memory/vhdl/dqalign.vhd
	mkdir -p memory
	$(VHDLC) -work memory  ../../../memory/vhdl/dqalign.vhd

memory/bootddr2/behavioral.dat: ../../../memory/vhdl/bootddr2.vhd
	mkdir -p memory
	$(VHDLC) -work memory  ../../../memory/vhdl/bootddr2.vhd

memory/readddr2/behavioral.dat: ../../../memory/vhdl/readddr2.vhd
	mkdir -p memory
	$(VHDLC) -work memory  ../../../memory/vhdl/readddr2.vhd

memory/memcontmux/behavioral.dat: ../../../memory/vhdl/memcontmux.vhd
	mkdir -p memory
	$(VHDLC) -work memory  ../../../memory/vhdl/memcontmux.vhd

memory/refreshddr2/behavioral.dat: ../../../memory/vhdl/refreshddr2.vhd
	mkdir -p memory
	$(VHDLC) -work memory  ../../../memory/vhdl/refreshddr2.vhd

memory/writeddr2/behavioral.dat: ../../../memory/vhdl/writeddr2.vhd
	mkdir -p memory
	$(VHDLC) -work memory  ../../../memory/vhdl/writeddr2.vhd

memory/memddr2/behavioral.dat: ../../../memory/vhdl/memddr2.vhd
	mkdir -p memory
	$(VHDLC) -work memory  ../../../memory/vhdl/memddr2.vhd

soma/decoder/behavioral.dat: ../../../vhdl/fiberdebug/decoder.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../../vhdl/fiberdebug/decoder.vhd

soma/fiberdebugrx/behavioral.dat: ../../../vhdl/fiberdebug/fiberdebugrx.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../../vhdl/fiberdebug/fiberdebugrx.vhd

soma/fiberdebugtx/behavioral.dat: ../../../vhdl/fiberdebug/fiberdebugtx.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../../vhdl/fiberdebug/fiberdebugtx.vhd

soma/fiberdebug/behavioral.dat: ../../../vhdl/fiberdebug/fiberdebug.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../../vhdl/fiberdebug/fiberdebug.vhd

soma/fibertx/behavioral.dat: ../../../vhdl/fiberdebug/fibertx.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../../vhdl/fiberdebug/fibertx.vhd

soma/framedis/behavioral.dat: ../../../vhdl/fiberdebug/framedis.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../../vhdl/fiberdebug/framedis.vhd

soma/txeventbuffer/behavioral.dat: ../../../vhdl/fiberdebug/txeventbuffer.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../../vhdl/fiberdebug/txeventbuffer.vhd

work/decode8b10b/behavioral.dat: ../vhdl/decode8b10b.vhd
	mkdir -p work
	$(VHDLC) -work work  ../vhdl/decode8b10b.vhd

work/encode8b10b/behavioral.dat: ../vhdl/encode8b10b.vhd
	mkdir -p work
	$(VHDLC) -work work  ../vhdl/encode8b10b.vhd

work/fiberdecode8b10b/behavioral.dat: ../vhdl/fiberdecode8b10b.vhd
	mkdir -p work
	$(VHDLC) -work work  ../vhdl/fiberdecode8b10b.vhd

work/fiberencode8b10b/behavioral.dat: ../vhdl/fiberencode8b10b.vhd
	mkdir -p work
	$(VHDLC) -work work  ../vhdl/fiberencode8b10b.vhd

work/backplane_mem/body.dat: ../vhdl/backplane_mem.vhd
	mkdir -p work
	$(VHDLC) -work work  ../vhdl/backplane_mem.vhd

work/fakedata/behavioral.dat: ../vhdl/fakedata.vhd
	mkdir -p work
	$(VHDLC) -work work  ../vhdl/fakedata.vhd

work/backplane/behavioral.dat: ../vhdl/backplane.vhd
	mkdir -p work
	$(VHDLC) -work work  ../vhdl/backplane.vhd

hw: soma/somabackplane/body.dat network/networkstack/body.dat network/netports/body.dat soma/rxeventfifo/behavioral.dat soma/bootdeser/behavioral.dat soma/eventrouter/behavioral.dat soma/timer/behavioral.dat soma/nicserialio/behavioral.dat soma/ethercontrol/behavioral.dat soma/ether/behavioral.dat soma/txcounter/behavioral.dat soma/netcontrol/behavioral.dat jtag/jtagesend/behavioral.dat jtag/jtagereceive/behavioral.dat eproc/alu/behavioral.dat eproc/ecore/behavioral.dat eproc/eventtx/behavioral.dat eproc/eproc/behavioral.dat eproc/evtdnd/behavioral.dat eproc/regfile/behavioral.dat eproc/txeventbuffer/behavioral.dat syscon/syscontrol/behavioral.dat syscon/bootserialize/behavioral.dat syscon/bootserperipheral/behavioral.dat soma/bootspiio/behavioral.dat soma/bootstore/behavioral.dat soma/singleeventdesttx/behavioral.dat network/ipchecksum/behavioral.dat network/udpheaderwriter/behavioral.dat network/crc_combinational/behavioral.dat network/crc16_combinational/behavioral.dat network/crcverify/behavioral.dat network/crcappend/behavioral.dat network/arpresponse/behavioral.dat network/dataacquire/behavioral.dat network/datafifo/behavioral.dat network/datapacketgen/behavioral.dat network/dataretxresponse/behavioral.dat network/dataretxbuf/behavioral.dat network/data/behavioral.dat network/bigmem/behavioral.dat network/retxbuffer/behavioral.dat network/eventbodywriter/behavioral.dat network/eventrxbusoutput/behavioral.dat network/eventrxresponsewr/behavioral.dat network/eventtxpkfifo/behavioral.dat network/eventretxresponse/behavioral.dat network/eventrx/behavioral.dat network/eventtx/behavioral.dat network/bitcnt/behavioral.dat network/pingicmpwriter/behavioral.dat network/pingipwriter/behavioral.dat network/pingresponse/behavioral.dat network/txmux/behavioral.dat network/inputcontrol/behavioral.dat network/network/behavioral.dat memory/dqalign/behavioral.dat memory/bootddr2/behavioral.dat memory/readddr2/behavioral.dat memory/memcontmux/behavioral.dat memory/refreshddr2/behavioral.dat memory/writeddr2/behavioral.dat memory/memddr2/behavioral.dat soma/decoder/behavioral.dat soma/fiberdebugrx/behavioral.dat soma/fiberdebugtx/behavioral.dat soma/fiberdebug/behavioral.dat soma/fibertx/behavioral.dat soma/framedis/behavioral.dat soma/txeventbuffer/behavioral.dat work/decode8b10b/behavioral.dat work/encode8b10b/behavioral.dat work/fiberdecode8b10b/behavioral.dat work/fiberencode8b10b/behavioral.dat work/backplane_mem/body.dat work/fakedata/behavioral.dat work/backplane/behavioral.dat 

$(WORKDIR)/bootdeserialize/behavioral.dat: ../../../sim/components/bootdeser/bootdeserialize.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../../sim/components/bootdeser/bootdeserialize.vhd

$(WORKDIR)/mmc/behavioral.dat: ../../../sim/components/bootdeser/bootdeserialize.vhd ../../../boot/sim/components/mmc/mmc.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../../boot/sim/components/mmc/mmc.vhd

comp: $(WORKDIR)/bootdeserialize/behavioral.dat $(WORKDIR)/mmc/behavioral.dat 

$(WORKDIR)/backplanetest/behavioral.dat: ../../../sim/components/bootdeser/bootdeserialize.vhd ../../../boot/sim/components/mmc/mmc.vhd backplanetest.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) backplanetest.vhd

sim: $(WORKDIR)/backplanetest/behavioral.dat 
runsim: all
	$(VHDLS) backplanetest


clean:
	rm -Rf eproc work network soma syscon memory jtag 

eproc/:
	mkdir -p eproc
	touch  eproc/_info
work/:
	mkdir -p work
	touch  work/_info
network/:
	mkdir -p network
	touch  network/_info
soma/:
	mkdir -p soma
	touch  soma/_info
syscon/:
	mkdir -p syscon
	touch  syscon/_info
memory/:
	mkdir -p memory
	touch  memory/_info
jtag/:
	mkdir -p jtag
	touch  jtag/_info
