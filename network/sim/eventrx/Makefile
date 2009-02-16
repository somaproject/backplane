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

$(WORKDIR)/crc_combinational/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/somabackplane.vhd ../../vhdl/netports.vhd ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../vhdl/networkstack.vhd ../../crc/vhdl/crc_combinational.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../crc/vhdl/crc_combinational.vhd

$(WORKDIR)/crc16_combinational/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/somabackplane.vhd ../../vhdl/netports.vhd ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../vhdl/networkstack.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../crc/vhdl/crc16_combinational.vhd

$(WORKDIR)/crcverify/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/somabackplane.vhd ../../vhdl/netports.vhd ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../vhdl/networkstack.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../crc/vhdl/crcverify.vhd

$(WORKDIR)/ipchecksum/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/somabackplane.vhd ../../vhdl/netports.vhd ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../vhdl/networkstack.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../crc/vhdl/crcverify.vhd ../../vhdl/ipchecksum.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/ipchecksum.vhd

$(WORKDIR)/udpheaderwriter/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/somabackplane.vhd ../../vhdl/netports.vhd ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../vhdl/networkstack.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../crc/vhdl/crcverify.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/udpheaderwriter.vhd

$(WORKDIR)/eventrxbusoutput/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/somabackplane.vhd ../../vhdl/netports.vhd ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../vhdl/networkstack.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../crc/vhdl/crcverify.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/eventrxbusoutput.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/eventrxbusoutput.vhd

$(WORKDIR)/eventrxresponsewr/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/somabackplane.vhd ../../vhdl/netports.vhd ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../vhdl/networkstack.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../crc/vhdl/crcverify.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/eventrxbusoutput.vhd ../../vhdl/eventrxbusoutput.vhd ../../vhdl/eventrxresponsewr.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/eventrxresponsewr.vhd

$(WORKDIR)/eventrx/behavioral.dat: $(WORKDIR)/touched ../../../vhdl/somabackplane.vhd ../../vhdl/netports.vhd ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../vhdl/networkstack.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../crc/vhdl/crcverify.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/eventrxbusoutput.vhd ../../vhdl/eventrxbusoutput.vhd ../../vhdl/eventrxresponsewr.vhd ../../vhdl/eventrxresponsewr.vhd ../../vhdl/eventrx.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/eventrx.vhd

hw: soma/somabackplane/body.dat $(WORKDIR)/netports/body.dat $(WORKDIR)/networkstack/body.dat $(WORKDIR)/crc_combinational/behavioral.dat $(WORKDIR)/crc16_combinational/behavioral.dat $(WORKDIR)/crcverify/behavioral.dat $(WORKDIR)/ipchecksum/behavioral.dat $(WORKDIR)/udpheaderwriter/behavioral.dat $(WORKDIR)/eventrxbusoutput/behavioral.dat $(WORKDIR)/eventrxresponsewr/behavioral.dat $(WORKDIR)/eventrx/behavioral.dat 

$(WORKDIR)/inputcontrol/behavioral.dat: $(WORKDIR)/touched ../../vhdl/inputcontrol.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/inputcontrol.vhd

$(WORKDIR)/eventrxverify/behavioral.dat: $(WORKDIR)/touched ../../vhdl/inputcontrol.vhd ../components/eventrxverify/eventrxverify.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../components/eventrxverify/eventrxverify.vhd

comp: $(WORKDIR)/inputcontrol/behavioral.dat $(WORKDIR)/eventrxverify/behavioral.dat 

$(WORKDIR)/eventrxtest/behavioral.dat: $(WORKDIR)/touched ../../vhdl/inputcontrol.vhd ../components/eventrxverify/eventrxverify.vhd eventrxtest.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) eventrxtest.vhd

sim: $(WORKDIR)/eventrxtest/behavioral.dat 
runsim: all
	$(VHDLS) eventrxtest


clean:
	rm -Rf soma work 

soma/touched:
	vlib  soma
	touch  soma/touched
work/touched:
	vlib  work
	touch  work/touched
