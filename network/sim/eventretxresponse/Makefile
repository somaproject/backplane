VHDLC=vcom
VHDLS=vsim
WORKDIR=work
all: hw comp sim

$(WORKDIR)/networkstack/body.dat: $(WORKDIR)/touched ../../vhdl/networkstack.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/networkstack.vhd

$(WORKDIR)/netports/body.dat: $(WORKDIR)/touched ../../vhdl/networkstack.vhd ../../vhdl/networkstack.vhd ../../vhdl/netports.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/netports.vhd

$(WORKDIR)/crc_combinational/behavioral.dat: $(WORKDIR)/touched ../../vhdl/networkstack.vhd ../../vhdl/networkstack.vhd ../../vhdl/netports.vhd ../../vhdl/netports.vhd ../../crc/vhdl/crc_combinational.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../crc/vhdl/crc_combinational.vhd

$(WORKDIR)/crc16_combinational/behavioral.dat: $(WORKDIR)/touched ../../vhdl/networkstack.vhd ../../vhdl/networkstack.vhd ../../vhdl/netports.vhd ../../vhdl/netports.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../crc/vhdl/crc16_combinational.vhd

$(WORKDIR)/crcverify/behavioral.dat: $(WORKDIR)/touched ../../vhdl/networkstack.vhd ../../vhdl/networkstack.vhd ../../vhdl/netports.vhd ../../vhdl/netports.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../crc/vhdl/crcverify.vhd

$(WORKDIR)/inputcontrol/behavioral.dat: $(WORKDIR)/touched ../../vhdl/networkstack.vhd ../../vhdl/networkstack.vhd ../../vhdl/netports.vhd ../../vhdl/netports.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../crc/vhdl/crcverify.vhd ../../vhdl/inputcontrol.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/inputcontrol.vhd

$(WORKDIR)/eventretxresponse/behavioral.dat: $(WORKDIR)/touched ../../vhdl/networkstack.vhd ../../vhdl/networkstack.vhd ../../vhdl/netports.vhd ../../vhdl/netports.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../crc/vhdl/crcverify.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/eventretxresponse.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/eventretxresponse.vhd

hw: $(WORKDIR)/networkstack/body.dat $(WORKDIR)/netports/body.dat $(WORKDIR)/crc_combinational/behavioral.dat $(WORKDIR)/crc16_combinational/behavioral.dat $(WORKDIR)/crcverify/behavioral.dat $(WORKDIR)/inputcontrol/behavioral.dat $(WORKDIR)/eventretxresponse/behavioral.dat 

comp: 

$(WORKDIR)/eventretxresponsetest/behavioral.dat: $(WORKDIR)/touched eventretxresponsetest.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) eventretxresponsetest.vhd

sim: $(WORKDIR)/eventretxresponsetest/behavioral.dat 
runsim: all
	$(VHDLS) eventretxresponsetest.vhd


clean:
	rm -Rf work 

work/touched:
	vlib  work
	touch  work/touched
