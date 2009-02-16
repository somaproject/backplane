VHDLC=vcom
VHDLS=vsim
WORKDIR=work
all: hw comp sim

$(WORKDIR)/netports/body.dat: $(WORKDIR)/touched ../../vhdl/netports.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/netports.vhd

$(WORKDIR)/crc_combinational/behavioral.dat: $(WORKDIR)/touched ../../vhdl/netports.vhd ../../vhdl/netports.vhd ../../crc/vhdl/crc_combinational.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../crc/vhdl/crc_combinational.vhd

$(WORKDIR)/crc16_combinational/behavioral.dat: $(WORKDIR)/touched ../../vhdl/netports.vhd ../../vhdl/netports.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../crc/vhdl/crc16_combinational.vhd

$(WORKDIR)/crcverify/behavioral.dat: $(WORKDIR)/touched ../../vhdl/netports.vhd ../../vhdl/netports.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../crc/vhdl/crcverify.vhd

$(WORKDIR)/networkstack/body.dat: $(WORKDIR)/touched ../../vhdl/netports.vhd ../../vhdl/netports.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../crc/vhdl/crcverify.vhd ../../vhdl/networkstack.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/networkstack.vhd

$(WORKDIR)/inputcontrol/behavioral.dat: $(WORKDIR)/touched ../../vhdl/netports.vhd ../../vhdl/netports.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../crc/vhdl/crcverify.vhd ../../vhdl/networkstack.vhd ../../vhdl/networkstack.vhd ../../vhdl/inputcontrol.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/inputcontrol.vhd

hw: $(WORKDIR)/netports/body.dat $(WORKDIR)/crc_combinational/behavioral.dat $(WORKDIR)/crc16_combinational/behavioral.dat $(WORKDIR)/crcverify/behavioral.dat $(WORKDIR)/networkstack/body.dat $(WORKDIR)/inputcontrol/behavioral.dat 

comp: 

$(WORKDIR)/inputcontroltest/behavioral.dat: $(WORKDIR)/touched inputcontroltest.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) inputcontroltest.vhd

sim: $(WORKDIR)/inputcontroltest/behavioral.dat 
runsim: all
	$(VHDLS) inputcontroltest


clean:
	rm -Rf work 

work/touched:
	vlib  work
	touch  work/touched
