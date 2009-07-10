VHDLC=vcom
VHDLS=vsim
WORKDIR=work
all: hw comp sim

$(WORKDIR)/somabackplane/body.dat: $(WORKDIR)/touched ../../vhdl/somabackplane.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/somabackplane.vhd

$(WORKDIR)/datasequencer/behavioral.dat: $(WORKDIR)/touched ../../vhdl/somabackplane.vhd ../../vhdl/somabackplane.vhd ../../vhdl/core/datasequencer.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/core/datasequencer.vhd

$(WORKDIR)/datarouter/behavioral.dat: $(WORKDIR)/touched ../../vhdl/somabackplane.vhd ../../vhdl/somabackplane.vhd ../../vhdl/core/datasequencer.vhd ../../vhdl/core/datasequencer.vhd ../../vhdl/core/datarouter.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/core/datarouter.vhd

hw: $(WORKDIR)/somabackplane/body.dat $(WORKDIR)/datasequencer/behavioral.dat $(WORKDIR)/datarouter/behavioral.dat 

comp: 

$(WORKDIR)/dataroutertest/behavioral.dat: $(WORKDIR)/touched dataroutertest.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) dataroutertest.vhd

sim: $(WORKDIR)/dataroutertest/behavioral.dat 
runsim: all
	$(VHDLS) dataroutertest


clean:
	rm -Rf work 

work/touched:
	vlib  work
	touch  work/touched
