VHDLC=vcom
VHDLS=vsim
WORKDIR=work
all: hw comp sim always

soma/somabackplane/body.dat: soma/touched ../../vhdl/somabackplane.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../vhdl/somabackplane.vhd

eproc/alu/behavioral.dat: eproc/touched ../../vhdl/somabackplane.vhd ../../eproc/vhdl/alu.vhd
	mkdir -p eproc
	$(VHDLC) -work eproc  ../../eproc/vhdl/alu.vhd

eproc/regfile/behavioral.dat: eproc/touched ../../vhdl/somabackplane.vhd ../../eproc/vhdl/alu.vhd ../../eproc/vhdl/regfile.vhd
	mkdir -p eproc
	$(VHDLC) -work eproc  ../../eproc/vhdl/regfile.vhd

eproc/ecore/behavioral.dat: eproc/touched ../../vhdl/somabackplane.vhd ../../eproc/vhdl/alu.vhd ../../eproc/vhdl/regfile.vhd ../../eproc/vhdl/ecore.vhd
	mkdir -p eproc
	$(VHDLC) -work eproc  ../../eproc/vhdl/ecore.vhd

eproc/eventtx/behavioral.dat: eproc/touched ../../vhdl/somabackplane.vhd ../../eproc/vhdl/alu.vhd ../../eproc/vhdl/regfile.vhd ../../eproc/vhdl/ecore.vhd ../../eproc/vhdl/eventtx.vhd
	mkdir -p eproc
	$(VHDLC) -work eproc  ../../eproc/vhdl/eventtx.vhd

eproc/evtdnd/behavioral.dat: eproc/touched ../../vhdl/somabackplane.vhd ../../eproc/vhdl/alu.vhd ../../eproc/vhdl/regfile.vhd ../../eproc/vhdl/ecore.vhd ../../eproc/vhdl/eventtx.vhd ../../eproc/vhdl/evtdnd.vhd
	mkdir -p eproc
	$(VHDLC) -work eproc  ../../eproc/vhdl/evtdnd.vhd

eproc/txeventbuffer/behavioral.dat: eproc/touched ../../vhdl/somabackplane.vhd ../../eproc/vhdl/alu.vhd ../../eproc/vhdl/regfile.vhd ../../eproc/vhdl/ecore.vhd ../../eproc/vhdl/eventtx.vhd ../../eproc/vhdl/evtdnd.vhd ../../eproc/vhdl/txeventbuffer.vhd
	mkdir -p eproc
	$(VHDLC) -work eproc  ../../eproc/vhdl/txeventbuffer.vhd

eproc/eproc/behavioral.dat: eproc/touched ../../vhdl/somabackplane.vhd ../../eproc/vhdl/alu.vhd ../../eproc/vhdl/regfile.vhd ../../eproc/vhdl/ecore.vhd ../../eproc/vhdl/eventtx.vhd ../../eproc/vhdl/evtdnd.vhd ../../eproc/vhdl/txeventbuffer.vhd ../../eproc/vhdl/eproc.vhd
	mkdir -p eproc
	$(VHDLC) -work eproc  ../../eproc/vhdl/eproc.vhd

soma/nicserialio/behavioral.dat: soma/touched ../../vhdl/somabackplane.vhd ../../eproc/vhdl/alu.vhd ../../eproc/vhdl/regfile.vhd ../../eproc/vhdl/ecore.vhd ../../eproc/vhdl/eventtx.vhd ../../eproc/vhdl/evtdnd.vhd ../../eproc/vhdl/txeventbuffer.vhd ../../eproc/vhdl/eproc.vhd ../../vhdl/netcontrol/nicserialio.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../vhdl/netcontrol/nicserialio.vhd

soma/nicserialioaddr/behavioral.dat: soma/touched ../../vhdl/somabackplane.vhd ../../eproc/vhdl/alu.vhd ../../eproc/vhdl/regfile.vhd ../../eproc/vhdl/ecore.vhd ../../eproc/vhdl/eventtx.vhd ../../eproc/vhdl/evtdnd.vhd ../../eproc/vhdl/txeventbuffer.vhd ../../eproc/vhdl/eproc.vhd ../../vhdl/netcontrol/nicserialio.vhd ../../vhdl/netcontrol/nicserialioaddr.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../vhdl/netcontrol/nicserialioaddr.vhd

soma/txcounter/behavioral.dat: soma/touched ../../vhdl/somabackplane.vhd ../../eproc/vhdl/alu.vhd ../../eproc/vhdl/regfile.vhd ../../eproc/vhdl/ecore.vhd ../../eproc/vhdl/eventtx.vhd ../../eproc/vhdl/evtdnd.vhd ../../eproc/vhdl/txeventbuffer.vhd ../../eproc/vhdl/eproc.vhd ../../vhdl/netcontrol/nicserialio.vhd ../../vhdl/netcontrol/nicserialioaddr.vhd ../../vhdl/netcontrol/txcounter.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../vhdl/netcontrol/txcounter.vhd

soma/netcontrol/behavioral.dat: soma/touched ../../vhdl/somabackplane.vhd ../../eproc/vhdl/alu.vhd ../../eproc/vhdl/regfile.vhd ../../eproc/vhdl/ecore.vhd ../../eproc/vhdl/eventtx.vhd ../../eproc/vhdl/evtdnd.vhd ../../eproc/vhdl/txeventbuffer.vhd ../../eproc/vhdl/eproc.vhd ../../vhdl/netcontrol/nicserialio.vhd ../../vhdl/netcontrol/nicserialioaddr.vhd ../../vhdl/netcontrol/txcounter.vhd ../../vhdl/netcontrol/netcontrol.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../vhdl/netcontrol/netcontrol.vhd

hw: soma/somabackplane/body.dat eproc/alu/behavioral.dat eproc/regfile/behavioral.dat eproc/ecore/behavioral.dat eproc/eventtx/behavioral.dat eproc/evtdnd/behavioral.dat eproc/txeventbuffer/behavioral.dat eproc/eproc/behavioral.dat soma/nicserialio/behavioral.dat soma/nicserialioaddr/behavioral.dat soma/txcounter/behavioral.dat soma/netcontrol/behavioral.dat 

comp: 

$(WORKDIR)/netcontroltest_mem/body.dat: $(WORKDIR)/touched netcontroltest_mem.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) netcontroltest_mem.vhd

$(WORKDIR)/netcontroltest/behavioral.dat: $(WORKDIR)/touched netcontroltest_mem.vhd netcontroltest.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) netcontroltest.vhd

sim: $(WORKDIR)/netcontroltest_mem/body.dat $(WORKDIR)/netcontroltest/behavioral.dat 
runsim: all
	$(VHDLS) netcontroltest


clean:
	rm -Rf soma eproc work 

soma/touched:
	vlib  soma
	touch  soma/touched
eproc/touched:
	vlib  eproc
	touch  eproc/touched
work/touched:
	vlib  work
	touch  work/touched
always:
	python ../../eproc/assemble/assemble.py ../../vhdl/netcontrol/netcontrol.asmpy netcontrol.imem
	python ../../eproc/assemble/genrom.py netcontroltest.bmm netcontrol.imem
