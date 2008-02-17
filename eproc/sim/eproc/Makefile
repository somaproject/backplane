VHDLC=vcom
VHDLS=vsim
WORKDIR=work
all: hw comp sim always

soma/somabackplane/body.dat: soma/touched ../../../vhdl/somabackplane.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../../vhdl/somabackplane.vhd

$(WORKDIR)/alu/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/somabackplane.vhd ../../vhdl/alu.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/alu.vhd

$(WORKDIR)/regfile/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/somabackplane.vhd ../../vhdl/alu.vhd ../../vhdl/alu.vhd ../../vhdl/regfile.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/regfile.vhd

$(WORKDIR)/ecore/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/somabackplane.vhd ../../vhdl/alu.vhd ../../vhdl/alu.vhd ../../vhdl/regfile.vhd ../../vhdl/regfile.vhd ../../vhdl/ecore.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/ecore.vhd

$(WORKDIR)/eventtx/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/somabackplane.vhd ../../vhdl/alu.vhd ../../vhdl/alu.vhd ../../vhdl/regfile.vhd ../../vhdl/regfile.vhd ../../vhdl/ecore.vhd ../../vhdl/ecore.vhd ../../vhdl/eventtx.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/eventtx.vhd

$(WORKDIR)/evtdnd/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/somabackplane.vhd ../../vhdl/alu.vhd ../../vhdl/alu.vhd ../../vhdl/regfile.vhd ../../vhdl/regfile.vhd ../../vhdl/ecore.vhd ../../vhdl/ecore.vhd ../../vhdl/eventtx.vhd ../../vhdl/eventtx.vhd ../../vhdl/evtdnd.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/evtdnd.vhd

$(WORKDIR)/txeventbuffer/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/somabackplane.vhd ../../vhdl/alu.vhd ../../vhdl/alu.vhd ../../vhdl/regfile.vhd ../../vhdl/regfile.vhd ../../vhdl/ecore.vhd ../../vhdl/ecore.vhd ../../vhdl/eventtx.vhd ../../vhdl/eventtx.vhd ../../vhdl/evtdnd.vhd ../../vhdl/evtdnd.vhd ../../vhdl/txeventbuffer.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/txeventbuffer.vhd

$(WORKDIR)/eproc/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/somabackplane.vhd ../../vhdl/alu.vhd ../../vhdl/alu.vhd ../../vhdl/regfile.vhd ../../vhdl/regfile.vhd ../../vhdl/ecore.vhd ../../vhdl/ecore.vhd ../../vhdl/eventtx.vhd ../../vhdl/eventtx.vhd ../../vhdl/evtdnd.vhd ../../vhdl/evtdnd.vhd ../../vhdl/txeventbuffer.vhd ../../vhdl/txeventbuffer.vhd ../../vhdl/eproc.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/eproc.vhd

hw: soma/somabackplane/body.dat $(WORKDIR)/alu/behavioral.dat $(WORKDIR)/regfile/behavioral.dat $(WORKDIR)/ecore/behavioral.dat $(WORKDIR)/eventtx/behavioral.dat $(WORKDIR)/evtdnd/behavioral.dat $(WORKDIR)/txeventbuffer/behavioral.dat $(WORKDIR)/eproc/behavioral.dat 

$(WORKDIR)/IRAM/behavioral.dat: $(WORKDIR)/touched ../components/iram/iram.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../components/iram/iram.vhd

comp: $(WORKDIR)/IRAM/behavioral.dat 

$(WORKDIR)/eproctest/behavioral.dat: $(WORKDIR)/touched ../components/iram/iram.vhd eproctest.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) eproctest.vhd

sim: $(WORKDIR)/eproctest/behavioral.dat 
runsim: all
	$(VHDLS) eproctest


clean:
	rm -Rf soma work 

soma/touched:
	vlib  soma
	touch  soma/touched
work/touched:
	vlib  work
	touch  work/touched
always:
	python ../../assemble/assemble.py loadtest.py loadtest.iram
