VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/networkstack/prim.var: ../../vhdl/networkstack.vhd
	$(VHDLC) -vital2000 ../../vhdl/networkstack.vhd

$(WORKDIR)/netports/prim.var: ../../vhdl/networkstack.vhd ../../vhdl/netports.vhd
	$(VHDLC) -vital2000 ../../vhdl/netports.vhd

$(WORKDIR)/crc_combinational/_behavioral.var: ../../vhdl/networkstack.vhd ../../vhdl/netports.vhd ../../crc/vhdl/crc_combinational.vhd
	$(VHDLC) -vital2000 ../../crc/vhdl/crc_combinational.vhd

$(WORKDIR)/crc16_combinational/_behavioral.var: ../../vhdl/networkstack.vhd ../../vhdl/netports.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd
	$(VHDLC) -vital2000 ../../crc/vhdl/crc16_combinational.vhd

$(WORKDIR)/crcverify/_behavioral.var: ../../vhdl/networkstack.vhd ../../vhdl/netports.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd
	$(VHDLC) -vital2000 ../../crc/vhdl/crcverify.vhd

$(WORKDIR)/inputcontrol/_behavioral.var: ../../vhdl/networkstack.vhd ../../vhdl/netports.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../vhdl/inputcontrol.vhd
	$(VHDLC) -vital2000 ../../vhdl/inputcontrol.vhd

$(WORKDIR)/eventretxresponse/_behavioral.var: ../../vhdl/networkstack.vhd ../../vhdl/netports.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/eventretxresponse.vhd
	$(VHDLC) -vital2000 ../../vhdl/eventretxresponse.vhd

hw: $(WORKDIR)/networkstack/prim.var $(WORKDIR)/netports/prim.var $(WORKDIR)/crc_combinational/_behavioral.var $(WORKDIR)/crc16_combinational/_behavioral.var $(WORKDIR)/crcverify/_behavioral.var $(WORKDIR)/inputcontrol/_behavioral.var $(WORKDIR)/eventretxresponse/_behavioral.var 

comp: 

$(WORKDIR)/eventretxresponsetest/_behavioral.var: eventretxresponsetest.vhd
	$(VHDLC) -vital2000 eventretxresponsetest.vhd

sim: $(WORKDIR)/eventretxresponsetest/_behavioral.var 
runsim: all
	$(VHDLS) eventretxresponsetest.vhd


clean:
	rm -Rf *.sym

