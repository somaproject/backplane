VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/dqalign/_behavioral.var: ../../../memory/vhdl/dqalign.vhd
	$(VHDLC) -vital2000 ../../../memory/vhdl/dqalign.vhd

$(WORKDIR)/bootddr2/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd
	$(VHDLC) -vital2000 ../../../memory/vhdl/bootddr2.vhd

$(WORKDIR)/readddr2/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd
	$(VHDLC) -vital2000 ../../../memory/vhdl/readddr2.vhd

$(WORKDIR)/refreshddr2/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd
	$(VHDLC) -vital2000 ../../../memory/vhdl/refreshddr2.vhd

$(WORKDIR)/writeddr2/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd
	$(VHDLC) -vital2000 ../../../memory/vhdl/writeddr2.vhd

$(WORKDIR)/memcontmux/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd
	$(VHDLC) -vital2000 ../../../memory/vhdl/memcontmux.vhd

$(WORKDIR)/memddr2/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd
	$(VHDLC) -vital2000 ../../../memory/vhdl/memddr2.vhd

$(WORKDIR)/networkstack/prim.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd
	$(VHDLC) -vital2000 ../../vhdl/networkstack.vhd

$(WORKDIR)/somabackplane/prim.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd
	$(VHDLC) -vital2000 ../../../vhdl/somabackplane.vhd

$(WORKDIR)/ipchecksum/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd
	$(VHDLC) -vital2000 ../../vhdl/ipchecksum.vhd

$(WORKDIR)/bigmem/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd
	$(VHDLC) -vital2000 ../../vhdl/bigmem.vhd

$(WORKDIR)/udpheaderwriter/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd
	$(VHDLC) -vital2000 ../../vhdl/udpheaderwriter.vhd

$(WORKDIR)/arpresponse/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd
	$(VHDLC) -vital2000 ../../vhdl/arpresponse.vhd

$(WORKDIR)/eventbodywriter/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd
	$(VHDLC) -vital2000 ../../vhdl/eventbodywriter.vhd

$(WORKDIR)/eventtx/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd
	$(VHDLC) -vital2000 ../../vhdl/eventtx.vhd

$(WORKDIR)/inputcontrol/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd
	$(VHDLC) -vital2000 ../../vhdl/inputcontrol.vhd

$(WORKDIR)/pingicmpwriter/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd
	$(VHDLC) -vital2000 ../../vhdl/pingicmpwriter.vhd

$(WORKDIR)/pingipwriter/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingipwriter.vhd
	$(VHDLC) -vital2000 ../../vhdl/pingipwriter.vhd

$(WORKDIR)/pingresponse/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingresponse.vhd
	$(VHDLC) -vital2000 ../../vhdl/pingresponse.vhd

$(WORKDIR)/txmux/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingresponse.vhd ../../vhdl/txmux.vhd
	$(VHDLC) -vital2000 ../../vhdl/txmux.vhd

$(WORKDIR)/crc_combinational/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingresponse.vhd ../../vhdl/txmux.vhd ../../crc/vhdl/crc_combinational.vhd
	$(VHDLC) -vital2000 ../../crc/vhdl/crc_combinational.vhd

$(WORKDIR)/crc16_combinational/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingresponse.vhd ../../vhdl/txmux.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd
	$(VHDLC) -vital2000 ../../crc/vhdl/crc16_combinational.vhd

$(WORKDIR)/crcverify/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingresponse.vhd ../../vhdl/txmux.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd
	$(VHDLC) -vital2000 ../../crc/vhdl/crcverify.vhd

$(WORKDIR)/crcappend/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingresponse.vhd ../../vhdl/txmux.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../crc/vhdl/crcappend.vhd
	$(VHDLC) -vital2000 ../../crc/vhdl/crcappend.vhd

$(WORKDIR)/dataretxresponse/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingresponse.vhd ../../vhdl/txmux.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../crc/vhdl/crcappend.vhd ../../vhdl/dataretxresponse.vhd
	$(VHDLC) -vital2000 ../../vhdl/dataretxresponse.vhd

$(WORKDIR)/eventrxbusoutput/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingresponse.vhd ../../vhdl/txmux.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../crc/vhdl/crcappend.vhd ../../vhdl/dataretxresponse.vhd ../../vhdl/eventrxbusoutput.vhd
	$(VHDLC) -vital2000 ../../vhdl/eventrxbusoutput.vhd

$(WORKDIR)/eventrxresponsewr/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingresponse.vhd ../../vhdl/txmux.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../crc/vhdl/crcappend.vhd ../../vhdl/dataretxresponse.vhd ../../vhdl/eventrxbusoutput.vhd ../../vhdl/eventrxresponsewr.vhd
	$(VHDLC) -vital2000 ../../vhdl/eventrxresponsewr.vhd

$(WORKDIR)/eventrx/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingresponse.vhd ../../vhdl/txmux.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../crc/vhdl/crcappend.vhd ../../vhdl/dataretxresponse.vhd ../../vhdl/eventrxbusoutput.vhd ../../vhdl/eventrxresponsewr.vhd ../../vhdl/eventrx.vhd
	$(VHDLC) -vital2000 ../../vhdl/eventrx.vhd

$(WORKDIR)/datamempktretx/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingresponse.vhd ../../vhdl/txmux.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../crc/vhdl/crcappend.vhd ../../vhdl/dataretxresponse.vhd ../../vhdl/eventrxbusoutput.vhd ../../vhdl/eventrxresponsewr.vhd ../../vhdl/eventrx.vhd ../../vhdl/datamempktretx.vhd
	$(VHDLC) -vital2000 ../../vhdl/datamempktretx.vhd

$(WORKDIR)/datamempkttx/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingresponse.vhd ../../vhdl/txmux.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../crc/vhdl/crcappend.vhd ../../vhdl/dataretxresponse.vhd ../../vhdl/eventrxbusoutput.vhd ../../vhdl/eventrxresponsewr.vhd ../../vhdl/eventrx.vhd ../../vhdl/datamempktretx.vhd ../../vhdl/datamempkttx.vhd
	$(VHDLC) -vital2000 ../../vhdl/datamempkttx.vhd

$(WORKDIR)/datamempktinput/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingresponse.vhd ../../vhdl/txmux.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../crc/vhdl/crcappend.vhd ../../vhdl/dataretxresponse.vhd ../../vhdl/eventrxbusoutput.vhd ../../vhdl/eventrxresponsewr.vhd ../../vhdl/eventrx.vhd ../../vhdl/datamempktretx.vhd ../../vhdl/datamempkttx.vhd ../../vhdl/datamempktinput.vhd
	$(VHDLC) -vital2000 ../../vhdl/datamempktinput.vhd

$(WORKDIR)/datapacketgen/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingresponse.vhd ../../vhdl/txmux.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../crc/vhdl/crcappend.vhd ../../vhdl/dataretxresponse.vhd ../../vhdl/eventrxbusoutput.vhd ../../vhdl/eventrxresponsewr.vhd ../../vhdl/eventrx.vhd ../../vhdl/datamempktretx.vhd ../../vhdl/datamempkttx.vhd ../../vhdl/datamempktinput.vhd ../../vhdl/datapacketgen.vhd
	$(VHDLC) -vital2000 ../../vhdl/datapacketgen.vhd

$(WORKDIR)/datamemarbit/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingresponse.vhd ../../vhdl/txmux.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../crc/vhdl/crcappend.vhd ../../vhdl/dataretxresponse.vhd ../../vhdl/eventrxbusoutput.vhd ../../vhdl/eventrxresponsewr.vhd ../../vhdl/eventrx.vhd ../../vhdl/datamempktretx.vhd ../../vhdl/datamempkttx.vhd ../../vhdl/datamempktinput.vhd ../../vhdl/datapacketgen.vhd ../../vhdl/datamemarbit.vhd
	$(VHDLC) -vital2000 ../../vhdl/datamemarbit.vhd

$(WORKDIR)/datafifo/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingresponse.vhd ../../vhdl/txmux.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../crc/vhdl/crcappend.vhd ../../vhdl/dataretxresponse.vhd ../../vhdl/eventrxbusoutput.vhd ../../vhdl/eventrxresponsewr.vhd ../../vhdl/eventrx.vhd ../../vhdl/datamempktretx.vhd ../../vhdl/datamempkttx.vhd ../../vhdl/datamempktinput.vhd ../../vhdl/datapacketgen.vhd ../../vhdl/datamemarbit.vhd ../../vhdl/datafifo.vhd
	$(VHDLC) -vital2000 ../../vhdl/datafifo.vhd

$(WORKDIR)/dataretxbuf/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingresponse.vhd ../../vhdl/txmux.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../crc/vhdl/crcappend.vhd ../../vhdl/dataretxresponse.vhd ../../vhdl/eventrxbusoutput.vhd ../../vhdl/eventrxresponsewr.vhd ../../vhdl/eventrx.vhd ../../vhdl/datamempktretx.vhd ../../vhdl/datamempkttx.vhd ../../vhdl/datamempktinput.vhd ../../vhdl/datapacketgen.vhd ../../vhdl/datamemarbit.vhd ../../vhdl/datafifo.vhd ../../vhdl/dataretxbuf.vhd
	$(VHDLC) -vital2000 ../../vhdl/dataretxbuf.vhd

$(WORKDIR)/dataacquire/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingresponse.vhd ../../vhdl/txmux.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../crc/vhdl/crcappend.vhd ../../vhdl/dataretxresponse.vhd ../../vhdl/eventrxbusoutput.vhd ../../vhdl/eventrxresponsewr.vhd ../../vhdl/eventrx.vhd ../../vhdl/datamempktretx.vhd ../../vhdl/datamempkttx.vhd ../../vhdl/datamempktinput.vhd ../../vhdl/datapacketgen.vhd ../../vhdl/datamemarbit.vhd ../../vhdl/datafifo.vhd ../../vhdl/dataretxbuf.vhd ../../vhdl/dataacquire.vhd
	$(VHDLC) -vital2000 ../../vhdl/dataacquire.vhd

$(WORKDIR)/data/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingresponse.vhd ../../vhdl/txmux.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../crc/vhdl/crcappend.vhd ../../vhdl/dataretxresponse.vhd ../../vhdl/eventrxbusoutput.vhd ../../vhdl/eventrxresponsewr.vhd ../../vhdl/eventrx.vhd ../../vhdl/datamempktretx.vhd ../../vhdl/datamempkttx.vhd ../../vhdl/datamempktinput.vhd ../../vhdl/datapacketgen.vhd ../../vhdl/datamemarbit.vhd ../../vhdl/datafifo.vhd ../../vhdl/dataretxbuf.vhd ../../vhdl/dataacquire.vhd ../../vhdl/data.vhd
	$(VHDLC) -vital2000 ../../vhdl/data.vhd

$(WORKDIR)/retxbuffer/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingresponse.vhd ../../vhdl/txmux.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../crc/vhdl/crcappend.vhd ../../vhdl/dataretxresponse.vhd ../../vhdl/eventrxbusoutput.vhd ../../vhdl/eventrxresponsewr.vhd ../../vhdl/eventrx.vhd ../../vhdl/datamempktretx.vhd ../../vhdl/datamempkttx.vhd ../../vhdl/datamempktinput.vhd ../../vhdl/datapacketgen.vhd ../../vhdl/datamemarbit.vhd ../../vhdl/datafifo.vhd ../../vhdl/dataretxbuf.vhd ../../vhdl/dataacquire.vhd ../../vhdl/data.vhd ../../vhdl/retxbuffer.vhd
	$(VHDLC) -vital2000 ../../vhdl/retxbuffer.vhd

$(WORKDIR)/bitcnt/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingresponse.vhd ../../vhdl/txmux.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../crc/vhdl/crcappend.vhd ../../vhdl/dataretxresponse.vhd ../../vhdl/eventrxbusoutput.vhd ../../vhdl/eventrxresponsewr.vhd ../../vhdl/eventrx.vhd ../../vhdl/datamempktretx.vhd ../../vhdl/datamempkttx.vhd ../../vhdl/datamempktinput.vhd ../../vhdl/datapacketgen.vhd ../../vhdl/datamemarbit.vhd ../../vhdl/datafifo.vhd ../../vhdl/dataretxbuf.vhd ../../vhdl/dataacquire.vhd ../../vhdl/data.vhd ../../vhdl/retxbuffer.vhd ../../vhdl/bitcnt.vhd
	$(VHDLC) -vital2000 ../../vhdl/bitcnt.vhd

$(WORKDIR)/eventtxpkfifo/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingresponse.vhd ../../vhdl/txmux.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../crc/vhdl/crcappend.vhd ../../vhdl/dataretxresponse.vhd ../../vhdl/eventrxbusoutput.vhd ../../vhdl/eventrxresponsewr.vhd ../../vhdl/eventrx.vhd ../../vhdl/datamempktretx.vhd ../../vhdl/datamempkttx.vhd ../../vhdl/datamempktinput.vhd ../../vhdl/datapacketgen.vhd ../../vhdl/datamemarbit.vhd ../../vhdl/datafifo.vhd ../../vhdl/dataretxbuf.vhd ../../vhdl/dataacquire.vhd ../../vhdl/data.vhd ../../vhdl/retxbuffer.vhd ../../vhdl/bitcnt.vhd ../../vhdl/eventtxpkfifo.vhd
	$(VHDLC) -vital2000 ../../vhdl/eventtxpkfifo.vhd

$(WORKDIR)/eventretxresponse/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingresponse.vhd ../../vhdl/txmux.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../crc/vhdl/crcappend.vhd ../../vhdl/dataretxresponse.vhd ../../vhdl/eventrxbusoutput.vhd ../../vhdl/eventrxresponsewr.vhd ../../vhdl/eventrx.vhd ../../vhdl/datamempktretx.vhd ../../vhdl/datamempkttx.vhd ../../vhdl/datamempktinput.vhd ../../vhdl/datapacketgen.vhd ../../vhdl/datamemarbit.vhd ../../vhdl/datafifo.vhd ../../vhdl/dataretxbuf.vhd ../../vhdl/dataacquire.vhd ../../vhdl/data.vhd ../../vhdl/retxbuffer.vhd ../../vhdl/bitcnt.vhd ../../vhdl/eventtxpkfifo.vhd ../../vhdl/eventretxresponse.vhd
	$(VHDLC) -vital2000 ../../vhdl/eventretxresponse.vhd

$(WORKDIR)/network/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingresponse.vhd ../../vhdl/txmux.vhd ../../crc/vhdl/crc_combinational.vhd ../../crc/vhdl/crc16_combinational.vhd ../../crc/vhdl/crcverify.vhd ../../crc/vhdl/crcappend.vhd ../../vhdl/dataretxresponse.vhd ../../vhdl/eventrxbusoutput.vhd ../../vhdl/eventrxresponsewr.vhd ../../vhdl/eventrx.vhd ../../vhdl/datamempktretx.vhd ../../vhdl/datamempkttx.vhd ../../vhdl/datamempktinput.vhd ../../vhdl/datapacketgen.vhd ../../vhdl/datamemarbit.vhd ../../vhdl/datafifo.vhd ../../vhdl/dataretxbuf.vhd ../../vhdl/dataacquire.vhd ../../vhdl/data.vhd ../../vhdl/retxbuffer.vhd ../../vhdl/bitcnt.vhd ../../vhdl/eventtxpkfifo.vhd ../../vhdl/eventretxresponse.vhd ../../vhdl/network.vhd
	$(VHDLC) -vital2000 ../../vhdl/network.vhd

hw: $(WORKDIR)/dqalign/_behavioral.var $(WORKDIR)/bootddr2/_behavioral.var $(WORKDIR)/readddr2/_behavioral.var $(WORKDIR)/refreshddr2/_behavioral.var $(WORKDIR)/writeddr2/_behavioral.var $(WORKDIR)/memcontmux/_behavioral.var $(WORKDIR)/memddr2/_behavioral.var $(WORKDIR)/networkstack/prim.var $(WORKDIR)/somabackplane/prim.var $(WORKDIR)/ipchecksum/_behavioral.var $(WORKDIR)/bigmem/_behavioral.var $(WORKDIR)/udpheaderwriter/_behavioral.var $(WORKDIR)/arpresponse/_behavioral.var $(WORKDIR)/eventbodywriter/_behavioral.var $(WORKDIR)/eventtx/_behavioral.var $(WORKDIR)/inputcontrol/_behavioral.var $(WORKDIR)/pingicmpwriter/_behavioral.var $(WORKDIR)/pingipwriter/_behavioral.var $(WORKDIR)/pingresponse/_behavioral.var $(WORKDIR)/txmux/_behavioral.var $(WORKDIR)/crc_combinational/_behavioral.var $(WORKDIR)/crc16_combinational/_behavioral.var $(WORKDIR)/crcverify/_behavioral.var $(WORKDIR)/crcappend/_behavioral.var $(WORKDIR)/dataretxresponse/_behavioral.var $(WORKDIR)/eventrxbusoutput/_behavioral.var $(WORKDIR)/eventrxresponsewr/_behavioral.var $(WORKDIR)/eventrx/_behavioral.var $(WORKDIR)/datamempktretx/_behavioral.var $(WORKDIR)/datamempkttx/_behavioral.var $(WORKDIR)/datamempktinput/_behavioral.var $(WORKDIR)/datapacketgen/_behavioral.var $(WORKDIR)/datamemarbit/_behavioral.var $(WORKDIR)/datafifo/_behavioral.var $(WORKDIR)/dataretxbuf/_behavioral.var $(WORKDIR)/dataacquire/_behavioral.var $(WORKDIR)/data/_behavioral.var $(WORKDIR)/retxbuffer/_behavioral.var $(WORKDIR)/bitcnt/_behavioral.var $(WORKDIR)/eventtxpkfifo/_behavioral.var $(WORKDIR)/eventretxresponse/_behavioral.var $(WORKDIR)/network/_behavioral.var 

comp: 

$(WORKDIR)/retxreq/_behavioral.var: retxreq.vhd
	$(VHDLC) -vital2000 retxreq.vhd

$(WORKDIR)/datareceiver/_behavioral.var: retxreq.vhd datareceiver.vhd
	$(VHDLC) -vital2000 datareceiver.vhd

$(WORKDIR)/eventreceiver/_behavioral.var: retxreq.vhd datareceiver.vhd eventreceiver.vhd
	$(VHDLC) -vital2000 eventreceiver.vhd

fmf.sym/conversions/prim.var: retxreq.vhd datareceiver.vhd eventreceiver.vhd ../../../memory/sim/components/freemodel/conversions.vhd
	$(VHDLC) -vital2000 -work fmf  ../../../memory/sim/components/freemodel/conversions.vhd

fmf.sym/ecl_package/prim.var: retxreq.vhd datareceiver.vhd eventreceiver.vhd ../../../memory/sim/components/freemodel/ecl_package.vhd
	$(VHDLC) -vital2000 -work fmf  ../../../memory/sim/components/freemodel/ecl_package.vhd

fmf.sym/ecl_utils/prim.var: retxreq.vhd datareceiver.vhd eventreceiver.vhd ../../../memory/sim/components/freemodel/ecl_utils.vhd
	$(VHDLC) -vital2000 -work fmf  ../../../memory/sim/components/freemodel/ecl_utils.vhd

fmf.sym/ff_package/prim.var: retxreq.vhd datareceiver.vhd eventreceiver.vhd ../../../memory/sim/components/freemodel/ff_package.vhd
	$(VHDLC) -vital2000 -work fmf  ../../../memory/sim/components/freemodel/ff_package.vhd

fmf.sym/gen_utils/prim.var: retxreq.vhd datareceiver.vhd eventreceiver.vhd ../../../memory/sim/components/freemodel/gen_utils.vhd
	$(VHDLC) -vital2000 -work fmf  ../../../memory/sim/components/freemodel/gen_utils.vhd

fmf.sym/memory/prim.var: retxreq.vhd datareceiver.vhd eventreceiver.vhd ../../../memory/sim/components/freemodel/memory.vhd
	$(VHDLC) -vital2000 -work fmf  ../../../memory/sim/components/freemodel/memory.vhd

fmf.sym/state_tab_package/prim.var: retxreq.vhd datareceiver.vhd eventreceiver.vhd ../../../memory/sim/components/freemodel/state_tab_package.vhd
	$(VHDLC) -vital2000 -work fmf  ../../../memory/sim/components/freemodel/state_tab_package.vhd

fmf.sym/switch_pkg/_behavior.var: retxreq.vhd datareceiver.vhd eventreceiver.vhd ../../../memory/sim/components/freemodel/switch_pkg.vhd
	$(VHDLC) -vital2000 -work fmf  ../../../memory/sim/components/freemodel/switch_pkg.vhd

$(WORKDIR)/mt47h64m16/_vhdl_behavioral.var: retxreq.vhd datareceiver.vhd eventreceiver.vhd ../../../memory/sim/components/freemodel/mt47h64m16.vhd
	$(VHDLC) -vital2000 ../../../memory/sim/components/freemodel/mt47h64m16.vhd

$(WORKDIR)/clockgen/_behavioral.var: retxreq.vhd datareceiver.vhd eventreceiver.vhd ../../../memory/sim/components/freemodel/mt47h64m16.vhd ../components/clockgen/clockgen.vhd
	$(VHDLC) -vital2000 ../components/clockgen/clockgen.vhd

$(WORKDIR)/networktest/_behavioral.var: retxreq.vhd datareceiver.vhd eventreceiver.vhd ../../../memory/sim/components/freemodel/mt47h64m16.vhd ../components/clockgen/clockgen.vhd networktest.vhd
	$(VHDLC) -vital2000 networktest.vhd

sim: $(WORKDIR)/retxreq/_behavioral.var $(WORKDIR)/datareceiver/_behavioral.var $(WORKDIR)/eventreceiver/_behavioral.var fmf.sym/conversions/prim.var fmf.sym/ecl_package/prim.var fmf.sym/ecl_utils/prim.var fmf.sym/ff_package/prim.var fmf.sym/gen_utils/prim.var fmf.sym/memory/prim.var fmf.sym/state_tab_package/prim.var fmf.sym/switch_pkg/_behavior.var $(WORKDIR)/mt47h64m16/_vhdl_behavioral.var $(WORKDIR)/clockgen/_behavioral.var $(WORKDIR)/networktest/_behavioral.var 
runsim: all
	$(VHDLS) networktest


clean:
	rm -Rf *.sym

