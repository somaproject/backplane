VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/dqalign/_behavioral.var: ../../../memory/vhdl/dqalign.vhd
	$(VHDLC) ../../../memory/vhdl/dqalign.vhd

$(WORKDIR)/bootddr2/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd
	$(VHDLC) ../../../memory/vhdl/bootddr2.vhd

$(WORKDIR)/readddr2/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd
	$(VHDLC) ../../../memory/vhdl/readddr2.vhd

$(WORKDIR)/refreshddr2/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd
	$(VHDLC) ../../../memory/vhdl/refreshddr2.vhd

$(WORKDIR)/writeddr2/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd
	$(VHDLC) ../../../memory/vhdl/writeddr2.vhd

$(WORKDIR)/memcontmux/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd
	$(VHDLC) ../../../memory/vhdl/memcontmux.vhd

$(WORKDIR)/memddr2/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd
	$(VHDLC) ../../../memory/vhdl/memddr2.vhd

$(WORKDIR)/networkstack/prim.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd
	$(VHDLC) ../../vhdl/networkstack.vhd

$(WORKDIR)/somabackplane/prim.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd
	$(VHDLC) ../../../vhdl/somabackplane.vhd

$(WORKDIR)/ipchecksum/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd
	$(VHDLC) ../../vhdl/ipchecksum.vhd

$(WORKDIR)/bigmem/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd
	$(VHDLC) ../../vhdl/bigmem.vhd

$(WORKDIR)/udpheaderwriter/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd
	$(VHDLC) ../../vhdl/udpheaderwriter.vhd

$(WORKDIR)/eventbodywriter/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/eventbodywriter.vhd
	$(VHDLC) ../../vhdl/eventbodywriter.vhd

$(WORKDIR)/eventtx/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd
	$(VHDLC) ../../vhdl/eventtx.vhd

$(WORKDIR)/inputcontrol/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd
	$(VHDLC) ../../vhdl/inputcontrol.vhd

$(WORKDIR)/txmux/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/txmux.vhd
	$(VHDLC) ../../vhdl/txmux.vhd

$(WORKDIR)/dataretxresponse/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/txmux.vhd ../../vhdl/dataretxresponse.vhd
	$(VHDLC) ../../vhdl/dataretxresponse.vhd

$(WORKDIR)/eventrxbusoutput/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/txmux.vhd ../../vhdl/dataretxresponse.vhd ../../vhdl/eventrxbusoutput.vhd
	$(VHDLC) ../../vhdl/eventrxbusoutput.vhd

$(WORKDIR)/eventrxresponsewr/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/txmux.vhd ../../vhdl/dataretxresponse.vhd ../../vhdl/eventrxbusoutput.vhd ../../vhdl/eventrxresponsewr.vhd
	$(VHDLC) ../../vhdl/eventrxresponsewr.vhd

$(WORKDIR)/eventrx/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/txmux.vhd ../../vhdl/dataretxresponse.vhd ../../vhdl/eventrxbusoutput.vhd ../../vhdl/eventrxresponsewr.vhd ../../vhdl/eventrx.vhd
	$(VHDLC) ../../vhdl/eventrx.vhd

$(WORKDIR)/datafifo/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/txmux.vhd ../../vhdl/dataretxresponse.vhd ../../vhdl/eventrxbusoutput.vhd ../../vhdl/eventrxresponsewr.vhd ../../vhdl/eventrx.vhd ../../vhdl/datafifo.vhd
	$(VHDLC) ../../vhdl/datafifo.vhd

$(WORKDIR)/dataretxbuf/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/txmux.vhd ../../vhdl/dataretxresponse.vhd ../../vhdl/eventrxbusoutput.vhd ../../vhdl/eventrxresponsewr.vhd ../../vhdl/eventrx.vhd ../../vhdl/datafifo.vhd ../../vhdl/dataretxbuf.vhd
	$(VHDLC) ../../vhdl/dataretxbuf.vhd

$(WORKDIR)/dataacquire/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/txmux.vhd ../../vhdl/dataretxresponse.vhd ../../vhdl/eventrxbusoutput.vhd ../../vhdl/eventrxresponsewr.vhd ../../vhdl/eventrx.vhd ../../vhdl/datafifo.vhd ../../vhdl/dataretxbuf.vhd ../../vhdl/dataacquire.vhd
	$(VHDLC) ../../vhdl/dataacquire.vhd

$(WORKDIR)/data/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/txmux.vhd ../../vhdl/dataretxresponse.vhd ../../vhdl/eventrxbusoutput.vhd ../../vhdl/eventrxresponsewr.vhd ../../vhdl/eventrx.vhd ../../vhdl/datafifo.vhd ../../vhdl/dataretxbuf.vhd ../../vhdl/dataacquire.vhd ../../vhdl/data.vhd
	$(VHDLC) ../../vhdl/data.vhd

$(WORKDIR)/retxbuffer/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/txmux.vhd ../../vhdl/dataretxresponse.vhd ../../vhdl/eventrxbusoutput.vhd ../../vhdl/eventrxresponsewr.vhd ../../vhdl/eventrx.vhd ../../vhdl/datafifo.vhd ../../vhdl/dataretxbuf.vhd ../../vhdl/dataacquire.vhd ../../vhdl/data.vhd ../../vhdl/retxbuffer.vhd
	$(VHDLC) ../../vhdl/retxbuffer.vhd

$(WORKDIR)/bitcnt/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/txmux.vhd ../../vhdl/dataretxresponse.vhd ../../vhdl/eventrxbusoutput.vhd ../../vhdl/eventrxresponsewr.vhd ../../vhdl/eventrx.vhd ../../vhdl/datafifo.vhd ../../vhdl/dataretxbuf.vhd ../../vhdl/dataacquire.vhd ../../vhdl/data.vhd ../../vhdl/retxbuffer.vhd ../../vhdl/bitcnt.vhd
	$(VHDLC) ../../vhdl/bitcnt.vhd

$(WORKDIR)/eventtxpkfifo/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/txmux.vhd ../../vhdl/dataretxresponse.vhd ../../vhdl/eventrxbusoutput.vhd ../../vhdl/eventrxresponsewr.vhd ../../vhdl/eventrx.vhd ../../vhdl/datafifo.vhd ../../vhdl/dataretxbuf.vhd ../../vhdl/dataacquire.vhd ../../vhdl/data.vhd ../../vhdl/retxbuffer.vhd ../../vhdl/bitcnt.vhd ../../vhdl/eventtxpkfifo.vhd
	$(VHDLC) ../../vhdl/eventtxpkfifo.vhd

$(WORKDIR)/eventretxresponse/_behavioral.var: ../../../memory/vhdl/dqalign.vhd ../../../memory/vhdl/bootddr2.vhd ../../../memory/vhdl/readddr2.vhd ../../../memory/vhdl/refreshddr2.vhd ../../../memory/vhdl/writeddr2.vhd ../../../memory/vhdl/memcontmux.vhd ../../../memory/vhdl/memddr2.vhd ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/bigmem.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/txmux.vhd ../../vhdl/dataretxresponse.vhd ../../vhdl/eventrxbusoutput.vhd ../../vhdl/eventrxresponsewr.vhd ../../vhdl/eventrx.vhd ../../vhdl/datafifo.vhd ../../vhdl/dataretxbuf.vhd ../../vhdl/dataacquire.vhd ../../vhdl/data.vhd ../../vhdl/retxbuffer.vhd ../../vhdl/bitcnt.vhd ../../vhdl/eventtxpkfifo.vhd ../../vhdl/eventretxresponse.vhd
	$(VHDLC) ../../vhdl/eventretxresponse.vhd

hw: $(WORKDIR)/dqalign/_behavioral.var $(WORKDIR)/bootddr2/_behavioral.var $(WORKDIR)/readddr2/_behavioral.var $(WORKDIR)/refreshddr2/_behavioral.var $(WORKDIR)/writeddr2/_behavioral.var $(WORKDIR)/memcontmux/_behavioral.var $(WORKDIR)/memddr2/_behavioral.var $(WORKDIR)/networkstack/prim.var $(WORKDIR)/somabackplane/prim.var $(WORKDIR)/ipchecksum/_behavioral.var $(WORKDIR)/bigmem/_behavioral.var $(WORKDIR)/udpheaderwriter/_behavioral.var $(WORKDIR)/eventbodywriter/_behavioral.var $(WORKDIR)/eventtx/_behavioral.var $(WORKDIR)/inputcontrol/_behavioral.var $(WORKDIR)/txmux/_behavioral.var $(WORKDIR)/dataretxresponse/_behavioral.var $(WORKDIR)/eventrxbusoutput/_behavioral.var $(WORKDIR)/eventrxresponsewr/_behavioral.var $(WORKDIR)/eventrx/_behavioral.var $(WORKDIR)/datafifo/_behavioral.var $(WORKDIR)/dataretxbuf/_behavioral.var $(WORKDIR)/dataacquire/_behavioral.var $(WORKDIR)/data/_behavioral.var $(WORKDIR)/retxbuffer/_behavioral.var $(WORKDIR)/bitcnt/_behavioral.var $(WORKDIR)/eventtxpkfifo/_behavioral.var $(WORKDIR)/eventretxresponse/_behavioral.var 

comp: 

$(WORKDIR)/clockgen/_behavioral.var: ../components/clockgen/clockgen.vhd
	$(VHDLC) ../components/clockgen/clockgen.vhd

$(WORKDIR)/hy5ps121621f_pack/prim.var: ../components/clockgen/clockgen.vhd ../../../memory/sim/components/hynix/HY5PS121621F_PACK.vhd
	$(VHDLC) ../../../memory/sim/components/hynix/HY5PS121621F_PACK.vhd

$(WORKDIR)/hy5ps121621f/_behavioral_model_hy5ps121621f.var: ../components/clockgen/clockgen.vhd ../../../memory/sim/components/hynix/HY5PS121621F_PACK.vhd ../../../memory/sim/components/hynix/HY5PS121621F.vhd
	$(VHDLC) ../../../memory/sim/components/hynix/HY5PS121621F.vhd

$(WORKDIR)/retxreq/_behavioral.var: ../components/clockgen/clockgen.vhd ../../../memory/sim/components/hynix/HY5PS121621F_PACK.vhd ../../../memory/sim/components/hynix/HY5PS121621F.vhd retxreq.vhd
	$(VHDLC) retxreq.vhd

$(WORKDIR)/eventrxdecode/_behavioral.var: ../components/clockgen/clockgen.vhd ../../../memory/sim/components/hynix/HY5PS121621F_PACK.vhd ../../../memory/sim/components/hynix/HY5PS121621F.vhd retxreq.vhd eventrxdecode.vhd
	$(VHDLC) eventrxdecode.vhd

$(WORKDIR)/eventretxtest/_behavioral.var: ../components/clockgen/clockgen.vhd ../../../memory/sim/components/hynix/HY5PS121621F_PACK.vhd ../../../memory/sim/components/hynix/HY5PS121621F.vhd retxreq.vhd eventrxdecode.vhd eventretxtest.vhd
	$(VHDLC) eventretxtest.vhd

sim: $(WORKDIR)/clockgen/_behavioral.var $(WORKDIR)/hy5ps121621f_pack/prim.var $(WORKDIR)/hy5ps121621f/_behavioral_model_hy5ps121621f.var $(WORKDIR)/retxreq/_behavioral.var $(WORKDIR)/eventrxdecode/_behavioral.var $(WORKDIR)/eventretxtest/_behavioral.var 
runsim: all
	$(VHDLS) eventretxtest


clean:
	rm -Rf $(WORKDIR)$

