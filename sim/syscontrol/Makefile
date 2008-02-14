VHDLC=vcom
VHDLS=vsim
WORKDIR=work
all: hw comp sim always

soma/somabackplane/body.dat: soma/touched ../../vhdl/somabackplane.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../vhdl/somabackplane.vhd

network/networkstack/body.dat: network/touched ../../vhdl/somabackplane.vhd ../../network/vhdl/networkstack.vhd
	mkdir -p network
	$(VHDLC) -work network  ../../network/vhdl/networkstack.vhd

network/netports/body.dat: network/touched ../../vhdl/somabackplane.vhd ../../network/vhdl/networkstack.vhd ../../network/vhdl/netports.vhd
	mkdir -p network
	$(VHDLC) -work network  ../../network/vhdl/netports.vhd

soma/rxeventfifo/behavioral.dat: soma/touched ../../vhdl/somabackplane.vhd ../../network/vhdl/networkstack.vhd ../../network/vhdl/netports.vhd ../../vhdl/rxeventfifo.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../vhdl/rxeventfifo.vhd

soma/bootdeserialize/behavioral.dat: soma/touched ../../vhdl/somabackplane.vhd ../../network/vhdl/networkstack.vhd ../../network/vhdl/netports.vhd ../../vhdl/rxeventfifo.vhd ../../deviceio/vhdl/bootdeser.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../deviceio/vhdl/bootdeser.vhd

soma/eventrouter/behavioral.dat: soma/touched ../../vhdl/somabackplane.vhd ../../network/vhdl/networkstack.vhd ../../network/vhdl/netports.vhd ../../vhdl/rxeventfifo.vhd ../../deviceio/vhdl/bootdeser.vhd ../../vhdl/core/eventrouter.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../vhdl/core/eventrouter.vhd

soma/timer/behavioral.dat: soma/touched ../../vhdl/somabackplane.vhd ../../network/vhdl/networkstack.vhd ../../network/vhdl/netports.vhd ../../vhdl/rxeventfifo.vhd ../../deviceio/vhdl/bootdeser.vhd ../../vhdl/core/eventrouter.vhd ../../vhdl/timer.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../vhdl/timer.vhd

jtag/jtagesend/behavioral.dat: jtag/touched ../../vhdl/somabackplane.vhd ../../network/vhdl/networkstack.vhd ../../network/vhdl/netports.vhd ../../vhdl/rxeventfifo.vhd ../../deviceio/vhdl/bootdeser.vhd ../../vhdl/core/eventrouter.vhd ../../vhdl/timer.vhd ../../jtag/vhdl/jtagesend.vhd
	mkdir -p jtag
	$(VHDLC) -work jtag  ../../jtag/vhdl/jtagesend.vhd

jtag/jtagereceive/behavioral.dat: jtag/touched ../../vhdl/somabackplane.vhd ../../network/vhdl/networkstack.vhd ../../network/vhdl/netports.vhd ../../vhdl/rxeventfifo.vhd ../../deviceio/vhdl/bootdeser.vhd ../../vhdl/core/eventrouter.vhd ../../vhdl/timer.vhd ../../jtag/vhdl/jtagesend.vhd ../../jtag/vhdl/jtagereceive.vhd
	mkdir -p jtag
	$(VHDLC) -work jtag  ../../jtag/vhdl/jtagereceive.vhd

eproc/alu/behavioral.dat: eproc/touched ../../vhdl/somabackplane.vhd ../../network/vhdl/networkstack.vhd ../../network/vhdl/netports.vhd ../../vhdl/rxeventfifo.vhd ../../deviceio/vhdl/bootdeser.vhd ../../vhdl/core/eventrouter.vhd ../../vhdl/timer.vhd ../../jtag/vhdl/jtagesend.vhd ../../jtag/vhdl/jtagereceive.vhd ../../eproc/vhdl/alu.vhd
	mkdir -p eproc
	$(VHDLC) -work eproc  ../../eproc/vhdl/alu.vhd

eproc/ecore/behavioral.dat: eproc/touched ../../vhdl/somabackplane.vhd ../../network/vhdl/networkstack.vhd ../../network/vhdl/netports.vhd ../../vhdl/rxeventfifo.vhd ../../deviceio/vhdl/bootdeser.vhd ../../vhdl/core/eventrouter.vhd ../../vhdl/timer.vhd ../../jtag/vhdl/jtagesend.vhd ../../jtag/vhdl/jtagereceive.vhd ../../eproc/vhdl/alu.vhd ../../eproc/vhdl/ecore.vhd
	mkdir -p eproc
	$(VHDLC) -work eproc  ../../eproc/vhdl/ecore.vhd

eproc/eventtx/behavioral.dat: eproc/touched ../../vhdl/somabackplane.vhd ../../network/vhdl/networkstack.vhd ../../network/vhdl/netports.vhd ../../vhdl/rxeventfifo.vhd ../../deviceio/vhdl/bootdeser.vhd ../../vhdl/core/eventrouter.vhd ../../vhdl/timer.vhd ../../jtag/vhdl/jtagesend.vhd ../../jtag/vhdl/jtagereceive.vhd ../../eproc/vhdl/alu.vhd ../../eproc/vhdl/ecore.vhd ../../eproc/vhdl/eventtx.vhd
	mkdir -p eproc
	$(VHDLC) -work eproc  ../../eproc/vhdl/eventtx.vhd

eproc/eproc/behavioral.dat: eproc/touched ../../vhdl/somabackplane.vhd ../../network/vhdl/networkstack.vhd ../../network/vhdl/netports.vhd ../../vhdl/rxeventfifo.vhd ../../deviceio/vhdl/bootdeser.vhd ../../vhdl/core/eventrouter.vhd ../../vhdl/timer.vhd ../../jtag/vhdl/jtagesend.vhd ../../jtag/vhdl/jtagereceive.vhd ../../eproc/vhdl/alu.vhd ../../eproc/vhdl/ecore.vhd ../../eproc/vhdl/eventtx.vhd ../../eproc/vhdl/eproc.vhd
	mkdir -p eproc
	$(VHDLC) -work eproc  ../../eproc/vhdl/eproc.vhd

eproc/evtdnd/behavioral.dat: eproc/touched ../../vhdl/somabackplane.vhd ../../network/vhdl/networkstack.vhd ../../network/vhdl/netports.vhd ../../vhdl/rxeventfifo.vhd ../../deviceio/vhdl/bootdeser.vhd ../../vhdl/core/eventrouter.vhd ../../vhdl/timer.vhd ../../jtag/vhdl/jtagesend.vhd ../../jtag/vhdl/jtagereceive.vhd ../../eproc/vhdl/alu.vhd ../../eproc/vhdl/ecore.vhd ../../eproc/vhdl/eventtx.vhd ../../eproc/vhdl/eproc.vhd ../../eproc/vhdl/evtdnd.vhd
	mkdir -p eproc
	$(VHDLC) -work eproc  ../../eproc/vhdl/evtdnd.vhd

eproc/regfile/behavioral.dat: eproc/touched ../../vhdl/somabackplane.vhd ../../network/vhdl/networkstack.vhd ../../network/vhdl/netports.vhd ../../vhdl/rxeventfifo.vhd ../../deviceio/vhdl/bootdeser.vhd ../../vhdl/core/eventrouter.vhd ../../vhdl/timer.vhd ../../jtag/vhdl/jtagesend.vhd ../../jtag/vhdl/jtagereceive.vhd ../../eproc/vhdl/alu.vhd ../../eproc/vhdl/ecore.vhd ../../eproc/vhdl/eventtx.vhd ../../eproc/vhdl/eproc.vhd ../../eproc/vhdl/evtdnd.vhd ../../eproc/vhdl/regfile.vhd
	mkdir -p eproc
	$(VHDLC) -work eproc  ../../eproc/vhdl/regfile.vhd

eproc/txeventbuffer/behavioral.dat: eproc/touched ../../vhdl/somabackplane.vhd ../../network/vhdl/networkstack.vhd ../../network/vhdl/netports.vhd ../../vhdl/rxeventfifo.vhd ../../deviceio/vhdl/bootdeser.vhd ../../vhdl/core/eventrouter.vhd ../../vhdl/timer.vhd ../../jtag/vhdl/jtagesend.vhd ../../jtag/vhdl/jtagereceive.vhd ../../eproc/vhdl/alu.vhd ../../eproc/vhdl/ecore.vhd ../../eproc/vhdl/eventtx.vhd ../../eproc/vhdl/eproc.vhd ../../eproc/vhdl/evtdnd.vhd ../../eproc/vhdl/regfile.vhd ../../eproc/vhdl/txeventbuffer.vhd
	mkdir -p eproc
	$(VHDLC) -work eproc  ../../eproc/vhdl/txeventbuffer.vhd

soma/nicserialio/behavioral.dat: soma/touched ../../vhdl/somabackplane.vhd ../../network/vhdl/networkstack.vhd ../../network/vhdl/netports.vhd ../../vhdl/rxeventfifo.vhd ../../deviceio/vhdl/bootdeser.vhd ../../vhdl/core/eventrouter.vhd ../../vhdl/timer.vhd ../../jtag/vhdl/jtagesend.vhd ../../jtag/vhdl/jtagereceive.vhd ../../eproc/vhdl/alu.vhd ../../eproc/vhdl/ecore.vhd ../../eproc/vhdl/eventtx.vhd ../../eproc/vhdl/eproc.vhd ../../eproc/vhdl/evtdnd.vhd ../../eproc/vhdl/regfile.vhd ../../eproc/vhdl/txeventbuffer.vhd ../../vhdl/netcontrol/nicserialio.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../vhdl/netcontrol/nicserialio.vhd

soma/nicserialioaddr/behavioral.dat: soma/touched ../../vhdl/somabackplane.vhd ../../network/vhdl/networkstack.vhd ../../network/vhdl/netports.vhd ../../vhdl/rxeventfifo.vhd ../../deviceio/vhdl/bootdeser.vhd ../../vhdl/core/eventrouter.vhd ../../vhdl/timer.vhd ../../jtag/vhdl/jtagesend.vhd ../../jtag/vhdl/jtagereceive.vhd ../../eproc/vhdl/alu.vhd ../../eproc/vhdl/ecore.vhd ../../eproc/vhdl/eventtx.vhd ../../eproc/vhdl/eproc.vhd ../../eproc/vhdl/evtdnd.vhd ../../eproc/vhdl/regfile.vhd ../../eproc/vhdl/txeventbuffer.vhd ../../vhdl/netcontrol/nicserialio.vhd ../../vhdl/netcontrol/nicserialioaddr.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../vhdl/netcontrol/nicserialioaddr.vhd

soma/txcounter/behavioral.dat: soma/touched ../../vhdl/somabackplane.vhd ../../network/vhdl/networkstack.vhd ../../network/vhdl/netports.vhd ../../vhdl/rxeventfifo.vhd ../../deviceio/vhdl/bootdeser.vhd ../../vhdl/core/eventrouter.vhd ../../vhdl/timer.vhd ../../jtag/vhdl/jtagesend.vhd ../../jtag/vhdl/jtagereceive.vhd ../../eproc/vhdl/alu.vhd ../../eproc/vhdl/ecore.vhd ../../eproc/vhdl/eventtx.vhd ../../eproc/vhdl/eproc.vhd ../../eproc/vhdl/evtdnd.vhd ../../eproc/vhdl/regfile.vhd ../../eproc/vhdl/txeventbuffer.vhd ../../vhdl/netcontrol/nicserialio.vhd ../../vhdl/netcontrol/nicserialioaddr.vhd ../../vhdl/netcontrol/txcounter.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../vhdl/netcontrol/txcounter.vhd

soma/netcontrol/behavioral.dat: soma/touched ../../vhdl/somabackplane.vhd ../../network/vhdl/networkstack.vhd ../../network/vhdl/netports.vhd ../../vhdl/rxeventfifo.vhd ../../deviceio/vhdl/bootdeser.vhd ../../vhdl/core/eventrouter.vhd ../../vhdl/timer.vhd ../../jtag/vhdl/jtagesend.vhd ../../jtag/vhdl/jtagereceive.vhd ../../eproc/vhdl/alu.vhd ../../eproc/vhdl/ecore.vhd ../../eproc/vhdl/eventtx.vhd ../../eproc/vhdl/eproc.vhd ../../eproc/vhdl/evtdnd.vhd ../../eproc/vhdl/regfile.vhd ../../eproc/vhdl/txeventbuffer.vhd ../../vhdl/netcontrol/nicserialio.vhd ../../vhdl/netcontrol/nicserialioaddr.vhd ../../vhdl/netcontrol/txcounter.vhd ../../vhdl/netcontrol/netcontrol.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../vhdl/netcontrol/netcontrol.vhd

soma/syscontrol/behavioral.dat: soma/touched ../../vhdl/somabackplane.vhd ../../network/vhdl/networkstack.vhd ../../network/vhdl/netports.vhd ../../vhdl/rxeventfifo.vhd ../../deviceio/vhdl/bootdeser.vhd ../../vhdl/core/eventrouter.vhd ../../vhdl/timer.vhd ../../jtag/vhdl/jtagesend.vhd ../../jtag/vhdl/jtagereceive.vhd ../../eproc/vhdl/alu.vhd ../../eproc/vhdl/ecore.vhd ../../eproc/vhdl/eventtx.vhd ../../eproc/vhdl/eproc.vhd ../../eproc/vhdl/evtdnd.vhd ../../eproc/vhdl/regfile.vhd ../../eproc/vhdl/txeventbuffer.vhd ../../vhdl/netcontrol/nicserialio.vhd ../../vhdl/netcontrol/nicserialioaddr.vhd ../../vhdl/netcontrol/txcounter.vhd ../../vhdl/netcontrol/netcontrol.vhd ../../vhdl/syscontrol/syscontrol.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../vhdl/syscontrol/syscontrol.vhd

soma/bootserialize/behavioral.dat: soma/touched ../../vhdl/somabackplane.vhd ../../network/vhdl/networkstack.vhd ../../network/vhdl/netports.vhd ../../vhdl/rxeventfifo.vhd ../../deviceio/vhdl/bootdeser.vhd ../../vhdl/core/eventrouter.vhd ../../vhdl/timer.vhd ../../jtag/vhdl/jtagesend.vhd ../../jtag/vhdl/jtagereceive.vhd ../../eproc/vhdl/alu.vhd ../../eproc/vhdl/ecore.vhd ../../eproc/vhdl/eventtx.vhd ../../eproc/vhdl/eproc.vhd ../../eproc/vhdl/evtdnd.vhd ../../eproc/vhdl/regfile.vhd ../../eproc/vhdl/txeventbuffer.vhd ../../vhdl/netcontrol/nicserialio.vhd ../../vhdl/netcontrol/nicserialioaddr.vhd ../../vhdl/netcontrol/txcounter.vhd ../../vhdl/netcontrol/netcontrol.vhd ../../vhdl/syscontrol/syscontrol.vhd ../../vhdl/syscontrol/bootserialize.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../vhdl/syscontrol/bootserialize.vhd

soma/bootserperipheral/behavioral.dat: soma/touched ../../vhdl/somabackplane.vhd ../../network/vhdl/networkstack.vhd ../../network/vhdl/netports.vhd ../../vhdl/rxeventfifo.vhd ../../deviceio/vhdl/bootdeser.vhd ../../vhdl/core/eventrouter.vhd ../../vhdl/timer.vhd ../../jtag/vhdl/jtagesend.vhd ../../jtag/vhdl/jtagereceive.vhd ../../eproc/vhdl/alu.vhd ../../eproc/vhdl/ecore.vhd ../../eproc/vhdl/eventtx.vhd ../../eproc/vhdl/eproc.vhd ../../eproc/vhdl/evtdnd.vhd ../../eproc/vhdl/regfile.vhd ../../eproc/vhdl/txeventbuffer.vhd ../../vhdl/netcontrol/nicserialio.vhd ../../vhdl/netcontrol/nicserialioaddr.vhd ../../vhdl/netcontrol/txcounter.vhd ../../vhdl/netcontrol/netcontrol.vhd ../../vhdl/syscontrol/syscontrol.vhd ../../vhdl/syscontrol/bootserialize.vhd ../../vhdl/syscontrol/bootserperipheral.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../vhdl/syscontrol/bootserperipheral.vhd

hw: soma/somabackplane/body.dat network/networkstack/body.dat network/netports/body.dat soma/rxeventfifo/behavioral.dat soma/bootdeserialize/behavioral.dat soma/eventrouter/behavioral.dat soma/timer/behavioral.dat jtag/jtagesend/behavioral.dat jtag/jtagereceive/behavioral.dat eproc/alu/behavioral.dat eproc/ecore/behavioral.dat eproc/eventtx/behavioral.dat eproc/eproc/behavioral.dat eproc/evtdnd/behavioral.dat eproc/regfile/behavioral.dat eproc/txeventbuffer/behavioral.dat soma/nicserialio/behavioral.dat soma/nicserialioaddr/behavioral.dat soma/txcounter/behavioral.dat soma/netcontrol/behavioral.dat soma/syscontrol/behavioral.dat soma/bootserialize/behavioral.dat soma/bootserperipheral/behavioral.dat 

comp: 

work/syscontroltest_mem/body.dat: work/touched syscontroltest_mem.vhd
	mkdir -p work
	$(VHDLC) -work work  syscontroltest_mem.vhd

work/syscontroltest/behavioral.dat: work/touched syscontroltest.vhd
	mkdir -p work
	$(VHDLC) -work work  syscontroltest.vhd

sim: work/syscontroltest_mem/body.dat work/syscontroltest/behavioral.dat 
runsim: all
	$(VHDLS) syscontroltest


clean:
	rm -Rf soma eproc work network jtag 

soma/touched:
	vlib  soma
	touch  soma/touched
eproc/touched:
	vlib  eproc
	touch  eproc/touched
work/touched:
	vlib  work
	touch  work/touched
network/touched:
	vlib  network
	touch  network/touched
jtag/touched:
	vlib  jtag
	touch  jtag/touched
always:
	python ../../eproc/assemble/assemble.py ../../tgt/backplane/vhdl/backplane.asmpy syscontrol.imem
	python ../../eproc/assemble/genrom.py syscontroltest.bmm syscontrol.imem
