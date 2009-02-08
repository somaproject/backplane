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

$(WORKDIR)/dataacquire/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/somabackplane.vhd ../../vhdl/netports.vhd ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../vhdl/networkstack.vhd ../../vhdl/dataacquire.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/dataacquire.vhd

$(WORKDIR)/bigmem/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/somabackplane.vhd ../../vhdl/netports.vhd ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../vhdl/networkstack.vhd ../../vhdl/dataacquire.vhd ../../vhdl/dataacquire.vhd ../../vhdl/bigmem.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/bigmem.vhd

$(WORKDIR)/dataretxbuf/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/somabackplane.vhd ../../vhdl/netports.vhd ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../vhdl/networkstack.vhd ../../vhdl/dataacquire.vhd ../../vhdl/dataacquire.vhd ../../vhdl/bigmem.vhd ../../vhdl/bigmem.vhd ../../vhdl/dataretxbuf.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/dataretxbuf.vhd

$(WORKDIR)/datafifo/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/somabackplane.vhd ../../vhdl/netports.vhd ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../vhdl/networkstack.vhd ../../vhdl/dataacquire.vhd ../../vhdl/dataacquire.vhd ../../vhdl/bigmem.vhd ../../vhdl/bigmem.vhd ../../vhdl/dataretxbuf.vhd ../../vhdl/dataretxbuf.vhd ../../vhdl/datafifo.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/datafifo.vhd

$(WORKDIR)/ipchecksum/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/somabackplane.vhd ../../vhdl/netports.vhd ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../vhdl/networkstack.vhd ../../vhdl/dataacquire.vhd ../../vhdl/dataacquire.vhd ../../vhdl/bigmem.vhd ../../vhdl/bigmem.vhd ../../vhdl/dataretxbuf.vhd ../../vhdl/dataretxbuf.vhd ../../vhdl/datafifo.vhd ../../vhdl/datafifo.vhd ../../vhdl/ipchecksum.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/ipchecksum.vhd

$(WORKDIR)/udpheaderwriter/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/somabackplane.vhd ../../vhdl/netports.vhd ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../vhdl/networkstack.vhd ../../vhdl/dataacquire.vhd ../../vhdl/dataacquire.vhd ../../vhdl/bigmem.vhd ../../vhdl/bigmem.vhd ../../vhdl/dataretxbuf.vhd ../../vhdl/dataretxbuf.vhd ../../vhdl/datafifo.vhd ../../vhdl/datafifo.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/udpheaderwriter.vhd

$(WORKDIR)/datapacketgen/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/somabackplane.vhd ../../vhdl/netports.vhd ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../vhdl/networkstack.vhd ../../vhdl/dataacquire.vhd ../../vhdl/dataacquire.vhd ../../vhdl/bigmem.vhd ../../vhdl/bigmem.vhd ../../vhdl/dataretxbuf.vhd ../../vhdl/dataretxbuf.vhd ../../vhdl/datafifo.vhd ../../vhdl/datafifo.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/datapacketgen.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/datapacketgen.vhd

$(WORKDIR)/data/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/somabackplane.vhd ../../vhdl/netports.vhd ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../vhdl/networkstack.vhd ../../vhdl/dataacquire.vhd ../../vhdl/dataacquire.vhd ../../vhdl/bigmem.vhd ../../vhdl/bigmem.vhd ../../vhdl/dataretxbuf.vhd ../../vhdl/dataretxbuf.vhd ../../vhdl/datafifo.vhd ../../vhdl/datafifo.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/datapacketgen.vhd ../../vhdl/datapacketgen.vhd ../../vhdl/data.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/data.vhd

hw: soma/somabackplane/body.dat $(WORKDIR)/netports/body.dat $(WORKDIR)/networkstack/body.dat $(WORKDIR)/dataacquire/behavioral.dat $(WORKDIR)/bigmem/behavioral.dat $(WORKDIR)/dataretxbuf/behavioral.dat $(WORKDIR)/datafifo/behavioral.dat $(WORKDIR)/ipchecksum/behavioral.dat $(WORKDIR)/udpheaderwriter/behavioral.dat $(WORKDIR)/datapacketgen/behavioral.dat $(WORKDIR)/data/behavioral.dat 

comp: 

$(WORKDIR)/datatest/behavioral.dat: $(WORKDIR)/touched datatest.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) datatest.vhd

sim: $(WORKDIR)/datatest/behavioral.dat 
runsim: all
	$(VHDLS) datatest


clean:
	rm -Rf soma work 

soma/touched:
	vlib  soma
	touch  soma/touched
work/touched:
	vlib  work
	touch  work/touched
