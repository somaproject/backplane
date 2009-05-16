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

hw: $(WORKDIR)/somabackplane/body.dat $(WORKDIR)/windowdetect/behavioral.dat 

comp: 

$(WORKDIR)/windowdetecttest/behavioral.dat: $(WORKDIR)/touched windowdetecttest.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) windowdetecttest.vhd

sim: $(WORKDIR)/windowdetecttest/behavioral.dat 
runsim: all
	$(VHDLS) windowdetecttest


clean:
	rm -Rf work 

work/touched:
	vlib  work
	touch  work/touched
