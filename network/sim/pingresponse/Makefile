VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/netports/prim.var: ../../vhdl/netports.vhd
	$(VHDLC) -vital2000 ../../vhdl/netports.vhd

$(WORKDIR)/networkstack/prim.var: ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd
	$(VHDLC) -vital2000 ../../vhdl/networkstack.vhd

$(WORKDIR)/crc_combinational/_behavioral.var: ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../crc/vhdl/crc_combinational.vhd
	$(VHDLC) -vital2000 ../../crc/vhdl/crc_combinational.vhd

$(WORKDIR)/crc16_combinational/_behavioral.var: ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd
	$(VHDLC) -vital2000 ../../crc/vhdl/crc16_combinational.vhd

$(WORKDIR)/crcverify/_behavioral.var: ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd
	$(VHDLC) -vital2000 ../../crc/vhdl/crcverify.vhd

$(WORKDIR)/inputcontrol/_behavioral.var: ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../vhdl/inputcontrol.vhd
	$(VHDLC) -vital2000 ../../vhdl/inputcontrol.vhd

$(WORKDIR)/ipchecksum/_behavioral.var: ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/ipchecksum.vhd
	$(VHDLC) -vital2000 ../../vhdl/ipchecksum.vhd

$(WORKDIR)/pingipwriter/_behavioral.var: ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/pingipwriter.vhd
	$(VHDLC) -vital2000 ../../vhdl/pingipwriter.vhd

$(WORKDIR)/pingicmpwriter/_behavioral.var: ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingicmpwriter.vhd
	$(VHDLC) -vital2000 ../../vhdl/pingicmpwriter.vhd

$(WORKDIR)/pingresponse/_behavioral.var: ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingresponse.vhd
	$(VHDLC) -vital2000 ../../vhdl/pingresponse.vhd

hw: $(WORKDIR)/netports/prim.var $(WORKDIR)/networkstack/prim.var $(WORKDIR)/crc_combinational/_behavioral.var $(WORKDIR)/crc16_combinational/_behavioral.var $(WORKDIR)/crcverify/_behavioral.var $(WORKDIR)/inputcontrol/_behavioral.var $(WORKDIR)/ipchecksum/_behavioral.var $(WORKDIR)/pingipwriter/_behavioral.var $(WORKDIR)/pingicmpwriter/_behavioral.var $(WORKDIR)/pingresponse/_behavioral.var 

comp: 

$(WORKDIR)/pingresponsetest/_behavioral.var: pingresponsetest.vhd
	$(VHDLC) -vital2000 pingresponsetest.vhd

sim: $(WORKDIR)/pingresponsetest/_behavioral.var 
runsim: all
	$(VHDLS) pingresponsetest.vhd


clean:
	rm -Rf *.sym

