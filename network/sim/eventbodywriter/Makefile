VHDLC=vcom
VHDLS=vsim
WORKDIR=work
all: hw comp sim

$(WORKDIR)/networkstack/body.dat: $(WORKDIR)/touched ../../vhdl/networkstack.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/networkstack.vhd

soma/somabackplane/body.dat: soma/touched ../../vhdl/networkstack.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../../vhdl/somabackplane.vhd

$(WORKDIR)/eventbodywriter/behavioral.dat: $(WORKDIR)/touched ../../vhdl/networkstack.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/eventbodywriter.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/eventbodywriter.vhd

hw: $(WORKDIR)/networkstack/body.dat soma/somabackplane/body.dat $(WORKDIR)/eventbodywriter/behavioral.dat 

comp: 

$(WORKDIR)/eventbodywritertest/behavioral.dat: $(WORKDIR)/touched eventbodywritertest.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) eventbodywritertest.vhd

sim: $(WORKDIR)/eventbodywritertest/behavioral.dat 
runsim: all
	$(VHDLS) eventbodywritertest


clean:
	rm -Rf soma work 

soma/touched:
	vlib  soma
	touch  soma/touched
work/touched:
	vlib  work
	touch  work/touched
