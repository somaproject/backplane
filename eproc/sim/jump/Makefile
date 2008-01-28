VHDLC=vcom
VHDLS=vsim
WORKDIR=work
all: hw comp sim

$(WORKDIR)/alu/behavioral.dat: $(WORKDIR)/touched ../../vhdl/alu.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/alu.vhd

$(WORKDIR)/regfile/behavioral.dat: $(WORKDIR)/touched ../../vhdl/alu.vhd ../../vhdl/alu.vhd ../../vhdl/regfile.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/regfile.vhd

$(WORKDIR)/ecore/behavioral.dat: $(WORKDIR)/touched ../../vhdl/alu.vhd ../../vhdl/alu.vhd ../../vhdl/regfile.vhd ../../vhdl/regfile.vhd ../../vhdl/ecore.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/ecore.vhd

hw: $(WORKDIR)/alu/behavioral.dat $(WORKDIR)/regfile/behavioral.dat $(WORKDIR)/ecore/behavioral.dat 

$(WORKDIR)/IRAM/behavioral.dat: $(WORKDIR)/touched ../components/iram/iram.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../components/iram/iram.vhd

$(WORKDIR)/outverify/behavioral.dat: $(WORKDIR)/touched ../components/iram/iram.vhd ../components/outverify/outverify.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../components/outverify/outverify.vhd

comp: $(WORKDIR)/IRAM/behavioral.dat $(WORKDIR)/outverify/behavioral.dat 

$(WORKDIR)/jumptest/behavioral.dat: $(WORKDIR)/touched ../components/iram/iram.vhd ../components/outverify/outverify.vhd jumptest.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) jumptest.vhd

sim: $(WORKDIR)/jumptest/behavioral.dat 
runsim: all
	$(VHDLS) jumptest


clean:
	rm -Rf work 

work/touched:
	vlib  work
	touch  work/touched
