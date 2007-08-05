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

$(WORKDIR)/dataretxresponse/_behavioral.var: ../../vhdl/networkstack.vhd ../../vhdl/netports.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/dataretxresponse.vhd
	$(VHDLC) -vital2000 ../../vhdl/dataretxresponse.vhd

hw: $(WORKDIR)/networkstack/prim.var $(WORKDIR)/netports/prim.var $(WORKDIR)/crc_combinational/_behavioral.var $(WORKDIR)/crc16_combinational/_behavioral.var $(WORKDIR)/crcverify/_behavioral.var $(WORKDIR)/inputcontrol/_behavioral.var $(WORKDIR)/dataretxresponse/_behavioral.var 

comp: 

$(WORKDIR)/dataretxresponsetest/_behavioral.var: dataretxresponsetest.vhd
	$(VHDLC) -vital2000 dataretxresponsetest.vhd

sim: $(WORKDIR)/dataretxresponsetest/_behavioral.var 
runsim: all
	$(VHDLS) dataretxresponsetest.vhd


clean:
	rm -Rf *.sym

