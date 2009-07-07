VHDLC=vcom
VHDLS=vsim
WORKDIR=work
all: hw comp sim

soma/somabackplane/body.dat: soma/touched ../../../vhdl/somabackplane.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../../vhdl/somabackplane.vhd

$(WORKDIR)/networkstack/body.dat: $(WORKDIR)/touched ../../../vhdl/somabackplane.vhd ../../vhdl/networkstack.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/networkstack.vhd

$(WORKDIR)/dataacquire/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/somabackplane.vhd ../../vhdl/networkstack.vhd ../../vhdl/networkstack.vhd ../../vhdl/dataacquire.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/dataacquire.vhd

$(WORKDIR)/ipchecksum/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/somabackplane.vhd ../../vhdl/networkstack.vhd ../../vhdl/networkstack.vhd ../../vhdl/dataacquire.vhd ../../vhdl/dataacquire.vhd ../../vhdl/ipchecksum.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/ipchecksum.vhd

$(WORKDIR)/udpheaderwriter/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/somabackplane.vhd ../../vhdl/networkstack.vhd ../../vhdl/networkstack.vhd ../../vhdl/dataacquire.vhd ../../vhdl/dataacquire.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/udpheaderwriter.vhd

$(WORKDIR)/datapacketgen/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/somabackplane.vhd ../../vhdl/networkstack.vhd ../../vhdl/networkstack.vhd ../../vhdl/dataacquire.vhd ../../vhdl/dataacquire.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/datapacketgen.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/datapacketgen.vhd

hw: soma/somabackplane/body.dat $(WORKDIR)/networkstack/body.dat $(WORKDIR)/dataacquire/behavioral.dat $(WORKDIR)/ipchecksum/behavioral.dat $(WORKDIR)/udpheaderwriter/behavioral.dat $(WORKDIR)/datapacketgen/behavioral.dat 

comp: 

$(WORKDIR)/datapacketgentest/behavioral.dat: $(WORKDIR)/touched datapacketgenoverwritetest.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) datapacketgenoverwritetest.vhd

sim: $(WORKDIR)/datapacketgentest/behavioral.dat 
runsim: all
	$(VHDLS) datapacketgenoverwritetest


clean:
	rm -Rf soma work 

soma/touched:
	vlib  soma
	touch  soma/touched
work/touched:
	vlib  work
	touch  work/touched
