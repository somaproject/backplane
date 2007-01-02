VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/networkstack/prim.var: ../../vhdl/networkstack.vhd
	$(VHDLC) ../../vhdl/networkstack.vhd

$(WORKDIR)/crc_combinational/_behavioral.var: ../../vhdl/networkstack.vhd ../../crc/vhdl/crc_combinational.vhd
	$(VHDLC) ../../crc/vhdl/crc_combinational.vhd

$(WORKDIR)/crc16_combinational/_behavioral.var: ../../vhdl/networkstack.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd
	$(VHDLC) ../../crc/vhdl/crc16_combinational.vhd

$(WORKDIR)/crcverify/_behavioral.var: ../../vhdl/networkstack.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd
	$(VHDLC) ../../crc/vhdl/crcverify.vhd

$(WORKDIR)/inputcontrol/_behavioral.var: ../../vhdl/networkstack.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../vhdl/inputcontrol.vhd
	$(VHDLC) ../../vhdl/inputcontrol.vhd

$(WORKDIR)/eventretxresponse/_behavioral.var: ../../vhdl/networkstack.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/eventretxresponse.vhd
	$(VHDLC) ../../vhdl/eventretxresponse.vhd

hw: $(WORKDIR)/networkstack/prim.var $(WORKDIR)/crc_combinational/_behavioral.var $(WORKDIR)/crc16_combinational/_behavioral.var $(WORKDIR)/crcverify/_behavioral.var $(WORKDIR)/inputcontrol/_behavioral.var $(WORKDIR)/eventretxresponse/_behavioral.var 

comp: 

$(WORKDIR)/eventretxresponsetest/_behavioral.var: eventretxresponsetest.vhd
	$(VHDLC) eventretxresponsetest.vhd

sim: $(WORKDIR)/eventretxresponsetest/_behavioral.var 
runsim: all
	$(VHDLS) eventretxresponsetest.vhd


clean:
	rm -Rf $(WORKDIR)$

