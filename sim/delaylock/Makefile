VHDLC=vcom
VHDLS=vsim
WORKDIR=work
all: hw comp sim

$(WORKDIR)/somabackplane/body.dat: $(WORKDIR)/touched ../../vhdl/somabackplane.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/somabackplane.vhd

$(WORKDIR)/windowdetect/behavioral.dat: $(WORKDIR)/touched ../../vhdl/somabackplane.vhd ../../vhdl/somabackplane.vhd ../../vhdl/devicelink/windowdetect.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/devicelink/windowdetect.vhd

$(WORKDIR)/delaytable/behavioral.dat: $(WORKDIR)/touched ../../vhdl/somabackplane.vhd ../../vhdl/somabackplane.vhd ../../vhdl/devicelink/windowdetect.vhd ../../vhdl/devicelink/windowdetect.vhd ../../vhdl/devicelink/delaytable.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/devicelink/delaytable.vhd

$(WORKDIR)/delaylock/behavioral.dat: $(WORKDIR)/touched ../../vhdl/somabackplane.vhd ../../vhdl/somabackplane.vhd ../../vhdl/devicelink/windowdetect.vhd ../../vhdl/devicelink/windowdetect.vhd ../../vhdl/devicelink/delaytable.vhd ../../vhdl/devicelink/delaytable.vhd ../../vhdl/devicelink/delaylock.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/devicelink/delaylock.vhd

hw: $(WORKDIR)/somabackplane/body.dat $(WORKDIR)/windowdetect/behavioral.dat $(WORKDIR)/delaytable/behavioral.dat $(WORKDIR)/delaylock/behavioral.dat 

$(WORKDIR)/simdelay/behavioral.dat: $(WORKDIR)/touched simdelay.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) simdelay.vhd

comp: $(WORKDIR)/simdelay/behavioral.dat 

$(WORKDIR)/delaylocktest/behavioral.dat: $(WORKDIR)/touched simdelay.vhd delaylocktest.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) delaylocktest.vhd

sim: $(WORKDIR)/delaylocktest/behavioral.dat 
runsim: all
	$(VHDLS) delaylocktest


clean:
	rm -Rf work 

work/touched:
	vlib  work
	touch  work/touched
