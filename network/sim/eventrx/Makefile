VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/networkstack/prim.var: ../../vhdl/networkstack.vhd
	$(VHDLC) -vital2000 ../../vhdl/networkstack.vhd

$(WORKDIR)/netports/prim.var: ../../vhdl/networkstack.vhd ../../vhdl/netports.vhd
	$(VHDLC) -vital2000 ../../vhdl/netports.vhd

$(WORKDIR)/somabackplane/prim.var: ../../vhdl/networkstack.vhd ../../vhdl/netports.vhd ../../../vhdl/somabackplane.vhd
	$(VHDLC) -vital2000 ../../../vhdl/somabackplane.vhd

$(WORKDIR)/crc_combinational/_behavioral.var: ../../vhdl/networkstack.vhd ../../vhdl/netports.vhd ../../../vhdl/somabackplane.vhd ../../crc/vhdl/crc_combinational.vhd
	$(VHDLC) -vital2000 ../../crc/vhdl/crc_combinational.vhd

$(WORKDIR)/crc16_combinational/_behavioral.var: ../../vhdl/networkstack.vhd ../../vhdl/netports.vhd ../../../vhdl/somabackplane.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd
	$(VHDLC) -vital2000 ../../crc/vhdl/crc16_combinational.vhd

$(WORKDIR)/crcverify/_behavioral.var: ../../vhdl/networkstack.vhd ../../vhdl/netports.vhd ../../../vhdl/somabackplane.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd
	$(VHDLC) -vital2000 ../../crc/vhdl/crcverify.vhd

$(WORKDIR)/ipchecksum/_behavioral.var: ../../vhdl/networkstack.vhd ../../vhdl/netports.vhd ../../../vhdl/somabackplane.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../vhdl/ipchecksum.vhd
	$(VHDLC) -vital2000 ../../vhdl/ipchecksum.vhd

$(WORKDIR)/udpheaderwriter/_behavioral.var: ../../vhdl/networkstack.vhd ../../vhdl/netports.vhd ../../../vhdl/somabackplane.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd
	$(VHDLC) -vital2000 ../../vhdl/udpheaderwriter.vhd

$(WORKDIR)/eventrxbusoutput/_behavioral.var: ../../vhdl/networkstack.vhd ../../vhdl/netports.vhd ../../../vhdl/somabackplane.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/eventrxbusoutput.vhd
	$(VHDLC) -vital2000 ../../vhdl/eventrxbusoutput.vhd

$(WORKDIR)/eventrxresponsewr/_behavioral.var: ../../vhdl/networkstack.vhd ../../vhdl/netports.vhd ../../../vhdl/somabackplane.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/eventrxbusoutput.vhd ../../vhdl/eventrxresponsewr.vhd
	$(VHDLC) -vital2000 ../../vhdl/eventrxresponsewr.vhd

$(WORKDIR)/eventrx/_behavioral.var: ../../vhdl/networkstack.vhd ../../vhdl/netports.vhd ../../../vhdl/somabackplane.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/eventrxbusoutput.vhd ../../vhdl/eventrxresponsewr.vhd ../../vhdl/eventrx.vhd
	$(VHDLC) -vital2000 ../../vhdl/eventrx.vhd

hw: $(WORKDIR)/networkstack/prim.var $(WORKDIR)/netports/prim.var $(WORKDIR)/somabackplane/prim.var $(WORKDIR)/crc_combinational/_behavioral.var $(WORKDIR)/crc16_combinational/_behavioral.var $(WORKDIR)/crcverify/_behavioral.var $(WORKDIR)/ipchecksum/_behavioral.var $(WORKDIR)/udpheaderwriter/_behavioral.var $(WORKDIR)/eventrxbusoutput/_behavioral.var $(WORKDIR)/eventrxresponsewr/_behavioral.var $(WORKDIR)/eventrx/_behavioral.var 

$(WORKDIR)/inputcontrol/_behavioral.var: ../../vhdl/inputcontrol.vhd
	$(VHDLC) -vital2000 ../../vhdl/inputcontrol.vhd

$(WORKDIR)/eventrxverify/_behavioral.var: ../../vhdl/inputcontrol.vhd ../components/eventrxverify/eventrxverify.vhd
	$(VHDLC) -vital2000 ../components/eventrxverify/eventrxverify.vhd

comp: $(WORKDIR)/inputcontrol/_behavioral.var $(WORKDIR)/eventrxverify/_behavioral.var 

$(WORKDIR)/eventrxtest/_behavioral.var: ../../vhdl/inputcontrol.vhd ../components/eventrxverify/eventrxverify.vhd eventrxtest.vhd
	$(VHDLC) -vital2000 eventrxtest.vhd

sim: $(WORKDIR)/eventrxtest/_behavioral.var 
runsim: all
	$(VHDLS) eventrxtest


clean:
	rm -Rf *.sym

