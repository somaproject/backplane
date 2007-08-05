VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/netports/prim.var: ../../vhdl/netports.vhd
	$(VHDLC) -vital2000 ../../vhdl/netports.vhd

$(WORKDIR)/crc_combinational/_behavioral.var: ../../vhdl/netports.vhd ../../crc/vhdl/crc_combinational.vhd
	$(VHDLC) -vital2000 ../../crc/vhdl/crc_combinational.vhd

$(WORKDIR)/crc16_combinational/_behavioral.var: ../../vhdl/netports.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd
	$(VHDLC) -vital2000 ../../crc/vhdl/crc16_combinational.vhd

$(WORKDIR)/crcverify/_behavioral.var: ../../vhdl/netports.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd
	$(VHDLC) -vital2000 ../../crc/vhdl/crcverify.vhd

$(WORKDIR)/networkstack/prim.var: ../../vhdl/netports.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../vhdl/networkstack.vhd
	$(VHDLC) -vital2000 ../../vhdl/networkstack.vhd

$(WORKDIR)/inputcontrol/_behavioral.var: ../../vhdl/netports.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../vhdl/networkstack.vhd ../../vhdl/inputcontrol.vhd
	$(VHDLC) -vital2000 ../../vhdl/inputcontrol.vhd

hw: $(WORKDIR)/netports/prim.var $(WORKDIR)/crc_combinational/_behavioral.var $(WORKDIR)/crc16_combinational/_behavioral.var $(WORKDIR)/crcverify/_behavioral.var $(WORKDIR)/networkstack/prim.var $(WORKDIR)/inputcontrol/_behavioral.var 

comp: 

$(WORKDIR)/inputcontroltest/_behavioral.var: inputcontroltest.vhd
	$(VHDLC) -vital2000 inputcontroltest.vhd

sim: $(WORKDIR)/inputcontroltest/_behavioral.var 
runsim: all
	$(VHDLS) inputcontroltest


clean:
	rm -Rf *.sym

