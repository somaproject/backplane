VHDLC=vcom
VHDLS=vsim
WORKDIR=work
all: hw comp sim

$(WORKDIR)/netports/body.dat: $(WORKDIR)/touched ../../vhdl/netports.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/netports.vhd

$(WORKDIR)/networkstack/body.dat: $(WORKDIR)/touched ../../vhdl/netports.vhd ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/networkstack.vhd

$(WORKDIR)/crc_combinational/behavioral.dat: $(WORKDIR)/touched ../../vhdl/netports.vhd ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../vhdl/networkstack.vhd ../../crc/vhdl/crc_combinational.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../crc/vhdl/crc_combinational.vhd

$(WORKDIR)/crc16_combinational/behavioral.dat: $(WORKDIR)/touched ../../vhdl/netports.vhd ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../vhdl/networkstack.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../crc/vhdl/crc16_combinational.vhd

$(WORKDIR)/crcverify/behavioral.dat: $(WORKDIR)/touched ../../vhdl/netports.vhd ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../vhdl/networkstack.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../crc/vhdl/crcverify.vhd

$(WORKDIR)/inputcontrol/behavioral.dat: $(WORKDIR)/touched ../../vhdl/netports.vhd ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../vhdl/networkstack.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../crc/vhdl/crcverify.vhd ../../vhdl/inputcontrol.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/inputcontrol.vhd

$(WORKDIR)/ipchecksum/behavioral.dat: $(WORKDIR)/touched ../../vhdl/netports.vhd ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../vhdl/networkstack.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../crc/vhdl/crcverify.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/ipchecksum.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/ipchecksum.vhd

$(WORKDIR)/pingipwriter/behavioral.dat: $(WORKDIR)/touched ../../vhdl/netports.vhd ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../vhdl/networkstack.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../crc/vhdl/crcverify.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/pingipwriter.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/pingipwriter.vhd

$(WORKDIR)/pingicmpwriter/behavioral.dat: $(WORKDIR)/touched ../../vhdl/netports.vhd ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../vhdl/networkstack.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../crc/vhdl/crcverify.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingicmpwriter.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/pingicmpwriter.vhd

$(WORKDIR)/pingresponse/behavioral.dat: $(WORKDIR)/touched ../../vhdl/netports.vhd ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../vhdl/networkstack.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../crc/vhdl/crcverify.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingresponse.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/pingresponse.vhd

hw: $(WORKDIR)/netports/body.dat $(WORKDIR)/networkstack/body.dat $(WORKDIR)/crc_combinational/behavioral.dat $(WORKDIR)/crc16_combinational/behavioral.dat $(WORKDIR)/crcverify/behavioral.dat $(WORKDIR)/inputcontrol/behavioral.dat $(WORKDIR)/ipchecksum/behavioral.dat $(WORKDIR)/pingipwriter/behavioral.dat $(WORKDIR)/pingicmpwriter/behavioral.dat $(WORKDIR)/pingresponse/behavioral.dat 

comp: 

$(WORKDIR)/pingresponsetest/behavioral.dat: $(WORKDIR)/touched pingresponsetest.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) pingresponsetest.vhd

sim: $(WORKDIR)/pingresponsetest/behavioral.dat 
runsim: all
	$(VHDLS) pingresponsetest


clean:
	rm -Rf work 

work/touched:
	vlib  work
	touch  work/touched
