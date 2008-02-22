VHDLC=vcom
VHDLS=vsim
WORKDIR=work
all: hw comp sim

soma/somabackplane/body.dat: soma/touched ../../../vhdl/somabackplane.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../../vhdl/somabackplane.vhd

$(WORKDIR)/netports/body.dat: $(WORKDIR)/touched ../../../vhdl/somabackplane.vhd ../../vhdl/netports.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/netports.vhd

$(WORKDIR)/networkstack/body.dat: $(WORKDIR)/touched ../../../vhdl/somabackplane.vhd ../../vhdl/netports.vhd ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/networkstack.vhd

$(WORKDIR)/eventbodywriter/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/somabackplane.vhd ../../vhdl/netports.vhd ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../vhdl/networkstack.vhd ../../vhdl/eventbodywriter.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/eventbodywriter.vhd

$(WORKDIR)/ipchecksum/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/somabackplane.vhd ../../vhdl/netports.vhd ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../vhdl/networkstack.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/ipchecksum.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/ipchecksum.vhd

$(WORKDIR)/udpheaderwriter/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/somabackplane.vhd ../../vhdl/netports.vhd ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../vhdl/networkstack.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/udpheaderwriter.vhd

$(WORKDIR)/eventtxpktfifo/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/somabackplane.vhd ../../vhdl/netports.vhd ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../vhdl/networkstack.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/eventtxpkfifo.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/eventtxpkfifo.vhd

$(WORKDIR)/bitcnt/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/somabackplane.vhd ../../vhdl/netports.vhd ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../vhdl/networkstack.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/eventtxpkfifo.vhd ../../vhdl/eventtxpkfifo.vhd ../../vhdl/bitcnt.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/bitcnt.vhd

$(WORKDIR)/eventtx/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/somabackplane.vhd ../../vhdl/netports.vhd ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../vhdl/networkstack.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/eventtxpkfifo.vhd ../../vhdl/eventtxpkfifo.vhd ../../vhdl/bitcnt.vhd ../../vhdl/bitcnt.vhd ../../vhdl/eventtx.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/eventtx.vhd

hw: soma/somabackplane/body.dat $(WORKDIR)/netports/body.dat $(WORKDIR)/networkstack/body.dat $(WORKDIR)/eventbodywriter/behavioral.dat $(WORKDIR)/ipchecksum/behavioral.dat $(WORKDIR)/udpheaderwriter/behavioral.dat $(WORKDIR)/eventtxpktfifo/behavioral.dat $(WORKDIR)/bitcnt/behavioral.dat $(WORKDIR)/eventtx/behavioral.dat 

comp: 

$(WORKDIR)/eventtxtest/behavioral.dat: $(WORKDIR)/touched eventtxtest.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) eventtxtest.vhd

sim: $(WORKDIR)/eventtxtest/behavioral.dat 
runsim: all
	$(VHDLS) eventtxtest


clean:
	rm -Rf soma work 

soma/touched:
	vlib  soma
	touch  soma/touched
work/touched:
	vlib  work
	touch  work/touched
