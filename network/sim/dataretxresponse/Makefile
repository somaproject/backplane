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

$(WORKDIR)/dataretxresponse/behavioral.dat: $(WORKDIR)/touched ../../vhdl/networkstack.vhd ../../vhdl/networkstack.vhd ../../vhdl/netports.vhd ../../vhdl/netports.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../crc/vhdl/crcverify.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/dataretxresponse.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/dataretxresponse.vhd

hw: $(WORKDIR)/networkstack/body.dat $(WORKDIR)/netports/body.dat $(WORKDIR)/crc_combinational/behavioral.dat $(WORKDIR)/crc16_combinational/behavioral.dat $(WORKDIR)/crcverify/behavioral.dat $(WORKDIR)/inputcontrol/behavioral.dat $(WORKDIR)/dataretxresponse/behavioral.dat 

comp: 

$(WORKDIR)/dataretxresponsetest/behavioral.dat: $(WORKDIR)/touched dataretxresponsetest.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) dataretxresponsetest.vhd

sim: $(WORKDIR)/dataretxresponsetest/behavioral.dat 
runsim: all
	$(VHDLS) dataretxresponsetest.vhd


clean:
	rm -Rf work 

work/touched:
	vlib  work
	touch  work/touched
