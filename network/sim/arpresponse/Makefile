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

$(WORKDIR)/arpresponse/behavioral.dat: $(WORKDIR)/touched ../../vhdl/netports.vhd ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../vhdl/networkstack.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../crc/vhdl/crcverify.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/arpresponse.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/arpresponse.vhd

hw: $(WORKDIR)/netports/body.dat $(WORKDIR)/networkstack/body.dat $(WORKDIR)/crc_combinational/behavioral.dat $(WORKDIR)/crc16_combinational/behavioral.dat $(WORKDIR)/crcverify/behavioral.dat $(WORKDIR)/inputcontrol/behavioral.dat $(WORKDIR)/arpresponse/behavioral.dat 

comp: 

$(WORKDIR)/arpresponsetest/behavioral.dat: $(WORKDIR)/touched arpresponsetest.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) arpresponsetest.vhd

sim: $(WORKDIR)/arpresponsetest/behavioral.dat 
runsim: all
	$(VHDLS) arpresponsetest


clean:
	rm -Rf work 

work/touched:
	vlib  work
	touch  work/touched
